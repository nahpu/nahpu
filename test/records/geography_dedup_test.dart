import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/geography_queries.dart';
import 'package:nahpu/services/types/geography.dart';

void main() {
  late Database database;
  late GeographyQuery query;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    query = GeographyQuery(database);
  });

  tearDown(() => database.close());

  group('match key normalization', () {
    test('folds case, including non-ASCII letters', () {
      // SQLite's lower() and COLLATE NOCASE only fold ASCII, which is why the
      // normalization lives in Dart.
      expect(
        const GeographyDraft(municipality: 'CAÑÓN').matchKey,
        const GeographyDraft(municipality: 'cañón').matchKey,
      );
      expect(
        const GeographyDraft(country: 'INDONESIA').matchKey,
        const GeographyDraft(country: 'indonesia').matchKey,
      );
    });

    test('trims and collapses whitespace', () {
      expect(
        const GeographyDraft(stateProvince: '  Sulawesi   Selatan ').matchKey,
        const GeographyDraft(stateProvince: 'Sulawesi Selatan').matchKey,
      );
    });

    test('treats null, empty, and blank the same', () {
      expect(
        const GeographyDraft(country: 'Peru').matchKey,
        const GeographyDraft(country: 'Peru', county: '   ').matchKey,
      );
      expect(const GeographyDraft().isEmpty, isTrue);
      expect(const GeographyDraft(county: '  ').isEmpty, isTrue);
      expect(const GeographyDraft(county: 'Gowa').isEmpty, isFalse);
    });

    test('keeps distinct fields distinct', () {
      // Values must not be able to slide across the field boundary.
      expect(
        const GeographyDraft(country: 'A', islandGroup: 'B').matchKey,
        isNot(const GeographyDraft(country: 'AB').matchKey),
      );
    });
  });

  group('resolve', () {
    test('reuses one record for equivalent drafts', () async {
      final first = await query.resolve(
        const GeographyDraft(
          country: 'Indonesia',
          stateProvince: 'Sulawesi Selatan',
          locality: 'Mt. Bawakaraeng',
        ),
      );
      final second = await query.resolve(
        const GeographyDraft(
          country: '  indonesia',
          stateProvince: 'SULAWESI  SELATAN',
          locality: 'mt. bawakaraeng ',
        ),
      );

      expect(first, isNotNull);
      expect(second, first);
      expect(await query.getAll(), hasLength(1));
    });

    test('stores the value as first entered, not normalized', () async {
      final id = await query.resolve(
        const GeographyDraft(country: ' Indonesia ', county: 'Gowa'),
      );
      final record = await query.getById(id);
      expect(record!.country, 'Indonesia');
      expect(record.county, 'Gowa');
      expect(record.stateProvince, isNull);
    });

    test('creates separate records for different localities', () async {
      final first = await query.resolve(
        const GeographyDraft(country: 'Indonesia', stateProvince: 'Papua'),
      );
      final second = await query.resolve(
        const GeographyDraft(country: 'Indonesia', stateProvince: 'Maluku'),
      );
      expect(second, isNot(first));
      expect(await query.getAll(), hasLength(2));
    });

    test('returns null for an empty draft', () async {
      expect(await query.resolve(const GeographyDraft()), isNull);
      expect(await query.resolve(const GeographyDraft(county: ' ')), isNull);
      expect(await query.getAll(), isEmpty);
    });

    test('findMatch reports whether a locality is already known', () async {
      const draft = GeographyDraft(country: 'Peru', locality: 'Cusco');
      expect(await query.findMatch(draft), isNull);
      final id = await query.resolve(draft);
      expect((await query.findMatch(draft))?.id, id);
    });
  });

  group('maintenance', () {
    test('getDistinctValues skips blanks and duplicates', () async {
      await query.resolve(const GeographyDraft(country: 'Peru', locality: 'A'));
      await query.resolve(const GeographyDraft(country: 'peru', locality: 'B'));
      await query.resolve(const GeographyDraft(locality: 'C'));

      expect(await query.getDistinctValues(GeographyField.country), [
        'Peru',
        'peru',
      ]);
      expect(await query.getDistinctValues(GeographyField.locality), [
        'A',
        'B',
        'C',
      ]);
    });

    test(
      'deleteUnreferenced keeps localities a site still points at',
      () async {
        final used = await query.resolve(
          const GeographyDraft(country: 'Peru', locality: 'Used'),
        );
        await query.resolve(
          const GeographyDraft(country: 'Peru', locality: 'Orphan'),
        );
        await database
            .into(database.site)
            .insert(SiteCompanion(geographyId: Value(used)));

        expect(await query.deleteUnreferenced(), 1);
        final remaining = await query.getAll();
        expect(remaining, hasLength(1));
        expect(remaining.single.id, used);
      },
    );
  });
}
