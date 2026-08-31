import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/specimen_part_filter.dart';

import '../data/specimen_part_fixture.dart';

void main() {
  test('empty filters include missing types and numbers', () {
    const filter = SpecimenPartFilter.empty();
    expect(filter.isActive, isFalse);
    expect(filter.matches(specimenPartFixture()), isTrue);
    expect(filter.matches(specimenPartFixture(type: 'Blood')), isTrue);
    expect(
      SpecimenPartFilter(
        numberType: SpecimenPartNumberType.projectNumber,
      ).matches(specimenPartFixture()),
      isTrue,
    );
  });

  test(
    'multiple types use normalized exact matching and immutable choices',
    () {
      final types = {' Blood ', 'LIVER'};
      final filter = SpecimenPartFilter(partTypes: types);
      types.clear();

      expect(filter.isActive, isTrue);
      expect(filter.matches(specimenPartFixture(type: 'BLOOD')), isTrue);
      expect(filter.matches(specimenPartFixture(type: ' liver ')), isTrue);
      expect(filter.matches(specimenPartFixture(type: 'Whole blood')), isFalse);
      expect(filter.matches(specimenPartFixture()), isFalse);
      expect(() => filter.partTypes.add('skin'), throwsUnsupportedError);
    },
  );

  test('unspecified type includes null, empty, and whitespace types', () {
    final filter = SpecimenPartFilter(partTypes: {''});
    for (final type in [null, '', '  ']) {
      expect(filter.matches(specimenPartFixture(type: type)), isTrue);
    }
    expect(filter.matches(specimenPartFixture(type: 'Unspecified')), isFalse);
    expect(filter.matches(specimenPartFixture(type: 'Blood')), isFalse);
  });

  test('type options are trimmed, deduplicated, and sorted', () {
    final options = SpecimenPartFilter.typeOptionsFor([
      specimenPartFixture(type: ' Liver '),
      specimenPartFixture(type: 'Blood'),
      specimenPartFixture(type: ' blood '),
      specimenPartFixture(),
      specimenPartFixture(type: ' '),
    ]);
    expect(options.map((option) => option.label), [
      'Blood',
      'Liver',
      'Unspecified',
    ]);
    expect(options.map((option) => option.value), ['blood', 'liver', '']);
    expect(SpecimenPartFilter.typeOptionsFor([]), isEmpty);
  });

  for (final numberType in SpecimenPartNumberType.values) {
    group(numberType.name, () {
      test('range is inclusive and uses only the chosen number', () {
        final filter = SpecimenPartFilter(
          numberType: numberType,
          from: 10,
          to: 20,
        );
        for (final number in [9, 10, 15, 20, 21]) {
          final part = specimenPartFixture(
            fieldNumber: numberType == SpecimenPartNumberType.fieldNumber
                ? number
                : 15,
            projectNumber: numberType == SpecimenPartNumberType.projectNumber
                ? number
                : 15,
          );
          expect(filter.matches(part), number >= 10 && number <= 20);
        }
        expect(
          filter.matches(
            specimenPartFixture(
              fieldNumber: numberType == SpecimenPartNumberType.projectNumber
                  ? 15
                  : null,
              projectNumber: numberType == SpecimenPartNumberType.fieldNumber
                  ? 15
                  : null,
            ),
          ),
          isFalse,
        );
      });

      test(
        'either bound can be omitted and equal bounds select one number',
        () {
          final part = specimenPartFixture(fieldNumber: 10, projectNumber: 10);
          expect(
            SpecimenPartFilter(numberType: numberType, from: 10).matches(part),
            isTrue,
          );
          expect(
            SpecimenPartFilter(numberType: numberType, from: 11).matches(part),
            isFalse,
          );
          expect(
            SpecimenPartFilter(numberType: numberType, to: 10).matches(part),
            isTrue,
          );
          expect(
            SpecimenPartFilter(numberType: numberType, to: 9).matches(part),
            isFalse,
          );
          expect(
            SpecimenPartFilter(
              numberType: numberType,
              from: 10,
              to: 10,
            ).matches(part),
            isTrue,
          );
          expect(
            SpecimenPartFilter(
              numberType: numberType,
              from: 0,
            ).matches(specimenPartFixture()),
            isFalse,
          );
        },
      );
    });
  }

  test('search combines with type and number filters', () {
    final filter = SpecimenPartFilter(
      partTypes: {'blood', 'liver'},
      from: 10,
      to: 20,
    );
    final records = [
      specimenPartFixture(
        id: 1,
        type: 'Blood',
        fieldNumber: 10,
        treatment: 'Frozen',
      ),
      specimenPartFixture(
        id: 2,
        type: 'Liver',
        fieldNumber: 20,
        treatment: 'Frozen',
      ),
      specimenPartFixture(
        id: 3,
        type: 'Skin',
        fieldNumber: 15,
        treatment: 'Frozen',
      ),
      specimenPartFixture(
        id: 4,
        type: 'Blood',
        fieldNumber: 21,
        treatment: 'Frozen',
      ),
      specimenPartFixture(
        id: 5,
        type: 'Blood',
        fieldNumber: 15,
        treatment: 'Ethanol',
      ),
    ];
    expect(
      records
          .where((record) => filter.matches(record, query: ' FROZEN '))
          .map((record) => record.recordId),
      ['1', '2'],
    );
  });

  test('search retains old fields and includes project number', () {
    const filter = SpecimenPartFilter.empty();
    final record = specimenPartFixture(
      tissueId: 'Tissue-A',
      barcode: 'Barcode-B',
      type: 'Blood',
      treatment: 'Frozen',
      fieldNumber: 123,
      projectNumber: 456,
      museumId: 'Museum-C',
    );
    for (final query in [
      'tissue-a',
      'barcode-b',
      'blood',
      'frozen',
      '123',
      '456',
      'museum-c',
      ' ',
    ]) {
      expect(filter.matches(record, query: query), isTrue, reason: query);
    }
    expect(filter.matches(record, query: 'not present'), isFalse);
  });

  test('range input accepts empty bounds and decimal whole numbers only', () {
    for (final input in [null, '', ' ', '0', '0012', ' 123 ']) {
      expect(SpecimenPartFilter.validateNumber(input), isNull, reason: input);
    }
    for (final input in [
      '-1',
      '1.5',
      'abc',
      '0x10',
      '+1',
      '1e3',
      '999999999999999999999999',
    ]) {
      expect(
        SpecimenPartFilter.validateNumber(input),
        isNotNull,
        reason: input,
      );
    }
    expect(SpecimenPartFilter.validateRange('20', '10'), isNotNull);
    expect(SpecimenPartFilter.validateRange('10', '10'), isNull);
    expect(SpecimenPartFilter.validateRange('', '10'), isNull);
    expect(SpecimenPartFilter.validateRange('10', ''), isNull);
    expect(() => SpecimenPartFilter(from: -1), throwsArgumentError);
    expect(() => SpecimenPartFilter(to: -1), throwsArgumentError);
    expect(() => SpecimenPartFilter(from: 20, to: 10), throwsArgumentError);
  });
}
