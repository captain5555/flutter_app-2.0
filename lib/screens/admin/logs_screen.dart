import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../constants/theme_constants.dart';

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

  String _getActionLabel(String? action) {
    switch (action) {
      case 'login':
        return '登录';
      case 'logout':
        return '退出';
      case 'upload_material':
        return '上传素材';
      case 'update_material':
        return '更新素材';
      case 'trash_material':
        return '删除素材';
      case 'create_user':
        return '创建用户';
      case 'delete_user':
        return '删除用户';
      case 'batch_trash':
        return '批量删除';
      case 'batch_restore':
        return '批量恢复';
      case 'batch_copy':
        return '批量复制';
      case 'batch_move':
        return '批量移动';
      default:
        return action ?? '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('操作日志'),
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
                          onPressed: _loadLogs,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  )
                : _logs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.text_bubble,
                              size: 60,
                              color: CupertinoColors.systemGrey3,
                            ),
                            const SizedBox(height: ThemeConstants.spacingMd),
                            const Text(
                              '暂无日志',
                              style: TextStyle(
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
                            actionLabel: _getActionLabel(log['action']),
                            dateLabel: _formatDate(log['created_at']),
                          );
                        },
                      ),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final Map<String, dynamic> log;
  final String actionLabel;
  final String dateLabel;

  const _LogCard({
    required this.log,
    required this.actionLabel,
    required this.dateLabel,
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
              '用户ID: ${log['user_id']}',
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
          if (log['target_type'] != null) ...[
            const SizedBox(height: 4),
            Text(
              '目标类型: ${log['target_type']}',
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
          if (log['target_id'] != null) ...[
            const SizedBox(height: 4),
            Text(
              '目标ID: ${log['target_id']}',
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
          if (log['details'] != null && log['details'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '详情: ${log['details']}',
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
