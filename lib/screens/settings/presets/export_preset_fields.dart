import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:nahpu/screens/shared/inline_grouped_field_picker.dart';
import 'package:nahpu/screens/shared/text_replacement_rules_editor.dart';
import 'package:nahpu/screens/templates/template_model.dart'
    show isEncodedFieldKey;
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/specimens/conditional_brackets.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/preset_record_exporter.dart';
import 'package:nahpu/services/export/export_header_resolver.dart';
import 'package:nahpu/services/export/list_value_formatter.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/export/text_replacements.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/text_replacement_labels.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';

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
    final customDefinitions =
        ref.watch(allCustomFieldDefinitionsProvider).value ?? const [];
    final canAddNested = _nestedFieldGroups(
      _availableFieldGroups(
        ref.read(databaseProvider),
        _preset.recordType,
        _preset.specimenRecordType,
        customDefinitions,
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
                onAddCustom: _addCustom,
                onAddNested: _addNested,
              ),
            ),
          ),
          const Divider(height: 2),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _preset.mappings.length,
              onReorderItem: _reorder,
              itemBuilder: (context, index) => _ExportMappingCard(
                key: ValueKey('mapping-$index'),
                mapping: _preset.mappings[index],
                headerFormat: _preset.headerFormat,
                customDefinitions: customDefinitions,
                onRemove: () => _remove(index),
                onCustomize: () => _customizeMapping(index),
              ),
            ),
          ),
          const Divider(height: 2),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.visibility_outlined),
                label: Text(context.l10n.commonPreview),
                onPressed: _showPreview,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.exportFieldsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _preset),
        ),
      ),
      body: PopScope(
        canPop: true,
        child: SafeArea(
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
                      TabBar(
                        tabs: [
                          Tab(text: context.l10n.exportFieldsAvailableFields),
                          Tab(text: context.l10n.exportFieldsSelectedMappings),
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
      'collMethod',
      'collPersonnel',
      'specimenPart',
    ];
    final groups = _nestedFieldGroups(
      _availableFieldGroups(
        ref.read(databaseProvider),
        _preset.recordType,
        _preset.specimenRecordType,
        ref.read(allCustomFieldDefinitionsProvider).value ?? const [],
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

  void _addCustom() {
    _openMappingCustomizer(
      const ExportFieldMapping(expression: ''),
      allowExpandRows: true,
      onSave: (mapping) => _update(mappings: [..._preset.mappings, mapping]),
      initialMappingKind: 'custom',
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
        description: _preset.description,
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
        builder: (context) => SafeArea(
          top: false,
          child: _MappingCustomizerBottomSheet(
            mapping: mapping,
            recordType: _preset.recordType,
            specimenRecordType: _preset.specimenRecordType,
            headerFormat: _preset.headerFormat,
            allowExpandRows: allowExpandRows,
            onSave: onSave,
            initialMappingKind: initialMappingKind,
          ),
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
              title: Text(context.l10n.exportFieldsNoPreviewTitle),
              content: Text(context.l10n.exportFieldsNoPreviewBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.commonClose),
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
            title: Text(context.l10n.commonError),
            content: Text(context.l10n.exportFieldsPreviewFailed('$e')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.commonClose),
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
    final customDefinitions =
        ref.watch(allCustomFieldDefinitionsProvider).value ?? const [];
    final groups = _getAllGroups(customDefinitions);
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
                      context.l10n.exportFieldsInsertSourceField,
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
                            context.l10n.exportFieldsDisplayTableField,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'short',
                          child: Text(
                            context.l10n.exportFieldsDisplayFieldOnly,
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
          const Divider(height: 2),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: groupKeys.length,
              itemBuilder: (context, index) {
                final table = groupKeys[index];
                final fields = groups[table]!;
                return ExpansionTile(
                  title: Text(
                    databaseTableLocalizedTitle(context.l10n, table),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  dense: true,
                  childrenPadding: EdgeInsets.zero,
                  children: fields.map((field) {
                    final customLabel = _customFieldLabel(
                      field,
                      customDefinitions,
                    );
                    final displayLabel = _fieldDisplayOption == 'short'
                        ? '[${customLabel ?? field.split('::').last}]'
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
                          fontSize: 14,
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

  Map<String, List<String>> _getAllGroups(
    List<CustomFieldDefinitionData> customDefinitions,
  ) {
    return _availableFieldGroups(
      ref.read(databaseProvider),
      widget.recordType,
      widget.specimenRecordType,
      customDefinitions,
    );
  }
}

Map<String, List<String>> _availableFieldGroups(
  Database db,
  RecordType recordType,
  SpecimenRecordType specimenRecordType, [
  List<CustomFieldDefinitionData> customDefinitions = const [],
]) {
  final Map<String, List<String>> groups = {};
  final Set<String> allowedTables;
  switch (recordType) {
    case RecordType.none:
      allowedTables = {'personnel', 'project'};
      break;
    case RecordType.narrative:
      allowedTables = {'narrative', 'site', 'geography', 'personnel'};
      break;
    case RecordType.site:
      allowedTables = {
        'site',
        'geography',
        'siteAttribute',
        'personnel',
        'coordinate',
      };
      break;
    case RecordType.collEvent:
      allowedTables = {
        'collEvent',
        'site',
        'geography',
        'siteAttribute',
        'environment',
        'coordinate',
        'collMethod',
        'collPersonnel',
      };
      break;
    case RecordType.specimenRecord:
    case RecordType.specimenParts:
    case RecordType.parasites:
      allowedTables = {
        'specimen',
        'taxonomy',
        'personnel',
        'project',
        'collEvent',
        'collMethod',
        'collPersonnel',
        'site',
        'geography',
        'siteAttribute',
        'coordinate',
        'environment',
        'mammalAttribute',
        'birdAttribute',
        'herpAttribute',
        'invertebrateAttribute',
        'fishAttribute',
        'fossilAttribute',
        'specimenPart',
      };
      if (recordType == RecordType.parasites) {
        allowedTables
          ..remove('specimenPart')
          ..addAll({'parasite', 'parasiteDetection'});
      }
      if (specimenRecordType == SpecimenRecordType.mammals) {
        allowedTables.remove('birdAttribute');
        allowedTables.remove('herpAttribute');
        allowedTables.remove('invertebrateAttribute');
        allowedTables.remove('fishAttribute');
      } else if (specimenRecordType == SpecimenRecordType.birds) {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('herpAttribute');
        allowedTables.remove('invertebrateAttribute');
        allowedTables.remove('fishAttribute');
      } else if (specimenRecordType == SpecimenRecordType.herpetofauna) {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('birdAttribute');
        allowedTables.remove('invertebrateAttribute');
        allowedTables.remove('fishAttribute');
      } else if (specimenRecordType == SpecimenRecordType.invertebrates) {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('birdAttribute');
        allowedTables.remove('herpAttribute');
        allowedTables.remove('fishAttribute');
      } else if (specimenRecordType == SpecimenRecordType.fishes) {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('birdAttribute');
        allowedTables.remove('herpAttribute');
        allowedTables.remove('invertebrateAttribute');
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
  for (final definition in customDefinitions) {
    final namespace = switch (definition.placement) {
      FieldUISection.siteAttribute => 'customSite',
      FieldUISection.environmentalData => 'customEnvironment',
      FieldUISection.specimenAttribute => 'customSpecimen',
      FieldUISection.specimenPart => 'customSpecimenPart',
      FieldUISection.parasite => 'customParasite',
    };
    final isAvailable = switch (recordType) {
      RecordType.site || RecordType.narrative => namespace == 'customSite',
      RecordType.collEvent =>
        namespace == 'customSite' || namespace == 'customEnvironment',
      RecordType.specimenRecord ||
      RecordType.specimenParts ||
      RecordType.parasites => true,
      RecordType.none => false,
    };
    if (!isAvailable ||
        !_matchesSpecimenRecordType(definition, specimenRecordType)) {
      continue;
    }
    groups
        .putIfAbsent(namespace, () => <String>[])
        .add('$namespace::${definition.uuid}');
  }
  return groups;
}

bool _matchesSpecimenRecordType(
  CustomFieldDefinitionData definition,
  SpecimenRecordType recordType,
) {
  final catalog = definition.applicableCatalog;
  if (catalog == null || !definition.placement.isSpecimenRelated) {
    return true;
  }
  return switch (recordType) {
    SpecimenRecordType.birds => catalog == CatalogFmt.ornithology,
    SpecimenRecordType.mammals => catalog == CatalogFmt.mammalogy,
    SpecimenRecordType.herpetofauna => catalog == CatalogFmt.herpetology,
    SpecimenRecordType.invertebrates =>
      catalog == CatalogFmt.invertebrateZoology,
    SpecimenRecordType.fishes => catalog == CatalogFmt.ichthyology,
    SpecimenRecordType.allTaxa => true,
  };
}

String? _customFieldLabel(
  String key,
  List<CustomFieldDefinitionData> definitions,
) {
  if (!key.startsWith('custom')) return null;
  final uuid = key.split('::').last;
  return definitions
      .where((definition) => definition.uuid == uuid)
      .map((definition) => definition.name)
      .firstOrNull;
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
  AppLocalizations l10n,
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
  final table = _fieldTableName(normalized, l10n);
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

String _fieldTableName(String value, AppLocalizations l10n) {
  final separator = value.indexOf('::');
  return separator == -1
      ? l10n.exportFieldsOtherFields
      : value.substring(0, separator);
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
    final l10n = context.l10n;
    final tableName = value == null ? null : _fieldTableName(value!, l10n);
    return Semantics(
      button: true,
      label: decoration.labelText,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          final selected = await _showGroupedFieldPicker(
            context,
            title: decoration.labelText ?? l10n.exportFieldsSelectField,
            groups: groups,
            selectedValue: value,
          );
          if (selected != null) onChanged(selected);
        },
        child: InputDecorator(
          decoration: decoration.copyWith(
            hintText: displayValue == null
                ? l10n.exportFieldsChooseField
                : null,
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
                tooltip: context.l10n.exportFieldsCloseFieldPicker,
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
            decoration: InputDecoration(
              labelText: context.l10n.exportFieldsSearchFields,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        const Divider(height: 2),
        Expanded(
          child: filteredGroups.isEmpty
              ? Center(child: Text(context.l10n.exportFieldsNoMatchingFields))
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
    required this.onAddCustom,
    required this.onAddNested,
  });

  final bool canAddNested;
  final VoidCallback onAddCustom;
  final VoidCallback onAddNested;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactActions = constraints.maxWidth < 480;
        final l10n = context.l10n;
        final title = Text(
          l10n.exportFieldsSelectedMappings,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        );
        if (compactActions) {
          return Row(
            children: [
              Expanded(child: title),
              IconButton(
                tooltip: l10n.exportFieldsAddCustomField,
                onPressed: onAddCustom,
                icon: const Icon(Icons.edit_note_outlined),
              ),
              IconButton(
                tooltip: l10n.exportFieldsAddNested,
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
              onPressed: onAddCustom,
              icon: const Icon(Icons.edit_note_outlined),
              label: Text(l10n.exportFieldsAddCustomField),
            ),
            TextButton.icon(
              onPressed: canAddNested ? onAddNested : null,
              icon: const Icon(Icons.account_tree_outlined),
              label: Text(l10n.exportFieldsAddNested),
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
    required this.headerFormat,
    required this.customDefinitions,
    required this.onRemove,
    required this.onCustomize,
  });

  final ExportFieldMapping mapping;
  final ExportHeaderFormat headerFormat;
  final List<CustomFieldDefinitionData> customDefinitions;
  final VoidCallback onRemove;
  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final columnName = exportMappingColumnName(
      mapping,
      headerFormat,
      customLabel: (key) => _customFieldLabel(key, customDefinitions),
    );
    final displayName = columnName.isEmpty
        ? l10n.exportFieldsUnnamed
        : columnName;

    final String title;
    final String subtitle;
    final IconData icon;

    if (mapping.isNested) {
      title = l10n.exportFieldsCardNested(displayName);
      subtitle =
          '${_nestedModeLabel(mapping.nestedMode, l10n)} · '
          '${mapping.nestedFields.join(', ')}';
      icon = Icons.account_tree_outlined;
    } else if (mapping.textType == 'list') {
      title = l10n.exportFieldsCardList(displayName);
      subtitle = mapping.listMode == ListExportMode.spreadColumns
          ? l10n.exportFieldsCardIndexedColumns(
              _indexedStyleLabel(mapping.indexedHeaderStyle),
            )
          : headerFormat == ExportHeaderFormat.darwinCore
          ? l10n.exportFieldsCardDarwinCoreSeparator
          : l10n.exportFieldsCardSeparator(
              normalizeTemplateListFormatOption(mapping.formatOption),
            );
      icon = Icons.view_column_outlined;
    } else {
      title = isDirectExportSourceExpression(mapping.expression)
          ? l10n.exportFieldsCardField(displayName)
          : l10n.exportFieldsCardCustom(displayName);
      subtitle = l10n.exportFieldsCardFormat(
        _valueFormatLabel(mapping.textType, l10n),
        mapping.formatOption,
      );
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
          borderRadius: BorderRadius.circular(12),
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
                tooltip: l10n.exportFieldsCustomize,
                icon: const Icon(Icons.edit_outlined),
                onPressed: onCustomize,
              ),
              IconButton(
                tooltip: l10n.commonRemove,
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

  String _nestedModeLabel(NestedExportMode mode, AppLocalizations l10n) =>
      switch (mode) {
        NestedExportMode.concatenate => l10n.exportFieldsOneColumn,
        NestedExportMode.spreadColumns => l10n.exportFieldsIndexedColumns,
        NestedExportMode.expandRows => l10n.exportFieldsRepeatedRows,
      };

  String _indexedStyleLabel(IndexedHeaderStyle style) => switch (style) {
    IndexedHeaderStyle.underscore => 'field_1',
    IndexedHeaderStyle.compact => 'field1',
    IndexedHeaderStyle.brackets => 'field[1]',
  };

  String _valueFormatLabel(
    String textType,
    AppLocalizations l10n,
  ) => switch (textType) {
    kConditionalBracketExportTextType =>
      l10n.exportFieldsFormatConditionalBrackets,
    kConditionalFieldExportTextType => l10n.exportFieldsFormatConditionalField,
    kConditionalValueExportTextType => l10n.exportFieldsFormatConditionalValue,
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
    _localMapping = widget.mapping.textType == 'list'
        ? widget.mapping.copyWith(
            formatOption: normalizeTemplateListFormatOption(
              widget.mapping.formatOption,
            ),
          )
        : widget.mapping;
    _mappingKind =
        widget.initialMappingKind ??
        (_localMapping.isNested
            ? 'nested'
            : _localMapping.textType == 'list'
            ? 'list'
            : isDirectExportSourceExpression(_localMapping.expression)
            ? 'scalar'
            : 'custom');

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
    final customDefinitions =
        ref.watch(allCustomFieldDefinitionsProvider).value ?? const [];
    final groups = _availableFieldGroups(
      ref.read(databaseProvider),
      widget.recordType,
      widget.specimenRecordType,
      customDefinitions,
    );
    final l10n = context.l10n;
    final selectedSource = _exactSourceField(_expressionController.text);
    final sourceGroups = _fieldGroupsWithValue(groups, selectedSource, l10n);
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
          isExpanded: true,
          key: ValueKey('mapping-kind-$_mappingKind'),
          initialValue: _mappingKind,
          decoration: InputDecoration(labelText: l10n.exportFieldsMappingType),
          items: [
            DropdownMenuItem(
              value: 'scalar',
              child: Text(l10n.exportFieldsKindSingle),
            ),
            DropdownMenuItem(
              value: 'custom',
              child: Text(l10n.exportFieldsKindCustom),
            ),
            DropdownMenuItem(
              value: 'list',
              child: Text(l10n.exportFieldsKindList),
            ),
            DropdownMenuItem(
              value: 'nested',
              child: Text(l10n.exportFieldsKindNested),
            ),
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
              decoration: InputDecoration(
                labelText: l10n.exportFieldsSourceField,
                helperText: l10n.exportFieldsSourceFieldHelper,
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
              decoration: InputDecoration(
                labelText: l10n.exportFieldsSourceField,
                helperText: l10n.exportFieldsSourceFieldHelper,
              ),
              onChanged: (value) {
                setState(() => _expressionController.text = '[$value]');
              },
            ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _headerController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.exportFieldsColumnNameOptional,
              helperText: l10n.exportFieldsColumnNameOptionalHelper,
            ),
          ),
          if (_mappingKind == 'list') ...[
            const SizedBox(height: 16),
            Text(
              l10n.exportFieldsListOutput,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            RadioGroup<ListExportMode>(
              groupValue: _localMapping.listMode,
              onChanged: _setListMode,
              child: Column(
                children: [
                  RadioListTile<ListExportMode>(
                    value: ListExportMode.concatenate,
                    title: Text(l10n.exportFieldsOneColumn),
                    subtitle: Text(l10n.exportFieldsExample('A, B, C')),
                  ),
                  RadioListTile<ListExportMode>(
                    value: ListExportMode.spreadColumns,
                    title: Text(l10n.exportFieldsIndexedColumns),
                    subtitle: Text(
                      l10n.exportFieldsExample('field_1, field_2, field_3'),
                    ),
                  ),
                ],
              ),
            ),
            if (_localMapping.listMode == ListExportMode.concatenate) ...[
              if (widget.headerFormat == ExportHeaderFormat.darwinCore)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(l10n.exportFieldsDarwinCoreListSeparator),
                )
              else
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  key: ValueKey(
                    'separator-${_listSeparatorOption(_localMapping.formatOption)}',
                  ),
                  initialValue: _listSeparatorOption(
                    _localMapping.formatOption,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.exportFieldsSeparator,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'pipe',
                      child: Text(l10n.exportFieldsSeparatorPipe),
                    ),
                    DropdownMenuItem(
                      value: 'comma',
                      child: Text(l10n.exportFieldsSeparatorComma),
                    ),
                    DropdownMenuItem(
                      value: 'semicolon',
                      child: Text(l10n.exportFieldsSeparatorSemicolon),
                    ),
                    DropdownMenuItem(
                      value: 'slash',
                      child: Text(l10n.exportFieldsSeparatorSlash),
                    ),
                    DropdownMenuItem(
                      value: 'newline',
                      child: Text(l10n.exportFieldsSeparatorNewLine),
                    ),
                    DropdownMenuItem(
                      value: 'bullet',
                      child: Text(l10n.exportFieldsSeparatorBulleted),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text(l10n.exportFieldsSeparatorCustom),
                    ),
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
              if (widget.headerFormat != ExportHeaderFormat.darwinCore &&
                  _localMapping.formatOption.startsWith('custom:')) ...[
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _localMapping.formatOption.substring(7),
                  key: const ValueKey('list-custom-separator'),
                  decoration: InputDecoration(
                    labelText: l10n.exportFieldsCustomSeparator,
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
              isExpanded: true,
              key: ValueKey('format-${_localMapping.textType}'),
              initialValue: _standardTextType(_localMapping.textType),
              decoration: InputDecoration(
                labelText: l10n.exportFieldsValueFormat,
              ),
              items: [
                DropdownMenuItem(
                  value: 'normal',
                  child: Text(l10n.exportFieldsValueNormal),
                ),
                DropdownMenuItem(
                  value: 'encoded',
                  child: Text(l10n.exportFieldsValueEncoded),
                ),
                DropdownMenuItem(
                  value: 'coordinates',
                  child: Text(l10n.exportFieldsValueCoordinates),
                ),
                DropdownMenuItem(
                  value: kConditionalBracketExportTextType,
                  child: Text(l10n.exportFieldsValueConditionalBrackets),
                ),
                DropdownMenuItem(
                  value: kConditionalFieldExportTextType,
                  child: Text(l10n.exportFieldsValueConditionalField),
                ),
                DropdownMenuItem(
                  value: kConditionalValueExportTextType,
                  child: Text(l10n.exportFieldsValueConditionalValue),
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
                  decoration: InputDecoration(
                    labelText: l10n.exportFieldsReplacementText,
                    helperText: l10n.exportFieldsReplacementTextHelper,
                  ),
                ),
              ],
            ],
          ],
        ] else if (_mappingKind == 'custom') ...[
          _CustomExpressionComposer(
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
            decoration: InputDecoration(
              labelText: l10n.exportFieldsColumnName,
              helperText: l10n.exportFieldsColumnNameHelper,
            ),
          ),
        ] else ...[
          DropdownButtonFormField<String>(
            key: ValueKey('namespace-$namespace'),
            initialValue: namespaces.contains(namespace) ? namespace : null,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.exportFieldsRelatedRecords,
              helperText: l10n.exportFieldsRelatedRecordsHelper,
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
            l10n.exportFieldsSelectedChildFields,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (_nestedFields.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.exportFieldsSelectChildFieldHint),
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
                      tooltip: l10n.exportFieldsMoveUp,
                      onPressed: entry.key == 0
                          ? null
                          : () => _moveNestedField(entry.key, -1),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      tooltip: l10n.exportFieldsMoveDown,
                      onPressed: entry.key == _nestedFields.length - 1
                          ? null
                          : () => _moveNestedField(entry.key, 1),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    IconButton(
                      tooltip: l10n.exportFieldsRemoveField,
                      onPressed: () => _toggleNestedField(entry.value, false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(l10n.exportFieldsChooseChildFields),
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
            decoration: InputDecoration(
              labelText: l10n.exportFieldsColumnPrefixOptional,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.exportFieldsNestedOutput,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          RadioGroup<NestedExportMode>(
            groupValue: _localMapping.nestedMode,
            onChanged: _setNestedMode,
            child: Column(
              children: [
                RadioListTile<NestedExportMode>(
                  value: NestedExportMode.concatenate,
                  title: Text(l10n.exportFieldsOneColumn),
                  subtitle: Text(l10n.exportFieldsNestedOneColumnHint),
                ),
                RadioListTile<NestedExportMode>(
                  value: NestedExportMode.spreadColumns,
                  title: Text(l10n.exportFieldsIndexedColumns),
                  subtitle: Text(l10n.exportFieldsNestedIndexedHint),
                ),
                RadioListTile<NestedExportMode>(
                  value: NestedExportMode.expandRows,
                  title: Text(l10n.exportFieldsRepeatedRows),
                  subtitle: Text(
                    widget.allowExpandRows
                        ? l10n.exportFieldsNestedRepeatedHint
                        : l10n.exportFieldsNestedRepeatedTaken,
                  ),
                  enabled: widget.allowExpandRows,
                ),
              ],
            ),
          ),
          if (_localMapping.nestedMode == NestedExportMode.concatenate) ...[
            if (widget.headerFormat == ExportHeaderFormat.darwinCore &&
                _nestedFields.length == 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.exportFieldsDarwinCoreListSeparator),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fieldSepController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: l10n.exportFieldsFieldSeparator,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _recordSepController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: l10n.exportFieldsRecordSeparator,
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
          title: Text(l10n.exportFieldsAdvanced),
          children: [
            if (_mappingKind != 'nested') ...[
              TextFormField(
                controller: _expressionController,
                onChanged: (_) => setState(() {}),
                // Long expressions wrap for review, but stay one logical line
                // because a line break would be written into the export cell.
                minLines: 2,
                maxLines: 8,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                decoration: InputDecoration(
                  labelText: l10n.exportFieldsRawExpression,
                  helperText: l10n.exportFieldsExample(
                    '[specimen::catalogNum]',
                  ),
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
                  decoration: InputDecoration(
                    labelText: l10n.exportFieldsRawFormatOption,
                    helperText: l10n.exportFieldsRawFormatOptionHelper,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                key: ValueKey(
                  'null-fallback-${_localMapping.nullFallbackOption}',
                ),
                initialValue: _localMapping.nullFallbackOption,
                decoration: InputDecoration(
                  labelText: l10n.exportFieldsEmptyValue,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'blank',
                    child: Text(l10n.exportFieldsEmptyBlank),
                  ),
                  DropdownMenuItem(
                    value: 'custom',
                    child: Text(l10n.exportFieldsEmptyCustomText),
                  ),
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
                  decoration: InputDecoration(
                    labelText: l10n.exportFieldsCustomEmptyText,
                  ),
                ),
              ],
            ] else
              TextFormField(
                controller: _nestedNamespaceController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.exportFieldsRawNamespace,
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
              child: Text(l10n.commonCancel),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: canSave ? _submit : null,
              child: Text(l10n.commonDone),
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
          'custom' => 'normal',
          _ => _localMapping.textType,
        },
        clearNestedNamespace: true,
        headerOverride: _headerController.text.trim(),
        clearHeaderOverride: _headerController.text.trim().isEmpty,
        formatOption: _mappingKind == 'list'
            ? _formatOptionController.text
            : _formatOptionController.text.trim(),
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
          _localMapping = _localMapping.copyWith(formatOption: 'pipe');
          _formatOptionController.text = 'pipe';
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
    final l10n = context.l10n;
    for (
      var index = 0;
      index < _localMapping.replacementRules.length;
      index++
    ) {
      final error = validateTextReplacementRule(
        _localMapping.replacementRules[index],
      );
      if (error != null) {
        return l10n.exportFieldsErrorReplacement(index + 1, error.label(l10n));
      }
    }
    if (_mappingKind == 'nested') {
      if (_nestedNamespaceController.text.trim().isEmpty) {
        return l10n.exportFieldsErrorChooseGroup;
      }
      if (_nestedFields.isEmpty) return l10n.exportFieldsErrorChooseChild;
      if (_localMapping.nestedMode == NestedExportMode.concatenate &&
          (_fieldSepController.text.isEmpty ||
              _recordSepController.text.isEmpty) &&
          !(widget.headerFormat == ExportHeaderFormat.darwinCore &&
              _nestedFields.length == 1)) {
        return l10n.exportFieldsErrorSeparatorsEmpty;
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
        return l10n.exportFieldsErrorMultiFieldHeader;
      }
      return '';
    }
    if (_expressionController.text.trim().isEmpty) {
      return _mappingKind == 'custom'
          ? l10n.exportFieldsErrorAddSegment
          : l10n.exportFieldsErrorChooseSource;
    }
    if (usesStandardizedExportHeaders(widget.headerFormat) &&
        _headerController.text.trim().isEmpty &&
        _exactSourceField(_expressionController.text) == null) {
      return l10n.exportFieldsErrorCompositeHeader;
    }
    if (_mappingKind == 'list' &&
        _localMapping.listMode == ListExportMode.spreadColumns &&
        _exactSourceField(_expressionController.text) == null) {
      return l10n.exportFieldsErrorIndexedSingleSource;
    }
    if (_localMapping.textType == kConditionalBracketExportTextType ||
        isConditionalReplacementExportTextType(_localMapping.textType)) {
      final target = _exactSourceField(_expressionController.text);
      if (target == null) {
        return l10n.exportFieldsErrorConditionalSingleSource;
      }
      if (_localMapping.bracketConditions.isEmpty) {
        return l10n.exportFieldsErrorAddCondition;
      }
      if (isConditionalReplacementExportTextType(_localMapping.textType) &&
          _conditionalTextController.text.isEmpty) {
        return l10n.exportFieldsErrorReplacementText;
      }
      for (final condition in _localMapping.bracketConditions) {
        if (_localMapping.textType != kConditionalValueExportTextType &&
            condition.sourceField.trim().isEmpty) {
          return l10n.exportFieldsErrorControllingField;
        }
        if (condition.comparisonValue.trim().isEmpty) {
          return l10n.exportFieldsErrorComparisonValue;
        }
        if (_localMapping.textType != kConditionalValueExportTextType &&
            condition.sourceField.trim().toLowerCase() ==
                target.toLowerCase()) {
          return l10n.exportFieldsErrorSelfDependency;
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
    final normalized = normalizeTemplateListFormatOption(value);
    return normalized.startsWith('custom:') ? 'custom' : normalized;
  }

  bool _isListFormatOption(String value) => isTemplateListFormatOption(value);

  String? _exactSourceField(String expression) {
    final match = RegExp(r'^\s*\[([^\]]+)\]\s*$').firstMatch(expression);
    return match?.group(1)?.trim();
  }
}

class _CustomExpressionComposer extends StatefulWidget {
  const _CustomExpressionComposer({
    required this.expression,
    required this.fieldGroups,
    required this.onChanged,
  });

  final String expression;
  final Map<String, List<String>> fieldGroups;
  final ValueChanged<String> onChanged;

  @override
  State<_CustomExpressionComposer> createState() =>
      _CustomExpressionComposerState();
}

class _CustomExpressionComposerState extends State<_CustomExpressionComposer> {
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
  void didUpdateWidget(covariant _CustomExpressionComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expression != oldWidget.expression &&
        widget.expression != serializeExportExpression(_segments)) {
      _segments = parseExportExpression(widget.expression);
      _segmentIds = List.generate(_segments.length, (_) => _nextSegmentId++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.exportFieldsCustomValue,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(l10n.exportFieldsCustomValueHelp),
        const SizedBox(height: 8),
        if (_segments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.exportFieldsCustomValueEmpty),
          ),
        ..._segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          final segmentId = _segmentIds[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Material(
              key: ValueKey('custom-segment-$segmentId'),
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
                    Icon(switch (segment.kind) {
                      ExportExpressionSegmentKind.field => Icons.data_object,
                      ExportExpressionSegmentKind.text => Icons.text_fields,
                      ExportExpressionSegmentKind.conditional =>
                        Icons.alt_route,
                    }),
                    const SizedBox(width: 8),
                    Expanded(
                      child: switch (segment.kind) {
                        ExportExpressionSegmentKind.field => Text(
                          segment.value,
                        ),
                        ExportExpressionSegmentKind.conditional => Text(
                          _conditionalSegmentSummary(segment.value, l10n),
                        ),
                        ExportExpressionSegmentKind.text => TextFormField(
                          key: ValueKey('custom-text-$segmentId'),
                          initialValue: segment.value,
                          decoration: InputDecoration(
                            labelText: l10n.exportFieldsTextOrSeparator,
                            isDense: true,
                          ),
                          onChanged: (value) => _setText(index, value),
                        ),
                      },
                    ),
                    if (segment.isField &&
                        isEncodedFieldKey(
                          parsePlaceholderKey(segment.value).key,
                        ))
                      IconButton(
                        tooltip: l10n.exportFieldsShowLabel,
                        isSelected: parsePlaceholderKey(segment.value).decode,
                        onPressed: () => _toggleLabel(index),
                        icon: const Icon(Icons.label_outline),
                        selectedIcon: const Icon(Icons.label),
                      ),
                    if (segment.isConditional &&
                        (parseConditionalBracketExpression(
                              segment.value,
                              0,
                            )?.isConditionalText ??
                            false))
                      IconButton(
                        tooltip: l10n.exportFieldsEditConditionalText,
                        onPressed: () => _editConditionalText(index),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    IconButton(
                      tooltip: l10n.exportFieldsMoveSegmentUp,
                      onPressed: index == 0 ? null : () => _move(index, -1),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      tooltip: l10n.exportFieldsMoveSegmentDown,
                      onPressed: index == _segments.length - 1
                          ? null
                          : () => _move(index, 1),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    IconButton(
                      tooltip: l10n.exportFieldsRemoveSegment,
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
              label: Text(l10n.exportFieldsAddField),
            ),
            OutlinedButton.icon(
              onPressed: _addText,
              icon: const Icon(Icons.add),
              label: Text(l10n.exportFieldsAddText),
            ),
            OutlinedButton.icon(
              onPressed: _addConditionalText,
              icon: const Icon(Icons.add),
              label: Text(l10n.exportFieldsAddConditionalText),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.exportFieldsExpression(serializeExportExpression(_segments)),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _notify() => widget.onChanged(serializeExportExpression(_segments));

  Future<void> _addField() async {
    final field = await _showGroupedFieldPicker(
      context,
      title: context.l10n.exportFieldsAddSourceField,
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

  void _toggleLabel(int index) {
    final parsed = parsePlaceholderKey(_segments[index].value);
    setState(() {
      _segments[index] = ExportExpressionSegment.field(
        parsed.decode ? parsed.key : '${parsed.key}$kPlaceholderLabelMarker',
      );
    });
    _notify();
  }

  Future<void> _addConditionalText() async {
    final syntax = await _showConditionalTextDialog();
    if (syntax == null || !mounted) return;
    setState(() {
      _segments.add(ExportExpressionSegment.conditional(syntax));
      _segmentIds.add(_nextSegmentId++);
    });
    _notify();
  }

  Future<void> _editConditionalText(int index) async {
    final syntax = await _showConditionalTextDialog(_segments[index].value);
    if (syntax == null || !mounted) return;
    setState(() {
      _segments[index] = ExportExpressionSegment.conditional(syntax);
    });
    _notify();
  }

  Future<String?> _showConditionalTextDialog([String? syntax]) {
    return showDialog<String>(
      context: context,
      builder: (context) => _ConditionalTextSegmentDialog(
        fieldGroups: widget.fieldGroups,
        syntax: syntax,
      ),
    );
  }
}

/// Builds a `[[if][…]=>"…"|"…"]]` segment for a custom field expression.
class _ConditionalTextSegmentDialog extends StatefulWidget {
  const _ConditionalTextSegmentDialog({required this.fieldGroups, this.syntax});

  final Map<String, List<String>> fieldGroups;

  /// The segment being edited, or `null` for a new one.
  final String? syntax;

  @override
  State<_ConditionalTextSegmentDialog> createState() =>
      _ConditionalTextSegmentDialogState();
}

class _ConditionalTextSegmentDialogState
    extends State<_ConditionalTextSegmentDialog> {
  late List<ConditionalBracketCondition> _conditions;
  late ConditionalMatchMode _mode;
  late final TextEditingController _thenController;
  late final TextEditingController _elseController;

  @override
  void initState() {
    super.initState();
    final syntax = widget.syntax;
    final existing = syntax == null
        ? null
        : parseConditionalBracketExpression(syntax, 0);
    _conditions =
        existing?.conditions ??
        const [
          ConditionalBracketCondition(
            sourceField: '',
            operator: ConditionalComparisonOperator.equals,
            comparisonValue: '',
          ),
        ];
    _mode = existing?.matchMode ?? ConditionalMatchMode.any;
    _thenController = TextEditingController(
      text: existing?.replacementText ?? '',
    );
    _elseController = TextEditingController(text: existing?.elseText ?? '');
  }

  @override
  void dispose() {
    _thenController.dispose();
    _elseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid =
        _conditions.isNotEmpty &&
        _conditions.every(
          (condition) =>
              condition.sourceField.trim().isNotEmpty &&
              (condition.operator == ConditionalComparisonOperator.isEmpty ||
                  condition.operator ==
                      ConditionalComparisonOperator.isNotEmpty ||
                  condition.comparisonValue.trim().isNotEmpty),
        );
    final l10n = context.l10n;
    // The texts are deliberately optional: an empty text writes nothing.
    return AlertDialog(
      title: Text(l10n.exportFieldsConditionalText),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ConditionalBracketControls(
                fieldGroups: widget.fieldGroups,
                targetField: null,
                compareTargetValue: false,
                conditions: _conditions,
                mode: _mode,
                onChanged: (conditions, mode) => setState(() {
                  _conditions = conditions;
                  _mode = mode;
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _thenController,
                decoration: InputDecoration(
                  labelText: l10n.exportFieldsTextWhenMatched,
                  helperText: l10n.exportFieldsTextWhenMatchedHelper(
                    '[mammalAttribute::testisWidth]',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _elseController,
                decoration: InputDecoration(
                  labelText: l10n.exportFieldsTextOtherwise,
                  helperText: l10n.exportFieldsTextOtherwiseHelper,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: valid ? _save : null,
          child: Text(l10n.commonApply),
        ),
      ],
    );
  }

  void _save() {
    final elseText = _elseController.text;
    Navigator.pop(
      context,
      ConditionalBracketExpression(
        targetField: kConditionalTextKeyword,
        conditions: _conditions,
        matchMode: _mode,
        start: 0,
        end: 0,
        outputAction: ConditionalOutputAction.text,
        replacementText: _thenController.text,
        elseText: elseText.isEmpty ? null : elseText,
      ).toTemplateSyntax(),
    );
  }
}

/// Describes a conditional segment in words for the custom field composer.
///
/// Targeted conditionals, which the composer does not edit, show their syntax.
String _conditionalSegmentSummary(String syntax, AppLocalizations l10n) {
  final expression = parseConditionalBracketExpression(syntax, 0);
  if (expression == null || !expression.isConditionalText) return syntax;
  final joiner = expression.matchMode == ConditionalMatchMode.any
      ? ' ${l10n.exportFieldsSummaryOr} '
      : ' ${l10n.exportFieldsSummaryAnd} ';
  final conditions = expression.conditions
      .map((condition) => _conditionSummary(condition, l10n))
      .join(joiner);
  final elseText = expression.elseText;
  return elseText == null
      ? l10n.exportFieldsSummaryIf(conditions, expression.replacementText)
      : l10n.exportFieldsSummaryIfOtherwise(
          conditions,
          expression.replacementText,
          elseText,
        );
}

String _conditionSummary(
  ConditionalBracketCondition condition,
  AppLocalizations l10n,
) {
  final field = condition.sourceField.split('::').last;
  final value = condition.comparisonValue;
  return switch (condition.operator) {
    ConditionalComparisonOperator.equals => l10n.exportFieldsSummaryEquals(
      field,
      value,
    ),
    ConditionalComparisonOperator.notEquals =>
      l10n.exportFieldsSummaryNotEquals(field, value),
    ConditionalComparisonOperator.contains => l10n.exportFieldsSummaryContains(
      field,
      value,
    ),
    ConditionalComparisonOperator.isNotEmpty =>
      l10n.exportFieldsSummaryIsNotEmpty(field),
    ConditionalComparisonOperator.isEmpty => l10n.exportFieldsSummaryIsEmpty(
      field,
    ),
  };
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          compareTargetValue
              ? l10n.exportFieldsValueConditions
              : l10n.exportFieldsFieldConditions,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(l10n.exportFieldsConditionsHelp),
        DropdownButtonFormField<ConditionalMatchMode>(
          isExpanded: true,
          key: ValueKey('bracket-mode-$mode'),
          initialValue: mode,
          decoration: InputDecoration(labelText: l10n.exportFieldsMatchLogic),
          items: [
            DropdownMenuItem(
              value: ConditionalMatchMode.any,
              child: Text(l10n.exportFieldsMatchAny),
            ),
            DropdownMenuItem(
              value: ConditionalMatchMode.all,
              child: Text(l10n.exportFieldsMatchAll),
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
            label: Text(l10n.exportFieldsAddCondition),
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
    final l10n = context.l10n;
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
                groups: _fieldGroupsWithValue(
                  widget.fieldGroups,
                  selected,
                  l10n,
                ),
                decoration: InputDecoration(
                  labelText: l10n.exportFieldsControllingField,
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
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: ConditionalComparisonOperator.equals,
                child: Text(l10n.exportFieldsOperatorEquals),
              ),
              DropdownMenuItem(
                value: ConditionalComparisonOperator.notEquals,
                child: Text(l10n.exportFieldsOperatorNotEquals),
              ),
              DropdownMenuItem(
                value: ConditionalComparisonOperator.contains,
                child: Text(l10n.exportFieldsOperatorContains),
              ),
              DropdownMenuItem(
                value: ConditionalComparisonOperator.isNotEmpty,
                child: Text(l10n.exportFieldsOperatorIsNotEmpty),
              ),
              DropdownMenuItem(
                value: ConditionalComparisonOperator.isEmpty,
                child: Text(l10n.exportFieldsOperatorIsEmpty),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.onChanged(condition.copyWith(operator: value));
              }
            },
          ),
          // The emptiness operators ignore the comparison value, so the field
          // is dropped rather than left to collect text that does nothing.
          if (condition.operator != ConditionalComparisonOperator.isEmpty &&
              condition.operator != ConditionalComparisonOperator.isNotEmpty)
            SizedBox(
              width: 180,
              child: TextFormField(
                key: ValueKey('condition-value-${widget.index}'),
                controller: _valueController,
                decoration: InputDecoration(labelText: l10n.exportFieldsValue),
                onChanged: (value) => widget.onChanged(
                  condition.copyWith(comparisonValue: value),
                ),
              ),
            ),
          IconButton(
            tooltip: l10n.exportFieldsRemoveCondition,
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
      isExpanded: true,
      key: ValueKey('indexed-style-$value'),
      initialValue: value,
      decoration: InputDecoration(
        labelText: context.l10n.exportFieldsIndexedColumnNames,
      ),
      items: [
        DropdownMenuItem(
          value: IndexedHeaderStyle.underscore,
          child: Text(context.l10n.exportFieldsIndexedUnderscore('field_1')),
        ),
        DropdownMenuItem(
          value: IndexedHeaderStyle.compact,
          child: Text(context.l10n.exportFieldsIndexedCompact('field1')),
        ),
        DropdownMenuItem(
          value: IndexedHeaderStyle.brackets,
          child: Text(context.l10n.exportFieldsIndexedBrackets('field[1]')),
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
              context.l10n.exportFieldsOutputExample,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            if (headers.isEmpty)
              Text(context.l10n.exportFieldsOutputExampleEmpty)
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
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(context.l10n.exportFieldsOutputExampleRows),
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
    if (mappingKind == 'scalar' || mappingKind == 'custom') return [base];
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
            ? context.l10n.exportFieldsCustomizeNested
            : context.l10n.exportFieldsCustomizeField,
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
                  ? context.l10n.exportFieldsCustomizeNested
                  : context.l10n.exportFieldsCustomizeField,
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
          Text(context.l10n.exportFieldsPreviewTitle),
          const Spacer(),
          Text(
            context.l10n.exportFieldsPreviewShowing(
              previewRows.length,
              widget.rows.length,
            ),
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
          child: Text(context.l10n.commonClose),
        ),
      ],
    );
  }
}
