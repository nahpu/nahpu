import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/services/export/dwc_bundle.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';

class FileSettingsCard extends StatelessWidget {
  const FileSettingsCard({
    super.key,
    required this.exportCtr,
    required this.selectedDir,
    required this.onExportFmtChanged,
    required this.onFileNameChanged,
    required this.onSelectDir,
    required this.onClearDir,
  });

  final FileOpCtrModel exportCtr;
  final Directory? selectedDir;
  final void Function(ExportFmt?) onExportFmtChanged;
  final void Function(String?) onFileNameChanged;
  final VoidCallback onSelectDir;
  final VoidCallback onClearDir;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExportFmt>(
              initialValue: exportCtr.exportFmtCtr,
              decoration: const InputDecoration(
                labelText: 'File format',
              ),
              items: exportFormats
                  .map((e) => DropdownMenuItem(
                        value: ExportFmt.values[exportFormats.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: onExportFmtChanged,
            ),
            FileNameField(
              controller: exportCtr,
              onChanged: onFileNameChanged,
            ),
            Visibility(
              visible: !Platform.isIOS,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FileSettingsDirectoryPicker(
                  selectedDir: selectedDir,
                  onSelectDir: onSelectDir,
                  onClearDir: onClearDir,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BundleFileSettingsCard extends StatelessWidget {
  const BundleFileSettingsCard({
    super.key,
    required this.exportCtr,
    required this.selectedDir,
    required this.format,
    required this.archiveFormat,
    required this.onFormatChanged,
    required this.onArchiveFormatChanged,
    required this.onFileNameChanged,
    required this.onSelectDir,
    required this.onClearDir,
  });

  final FileOpCtrModel exportCtr;
  final Directory? selectedDir;
  final DwcBundleFormat format;
  final BundleArchiveFormat archiveFormat;
  final ValueChanged<DwcBundleFormat> onFormatChanged;
  final ValueChanged<BundleArchiveFormat> onArchiveFormatChanged;
  final ValueChanged<String?> onFileNameChanged;
  final VoidCallback onSelectDir;
  final VoidCallback onClearDir;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DwcBundleFormat>(
              initialValue: format,
              decoration: const InputDecoration(labelText: 'Bundle format'),
              items: DwcBundleFormat.values
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ))
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) onFormatChanged(value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BundleArchiveFormat>(
              key: ValueKey('${format.name}-${archiveFormat.name}'),
              initialValue: archiveFormat,
              decoration: const InputDecoration(labelText: 'Archive format'),
              items: format.allowedArchives
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ))
                  .toList(growable: false),
              onChanged: format.allowedArchives.length == 1
                  ? null
                  : (value) {
                      if (value != null) onArchiveFormatChanged(value);
                    },
            ),
            if (format == DwcBundleFormat.darwinCoreDataPackage &&
                archiveFormat == BundleArchiveFormat.zip) ...[
              const SizedBox(height: 8),
              Text(
                'ZIP is provided for compatibility. TAR.GZ is the standards-oriented DwC-DP option.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            FileNameField(
              controller: exportCtr,
              onChanged: onFileNameChanged,
            ),
            Visibility(
              visible: !Platform.isIOS,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FileSettingsDirectoryPicker(
                  selectedDir: selectedDir,
                  onSelectDir: onSelectDir,
                  onClearDir: onClearDir,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
