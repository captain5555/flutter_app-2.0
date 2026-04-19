import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/theme_constants.dart';
import '../../l10n/app_localizations.dart';
import '../login/login_screen.dart';
import '../admin/user_management_screen.dart';
import '../admin/ai_settings_screen.dart';
import '../admin/stats_screen.dart';
import '../admin/logs_screen.dart';
import '../admin/backup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<SettingsProvider>(context, listen: false).loadSettings();
      }
    });
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

  void _showApiUrlDialog() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations(settingsProvider.locale);
    final controller = TextEditingController(text: settingsProvider.baseUrl);

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(l10n.apiAddress),
        content: Padding(
          padding: const EdgeInsets.only(top: ThemeConstants.spacingMd),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'http://localhost:3000',
            autofocus: true,
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: Text(l10n.save),
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                await settingsProvider.updateBaseUrl(url);
              }
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations(settingsProvider.locale);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(l10n.selectLanguage),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              settingsProvider.setLocale(const Locale('en'));
            },
            child: Text(l10n.english),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              settingsProvider.setLocale(const Locale('zh'));
            },
            child: Text(l10n.chinese),
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

  void _showClearCacheDialog() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations(settingsProvider.locale);

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.confirmClearCache),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.clear),
            onPressed: () async {
              Navigator.pop(ctx);
              await _clearCache();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations(settingsProvider.locale);

    try {
      await settingsProvider.clearCache();

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.clearSuccess),
            content: Text(l10n.cacheCleared),
            actions: [
              CupertinoDialogAction(
                child: Text(l10n.ok),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.clearFailed),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final l10n = AppLocalizations(settingsProvider.locale);
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(l10n.settings),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(ThemeConstants.spacingMd),
              children: [
                // Theme Setting
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return CupertinoListSection.insetGrouped(
                      header: Text(l10n.appearance),
                      children: [
                        CupertinoListTile(
                          title: Text(l10n.darkMode),
                          trailing: CupertinoSwitch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.setTheme(value);
                            },
                          ),
                        ),
                        CupertinoListTile(
                          title: Text(l10n.language),
                          subtitle: Text(
                            settingsProvider.locale.languageCode == 'zh'
                                ? l10n.chinese
                                : l10n.english,
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: _showLanguageDialog,
                        ),
                      ],
                    );
                  },
                ),

            // API Setting
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                return CupertinoListSection.insetGrouped(
                  header: Text(l10n.server),
                  children: [
                    CupertinoListTile(
                      title: Text(l10n.apiAddress),
                      subtitle: Text(settingsProvider.baseUrl),
                      trailing: const CupertinoListTileChevron(),
                      onTap: _showApiUrlDialog,
                    ),
                  ],
                );
              },
            ),

            // Cache Section
            CupertinoListSection.insetGrouped(
              header: Text(l10n.cache),
              children: [
                CupertinoListTile(
                  title: Text(l10n.clearCache),
                  trailing: const CupertinoListTileChevron(),
                  onTap: _showClearCacheDialog,
                ),
              ],
            ),

            // Admin Section (only for admin)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.user?.role != 'admin') {
                  return const SizedBox.shrink();
                }
                return CupertinoListSection.insetGrouped(
                  header: Text(l10n.management),
                  children: [
                    CupertinoListTile(
                      title: Text(l10n.userManagement),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const UserManagementScreen(),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: Text(l10n.systemStats),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const StatsScreen(),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: Text(l10n.operationLogs),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const LogsScreen(),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: Text(l10n.backupManagement),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const BackupScreen(),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: Text(l10n.aiSettings),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const AiSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            // Account Section
            CupertinoListSection.insetGrouped(
              header: Text(l10n.account),
              children: [
                CupertinoListTile(
                  title: Text(
                    l10n.logout,
                    style: const TextStyle(color: CupertinoColors.systemRed),
                  ),
                  onTap: _logout,
                ),
              ],
            ),

            // Info Section
            CupertinoListSection.insetGrouped(
              header: Text(l10n.about),
              children: [
                CupertinoListTile(
                  title: Text(l10n.version),
                  subtitle: const Text('1.0.0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
