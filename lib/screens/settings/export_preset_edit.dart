import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/export.dart';

const Map<SpecimenRecordType, String> TaxonGroupDropdownMap = {
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
  final Map<String, String> initialPreset;

  @override
  ExportPresetEditFormState createState() => ExportPresetEditFormState();
}

class ExportPresetEditFormState extends ConsumerState<ExportPresetEditForm> {
  late Map<String, String> _currentPreset;
  SpecimenRecordType _selectedTaxon = SpecimenRecordType.allTaxa;

  @override
  void initState() {
    super.initState();
    _currentPreset = Map.from(widget.initialPreset);
  }

  @override
  void didUpdateWidget(ExportPresetEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.presetName != widget.presetName) {
      setState(() {
        _currentPreset = Map.from(widget.initialPreset);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _getAllGroups();
    final groupKeys = groups.keys.toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Edit ${widget.presetName}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const CommonLineDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Taxon Group:'),
              DropdownButton<SpecimenRecordType>(
                value: _selectedTaxon,
                items: TaxonGroupDropdownMap.entries.map((entry) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Apply naming convention to selected:'),
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ...groupKeys.map((table) {
                List<String> columns = groups[table]!;
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
                      initiallyExpanded: false,
                      children: columns.map((col) {
                        final isSelected = _currentPreset.containsKey(col);
                        return ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (bool? val) {
                              setState(() {
                                if (val == true) {
                                  _currentPreset[col] = col;
                                } else {
                                  _currentPreset.remove(col);
                                }
                              });
                            },
                          ),
                          title: Text(col.split('::').last),
                          subtitle: isSelected
                              ? TextFormField(
                                  initialValue: _currentPreset[col],
                                  decoration: const InputDecoration(
                                    labelText: 'Custom Name',
                                    isDense: true,
                                  ),
                                  onChanged: (val) {
                                    _currentPreset[col] = val;
                                  },
                                )
                              : null,
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
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
    );
  }

  Map<String, List<String>> _getAllGroups() {
    Map<String, List<String>> groups = {
      'Collecting Record': collectingRecordExportList,
      'Site': siteExportList,
      'Collection Event': collEventExportList,
      'Specimen Part': [...partExportListDelimited, partExportSimple],
      'Media': allMediaExportList,
      'Narrative': narrativeExportList,
    };

    if (_selectedTaxon == SpecimenRecordType.allTaxa ||
        _selectedTaxon == SpecimenRecordType.generalMammals) {
      groups['Mammal Measurements'] = mammalMeasurementExportList;
    }
    if (_selectedTaxon == SpecimenRecordType.allTaxa ||
        _selectedTaxon == SpecimenRecordType.bats) {
      groups['Bat Measurements'] = batMeasurementExportList;
    }
    if (_selectedTaxon == SpecimenRecordType.allTaxa ||
        _selectedTaxon == SpecimenRecordType.birds) {
      groups['Avian Measurements'] = avianMeasurementExportList;
    }
    if (_selectedTaxon == SpecimenRecordType.allTaxa ||
        _selectedTaxon == SpecimenRecordType.herpetofauna) {
      groups['Herpetofauna Measurements'] = herpMeasurementExportList;
    }

    return groups;
  }

  void _applyNamingConvention(String type) {
    setState(() {
      for (final key in _currentPreset.keys) {
        if (type == 'table::fieldName') {
          _currentPreset[key] = key;
        } else if (type == 'fieldName') {
          _currentPreset[key] = key.split('::').last;
        }
      }
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
}
