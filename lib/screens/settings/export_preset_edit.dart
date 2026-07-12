import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/export/preset_record_exporter.dart';
import 'package:nahpu/services/providers/database.dart';
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
  String? _fieldToAdd;

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

  @override
  Widget build(BuildContext context) {
    final availableFields = _availableFields();
    return FormCard(
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
          _AddMappingControls(
            availableFields: availableFields,
            selectedField: _fieldToAdd,
            onSelectedFieldChanged: (value) =>
                setState(() => _fieldToAdd = value),
            onAddScalar: _fieldToAdd == null ? null : _addScalar,
            onAddNested: _addNested,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _preset.mappings.length,
              onReorderItem: _reorder,
              itemBuilder: (context, index) => _ExportMappingCard(
                key: ValueKey('mapping-$index'),
                mapping: _preset.mappings[index],
                onRemove: () => _remove(index),
                onChanged: (mapping) => _replace(index, mapping),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
                label: 'Save', icon: Icons.save, onPressed: _save),
          ),
        ],
      ),
    );
  }

  List<String> _availableFields() {
    final db = ref.read(databaseProvider);
    return [
      for (final table in db.allTables)
        for (final column in table.$columns)
          '${table.actualTableName}::${column.name}',
    ];
  }

  void _addScalar() {
    final field = _fieldToAdd;
    if (field == null) return;
    _update(mappings: [
      ..._preset.mappings,
      ExportFieldMapping(expression: '[$field]'),
    ]);
  }

  void _addNested() => _update(mappings: [
        ..._preset.mappings,
        const ExportFieldMapping(
          expression: '',
          nestedNamespace: 'coordinate',
          nestedFields: ['decimalLatitude', 'decimalLongitude'],
        ),
      ]);

  void _remove(int index) {
    final mappings = List<ExportFieldMapping>.from(_preset.mappings)
      ..removeAt(index);
    _update(mappings: mappings);
  }

  void _replace(int index, ExportFieldMapping mapping) {
    final mappings = List<ExportFieldMapping>.from(_preset.mappings);
    mappings[index] = mapping;
    _update(mappings: mappings);
  }

  void _reorder(int oldIndex, int newIndex) {
    final mappings = List<ExportFieldMapping>.from(_preset.mappings);
    final item = mappings.removeAt(oldIndex);
    mappings.insert(newIndex, item);
    _update(mappings: mappings);
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

class _AddMappingControls extends StatelessWidget {
  const _AddMappingControls({
    required this.availableFields,
    required this.selectedField,
    required this.onSelectedFieldChanged,
    required this.onAddScalar,
    required this.onAddNested,
  });

  final List<String> availableFields;
  final String? selectedField;
  final ValueChanged<String?> onSelectedFieldChanged;
  final VoidCallback? onAddScalar;
  final VoidCallback onAddNested;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: selectedField,
              decoration: const InputDecoration(labelText: 'Add source field'),
              items: availableFields
                  .map(
                    (field) =>
                        DropdownMenuItem(value: field, child: Text(field)),
                  )
                  .toList(growable: false),
              onChanged: onSelectedFieldChanged,
            ),
          ),
          IconButton(
            tooltip: 'Add field mapping',
            icon: const Icon(Icons.add),
            onPressed: onAddScalar,
          ),
          IconButton(
            tooltip: 'Add nested mapping',
            icon: const Icon(Icons.account_tree_outlined),
            onPressed: onAddNested,
          ),
        ],
      ),
    );
  }
}

class _ExportMappingCard extends StatelessWidget {
  const _ExportMappingCard({
    super.key,
    required this.mapping,
    required this.onRemove,
    required this.onChanged,
  });

  final ExportFieldMapping mapping;
  final VoidCallback onRemove;
  final ValueChanged<ExportFieldMapping> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                      mapping.isNested ? 'Nested mapping' : 'Field mapping'),
                ),
                IconButton(
                  tooltip: 'Remove mapping',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                ),
                const Icon(Icons.drag_handle),
              ],
            ),
            if (mapping.isNested)
              _NestedMappingFields(mapping: mapping, onChanged: onChanged)
            else
              _ScalarMappingFields(mapping: mapping, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _ScalarMappingFields extends StatelessWidget {
  const _ScalarMappingFields({required this.mapping, required this.onChanged});

  final ExportFieldMapping mapping;
  final ValueChanged<ExportFieldMapping> onChanged;

  @override
  Widget build(BuildContext context) {
    final textType =
        {'normal', 'encoded', 'list', 'coordinates'}.contains(mapping.textType)
            ? mapping.textType
            : 'normal';
    return Column(
      children: [
        TextFormField(
          key: ValueKey('expression-${mapping.expression}'),
          initialValue: mapping.expression,
          decoration: const InputDecoration(
            labelText: 'Source expression',
            helperText:
                'Use document placeholders, e.g. [specimen::catalogNum].',
          ),
          onChanged: (value) => onChanged(mapping.copyWith(expression: value)),
        ),
        TextFormField(
          key: ValueKey('header-${mapping.headerOverride}'),
          initialValue: mapping.headerOverride ?? '',
          decoration:
              const InputDecoration(labelText: 'Custom header (optional)'),
          onChanged: (value) => onChanged(
            mapping.copyWith(
              headerOverride: value,
              clearHeaderOverride: value.trim().isEmpty,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: textType,
          decoration: const InputDecoration(labelText: 'Mapping format'),
          items: const [
            DropdownMenuItem(value: 'normal', child: Text('Normal text')),
            DropdownMenuItem(value: 'encoded', child: Text('Encoded text')),
            DropdownMenuItem(value: 'list', child: Text('List values')),
            DropdownMenuItem(value: 'coordinates', child: Text('Coordinates')),
          ],
          onChanged: (value) {
            if (value != null) onChanged(mapping.copyWith(textType: value));
          },
        ),
        TextFormField(
          key: ValueKey('format-${mapping.formatOption}'),
          initialValue: mapping.formatOption,
          decoration: const InputDecoration(
            labelText: 'Format option',
            helperText: 'Examples: enum, comma, dms, or custom_map:0=No,1=Yes.',
          ),
          onChanged: (value) =>
              onChanged(mapping.copyWith(formatOption: value)),
        ),
      ],
    );
  }
}

class _NestedMappingFields extends StatelessWidget {
  const _NestedMappingFields({required this.mapping, required this.onChanged});

  final ExportFieldMapping mapping;
  final ValueChanged<ExportFieldMapping> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          key: ValueKey('namespace-${mapping.nestedNamespace}'),
          initialValue: mapping.nestedNamespace,
          decoration:
              const InputDecoration(labelText: 'Related record namespace'),
          onChanged: (value) =>
              onChanged(mapping.copyWith(nestedNamespace: value)),
        ),
        TextFormField(
          key: ValueKey('nested-fields-${mapping.nestedFields.join(',')}'),
          initialValue: mapping.nestedFields.join(', '),
          decoration: const InputDecoration(
              labelText: 'Child fields (comma separated)'),
          onChanged: (value) => onChanged(
            mapping.copyWith(
              nestedFields: value
                  .split(',')
                  .map((field) => field.trim())
                  .where((field) => field.isNotEmpty)
                  .toList(),
            ),
          ),
        ),
        TextFormField(
          key: ValueKey('nested-header-${mapping.headerOverride}'),
          initialValue: mapping.headerOverride ?? '',
          decoration:
              const InputDecoration(labelText: 'Header prefix (optional)'),
          onChanged: (value) => onChanged(
            mapping.copyWith(
              headerOverride: value,
              clearHeaderOverride: value.trim().isEmpty,
            ),
          ),
        ),
        DropdownButtonFormField<NestedExportMode>(
          initialValue: mapping.nestedMode,
          decoration: const InputDecoration(labelText: 'Nested output'),
          items: const [
            DropdownMenuItem(
              value: NestedExportMode.concatenate,
              child: Text('Concatenate into one column'),
            ),
            DropdownMenuItem(
              value: NestedExportMode.spreadColumns,
              child: Text('Spread indexed columns'),
            ),
            DropdownMenuItem(
              value: NestedExportMode.expandRows,
              child: Text('Expand rows'),
            ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(mapping.copyWith(nestedMode: value));
          },
        ),
        if (mapping.nestedMode == NestedExportMode.concatenate)
          _NestedSeparatorFields(mapping: mapping, onChanged: onChanged),
      ],
    );
  }
}

class _NestedSeparatorFields extends StatelessWidget {
  const _NestedSeparatorFields(
      {required this.mapping, required this.onChanged});

  final ExportFieldMapping mapping;
  final ValueChanged<ExportFieldMapping> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: mapping.fieldSeparator,
            decoration: const InputDecoration(labelText: 'Field separator'),
            onChanged: (value) =>
                onChanged(mapping.copyWith(fieldSeparator: value)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: mapping.recordSeparator,
            decoration: const InputDecoration(labelText: 'Record separator'),
            onChanged: (value) =>
                onChanged(mapping.copyWith(recordSeparator: value)),
          ),
        ),
      ],
    );
  }
}
