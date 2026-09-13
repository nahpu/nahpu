import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// App-bar actions shared by document, template, and tabular preset screens.
///
/// The menu is grouped by what an action does: create, bring presets in, send
/// presets out, and add the bundled defaults. Export is offered at two scopes:
/// the selected item alone, and everything. The selected-item entry is hidden
/// when nothing is selected.
class PresetAppBarActions extends StatelessWidget {
  const PresetAppBarActions({
    super.key,
    required this.onCreate,
    required this.onImport,
    required this.onExportAll,
    this.onScanQr,
    this.onExportSelected,
    this.onLoadDefaults,
    this.itemName = 'preset',
  });

  final VoidCallback onCreate;

  /// Imports from a QR code. Items that cannot be shown as a QR code leave it
  /// null, which hides the entry.
  final VoidCallback? onScanQr;
  final VoidCallback onImport;
  final VoidCallback onExportAll;

  /// Exports only the currently selected item, when there is one.
  final VoidCallback? onExportSelected;

  /// Adds the bundled default presets, when the screen offers them.
  final VoidCallback? onLoadDefaults;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onCreate,
          icon: const Icon(Icons.add_circle_outline_rounded),
          tooltip: 'Create new $itemName',
        ),
        AdaptiveMenuButton<_PresetMenuAction>(
          tooltip:
              '${itemName[0].toUpperCase()}${itemName.substring(1)} options',
          itemBuilder: _items,
          onSelected: _onSelected,
        ),
      ],
    );
  }

  List<AdaptiveMenuItem<_PresetMenuAction>> _items() => [
    const AdaptiveMenuItem(
      value: _PresetMenuAction.create,
      icon: Icons.add_circle_outline_rounded,
      label: 'Create new',
    ),
    if (onScanQr != null)
      const AdaptiveMenuItem(
        value: _PresetMenuAction.scanQr,
        icon: Icons.qr_code_scanner_outlined,
        label: 'Scan QR',
        hasDividerBefore: true,
      ),
    AdaptiveMenuItem(
      value: _PresetMenuAction.import,
      icon: Icons.file_download_outlined,
      label: 'Import',
      hasDividerBefore: onScanQr == null,
    ),
    if (onExportSelected != null)
      AdaptiveMenuItem(
        value: _PresetMenuAction.exportSelected,
        icon: Icons.file_upload_outlined,
        label: 'Export this $itemName',
        hasDividerBefore: true,
      ),
    AdaptiveMenuItem(
      value: _PresetMenuAction.exportAll,
      icon: Icons.drive_folder_upload_outlined,
      // Only distinguish the scopes when both are offered.
      label: onExportSelected == null ? 'Export' : 'Export all ${itemName}s',
      hasDividerBefore: onExportSelected == null,
    ),
    if (onLoadDefaults != null)
      const AdaptiveMenuItem(
        value: _PresetMenuAction.loadDefaults,
        icon: Icons.restore_outlined,
        label: 'Load defaults',
        hasDividerBefore: true,
      ),
  ];

  void _onSelected(_PresetMenuAction action) {
    switch (action) {
      case _PresetMenuAction.create:
        onCreate();
      case _PresetMenuAction.scanQr:
        onScanQr?.call();
      case _PresetMenuAction.import:
        onImport();
      case _PresetMenuAction.exportSelected:
        onExportSelected?.call();
      case _PresetMenuAction.exportAll:
        onExportAll();
      case _PresetMenuAction.loadDefaults:
        onLoadDefaults?.call();
    }
  }
}

enum _PresetMenuAction {
  create,
  scanQr,
  import,
  exportSelected,
  exportAll,
  loadDefaults,
}

/// Stands in for a preset list that has nothing in it yet.
class PresetEmptyState extends StatelessWidget {
  const PresetEmptyState({
    super.key,
    required this.message,
    this.onLoadDefaults,
    this.secondaryLabel,
    this.secondaryIcon,
    this.onSecondary,
  });

  final String message;

  /// Adds the bundled defaults; the button is hidden when null.
  final VoidCallback? onLoadDefaults;
  final String? secondaryLabel;
  final IconData? secondaryIcon;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryLabel = this.secondaryLabel;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: NahpuSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: NahpuSpacing.md,
              runSpacing: NahpuSpacing.md,
              children: [
                if (onLoadDefaults != null)
                  FilledButton.tonalIcon(
                    onPressed: onLoadDefaults,
                    icon: const Icon(Icons.restore_outlined),
                    label: const Text('Load defaults'),
                  ),
                if (onSecondary != null && secondaryLabel != null)
                  OutlinedButton.icon(
                    onPressed: onSecondary,
                    icon: Icon(secondaryIcon ?? Icons.tune_outlined),
                    label: Text(secondaryLabel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
