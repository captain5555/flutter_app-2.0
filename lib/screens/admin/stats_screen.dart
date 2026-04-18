import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../constants/theme_constants.dart';
import '../../models/user.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _stats = await _adminService.getStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('系统统计'),
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
                          onPressed: _loadStats,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final userCount = _stats?['userCount'] ?? 0;
    final totalFiles = _stats?['totalFiles'] ?? 0;
    final totalSize = _stats?['totalSize'] ?? 0;
    final storageByUser = _stats?['storageByUser'] as List? ?? [];

    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          title: '概览',
          children: [
            _buildStatCard(
              icon: CupertinoIcons.person_3,
              title: '用户数',
              value: '$userCount',
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildStatCard(
              icon: CupertinoIcons.photo_on_rectangle,
              title: '文件数',
              value: '$totalFiles',
              color: CupertinoColors.systemGreen,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildStatCard(
              icon: CupertinoIcons.tray_full,
              title: '总存储',
              value: _formatSize(totalSize),
              color: CupertinoColors.systemOrange,
            ),
          ],
        ),
        const SizedBox(height: ThemeConstants.spacingLg),
        if (storageByUser.isNotEmpty)
          _buildSection(
            title: '用户存储详情',
            children: storageByUser.map((item) {
              final userId = item['user_id'] ?? 0;
              final fileCount = item['file_count'] ?? 0;
              final totalSize = item['total_size'] ?? 0;
              return _buildUserStorageCard(
                userId: userId,
                fileCount: fileCount,
                totalSize: totalSize,
              );
            }).toList(),
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(width: ThemeConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStorageCard({
    required int userId,
    required int fileCount,
    required int totalSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'U$userId',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: ThemeConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '用户 $userId',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$fileCount 个文件 · ${_formatSize(totalSize)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
