import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/components/columns.dart';
import 'package:nahpu/screens/exports/components/record_options.dart';
import 'package:nahpu/screens/exports/components/format_options.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/export_columns.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/export/site_writer.dart';
import 'package:nahpu/services/export/specimen_part_records.dart';
import 'package:nahpu/services/export/coll_event_writer.dart';
import 'package:nahpu/services/export/narrative_writer.dart';
import 'package:nahpu/services/export/record_writer.dart';
import 'package:nahpu/services/providers/settings.dart';

class ExportForm extends ConsumerStatefulWidget {
  const ExportForm({super.key});

  @override
  ExportFormState createState() => ExportFormState();
}

class ExportFormState extends ConsumerState<ExportForm> {
  FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  RecordType _recordType = RecordType.narrative;
  TaxonRecordType? _taxonRecordType;
  SpecimenRecordType _specimenRecordType = SpecimenRecordType.generalMammals;
  MammalRecordType _mammalRecordType = MammalRecordType.excludeBats;
  SpecimenExportFmt _specimenExportFmt = SpecimenExportFmt.standard;
  bool _concatenateMultiEntry = false;
  bool _useFieldNamesOnly = false;
  bool get _isCustomFields =>
      _specimenExportFmt == SpecimenExportFmt.selectFields &&
      _selectedPresetName == null;
  String _fileStem = 'export';
  Directory? _selectedDir;
  bool _hasSaved = false;
  late File _savePath;
  bool _isRunning = false;
  bool _inaccurateInBrackets = true;

  List<String> _availableColumns = [];
  List<String>? _selectedColumns;
  String? _selectedPresetName;
  ExportPresetModel? _selectedPresetMap;

  @override
  void initState() {
    super.initState();
    _updateAvailableColumns();
  }

  @override
  void dispose() {
    exportCtr.dispose();
    super.dispose();
  }

  void _updateAvailableColumns() {
    setState(() {
      _availableColumns = getAvailableExportColumns(
        recordType: _recordType,
        specimenRecordType: _specimenRecordType,
        specimenExportFmt: _specimenExportFmt,
      );
      // Reset selected columns when switching record types
      _selectedColumns = List.from(_availableColumns);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export records'),
      ),
      body: isLargeScreen ? _buildLargeScreenLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FileOperationPage(
            children: _buildFormChildren(isLargeScreen: true),
          ),
        ),
        if (_isCustomFields || _selectedPresetName != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(16.0),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.4),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _selectedPresetMap != null
                      ? PresetFieldViewer(preset: _selectedPresetMap!)
                      : ColumnSelectionList(
                          availableColumns: _availableColumns,
                          selectedColumns:
                              _selectedColumns ?? _availableColumns,
                          onSelectionChanged: (selected) {
                            setState(() {
                              _selectedColumns = selected;
                              _hasSaved = false;
                            });
                          },
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return FileOperationPage(
      children: _buildFormChildren(isLargeScreen: false),
    );
  }

  List<Widget> _buildFormChildren({required bool isLargeScreen}) {
    final presets = ref.watch(exportPresetNotifierProvider);
    return [
      FileFormatIcon(path: _matchFileIconPath()),
      const SizedBox(height: 8),
      presets.when(
        data: (data) {
          if (data.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String?>(
              initialValue: _selectedPresetName,
              decoration: const InputDecoration(
                labelText: 'Use Preset',
                helperText: 'Select an export preset to apply custom columns',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('None (Default)'),
                ),
                ...data.keys.map((preset) {
                  return DropdownMenuItem(
                    value: preset,
                    child: Text(preset),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedPresetName = val;
                  if (val != null) {
                    _selectedPresetMap = data[val];
                    if (_selectedPresetMap != null) {
                      _selectedColumns =
                          _selectedPresetMap!.fields.keys.toList();
                      _useFieldNamesOnly = false;
                      _specimenExportFmt = SpecimenExportFmt.selectFields;
                    }
                  } else {
                    _selectedPresetMap = null;
                    _selectedColumns = List.from(_availableColumns);
                  }
                  _hasSaved = false;
                });
              },
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (err, stack) => const SizedBox.shrink(),
      ),
      if (_selectedPresetName == null) ...[
        RecordOptionsCard(
          recordType: _recordType,
          taxonRecordType: _taxonRecordType,
          mammalRecordType: _mammalRecordType,
          inaccurateInBrackets: _inaccurateInBrackets,
          isMammalSpecimenRecord: _isMammalSpecimenRecord(),
          onRecordTypeChanged: (RecordType? value) {
            if (value != null) {
              setState(() {
                _recordType = value;
                _hasSaved = false;
                _updateAvailableColumns();
              });
            }
          },
          onTaxonRecordTypeChanged: (TaxonRecordType? value) {
            if (value != null) {
              setState(() {
                _taxonRecordType = value;
                _matchTaxonToRecordType();
                _hasSaved = false;
                _updateAvailableColumns();
              });
            }
          },
          onMammalRecordTypeChanged: (MammalRecordType? value) {
            if (value != null) {
              setState(() {
                _mammalRecordType = value;
                _matchTaxonToRecordType();
                _hasSaved = false;
                _updateAvailableColumns();
              });
            }
          },
          onInaccurateInBracketsChanged: (bool value) {
            setState(() {
              _inaccurateInBrackets = value;
              _hasSaved = false;
            });
          },
        ),
        const SizedBox(height: 16),
      ],
      FormatOptionsCard(
        recordType: _selectedPresetName != null
            ? RecordType.specimenRecord
            : _recordType,
        specimenExportFmt: _specimenExportFmt,
        concatenateMultiEntry: _concatenateMultiEntry,
        useFieldNamesOnly: _useFieldNamesOnly,
        isPreset: _selectedPresetName != null,
        onSpecimenExportFmtChanged: (SpecimenExportFmt? value) {
          if (value != null) {
            setState(() {
              _specimenExportFmt = value;
              _hasSaved = false;
              _updateAvailableColumns();
            });
          }
        },
        onConcatenateMultiEntryChanged: (bool value) {
          setState(() {
            _concatenateMultiEntry = value;
            _hasSaved = false;
          });
        },
        onSelectFields: !isLargeScreen && _selectedPresetName == null
            ? () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.8,
                      child: ColumnSelectionList(
                        availableColumns: _availableColumns,
                        selectedColumns: _selectedColumns ?? _availableColumns,
                        onSelectionChanged: (selected) {
                          setState(() {
                            _selectedColumns = selected;
                            _hasSaved = false;
                          });
                        },
                      ),
                    );
                  },
                );
              }
            : null,
        onUseFieldNamesOnlyChanged: (bool value) {
          setState(() {
            _useFieldNamesOnly = value;
            _hasSaved = false;
          });
        },
      ),
      if (_selectedPresetName != null && !isLargeScreen)
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SecondaryButton(
            text: 'View Preset Fields',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return FractionallySizedBox(
                    heightFactor: 0.8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PresetFieldViewer(preset: _selectedPresetMap!),
                    ),
                  );
                },
              );
            },
          ),
        ),
      const SizedBox(height: 16),
      FileSettingsCard(
        exportCtr: exportCtr,
        selectedDir: _selectedDir,
        onExportFmtChanged: (ExportFmt? value) {
          if (value != null) {
            setState(() {
              exportCtr.exportFmtCtr = value;
              _hasSaved = false;
            });
          }
        },
        onFileNameChanged: (String? value) {
          if (value != null) {
            setState(() {
              _fileStem = value;
              _hasSaved = false;
            });
          }
        },
        onSelectDir: () async {
          final path = await FilePickerServices().selectDir();
          if (path != null) {
            setState(() {
              _selectedDir = path;
            });
          }
        },
        onClearDir: () {
          setState(() {
            _selectedDir = null;
            _hasSaved = false;
          });
        },
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 20,
        children: [
          SaveSecondaryButton(hasSaved: _hasSaved),
          !_hasSaved
              ? ProgressButton(
                  label: 'Save',
                  isRunning: _isRunning,
                  icon: Icons.save_alt_outlined,
                  onPressed: !_isValid()
                      ? null
                      : () async {
                          setState(() {
                            _isRunning = true;
                          });
                          await _exportFile();
                          setState(() {
                            _isRunning = false;
                          });
                        },
                )
              : Builder(builder: (BuildContext context) {
                  return ShareButton(
                    onPressed: () async {
                      _shareFile(context);
                    },
                  );
                }),
        ],
      ),
    ];
  }

  String _matchFileIconPath() {
    switch (exportCtr.exportFmtCtr) {
      case ExportFmt.csv:
        return 'assets/icons/csv.svg';
      case ExportFmt.tsv:
        return 'assets/icons/tsv.svg';
      case ExportFmt.excel:
        return 'assets/icons/csv.svg'; // fallback if no excel.svg
      case ExportFmt.json:
        return 'assets/icons/json.svg'; // fallback
    }
  }

  bool _isValid() {
    bool isFieldValid = exportCtr.isValid;
    if (_recordType == RecordType.specimenRecord) {
      return isFieldValid && _taxonRecordType != null;
    }
    return isFieldValid;
  }

  bool _isMammalSpecimenRecord() {
    return _recordType == RecordType.specimenRecord &&
        _taxonRecordType == TaxonRecordType.mammals;
  }

  void _matchTaxonToRecordType() {
    switch (_taxonRecordType) {
      case TaxonRecordType.mammals:
        switch (_mammalRecordType) {
          case MammalRecordType.excludeBats:
            _specimenRecordType = SpecimenRecordType.generalMammals;
            break;
          case MammalRecordType.onlyBats:
            _specimenRecordType = SpecimenRecordType.bats;
            break;
          default:
            _specimenRecordType = SpecimenRecordType.allMammals;
            break;
        }
        break;
      case TaxonRecordType.birds:
        _specimenRecordType = SpecimenRecordType.birds;
        break;
      case TaxonRecordType.herps:
        _specimenRecordType = SpecimenRecordType.herpetofauna;
        break;
      default:
        break;
    }
  }

  Future<void> _exportFile() async {
    await _writeDelimited(exportCtr.exportFmtCtr);
  }

  Future<void> _writeDelimited(ExportFmt format) async {
    String ext;
    if (format == ExportFmt.excel) {
      ext = 'xlsx';
    } else if (format == ExportFmt.json) {
      ext = 'json';
    } else {
      ext = format.name;
    }
    try {
      _savePath = await AppIOServices(
        dir: _selectedDir,
        fileStem: _fileStem,
        ext: ext,
      ).getSavePath();
      await _matchRecordTypeToWriter(_savePath, format);
      setState(() {
        _hasSaved = true;
      });
      _showSavedPath();
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errors),
      ),
    );
  }

  void _showSavedPath() {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            systemPlatform == PlatformType.desktop
                ? 'File saved as $_savePath'
                : 'File saved!',
          ),
        ),
      );
    }
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      await FilePickerServices().shareFile(context, _savePath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  Future<void> _matchRecordTypeToWriter(File file, ExportFmt format) async {
    if (_selectedPresetName != null) {
      await SpecimenRecordWriter(
        ref: ref,
        recordType: SpecimenRecordType.allTaxa,
        isInaccurateInBrackets: _inaccurateInBrackets,
        isAllFields: false,
        concatenateMultiEntry: _concatenateMultiEntry,
        useFieldNamesOnly: _useFieldNamesOnly,
        selectedColumns: _selectedColumns,
        exportPreset: _selectedPresetMap,
      ).writeRecordDelimited(file, format);
      return;
    }

    switch (_recordType) {
      case RecordType.narrative:
        await NarrativeRecordWriter(
          ref: ref,
          useFieldNamesOnly: _useFieldNamesOnly,
          selectedColumns: _isCustomFields ? _selectedColumns : null,
        ).writeNarrativeDelimited(file, format);
        break;
      case RecordType.site:
        await SiteWriterServices(
          ref: ref,
          useFieldNamesOnly: _useFieldNamesOnly,
          selectedColumns: _isCustomFields ? _selectedColumns : null,
        ).writeSiteDelimited(file, format);
        break;
      case RecordType.collEvent:
        await CollEventRecordWriter(
          ref: ref,
          useFieldNamesOnly: _useFieldNamesOnly,
          selectedColumns: _isCustomFields ? _selectedColumns : null,
        ).writeCollEventDelimited(file, format);
        break;
      case RecordType.specimenRecord:
        await SpecimenRecordWriter(
          ref: ref,
          recordType: _specimenRecordType,
          isInaccurateInBrackets: _inaccurateInBrackets,
          isAllFields: _specimenExportFmt == SpecimenExportFmt.allFields,
          concatenateMultiEntry: _concatenateMultiEntry,
          useFieldNamesOnly: _useFieldNamesOnly,
          selectedColumns: _isCustomFields ? _selectedColumns : null,
          exportPreset: _selectedPresetMap,
        ).writeRecordDelimited(file, format);
        break;
      case RecordType.specimenParts:
        await SpecimenPartWriter(
          ref: ref,
          useFieldNamesOnly: _useFieldNamesOnly,
          selectedColumns: _isCustomFields ? _selectedColumns : null,
        ).writeDelimited(
          file,
          format,
        );
        break;
    }
  }
}

class PresetFieldViewer extends StatelessWidget {
  const PresetFieldViewer({super.key, required this.preset});
  final ExportPresetModel preset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Preset Fields (Read-Only)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (preset.fields.isNotEmpty) ...[
                Text('Standard Fields',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: preset.fields.values.map((f) {
                    return Chip(
                      label: Text(f),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              if (preset.combinedFields.isNotEmpty) ...[
                Text('Combined Fields',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: preset.combinedFields.map((f) {
                    return Chip(
                      label: Text(f.fieldId),
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
