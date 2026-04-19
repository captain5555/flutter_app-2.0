import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:app_settings/app_settings.dart';
import '../../models/material.dart';
import '../../providers/settings_provider.dart';
import '../../providers/material_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';
import '../../constants/theme_constants.dart';
import '../../l10n/app_localizations.dart';

class MaterialDetailScreen extends StatefulWidget {
  final Material material;

  const MaterialDetailScreen({super.key, required this.material});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _usageTag;
  late String _viralTag;
  bool _isLoading = false;
  bool _isEdited = false;
  bool _isAiGenerating = false;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  String? _currentScreenshot;

  final AiService _aiService = AiService();

  final List<String> _usageTags = ['unused', 'used', 'viral_candidate'];
  final List<String> _viralTags = ['not_viral', 'monitoring', 'viral'];

  String _getUsageTagLabel(String tag, AppLocalizations l10n) {
    switch (tag) {
      case 'unused':
        return l10n.unused;
      case 'used':
        return l10n.used;
      case 'viral_candidate':
        return l10n.viralCandidate;
      default:
        return tag;
    }
  }

  String _getViralTagLabel(String tag, AppLocalizations l10n) {
    switch (tag) {
      case 'not_viral':
        return l10n.notViral;
      case 'monitoring':
        return l10n.monitoring;
      case 'viral':
        return l10n.viral;
      default:
        return tag;
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.material.title ?? '');
    _descriptionController = TextEditingController(text: widget.material.description ?? '');
    _usageTag = widget.material.usageTag;
    _viralTag = widget.material.viralTag;

    _titleController.addListener(_onChanged);
    _descriptionController.addListener(_onChanged);

    // 初始化视频播放器
    if (widget.material.isVideo) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final mediaUrl = _getMediaUrl(settingsProvider.baseUrl);
      if (mediaUrl != null) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(mediaUrl));
        _videoController!.initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _isVideoError = true;
            });
          }
        });
      }
    }
  }

  void _onChanged() {
    setState(() {
      _isEdited = _titleController.text != (widget.material.title ?? '') ||
          _descriptionController.text != (widget.material.description ?? '') ||
          _usageTag != widget.material.usageTag ||
          _viralTag != widget.material.viralTag;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!_isEdited) return;

    setState(() => _isLoading = true);

    try {
      await context.read<MaterialProvider>().updateMaterial(
        widget.material.id,
        {
          'title': _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          'usage_tag': _usageTag,
          'viral_tag': _viralTag,
        },
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.saveFailed),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: Text(l10n.ok),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _takeScreenshot(AppLocalizations l10n) async {
    // 在Web端，video_player插件不支持直接截图
    // 这里我们显示一个提示，告诉用户这个功能在Web端暂不可用
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(l10n.noticeFeatureUnavailable),
          content: Text(l10n.videoScreenshotWebUnavailable),
          actions: [
            CupertinoDialogAction(
              child: Text(l10n.ok),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _generateTitle(AppLocalizations l10n) async {
    setState(() => _isAiGenerating = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final title = await _aiService.generateTitle(
        currentUserId: authProvider.user?.id,
        currentTitle: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      );
      setState(() {
        _titleController.text = title;
      });
      _onChanged();
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.generateFailed),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: Text(l10n.ok),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAiGenerating = false);
      }
    }
  }

  Future<void> _generateDescription(AppLocalizations l10n) async {
    setState(() => _isAiGenerating = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final description = await _aiService.generateDescription(
        currentUserId: authProvider.user?.id,
        currentDescription: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      );
      setState(() {
        _descriptionController.text = description;
      });
      _onChanged();
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.generateFailed),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: Text(l10n.ok),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAiGenerating = false);
      }
    }
  }

  void _showTranslateOptions({required bool isTitle, required AppLocalizations l10n}) {
    final text = isTitle ? _titleController.text.trim() : _descriptionController.text.trim();
    if (text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(l10n.notice),
          content: Text(l10n.pleaseEnterContent),
          actions: [
            CupertinoDialogAction(
              child: Text(l10n.ok),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(l10n.selectTranslationDirection),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _translate(isTitle: isTitle, toEnglish: true, l10n: l10n);
            },
            child: Text(l10n.chineseToEnglish),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _translate(isTitle: isTitle, toEnglish: false, l10n: l10n);
            },
            child: Text(l10n.englishToChinese),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  Future<void> _translate({required bool isTitle, required bool toEnglish, required AppLocalizations l10n}) async {
    final text = isTitle ? _titleController.text.trim() : _descriptionController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isAiGenerating = true);
    try {
      String translated;
      if (toEnglish) {
        translated = await _aiService.translateToEnglish(text);
      } else {
        // 英译汉需要后端支持，目前先用中译英模拟
        translated = await _aiService.translateToChinese(text);
      }

      setState(() {
        if (isTitle) {
          _titleController.text = translated;
        } else {
          _descriptionController.text = translated;
        }
      });
      _onChanged();
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        // 移除本地的错误掩盖，显示真实的错误信息
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.translateFailed),
            content: Text(errorMsg),
            actions: [
              CupertinoDialogAction(
                child: Text(l10n.ok),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAiGenerating = false);
      }
    }
  }

  Future<void> _downloadMedia(AppLocalizations l10n) async {
    setState(() => _isLoading = true);
    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final mediaUrl = _getMediaUrl(settingsProvider.baseUrl);

      if (mediaUrl == null) {
        throw Exception('Unable to get media link');
      }

      // Android需要存储权限
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission is required to download, please enable it in settings');
        }
      }

      // iOS权限由image_gallery_saver自动处理

      // 下载文件
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/${widget.material.fileName}';

      await dio.download(
        mediaUrl,
        savePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      // 保存到相册 - iOS权限由image_gallery_saver自动处理
      final result = await ImageGallerySaver.saveFile(
        savePath,
        name: widget.material.fileName,
      );

      if (result['isSuccess'] == true) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: Text(widget.material.isVideo ? l10n.downloadSuccess : l10n.saveSuccess),
              content: Text(widget.material.isVideo
                  ? l10n.videoSavedToAlbum
                  : l10n.imageSavedToAlbum),
              actions: [
                CupertinoDialogAction(
                  child: Text(l10n.ok),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception(result['errorMessage'] ?? l10n.saveToAlbumFailed);
      }

      // 清理临时文件
      try {
        final tempFile = File(savePath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {
        // 忽略清理错误
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.downloadFailed),
            content: Text(e.toString()),
            actions: [
              if (Platform.isIOS)
                CupertinoDialogAction(
                  child: Text(l10n.goToSettings),
                  onPressed: () {
                    Navigator.pop(ctx);
                    AppSettings.openAppSettings();
                  },
                ),
              CupertinoDialogAction(
                child: Text(l10n.ok),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _copyToClipboard(String text, AppLocalizations l10n) async {
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(l10n.copied),
          content: Text(l10n.contentCopiedToClipboard),
          actions: [
            CupertinoDialogAction(
              child: Text(l10n.ok),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    }
  }

  String? _getMediaUrl(String baseUrl) {
    // 优先使用后端提供的完整 file_url
    if (widget.material.fileUrl != null && widget.material.fileUrl!.isNotEmpty) {
      return _buildFullUrl(baseUrl, widget.material.fileUrl!);
    }
    if (widget.material.filePath.isEmpty) return null;
    return _buildFullUrl(baseUrl, widget.material.filePath);
  }

  String _buildFullUrl(String baseUrl, String path) {
    // 如果已经是完整URL，直接返回
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // 如果是以 / 开头，拼接到 baseUrl
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }
    // 其他情况，加上 /uploads/
    return '$baseUrl/uploads/$path';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final l10n = AppLocalizations(settingsProvider.locale);
        final mediaUrl = _getMediaUrl(settingsProvider.baseUrl);

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(widget.material.displayTitle),
            trailing: _isLoading
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _isEdited ? () => _save(l10n) : null,
                    child: Text(
                      l10n.save,
                      style: TextStyle(
                        color: _isEdited ? CupertinoTheme.of(context).primaryColor : CupertinoColors.inactiveGray,
                      ),
                    ),
                  ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(ThemeConstants.spacingMd),
              children: [
                // Media Preview
                if (mediaUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMd),
                    child: widget.material.isImage
                        ? CachedNetworkImage(
                            imageUrl: mediaUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              height: 300,
                              color: CupertinoColors.systemGrey5,
                              child: const Center(child: CupertinoActivityIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 300,
                              color: CupertinoColors.systemGrey5,
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.photo,
                                  size: 60,
                                  color: CupertinoColors.systemGrey3,
                                ),
                              ),
                            ),
                          )
                        : _isVideoError
                            ? Container(
                                height: 300,
                                color: CupertinoColors.systemGrey5,
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.exclamationmark_triangle,
                                    size: 60,
                                    color: CupertinoColors.systemGrey3,
                                  ),
                                ),
                              )
                            : _isVideoInitialized
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: _videoController!.value.aspectRatio,
                                        child: VideoPlayer(_videoController!),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (_videoController!.value.isPlaying) {
                                              _videoController!.pause();
                                            } else {
                                              _videoController!.play();
                                            }
                                          });
                                        },
                                        child: Container(
                                          color: CupertinoColors.black.withOpacity(0.3),
                                          child: Icon(
                                            _videoController!.value.isPlaying
                                                ? CupertinoIcons.pause_circle_fill
                                                : CupertinoIcons.play_circle_fill,
                                            size: 60,
                                            color: CupertinoColors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    height: 300,
                                    color: CupertinoColors.systemGrey5,
                                    child: const Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                  ),
                  ),
                // Screenshot button for videos
                if (widget.material.isVideo && _isVideoInitialized)
                  Padding(
                    padding: const EdgeInsets.only(top: ThemeConstants.spacingMd),
                    child: CupertinoButton.filled(
                      onPressed: () => _takeScreenshot(l10n),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.camera, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.screenshot),
                        ],
                      ),
                    ),
                  ),
                // Show screenshot if available
                if (_currentScreenshot != null)
                  Padding(
                    padding: const EdgeInsets.only(top: ThemeConstants.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.screenshotSelected,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: ThemeConstants.spacingSm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMd),
                          child: Image.network(
                            _currentScreenshot!,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: ThemeConstants.spacingLg),

                // Title
                _buildSection(
                  title: l10n.basicInfo,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextFieldWithActions(
                        l10n: l10n,
                        controller: _titleController,
                        placeholder: l10n.title,
                        minLines: 1,
                        maxLines: 3,
                        onGenerate: () => _generateTitle(l10n),
                        onTranslate: () => _showTranslateOptions(isTitle: true, l10n: l10n),
                      ),
                      const SizedBox(height: ThemeConstants.spacingMd),
                      _buildTextFieldWithActions(
                        l10n: l10n,
                        controller: _descriptionController,
                        placeholder: l10n.description,
                        minLines: 3,
                        maxLines: 10,
                        onGenerate: () => _generateDescription(l10n),
                        onTranslate: () => _showTranslateOptions(isTitle: false, l10n: l10n),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ThemeConstants.spacingLg),

                // Usage Tag
                _buildSection(
                  title: l10n.usageStatus,
                  child: _buildSegmentedControl(
                    l10n: l10n,
                    value: _usageTag,
                    options: _usageTags,
                    labels: _usageTags.map((tag) => _getUsageTagLabel(tag, l10n)).toList(),
                    onChanged: (value) {
                      setState(() {
                        _usageTag = value;
                        _onChanged();
                      });
                    },
                  ),
                ),
                const SizedBox(height: ThemeConstants.spacingLg),

                // Viral Tag
                _buildSection(
                  title: l10n.viralStatus,
                  child: _buildSegmentedControl(
                    l10n: l10n,
                    value: _viralTag,
                    options: _viralTags,
                    labels: _viralTags.map((tag) => _getViralTagLabel(tag, l10n)).toList(),
                    onChanged: (value) {
                      setState(() {
                        _viralTag = value;
                        _onChanged();
                      });
                    },
                  ),
                ),
                const SizedBox(height: ThemeConstants.spacingLg),

                // File Info
                _buildSection(
                  title: l10n.fileInfo,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(l10n.fileName, widget.material.fileName),
                      const SizedBox(height: ThemeConstants.spacingSm),
                      _buildInfoRow(l10n.size, widget.material.fileSizeFormatted),
                      const SizedBox(height: ThemeConstants.spacingSm),
                      _buildInfoRow(l10n.type, widget.material.folderType),
                      if (widget.material.createdAt != null) ...[
                        const SizedBox(height: ThemeConstants.spacingSm),
                        _buildInfoRow(l10n.uploadTime, _formatDate(widget.material.createdAt!)),
                      ],
                      const SizedBox(height: ThemeConstants.spacingMd),
                      CupertinoButton.filled(
                        onPressed: _isLoading ? null : () => _downloadMedia(l10n),
                        child: _isLoading
                            ? const CupertinoActivityIndicator()
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(CupertinoIcons.arrow_down_doc, size: 18),
                                  const SizedBox(width: 8),
                                  Text(widget.material.isVideo ? l10n.downloadVideo : l10n.downloadImage),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingSm),
        child,
      ],
    );
  }

  Widget _buildTextFieldWithActions({
    required AppLocalizations l10n,
    required TextEditingController controller,
    required String placeholder,
    int minLines = 1,
    int maxLines = 1,
    required VoidCallback onGenerate,
    required VoidCallback onTranslate,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMd,
        vertical: ThemeConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            minLines: minLines,
            maxLines: maxLines,
            decoration: null,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: ThemeConstants.spacingSm),
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.spacingMd,
                  vertical: ThemeConstants.spacingSm,
                ),
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                onPressed: _isAiGenerating ? null : onGenerate,
                child: _isAiGenerating
                    ? const CupertinoActivityIndicator()
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.sparkles, size: 16),
                          const SizedBox(width: 4),
                          Text(l10n.aiGenerate, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
              ),
              const SizedBox(width: ThemeConstants.spacingSm),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.spacingMd,
                  vertical: ThemeConstants.spacingSm,
                ),
                color: CupertinoColors.systemGrey5,
                onPressed: _isAiGenerating ? null : onTranslate,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.globe, size: 16),
                    const SizedBox(width: 4),
                    Text(l10n.translateText, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: ThemeConstants.spacingSm),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.spacingMd,
                  vertical: ThemeConstants.spacingSm,
                ),
                color: CupertinoColors.systemGrey5,
                onPressed: controller.text.isEmpty ? null : () => _copyToClipboard(controller.text, l10n),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.doc_on_doc, size: 16),
                    const SizedBox(width: 4),
                    Text(l10n.copy, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl({
    required AppLocalizations l10n,
    required String value,
    required List<String> options,
    required List<String> labels,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = value == option;
        final isFirst = index == 0;
        final isLast = index == options.length - 1;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(option),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingMd),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoTheme.of(context).primaryColor
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.horizontal(
                  left: isFirst ? const Radius.circular(ThemeConstants.borderRadiusMd) : Radius.zero,
                  right: isLast ? const Radius.circular(ThemeConstants.borderRadiusMd) : Radius.zero,
                ),
                border: Border.all(
                  color: isSelected
                      ? CupertinoTheme.of(context).primaryColor
                      : CupertinoColors.systemGrey5,
                  width: 1,
                ),
              ),
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? CupertinoColors.white : CupertinoColors.label,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
