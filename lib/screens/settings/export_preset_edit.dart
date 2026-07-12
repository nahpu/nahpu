import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/export_preset_fields.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/export/preset_record_exporter.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/export.dart';

class ExportPresetEditForm extends ConsumerStatefulWidget {
  const ExportPresetEditForm({
    super.key,
    required this.presetName,
    required this.initialPreset,
    required this.onPresetRenamed,
  });

  final String presetName;
  final ExportPresetModel initialPreset;
  final void Function(String, String) onPresetRenamed;

  @override
  ConsumerState<ExportPresetEditForm> createState() =>
      _ExportPresetEditFormState();
}

class _ExportPresetEditFormState extends ConsumerState<ExportPresetEditForm> {
  late TextEditingController _nameController;
  late ExportPresetModel _preset;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.presetName);
    _preset = widget.initialPreset;
  }

  @override
  void didUpdateWidget(covariant ExportPresetEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.presetName != widget.presetName) {
      _nameController.text = widget.presetName;
      _preset = widget.initialPreset;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _areMappingsEqual(
      List<ExportFieldMapping> list1, List<ExportFieldMapping> list2) {
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      final m1 = list1[i];
      final m2 = list2[i];
      if (m1.expression != m2.expression ||
          m1.headerOverride != m2.headerOverride ||
          m1.textType != m2.textType ||
          m1.formatOption != m2.formatOption ||
          m1.caseFormat != m2.caseFormat ||
          m1.nullFallbackOption != m2.nullFallbackOption ||
          m1.customNullFallbackText != m2.customNullFallbackText ||
          m1.nestedNamespace != m2.nestedNamespace ||
          m1.nestedFields.join(',') != m2.nestedFields.join(',') ||
          m1.nestedMode != m2.nestedMode ||
          m1.listMode != m2.listMode ||
          m1.indexedHeaderStyle != m2.indexedHeaderStyle ||
          m1.fieldSeparator != m2.fieldSeparator ||
          m1.recordSeparator != m2.recordSeparator) {
        return false;
      }
    }
    return true;
  }

  void _showPreview() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final exporter = PresetRecordExporter(ref: ref, preset: _preset);
      final previewData = await exporter.getPreviewData();
      if (mounted) {
        Navigator.pop(context);
      }

      if (previewData.headers.isEmpty || previewData.rows.isEmpty) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Preview Data'),
              content: const Text(
                'No records matched the selected filters, or mappings are empty.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => PreviewTableDialog(
            headers: previewData.headers,
            rows: previewData.rows,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to generate preview: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _update({
    RecordType? recordType,
    SpecimenRecordType? specimenRecordType,
    ExportHeaderFormat? headerFormat,
    List<ExportFieldMapping>? mappings,
  }) =>
      setState(() {
        _preset = ExportPresetModel(
          recordType: recordType ?? _preset.recordType,
          specimenRecordType: specimenRecordType ?? _preset.specimenRecordType,
          headerFormat: headerFormat ?? _preset.headerFormat,
          mappings: mappings ?? _preset.mappings,
        );
      });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final hasChanges = _preset.mappings.length !=
                widget.initialPreset.mappings.length ||
            _nameController.text.trim() != widget.presetName ||
            _preset.recordType != widget.initialPreset.recordType ||
            _preset.specimenRecordType !=
                widget.initialPreset.specimenRecordType ||
            _preset.headerFormat != widget.initialPreset.headerFormat ||
            !_areMappingsEqual(_preset.mappings, widget.initialPreset.mappings);

        if (!hasChanges) {
          Navigator.pop(context);
          return;
        }

        final exit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
              'You have unsaved changes to your preset settings. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onErrorContainer,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Leave without saving'),
              ),
            ],
          ),
        );

        if (exit == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: FormCard(
        title: 'Edit ${widget.presetName}',
        isExpanded: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Preset name'),
              ),
            ),
            _PresetSettingsCard(
              preset: _preset,
              onRecordTypeChanged: (value) => _update(recordType: value),
              onSpecimenRecordTypeChanged: (value) =>
                  _update(specimenRecordType: value),
              onHeaderFormatChanged: (value) => _update(headerFormat: value),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Edit Mappings',
                      icon: Icons.list_alt_outlined,
                      onPressed: () async {
                        final updated = await Navigator.push<ExportPresetModel>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExportPresetFieldsScreen(
                              preset: _preset,
                            ),
                          ),
                        );
                        if (updated != null) {
                          setState(() {
                            _preset = updated;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.visibility_outlined),
                    tooltip: 'Preview Export Table',
                    onPressed: _showPreview,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                  label: 'Save', icon: Icons.save, onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final errors = validateExportPreset(_preset);
    if (name.isEmpty) errors.insert(0, 'Preset name cannot be empty.');
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errors.join('\n'))));
      return;
    }
    if (name != widget.presetName) {
      await ref
          .read(exportPresetNotifierProvider.notifier)
          .deletePreset(widget.presetName);
      widget.onPresetRenamed(widget.presetName, name);
    }
    await ref
        .read(exportPresetNotifierProvider.notifier)
        .savePreset(name, _preset);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Preset saved')));
    }
  }
}

class _PresetSettingsCard extends StatelessWidget {
  const _PresetSettingsCard({
    required this.preset,
    required this.onRecordTypeChanged,
    required this.onSpecimenRecordTypeChanged,
    required this.onHeaderFormatChanged,
  });

  final ExportPresetModel preset;
  final ValueChanged<RecordType> onRecordTypeChanged;
  final ValueChanged<SpecimenRecordType> onSpecimenRecordTypeChanged;
  final ValueChanged<ExportHeaderFormat> onHeaderFormatChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              DropdownButtonFormField<RecordType>(
                initialValue: preset.recordType,
                decoration: const InputDecoration(labelText: 'Record type'),
                items: RecordType.values
                    .where((type) => type != RecordType.none)
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(recordTypeToString(type)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) onRecordTypeChanged(value);
                },
              ),
              if (preset.recordType == RecordType.specimenRecord) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<SpecimenRecordType>(
                  initialValue: preset.specimenRecordType,
                  decoration:
                      const InputDecoration(labelText: 'Specimen taxon group'),
                  items: SpecimenRecordType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) onSpecimenRecordTypeChanged(value);
                  },
                ),
              ],
              const SizedBox(height: 8),
              DropdownButtonFormField<ExportHeaderFormat>(
                initialValue: preset.headerFormat,
                decoration:
                    const InputDecoration(labelText: 'Generated header format'),
                items: const [
                  DropdownMenuItem(
                    value: ExportHeaderFormat.tableFieldName,
                    child: Text('table::fieldName'),
                  ),
                  DropdownMenuItem(
                    value: ExportHeaderFormat.fieldName,
                    child: Text('fieldName'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onHeaderFormatChanged(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
