import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/material_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/material_card.dart';
import '../../models/material.dart';
import '../../constants/theme_constants.dart';
import '../../l10n/app_localizations.dart';
import '../material/material_detail_screen.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final Set<int> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrash();
    });
  }

  Future<void> _loadTrash() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await context.read<MaterialProvider>().loadTrash(authProvider.user!);
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _handleBatchRestore() async {
    if (_selectedIds.isEmpty) return;

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations(settingsProvider.locale);

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.confirmRestoreItems(_selectedIds.length)),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          CupertinoDialogAction(
            child: Text(l10n.restore),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        await context.read<MaterialProvider>().batchRestore(
          _selectedIds.toList(),
          authProvider.user!,
        );
      }
      _exitSelectionMode();
    }
  }

  Future<void> _handleBatchDelete() async {
    if (_selectedIds.isEmpty) return;

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations(settingsProvider.locale);

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.permanentlyDeleteItems(_selectedIds.length)),
        content: Text(l10n.actionCannotBeUndone),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.deletePermanently),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        await context.read<MaterialProvider>().batchDelete(
          _selectedIds.toList(),
          authProvider.user!,
        );
      }
      _exitSelectionMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final l10n = AppLocalizations(settingsProvider.locale);
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: _isSelectionMode
                ? Text(l10n.itemsSelected(_selectedIds.length))
                : Text(l10n.trash),
            leading: _isSelectionMode
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(l10n.cancel),
                    onPressed: _exitSelectionMode,
                  )
                : null,
            trailing: _isSelectionMode
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _handleBatchRestore,
                        child: Text(l10n.restore),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _handleBatchDelete,
                        child: Text(
                          l10n.deletePermanently,
                          style: const TextStyle(color: CupertinoColors.systemRed),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Consumer<MaterialProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.trashMaterials.isEmpty) {
                        return const Center(child: CupertinoActivityIndicator());
                      }

                      if (provider.error != null && provider.trashMaterials.isEmpty) {
                        return Center(
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
                                onPressed: _loadTrash,
                                child: Text(l10n.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (provider.trashMaterials.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.trash,
                                size: 60,
                                color: CupertinoColors.systemGrey3,
                              ),
                              const SizedBox(height: ThemeConstants.spacingMd),
                              Text(
                                l10n.trashIsEmpty,
                                style: const TextStyle(
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
                        itemCount: provider.trashMaterials.length,
                        itemBuilder: (context, index) {
                          final material = provider.trashMaterials[index];
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
                                );
                              }
                            },
                            onLongPress: () {
                              _toggleSelection(material.id);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
