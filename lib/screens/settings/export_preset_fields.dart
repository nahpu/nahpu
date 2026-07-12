import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/preset_record_exporter.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';

class ExportPresetFieldsScreen extends ConsumerStatefulWidget {
  const ExportPresetFieldsScreen({
    super.key,
    required this.preset,
  });

  final ExportPresetModel preset;

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

  void _applyStandardFields(Set<String> selectedFields) {
    final mappings = List<ExportFieldMapping>.from(_preset.mappings)
      ..removeWhere((mapping) {
        if (mapping.isNested) return false;
        final field = _directSourceField(mapping.expression);
        return field != null && !selectedFields.contains(field);
      });

    final mappedFields = mappings
        .where((mapping) => !mapping.isNested)
        .map((mapping) => _directSourceField(mapping.expression))
        .whereType<String>()
        .toSet();
    for (final field in selectedFields) {
      if (!mappedFields.contains(field)) {
        mappings.add(ExportFieldMapping(expression: '[$field]'));
      }
    }
    _update(mappings: mappings);
  }

  String? _directSourceField(String expression) {
    return RegExp(r'^\s*\[([^\]]+)\]\s*$')
        .firstMatch(expression)
        ?.group(1)
        ?.trim();
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
    final groups = _nestedFieldGroups(_availableFieldGroups(
      ref.read(databaseProvider),
      _preset.recordType,
      _preset.specimenRecordType,
    ));
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
      allowExpandRows: !_preset.mappings.any((mapping) =>
          mapping.isNested &&
          mapping.nestedMode == NestedExportMode.expandRows),
      onSave: (mapping) => _update(mappings: [..._preset.mappings, mapping]),
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

  void _update({
    List<ExportFieldMapping>? mappings,
  }) {
    setState(() {
      _preset = ExportPresetModel(
        recordType: _preset.recordType,
        specimenRecordType: _preset.specimenRecordType,
        headerFormat: _preset.headerFormat,
        mappings: mappings ?? _preset.mappings,
      );
    });
  }

  void _customizeMapping(int index) {
    final mapping = _preset.mappings[index];
    final allowExpandRows = !_preset.mappings.asMap().entries.any((entry) =>
        entry.key != index &&
        entry.value.isNested &&
        entry.value.nestedMode == NestedExportMode.expandRows);

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

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.sizeOf(context).width > 600;
    final scheme = Theme.of(context).colorScheme;

    final availableFieldsWidget = _AvailableFieldsSection(
      recordType: _preset.recordType,
      specimenRecordType: _preset.specimenRecordType,
      mappings: _preset.mappings,
      onApplyFields: _applyStandardFields,
    );

    final selectedFieldsWidget = Material(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: scheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected Mappings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _nestedFieldGroups(_availableFieldGroups(
                    ref.read(databaseProvider),
                    _preset.recordType,
                    _preset.specimenRecordType,
                  )).isEmpty
                      ? null
                      : _addNested,
                  icon: const Icon(Icons.account_tree_outlined),
                  label: const Text('Add nested'),
                ),
              ],
            ),
          ),
          const Divider(height: 1.0),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(12),
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
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final hasChanges =
              _preset.mappings.length != widget.preset.mappings.length ||
                  !_areMappingsEqual(_preset.mappings, widget.preset.mappings);
          if (!hasChanges) {
            Navigator.pop(context, widget.preset);
            return;
          }

          final action = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text(
                'You have modified mappings. Do you want to apply these changes? '
                'Remember to click Save on the preset screen to persist them.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'discard'),
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'cancel'),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'apply'),
                  child: const Text('Apply'),
                ),
              ],
            ),
          );

          if (action == 'discard' && context.mounted) {
            Navigator.pop(context, widget.preset);
          } else if (action == 'apply' && context.mounted) {
            Navigator.pop(context, _preset);
          }
        },
        child: isLargeScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: availableFieldsWidget,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
}

class _AvailableFieldsSection extends ConsumerStatefulWidget {
  const _AvailableFieldsSection({
    required this.recordType,
    required this.specimenRecordType,
    required this.mappings,
    required this.onApplyFields,
  });

  final RecordType recordType;
  final SpecimenRecordType specimenRecordType;
  final List<ExportFieldMapping> mappings;
  final ValueChanged<Set<String>> onApplyFields;

  @override
  ConsumerState<_AvailableFieldsSection> createState() =>
      _AvailableFieldsSectionState();
}

class _AvailableFieldsSectionState
    extends ConsumerState<_AvailableFieldsSection> {
  String _fieldDisplayOption = 'short';
  late Set<String> _selectedFields;

  @override
  void initState() {
    super.initState();
    _selectedFields = _selectedSourceFields(widget.mappings);
  }

  @override
  void didUpdateWidget(covariant _AvailableFieldsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mappings != widget.mappings) {
      _selectedFields = _selectedSourceFields(widget.mappings);
    }
  }

  bool _isFieldSelected(String field) {
    return _selectedFields.contains(field);
  }

  Set<String> _selectedSourceFields(List<ExportFieldMapping> mappings) {
    return mappings
        .where((mapping) => !mapping.isNested)
        .map((mapping) => RegExp(r'^\s*\[([^\]]+)\]\s*$')
            .firstMatch(mapping.expression)
            ?.group(1)
            ?.trim())
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
        side: BorderSide(
          color: scheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Insert Source Field',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: DropdownButton<String>(
                    value: _fieldDisplayOption,
                    isDense: true,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: 'full',
                        child: Text(
                          'Table::Field',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'short',
                        child: Text(
                          'Field Only',
                          style: TextStyle(fontSize: 12.0),
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
                    table.toUpperCase(),
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
                          setState(() {
                            if (val) {
                              _selectedFields.add(field);
                            } else {
                              _selectedFields.remove(field);
                            }
                          });
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => widget.onApplyFields(_selectedFields),
                icon: const Icon(Icons.check),
                label: const Text('Apply source fields'),
              ),
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
        'site',
        'coordinate',
        'weather',
        'mammalMeasurement',
        'avianMeasurement',
        'herpMeasurement',
        'specimenPart',
      };
      if (specimenRecordType == SpecimenRecordType.generalMammals ||
          specimenRecordType == SpecimenRecordType.bats ||
          specimenRecordType == SpecimenRecordType.allMammals) {
        allowedTables.remove('avianMeasurement');
        allowedTables.remove('herpMeasurement');
      } else if (specimenRecordType == SpecimenRecordType.birds) {
        allowedTables.remove('mammalMeasurement');
        allowedTables.remove('herpMeasurement');
      } else if (specimenRecordType == SpecimenRecordType.herpetofauna) {
        allowedTables.remove('mammalMeasurement');
        allowedTables.remove('avianMeasurement');
      }
      break;
  }

  for (var table in db.allTables) {
    final tableName = table.actualTableName;
    if (allowedTables.contains(tableName)) {
      groups[tableName] =
          table.$columns.map<String>((c) => '$tableName::${c.name}').toList();
    }
  }
  return groups;
}

Map<String, List<String>> _nestedFieldGroups(
  Map<String, List<String>> groups,
) {
  // Nested mappings retain the same table choices as the source-field picker.
  // Some sources are repeated in only certain record types, but preserving the
  // full set keeps existing and advanced mappings editable.
  return Map<String, List<String>>.from(groups);
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
      subtitle = '${_nestedModeLabel(mapping.nestedMode)} · '
          '${mapping.nestedFields.join(', ')}';
      icon = Icons.account_tree_outlined;
    } else if (mapping.textType == 'list') {
      title = 'List: ${mapping.expression}';
      subtitle = mapping.listMode == ListExportMode.spreadColumns
          ? 'Indexed columns · ${_indexedStyleLabel(mapping.indexedHeaderStyle)}'
          : 'One column · ${mapping.formatOption} separator';
      icon = Icons.view_column_outlined;
    } else {
      title = 'Field: ${mapping.expression}';
      subtitle =
          'Format: ${mapping.textType} · Options: ${mapping.formatOption}';
      icon = Icons.grid_on_outlined;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
  });

  final ExportFieldMapping mapping;
  final RecordType recordType;
  final SpecimenRecordType specimenRecordType;
  final ExportHeaderFormat headerFormat;
  final bool allowExpandRows;
  final ValueChanged<ExportFieldMapping> onSave;
  final VoidCallback onCancel;

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
  late TextEditingController _nestedNamespaceController;
  late TextEditingController _fieldSepController;
  late TextEditingController _recordSepController;
  late List<String> _nestedFields;

  @override
  void initState() {
    super.initState();
    _localMapping = widget.mapping;
    _mappingKind = _localMapping.isNested
        ? 'nested'
        : _localMapping.textType == 'list'
            ? 'list'
            : 'scalar';

    _expressionController =
        TextEditingController(text: _localMapping.expression);
    _headerController =
        TextEditingController(text: _localMapping.headerOverride ?? '');
    _formatOptionController =
        TextEditingController(text: _localMapping.formatOption);
    _customNullTextController =
        TextEditingController(text: _localMapping.customNullFallbackText);

    _nestedNamespaceController =
        TextEditingController(text: _localMapping.nestedNamespace ?? '');
    _nestedFields = List<String>.from(_localMapping.nestedFields);
    _fieldSepController =
        TextEditingController(text: _localMapping.fieldSeparator);
    _recordSepController =
        TextEditingController(text: _localMapping.recordSeparator);
  }

  @override
  void dispose() {
    _expressionController.dispose();
    _headerController.dispose();
    _formatOptionController.dispose();
    _customNullTextController.dispose();
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
    final allFields = groups.values.expand((fields) => fields).toList();
    final selectedSource = _exactSourceField(_expressionController.text);
    if (selectedSource != null && !allFields.contains(selectedSource)) {
      allFields.add(selectedSource);
    }
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
            DropdownMenuItem(value: 'list', child: Text('List field')),
            DropdownMenuItem(value: 'nested', child: Text('Nested records')),
          ],
          onChanged: (value) => value == null ? null : _setMappingKind(value),
        ),
        const SizedBox(height: 16),
        if (_mappingKind != 'nested') ...[
          DropdownButtonFormField<String>(
            key: ValueKey('source-$selectedSource'),
            initialValue:
                selectedSource != null && allFields.contains(selectedSource)
                    ? selectedSource
                    : null,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Source field',
              helperText: 'Choose the NAHPU field that supplies this column.',
            ),
            items: allFields
                .map((field) => DropdownMenuItem(
                      value: field,
                      child: Text(field, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _expressionController.text = '[$value]');
              }
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
                      value: 'slash', child: Text('Slash (A / B)')),
                  DropdownMenuItem(value: 'newline', child: Text('New line')),
                  DropdownMenuItem(value: 'bullet', child: Text('Bulleted')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    final option = value == 'custom' ? 'custom:' : value;
                    _localMapping =
                        _localMapping.copyWith(formatOption: option);
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
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _localMapping = _localMapping.copyWith(textType: value);
                  });
                }
              },
            ),
          ],
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
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ))
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
          Text('Selected child fields',
              style: Theme.of(context).textTheme.titleSmall),
          if (_nestedFields.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Select at least one child field below.'),
            )
          else
            ..._nestedFields.asMap().entries.map((entry) => ListTile(
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
                )),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Choose child fields'),
            children: availableNestedFields
                .map((field) => CheckboxListTile(
                      dense: true,
                      value: _nestedFields.contains(field),
                      title: Text(field),
                      onChanged: (selected) =>
                          _toggleNestedField(field, selected ?? false),
                    ))
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
                  subtitle: Text(widget.allowExpandRows
                      ? 'Create one export row per child record.'
                      : 'Another mapping already expands export rows.'),
                  enabled: widget.allowExpandRows,
                ),
              ],
            ),
          ),
          if (_localMapping.nestedMode == NestedExportMode.concatenate) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fieldSepController,
                    onChanged: (_) => setState(() {}),
                    decoration:
                        const InputDecoration(labelText: 'Field separator'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _recordSepController,
                    onChanged: (_) => setState(() {}),
                    decoration:
                        const InputDecoration(labelText: 'Record separator'),
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
              if (_mappingKind == 'scalar') ...[
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
                decoration: const InputDecoration(
                  labelText: 'Empty value',
                ),
                items: const [
                  DropdownMenuItem(value: 'blank', child: Text('Blank')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom text')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _localMapping =
                          _localMapping.copyWith(nullFallbackOption: value);
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
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: canSave ? _submit : null,
              child: const Text('Save'),
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
        textType: _mappingKind == 'list' ? 'list' : _localMapping.textType,
        clearNestedNamespace: true,
        headerOverride: _headerController.text.trim(),
        clearHeaderOverride: _headerController.text.trim().isEmpty,
        formatOption: _formatOptionController.text.trim(),
        customNullFallbackText: _customNullTextController.text.trim(),
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
    if (_mappingKind == 'nested') {
      if (_nestedNamespaceController.text.trim().isEmpty) {
        return 'Choose a related-record group.';
      }
      if (_nestedFields.isEmpty) return 'Choose at least one child field.';
      if (_localMapping.nestedMode == NestedExportMode.concatenate &&
          (_fieldSepController.text.isEmpty ||
              _recordSepController.text.isEmpty)) {
        return 'Field and record separators cannot be empty.';
      }
      return '';
    }
    if (_expressionController.text.trim().isEmpty) {
      return 'Choose a source field.';
    }
    if (_mappingKind == 'list' &&
        _localMapping.listMode == ListExportMode.spreadColumns &&
        _exactSourceField(_expressionController.text) == null) {
      return 'Indexed lists require exactly one source field.';
    }
    return '';
  }

  String _standardTextType(String value) =>
      {'normal', 'encoded', 'coordinates'}.contains(value) ? value : 'normal';

  String _listSeparatorOption(String value) {
    if (value.startsWith('custom:')) return 'custom';
    return _isListFormatOption(value) ? value : 'pipe';
  }

  bool _isListFormatOption(String value) =>
      {'pipe', 'comma', 'semicolon', 'slash', 'newline', 'bullet'}
          .contains(value) ||
      value.startsWith('custom:');

  String? _exactSourceField(String expression) {
    final match = RegExp(r'^\s*\[([^\]]+)\]\s*$').firstMatch(expression);
    return match?.group(1)?.trim();
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
            Text('Output example',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            if (headers.isEmpty)
              const Text('Complete the mapping to see its output shape.')
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    headers.map((header) => Chip(label: Text(header))).toList(),
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
    final sourceKey =
        RegExp(r'^\s*\[([^\]]+)\]\s*$').firstMatch(sourceExpression)?.group(1);
    final source = headerFormat == ExportHeaderFormat.fieldName
        ? sourceKey?.split('::').last
        : sourceKey;
    final base = headerOverride.trim().isNotEmpty
        ? headerOverride.trim()
        : mappingKind == 'nested'
            ? namespace.trim()
            : source ?? '';
    if (base.isEmpty) return const [];
    if (mappingKind == 'scalar') return [base];
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
  });

  final ExportFieldMapping mapping;
  final RecordType recordType;
  final SpecimenRecordType specimenRecordType;
  final ExportHeaderFormat headerFormat;
  final bool allowExpandRows;
  final ValueChanged<ExportFieldMapping> onSave;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(mapping.isNested
          ? 'Customize Nested Mapping'
          : 'Customize Field Mapping'),
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
  });

  final ExportFieldMapping mapping;
  final RecordType recordType;
  final SpecimenRecordType specimenRecordType;
  final ExportHeaderFormat headerFormat;
  final bool allowExpandRows;
  final ValueChanged<ExportFieldMapping> onSave;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding:
          EdgeInsets.fromLTRB(16, 16, 16, mediaQuery.viewInsets.bottom + 16),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
  final List<Map<String, String>> rows;

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
                      .map((header) => DataColumn(
                            label: Text(
                              header,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                  rows: previewRows
                      .map((row) => DataRow(
                            cells: widget.headers
                                .map((header) =>
                                    DataCell(Text(row[header] ?? '')))
                                .toList(),
                          ))
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
