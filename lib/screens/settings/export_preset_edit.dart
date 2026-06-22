import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/screens/settings/export_presets.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/screens/settings/components/combined_field_dialog.dart';

const Map<SpecimenRecordType, String> taxonGroupDropdownMap = {
  SpecimenRecordType.allTaxa: 'All taxa',
  SpecimenRecordType.birds: 'Birds',
  SpecimenRecordType.bats: 'Bats',
  SpecimenRecordType.generalMammals: 'General mammals',
  SpecimenRecordType.herpetofauna: 'Herpetofauna',
};

class ExportPresetEditForm extends ConsumerStatefulWidget {
  const ExportPresetEditForm({
    super.key,
    required this.presetName,
    required this.initialPreset,
  });

  final String presetName;
  final ExportPresetModel initialPreset;

  @override
  ExportPresetEditFormState createState() => ExportPresetEditFormState();
}

class ExportPresetEditFormState extends ConsumerState<ExportPresetEditForm> {
  late ExportPresetModel _currentPreset;
  SpecimenRecordType _selectedTaxon = SpecimenRecordType.allTaxa;

  @override
  void initState() {
    super.initState();
    _currentPreset = ExportPresetModel(
      fields: Map.from(widget.initialPreset.fields),
      combinedFields: List.from(widget.initialPreset.combinedFields),
    );
  }

  @override
  void didUpdateWidget(ExportPresetEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.presetName != widget.presetName) {
      setState(() {
        _currentPreset = ExportPresetModel(
          fields: Map.from(widget.initialPreset.fields),
          combinedFields: List.from(widget.initialPreset.combinedFields),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _getAllGroups(ref);
    final groupKeys = groups.keys.toList();

    return FormCard(
      title: 'Edit ${widget.presetName}',
      infoContent: const ExportPresetInfoContent(),
      isExpanded: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Taxon Group:',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownButton<SpecimenRecordType>(
                  value: _selectedTaxon,
                  items: taxonGroupDropdownMap.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedTaxon = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Apply naming convention:',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownButton<String>(
                  value: 'table::fieldName',
                  items: const [
                    DropdownMenuItem(
                      value: 'table::fieldName',
                      child: Text('table::fieldName'),
                    ),
                    DropdownMenuItem(
                      value: 'fieldName',
                      child: Text('fieldName'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      _applyNamingConvention(val);
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Fields',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.reorder),
                      tooltip: 'Reorder Fields',
                      onPressed: _showReorderDialog,
                    ),
                    TextButton(
                      onPressed: _selectAll,
                      child: const Text('Select All'),
                    ),
                    TextButton(
                      onPressed: _deselectAll,
                      child: const Text('Clear All'),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ...groupKeys.map((table) {
                  List<String> columns = groups[table]!;
                  final selectedCount = columns
                      .where((col) => _currentPreset.fields.containsKey(col))
                      .length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(16.0),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.8),
                      child: ExpansionTile(
                        shape: const Border(),
                        title: Text(
                          table.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$selectedCount / ${columns.length} selected',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        initiallyExpanded: false,
                        children: columns.map((col) {
                          final isSelected =
                              _currentPreset.fields.containsKey(col);
                          return ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (bool? val) {
                                setState(() {
                                  if (val == true) {
                                    _currentPreset.fields[col] = col;
                                  } else {
                                    _currentPreset.fields.remove(col);
                                  }
                                });
                              },
                            ),
                            title: Text(col.split('::').last),
                            subtitle: isSelected
                                ? TextFormField(
                                    initialValue: _currentPreset.fields[col],
                                    decoration: const InputDecoration(
                                      labelText: 'Custom Name',
                                      isDense: true,
                                    ),
                                    onChanged: (val) {
                                      _currentPreset.fields[col] = val;
                                    },
                                  )
                                : null,
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.8),
                    child: ExpansionTile(
                      shape: const Border(),
                      title: const Text(
                        'COMBINED FIELDS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      initiallyExpanded: true,
                      children: [
                        ..._currentPreset.combinedFields.map((field) {
                          return ListTile(
                            title: Text(field.fieldId),
                            subtitle: Text(field.fields.join(' ')),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final newField =
                                        await showCombinedFieldDialog(
                                            context, field);
                                    if (newField != null) {
                                      setState(() {
                                        final index = _currentPreset
                                            .combinedFields
                                            .indexOf(field);
                                        _currentPreset.combinedFields[index] =
                                            newField;
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _currentPreset.combinedFields
                                          .remove(field);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SecondaryButton(
                            text: 'Add Combined Field',
                            onPressed: () async {
                              final field =
                                  await showCombinedFieldDialog(context);
                              if (field != null) {
                                setState(() {
                                  _currentPreset.combinedFields.add(field);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Save',
            icon: Icons.save,
            onPressed: _save,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Map<String, List<String>> _getAllGroups(WidgetRef ref) {
    final db = ref.read(databaseProvider);
    Map<String, List<String>> groups = {};
    for (var table in db.allTables) {
      final tableName = table.actualTableName;
      groups[tableName] =
          table.$columns.map((c) => '$tableName::${c.name}').toList();
    }
    return groups;
  }

  void _applyNamingConvention(String type) {
    setState(() {
      for (final key in _currentPreset.fields.keys) {
        if (type == 'table::fieldName') {
          _currentPreset.fields[key] = key;
        } else if (type == 'fieldName') {
          _currentPreset.fields[key] = key.split('::').last;
        }
      }
    });
  }

  void _selectAll() {
    setState(() {
      final groups = _getAllGroups(ref);
      for (final table in groups.keys) {
        for (final col in groups[table]!) {
          _currentPreset.fields[col] = col.split('::').last;
        }
      }
    });
  }

  void _deselectAll() {
    setState(() {
      _currentPreset.fields.clear();
    });
  }

  void _save() async {
    await ref.read(exportPresetNotifierProvider.notifier).savePreset(
          widget.presetName,
          _currentPreset,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preset saved')),
      );
    }
  }

  Future<void> _showReorderDialog() async {
    final entries = _currentPreset.fields.entries.toList();
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fields selected to reorder.')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Reorder Fields'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.sizeOf(context).height * 0.6,
                child: ReorderableListView(
                  onReorderItem: (oldIndex, newIndex) {
                    setStateDialog(() {
                      final item = entries.removeAt(oldIndex);
                      entries.insert(newIndex, item);
                    });
                  },
                  children: entries.map((e) {
                    return ListTile(
                      key: ValueKey(e.key),
                      title: Text(e.value),
                      subtitle: Text(e.key),
                      trailing: const Icon(Icons.drag_handle),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    setState(() {
      _currentPreset.fields.clear();
      _currentPreset.fields.addEntries(entries);
    });
  }
}
