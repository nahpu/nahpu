import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/services/export/dwc_bundle.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/common/platform_services.dart';

class GenericFileSettingsCard<T> extends StatelessWidget {
  const GenericFileSettingsCard({
    super.key,
    required this.exportCtr,
    required this.selectedDir,
    required this.format,
    required this.formats,
    required this.formatLabel,
    required this.onFormatChanged,
    required this.onFileNameChanged,
    required this.onSelectDir,
    required this.onClearDir,
    this.formatFieldLabel = 'File format',
  });

  final FileOpCtrModel exportCtr;
  final Directory? selectedDir;
  final T format;
  final List<T> formats;
  final String Function(T) formatLabel;
  final ValueChanged<T> onFormatChanged;
  final ValueChanged<String?> onFileNameChanged;
  final VoidCallback onSelectDir;
  final VoidCallback onClearDir;
  final String formatFieldLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
            DropdownButtonFormField<T>(
              key: ValueKey(format),
              initialValue: format,
              isExpanded: true,
              decoration: InputDecoration(labelText: formatFieldLabel),
              items: [
                for (final value in formats)
                  DropdownMenuItem(
                    value: value,
                    child: CommonDropdownText(text: formatLabel(value)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onFormatChanged(value);
              },
            ),
            FileNameField(controller: exportCtr, onChanged: onFileNameChanged),
            if (systemPlatform == PlatformType.desktop)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FileSettingsDirectoryPicker(
                  selectedDir: selectedDir,
                  onSelectDir: onSelectDir,
                  onClearDir: onClearDir,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
    return GenericFileSettingsCard<ExportFmt>(
      exportCtr: exportCtr,
      selectedDir: selectedDir,
      format: exportCtr.exportFmtCtr,
      formats: ExportFmt.values,
      formatLabel: (value) => exportFormats[value.index],
      onFormatChanged: (value) => onExportFmtChanged(value),
      onFileNameChanged: onFileNameChanged,
      onSelectDir: onSelectDir,
      onClearDir: onClearDir,
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
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.label),
                    ),
                  )
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
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.label),
                    ),
                  )
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
            FileNameField(controller: exportCtr, onChanged: onFileNameChanged),
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
