import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';

void main() {
  late Database db;

  setUp(() {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  group('getMediaByIds', () {
    test('returns media in input order and skips missing ids', () async {
      final first = await db
          .into(db.media)
          .insert(const MediaCompanion(fileName: Value('first.jpg')));
      final second = await db
          .into(db.media)
          .insert(const MediaCompanion(fileName: Value('second.jpg')));

      final media = await MediaDbQuery(db).getMediaByIds([second, 999, first]);

      expect(media.map((row) => row.fileName), ['second.jpg', 'first.jpg']);
    });

    test('an empty list returns no media', () async {
      await db
          .into(db.media)
          .insert(const MediaCompanion(fileName: Value('first.jpg')));

      expect(await MediaDbQuery(db).getMediaByIds([]), isEmpty);
    });
  });

  group('getSitesByIds', () {
    test('returns sites with geography in input order', () async {
      final geography = await db
          .into(db.geography)
          .insert(
            const GeographyCompanion(
              country: Value('Indonesia'),
              matchKey: Value('indonesia'),
            ),
          );
      final withGeography = await db
          .into(db.site)
          .insert(
            SiteCompanion(
              siteID: const Value('Alpha'),
              geographyId: Value(geography),
            ),
          );
      final withoutGeography = await db
          .into(db.site)
          .insert(const SiteCompanion(siteID: Value('Beta')));

      final sites = await SiteQuery(
        db,
      ).getSitesByIds([withoutGeography, 999, withGeography]);

      expect(sites.map((site) => site.siteID), ['Beta', 'Alpha']);
      expect(sites.first.geography, isNull);
      expect(sites.last.country, 'Indonesia');
    });

    test('an empty list returns no sites', () async {
      await db.into(db.site).insert(const SiteCompanion(siteID: Value('A')));

      expect(await SiteQuery(db).getSitesByIds([]), isEmpty);
    });
  });
}
