import 'package:flutter/material.dart';

/// App-bar actions shared by document and tabular preset management screens.
class PresetAppBarActions extends StatelessWidget {
  const PresetAppBarActions({
    super.key,
    required this.onCreate,
    required this.onScanQr,
    required this.onImport,
    required this.onExport,
  });

  final VoidCallback onCreate;
  final VoidCallback onScanQr;
  final VoidCallback onImport;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onCreate,
          icon: const Icon(Icons.add_circle_outline_rounded),
          tooltip: 'Create new preset',
        ),
        PopupMenuButton<_PresetMenuAction>(
          tooltip: 'Preset options',
          onSelected: (action) {
            switch (action) {
              case _PresetMenuAction.create:
                onCreate();
              case _PresetMenuAction.scanQr:
                onScanQr();
              case _PresetMenuAction.import:
                onImport();
              case _PresetMenuAction.export:
                onExport();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _PresetMenuAction.create,
              child: _PresetMenuItem(
                icon: Icons.add_circle_outline_rounded,
                label: 'Create new',
              ),
            ),
            PopupMenuDivider(height: 8),
            PopupMenuItem(
              value: _PresetMenuAction.scanQr,
              child: _PresetMenuItem(
                icon: Icons.qr_code_scanner_outlined,
                label: 'Scan QR',
              ),
            ),
            PopupMenuItem(
              value: _PresetMenuAction.import,
              child: _PresetMenuItem(
                icon: Icons.file_download_outlined,
                label: 'Import',
              ),
            ),
            PopupMenuItem(
              value: _PresetMenuAction.export,
              child: _PresetMenuItem(
                icon: Icons.file_upload_outlined,
                label: 'Export',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _PresetMenuAction { create, scanQr, import, export }

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
        Text(label),
      ],
    );
  }
}
