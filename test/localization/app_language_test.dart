import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/l10n/app_localizations.dart';
import 'package:nahpu/services/localization/app_language.dart';
import 'package:path/path.dart' as p;

void main() {
  group('AppLanguage.resolve', () {
    test('picks the first shipped device language', () {
      expect(
        AppLanguage.resolve(const [Locale('fr'), Locale('id', 'ID')]),
        AppLanguage.indonesian,
      );
      expect(
        AppLanguage.resolve(const [Locale('pt', 'PT')]),
        AppLanguage.portuguese,
      );
    });

    test('falls back to English', () {
      expect(AppLanguage.resolve(const [Locale('ja')]), AppLanguage.english);
      expect(AppLanguage.resolve(const []), AppLanguage.english);
    });
  });

  test('tryParse reads saved codes and rejects unknown ones', () {
    expect(AppLanguage.tryParse('es'), AppLanguage.spanish);
    expect(AppLanguage.tryParse('xx'), isNull);
    expect(AppLanguage.tryParse(null), isNull);
  });

  test('only translations are marked beta', () {
    expect(AppLanguage.english.isBeta, isFalse);
    expect(
      AppLanguage.values.where((language) => language.isBeta),
      hasLength(AppLanguage.values.length - 1),
    );
  });

  test('every language has UI strings and bundled documentation', () {
    final supported = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();
    final cookbook = Directory(p.join('assets', 'docs', 'cookbook'))
        .listSync()
        .whereType<Directory>()
        .map((dir) => p.basename(dir.path))
        .toSet();
    final codes = AppLanguage.values.map((language) => language.code).toSet();

    expect(supported, codes);
    expect(cookbook, codes);
  });
}
