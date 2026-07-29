import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/inline_grouped_field_picker.dart';
import 'package:nahpu/screens/shared/text_replacement_rules_editor.dart';
import 'package:nahpu/services/conditional_brackets.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/preset_record_exporter.dart';
import 'package:nahpu/services/export/export_header_resolver.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/text_replacements.dart';

class ExportPresetFieldsScreen extends ConsumerStatefulWidget {
  const ExportPresetFieldsScreen({
    super.key,
    required this.preset,
    this.onPresetChanged,
  });

  final ExportPresetModel preset;
  final ValueChanged<ExportPresetModel>? onPresetChanged;

  @override
  ConsumerState<ExportPresetFieldsScreen> createState() =>
      _ExportPresetFieldsScreenState();
}

class _ExportPresetFieldsScreenState
    extends ConsumerState<ExportPresetFieldsScreen> {
  late ExportPresetModel _preset;

  @override
  void initState() {
    super.initState();
    _preset = widget.preset;
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.sizeOf(context).width > 600;
    final scheme = Theme.of(context).colorScheme;
    final canAddNested = _nestedFieldGroups(
      _availableFieldGroups(
        ref.read(databaseProvider),
        _preset.recordType,
        _preset.specimenRecordType,
      ),
    ).isNotEmpty;

    final availableFieldsWidget = _AvailableFieldsSection(
      recordType: _preset.recordType,
      specimenRecordType: _preset.specimenRecordType,
      mappings: _preset.mappings,
      onFieldToggled: _toggleStandardField,
    );

    final selectedFieldsWidget = Material(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              height: 48,
              child: _SelectedMappingsHeader(
                key: const ValueKey('selected-mappings-header'),
                canAddNested: canAddNested,
                onAddCombined: _addCombined,
                onAddNested: _addNested,
              ),
            ),
          ),
          const Divider(height: 1.0),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _preset.mappings.length,
              onReorderItem: _reorder,
              itemBuilder: (context, index) => _ExportMappingCard(
                key: ValueKey('mapping-$index'),
                mapping: _preset.mappings[index],
                onRemove: () => _remove(index),
                onCustomize: () => _customizeMapping(index),
              ),
            ),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Preview'),
                onPressed: _showPreview,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Preset Mappings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _preset),
        ),
      ),
      body: PopScope(
        canPop: true,
        child: isLargeScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: availableFieldsWidget,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: selectedFieldsWidget,
                    ),
                  ),
                ],
              )
            : DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Available Fields'),
                        Tab(text: 'Selected Mappings'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: availableFieldsWidget,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: selectedFieldsWidget,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _toggleStandardField(String field, bool selected) {
    final mappings = List<ExportFieldMapping>.from(_preset.mappings);
    final index = mappings.indexWhere(
      (mapping) =>
          !mapping.isNested && _directSourceField(mapping.expression) == field,
    );
    if (selected && index == -1) {
      mappings.add(ExportFieldMapping(expression: '[$field]'));
    } else if (!selected && index != -1) {
      mappings.removeAt(index);
    }
    _update(mappings: mappings);
  }

  String? _directSourceField(String expression) {
    return RegExp(
      r'^\s*\[([^\]]+)\]\s*$',
    ).firstMatch(expression)?.group(1)?.trim();
  }

  void _remove(int index) {
    final mappings = List<ExportFieldMapping>.from(_preset.mappings)
      ..removeAt(index);
    _update(mappings: mappings);
  }

  void _addNested() {
    const preferredNamespaces = [
      'coordinate',
      'collEffort',
      'collPersonnel',
      'specimenPart',
    ];
    final groups = _nestedFieldGroups(
      _availableFieldGroups(
        ref.read(databaseProvider),
        _preset.recordType,
        _preset.specimenRecordType,
      ),
    );
    if (groups.isEmpty) return;
    final namespace = preferredNamespaces.firstWhere(
      groups.containsKey,
      orElse: () => groups.keys.first,
    );
    _openMappingCustomizer(
      ExportFieldMapping(
        expression: '',
        nestedNamespace: namespace,
        nestedMode: NestedExportMode.spreadColumns,
      ),
      allowExpandRows: !_preset.mappings.any(
        (mapping) =>
            mapping.isNested &&
            mapping.nestedMode == NestedExportMode.expandRows,
      ),
      onSave: (mapping) => _update(mappings: [..._preset.mappings, mapping]),
    );
  }

  void _addCombined() {
    _openMappingCustomizer(
      const ExportFieldMapping(expression: ''),
      allowExpandRows: true,
      onSave: (mapping) => _update(mappings: [..._preset.mappings, mapping]),
      initialMappingKind: 'combined',
    );
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

  void _update({List<ExportFieldMapping>? mappings}) {
    setState(() {
      _preset = ExportPresetModel(
        recordType: _preset.recordType,
        specimenRecordType: _preset.specimenRecordType,
        headerFormat: _preset.headerFormat,
        mappings: mappings ?? _preset.mappings,
      );
    });
    widget.onPresetChanged?.call(_preset);
  }

  void _customizeMapping(int index) {
    final mapping = _preset.mappings[index];
    final allowExpandRows = !_preset.mappings.asMap().entries.any(
      (entry) =>
          entry.key != index &&
          entry.value.isNested &&
          entry.value.nestedMode == NestedExportMode.expandRows,
    );

    _openMappingCustomizer(
      mapping,
      allowExpandRows: allowExpandRows,
      onSave: (updated) => _replace(index, updated),
    );
  }

  void _openMappingCustomizer(
    ExportFieldMapping mapping, {
    required bool allowExpandRows,
    required ValueChanged<ExportFieldMapping> onSave,
    String? initialMappingKind,
  }) {
    final isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    if (isLargeScreen) {
      showDialog(
        context: context,
        builder: (context) => _MappingCustomizerDialog(
          mapping: mapping,
          recordType: _preset.recordType,
          specimenRecordType: _preset.specimenRecordType,
          headerFormat: _preset.headerFormat,
          allowExpandRows: allowExpandRows,
          onSave: onSave,
          initialMappingKind: initialMappingKind,
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => _MappingCustomizerBottomSheet(
          mapping: mapping,
          recordType: _preset.recordType,
          specimenRecordType: _preset.specimenRecordType,
          headerFormat: _preset.headerFormat,
          allowExpandRows: allowExpandRows,
          onSave: onSave,
          initialMappingKind: initialMappingKind,
        ),
      );
    }
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
}

class _AvailableFieldsSection extends ConsumerStatefulWidget {
  const _AvailableFieldsSection({
    required this.recordType,
    required this.specimenRecordType,
    required this.mappings,
    required this.onFieldToggled,
  });

  final RecordType recordType;
  final SpecimenRecordType specimenRecordType;
  final List<ExportFieldMapping> mappings;
  final void Function(String field, bool selected) onFieldToggled;

  @override
  ConsumerState<_AvailableFieldsSection> createState() =>
      _AvailableFieldsSectionState();
}

class _AvailableFieldsSectionState
    extends ConsumerState<_AvailableFieldsSection> {
  String _fieldDisplayOption = 'short';
  bool _isFieldSelected(String field) {
    return _selectedSourceFields(widget.mappings).contains(field);
  }

  Set<String> _selectedSourceFields(List<ExportFieldMapping> mappings) {
    return mappings
        .where((mapping) => !mapping.isNested)
        .map(
          (mapping) => RegExp(
            r'^\s*\[([^\]]+)\]\s*$',
          ).firstMatch(mapping.expression)?.group(1)?.trim(),
        )
        .whereType<String>()
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _getAllGroups();
    final groupKeys = groups.keys.toList();
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              key: const ValueKey('available-fields-header'),
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Insert Source Field',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: DropdownButton<String>(
                      value: _fieldDisplayOption,
                      isDense: true,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: 'full',
                          child: Text(
                            'Table::Field',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'short',
                          child: Text(
                            'Field Only',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _fieldDisplayOption = v;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1.0),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: groupKeys.length,
              itemBuilder: (context, index) {
                final table = groupKeys[index];
                final fields = groups[table]!;
                return ExpansionTile(
                  title: Text(
                    databaseTableDisplayTitle(table),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                  ),
                  dense: true,
                  childrenPadding: EdgeInsets.zero,
                  children: fields.map((field) {
                    final displayLabel = _fieldDisplayOption == 'short'
                        ? '[${field.split('::').last}]'
                        : '[$field]';
                    final isSelected = _isFieldSelected(field);

                    return CheckboxListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      value: isSelected,
                      title: Text(
                        displayLabel,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13.0,
                        ),
                      ),
                      onChanged: (bool? val) {
                        if (val != null) {
                          widget.onFieldToggled(field, val);
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _getAllGroups() {
    return _availableFieldGroups(
      ref.read(databaseProvider),
      widget.recordType,
      widget.specimenRecordType,
    );
  }
}

Map<String, List<String>> _availableFieldGroups(
  Database db,
  RecordType recordType,
  SpecimenRecordType specimenRecordType,
) {
  final Map<String, List<String>> groups = {};
  final Set<String> allowedTables;
  switch (recordType) {
    case RecordType.none:
      allowedTables = {'personnel', 'project'};
      break;
    case RecordType.narrative:
      allowedTables = {'narrative', 'site', 'personnel'};
      break;
    case RecordType.site:
      allowedTables = {'site', 'personnel', 'coordinate'};
      break;
    case RecordType.collEvent:
      allowedTables = {
        'collEvent',
        'site',
        'weather',
        'coordinate',
        'collEffort',
        'collPersonnel',
      };
      break;
    case RecordType.specimenRecord:
    case RecordType.specimenParts:
      allowedTables = {
        'specimen',
        'taxonomy',
        'personnel',
        'project',
        'collEvent',
        'collEffort',
        'collPersonnel',
        'site',
        'coordinate',
        'weather',
        'mammalAttribute',
        'birdAttribute',
        'herpAttribute',
        'specimenPart',
      };
      if (specimenRecordType == SpecimenRecordType.generalMammals ||
          specimenRecordType == SpecimenRecordType.bats ||
          specimenRecordType == SpecimenRecordType.allMammals) {
        allowedTables.remove('birdAttribute');
        allowedTables.remove('herpAttribute');
      } else if (specimenRecordType == SpecimenRecordType.birds) {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('herpAttribute');
      } else if (specimenRecordType == SpecimenRecordType.herpetofauna) {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('birdAttribute');
      }
      break;
  }

  for (var table in db.allTables) {
    final tableName = table.actualTableName;
    if (allowedTables.contains(tableName)) {
      groups[tableName] = table.$columns
          .map<String>((c) => '$tableName::${c.name}')
          .toList();
    }
  }
  return groups;
}

Map<String, List<String>> _nestedFieldGroups(Map<String, List<String>> groups) {
  // Nested mappings retain the same table choices as the source-field picker.
  // Some sources are repeated in only certain record types, but preserving the
  // full set keeps existing and advanced mappings editable.
  return Map<String, List<String>>.from(groups);
}

Map<String, List<String>> _fieldGroupsWithValue(
  Map<String, List<String>> groups,
  String? value,
) {
  final result = {
    for (final entry in groups.entries)
      entry.key: List<String>.from(entry.value),
  };
  if (value == null || value.trim().isEmpty) return result;

  final normalized = value.trim();
  if (result.values.any((fields) => fields.contains(normalized))) {
    return result;
  }
  final table = _fieldTableName(normalized);
  result.putIfAbsent(table, () => <String>[]).add(normalized);
  return result;
}

Map<String, List<String>> _withoutField(
  Map<String, List<String>> groups,
  String? excludedField,
) {
  if (excludedField == null || excludedField.trim().isEmpty) return groups;
  final normalized = excludedField.trim().toLowerCase();
  return {
    for (final entry in groups.entries)
      if (entry.value.any((field) => field.toLowerCase() != normalized))
        entry.key: entry.value
            .where((field) => field.toLowerCase() != normalized)
            .toList(growable: false),
  };
}

String _fieldTableName(String value) {
  final separator = value.indexOf('::');
  return separator == -1 ? 'Other fields' : value.substring(0, separator);
}

String _fieldDisplayName(String value) {
  final separator = value.lastIndexOf('::');
  return separator == -1 ? value : value.substring(separator + 2);
}

Future<String?> _showGroupedFieldPicker(
  BuildContext context, {
  required String title,
  required Map<String, List<String>> groups,
  String? selectedValue,
}) {
  final content = _GroupedFieldPickerContent(
    title: title,
    groups: groups,
    selectedValue: selectedValue,
  );
  if (MediaQuery.sizeOf(context).width > 600) {
    return showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: SizedBox(width: 520, height: 560, child: content),
      ),
    );
  }
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SafeArea(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .8,
          child: content,
        ),
      ),
    ),
  );
}

class _GroupedFieldPicker extends StatelessWidget {
  const _GroupedFieldPicker({
    super.key,
    required this.value,
    required this.groups,
    required this.decoration,
    required this.onChanged,
  });

  final String? value;
  final Map<String, List<String>> groups;
  final InputDecoration decoration;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null ? null : _fieldDisplayName(value!);
    final tableName = value == null ? null : _fieldTableName(value!);
    return Semantics(
      button: true,
      label: decoration.labelText,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          final selected = await _showGroupedFieldPicker(
            context,
            title: decoration.labelText ?? 'Select field',
            groups: groups,
            selectedValue: value,
          );
          if (selected != null) onChanged(selected);
        },
        child: InputDecorator(
          decoration: decoration.copyWith(
            hintText: displayValue == null ? 'Choose a field' : null,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          isEmpty: displayValue == null,
          child: displayValue == null
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(displayValue, overflow: TextOverflow.ellipsis),
                    Text(
                      tableName!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GroupedFieldPickerContent extends StatefulWidget {
  const _GroupedFieldPickerContent({
    required this.title,
    required this.groups,
    required this.selectedValue,
  });

  final String title;
  final Map<String, List<String>> groups;
  final String? selectedValue;

  @override
  State<_GroupedFieldPickerContent> createState() =>
      _GroupedFieldPickerContentState();
}

class _GroupedFieldPickerContentState
    extends State<_GroupedFieldPickerContent> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _onQueryChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final filteredGroups = _filteredGroups();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Close field picker',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Search fields or tables',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filteredGroups.isEmpty
              ? const Center(child: Text('No matching fields.'))
              : ListView(
                  children: [
                    for (final entry in filteredGroups.entries) ...[
                      Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      for (final field in entry.value)
                        ListTile(
                          title: Text(_fieldDisplayName(field)),
                          subtitle: Text(entry.key),
                          selected: field == widget.selectedValue,
                          onTap: () => Navigator.pop(context, field),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Map<String, List<String>> _filteredGroups() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.groups;
    final matches = <String, List<String>>{};
    for (final entry in widget.groups.entries) {
      final tableMatches = entry.key.toLowerCase().contains(query);
      final fields = tableMatches
          ? entry.value
          : entry.value
                .where(
                  (field) =>
                      _fieldDisplayName(field).toLowerCase().contains(query),
                )
                .toList(growable: false);
      if (fields.isNotEmpty) matches[entry.key] = fields;
    }
    return matches;
  }
}

class _SelectedMappingsHeader extends StatelessWidget {
  const _SelectedMappingsHeader({
    super.key,
    required this.canAddNested,
    required this.onAddCombined,
    required this.onAddNested,
  });

  final bool canAddNested;
  final VoidCallback onAddCombined;
  final VoidCallback onAddNested;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactActions = constraints.maxWidth < 440;
        final title = Text(
          'Selected Mappings',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        );
        if (compactActions) {
          return Row(
            children: [
              Expanded(child: title),
              IconButton(
                tooltip: 'Add combined',
                onPressed: onAddCombined,
                icon: const Icon(Icons.merge_type_outlined),
              ),
              IconButton(
                tooltip: 'Add nested',
                onPressed: canAddNested ? onAddNested : null,
                icon: const Icon(Icons.account_tree_outlined),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            TextButton.icon(
              onPressed: onAddCombined,
              icon: const Icon(Icons.merge_type_outlined),
              label: const Text('Add combined'),
            ),
            TextButton.icon(
              onPressed: canAddNested ? onAddNested : null,
              icon: const Icon(Icons.account_tree_outlined),
              label: const Text('Add nested'),
            ),
          ],
        );
      },
    );
  }
}

class _ExportMappingCard extends StatelessWidget {
  const _ExportMappingCard({
    super.key,
    required this.mapping,
    required this.onRemove,
    required this.onCustomize,
  });

  final ExportFieldMapping mapping;
  final VoidCallback onRemove;
  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final String title;
    final String subtitle;
    final IconData icon;

    if (mapping.isNested) {
      title = 'Nested: ${mapping.nestedNamespace ?? 'Unnamed'}';
      subtitle =
          '${_nestedModeLabel(mapping.nestedMode)} · '
          '${mapping.nestedFields.join(', ')}';
      icon = Icons.account_tree_outlined;
    } else if (mapping.textType == 'list') {
      title = 'List: ${mapping.expression}';
      subtitle = mapping.listMode == ListExportMode.spreadColumns
          ? 'Indexed columns · ${_indexedStyleLabel(mapping.indexedHeaderStyle)}'
          : 'One column · ${mapping.formatOption} separator';
      icon = Icons.view_column_outlined;
    } else {
      title = isDirectExportSourceExpression(mapping.expression)
          ? 'Field: ${mapping.expression}'
          : 'Combined: ${mapping.expression}';
      subtitle =
          'Format: ${_valueFormatLabel(mapping.textType)} · '
          'Options: ${mapping.formatOption}';
      icon = Icons.grid_on_outlined;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: ListTile(
          leading: Icon(icon, color: colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Customize',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onCustomize,
              ),
              IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: onRemove,
              ),
              const Icon(Icons.drag_handle),
            ],
          ),
        ),
      ),
    );
  }

  String _nestedModeLabel(NestedExportMode mode) => switch (mode) {
    NestedExportMode.concatenate => 'One column',
    NestedExportMode.spreadColumns => 'Indexed columns',
    NestedExportMode.expandRows => 'Repeated rows',
  };

  String _indexedStyleLabel(IndexedHeaderStyle style) => switch (style) {
    IndexedHeaderStyle.underscore => 'field_1',
    IndexedHeaderStyle.compact => 'field1',
    IndexedHeaderStyle.brackets => 'field[1]',
  };

  String _valueFormatLabel(String textType) => switch (textType) {
    kConditionalBracketExportTextType => 'conditional brackets',
    kConditionalFieldExportTextType => 'conditional field',
    kConditionalValueExportTextType => 'conditional value',
    _ => textType,
  };
}

class _MappingCustomizerForm extends ConsumerStatefulWidget {
  const _MappingCustomizerForm({
    required this.mapping,
    required this.recordType,
    required this.specimenRecordType,
    required this.headerFormat,
    required this.allowExpandRows,
    required this.onSave,
    required this.onCancel,
    this.initialMappingKind,
  });

  final ExportFieldMapping mapping;
  final RecordType recordType;
  final SpecimenRecordType specimenRecordType;
  final ExportHeaderFormat headerFormat;
  final bool allowExpandRows;
  final ValueChanged<ExportFieldMapping> onSave;
  final VoidCallback onCancel;
  final String? initialMappingKind;

  @override
  ConsumerState<_MappingCustomizerForm> createState() =>
      _MappingCustomizerFormState();
}

class _MappingCustomizerFormState
    extends ConsumerState<_MappingCustomizerForm> {
  late ExportFieldMapping _localMapping;
  late String _mappingKind;
  late TextEditingController _expressionController;
  late TextEditingController _headerController;
  late TextEditingController _formatOptionController;
  late TextEditingController _customNullTextController;
  late TextEditingController _conditionalTextController;
  late TextEditingController _nestedNamespaceController;
  late TextEditingController _fieldSepController;
  late TextEditingController _recordSepController;
  late List<String> _nestedFields;

  @override
  void initState() {
    super.initState();
    _localMapping = widget.mapping;
    _mappingKind =
        widget.initialMappingKind ??
        (_localMapping.isNested
            ? 'nested'
            : _localMapping.textType == 'list'
            ? 'list'
            : isDirectExportSourceExpression(_localMapping.expression)
            ? 'scalar'
            : 'combined');

    _expressionController = TextEditingController(
      text: _localMapping.expression,
    );
    _headerController = TextEditingController(
      text: _localMapping.headerOverride ?? '',
    );
    _formatOptionController = TextEditingController(
      text: _localMapping.formatOption,
    );
    _customNullTextController = TextEditingController(
      text: _localMapping.customNullFallbackText,
    );
    _conditionalTextController = TextEditingController(
      text: _localMapping.conditionalText,
    );

    _nestedNamespaceController = TextEditingController(
      text: _localMapping.nestedNamespace ?? '',
    );
    _nestedFields = List<String>.from(_localMapping.nestedFields);
    _fieldSepController = TextEditingController(
      text: _localMapping.fieldSeparator,
    );
    _recordSepController = TextEditingController(
      text: _localMapping.recordSeparator,
    );
  }

  @override
  void dispose() {
    _expressionController.dispose();
    _headerController.dispose();
    _formatOptionController.dispose();
    _customNullTextController.dispose();
    _conditionalTextController.dispose();
    _nestedNamespaceController.dispose();
    _fieldSepController.dispose();
    _recordSepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _availableFieldGroups(
      ref.read(databaseProvider),
      widget.recordType,
      widget.specimenRecordType,
    );
    final selectedSource = _exactSourceField(_expressionController.text);
    final sourceGroups = _fieldGroupsWithValue(groups, selectedSource);
    final namespace = _nestedNamespaceController.text.trim();
    final nestedGroups = _nestedFieldGroups(groups);
    if (namespace.isNotEmpty &&
        groups.containsKey(namespace) &&
        !nestedGroups.containsKey(namespace)) {
      nestedGroups[namespace] = groups[namespace]!;
    }
    final namespaces = nestedGroups.keys.toList();
    if (namespace.isNotEmpty && !namespaces.contains(namespace)) {
      namespaces.add(namespace);
    }
    final availableNestedFields = (nestedGroups[namespace] ?? const <String>[])
        .map((field) => field.split('::').last)
        .toList();
    for (final field in _nestedFields) {
      if (!availableNestedFields.contains(field)) {
        availableNestedFields.add(field);
      }
    }
    final canSave = _canSave();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey('mapping-kind-$_mappingKind'),
          initialValue: _mappingKind,
          decoration: const InputDecoration(labelText: 'Mapping type'),
          items: const [
            DropdownMenuItem(value: 'scalar', child: Text('Single field')),
            DropdownMenuItem(value: 'combined', child: Text('Combined fields')),
            DropdownMenuItem(value: 'list', child: Text('List field')),
            DropdownMenuItem(value: 'nested', child: Text('Nested records')),
          ],
          onChanged: (value) => value == null ? null : _setMappingKind(value),
        ),
        const SizedBox(height: 16),
        if (_mappingKind == 'scalar' || _mappingKind == 'list') ...[
          if (_mappingKind == 'scalar' &&
              (_localMapping.textType == kConditionalBracketExportTextType ||
                  isConditionalReplacementExportTextType(
                    _localMapping.textType,
                  )))
            InlineGroupedFieldPicker(
              key: ValueKey('inline-source-$selectedSource'),
              value: selectedSource,
              groups: sourceGroups,
              decoration: const InputDecoration(
                labelText: 'Source field',
                helperText: 'Choose the NAHPU field that supplies this column.',
              ),
              onChanged: (value) {
                setState(() => _expressionController.text = '[$value]');
              },
            )
          else
            _GroupedFieldPicker(
              key: ValueKey('source-$selectedSource'),
              value: selectedSource,
              groups: sourceGroups,
              decoration: const InputDecoration(
                labelText: 'Source field',
                helperText: 'Choose the NAHPU field that supplies this column.',
              ),
              onChanged: (value) {
                setState(() => _expressionController.text = '[$value]');
              },
            ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _headerController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Column name (optional)',
              helperText: 'Leave blank to use the source field name.',
            ),
          ),
          if (_mappingKind == 'list') ...[
            const SizedBox(height: 16),
            Text('List output', style: Theme.of(context).textTheme.titleSmall),
            RadioGroup<ListExportMode>(
              groupValue: _localMapping.listMode,
              onChanged: _setListMode,
              child: Column(
                children: const [
                  RadioListTile<ListExportMode>(
                    value: ListExportMode.concatenate,
                    title: Text('One column'),
                    subtitle: Text('Example: A, B, C'),
                  ),
                  RadioListTile<ListExportMode>(
                    value: ListExportMode.spreadColumns,
                    title: Text('Indexed columns'),
                    subtitle: Text('Example: field_1, field_2, field_3'),
                  ),
                ],
              ),
            ),
            if (_localMapping.listMode == ListExportMode.concatenate) ...[
              DropdownButtonFormField<String>(
                key: ValueKey(
                  'separator-${_listSeparatorOption(_localMapping.formatOption)}',
                ),
                initialValue: _listSeparatorOption(_localMapping.formatOption),
                decoration: const InputDecoration(labelText: 'Separator'),
                items: const [
                  DropdownMenuItem(value: 'pipe', child: Text('Pipe (A | B)')),
                  DropdownMenuItem(value: 'comma', child: Text('Comma (A, B)')),
                  DropdownMenuItem(
                    value: 'semicolon',
                    child: Text('Semicolon (A; B)'),
                  ),
                  DropdownMenuItem(
                    value: 'slash',
                    child: Text('Slash (A / B)'),
                  ),
                  DropdownMenuItem(value: 'newline', child: Text('New line')),
                  DropdownMenuItem(value: 'bullet', child: Text('Bulleted')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    final option = value == 'custom' ? 'custom:' : value;
                    _localMapping = _localMapping.copyWith(
                      formatOption: option,
                    );
                    _formatOptionController.text = option;
                  });
                },
              ),
              if (_localMapping.formatOption.startsWith('custom:')) ...[
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _localMapping.formatOption.substring(7),
                  decoration: const InputDecoration(
                    labelText: 'Custom separator',
                  ),
                  onChanged: (value) => setState(() {
                    _localMapping = _localMapping.copyWith(
                      formatOption: 'custom:$value',
                    );
                    _formatOptionController.text = 'custom:$value';
                  }),
                ),
              ],
            ] else ...[
              const SizedBox(height: 8),
              _IndexedStyleField(
                value: _localMapping.indexedHeaderStyle,
                onChanged: _setIndexedStyle,
              ),
            ],
          ] else ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('format-${_localMapping.textType}'),
              initialValue: _standardTextType(_localMapping.textType),
              decoration: const InputDecoration(labelText: 'Value format'),
              items: const [
                DropdownMenuItem(value: 'normal', child: Text('Normal text')),
                DropdownMenuItem(value: 'encoded', child: Text('Encoded text')),
                DropdownMenuItem(
                  value: 'coordinates',
                  child: Text('Coordinates'),
                ),
                DropdownMenuItem(
                  value: kConditionalBracketExportTextType,
                  child: Text('Conditional brackets'),
                ),
                DropdownMenuItem(
                  value: kConditionalFieldExportTextType,
                  child: Text('Conditional field'),
                ),
                DropdownMenuItem(
                  value: kConditionalValueExportTextType,
                  child: Text('Conditional value'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _localMapping = _localMapping.copyWith(
                      textType: value,
                      bracketConditions:
                          (value == kConditionalBracketExportTextType ||
                                  isConditionalReplacementExportTextType(
                                    value,
                                  )) &&
                              _localMapping.bracketConditions.isEmpty
                          ? const [
                              ConditionalBracketCondition(
                                sourceField: '',
                                operator: ConditionalComparisonOperator.equals,
                                comparisonValue: '',
                              ),
                            ]
                          : _localMapping.bracketConditions,
                    );
                  });
                }
              },
            ),
            if (_localMapping.textType == kConditionalBracketExportTextType ||
                isConditionalReplacementExportTextType(
                  _localMapping.textType,
                )) ...[
              const SizedBox(height: 12),
              _ConditionalBracketControls(
                fieldGroups: groups,
                targetField: selectedSource,
                compareTargetValue:
                    _localMapping.textType == kConditionalValueExportTextType,
                conditions: _localMapping.bracketConditions,
                mode: _localMapping.bracketConditionMode,
                onChanged: (conditions, mode) => setState(() {
                  _localMapping = _localMapping.copyWith(
                    bracketConditions: conditions,
                    bracketConditionMode: mode,
                  );
                }),
              ),
              if (isConditionalReplacementExportTextType(
                _localMapping.textType,
              )) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _conditionalTextController,
                  onChanged: (value) => setState(() {
                    _localMapping = _localMapping.copyWith(
                      conditionalText: value,
                    );
                  }),
                  decoration: const InputDecoration(
                    labelText: 'Replacement text',
                    helperText:
                        'Written when the condition matches; otherwise the original value is kept.',
                  ),
                ),
              ],
            ],
          ],
        ] else if (_mappingKind == 'combined') ...[
          _ConcatenatedExpressionComposer(
            expression: _expressionController.text,
            fieldGroups: groups,
            onChanged: (expression) => setState(() {
              _expressionController.text = expression;
              _localMapping = _localMapping.copyWith(textType: 'normal');
            }),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _headerController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Column name',
              helperText:
                  'Name the output column containing the combined value.',
            ),
          ),
        ] else ...[
          DropdownButtonFormField<String>(
            key: ValueKey('namespace-$namespace'),
            initialValue: namespaces.contains(namespace) ? namespace : null,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Related records',
              helperText: 'Select the repeated record group to export.',
            ),
            items: namespaces
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _nestedNamespaceController.text = value;
                _nestedFields = [];
                _localMapping = _localMapping.copyWith(
                  nestedNamespace: value,
                  nestedFields: const [],
                );
              });
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Selected child fields',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (_nestedFields.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Select at least one child field below.'),
            )
          else
            ..._nestedFields.asMap().entries.map(
              (entry) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 12,
                  child: Text('${entry.key + 1}'),
                ),
                title: Text(entry.value),
                trailing: Wrap(
                  children: [
                    IconButton(
                      tooltip: 'Move up',
                      onPressed: entry.key == 0
                          ? null
                          : () => _moveNestedField(entry.key, -1),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      tooltip: 'Move down',
                      onPressed: entry.key == _nestedFields.length - 1
                          ? null
                          : () => _moveNestedField(entry.key, 1),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    IconButton(
                      tooltip: 'Remove field',
                      onPressed: () => _toggleNestedField(entry.value, false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Choose child fields'),
            children: availableNestedFields
                .map(
                  (field) => CheckboxListTile(
                    dense: true,
                    value: _nestedFields.contains(field),
                    title: Text(field),
                    onChanged: (selected) =>
                        _toggleNestedField(field, selected ?? false),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _headerController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Column prefix (optional)',
            ),
          ),
          const SizedBox(height: 16),
          Text('Nested output', style: Theme.of(context).textTheme.titleSmall),
          RadioGroup<NestedExportMode>(
            groupValue: _localMapping.nestedMode,
            onChanged: _setNestedMode,
            child: Column(
              children: [
                const RadioListTile<NestedExportMode>(
                  value: NestedExportMode.concatenate,
                  title: Text('One column'),
                  subtitle: Text('Combine all child records into one cell.'),
                ),
                const RadioListTile<NestedExportMode>(
                  value: NestedExportMode.spreadColumns,
                  title: Text('Indexed columns'),
                  subtitle: Text('Create a group of columns for each record.'),
                ),
                RadioListTile<NestedExportMode>(
                  value: NestedExportMode.expandRows,
                  title: const Text('Repeated rows'),
                  subtitle: Text(
                    widget.allowExpandRows
                        ? 'Create one export row per child record.'
                        : 'Another mapping already expands export rows.',
                  ),
                  enabled: widget.allowExpandRows,
                ),
              ],
            ),
          ),
          if (_localMapping.nestedMode == NestedExportMode.concatenate) ...[
            if (widget.headerFormat == ExportHeaderFormat.darwinCore &&
                _nestedFields.length == 1)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Darwin Core list values are separated with " | ".',
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fieldSepController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Field separator',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _recordSepController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Record separator',
                      ),
                    ),
                  ),
                ],
              ),
          ] else if (_localMapping.nestedMode ==
              NestedExportMode.spreadColumns) ...[
            _IndexedStyleField(
              value: _localMapping.indexedHeaderStyle,
              onChanged: _setIndexedStyle,
            ),
          ],
        ],
        const SizedBox(height: 16),
        TextReplacementRulesEditor(
          rules: _localMapping.replacementRules,
          onChanged: (rules) {
            setState(() {
              _localMapping = _localMapping.copyWith(replacementRules: rules);
            });
          },
        ),
        const SizedBox(height: 8),
        _MappingOutputExample(
          mappingKind: _mappingKind,
          sourceExpression: _expressionController.text,
          headerOverride: _headerController.text,
          namespace: _nestedNamespaceController.text,
          nestedFields: _nestedFields,
          listMode: _localMapping.listMode,
          nestedMode: _localMapping.nestedMode,
          indexedHeaderStyle: _localMapping.indexedHeaderStyle,
          headerFormat: widget.headerFormat,
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('Advanced'),
          children: [
            if (_mappingKind != 'nested') ...[
              TextFormField(
                controller: _expressionController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Raw source expression',
                  helperText: 'Example: [specimen::catalogNum]',
                ),
              ),
              if (_mappingKind == 'scalar' &&
                  _localMapping.textType != kConditionalBracketExportTextType &&
                  !isConditionalReplacementExportTextType(
                    _localMapping.textType,
                  )) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _formatOptionController,
                  decoration: const InputDecoration(
                    labelText: 'Raw format option',
                    helperText: 'For example: enum, dms, or custom_map:0=No.',
                  ),
                ),
              ],
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(
                  'null-fallback-${_localMapping.nullFallbackOption}',
                ),
                initialValue: _localMapping.nullFallbackOption,
                decoration: const InputDecoration(labelText: 'Empty value'),
                items: const [
                  DropdownMenuItem(value: 'blank', child: Text('Blank')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom text')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _localMapping = _localMapping.copyWith(
                        nullFallbackOption: value,
                      );
                    });
                  }
                },
              ),
              if (_localMapping.nullFallbackOption == 'custom') ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customNullTextController,
                  decoration: const InputDecoration(
                    labelText: 'Custom empty text',
                  ),
                ),
              ],
            ] else
              TextFormField(
                controller: _nestedNamespaceController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Raw related-record namespace',
                ),
              ),
          ],
        ),
        if (!canSave)
          Text(
            _validationMessage(),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: canSave ? _submit : null,
              child: const Text('Done'),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    ExportFieldMapping finalMapping;
    if (_mappingKind == 'nested') {
      finalMapping = _localMapping.copyWith(
        nestedNamespace: _nestedNamespaceController.text.trim(),
        nestedFields: _nestedFields,
        headerOverride: _headerController.text.trim(),
        clearHeaderOverride: _headerController.text.trim().isEmpty,
        fieldSeparator: _fieldSepController.text,
        recordSeparator: _recordSepController.text,
      );
    } else {
      finalMapping = _localMapping.copyWith(
        expression: _expressionController.text.trim(),
        textType: switch (_mappingKind) {
          'list' => 'list',
          'combined' => 'normal',
          _ => _localMapping.textType,
        },
        clearNestedNamespace: true,
        headerOverride: _headerController.text.trim(),
        clearHeaderOverride: _headerController.text.trim().isEmpty,
        formatOption: _formatOptionController.text.trim(),
        customNullFallbackText: _customNullTextController.text.trim(),
        conditionalText: _conditionalTextController.text,
      );
    }
    widget.onSave(finalMapping);
  }

  void _setMappingKind(String kind) {
    setState(() {
      _mappingKind = kind;
      if (kind == 'nested') {
        final source = _exactSourceField(_expressionController.text);
        final namespace = _nestedNamespaceController.text.trim().isNotEmpty
            ? _nestedNamespaceController.text.trim()
            : source?.split('::').first ?? 'coordinate';
        _nestedNamespaceController.text = namespace;
        _localMapping = _localMapping.copyWith(nestedNamespace: namespace);
      } else {
        _localMapping = _localMapping.copyWith(
          textType: kind == 'list' ? 'list' : 'normal',
          clearNestedNamespace: true,
        );
        if (kind == 'list' &&
            !_isListFormatOption(_localMapping.formatOption)) {
          _localMapping = _localMapping.copyWith(formatOption: 'comma');
          _formatOptionController.text = 'comma';
        }
      }
    });
  }

  void _setListMode(ListExportMode? value) {
    if (value != null) {
      setState(() => _localMapping = _localMapping.copyWith(listMode: value));
    }
  }

  void _setNestedMode(NestedExportMode? value) {
    if (value != null) {
      setState(() => _localMapping = _localMapping.copyWith(nestedMode: value));
    }
  }

  void _setIndexedStyle(IndexedHeaderStyle? value) {
    if (value != null) {
      setState(() {
        _localMapping = _localMapping.copyWith(indexedHeaderStyle: value);
      });
    }
  }

  void _toggleNestedField(String field, bool selected) {
    setState(() {
      if (selected && !_nestedFields.contains(field)) {
        _nestedFields.add(field);
      } else if (!selected) {
        _nestedFields.remove(field);
      }
      _localMapping = _localMapping.copyWith(nestedFields: _nestedFields);
    });
  }

  void _moveNestedField(int index, int offset) {
    setState(() {
      final field = _nestedFields.removeAt(index);
      _nestedFields.insert(index + offset, field);
      _localMapping = _localMapping.copyWith(nestedFields: _nestedFields);
    });
  }

  bool _canSave() => _validationMessage().isEmpty;

  String _validationMessage() {
    for (
      var index = 0;
      index < _localMapping.replacementRules.length;
      index++
    ) {
      final error = validateTextReplacementRule(
        _localMapping.replacementRules[index],
      );
      if (error != null) return 'Replacement ${index + 1}: $error';
    }
    if (_mappingKind == 'nested') {
      if (_nestedNamespaceController.text.trim().isEmpty) {
        return 'Choose a related-record group.';
      }
      if (_nestedFields.isEmpty) return 'Choose at least one child field.';
      if (_localMapping.nestedMode == NestedExportMode.concatenate &&
          (_fieldSepController.text.isEmpty ||
              _recordSepController.text.isEmpty) &&
          !(widget.headerFormat == ExportHeaderFormat.darwinCore &&
              _nestedFields.length == 1)) {
        return 'Field and record separators cannot be empty.';
      }
      if (mappingRequiresHeaderOverride(
        widget.headerFormat,
        _localMapping.copyWith(
          nestedNamespace: _nestedNamespaceController.text.trim(),
          nestedFields: _nestedFields,
          headerOverride: _headerController.text.trim(),
          clearHeaderOverride: _headerController.text.trim().isEmpty,
        ),
      )) {
        return 'Set a custom header for a multi-field concatenated mapping.';
      }
      return '';
    }
    if (_expressionController.text.trim().isEmpty) {
      return _mappingKind == 'combined'
          ? 'Add at least one source field.'
          : 'Choose a source field.';
    }
    if (_mappingKind == 'combined' &&
        !parseExportExpression(
          _expressionController.text,
        ).any((segment) => segment.isField)) {
      return 'Combined values must include at least one source field.';
    }
    if (usesStandardizedExportHeaders(widget.headerFormat) &&
        _headerController.text.trim().isEmpty &&
        _exactSourceField(_expressionController.text) == null) {
      return 'Set a custom header for a composite mapping.';
    }
    if (_mappingKind == 'list' &&
        _localMapping.listMode == ListExportMode.spreadColumns &&
        _exactSourceField(_expressionController.text) == null) {
      return 'Indexed lists require exactly one source field.';
    }
    if (_localMapping.textType == kConditionalBracketExportTextType ||
        isConditionalReplacementExportTextType(_localMapping.textType)) {
      final target = _exactSourceField(_expressionController.text);
      if (target == null) {
        return 'Conditional output requires exactly one source field.';
      }
      if (_localMapping.bracketConditions.isEmpty) {
        return 'Add at least one condition.';
      }
      if (isConditionalReplacementExportTextType(_localMapping.textType) &&
          _conditionalTextController.text.isEmpty) {
        return 'Enter replacement text.';
      }
      for (final condition in _localMapping.bracketConditions) {
        if (_localMapping.textType != kConditionalValueExportTextType &&
            condition.sourceField.trim().isEmpty) {
          return 'Choose a controlling field for every bracket condition.';
        }
        if (condition.comparisonValue.trim().isEmpty) {
          return 'Enter a comparison value for every bracket condition.';
        }
        if (_localMapping.textType != kConditionalValueExportTextType &&
            condition.sourceField.trim().toLowerCase() ==
                target.toLowerCase()) {
          return 'A conditional field cannot depend on itself.';
        }
      }
    }
    return '';
  }

  String _standardTextType(String value) =>
      {
        'normal',
        'encoded',
        'coordinates',
        kConditionalBracketExportTextType,
        kConditionalFieldExportTextType,
        kConditionalValueExportTextType,
      }.contains(value)
      ? value
      : 'normal';

  String _listSeparatorOption(String value) {
    if (value.startsWith('custom:')) return 'custom';
    return _isListFormatOption(value) ? value : 'pipe';
  }

  bool _isListFormatOption(String value) =>
      {
        'pipe',
        'comma',
        'semicolon',
        'slash',
        'newline',
        'bullet',
      }.contains(value) ||
      value.startsWith('custom:');

  String? _exactSourceField(String expression) {
    final match = RegExp(r'^\s*\[([^\]]+)\]\s*$').firstMatch(expression);
    return match?.group(1)?.trim();
  }
}

class _ConcatenatedExpressionComposer extends StatefulWidget {
  const _ConcatenatedExpressionComposer({
    required this.expression,
    required this.fieldGroups,
    required this.onChanged,
  });

  final String expression;
  final Map<String, List<String>> fieldGroups;
  final ValueChanged<String> onChanged;

  @override
  State<_ConcatenatedExpressionComposer> createState() =>
      _ConcatenatedExpressionComposerState();
}

class _ConcatenatedExpressionComposerState
    extends State<_ConcatenatedExpressionComposer> {
  late List<ExportExpressionSegment> _segments;
  late List<int> _segmentIds;
  int _nextSegmentId = 0;

  @override
  void initState() {
    super.initState();
    _segments = parseExportExpression(widget.expression);
    _segmentIds = List.generate(_segments.length, (_) => _nextSegmentId++);
  }

  @override
  void didUpdateWidget(covariant _ConcatenatedExpressionComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expression != oldWidget.expression &&
        widget.expression != serializeExportExpression(_segments)) {
      _segments = parseExportExpression(widget.expression);
      _segmentIds = List.generate(_segments.length, (_) => _nextSegmentId++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Combined value', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        const Text(
          'Fields and text are emitted left to right. Add as many segments as needed.',
        ),
        const SizedBox(height: 8),
        if (_segments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Add a source field to begin.'),
          ),
        ..._segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          final segmentId = _segmentIds[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Material(
              key: ValueKey('combined-segment-$segmentId'),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      segment.isField ? Icons.data_object : Icons.text_fields,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: segment.isField
                          ? Text(segment.value)
                          : TextFormField(
                              key: ValueKey('combined-text-$segmentId'),
                              initialValue: segment.value,
                              decoration: const InputDecoration(
                                labelText: 'Text or separator',
                                isDense: true,
                              ),
                              onChanged: (value) => _setText(index, value),
                            ),
                    ),
                    IconButton(
                      tooltip: 'Move segment up',
                      onPressed: index == 0 ? null : () => _move(index, -1),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      tooltip: 'Move segment down',
                      onPressed: index == _segments.length - 1
                          ? null
                          : () => _move(index, 1),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    IconButton(
                      tooltip: 'Remove segment',
                      onPressed: () => _remove(index),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _addField,
              icon: const Icon(Icons.add),
              label: const Text('Add field'),
            ),
            OutlinedButton.icon(
              onPressed: _addText,
              icon: const Icon(Icons.add),
              label: const Text('Add text'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Expression: ${serializeExportExpression(_segments)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _notify() => widget.onChanged(serializeExportExpression(_segments));

  Future<void> _addField() async {
    final field = await _showGroupedFieldPicker(
      context,
      title: 'Add source field',
      groups: widget.fieldGroups,
    );
    if (field == null || !mounted) return;
    setState(() {
      _segments.add(ExportExpressionSegment.field(field));
      _segmentIds.add(_nextSegmentId++);
    });
    _notify();
  }

  void _addText() {
    setState(() {
      _segments.add(const ExportExpressionSegment.text(''));
      _segmentIds.add(_nextSegmentId++);
    });
  }

  void _remove(int index) {
    setState(() {
      _segments.removeAt(index);
      _segmentIds.removeAt(index);
    });
    _notify();
  }

  void _move(int index, int offset) {
    setState(() {
      final segment = _segments.removeAt(index);
      final segmentId = _segmentIds.removeAt(index);
      _segments.insert(index + offset, segment);
      _segmentIds.insert(index + offset, segmentId);
    });
    _notify();
  }

  void _setText(int index, String value) {
    _segments[index] = ExportExpressionSegment.text(value);
    _notify();
  }
}

/// Edits the comparisons that control conditional brackets around a value.
class _ConditionalBracketControls extends StatelessWidget {
  const _ConditionalBracketControls({
    required this.fieldGroups,
    required this.targetField,
    required this.compareTargetValue,
    required this.conditions,
    required this.mode,
    required this.onChanged,
  });

  final Map<String, List<String>> fieldGroups;
  final String? targetField;
  final bool compareTargetValue;
  final List<ConditionalBracketCondition> conditions;
  final ConditionalMatchMode mode;
  final void Function(
    List<ConditionalBracketCondition> conditions,
    ConditionalMatchMode mode,
  )
  onChanged;

  @override
  Widget build(BuildContext context) {
    final sourceGroups = _withoutField(fieldGroups, targetField);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          compareTargetValue ? 'Value conditions' : 'Field conditions',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        const Text(
          'Compare raw stored values. Blank controlling values never match.',
        ),
        DropdownButtonFormField<ConditionalMatchMode>(
          key: ValueKey('bracket-mode-$mode'),
          initialValue: mode,
          decoration: const InputDecoration(labelText: 'Match logic'),
          items: const [
            DropdownMenuItem(
              value: ConditionalMatchMode.any,
              child: Text('Any condition (OR)'),
            ),
            DropdownMenuItem(
              value: ConditionalMatchMode.all,
              child: Text('All conditions (AND)'),
            ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(conditions, value);
          },
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < conditions.length; index++)
          _ConditionRow(
            key: ValueKey('bracket-condition-$index'),
            index: index,
            condition: conditions[index],
            fieldGroups: sourceGroups,
            targetField: targetField,
            showSourceField: !compareTargetValue,
            onChanged: (next) {
              final updated = List<ConditionalBracketCondition>.from(
                conditions,
              );
              updated[index] = compareTargetValue && targetField != null
                  ? next.copyWith(sourceField: targetField)
                  : next;
              onChanged(updated, mode);
            },
            onRemove: conditions.length <= 1
                ? null
                : () {
                    final updated = List<ConditionalBracketCondition>.from(
                      conditions,
                    )..removeAt(index);
                    onChanged(updated, mode);
                  },
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => onChanged([
              ...conditions,
              const ConditionalBracketCondition(
                sourceField: '',
                operator: ConditionalComparisonOperator.equals,
                comparisonValue: '',
              ),
            ], mode),
            icon: const Icon(Icons.add),
            label: const Text('Add condition'),
          ),
        ),
      ],
    );
  }
}

class _ConditionRow extends StatefulWidget {
  const _ConditionRow({
    super.key,
    required this.index,
    required this.condition,
    required this.fieldGroups,
    required this.targetField,
    required this.showSourceField,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final ConditionalBracketCondition condition;
  final Map<String, List<String>> fieldGroups;
  final String? targetField;
  final bool showSourceField;
  final ValueChanged<ConditionalBracketCondition> onChanged;
  final VoidCallback? onRemove;

  @override
  State<_ConditionRow> createState() => _ConditionRowState();
}

class _ConditionRowState extends State<_ConditionRow> {
  late final TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(
      text: widget.condition.comparisonValue,
    );
  }

  @override
  void didUpdateWidget(covariant _ConditionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_valueController.text != widget.condition.comparisonValue) {
      _valueController.value = TextEditingValue(
        text: widget.condition.comparisonValue,
        selection: TextSelection.collapsed(
          offset: widget.condition.comparisonValue.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final condition = widget.condition;
    final selected = condition.sourceField.trim().isEmpty
        ? null
        : condition.sourceField;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (widget.showSourceField)
            SizedBox(
              width: 240,
              child: InlineGroupedFieldPicker(
                key: ValueKey('condition-field-${condition.sourceField}'),
                value: selected,
                groups: _fieldGroupsWithValue(widget.fieldGroups, selected),
                decoration: const InputDecoration(
                  labelText: 'Controlling field',
                ),
                onChanged: (value) {
                  widget.onChanged(
                    conditionalBracketConditionForSource(
                      condition,
                      sourceField: value,
                      targetField: widget.targetField,
                    ),
                  );
                },
              ),
            ),
          DropdownButton<ConditionalComparisonOperator>(
            value: condition.operator,
            items: const [
              DropdownMenuItem(
                value: ConditionalComparisonOperator.equals,
                child: Text('Equals'),
              ),
              DropdownMenuItem(
                value: ConditionalComparisonOperator.notEquals,
                child: Text('Does not equal'),
              ),
              DropdownMenuItem(
                value: ConditionalComparisonOperator.contains,
                child: Text('Contains'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.onChanged(condition.copyWith(operator: value));
              }
            },
          ),
          SizedBox(
            width: 180,
            child: TextFormField(
              key: ValueKey('condition-value-${widget.index}'),
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'Value'),
              onChanged: (value) =>
                  widget.onChanged(condition.copyWith(comparisonValue: value)),
            ),
          ),
          IconButton(
            tooltip: 'Remove condition',
            onPressed: widget.onRemove,
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}

class _IndexedStyleField extends StatelessWidget {
  const _IndexedStyleField({required this.value, required this.onChanged});

  final IndexedHeaderStyle value;
  final ValueChanged<IndexedHeaderStyle?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IndexedHeaderStyle>(
      key: ValueKey('indexed-style-$value'),
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Indexed column names'),
      items: const [
        DropdownMenuItem(
          value: IndexedHeaderStyle.underscore,
          child: Text('Underscore: field_1'),
        ),
        DropdownMenuItem(
          value: IndexedHeaderStyle.compact,
          child: Text('Compact: field1'),
        ),
        DropdownMenuItem(
          value: IndexedHeaderStyle.brackets,
          child: Text('Brackets: field[1]'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _MappingOutputExample extends StatelessWidget {
  const _MappingOutputExample({
    required this.mappingKind,
    required this.sourceExpression,
    required this.headerOverride,
    required this.namespace,
    required this.nestedFields,
    required this.listMode,
    required this.nestedMode,
    required this.indexedHeaderStyle,
    required this.headerFormat,
  });

  final String mappingKind;
  final String sourceExpression;
  final String headerOverride;
  final String namespace;
  final List<String> nestedFields;
  final ListExportMode listMode;
  final NestedExportMode nestedMode;
  final IndexedHeaderStyle indexedHeaderStyle;
  final ExportHeaderFormat headerFormat;

  @override
  Widget build(BuildContext context) {
    final headers = _headers();
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Output example',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            if (headers.isEmpty)
              const Text('Complete the mapping to see its output shape.')
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: headers
                    .map((header) => Chip(label: Text(header)))
                    .toList(),
              ),
            if (mappingKind == 'nested' &&
                nestedMode == NestedExportMode.expandRows)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Each child record creates another export row.'),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _headers() {
    final sourceKey = RegExp(
      r'^\s*\[([^\]]+)\]\s*$',
    ).firstMatch(sourceExpression)?.group(1);
    final source = headerFormat == ExportHeaderFormat.fieldName
        ? sourceKey?.split('::').last
        : sourceKey;
    final base = headerOverride.trim().isNotEmpty
        ? headerOverride.trim()
        : mappingKind == 'nested'
        ? namespace.trim()
        : source ?? '';
    if (base.isEmpty) return const [];
    if (mappingKind == 'scalar' || mappingKind == 'combined') return [base];
    if (mappingKind == 'list') {
      if (listMode == ListExportMode.concatenate) return [base];
      return List.generate(3, (index) => _indexed(base, index + 1));
    }
    if (nestedFields.isEmpty) return const [];
    if (nestedMode == NestedExportMode.concatenate) return [base];
    if (nestedMode == NestedExportMode.expandRows) {
      return nestedFields
          .map((field) => '${base}_${_nestedFieldName(field)}')
          .toList();
    }
    return [
      for (var index = 1; index <= 2; index++)
        for (final field in nestedFields)
          '${_indexed(base, index)}_${_nestedFieldName(field)}',
    ];
  }

  String _nestedFieldName(String field) =>
      headerFormat == ExportHeaderFormat.fieldName
      ? field
      : '${namespace.trim()}::$field';

  String _indexed(String base, int index) => switch (indexedHeaderStyle) {
    IndexedHeaderStyle.underscore => '${base}_$index',
    IndexedHeaderStyle.compact => '$base$index',
    IndexedHeaderStyle.brackets => '$base[$index]',
  };
}

class _MappingCustomizerDialog extends StatelessWidget {
  const _MappingCustomizerDialog({
    required this.mapping,
    required this.recordType,
    required this.specimenRecordType,
    required this.headerFormat,
    required this.allowExpandRows,
    required this.onSave,
    this.initialMappingKind,
  });

  final ExportFieldMapping mapping;
  final RecordType recordType;
  final SpecimenRecordType specimenRecordType;
  final ExportHeaderFormat headerFormat;
  final bool allowExpandRows;
  final ValueChanged<ExportFieldMapping> onSave;
  final String? initialMappingKind;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        mapping.isNested
            ? 'Customize Nested Mapping'
            : 'Customize Field Mapping',
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: _MappingCustomizerForm(
            mapping: mapping,
            recordType: recordType,
            specimenRecordType: specimenRecordType,
            headerFormat: headerFormat,
            allowExpandRows: allowExpandRows,
            onSave: (updated) {
              onSave(updated);
              Navigator.pop(context);
            },
            onCancel: () => Navigator.pop(context),
            initialMappingKind: initialMappingKind,
          ),
        ),
      ),
    );
  }
}

class _MappingCustomizerBottomSheet extends StatelessWidget {
  const _MappingCustomizerBottomSheet({
    required this.mapping,
    required this.recordType,
    required this.specimenRecordType,
    required this.headerFormat,
    required this.allowExpandRows,
    required this.onSave,
    this.initialMappingKind,
  });

  final ExportFieldMapping mapping;
  final RecordType recordType;
  final SpecimenRecordType specimenRecordType;
  final ExportHeaderFormat headerFormat;
  final bool allowExpandRows;
  final ValueChanged<ExportFieldMapping> onSave;
  final String? initialMappingKind;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        mediaQuery.viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              mapping.isNested
                  ? 'Customize Nested Mapping'
                  : 'Customize Field Mapping',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _MappingCustomizerForm(
              mapping: mapping,
              recordType: recordType,
              specimenRecordType: specimenRecordType,
              headerFormat: headerFormat,
              allowExpandRows: allowExpandRows,
              onSave: (updated) {
                onSave(updated);
                Navigator.pop(context);
              },
              onCancel: () => Navigator.pop(context),
              initialMappingKind: initialMappingKind,
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewTableDialog extends StatefulWidget {
  const PreviewTableDialog({
    super.key,
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<List<String>> rows;

  @override
  State<PreviewTableDialog> createState() => _PreviewTableDialogState();
}

class _PreviewTableDialogState extends State<PreviewTableDialog> {
  late final ScrollController _verticalController;
  late final ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewRows = widget.rows.take(50).toList();
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.table_chart_outlined),
          const SizedBox(width: 8),
          const Text('Export Preview'),
          const Spacer(),
          Text(
            'Showing ${previewRows.length} of ${widget.rows.length} records',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: mediaQuery.size.width * 0.9,
        height: mediaQuery.size.height * 0.75,
        child: Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              notificationPredicate: (notif) => notif.depth == 1,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    theme.colorScheme.surfaceContainerHigh,
                  ),
                  columns: widget.headers
                      .map(
                        (header) => DataColumn(
                          label: Text(
                            header,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                  rows: previewRows
                      .map(
                        (row) => DataRow(
                          cells: List.generate(
                            widget.headers.length,
                            (index) => DataCell(
                              Text(index < row.length ? row[index] : ''),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
