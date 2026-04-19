import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/theme_constants.dart';
import '../../utils/user_storage.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  List<String> _savedUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = 'admin';
    _passwordController.text = 'admin123';
    _loadSavedUsers();
  }

  Future<void> _loadSavedUsers() async {
    final users = await UserStorage.getSavedUsers();
    setState(() {
      _savedUsers = users;
    });
  }

  void _showUserPicker() {
    final l10n = AppLocalizations.of(context)!;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(l10n.selectUser),
        message: _savedUsers.isEmpty ? Text(l10n.noSavedUsers) : null,
        actions: _savedUsers.isEmpty
            ? []
            : _savedUsers.map((username) => CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _usernameController.text = username;
                      _passwordController.text = '123';
                    });
                  },
                  child: Text(username),
                )).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty) {
      _showError(l10n.pleaseEnterUsername);
      return;
    }
    if (password.isEmpty) {
      _showError(l10n.pleaseEnterPassword);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(username, password);

    if (success) {
      await UserStorage.saveUser(username);
      await _loadSavedUsers();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
      _showError(authProvider.error ?? l10n.loginFailed);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(l10n.notice),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.ok),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.login),
      ),
      child: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading || _isLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: ThemeConstants.spacingXl),
                  Icon(
                    CupertinoIcons.photo_on_rectangle,
                    size: 80,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                  const SizedBox(height: ThemeConstants.spacingMd),
                  Text(
                    l10n.appTitle,
                    style: ThemeConstants.titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ThemeConstants.spacingXl * 2),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingSm),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: _usernameController,
                            placeholder: l10n.username,
                            prefix: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(CupertinoIcons.person, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          color: CupertinoColors.systemGrey6,
                          onPressed: _savedUsers.isEmpty ? null : _showUserPicker,
                          child: Icon(
                            _savedUsers.isEmpty
                                ? CupertinoIcons.person_badge_plus
                                : CupertinoIcons.person_3,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacingMd),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingSm),
                    child: CupertinoTextField(
                      controller: _passwordController,
                      placeholder: l10n.password,
                      obscureText: _obscurePassword,
                      prefix: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.lock, size: 20),
                      ),
                      suffix: CupertinoButton(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          _obscurePassword
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacingXl),

                  CupertinoButton.filled(
                    onPressed: _submit,
                    child: Text(l10n.login),
                  ),

                  const SizedBox(height: ThemeConstants.spacingMd),
                  Text(
                    l10n.adminAccountHint,
                    style: ThemeConstants.captionStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
