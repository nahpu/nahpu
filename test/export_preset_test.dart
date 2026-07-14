import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/conditional_brackets.dart';
import 'package:nahpu/services/export/preset_record_exporter.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  group('ExportPresetModel', () {
    test('round trips the versioned preset mapping schema', () {
      const preset = ExportPresetModel(
        recordType: RecordType.specimenRecord,
        specimenRecordType: SpecimenRecordType.birds,
        headerFormat: ExportHeaderFormat.fieldName,
        mappings: [
          ExportFieldMapping(
            expression: '[specimen::catalogNum]',
            headerOverride: 'Catalog number',
            textType: 'list',
            listMode: ListExportMode.spreadColumns,
            indexedHeaderStyle: IndexedHeaderStyle.brackets,
            bracketConditions: [
              ConditionalBracketCondition(
                sourceField: 'specimen::catalogNum',
                operator: ConditionalComparisonOperator.notEquals,
                comparisonValue: '',
              ),
            ],
          ),
          ExportFieldMapping(
            expression: '',
            nestedNamespace: 'coordinate',
            nestedFields: ['decimalLatitude', 'decimalLongitude'],
            nestedMode: NestedExportMode.spreadColumns,
          ),
        ],
      );

      final restored = ExportPresetModel.fromJson(preset.toJson());
      expect(restored.schemaVersion, recordExportPresetSchemaVersion);
      expect(restored.recordType, RecordType.specimenRecord);
      expect(restored.specimenRecordType, SpecimenRecordType.birds);
      expect(restored.mappings, hasLength(2));
      expect(restored.mappings.first.listMode, ListExportMode.spreadColumns);
      expect(restored.mappings.first.indexedHeaderStyle,
          IndexedHeaderStyle.brackets);
      expect(restored.mappings.first.bracketConditions, hasLength(1));
      expect(restored.mappings.last.nestedMode, NestedExportMode.spreadColumns);
    });

    test('migrates schema version 2 mappings with compatible defaults', () {
      final restored = ExportPresetModel.fromJson({
        'schemaVersion': 2,
        'recordType': 'site',
        'specimenRecordType': 'allTaxa',
        'headerFormat': 'fieldName',
        'mappings': [
          {
            'expression': '[site::habitatType]',
            'textType': 'list',
            'formatOption': 'comma',
          },
        ],
      });

      expect(restored.schemaVersion, recordExportPresetSchemaVersion);
      expect(restored.mappings.single.listMode, ListExportMode.concatenate);
      expect(restored.mappings.single.indexedHeaderStyle,
          IndexedHeaderStyle.underscore);
    });

    test('rejects the removed legacy schema', () {
      expect(
        () => ExportPresetModel.fromJson({'fields': {}}),
        throwsFormatException,
      );
    });

    test('validates one row-expanding nested mapping at most', () {
      const nested = ExportFieldMapping(
        expression: '',
        nestedNamespace: 'coordinate',
        nestedFields: ['decimalLatitude'],
        nestedMode: NestedExportMode.expandRows,
      );
      const preset = ExportPresetModel(
        recordType: RecordType.site,
        specimenRecordType: SpecimenRecordType.allTaxa,
        headerFormat: ExportHeaderFormat.fieldName,
        mappings: [nested, nested],
      );

      expect(validateExportPreset(preset),
          contains('Only one nested mapping can expand export rows.'));
    });

    test('indexed lists require one source placeholder', () {
      const preset = ExportPresetModel(
        recordType: RecordType.site,
        specimenRecordType: SpecimenRecordType.allTaxa,
        headerFormat: ExportHeaderFormat.fieldName,
        mappings: [
          ExportFieldMapping(
            expression: 'Prefix [site::habitatType]',
            textType: 'list',
            listMode: ListExportMode.spreadColumns,
          ),
        ],
      );

      expect(validateExportPreset(preset),
          contains('Indexed list mappings require exactly one source field.'));
    });
  });

  group('indexed list export helpers', () {
    test('formats every supported indexed header style', () {
      expect(
        formatIndexedExportHeader('method', 2, IndexedHeaderStyle.underscore),
        'method_2',
      );
      expect(
        formatIndexedExportHeader('method', 2, IndexedHeaderStyle.compact),
        'method2',
      );
      expect(
        formatIndexedExportHeader('method', 2, IndexedHeaderStyle.brackets),
        'method[2]',
      );
    });

    test('preserves blank positions when splitting repeated values', () {
      expect(splitExportListValue('A | | C'), ['A', '', 'C']);
      expect(splitExportListValue(''), isEmpty);
    });
  });
}
