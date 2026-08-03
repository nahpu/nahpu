import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';

void main() {
  test('top-level record queries return insertion order', () async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    const projectUuid = 'project-order';
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value(projectUuid),
            name: Value('Order project'),
          ),
        );

    final firstSite = await database
        .into(database.site)
        .insert(
          const SiteCompanion(
            projectUuid: Value(projectUuid),
            siteID: Value('First site'),
          ),
        );
    final secondSite = await database
        .into(database.site)
        .insert(
          const SiteCompanion(
            projectUuid: Value(projectUuid),
            siteID: Value('Second site'),
          ),
        );
    final firstEvent = await database
        .into(database.collEvent)
        .insert(
          const CollEventCompanion(
            projectUuid: Value(projectUuid),
            idSuffix: Value('first'),
          ),
        );
    final secondEvent = await database
        .into(database.collEvent)
        .insert(
          const CollEventCompanion(
            projectUuid: Value(projectUuid),
            idSuffix: Value('second'),
          ),
        );
    final firstNarrative = await database
        .into(database.narrative)
        .insert(
          const NarrativeCompanion(
            projectUuid: Value(projectUuid),
            narrative: Value('First narrative'),
          ),
        );
    final secondNarrative = await database
        .into(database.narrative)
        .insert(
          const NarrativeCompanion(
            projectUuid: Value(projectUuid),
            narrative: Value('Second narrative'),
          ),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('z-first-specimen'),
            projectUuid: Value(projectUuid),
          ),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('a-second-specimen'),
            projectUuid: Value(projectUuid),
          ),
        );

    expect(
      (await SiteQuery(database).getAllSites(projectUuid)).map((row) => row.id),
      [firstSite, secondSite],
    );
    expect(
      (await CollEventQuery(
        database,
      ).getAllCollEvents(projectUuid)).map((row) => row.id),
      [firstEvent, secondEvent],
    );
    expect(
      (await NarrativeQuery(
        database,
      ).getAllNarrative(projectUuid)).map((row) => row.id),
      [firstNarrative, secondNarrative],
    );
    expect(
      (await SpecimenQuery(
        database,
      ).getAllSpecimens(projectUuid)).map((row) => row.uuid),
      ['z-first-specimen', 'a-second-specimen'],
    );
  });
}
