import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/conditional_brackets.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/templates/template_model.dart'
    show formatTemplateText, truncateTrailingDecimalZeroText;
import 'package:nahpu/src/rust/api/export.dart';

class PresetExportPreviewData {
  const PresetExportPreviewData({required this.headers, required this.rows});
  final List<String> headers;
  final List<Map<String, String>> rows;
}

/// Formats a one-based index using the style selected for an export mapping.
String formatIndexedExportHeader(
  String base,
  int index,
  IndexedHeaderStyle style,
) {
  return switch (style) {
    IndexedHeaderStyle.underscore => '${base}_$index',
    IndexedHeaderStyle.compact => '$base$index',
    IndexedHeaderStyle.brackets => '$base[$index]',
  };
}

/// Splits NAHPU's pipe-delimited repeated values without losing empty slots.
List<String> splitExportListValue(String value) {
  if (value.isEmpty) return const [];
  return value.split('|').map((item) => item.trim()).toList(growable: false);
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
    final headers = _headers(sourceRecords);
    _ensureUniqueHeaders(headers);
    final rows = <Map<String, String>>[];
    for (final source in sourceRecords) {
      rows.addAll(_mapRecord(source, headers));
    }
    return PresetExportPreviewData(headers: headers, rows: rows);
  }

  Future<void> write(File file, ExportFmt format) async {
    final errors = validateExportPreset(preset);
    if (errors.isNotEmpty) throw ArgumentError(errors.join('\n'));

    final sourceRecords = await _sourceRecords();
    final headers = _headers(sourceRecords);
    _ensureUniqueHeaders(headers);
    final rows = <Map<String, String>>[];
    for (final source in sourceRecords) {
      rows.addAll(_mapRecord(source, headers));
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
        return Future.wait(specimens.map(
          (specimen) => documentFieldValuesForSpecimen(db, specimen, ref),
        ));
      case RecordType.site:
        final sites = await SiteServices(ref: ref).getAllSites();
        return Future.wait(sites.map(
          (site) => documentFieldValuesForSite(db, site, ref),
        ));
      case RecordType.collEvent:
        final events = await CollEventServices(ref: ref).getAllCollEvents();
        return Future.wait(events.map(
          (event) => documentFieldValuesForCollEvent(db, event, ref),
        ));
      case RecordType.narrative:
        final narratives = await NarrativeServices(ref: ref).getAllNarrative();
        return Future.wait(narratives.map(
          (narrative) => documentFieldValuesForNarrative(db, narrative, ref),
        ));
      case RecordType.specimenParts:
        final parts =
            await SpecimenPartServices(ref: ref).getProjectSpecimenParts();
        return Future.wait(parts.map(
          (part) => documentFieldValuesForSpecimenPart(db, part, ref),
        ));
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

  List<String> _headers(List<Map<String, String>> sourceRecords) {
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
            headers.add(formatIndexedExportHeader(
              _headerFor(mapping),
              index,
              mapping.indexedHeaderStyle,
            ));
          }
        } else {
          headers.add(_headerFor(mapping));
        }
        continue;
      }

      final fields = mapping.nestedFields;
      if (mapping.nestedMode == NestedExportMode.concatenate) {
        headers.add(_headerFor(mapping));
      } else if (mapping.nestedMode == NestedExportMode.expandRows) {
        headers.addAll(fields.map((field) => _nestedHeader(mapping, field)));
      } else {
        final count = sourceRecords.fold<int>(0, (maxCount, record) {
          final current = _nestedRows(record, mapping).length;
          return current > maxCount ? current : maxCount;
        });
        for (var index = 1; index <= count; index++) {
          headers.addAll(fields.map(
            (field) => _nestedHeader(mapping, field, index: index),
          ));
        }
      }
    }
    return headers;
  }

  List<Map<String, String>> _mapRecord(
    Map<String, String> source,
    List<String> headers,
  ) {
    final base = <String, String>{};
    for (final mapping in preset.mappings.where((item) => !item.isNested)) {
      if (mapping.textType == 'list' &&
          mapping.listMode == ListExportMode.spreadColumns) {
        final values = _listValues(source, mapping);
        for (var index = 0; index < values.length; index++) {
          base[formatIndexedExportHeader(
            _headerFor(mapping),
            index + 1,
            mapping.indexedHeaderStyle,
          )] = values[index];
        }
      } else {
        base[_headerFor(mapping)] = _formatScalar(source, mapping);
      }
    }

    ExportFieldMapping? rowMapping;
    for (final mapping in preset.mappings.where((item) => item.isNested)) {
      final nestedRows = _nestedRows(source, mapping);
      switch (mapping.nestedMode) {
        case NestedExportMode.concatenate:
          base[_headerFor(mapping)] = nestedRows
              .map((row) => mapping.nestedFields
                  .map((field) => row[field] ?? '')
                  .join(mapping.fieldSeparator))
              .join(mapping.recordSeparator);
        case NestedExportMode.spreadColumns:
          for (var index = 0; index < nestedRows.length; index++) {
            for (final field in mapping.nestedFields) {
              base[_nestedHeader(mapping, field, index: index + 1)] =
                  nestedRows[index][field] ?? '';
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
    return nestedRows.map((nested) {
      final row = Map<String, String>.from(base);
      for (final field in expansionMapping.nestedFields) {
        row[_nestedHeader(expansionMapping, field)] = nested[field] ?? '';
      }
      return _fillHeaders(row, headers);
    }).toList(growable: false);
  }

  Map<String, String> _fillHeaders(
      Map<String, String> row, List<String> headers) {
    for (final header in headers) {
      row.putIfAbsent(header, () => '');
    }
    return row.map(
      (header, value) => MapEntry(
        header,
        truncateTrailingDecimalZeroText(value),
      ),
    );
  }

  String _formatScalar(Map<String, String> source, ExportFieldMapping mapping) {
    final effectiveTextType =
        mapping.textType == kConditionalBracketExportTextType
            ? 'normal'
            : mapping.textType;
    final substituted = substituteDocumentPlaceholders(
      mapping.expression,
      source,
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
    if (mapping.textType != kConditionalBracketExportTextType) {
      return formatted;
    }
    final target = _directSourceField(mapping.expression);
    if (target == null ||
        (_sourceValue(source, target)?.trim().isEmpty ?? true)) {
      return formatted;
    }
    final matches = conditionalBracketConditionsMatch(
      mapping.bracketConditions,
      mapping.bracketConditionMode,
      (field) => _sourceValue(source, field),
    );
    return matches ? addConditionalBrackets(formatted) : formatted;
  }

  String? _directSourceField(String expression) {
    return RegExp(r'^\s*\[([^\]]+)\]\s*$')
        .firstMatch(expression)
        ?.group(1)
        ?.trim();
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
    final values = mapping.nestedFields.map((field) {
      final key = '${mapping.nestedNamespace}::$field';
      return splitExportListValue(source[key] ?? '');
    }).toList(growable: false);
    final count = values.fold<int>(
        0, (max, value) => value.length > max ? value.length : max);
    if (count == 0 ||
        values.every((value) => value.every((item) => item.isEmpty))) {
      return const [];
    }
    return List.generate(
      count,
      (index) => {
        for (var fieldIndex = 0;
            fieldIndex < mapping.nestedFields.length;
            fieldIndex++)
          mapping.nestedFields[fieldIndex]: index < values[fieldIndex].length
              ? values[fieldIndex][index]
              : '',
      },
      growable: false,
    );
  }

  String _headerFor(ExportFieldMapping mapping) {
    final override = mapping.headerOverride?.trim();
    if (override != null && override.isNotEmpty) return override;
    if (mapping.isNested) return mapping.nestedNamespace!;
    final match = RegExp(r'\[([^\]?\s]+)').firstMatch(mapping.expression);
    final key = match?.group(1) ?? mapping.expression.trim();
    if (preset.headerFormat == ExportHeaderFormat.fieldName) {
      return key.split('::').last;
    }
    return key;
  }

  String _nestedHeader(
    ExportFieldMapping mapping,
    String field, {
    int? index,
  }) {
    final prefix = mapping.headerOverride?.trim().isNotEmpty == true
        ? mapping.headerOverride!.trim()
        : mapping.nestedNamespace!;
    final fieldName = preset.headerFormat == ExportHeaderFormat.fieldName
        ? field
        : '${mapping.nestedNamespace}::$field';
    return index == null
        ? '${prefix}_$fieldName'
        : '${formatIndexedExportHeader(prefix, index, mapping.indexedHeaderStyle)}_'
            '$fieldName';
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
          (mapping.fieldSeparator.isEmpty || mapping.recordSeparator.isEmpty)) {
        errors.add('Nested separators cannot be empty.');
      }
    } else if (mapping.expression.trim().isEmpty) {
      errors.add('Scalar mappings require a source expression.');
    } else if (mapping.textType == kConditionalBracketExportTextType) {
      final directSource =
          RegExp(r'^\s*\[[^\]]+\]\s*$').hasMatch(mapping.expression);
      if (!directSource) {
        errors.add('Conditional brackets require exactly one source field.');
      }
      if (mapping.bracketConditions.isEmpty) {
        errors.add('Add at least one bracket condition.');
      }
      for (final condition in mapping.bracketConditions) {
        if (condition.sourceField.trim().isEmpty) {
          errors.add('Choose a controlling field for every bracket condition.');
        }
        if (condition.comparisonValue.trim().isEmpty) {
          errors.add('Enter a comparison value for every bracket condition.');
        }
        final target = RegExp(r'^\s*\[([^\]]+)\]\s*$')
            .firstMatch(mapping.expression)
            ?.group(1)
            ?.trim();
        if (target != null &&
            condition.sourceField.trim().toLowerCase() ==
                target.toLowerCase()) {
          errors.add('A measurement cannot depend on itself.');
        }
      }
    } else if (mapping.textType == 'list' &&
        mapping.listMode == ListExportMode.spreadColumns &&
        !RegExp(r'^\s*\[[^\]]+\]\s*$').hasMatch(mapping.expression)) {
      errors.add('Indexed list mappings require exactly one source field.');
    }
    final header = mapping.headerOverride?.trim();
    if (header != null &&
        header.isNotEmpty &&
        !headers.add(header.toLowerCase())) {
      errors.add('Export headers must be unique.');
    }
  }
  if (preset.mappings
          .where((mapping) =>
              mapping.isNested &&
              mapping.nestedMode == NestedExportMode.expandRows)
          .length >
      1) {
    errors.add('Only one nested mapping can expand export rows.');
  }
  return errors;
}
