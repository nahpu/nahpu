import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nahpu/services/localization/app_language.dart';
import 'package:nahpu/services/localization/regional_format.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('every offered format and language format has intl data', () {
    final tags = [
      ...RegionalFormat.all.map((format) => format.tag),
      ...AppLanguage.values.map((language) => language.formatLocale),
    ];
    for (final tag in tags) {
      expect(
        Intl.verifiedLocale(
          tag,
          DateFormat.localeExists,
          onFailure: (_) {
            return null;
          },
        ),
        isNotNull,
        reason: tag,
      );
      expect(
        () => regionalFormatSample(tag, DateTime(2024, 3, 18)),
        returnsNormally,
      );
    }
  });

  test('every offered format writes Latin digits', () {
    final digits = RegExp(r'^[0-9\s.,  ’\x27]+$');
    for (final format in RegionalFormat.all) {
      final number = regionalFormatSample(format.tag, DateTime(2024)).number;
      expect(number, matches(digits), reason: format.tag);
    }
  });

  test('splits tags into language and country', () {
    final format = RegionalFormat.tryParse('en_GB')!;
    expect(format.languageCode, 'en');
    expect(format.countryCode, 'GB');
    expect(RegionalFormat.tryParse('xx_YY'), isNull);
  });

  test('samples follow the region', () {
    final date = DateTime(2024, 3, 18);
    expect(regionalFormatSample('en_US', date).number, '1,234.5');
    expect(regionalFormatSample('de_DE', date).number, '1.234,5');
    expect(regionalFormatSample('id_ID', date).date, contains('Mar'));
    expect(regionalFormatSample('en_GB', date).date, startsWith('18'));
  });
}
