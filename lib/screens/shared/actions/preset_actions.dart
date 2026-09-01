import 'package:material_ui/material_ui.dart';

/// App-bar actions shared by document, template, and tabular preset screens.
///
/// Export is offered at two scopes: the selected item alone, and everything.
/// The selected-item entry is hidden when nothing is selected.
class PresetAppBarActions extends StatelessWidget {
  const PresetAppBarActions({
    super.key,
    required this.onCreate,
    required this.onScanQr,
    required this.onImport,
    required this.onExportAll,
    this.onExportSelected,
    this.itemName = 'preset',
  });

  final VoidCallback onCreate;
  final VoidCallback onScanQr;
  final VoidCallback onImport;
  final VoidCallback onExportAll;

  /// Exports only the currently selected item, when there is one.
  final VoidCallback? onExportSelected;
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
        PopupMenuButton<_PresetMenuAction>(
          tooltip:
              '${itemName[0].toUpperCase()}${itemName.substring(1)} options',
          onSelected: (action) {
            switch (action) {
              case _PresetMenuAction.create:
                onCreate();
              case _PresetMenuAction.scanQr:
                onScanQr();
              case _PresetMenuAction.import:
                onImport();
              case _PresetMenuAction.exportSelected:
                onExportSelected?.call();
              case _PresetMenuAction.exportAll:
                onExportAll();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _PresetMenuAction.create,
              child: _PresetMenuItem(
                icon: Icons.add_circle_outline_rounded,
                label: 'Create new',
              ),
            ),
            const PopupMenuDivider(height: 8),
            const PopupMenuItem(
              value: _PresetMenuAction.scanQr,
              child: _PresetMenuItem(
                icon: Icons.qr_code_scanner_outlined,
                label: 'Scan QR',
              ),
            ),
            const PopupMenuItem(
              value: _PresetMenuAction.import,
              child: _PresetMenuItem(
                icon: Icons.file_download_outlined,
                label: 'Import',
              ),
            ),
            if (onExportSelected != null)
              PopupMenuItem(
                value: _PresetMenuAction.exportSelected,
                child: _PresetMenuItem(
                  icon: Icons.file_upload_outlined,
                  label: 'Export this $itemName',
                ),
              ),
            PopupMenuItem(
              value: _PresetMenuAction.exportAll,
              child: _PresetMenuItem(
                icon: Icons.drive_folder_upload_outlined,
                // Only distinguish the scopes when both are offered.
                label: onExportSelected == null
                    ? 'Export'
                    : 'Export all ${itemName}s',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _PresetMenuAction { create, scanQr, import, exportSelected, exportAll }

class _PresetMenuItem extends StatelessWidget {
  const _PresetMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        // Scoped export labels carry the item name, so they need room to
        // shrink rather than overflow on a narrow menu.
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
