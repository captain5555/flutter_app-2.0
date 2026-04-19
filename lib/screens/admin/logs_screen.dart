import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/admin_service.dart';
import '../../constants/theme_constants.dart';
import '../../l10n/app_localizations.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _logs = await _adminService.getLogs();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.tryParse(dateStr);
      if (date == null) return dateStr;
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getActionLabel(String? action, AppLocalizations l10n) {
    switch (action) {
      case 'login':
        return l10n.login;
      case 'logout':
        return l10n.logout;
      case 'upload_material':
        return l10n.uploadMaterial;
      case 'update_material':
        return l10n.updateMaterial;
      case 'trash_material':
        return l10n.deleteMaterial;
      case 'create_user':
        return l10n.createUser;
      case 'delete_user':
        return l10n.deleteUser;
      case 'batch_trash':
        return l10n.batchDelete;
      case 'batch_restore':
        return l10n.batchRestore;
      case 'batch_copy':
        return l10n.batchCopy;
      case 'batch_move':
        return l10n.batchMove;
      default:
        return action ?? l10n.unknownAction;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final l10n = AppLocalizations(settingsProvider.locale);

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(l10n.operationLogs),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _loadLogs,
              child: const Icon(CupertinoIcons.refresh),
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
                            Text(
                              _error!,
                              style: const TextStyle(
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CupertinoButton.filled(
                              onPressed: _loadLogs,
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : _logs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.text_bubble,
                                  size: 60,
                                  color: CupertinoColors.systemGrey3,
                                ),
                                const SizedBox(height: ThemeConstants.spacingMd),
                                Text(
                                  l10n.noLogs,
                                  style: const TextStyle(
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(ThemeConstants.spacingMd),
                            itemCount: _logs.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: ThemeConstants.spacingSm),
                            itemBuilder: (context, index) {
                              final log = _logs[index] as Map<String, dynamic>;
                              return _LogCard(
                                log: log,
                                actionLabel: _getActionLabel(log['action'], l10n),
                                dateLabel: _formatDate(log['created_at']),
                                l10n: l10n,
                              );
                            },
                          ),
          ),
        );
      },
    );
  }
}

class _LogCard extends StatelessWidget {
  final Map<String, dynamic> log;
  final String actionLabel;
  final String dateLabel;
  final AppLocalizations l10n;

  const _LogCard({
    required this.log,
    required this.actionLabel,
    required this.dateLabel,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.systemBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
          if (log['user_id'] != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.userId(log['user_id'].toString()),
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
          if (log['target_type'] != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.targetType(log['target_type'].toString()),
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
          if (log['target_id'] != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.targetId(log['target_id'].toString()),
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
          if (log['details'] != null && log['details'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l10n.details(log['details'].toString()),
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (log['ip_address'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'IP: ${log['ip_address']}',
              style: const TextStyle(
                fontSize: 11,
                color: CupertinoColors.tertiaryLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
