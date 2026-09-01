import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/templates/user_font_service.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  const service = UserFontService();

  late Directory tempAppDir;

  File asset(String name) => File(p.join('assets', 'fonts', name));

  Future<File> copyAsset(String name, {String? as}) async {
    final target = File(p.join(tempAppDir.path, as ?? name));
    await target.writeAsBytes(await asset(name).readAsBytes());
    return target;
  }

  setUp(() {
    tempAppDir = Directory.systemTemp.createTempSync('nahpu-user-fonts-test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          switch (call.method) {
            case 'getApplicationDocumentsDirectory':
              return tempAppDir.path;
            case 'getTemporaryDirectory':
              return Directory.systemTemp.path;
            default:
              return null;
          }
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempAppDir.existsSync()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  test('an empty catalog is returned before anything is installed', () async {
    expect((await service.load()).fonts, isEmpty);
    expect(await service.loadAllFontBytes(), isEmpty);
  });

  test('imports a font under its internal family name', () async {
    final result = await service.importFile(
      await copyAsset('PlusJakartaSans-Regular.ttf'),
    );

    expect(result.font.family, 'Plus Jakarta Sans');
    expect(result.font.variants, hasLength(1));
    expect(result.font.variants.single.italic, isFalse);
    expect(result.font.variants.single.byteSize, greaterThan(0));
    expect(result.catalog.fonts, hasLength(1));

    final fontDir = await getUserFontDirectory();
    final stored = File(
      p.join(
        fontDir.path,
        result.font.relativePathOf(result.font.variants.single),
      ),
    );
    expect(stored.existsSync(), isTrue);
    expect(
      File(p.join(fontDir.path, result.font.id, 'font.json')).existsSync(),
      isTrue,
    );
  });

  test('the catalog survives a reload', () async {
    await service.importFile(await copyAsset('PlusJakartaSans-Regular.ttf'));

    final reloaded = await service.load();
    expect(reloaded.fonts, hasLength(1));
    expect(reloaded.byFamily('Plus Jakarta Sans'), isNotNull);
    expect(reloaded.byFamily('plus jakarta sans'), isNotNull);
    expect(reloaded.byFamily('Nonexistent'), isNull);
  });

  test('extra styles are added as variants of one family', () async {
    await service.importFile(await copyAsset('PlusJakartaSans-Regular.ttf'));
    await service.importFile(await copyAsset('PlusJakartaSans-Bold.ttf'));
    final result = await service.importFile(
      await copyAsset('PlusJakartaSans-Italic.ttf'),
    );

    expect(result.catalog.fonts, hasLength(1));
    final font = result.catalog.fonts.single;
    expect(font.variants, hasLength(3));
    expect(font.hasBold, isTrue);
    expect(font.hasItalic, isTrue);
    expect(await service.loadAllFontBytes(), hasLength(3));
  });

  test(
    're-importing the same style replaces it rather than duplicating',
    () async {
      await service.importFile(await copyAsset('PlusJakartaSans-Regular.ttf'));
      final result = await service.importFile(
        await copyAsset('PlusJakartaSans-Regular.ttf', as: 'renamed-copy.ttf'),
      );

      expect(result.catalog.fonts, hasLength(1));
      expect(result.catalog.fonts.single.variants, hasLength(1));
    },
  );

  test('separate families are stored separately', () async {
    await service.importFile(await copyAsset('PlusJakartaSans-Regular.ttf'));
    final result = await service.importFile(await copyAsset('DejaVuSerif.ttf'));

    expect(
      result.catalog.fonts.map((font) => font.family),
      containsAll(<String>['DejaVu Serif', 'Plus Jakarta Sans']),
    );
  });

  test('deleting a font removes its files and catalog entry', () async {
    final imported = await service.importFile(
      await copyAsset('PlusJakartaSans-Regular.ttf'),
    );
    final fontDir = await getUserFontDirectory();

    final catalog = await service.deleteFont(imported.font);

    expect(catalog.fonts, isEmpty);
    expect(
      Directory(p.join(fontDir.path, imported.font.id)).existsSync(),
      isFalse,
    );
    expect(await service.loadAllFontBytes(), isEmpty);
  });

  test('rejects a file that is not a font', () async {
    final notAFont = File(p.join(tempAppDir.path, 'logo.png'));
    await notAFont.writeAsBytes(List<int>.filled(32, 0));

    expect(() => service.importFile(notAFont), throwsA(isA<FormatException>()));
  });
}
