import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/template_transfer_service.dart';
import 'package:path/path.dart' as p;

void main() {
  const transfer = TemplateTransferService();

  Template template(String name, {String font = 'Merriweather'}) =>
      DefaultTemplate.defaultTemplate(name).copyWith(
        page1: TemplatePage(
          customTexts: [
            CustomTextElement(
              id: 'a',
              text: name,
              xMm: 1,
              yMm: 2,
              fontFamily: font,
            ),
          ],
        ),
      );

  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('nahpu-transfer'));
  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  group('encode', () {
    test('one template uses the same name-keyed envelope as many', () {
      final single = jsonDecode(transfer.encode([template('Tag')])) as Map;
      final many =
          jsonDecode(transfer.encode([template('Tag'), template('Label')]))
              as Map;

      expect(single.keys, ['Tag']);
      expect(many.keys, containsAll(<String>['Tag', 'Label']));
      expect(single['Tag'], many['Tag']);
    });
  });

  group('decode', () {
    test('round-trips a single template', () {
      final decoded = transfer.decode(transfer.encode([template('Tag')]));

      expect(decoded, hasLength(1));
      expect(decoded.single.name, 'Tag');
      expect(decoded.single.page1.customTexts.single.text, 'Tag');
    });

    test('round-trips several templates', () {
      final decoded = transfer.decode(
        transfer.encode([template('Tag'), template('Label')]),
      );

      expect(decoded.map((t) => t.name), containsAll(<String>['Tag', 'Label']));
    });

    test('accepts a bare template, as written by older exports', () {
      final decoded = transfer.decode(template('Legacy').toJsonString());

      expect(decoded, hasLength(1));
      expect(decoded.single.name, 'Legacy');
    });

    test('falls back to the map key when the body has no name', () {
      final body = template('Tag').toJson()..['name'] = '';
      final decoded = transfer.decode(jsonEncode({'From key': body}));

      expect(decoded.single.name, 'From key');
    });

    test('rejects a JSON array', () {
      expect(() => transfer.decode('[]'), throwsA(isA<FormatException>()));
    });

    test('rejects an object with no templates', () {
      expect(
        () => transfer.decode('{"a": 1}'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('uniqueName', () {
    test('keeps a free name', () {
      expect(transfer.uniqueName('Tag', {'Label'}), 'Tag');
    });

    test('suffixes until the name is free', () {
      expect(transfer.uniqueName('Tag', {'Tag'}), 'Tag_1');
      expect(transfer.uniqueName('Tag', {'Tag', 'Tag_1'}), 'Tag_2');
    });

    test('an empty name becomes Imported', () {
      expect(transfer.uniqueName('   ', {}), 'Imported');
    });

    test('trims before comparing', () {
      expect(transfer.uniqueName('  Tag  ', {'Tag'}), 'Tag_1');
    });
  });

  group('files', () {
    test('a written file reads back as the same templates', () async {
      final file = File(p.join(tempDir.path, 'templates.json'));
      await transfer.writeFile(file, [template('Tag'), template('Label')]);

      final read = await transfer.readFile(file);

      expect(read.map((t) => t.name), containsAll(<String>['Tag', 'Label']));
    });

    test('a single-template file name is derived from the template', () {
      expect(
        transfer.fileNameFor(template('Field Tag')),
        'template_Field_Tag.json',
      );
      expect(transfer.fileNameFor(template('  ')), 'template_template.json');
    });
  });

  test('the import limit matches the other preset importers', () {
    expect(TemplateTransferService.importLimit, 20);
  });
}
