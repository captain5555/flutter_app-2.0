import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../constants/theme_constants.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  bool _isCreating = false;
  String? _error;
  List<dynamic> _backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _backups = await _adminService.listBackups();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isCreating = true);

    try {
      await _adminService.createBackup();
      await _loadBackups();
      if (mounted) {
        _showSuccess('备份创建成功');
      }
    } catch (e) {
      if (mounted) {
        _showError('备份创建失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _deleteBackup(String backupId) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除备份 $backupId 吗？'),
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
      try {
        await _adminService.deleteBackup(backupId);
        await _loadBackups();
        if (mounted) {
          _showSuccess('删除成功');
        }
      } catch (e) {
        if (mounted) {
          _showError('删除失败: $e');
        }
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

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('备份管理'),
        trailing: _isCreating
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _createBackup,
                child: const Icon(CupertinoIcons.plus),
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
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton.filled(
                          onPressed: _loadBackups,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  )
                : _backups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.archivebox,
                              size: 60,
                              color: CupertinoColors.systemGrey3,
                            ),
                            const SizedBox(height: ThemeConstants.spacingMd),
                            const Text(
                              '暂无备份',
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(ThemeConstants.spacingMd),
                        itemCount: _backups.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: ThemeConstants.spacingSm),
                        itemBuilder: (context, index) {
                          final backup = _backups[index] as Map<String, dynamic>;
                          return _BackupCard(
                            backup: backup,
                            dateLabel: _formatDate(backup['created_at']),
                            sizeLabel: _formatSize(backup['size']),
                            onDelete: () => _deleteBackup(backup['id']?.toString() ?? ''),
                          );
                        },
                      ),
      ),
    );
  }
}

class _BackupCard extends StatelessWidget {
  final Map<String, dynamic> backup;
  final String dateLabel;
  final String sizeLabel;
  final VoidCallback onDelete;

  const _BackupCard({
    required this.backup,
    required this.dateLabel,
    required this.sizeLabel,
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CupertinoColors.systemOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.archivebox,
              size: 24,
              color: CupertinoColors.systemOrange,
            ),
          ),
          const SizedBox(width: ThemeConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup['id']?.toString() ?? '未知',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                if (sizeLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sizeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.tertiaryLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
