import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void _addStandard(String field) {
    _update(mappings: [
      ..._preset.mappings,
      ExportFieldMapping(expression: '[$field]'),
    ]);
  }

  void _removeStandard(String field) {
    final updated = List<ExportFieldMapping>.from(_preset.mappings)
      ..removeWhere((m) => !m.isNested && m.expression == '[$field]');
    _update(mappings: updated);
  }

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
    final isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    if (isLargeScreen) {
      showDialog(
        context: context,
        builder: (context) => _MappingCustomizerDialog(
          mapping: mapping,
          onSave: (updated) => _replace(index, updated),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => _MappingCustomizerBottomSheet(
          mapping: mapping,
          onSave: (updated) => _replace(index, updated),
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
      onToggleField: (field, selected) {
        if (selected) {
          _addStandard(field);
        } else {
          _removeStandard(field);
        }
      },
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
                Text(
                  'Selected Mappings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Preview Export Table',
            onPressed: _showPreview,
          ),
          const SizedBox(width: 8),
        ],
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
    required this.onToggleField,
  });

  final RecordType recordType;
  final SpecimenRecordType specimenRecordType;
  final List<ExportFieldMapping> mappings;
  final void Function(String field, bool selected) onToggleField;

  @override
  ConsumerState<_AvailableFieldsSection> createState() =>
      _AvailableFieldsSectionState();
}

class _AvailableFieldsSectionState
    extends ConsumerState<_AvailableFieldsSection> {
  String _fieldDisplayOption = 'short';

  bool _isFieldSelected(String field) {
    return widget.mappings
        .any((m) => !m.isNested && m.expression == '[$field]');
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
                const Text(
                  'Insert Source Field',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _fieldDisplayOption,
                  isDense: true,
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
                          widget.onToggleField(field, val);
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
    final db = ref.read(databaseProvider);
    final Map<String, List<String>> groups = {};

    final Set<String> allowedTables;
    switch (widget.recordType) {
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
        if (widget.specimenRecordType == SpecimenRecordType.generalMammals ||
            widget.specimenRecordType == SpecimenRecordType.bats ||
            widget.specimenRecordType == SpecimenRecordType.allMammals) {
          allowedTables.remove('avianMeasurement');
          allowedTables.remove('herpMeasurement');
        } else if (widget.specimenRecordType == SpecimenRecordType.birds) {
          allowedTables.remove('mammalMeasurement');
          allowedTables.remove('herpMeasurement');
        } else if (widget.specimenRecordType ==
            SpecimenRecordType.herpetofauna) {
          allowedTables.remove('mammalMeasurement');
          allowedTables.remove('avianMeasurement');
        }
        break;
    }

    for (var table in db.allTables) {
      final tableName = table.actualTableName;
      if (allowedTables.contains(tableName)) {
        groups[tableName] =
            table.$columns.map((c) => '$tableName::${c.name}').toList();
      }
    }
    return groups;
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
      subtitle = 'Fields: ${mapping.nestedFields.join(', ')}';
      icon = Icons.account_tree_outlined;
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
}

class _MappingCustomizerForm extends StatefulWidget {
  const _MappingCustomizerForm({
    required this.mapping,
    required this.onSave,
    required this.onCancel,
  });

  final ExportFieldMapping mapping;
  final ValueChanged<ExportFieldMapping> onSave;
  final VoidCallback onCancel;

  @override
  State<_MappingCustomizerForm> createState() => _MappingCustomizerFormState();
}

class _MappingCustomizerFormState extends State<_MappingCustomizerForm> {
  late ExportFieldMapping _localMapping;
  late TextEditingController _expressionController;
  late TextEditingController _headerController;
  late TextEditingController _formatOptionController;
  late TextEditingController _customNullTextController;

  late TextEditingController _nestedNamespaceController;
  late TextEditingController _nestedFieldsController;
  late TextEditingController _fieldSepController;
  late TextEditingController _recordSepController;

  @override
  void initState() {
    super.initState();
    _localMapping = widget.mapping;

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
    _nestedFieldsController =
        TextEditingController(text: _localMapping.nestedFields.join(', '));
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
    _nestedFieldsController.dispose();
    _fieldSepController.dispose();
    _recordSepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _localMapping.isNested ? 'nested' : 'scalar',
          decoration: const InputDecoration(labelText: 'Mapping type'),
          items: const [
            DropdownMenuItem(value: 'scalar', child: Text('Standard Field')),
            DropdownMenuItem(value: 'nested', child: Text('Nested Record')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                if (value == 'nested') {
                  String? defaultNamespace;
                  final match = RegExp(r'\[([^\]?\s]+)')
                      .firstMatch(_localMapping.expression);
                  final key =
                      match?.group(1) ?? _localMapping.expression.trim();
                  if (key.contains('::')) {
                    defaultNamespace = key.split('::').first;
                  }
                  _localMapping = _localMapping.copyWith(
                    nestedNamespace: _localMapping.nestedNamespace ??
                        defaultNamespace ??
                        'specimen',
                  );
                } else {
                  _localMapping = ExportFieldMapping(
                    expression: _localMapping.expression,
                    headerOverride: _localMapping.headerOverride,
                    textType: _localMapping.textType,
                    formatOption: _localMapping.formatOption,
                    caseFormat: _localMapping.caseFormat,
                    nullFallbackOption: _localMapping.nullFallbackOption,
                    customNullFallbackText:
                        _localMapping.customNullFallbackText,
                    nestedNamespace: null,
                    nestedFields: _localMapping.nestedFields,
                    nestedMode: _localMapping.nestedMode,
                    fieldSeparator: _localMapping.fieldSeparator,
                    recordSeparator: _localMapping.recordSeparator,
                  );
                }
              });
            }
          },
        ),
        const SizedBox(height: 8),
        if (_localMapping.isNested)
          ..._buildNestedFields()
        else
          ..._buildStandardFields(),
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
              onPressed: _submit,
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    ExportFieldMapping finalMapping;
    if (_localMapping.isNested) {
      final fields = _nestedFieldsController.text
          .split(',')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty)
          .toList();
      finalMapping = _localMapping.copyWith(
        nestedNamespace: _nestedNamespaceController.text.trim(),
        nestedFields: fields,
        headerOverride: _headerController.text.trim(),
        clearHeaderOverride: _headerController.text.trim().isEmpty,
        fieldSeparator: _fieldSepController.text,
        recordSeparator: _recordSepController.text,
      );
    } else {
      finalMapping = _localMapping.copyWith(
        expression: _expressionController.text.trim(),
        headerOverride: _headerController.text.trim(),
        clearHeaderOverride: _headerController.text.trim().isEmpty,
        formatOption: _formatOptionController.text.trim(),
        customNullFallbackText: _customNullTextController.text.trim(),
      );
    }
    widget.onSave(finalMapping);
  }

  List<Widget> _buildStandardFields() {
    final textType = {'normal', 'encoded', 'list', 'coordinates'}
            .contains(_localMapping.textType)
        ? _localMapping.textType
        : 'normal';

    return [
      TextFormField(
        controller: _expressionController,
        decoration: const InputDecoration(
          labelText: 'Source expression',
          helperText: 'Use document placeholders, e.g. [specimen::catalogNum].',
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _headerController,
        decoration:
            const InputDecoration(labelText: 'Custom header (optional)'),
      ),
      const SizedBox(height: 8),
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
          if (value != null) {
            setState(() {
              _localMapping = _localMapping.copyWith(textType: value);
            });
          }
        },
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _formatOptionController,
        decoration: const InputDecoration(
          labelText: 'Format option',
          helperText: 'Examples: enum, comma, dms, or custom_map:0=No,1=Yes.',
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        initialValue: _localMapping.nullFallbackOption,
        decoration:
            const InputDecoration(labelText: 'Empty content placeholder'),
        items: const [
          DropdownMenuItem(value: 'blank', child: Text('Blank')),
          DropdownMenuItem(value: 'custom', child: Text('Custom text')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _localMapping = _localMapping.copyWith(nullFallbackOption: value);
            });
          }
        },
      ),
      if (_localMapping.nullFallbackOption == 'custom') ...[
        const SizedBox(height: 8),
        TextFormField(
          controller: _customNullTextController,
          decoration: const InputDecoration(
            labelText: 'Custom null text',
            helperText: 'Text to use when field value is null/empty.',
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildNestedFields() {
    return [
      TextFormField(
        controller: _nestedNamespaceController,
        decoration:
            const InputDecoration(labelText: 'Related record namespace'),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _nestedFieldsController,
        decoration: const InputDecoration(
          labelText: 'Child fields (comma separated)',
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _headerController,
        decoration:
            const InputDecoration(labelText: 'Header prefix (optional)'),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<NestedExportMode>(
        initialValue: _localMapping.nestedMode,
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
          if (value != null) {
            setState(() {
              _localMapping = _localMapping.copyWith(nestedMode: value);
            });
          }
        },
      ),
      if (_localMapping.nestedMode == NestedExportMode.concatenate) ...[
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fieldSepController,
                decoration: const InputDecoration(labelText: 'Field separator'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _recordSepController,
                decoration:
                    const InputDecoration(labelText: 'Record separator'),
              ),
            ),
          ],
        ),
      ],
    ];
  }
}

class _MappingCustomizerDialog extends StatelessWidget {
  const _MappingCustomizerDialog({
    required this.mapping,
    required this.onSave,
  });

  final ExportFieldMapping mapping;
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
    required this.onSave,
  });

  final ExportFieldMapping mapping;
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
