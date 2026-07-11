import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/templates/template_nested_list_service.dart';

void main() {
  const fields = <String, String>{
    'coordinate::decimalLatitude': '31|29',
    'coordinate::decimalLongitude': '-110|-111',
  };

  group('expandNestedListPlaceholders', () {
    test('formats grouped fields as a Markdown table', () {
      final result = expandNestedListPlaceholders(
        '[coordinate::*]',
        fields,
        kTemplateNestedListTableFormat,
      );

      expect(result, contains('| Decimal Latitude | Decimal Longitude |'));
      expect(result, contains('| 31 | -110 |'));
      expect(result, contains('| 29 | -111 |'));
    });

    test('formats grouped fields as a card list', () {
      final result = expandNestedListPlaceholders(
        '[coordinate::*]',
        fields,
        kTemplateNestedListCardListFormat,
      );

      expect(result, contains('**1**'));
      expect(result, contains('- **Decimal Latitude:** 31'));
      expect(result, contains('- **Decimal Longitude:** -111'));
    });

    test('uses individual placeholders as the table columns', () {
      final result = expandNestedListPlaceholders(
        '[coordinate::nameId] [coordinate::decimalLatitude] '
        '[coordinate::decimalLongitude]',
        {
          ...fields,
          'coordinate::nameId': 'KMHH-L1S|KMHH-L1E|KMHH-PL1',
          'coordinate::decimalLatitude': '31|29|28',
          'coordinate::decimalLongitude': '-110|-111|-112',
        },
        kTemplateNestedListTableFormat,
      );

      expect(result,
          contains('| Name Id | Decimal Latitude | Decimal Longitude |'));
      expect(result, contains('| KMHH-L1S | 31 | -110 |'));
      expect(result, contains('| KMHH-PL1 | 28 | -112 |'));
    });

    test('uses short placeholders from a shared namespace', () {
      final result = expandNestedListPlaceholders(
        '[nameId] [decimalLatitude] [decimalLongitude]',
        {
          'coordinate::nameId': 'KMHH-L1S|KMHH-L1E',
          'coordinate::decimalLatitude': '3.80337|3.79961',
          'coordinate::decimalLongitude': '97.50336|97.50223',
        },
        kTemplateNestedListCardListFormat,
      );

      expect(result, contains('**1**'));
      expect(result, contains('- **Name Id:** KMHH-L1S'));
      expect(result, contains('- **Decimal Longitude:** 97.50223'));
    });

    test('leaves non-matching namespaces empty', () {
      expect(
        expandNestedListPlaceholders(
          '[effort::*]',
          fields,
          kTemplateNestedListTableFormat,
        ),
        isEmpty,
      );
    });

    test('does not expand ordinary text fields', () {
      const text = '[coordinate::decimalLatitude]';
      expect(
        expandNestedListTextIfEnabled(
          text: text,
          textType: 'normal',
          fieldValues: fields,
          formatOption: kTemplateNestedListTableFormat,
        ),
        text,
      );
    });

    test('respects title case for table headers (default)', () {
      final result = expandNestedListPlaceholders(
        '[coordinate::decimalLatitude]',
        fields,
        kTemplateNestedListTableFormat,
        'title',
      );
      expect(result, contains('| Decimal Latitude |'));
    });

    test('respects sentence case for table headers', () {
      final result = expandNestedListPlaceholders(
        '[coordinate::decimalLatitude]',
        fields,
        kTemplateNestedListTableFormat,
        'sentence',
      );
      expect(result, contains('| Decimal latitude |'));
    });

    test('respects uppercase for table headers', () {
      final result = expandNestedListPlaceholders(
        '[coordinate::decimalLatitude]',
        fields,
        kTemplateNestedListTableFormat,
        'uppercase',
      );
      expect(result, contains('| DECIMAL LATITUDE |'));
    });

    test('respects lowercase for table headers', () {
      final result = expandNestedListPlaceholders(
        '[coordinate::decimalLatitude]',
        fields,
        kTemplateNestedListTableFormat,
        'lowercase',
      );
      expect(result, contains('| decimal latitude |'));
    });
  });
}
