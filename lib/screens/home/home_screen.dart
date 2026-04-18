import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/material_provider.dart';
import '../../constants/theme_constants.dart';
import '../../widgets/material_card.dart';
import '../../models/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../login/login_screen.dart';
import '../settings/settings_screen.dart';
import '../trash/trash_screen.dart';
import '../material/material_detail_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMaterials();
    });
  }

  Future<void> _loadMaterials() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await context.read<MaterialProvider>().loadMaterials(authProvider.user!);
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.photo),
            label: '素材',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.trash),
            label: '垃圾箱',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: '设置',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        if (index == 0) {
          return _MaterialsTab(
            onLogout: _logout,
            onRefresh: _loadMaterials,
          );
        } else if (index == 1) {
          return const TrashScreen();
        } else {
          return const SettingsScreen();
        }
      },
    );
  }
}

class _MaterialsTab extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onRefresh;

  const _MaterialsTab({
    required this.onLogout,
    required this.onRefresh,
  });

  @override
  State<_MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends State<_MaterialsTab> {
  final Set<int> _selectedIds = {};
  bool _isSelectionMode = false;
  String _currentFolder = 'images';
  List<User> _users = [];
  bool _isLoadingUsers = false;
  int? _viewingUserId;

  final List<String> _folders = ['images', 'videos'];
  final UserService _userService = UserService();

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
        if (!_isSelectionMode) {
          _isSelectionMode = true;
          _loadUsers();
        }
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _loadUsers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.role != 'admin') return;

    setState(() => _isLoadingUsers = true);
    try {
      final users = await _userService.getUsers();
      // 过滤掉管理员自己
      setState(() {
        _users = users.where((u) => u.id != authProvider.user?.id).toList();
      });
    } catch (e) {
      print('Failed to load users: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
      }
    }
  }

  Future<void> _switchFolder(String folder) async {
    setState(() {
      _currentFolder = folder;
    });
    context.read<MaterialProvider>().setFolder(folder);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await context.read<MaterialProvider>().loadMaterials(
        authProvider.user!,
        viewingUserId: _viewingUserId,
      );
    }
  }

  void _showUserSwitcher() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.role != 'admin') return;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('选择查看用户'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _switchViewingUser(null);
            },
            child: Text('${authProvider.user?.username} (我)'),
          ),
          ..._users.where((u) => u.id != authProvider.user?.id).map((user) => CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  _switchViewingUser(user.id);
                },
                child: Text(user.username),
              )),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
  }

  Future<void> _switchViewingUser(int? userId) async {
    setState(() {
      _viewingUserId = userId;
      _selectedIds.clear();
      _isSelectionMode = false;
    });
    context.read<MaterialProvider>().setViewingUser(userId);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await context.read<MaterialProvider>().loadMaterials(
        authProvider.user!,
        viewingUserId: userId,
      );
    }
  }

  Future<void> _handleBatchTrash() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('确认删除 ${_selectedIds.length} 项？'),
        content: const Text('删除的素材将移到垃圾箱'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('删除'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<MaterialProvider>().batchTrash(_selectedIds.toList());
      _exitSelectionMode();
    }
  }

  void _showCopyDialog() {
    if (_users.isEmpty && !_isLoadingUsers) {
      _loadUsers();
    }

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('复制 ${_selectedIds.length} 项到'),
        content: _isLoadingUsers
            ? const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CupertinoActivityIndicator(),
              )
            : _users.isEmpty
                ? const Text('暂无其他用户')
                : null,
        actions: [
          if (!_isLoadingUsers)
            ..._users.map((user) => CupertinoDialogAction(
                  child: Text(user.username),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _handleCopy(user);
                  },
                )),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('取消'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog() {
    if (_users.isEmpty && !_isLoadingUsers) {
      _loadUsers();
    }

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('移动 ${_selectedIds.length} 项到'),
        content: _isLoadingUsers
            ? const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CupertinoActivityIndicator(),
              )
            : _users.isEmpty
                ? const Text('暂无其他用户')
                : null,
        actions: [
          if (!_isLoadingUsers)
            ..._users.map((user) => CupertinoDialogAction(
                  child: Text(user.username),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showFolderSelectionForMove(user);
                  },
                )),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('取消'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showFolderSelectionForMove(User targetUser) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('选择目标文件夹（${targetUser.username}）'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _handleMove(targetUser, 'images');
            },
            child: const Text('图片'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _handleMove(targetUser, 'videos');
            },
            child: const Text('视频'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
  }

  Future<void> _handleCopy(User targetUser) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    // Show loading
    if (mounted) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('复制到 ${targetUser.username}...'),
          content: const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: CupertinoActivityIndicator(),
            ),
          ),
        ),
      );
    }

    try {
      final success = await context.read<MaterialProvider>().batchCopy(
        _selectedIds.toList(),
        targetUser.id,
        authProvider.user!,
      );

      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _exitSelectionMode();

        if (success) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: const Text('复制成功'),
              content: Text('已复制到 ${targetUser.username}'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('确定'),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('复制失败'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _handleMove(User targetUser, String targetFolder) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    // Show loading
    if (mounted) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('移动到 ${targetUser.username}...'),
          content: const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: CupertinoActivityIndicator(),
            ),
          ),
        ),
      );
    }

    try {
      final success = await context.read<MaterialProvider>().batchMove(
        _selectedIds.toList(),
        targetUser.id,
        targetFolder,
        authProvider.user!,
      );

      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _exitSelectionMode();

        if (success) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: const Text('移动成功'),
              content: Text('已移动到 ${targetUser.username}'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('确定'),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('移动失败'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showUploadOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('选择上传方式'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _pickFromGallery();
            },
            child: const Text('相册选择'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _takePhoto();
            },
            child: const Text('拍照'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _pickFile();
            },
            child: const Text('文件选择'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    XFile? file;

    if (_currentFolder == 'videos') {
      file = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      file = await picker.pickImage(source: ImageSource.gallery);
    }

    if (file != null && mounted) {
      final bytes = await file.readAsBytes();
      await _uploadFile(bytes, file.name);
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    XFile? file;

    if (_currentFolder == 'videos') {
      file = await picker.pickVideo(source: ImageSource.camera);
    } else {
      file = await picker.pickImage(source: ImageSource.camera);
    }

    if (file != null && mounted) {
      final bytes = await file.readAsBytes();
      await _uploadFile(bytes, file.name);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'mp4', 'mov', 'avi'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null && mounted) {
      await _uploadFile(
        result.files.single.bytes!,
        result.files.single.name,
      );
    }
  }

  Future<void> _uploadFile(List<int> bytes, String fileName) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    // Show loading
    if (mounted) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const CupertinoAlertDialog(
          title: Text('上传中...'),
          content: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: CupertinoActivityIndicator(),
            ),
          ),
        ),
      );
    }

    try {
      await Provider.of<MaterialProvider>(context, listen: false).uploadMaterial(
        userId: authProvider.user!.id,
        bytes: bytes,
        fileName: fileName,
        folderType: _currentFolder,
      );

      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        widget.onRefresh();
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('上传成功'),
            actions: [
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('上传失败'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final materialProvider = context.watch<MaterialProvider>();
    final isAdmin = authProvider.user?.role == 'admin';
    final viewingUser = isAdmin
        ? (_viewingUserId != null
            ? _users.firstWhere((u) => u.id == _viewingUserId, orElse: () => authProvider.user!)
            : authProvider.user!)
        : authProvider.user;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: _isSelectionMode
            ? Text('已选择 ${_selectedIds.length} 项')
            : GestureDetector(
                onTap: isAdmin ? _showUserSwitcher : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(viewingUser?.username ?? '素材'),
                    if (isAdmin) ...[
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 14,
                      ),
                    ],
                  ],
                ),
              ),
        leading: _isSelectionMode
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('取消'),
                onPressed: _exitSelectionMode,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isSelectionMode) ...[
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.plus),
                onPressed: _showUploadOptions,
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.square_arrow_right),
                onPressed: widget.onLogout,
              ),
            ],
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Folder Switcher
            if (!_isSelectionMode)
              Padding(
                padding: const EdgeInsets.all(ThemeConstants.spacingMd),
                child: _buildFolderSwitcher(),
              ),
            Expanded(
              child: _buildContent(),
            ),
            // Batch Action Bar
            if (_isSelectionMode)
              _buildBatchActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderSwitcher() {
    return Row(
      children: _folders.map((folder) {
        final isSelected = _currentFolder == folder;
        final isFirst = folder == _folders.first;
        final isLast = folder == _folders.last;

        return Expanded(
          child: GestureDetector(
            onTap: () => _switchFolder(folder),
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
              ),
              child: Text(
                folder == 'images' ? '图片' : '视频',
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

  Widget _buildContent() {
    return Consumer<MaterialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.materials.isEmpty) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (provider.error != null && provider.materials.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '加载失败',
                  style: TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  onPressed: widget.onRefresh,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (provider.materials.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _currentFolder == 'images'
                      ? CupertinoIcons.photo_on_rectangle
                      : CupertinoIcons.video_camera,
                  size: 60,
                  color: CupertinoColors.systemGrey3,
                ),
                const SizedBox(height: ThemeConstants.spacingMd),
                const Text(
                  '暂无素材',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(ThemeConstants.spacingMd),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: ThemeConstants.spacingMd,
            mainAxisSpacing: ThemeConstants.spacingMd,
          ),
          itemCount: provider.materials.length,
          itemBuilder: (context, index) {
            final material = provider.materials[index];
            return MaterialCard(
              material: material,
              isSelected: _selectedIds.contains(material.id),
              onTap: () {
                if (_isSelectionMode) {
                  _toggleSelection(material.id);
                } else {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (ctx) => MaterialDetailScreen(material: material),
                    ),
                  ).then((result) {
                    if (result == true) {
                      widget.onRefresh();
                    }
                  });
                }
              },
              onLongPress: () {
                _toggleSelection(material.id);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBatchActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMd,
        vertical: ThemeConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: CupertinoIcons.trash,
            label: '删除',
            isDestructive: true,
            onPressed: _handleBatchTrash,
          ),
          const SizedBox(width: ThemeConstants.spacingSm),
          _buildActionButton(
            icon: CupertinoIcons.doc_on_doc,
            label: '复制',
            onPressed: _showCopyDialog,
          ),
          const SizedBox(width: ThemeConstants.spacingSm),
          _buildActionButton(
            icon: CupertinoIcons.arrow_right,
            label: '移动',
            onPressed: _showMoveDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isDestructive = false,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingSm),
        color: isDestructive
            ? CupertinoColors.systemRed.withOpacity(0.15)
            : CupertinoColors.systemGrey6,
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? CupertinoColors.systemRed : null,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDestructive ? CupertinoColors.systemRed : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
