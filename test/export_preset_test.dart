import 'package:flutter_test/flutter_test.dart';
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
            textType: 'normal',
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
      expect(restored.mappings.last.nestedMode, NestedExportMode.spreadColumns);
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
  });
}
