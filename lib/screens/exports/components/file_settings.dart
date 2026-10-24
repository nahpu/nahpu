import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/export/dwc_bundle.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/styles/design_tokens.dart';

class GenericFileSettingsCard<T> extends StatelessWidget {
  GenericFileSettingsCard({
    super.key,
    required this.exportCtr,
    required this.format,
    required this.formats,
    required this.formatLabel,
    required this.onFormatChanged,
    required this.onFileNameChanged,
    required this.extensionForFormat,
    required this.appendDate,
    required this.onAppendDateChanged,
    this.selectedDir,
    this.onSelectDir,
    this.onClearDir,
    this.formatFieldLabel,
    this.enabled = true,
    ExportDestinationMode? destinationMode,
  }) : destinationMode = destinationMode ?? platformExportDestination;

  final FileOpCtrModel exportCtr;
  final T format;
  final List<T> formats;
  final String Function(T) formatLabel;
  final String Function(T) extensionForFormat;
  final ValueChanged<T> onFormatChanged;
  final ValueChanged<String?> onFileNameChanged;
  final bool appendDate;
  final ValueChanged<bool> onAppendDateChanged;

  /// Supplied only by callers that keep the destination inside this card. The
  /// export screens show it in the location card above their export button.
  final Directory? selectedDir;
  final VoidCallback? onSelectDir;
  final VoidCallback? onClearDir;

  /// Defaults to the localized "File format".
  final String? formatFieldLabel;
  final bool enabled;
  final ExportDestinationMode destinationMode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentFileSettings,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: NahpuSpacing.xl),
          DropdownButtonFormField<T>(
            key: ValueKey(format),
            initialValue: format,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: formatFieldLabel ?? l10n.documentFileFormat,
            ),
            items: [
              for (final value in formats)
                DropdownMenuItem(
                  value: value,
                  child: CommonDropdownText(text: formatLabel(value)),
                ),
            ],
            onChanged: enabled
                ? (value) {
                    if (value != null) onFormatChanged(value);
                  }
                : null,
          ),
          const SizedBox(height: NahpuSpacing.xl),
          FileNameField(
            controller: exportCtr.fileNameCtr,
            extension: extensionForFormat(format),
            appendDate: appendDate,
            enabled: enabled,
            onChanged: onFileNameChanged,
          ),
          AppendDateSwitch(
            value: appendDate,
            enabled: enabled,
            onChanged: onAppendDateChanged,
          ),
          if (onSelectDir != null && onClearDir != null)
            Padding(
              padding: const EdgeInsets.only(top: NahpuSpacing.xl),
              child: ExportDestinationField(
                mode: destinationMode,
                selectedDir: selectedDir,
                onSelectDir: enabled ? onSelectDir! : () {},
                onClearDir: enabled ? onClearDir! : () {},
              ),
            ),
        ],
      ),
    );
  }
}

class FileSettingsCard extends StatelessWidget {
  const FileSettingsCard({
    super.key,
    required this.exportCtr,
    required this.onExportFmtChanged,
    required this.onFileNameChanged,
    required this.appendDate,
    required this.onAppendDateChanged,
    this.selectedDir,
    this.onSelectDir,
    this.onClearDir,
    this.enabled = true,
    this.destinationMode,
  });

  final FileOpCtrModel exportCtr;
  final void Function(ExportFmt?) onExportFmtChanged;
  final void Function(String?) onFileNameChanged;
  final bool appendDate;
  final ValueChanged<bool> onAppendDateChanged;
  final Directory? selectedDir;
  final VoidCallback? onSelectDir;
  final VoidCallback? onClearDir;
  final bool enabled;
  final ExportDestinationMode? destinationMode;

  @override
  Widget build(BuildContext context) {
    return GenericFileSettingsCard<ExportFmt>(
      exportCtr: exportCtr,
      destinationMode: destinationMode,
      selectedDir: selectedDir,
      format: exportCtr.exportFmtCtr,
      formats: ExportFmt.values,
      formatLabel: (value) => _exportFormatLabel(value, context.l10n),
      extensionForFormat: (value) => switch (value) {
        ExportFmt.excel => 'xlsx',
        _ => value.name,
      },
      onFormatChanged: (value) => onExportFmtChanged(value),
      onFileNameChanged: onFileNameChanged,
      appendDate: appendDate,
      onAppendDateChanged: onAppendDateChanged,
      onSelectDir: onSelectDir,
      onClearDir: onClearDir,
      enabled: enabled,
    );
  }
}

class BundleFileSettingsCard extends StatelessWidget {
  const BundleFileSettingsCard({
    super.key,
    required this.exportCtr,
    required this.format,
    required this.archiveFormat,
    required this.onFormatChanged,
    required this.onArchiveFormatChanged,
    required this.onFileNameChanged,
    required this.appendDate,
    required this.onAppendDateChanged,
    this.enabled = true,
  });

  final FileOpCtrModel exportCtr;
  final DwcBundleFormat format;
  final BundleArchiveFormat archiveFormat;
  final ValueChanged<DwcBundleFormat> onFormatChanged;
  final ValueChanged<BundleArchiveFormat> onArchiveFormatChanged;
  final ValueChanged<String?> onFileNameChanged;
  final bool appendDate;
  final ValueChanged<bool> onAppendDateChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentFileSettings,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: NahpuSpacing.xl),
          DropdownButtonFormField<DwcBundleFormat>(
            initialValue: format,
            decoration: InputDecoration(
              labelText: l10n.documentFileBundleFormat,
            ),
            items: DwcBundleFormat.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(growable: false),
            onChanged: enabled
                ? (value) {
                    if (value != null) onFormatChanged(value);
                  }
                : null,
          ),
          const SizedBox(height: NahpuSpacing.xl),
          DropdownButtonFormField<BundleArchiveFormat>(
            key: ValueKey('${format.name}-${archiveFormat.name}'),
            initialValue: archiveFormat,
            decoration: InputDecoration(
              labelText: l10n.settingsSelectionArchiveFormat,
            ),
            items: format.allowedArchives
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(growable: false),
            onChanged: !enabled || format.allowedArchives.length == 1
                ? null
                : (value) {
                    if (value != null) onArchiveFormatChanged(value);
                  },
          ),
          if (format == DwcBundleFormat.darwinCoreDataPackage &&
              archiveFormat == BundleArchiveFormat.zip) ...[
            const SizedBox(height: 8),
            Text(
              l10n.documentFileDwcDpZipNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: NahpuSpacing.xl),
          FileNameField(
            controller: exportCtr.fileNameCtr,
            extension: format.outputExtension(archiveFormat),
            appendDate: appendDate,
            enabled: enabled,
            onChanged: onFileNameChanged,
          ),
          AppendDateSwitch(
            value: appendDate,
            enabled: enabled,
            onChanged: onAppendDateChanged,
          ),
        ],
      ),
    );
  }
}

String _exportFormatLabel(ExportFmt format, AppLocalizations l10n) =>
    switch (format) {
      ExportFmt.csv => l10n.documentFileFormatCsv,
      ExportFmt.tsv => l10n.documentFileFormatTsv,
      ExportFmt.excel => l10n.documentFileFormatExcel,
      ExportFmt.json => l10n.documentFileFormatJson,
    };
