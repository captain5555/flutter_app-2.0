import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../utils/user_storage.dart';
import '../../constants/theme_constants.dart';
import '../../l10n/app_localizations.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _users = await _userService.getUsers();
      // 自动保存所有用户到登录列表
      for (final user in _users) {
        await UserStorage.saveUser(user.username);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateUserDialog(AppLocalizations l10n) {
    final nameController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.createUser),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: nameController,
            placeholder: l10n.username,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                await _createUser(name, l10n);
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  Future<void> _createUser(String username, AppLocalizations l10n) async {
    try {
      await _userService.createUser(username);
      // 保存新用户到登录列表
      await UserStorage.saveUser(username);
      await _loadUsers();
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.creationFailed),
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

  void _showDeleteUserDialog(User user, AppLocalizations l10n) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.deleteUserConfirm(user.username)),
        content: Text(l10n.userMediaTransferToAdmin),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteUser(user, l10n);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(User user, AppLocalizations l10n) async {
    try {
      await _userService.deleteUser(user.id);
      await _loadUsers();
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.deleteFailed),
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
        final authProvider = context.watch<AuthProvider>();
        final isAdmin = authProvider.user?.role == 'admin';

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(l10n.userManagement),
            trailing: isAdmin
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showCreateUserDialog(l10n),
                    child: const Icon(CupertinoIcons.plus),
                  )
                : null,
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
                              onPressed: _loadUsers,
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(ThemeConstants.spacingMd),
                        itemCount: _users.length,
                        separatorBuilder: (context, index) => const SizedBox(height: ThemeConstants.spacingSm),
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          final isCurrentUser = authProvider.user?.id == user.id;
                          return _UserCard(
                            user: user,
                            isCurrentUser: isCurrentUser,
                            canDelete: isAdmin && !isCurrentUser,
                            l10n: l10n,
                            onDelete: () => _showDeleteUserDialog(user, l10n),
                          );
                        },
                      ),
          ),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final bool isCurrentUser;
  final bool canDelete;
  final AppLocalizations l10n;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.isCurrentUser,
    required this.canDelete,
    required this.l10n,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                user.username.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: ThemeConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.current,
                          style: const TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.systemGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.role == 'admin' ? l10n.adminRole : l10n.userRole,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          if (canDelete)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onDelete,
              child: const Icon(
                CupertinoIcons.trash,
                color: CupertinoColors.systemRed,
              ),
            ),
        ],
      ),
    );
  }
}
