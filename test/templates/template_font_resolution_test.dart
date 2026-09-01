import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/font_registry.dart';
import 'package:nahpu/services/templates/template_font_resolution_service.dart';
import 'package:nahpu/services/types/user_fonts.dart';

void main() {
  const resolver = TemplateFontResolutionService();
  const registry = FontRegistry();

  CustomTextElement text(String id, String fontFamily) => CustomTextElement(
    id: id,
    text: 'Sample',
    xMm: 0,
    yMm: 0,
    fontFamily: fontFamily,
  );

  Template templateWith({
    List<CustomTextElement> page1 = const [],
    List<CustomTextElement> page2 = const [],
    String name = 'Tag',
  }) => DefaultTemplate.defaultTemplate(name).copyWith(
    page1: TemplatePage(customTexts: page1),
    page2: TemplatePage(customTexts: page2),
  );

  group('missingFamilies', () {
    test('bundled families are never missing', () {
      final template = templateWith(
        page1: [text('a', 'Merriweather'), text('b', 'DejaVu Sans')],
      );

      expect(resolver.missingFamilies([template], registry), isEmpty);
    });

    test('legacy compact keys resolve to their bundled family', () {
      final template = templateWith(
        page1: [text('a', 'LibertinusSerif'), text('b', 'PlusJakartaSans')],
      );

      expect(resolver.missingFamilies([template], registry), isEmpty);
    });

    test('an empty family means the default and is never missing', () {
      final template = templateWith(page1: [text('a', '')]);

      expect(resolver.missingFamilies([template], registry), isEmpty);
    });

    test('reports families this installation does not have', () {
      final template = templateWith(
        page1: [text('a', 'Roboto')],
        page2: [text('b', 'Lato'), text('c', 'Merriweather')],
      );

      expect(resolver.missingFamilies([template], registry), <String>{
        'Roboto',
        'Lato',
      });
    });

    test('a family is reported once across several templates', () {
      final templates = [
        templateWith(page1: [text('a', 'Roboto')], name: 'One'),
        templateWith(page1: [text('b', 'Roboto')], name: 'Two'),
      ];

      expect(resolver.missingFamilies(templates, registry), <String>{'Roboto'});
    });

    test('an installed user font is not missing', () {
      final withUserFont = FontRegistry(
        userFonts: [
          UserFont(id: 'x', family: 'Roboto', addedAt: DateTime.utc(2026)),
        ],
      );
      final template = templateWith(page1: [text('a', 'Roboto')]);

      expect(resolver.missingFamilies([template], withUserFont), isEmpty);
    });
  });

  group('applySubstitutions', () {
    test('rewrites the family on both pages', () {
      final template = templateWith(
        page1: [text('a', 'Roboto'), text('b', 'Merriweather')],
        page2: [text('c', 'Roboto')],
      );

      final resolved = resolver.applySubstitutions(template, {
        'Roboto': 'Merriweather',
      });

      expect(resolved.page1.customTexts.map((t) => t.fontFamily), [
        'Merriweather',
        'Merriweather',
      ]);
      expect(resolved.page2.customTexts.single.fontFamily, 'Merriweather');
    });

    test('leaves untouched families and other properties alone', () {
      final template = templateWith(
        page1: [text('a', 'Roboto'), text('b', 'DejaVu Serif')],
      );

      final resolved = resolver.applySubstitutions(template, {
        'Roboto': 'Libertinus Serif',
      });

      expect(resolved.page1.customTexts[1].fontFamily, 'DejaVu Serif');
      expect(resolved.page1.customTexts[0].id, 'a');
      expect(resolved.page1.customTexts[0].text, 'Sample');
      expect(resolved.name, 'Tag');
    });

    test('matches a stored compact key against a spelled-out substitution', () {
      final template = templateWith(page1: [text('a', 'SourceSans3')]);

      final resolved = resolver.applySubstitutions(template, {
        'Source Sans 3': 'Merriweather',
      });

      expect(resolved.page1.customTexts.single.fontFamily, 'Merriweather');
    });

    test('an empty substitution map returns the same template', () {
      final template = templateWith(page1: [text('a', 'Roboto')]);

      expect(
        identical(resolver.applySubstitutions(template, {}), template),
        isTrue,
      );
    });

    test('applies to every template in a batch', () {
      final templates = [
        templateWith(page1: [text('a', 'Roboto')], name: 'One'),
        templateWith(page1: [text('b', 'Roboto')], name: 'Two'),
      ];

      final resolved = resolver.applySubstitutionsToAll(templates, {
        'Roboto': 'Merriweather',
      });

      expect(resolved.map((t) => t.page1.customTexts.single.fontFamily), [
        'Merriweather',
        'Merriweather',
      ]);
      expect(resolver.missingFamilies(resolved, registry), isEmpty);
    });
  });
}
