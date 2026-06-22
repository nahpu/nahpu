import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  group('ExportPresetModel Parsing Tests', () {
    test('Can parse v1 format correctly', () {
      final v1Json = {
        'fields': {
          'specimen::catalogerID': 'Cataloger',
          'specimen::speciesID': 'Species',
        }
      };

      final preset = ExportPresetModel.fromJson(v1Json);
      expect(preset.fields.length, 2);
      expect(preset.fields['specimen::catalogerID'], 'Cataloger');
      expect(preset.combinedFields.isEmpty, true);
    });

    test('Can parse v2 format correctly', () {
      final v2Json = {
        'fields': {
          'specimen::catalogerID': 'Cataloger',
        },
        'combined': [
          {
            'fieldId': 'Combined1',
            'fields': ['specimen::speciesID', 'SEP:-', 'specimen::condition']
          }
        ]
      };

      final preset = ExportPresetModel.fromJson(v2Json);
      expect(preset.fields.length, 1);
      expect(preset.combinedFields.length, 1);
      expect(preset.combinedFields.first.fieldId, 'Combined1');
      expect(preset.combinedFields.first.fields.length, 3);
      expect(preset.combinedFields.first.fields[1], 'SEP:-');
    });

    test('Can serialize to json correctly', () {
      final preset = ExportPresetModel(
        fields: {'table::col1': 'Name1'},
        combinedFields: [
          CombinedField(fieldId: 'Combo', fields: ['table::col1', 'SEP: '])
        ],
      );

      final json = preset.toJson();
      expect(json['fields']['table::col1'], 'Name1');
      expect((json['combined'] as List).length, 1);
      expect((json['combined'] as List)[0]['fieldId'], 'Combo');
    });
  });
}
