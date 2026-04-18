import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';
import '../../constants/theme_constants.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final AiService _aiService = AiService();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  int _currentTab = 0;

  final _apiUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  final _titlePromptController = TextEditingController();
  final _descriptionPromptController = TextEditingController();
  final _safetyRulesController = TextEditingController();
  final _replacementWordsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final settings = await _aiService.getAiSettings();
      _apiUrlController.text = settings['api_url'] ?? '';
      _apiKeyController.text = settings['api_key'] ?? '';
      _modelController.text = settings['model'] ?? '';
      _titlePromptController.text = settings['title_prompt'] ?? '';
      _descriptionPromptController.text = settings['description_prompt'] ?? '';
      _safetyRulesController.text = settings['safety_rules'] ?? '';
      _replacementWordsController.text = settings['replacement_words'] ?? '';
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.role != 'admin') {
      if (mounted) {
        _showError('只有管理员可以修改AI设置');
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _aiService.updateAiSettingsRaw(
        apiUrl: _apiUrlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        model: _modelController.text.trim(),
        titlePrompt: _titlePromptController.text.trim(),
        descriptionPrompt: _descriptionPromptController.text.trim(),
        safetyRules: _safetyRulesController.text.trim(),
        replacementWords: _replacementWordsController.text.trim(),
      );

      if (mounted) {
        _showSuccess('保存成功');
      }
    } catch (e) {
      if (mounted) {
        _showError('保存失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccess(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('成功'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _titlePromptController.dispose();
    _descriptionPromptController.dispose();
    _safetyRulesController.dispose();
    _replacementWordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('AI 设置'),
        trailing: _isSaving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveSettings,
                child: const Text('保存'),
              ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '加载失败',
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton.filled(
                          onPressed: _loadSettings,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Tab selector
                      Padding(
                        padding: const EdgeInsets.all(ThemeConstants.spacingMd),
                        child: CupertinoSegmentedControl<int>(
                          groupValue: _currentTab,
                          onValueChanged: (value) {
                            setState(() {
                              _currentTab = value;
                            });
                          },
                          children: const {
                            0: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Text('API配置'),
                            ),
                            1: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Text('提示词'),
                            ),
                            2: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Text('安全规则'),
                            ),
                            3: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Text('替换词'),
                            ),
                          },
                        ),
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _currentTab,
                          children: [
                            _buildApiConfigTab(),
                            _buildPromptsTab(),
                            _buildSafetyRulesTab(),
                            _buildReplacementWordsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildApiConfigTab() {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          title: 'API 配置',
          children: [
            _buildTextField(
              controller: _apiUrlController,
              placeholder: 'API 地址',
              prefix: CupertinoIcons.link,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildTextField(
              controller: _apiKeyController,
              placeholder: 'API 密钥',
              prefix: CupertinoIcons.lock,
              obscureText: true,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildTextField(
              controller: _modelController,
              placeholder: '模型名称',
              prefix: CupertinoIcons.circle_grid_3x3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPromptsTab() {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          title: '提示词配置',
          children: [
            _buildTextField(
              controller: _titlePromptController,
              placeholder: '标题生成提示词',
              prefix: CupertinoIcons.doc_text,
              minLines: 5,
              maxLines: 10,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildTextField(
              controller: _descriptionPromptController,
              placeholder: '描述生成提示词',
              prefix: CupertinoIcons.doc_text_fill,
              minLines: 5,
              maxLines: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyRulesTab() {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          title: '安全规则',
          children: [
            _buildTextField(
              controller: _safetyRulesController,
              placeholder: '安全规则',
              prefix: CupertinoIcons.shield_fill,
              minLines: 8,
              maxLines: 15,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReplacementWordsTab() {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          title: '替换词',
          children: [
            _buildTextField(
              controller: _replacementWordsController,
              placeholder: '替换词 (JSON格式)',
              prefix: CupertinoIcons.arrow_right_arrow_left,
              minLines: 8,
              maxLines: 15,
            ),
            const SizedBox(height: ThemeConstants.spacingSm),
            const Text(
              '格式: JSON数组，例如 [{"original":"敏感词1","replacement":"替换词1"},{"original":"敏感词2","replacement":"替换词2"}]',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
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
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData prefix,
    bool obscureText = false,
    int minLines = 1,
    int maxLines = 1,
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
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: obscureText,
        minLines: minLines,
        maxLines: maxLines,
        decoration: null,
        style: const TextStyle(fontSize: 16),
        prefix: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(prefix, size: 20),
        ),
      ),
    );
  }
}
