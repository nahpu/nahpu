import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/media/media_details.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/media/media_linked_information_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/import.dart';

void main() {
  late Database database;
  late MediaLinkedInformationServices services;
  late int siteId;
  late int eventId;
  late int specimenMediaId;
  late int siteMediaId;
  late int eventMediaId;
  late int narrativeMediaId;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    services = MediaLinkedInformationServices(dbAccess: database);

    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-1'),
            name: Value('Linked media project'),
            catalogNumberPrefix: Value('NA-'),
            catalogNumberSuffix: Value('-X'),
          ),
        );
    await database
        .into(database.personnel)
        .insert(
          const PersonnelCompanion(
            uuid: Value('cataloger-1'),
            name: Value('Cataloger One'),
            initial: Value('CO'),
          ),
        );
    await database
        .into(database.personnel)
        .insert(
          const PersonnelCompanion(
            uuid: Value('writer-1'),
            name: Value('Narrative Writer'),
            initial: Value('NW'),
          ),
        );
    siteId = await database
        .into(database.site)
        .insert(
          const SiteCompanion(
            siteID: Value('SITE-01'),
            projectUuid: Value('project-1'),
            country: Value('Indonesia'),
            stateProvince: Value('West Java'),
            county: Value('Bogor'),
            municipality: Value('Cibodas'),
            locality: Value('Forest plot 7'),
          ),
        );
    eventId = await database
        .into(database.collEvent)
        .insert(
          CollEventCompanion(
            projectUuid: const Value('project-1'),
            siteID: Value(siteId),
            startDate: const Value('2026-01-02'),
            idSuffix: const Value('NIGHT'),
          ),
        );
    final taxonId = await database
        .into(database.taxonomy)
        .insert(
          const TaxonomyCompanion(
            taxonRank: Value('species'),
            genus: Value('Myotis'),
            specificEpithet: Value('lucifugus'),
          ),
        );
    await database
        .into(database.specimen)
        .insert(
          SpecimenCompanion(
            uuid: const Value('specimen-1'),
            projectUuid: const Value('project-1'),
            projectFieldNumber: const Value(42),
            catalogerID: const Value('cataloger-1'),
            museumID: const Value('MUSEUM-9'),
            speciesID: Value(taxonId),
            collEventID: Value(eventId),
          ),
        );
    final narrativeId = await database
        .into(database.narrative)
        .insert(
          NarrativeCompanion(
            projectUuid: const Value('project-1'),
            siteID: Value(siteId),
            writerId: const Value('writer-1'),
            narrative: const Value('Evening survey'),
          ),
        );

    specimenMediaId = await _insertMedia(database, 'specimen');
    siteMediaId = await _insertMedia(database, 'site');
    eventMediaId = await _insertMedia(database, 'event');
    narrativeMediaId = await _insertMedia(database, 'narrative');
    await database
        .into(database.specimenMedia)
        .insert(
          SpecimenMediaCompanion(
            specimenUuid: const Value('specimen-1'),
            mediaId: Value(specimenMediaId),
          ),
        );
    await database
        .into(database.siteMedia)
        .insert(
          SiteMediaCompanion(
            siteId: Value(siteId),
            mediaId: Value(siteMediaId),
          ),
        );
    await database
        .into(database.eventMedia)
        .insert(
          EventMediaCompanion(
            eventID: Value(eventId),
            mediaId: Value(eventMediaId),
          ),
        );
    await database
        .into(database.narrativeMedia)
        .insert(
          NarrativeMediaCompanion(
            narrativeId: Value(narrativeId),
            mediaId: Value(narrativeMediaId),
          ),
        );
  });

  tearDown(() => database.close());

  test(
    'resolves specimen identifiers, taxonomy, event, and site name',
    () async {
      final information = await services.resolve(
        mediaId: specimenMediaId,
        category: MediaCategory.specimen,
      );

      expect(_fields(information), {
        'Field ID': 'NA-42-X',
        'Museum ID': 'MUSEUM-9',
        'Species': 'Myotis lucifugus',
        'Event ID': 'SITE-01-2026-01-02-NIGHT',
        'Site name': 'Indonesia, West Java, Bogor, Cibodas, Forest plot 7',
      });
    },
  );

  test('omits a blank specimen museum ID', () async {
    await (database.update(database.specimen)
          ..where((row) => row.uuid.equals('specimen-1')))
        .write(const SpecimenCompanion(museumID: Value('  ')));

    final information = await services.resolve(
      mediaId: specimenMediaId,
      category: MediaCategory.specimen,
    );

    expect(_fields(information), isNot(contains('Museum ID')));
  });

  test('resolves site and event linked information', () async {
    expect(
      _fields(
        await services.resolve(
          mediaId: siteMediaId,
          category: MediaCategory.site,
        ),
      ),
      {
        'Site ID': 'SITE-01',
        'Site name': 'Indonesia, West Java, Bogor, Cibodas, Forest plot 7',
      },
    );
    expect(
      _fields(
        await services.resolve(
          mediaId: eventMediaId,
          category: MediaCategory.event,
        ),
      ),
      {
        'Event ID': 'SITE-01-2026-01-02-NIGHT',
        'Site name': 'Indonesia, West Java, Bogor, Cibodas, Forest plot 7',
      },
    );
  });

  test('resolves narrative site name and writer', () async {
    final information = await services.resolve(
      mediaId: narrativeMediaId,
      category: MediaCategory.narrative,
    );

    expect(_fields(information), {
      'Site name': 'Indonesia, West Java, Bogor, Cibodas, Forest plot 7',
      'Writer': 'Narrative Writer',
    });
  });

  testWidgets('shared media details renders narrative linked information', (
    tester,
  ) async {
    final media = await (database.select(
      database.media,
    )..where((row) => row.primaryId.equals(narrativeMediaId))).getSingle();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(body: MediaDetailsView(media: media)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Linked information'), findsOneWidget);
    expect(find.text('Site name'), findsOneWidget);
    expect(
      find.text('Indonesia, West Java, Bogor, Cibodas, Forest plot 7'),
      findsOneWidget,
    );
    expect(find.text('Writer'), findsOneWidget);
    expect(find.text('Narrative Writer'), findsOneWidget);
  });

  test('returns no linked section when the category link is missing', () async {
    final unlinkedMediaId = await _insertMedia(database, 'site');
    expect(
      await services.resolve(
        mediaId: unlinkedMediaId,
        category: MediaCategory.site,
      ),
      isNull,
    );
  });
}

Future<int> _insertMedia(Database database, String category) {
  return database
      .into(database.media)
      .insert(
        MediaCompanion(
          projectUuid: const Value('project-1'),
          category: Value(category),
          fileName: Value('$category.jpg'),
        ),
      );
}

Map<String, String?> _fields(MediaLinkedInformation? information) {
  return {
    for (final field in information?.fields ?? const <MediaLinkedField>[])
      field.label: field.value,
  };
}
