import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/ai_service.dart';
import '../../constants/theme_constants.dart';
import '../../l10n/app_localizations.dart';

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

  Future<void> _saveSettings(AppLocalizations l10n) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.role != 'admin') {
      if (mounted) {
        _showError(l10n, l10n.onlyAdminCanModifyAiSettings);
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
        _showSuccess(l10n, l10n.saveSuccessMsg);
      }
    } catch (e) {
      if (mounted) {
        _showError(l10n, l10n.saveFailedWithError(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccess(AppLocalizations l10n, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.success),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.ok),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showError(AppLocalizations l10n, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.error),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.ok),
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
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final l10n = AppLocalizations(settingsProvider.locale);

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(l10n.aiSettings),
            trailing: _isSaving
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _saveSettings(l10n),
                    child: Text(l10n.save),
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
                              l10n.failedToLoad,
                              style: const TextStyle(
                                color: CupertinoColors.systemRed,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CupertinoButton.filled(
                              onPressed: _loadSettings,
                              child: Text(l10n.retry),
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
                              children: {
                                0: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  child: Text(l10n.apiConfig),
                                ),
                                1: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  child: Text(l10n.prompts),
                                ),
                                2: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  child: Text(l10n.safetyRulesTab),
                                ),
                                3: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  child: Text(l10n.replacements),
                                ),
                              },
                            ),
                          ),
                          Expanded(
                            child: IndexedStack(
                              index: _currentTab,
                              children: [
                                _buildApiConfigTab(l10n),
                                _buildPromptsTab(l10n),
                                _buildSafetyRulesTab(l10n),
                                _buildReplacementWordsTab(l10n),
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

  Widget _buildApiConfigTab(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          l10n: l10n,
          title: l10n.apiConfig,
          children: [
            _buildTextField(
              l10n: l10n,
              controller: _apiUrlController,
              placeholder: l10n.apiAddress,
              prefix: CupertinoIcons.link,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildTextField(
              l10n: l10n,
              controller: _apiKeyController,
              placeholder: l10n.apiKey,
              prefix: CupertinoIcons.lock,
              obscureText: true,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildTextField(
              l10n: l10n,
              controller: _modelController,
              placeholder: l10n.modelName,
              prefix: CupertinoIcons.circle_grid_3x3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPromptsTab(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          l10n: l10n,
          title: l10n.promptConfig,
          children: [
            _buildTextField(
              l10n: l10n,
              controller: _titlePromptController,
              placeholder: l10n.titleGenerationPrompt,
              prefix: CupertinoIcons.doc_text,
              minLines: 5,
              maxLines: 10,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildTextField(
              l10n: l10n,
              controller: _descriptionPromptController,
              placeholder: l10n.descriptionGenerationPrompt,
              prefix: CupertinoIcons.doc_text_fill,
              minLines: 5,
              maxLines: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyRulesTab(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          l10n: l10n,
          title: l10n.safetyRules,
          children: [
            _buildTextField(
              l10n: l10n,
              controller: _safetyRulesController,
              placeholder: l10n.safetyRules,
              prefix: CupertinoIcons.shield_fill,
              minLines: 8,
              maxLines: 15,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReplacementWordsTab(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          l10n: l10n,
          title: l10n.replacementWords,
          children: [
            _buildTextField(
              l10n: l10n,
              controller: _replacementWordsController,
              placeholder: l10n.replacementWords,
              prefix: CupertinoIcons.arrow_right_arrow_left,
              minLines: 8,
              maxLines: 15,
            ),
            const SizedBox(height: ThemeConstants.spacingSm),
            Text(
              l10n.replacementWordsFormatHint,
              style: const TextStyle(
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
    required AppLocalizations l10n,
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
    required AppLocalizations l10n,
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
