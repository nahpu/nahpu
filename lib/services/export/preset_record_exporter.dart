import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/specimens/conditional_brackets.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/services/export/export_header_resolver.dart';
import 'package:nahpu/services/export/list_value_formatter.dart';
import 'package:nahpu/services/narrative/narrative_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/export/text_replacements.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/templates/template_model.dart'
    show formatTemplateText, truncateTrailingDecimalZeroText;
import 'package:nahpu/src/rust/api/export.dart';

export 'export_header_resolver.dart' show formatIndexedExportHeader;

class PresetExportPreviewData {
  const PresetExportPreviewData({required this.headers, required this.rows});
  final List<String> headers;
  final List<List<String>> rows;
}

/// Splits NAHPU's pipe-delimited repeated values without losing empty slots.
List<String> splitExportListValue(String value) {
  return splitNahpuRepeatedValue(value);
}

/// Executes a versioned record export preset without relying on screen state.
class PresetRecordExporter {
  const PresetRecordExporter({required this.ref, required this.preset});

  final WidgetRef ref;
  final ExportPresetModel preset;

  Future<PresetExportPreviewData> getPreviewData() async {
    final errors = validateExportPreset(preset);
    if (errors.isNotEmpty) {
      return const PresetExportPreviewData(headers: [], rows: []);
    }
    final sourceRecords = await _sourceRecords();
    final headerResolver = await ExportHeaderResolver.create(
      preset,
      database: ref.read(databaseProvider),
    );
    if (preset.headerFormat == ExportHeaderFormat.darwinCore) {
      return _darwinCorePreviewData(sourceRecords, headerResolver);
    }
    final headers = _headers(sourceRecords, headerResolver);
    _ensureUniqueHeaders(headers);
    final rows = <Map<String, String>>[];
    for (final source in sourceRecords) {
      rows.addAll(_mapRecord(source, headers, headerResolver));
    }
    return PresetExportPreviewData(
      headers: headers,
      rows: [
        for (final row in rows)
          [for (final header in headers) row[header] ?? ''],
      ],
    );
  }

  Future<void> write(File file, ExportFmt format) async {
    final errors = validateExportPreset(preset);
    if (errors.isNotEmpty) throw ArgumentError(errors.join('\n'));

    final sourceRecords = await _sourceRecords();
    final headerResolver = await ExportHeaderResolver.create(
      preset,
      database: ref.read(databaseProvider),
    );
    if (preset.headerFormat == ExportHeaderFormat.darwinCore) {
      if (format == ExportFmt.json) {
        throw ArgumentError(
          'Darwin Core generated headers support CSV, TSV, and Excel only.',
        );
      }
      final data = _darwinCorePreviewData(sourceRecords, headerResolver);
      await writeTabularRecords(
        headers: data.headers,
        rows: data.rows,
        outputPath: file.path,
        exportFormat: format.name,
      );
      return;
    }
    final headers = _headers(sourceRecords, headerResolver);
    _ensureUniqueHeaders(headers);
    final rows = <Map<String, String>>[];
    for (final source in sourceRecords) {
      rows.addAll(_mapRecord(source, headers, headerResolver));
    }

    await RecordWriter(
      jsonContent: jsonEncode(rows),
      outputPath: file.path,
      columnNames: headers,
      exportFormat: format.name,
      concatenateMultiEntries: true,
    ).write();
  }

  Future<List<Map<String, String>>> _sourceRecords() async {
    final db = ref.read(databaseProvider);
    switch (preset.recordType) {
      case RecordType.specimenRecord:
        final specimens = await _specimens();
        return Future.wait(
          specimens.map(
            (specimen) => documentFieldValuesForSpecimen(db, specimen, ref),
          ),
        );
      case RecordType.site:
        final sites = await SiteServices(ref: ref).getAllSites();
        return Future.wait(
          sites.map((site) => documentFieldValuesForSite(db, site, ref)),
        );
      case RecordType.collEvent:
        final events = await CollEventServices(ref: ref).getAllCollEvents();
        return Future.wait(
          events.map(
            (event) => documentFieldValuesForCollEvent(db, event, ref),
          ),
        );
      case RecordType.narrative:
        final narratives = await NarrativeServices(ref: ref).getAllNarrative();
        return Future.wait(
          narratives.map(
            (narrative) => documentFieldValuesForNarrative(db, narrative, ref),
          ),
        );
      case RecordType.specimenParts:
        final parts = await SpecimenPartServices(
          ref: ref,
        ).getProjectSpecimenParts();
        return Future.wait(
          parts.map(
            (part) => documentFieldValuesForSpecimenPart(db, part, ref),
          ),
        );
      case RecordType.none:
        return const [];
    }
  }

  Future<List<SpecimenData>> _specimens() async {
    final service = SpecimenServices(ref: ref);
    switch (preset.specimenRecordType) {
      case SpecimenRecordType.allTaxa:
        return service.getSpecimenList();
      case SpecimenRecordType.allMammals:
        return service.getSpecimenListForAllMammals();
      default:
        return service.getSpecimenListByTaxonGroup(
          matchRecordTypeToTaxonGroup(preset.specimenRecordType),
        );
    }
  }

  PresetExportPreviewData _darwinCorePreviewData(
    List<Map<String, String>> sourceRecords,
    ExportHeaderResolver headerResolver,
  ) {
    final headers = _darwinCoreHeaders(sourceRecords, headerResolver);
    final rows = <List<String>>[];
    for (final source in sourceRecords) {
      rows.addAll(_mapDarwinCoreRecord(source, sourceRecords, headerResolver));
    }
    return PresetExportPreviewData(headers: headers, rows: rows);
  }

  List<String> _darwinCoreHeaders(
    List<Map<String, String>> sourceRecords,
    ExportHeaderResolver headerResolver,
  ) {
    final headers = <String>[];
    for (final mapping in preset.mappings) {
      if (_suppressDarwinCoreMapping(mapping)) continue;
      if (!mapping.isNested) {
        final source = _directSourceField(mapping.expression);
        if (mapping.textType == 'list' &&
            mapping.listMode == ListExportMode.spreadColumns) {
          final count = sourceRecords.fold<int>(0, (maxCount, record) {
            return _listValues(record, mapping).length > maxCount
                ? _listValues(record, mapping).length
                : maxCount;
          });
          final base = headerResolver.headerFor(mapping);
          for (var index = 1; index <= count; index++) {
            headers.add(
              formatIndexedExportHeader(
                base,
                index,
                mapping.indexedHeaderStyle,
              ),
            );
          }
        } else if (source != null) {
          headers.addAll(headerResolver.headersForSource(source));
        } else {
          headers.add(headerResolver.headerFor(mapping));
        }
        continue;
      }

      if (mapping.nestedMode == NestedExportMode.concatenate) {
        headers.add(headerResolver.headerFor(mapping));
      } else if (mapping.nestedMode == NestedExportMode.expandRows) {
        headers.addAll(
          mapping.nestedFields.map(
            (field) => headerResolver.nestedHeader(mapping, field),
          ),
        );
      } else {
        final count = sourceRecords.fold<int>(0, (maxCount, record) {
          final current = _nestedRows(record, mapping).length;
          return current > maxCount ? current : maxCount;
        });
        for (var index = 1; index <= count; index++) {
          headers.addAll(
            mapping.nestedFields.map(
              (field) =>
                  headerResolver.nestedHeader(mapping, field, index: index),
            ),
          );
        }
      }
    }
    return headers;
  }

  List<List<String>> _mapDarwinCoreRecord(
    Map<String, String> source,
    List<Map<String, String>> sourceRecords,
    ExportHeaderResolver headerResolver,
  ) {
    final expanding = preset.mappings.where(
      (mapping) =>
          mapping.isNested && mapping.nestedMode == NestedExportMode.expandRows,
    );
    final base = _darwinCoreBaseValues(source, sourceRecords, headerResolver);
    if (expanding.isEmpty) return [base];

    final mapping = expanding.single;
    final nestedRows = _nestedRows(source, mapping);
    if (nestedRows.isEmpty) {
      return [
        [...base, for (final _ in mapping.nestedFields) ''],
      ];
    }
    return nestedRows
        .map((nested) {
          return [
            ...base,
            for (final field in mapping.nestedFields)
              _applyReplacements(mapping, nested[field] ?? ''),
          ];
        })
        .toList(growable: false);
  }

  List<String> _darwinCoreBaseValues(
    Map<String, String> source,
    List<Map<String, String>> sourceRecords,
    ExportHeaderResolver headerResolver,
  ) {
    final values = <String>[];
    for (final mapping in preset.mappings) {
      if (mapping.isNested &&
          mapping.nestedMode == NestedExportMode.expandRows) {
        continue;
      }
      if (_suppressDarwinCoreMapping(mapping)) continue;
      if (!mapping.isNested) {
        final directSource = _directSourceField(mapping.expression);
        if (mapping.textType == 'list' &&
            mapping.listMode == ListExportMode.spreadColumns) {
          final maxCount = sourceRecords.fold<int>(0, (max, record) {
            final count = _listValues(record, mapping).length;
            return count > max ? count : max;
          });
          final items = _listValues(source, mapping);
          for (var index = 0; index < maxCount; index++) {
            values.add(
              index < items.length
                  ? _applyReplacements(mapping, items[index])
                  : '',
            );
          }
        } else if (directSource != null) {
          final value = _formatDarwinCoreScalar(source, mapping);
          final dwc = headerResolver.dwcMappingForSource(directSource);
          if (dwc?.isMeasurement == true) {
            final dynamicUnitSource = dwc?.measurementUnitSource;
            final dynamicUnit = dynamicUnitSource == null
                ? null
                : source[dynamicUnitSource]?.trim();
            values.addAll(
              value.trim().isEmpty
                  ? const ['', '', '']
                  : [
                      dwc!.measurementType!,
                      value,
                      dynamicUnit?.isNotEmpty == true
                          ? dynamicUnit!
                          : dwc.measurementUnit ?? '',
                    ],
            );
          } else {
            final count = headerResolver.headersForSource(directSource).length;
            values.addAll(List<String>.filled(count, value));
          }
        } else {
          values.add(_formatScalar(source, mapping));
        }
        continue;
      }

      final nestedRows = _nestedRows(source, mapping);
      switch (mapping.nestedMode) {
        case NestedExportMode.concatenate:
          if (mapping.nestedFields.length == 1) {
            values.add(
              _applyReplacements(
                mapping,
                formatDarwinCoreList(
                  nestedRows.map(
                    (row) => row[mapping.nestedFields.single] ?? '',
                  ),
                ),
              ),
            );
          } else {
            values.add(
              _applyReplacements(
                mapping,
                nestedRows
                    .map(
                      (row) => mapping.nestedFields
                          .map((field) => row[field] ?? '')
                          .join(mapping.fieldSeparator),
                    )
                    .join(mapping.recordSeparator),
              ),
            );
          }
        case NestedExportMode.spreadColumns:
          final maxCount = sourceRecords.fold<int>(0, (max, record) {
            final count = _nestedRows(record, mapping).length;
            return count > max ? count : max;
          });
          for (var index = 0; index < maxCount; index++) {
            for (final field in mapping.nestedFields) {
              values.add(
                index < nestedRows.length
                    ? _applyReplacements(
                        mapping,
                        nestedRows[index][field] ?? '',
                      )
                    : '',
              );
            }
          }
        case NestedExportMode.expandRows:
          break;
      }
    }
    return values.map(truncateTrailingDecimalZeroText).toList(growable: false);
  }

  bool _suppressDarwinCoreMapping(ExportFieldMapping mapping) {
    if (mapping.isNested) return false;
    final source = _directSourceField(mapping.expression);
    if (source == null) return false;
    final intervalStarts = {
      'collEvent::endDate': 'collEvent::startDate',
      'event::endDate': 'event::startDate',
      'collEvent::endTime': 'collEvent::startTime',
      'event::endTime': 'event::startTime',
    };
    final start = intervalStarts[source];
    if (start != null && _selectedDirectSources().contains(start)) return true;

    if (!_darwinCoreAgentSources.contains(source)) return false;
    final selectedSources = _selectedDirectSources();
    final selectedAgents = _darwinCoreAgentSources
        .where(selectedSources.contains)
        .toList(growable: false);
    return selectedAgents.isNotEmpty && selectedAgents.first != source;
  }

  List<String> _selectedDirectSources() {
    final sources = <String>[];
    for (final mapping in preset.mappings) {
      if (mapping.isNested) continue;
      final source = _directSourceField(mapping.expression);
      if (source != null && !sources.contains(source)) sources.add(source);
    }
    return sources;
  }

  static const List<String> _darwinCoreAgentSources = [
    'collPersonnel::name',
    'collEvent::personnel',
    'event::personnel',
    'specimen::catalogerID',
    'specimen::preparatorID',
    'specimen::collPersonnelID',
    'specimen::collPersonnelId',
  ];

  String _formatDarwinCoreScalar(
    Map<String, String> source,
    ExportFieldMapping mapping,
  ) {
    final directSource = _directSourceField(mapping.expression);
    if (directSource == null) return _formatScalar(source, mapping);

    final intervalEnds = {
      'collEvent::startDate': 'collEvent::endDate',
      'event::startDate': 'event::endDate',
      'collEvent::startTime': 'collEvent::endTime',
      'event::startTime': 'event::endTime',
    };
    final endSource = intervalEnds[directSource];
    if (endSource != null) {
      final start = _sourceValue(source, directSource)?.trim() ?? '';
      final end = _sourceValue(source, endSource)?.trim() ?? '';
      if (start.isNotEmpty && end.isNotEmpty && start != end) {
        return _applyReplacements(mapping, '$start/$end');
      }
      return _applyReplacements(mapping, start.isNotEmpty ? start : end);
    }

    if (_darwinCoreAgentSources.contains(directSource)) {
      final selectedSources = _selectedDirectSources();
      final selectedAgents = _darwinCoreAgentSources
          .where(selectedSources.contains)
          .toList(growable: false);
      final names = <String>[];
      for (final agentSource in selectedAgents) {
        for (final rawValue in splitExportListValue(
          _sourceValue(source, agentSource) ?? '',
        )) {
          final name =
              (agentSource == 'collEvent::personnel' ||
                  agentSource == 'event::personnel')
              ? rawValue.split(';').first.trim()
              : rawValue.trim();
          if (name.isNotEmpty && !names.contains(name)) names.add(name);
        }
      }
      return _applyReplacements(mapping, formatDarwinCoreList(names));
    }
    return _formatScalar(source, mapping);
  }

  List<String> _headers(
    List<Map<String, String>> sourceRecords,
    ExportHeaderResolver headerResolver,
  ) {
    final headers = <String>[];
    for (final mapping in preset.mappings) {
      if (!mapping.isNested) {
        if (mapping.textType == 'list' &&
            mapping.listMode == ListExportMode.spreadColumns) {
          final count = sourceRecords.fold<int>(0, (maxCount, record) {
            final current = _listValues(record, mapping).length;
            return current > maxCount ? current : maxCount;
          });
          for (var index = 1; index <= count; index++) {
            headers.add(
              formatIndexedExportHeader(
                headerResolver.headerFor(mapping),
                index,
                mapping.indexedHeaderStyle,
              ),
            );
          }
        } else {
          headers.add(headerResolver.headerFor(mapping));
        }
        continue;
      }

      final fields = mapping.nestedFields;
      if (mapping.nestedMode == NestedExportMode.concatenate) {
        headers.add(headerResolver.headerFor(mapping));
      } else if (mapping.nestedMode == NestedExportMode.expandRows) {
        headers.addAll(
          fields.map((field) => headerResolver.nestedHeader(mapping, field)),
        );
      } else {
        final count = sourceRecords.fold<int>(0, (maxCount, record) {
          final current = _nestedRows(record, mapping).length;
          return current > maxCount ? current : maxCount;
        });
        for (var index = 1; index <= count; index++) {
          headers.addAll(
            fields.map(
              (field) =>
                  headerResolver.nestedHeader(mapping, field, index: index),
            ),
          );
        }
      }
    }
    return headers;
  }

  List<Map<String, String>> _mapRecord(
    Map<String, String> source,
    List<String> headers,
    ExportHeaderResolver headerResolver,
  ) {
    final base = <String, String>{};
    for (final mapping in preset.mappings.where((item) => !item.isNested)) {
      if (mapping.textType == 'list' &&
          mapping.listMode == ListExportMode.spreadColumns) {
        final values = _listValues(source, mapping);
        for (var index = 0; index < values.length; index++) {
          base[formatIndexedExportHeader(
            headerResolver.headerFor(mapping),
            index + 1,
            mapping.indexedHeaderStyle,
          )] = _applyReplacements(
            mapping,
            values[index],
          );
        }
      } else {
        base[headerResolver.headerFor(mapping)] = _formatScalar(
          source,
          mapping,
        );
      }
    }

    ExportFieldMapping? rowMapping;
    for (final mapping in preset.mappings.where((item) => item.isNested)) {
      final nestedRows = _nestedRows(source, mapping);
      switch (mapping.nestedMode) {
        case NestedExportMode.concatenate:
          final header = headerResolver.headerFor(mapping);
          if (preset.headerFormat == ExportHeaderFormat.darwinCore &&
              mapping.nestedFields.length == 1) {
            final field = mapping.nestedFields.single;
            base[header] = _applyReplacements(
              mapping,
              formatDarwinCoreList(nestedRows.map((row) => row[field] ?? '')),
            );
          } else {
            base[header] = _applyReplacements(
              mapping,
              nestedRows
                  .map(
                    (row) => mapping.nestedFields
                        .map((field) => row[field] ?? '')
                        .join(mapping.fieldSeparator),
                  )
                  .join(mapping.recordSeparator),
            );
          }
        case NestedExportMode.spreadColumns:
          for (var index = 0; index < nestedRows.length; index++) {
            for (final field in mapping.nestedFields) {
              base[headerResolver.nestedHeader(
                mapping,
                field,
                index: index + 1,
              )] = _applyReplacements(
                mapping,
                nestedRows[index][field] ?? '',
              );
            }
          }
        case NestedExportMode.expandRows:
          rowMapping = mapping;
      }
    }

    if (rowMapping == null) return [_fillHeaders(base, headers)];
    final expansionMapping = rowMapping;
    final nestedRows = _nestedRows(source, expansionMapping);
    if (nestedRows.isEmpty) return [_fillHeaders(base, headers)];
    return nestedRows
        .map((nested) {
          final row = Map<String, String>.from(base);
          for (final field in expansionMapping.nestedFields) {
            row[headerResolver.nestedHeader(expansionMapping, field)] =
                _applyReplacements(expansionMapping, nested[field] ?? '');
          }
          return _fillHeaders(row, headers);
        })
        .toList(growable: false);
  }

  Map<String, String> _fillHeaders(
    Map<String, String> row,
    List<String> headers,
  ) {
    for (final header in headers) {
      row.putIfAbsent(header, () => '');
    }
    return row.map(
      (header, value) =>
          MapEntry(header, truncateTrailingDecimalZeroText(value)),
    );
  }

  String _formatScalar(Map<String, String> source, ExportFieldMapping mapping) {
    if (mapping.textType == 'list' &&
        mapping.listMode == ListExportMode.concatenate) {
      final values = _listValues(source, mapping);
      return _applyReplacements(
        mapping,
        preset.headerFormat == ExportHeaderFormat.darwinCore
            ? formatDarwinCoreList(values)
            : formatTemplateListItems(values, mapping.formatOption),
      );
    }
    final isConditional =
        mapping.textType == kConditionalBracketExportTextType ||
        isConditionalReplacementExportTextType(mapping.textType);
    final effectiveTextType = isConditional ? 'normal' : mapping.textType;
    final substituted = resolveDocumentTemplatePlaceholders(
      text: mapping.expression,
      data: source,
      caseFormat: mapping.caseFormat,
      nullFallbackOption: mapping.nullFallbackOption,
      customNullFallbackText: mapping.customNullFallbackText,
      textType: effectiveTextType,
      formatOption: mapping.formatOption,
    );
    final formatted = formatTemplateText(
      substituted,
      effectiveTextType,
      mapping.formatOption,
      mapping.caseFormat,
    );
    if (!isConditional) {
      return _applyReplacements(mapping, formatted);
    }
    final target = _directSourceField(mapping.expression);
    if (target == null ||
        (_sourceValue(source, target)?.trim().isEmpty ?? true)) {
      return _applyReplacements(mapping, formatted);
    }
    final conditions = mapping.textType == kConditionalValueExportTextType
        ? mapping.bracketConditions
              .map((condition) => condition.copyWith(sourceField: target))
              .toList(growable: false)
        : mapping.bracketConditions;
    final matches = conditionalBracketConditionsMatch(
      conditions,
      mapping.bracketConditionMode,
      (field) => _sourceValue(source, field),
    );
    if (!matches) return _applyReplacements(mapping, formatted);
    if (mapping.textType == kConditionalBracketExportTextType) {
      return _applyReplacements(mapping, addConditionalBrackets(formatted));
    }
    return _applyReplacements(mapping, mapping.conditionalText);
  }

  String _applyReplacements(ExportFieldMapping mapping, String value) {
    return applyTextReplacementRules(
      truncateTrailingDecimalZeroText(value),
      mapping.replacementRules,
    );
  }

  String? _directSourceField(String expression) {
    return RegExp(
      r'^\s*\[([^\]]+)\]\s*$',
    ).firstMatch(expression)?.group(1)?.trim();
  }

  String? _sourceValue(Map<String, String> source, String field) {
    if (source.containsKey(field)) return source[field];
    final lower = field.toLowerCase();
    for (final entry in source.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    final short = field.contains('::') ? field.split('::').last : field;
    for (final entry in source.entries) {
      if (entry.key.split('::').last.toLowerCase() == short.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }

  List<String> _listValues(
    Map<String, String> source,
    ExportFieldMapping mapping,
  ) {
    final substituted = substituteDocumentPlaceholders(
      mapping.expression,
      source,
      nullFallbackOption: mapping.nullFallbackOption,
      customNullFallbackText: mapping.customNullFallbackText,
    );
    if (substituted.isEmpty) return const [];
    return splitExportListValue(substituted);
  }

  List<Map<String, String>> _nestedRows(
    Map<String, String> source,
    ExportFieldMapping mapping,
  ) {
    final values = mapping.nestedFields
        .map((field) {
          final key = '${mapping.nestedNamespace}::$field';
          return splitExportListValue(source[key] ?? '');
        })
        .toList(growable: false);
    final count = values.fold<int>(
      0,
      (max, value) => value.length > max ? value.length : max,
    );
    if (count == 0 ||
        values.every((value) => value.every((item) => item.isEmpty))) {
      return const [];
    }
    return List.generate(
      count,
      (index) => {
        for (
          var fieldIndex = 0;
          fieldIndex < mapping.nestedFields.length;
          fieldIndex++
        )
          mapping.nestedFields[fieldIndex]: index < values[fieldIndex].length
              ? values[fieldIndex][index]
              : '',
      },
      growable: false,
    );
  }

  void _ensureUniqueHeaders(List<String> headers) {
    final seen = <String>{};
    for (final header in headers) {
      if (!seen.add(header.toLowerCase())) {
        throw ArgumentError('Export headers must be unique: $header.');
      }
    }
  }
}

List<String> validateExportPreset(ExportPresetModel preset) {
  final errors = <String>[];
  if (preset.mappings.isEmpty) errors.add('Add at least one export mapping.');
  final headers = <String>{};
  for (final mapping in preset.mappings) {
    if (mapping.isNested) {
      if (mapping.nestedFields.isEmpty) {
        errors.add('Nested mappings must include at least one child field.');
      }
      if (mapping.nestedMode == NestedExportMode.concatenate &&
          (mapping.fieldSeparator.isEmpty || mapping.recordSeparator.isEmpty) &&
          !(preset.headerFormat == ExportHeaderFormat.darwinCore &&
              mapping.nestedFields.length == 1)) {
        errors.add('Nested separators cannot be empty.');
      }
    } else if (mapping.expression.trim().isEmpty) {
      errors.add('Scalar mappings require a source expression.');
    } else if (mapping.textType == kConditionalBracketExportTextType ||
        isConditionalReplacementExportTextType(mapping.textType)) {
      final directSource = RegExp(
        r'^\s*\[[^\]]+\]\s*$',
      ).hasMatch(mapping.expression);
      if (!directSource) {
        errors.add('Conditional output requires exactly one source field.');
      }
      if (mapping.bracketConditions.isEmpty) {
        errors.add('Add at least one condition.');
      }
      if (isConditionalReplacementExportTextType(mapping.textType) &&
          mapping.conditionalText.isEmpty) {
        errors.add('Enter conditional replacement text.');
      }
      for (final condition in mapping.bracketConditions) {
        if (mapping.textType != kConditionalValueExportTextType &&
            condition.sourceField.trim().isEmpty) {
          errors.add('Choose a controlling field for every bracket condition.');
        }
        if (condition.comparisonValue.trim().isEmpty) {
          errors.add('Enter a comparison value for every bracket condition.');
        }
        final target = RegExp(
          r'^\s*\[([^\]]+)\]\s*$',
        ).firstMatch(mapping.expression)?.group(1)?.trim();
        if (mapping.textType != kConditionalValueExportTextType &&
            target != null &&
            condition.sourceField.trim().toLowerCase() ==
                target.toLowerCase()) {
          errors.add('A conditional field cannot depend on itself.');
        }
      }
    } else if (mapping.textType == 'list' &&
        mapping.listMode == ListExportMode.spreadColumns &&
        !RegExp(r'^\s*\[[^\]]+\]\s*$').hasMatch(mapping.expression)) {
      errors.add('Indexed list mappings require exactly one source field.');
    }
    for (var index = 0; index < mapping.replacementRules.length; index++) {
      final error = validateTextReplacementRule(
        mapping.replacementRules[index],
      );
      if (error != null) {
        errors.add('Replacement rule ${index + 1}: $error');
      }
    }
    if (mappingRequiresHeaderOverride(preset.headerFormat, mapping)) {
      errors.add(
        'Standardized header modes require a custom header for composite mappings.',
      );
    }
    final header = mapping.headerOverride?.trim();
    if (header != null &&
        header.isNotEmpty &&
        !headers.add(header.toLowerCase())) {
      errors.add('Export headers must be unique.');
    }
  }
  if (preset.mappings
          .where(
            (mapping) =>
                mapping.isNested &&
                mapping.nestedMode == NestedExportMode.expandRows,
          )
          .length >
      1) {
    errors.add('Only one nested mapping can expand export rows.');
  }
  return errors;
}
