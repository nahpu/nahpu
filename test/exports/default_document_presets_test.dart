import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/document_layout_service.dart';

void main() {
  group('default document presets', () {
    for (final path in ['assets/configs/basic.json']) {
      test('$path parses and references bundled templates', () {
        final decoded = jsonDecode(File(path).readAsStringSync());
        final preset = Map<String, dynamic>.from(decoded as Map);

        final templates = (preset['template_presets'] as List)
            .map(
              (json) => Template.fromJson(
                Map<String, dynamic>.from((json as Map)['value'] as Map),
              ),
            )
            .toList();
        final templateNames = templates.map((t) => t.name).toSet();

        final layouts = (preset['document_layouts'] as List)
            .map(
              (json) => DocumentLayoutPresetJson.fromJson(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .toList();

        expect(preset['schema_version'], 3);
        expect(
          preset['included_sections'],
          containsAll(['template_presets', 'document_layouts']),
        );
        expect(templates, hasLength(7));
        expect(layouts, hasLength(8));
        expect(
          templateNames,
          containsAll([
            'Classic Event',
            'Classic Site',
            'Classic Specimen - General Mammals',
            'Classic Tissue Part Label',
            'new-specimen-tag',
            'skull-tag',
            'specimen-tag',
          ]),
        );

        for (final layout in layouts) {
          expect(layout.blocks, isNotEmpty);
          for (final block in layout.blocks) {
            expect(templateNames, contains(block.templateName));
          }
        }
      });
    }
  });
}
