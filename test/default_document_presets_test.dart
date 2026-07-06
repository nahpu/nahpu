import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/document_layout_service.dart';

void main() {
  group('default document presets', () {
    for (final path in [
      'assets/configs/classic.json',
      'assets/configs/modern.json',
    ]) {
      test('$path parses and references bundled templates', () {
        final decoded = jsonDecode(File(path).readAsStringSync());
        final preset = Map<String, dynamic>.from(decoded as Map);

        final templates = (preset['templates'] as List)
            .map((json) => Template.fromJson(
                  Map<String, dynamic>.from(json as Map),
                ))
            .toList();
        final templateNames = templates.map((t) => t.name).toSet();

        final layouts = (preset['layouts'] as List)
            .map((json) => DocumentLayoutPresetJson.fromJson(
                  Map<String, dynamic>.from(json as Map),
                ))
            .toList();

        expect(templates, hasLength(7));
        expect(layouts, hasLength(7));
        expect(
          templateNames.where((name) => name.contains('Specimen -')),
          hasLength(4),
        );
        expect(
          templateNames,
          containsAll([
            '${preset['name']} Narrative',
            '${preset['name']} Site',
            '${preset['name']} Event',
            '${preset['name']} Specimen - General Mammals',
            '${preset['name']} Specimen - Bats',
            '${preset['name']} Specimen - Birds',
            '${preset['name']} Specimen - Herpetofauna',
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
