import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/record_exchange/record_exchange_service.dart';

void main() {
  late Database database;
  late WidgetRef widgetRef;
  late RecordExchangeService service;

  Future<void> setUpService(WidgetTester tester) async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    WidgetRef? capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, child) {
              capturedRef = ref;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    widgetRef = capturedRef!;
    widgetRef.read(projectUuidProvider.notifier).updateProjectUuid('project-a');
    service = RecordExchangeService(ref: widgetRef);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
  }

  Future<void> tearDownService() async {
    await database.close();
  }

  testWidgets('site package round-trips coordinates and referenced personnel', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    await database
        .into(database.personnel)
        .insert(
          const PersonnelCompanion(
            uuid: Value('person-a'),
            name: Value('Person A'),
            isRegisterField: Value(true),
          ),
        );
    final sourceSite = await database
        .into(database.site)
        .insert(
          const SiteCompanion(
            projectUuid: Value('project-a'),
            siteID: Value('Camp A'),
            leadStaffId: Value('person-a'),
          ),
        );
    await database
        .into(database.coordinate)
        .insert(
          CoordinateCompanion(
            siteID: Value(sourceSite),
            nameId: const Value('GPS 1'),
            decimalLatitude: const Value(12.3),
            decimalLongitude: const Value(-45.6),
          ),
        );

    final payload = await service.exportSite(sourceSite);
    final parsed = RecordExchangePayload.parse(
      payload.compactEncoded,
      expectedType: 'site',
    );
    final result = await service.importPayload(parsed);

    expect(result.recordId, isNot(sourceSite));
    final importedSite = await (database.select(
      database.site,
    )..where((row) => row.id.equals(result.recordId))).getSingle();
    expect(importedSite.siteID, 'Camp A');
    expect(importedSite.projectUuid, 'project-a');
    expect(importedSite.leadStaffId, 'person-a');

    final coordinates = await (database.select(
      database.coordinate,
    )..where((row) => row.siteID.equals(result.recordId))).get();
    expect(coordinates, hasLength(1));
    expect(coordinates.single.decimalLatitude, 12.3);
    expect(
      await (database.select(
        database.personnel,
      )..where((row) => row.uuid.equals('person-a'))).get(),
      hasLength(1),
    );
  });

  testWidgets(
    'event package round-trips effort, personnel, weather, and site',
    (tester) async {
      await setUpService(tester);
      addTearDown(tearDownService);
      await database.batch((batch) {
        batch.insertAll(database.personnel, const [
          PersonnelCompanion(
            uuid: Value('person-a'),
            name: Value('Person A'),
            isRegisterField: Value(true),
          ),
          PersonnelCompanion(
            uuid: Value('person-b'),
            name: Value('Person B'),
            isRegisterField: Value(true),
          ),
        ]);
      });
      final sourceSite = await database
          .into(database.site)
          .insert(
            const SiteCompanion(
              projectUuid: Value('project-a'),
              siteID: Value('Camp A'),
              leadStaffId: Value('person-a'),
            ),
          );
      await database
          .into(database.coordinate)
          .insert(
            CoordinateCompanion(
              siteID: Value(sourceSite),
              decimalLatitude: const Value(1.0),
              decimalLongitude: const Value(2.0),
            ),
          );
      final sourceEvent = await database
          .into(database.collEvent)
          .insert(
            CollEventCompanion(
              projectUuid: const Value('project-a'),
              siteID: Value(sourceSite),
              startDate: const Value('2026-07-23'),
              primaryCollMethod: const Value('Mist net'),
            ),
          );
      await database
          .into(database.collEffort)
          .insert(
            CollEffortCompanion(
              eventID: Value(sourceEvent),
              method: const Value('Mist net'),
              count: const Value(3),
            ),
          );
      await database
          .into(database.collPersonnel)
          .insert(
            CollPersonnelCompanion(
              eventID: Value(sourceEvent),
              personnelId: const Value('person-b'),
              name: const Value('Person B'),
              role: const Value('Collector'),
            ),
          );
      await database
          .into(database.weather)
          .insert(
            WeatherCompanion(
              eventID: Value(sourceEvent),
              lowestDayTempC: const Value(18.5),
              highestDayTempC: const Value(27.0),
              moonPhase: const Value('Full moon'),
            ),
          );

      final payload = await service.exportEvent(sourceEvent);
      final result = await service.importPayload(
        RecordExchangePayload.parse(payload.compactEncoded),
        linkedSiteId: sourceSite,
      );

      expect(result.recordId, isNot(sourceEvent));
      final importedEvent = await (database.select(
        database.collEvent,
      )..where((row) => row.id.equals(result.recordId))).getSingle();
      expect(importedEvent.siteID, sourceSite);
      expect(importedEvent.primaryCollMethod, 'Mist net');
      expect(
        await (database.select(
          database.collEffort,
        )..where((row) => row.eventID.equals(result.recordId))).get(),
        hasLength(1),
      );
      expect(
        await (database.select(
          database.collPersonnel,
        )..where((row) => row.eventID.equals(result.recordId))).get(),
        hasLength(1),
      );
      final weather = await (database.select(
        database.weather,
      )..where((row) => row.eventID.equals(result.recordId))).getSingle();
      expect(weather.highestDayTempC, 27.0);
      expect(weather.moonPhase, 'Full moon');
    },
  );

  testWidgets('event import can create the embedded linked site', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final sourceSite = await database
        .into(database.site)
        .insert(
          const SiteCompanion(
            projectUuid: Value('project-a'),
            siteID: Value('Embedded Site'),
          ),
        );
    final sourceEvent = await database
        .into(database.collEvent)
        .insert(
          CollEventCompanion(
            projectUuid: const Value('project-a'),
            siteID: Value(sourceSite),
          ),
        );

    final payload = await service.exportEvent(sourceEvent);
    final result = await service.importPayload(
      RecordExchangePayload.parse(payload.compactEncoded),
      createEmbeddedSite: true,
    );

    expect(result.createdSiteId, isNotNull);
    expect(result.createdSiteId, isNot(sourceSite));
    final importedEvent = await (database.select(
      database.collEvent,
    )..where((row) => row.id.equals(result.recordId))).getSingle();
    expect(importedEvent.siteID, result.createdSiteId);
  });

  testWidgets('parser rejects the wrong record type and unsupported version', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    expect(
      () => RecordExchangePayload.parse(
        '{"nahpu_record":"event","version":1,"data":{}}',
        expectedType: 'site',
      ),
      throwsFormatException,
    );
    expect(
      () => RecordExchangePayload.parse(
        '{"nahpu_record":"site","version":2,"data":{}}',
      ),
      throwsFormatException,
    );
  });

  testWidgets(
    'specimen package round-trips measurements, parts, associated data, '
    'coordinates, taxonomy, event, and personnel',
    (tester) async {
      await setUpService(tester);
      addTearDown(tearDownService);

      await database
          .into(database.personnel)
          .insert(
            const PersonnelCompanion(
              uuid: Value('person-a'),
              name: Value('Person A'),
              isRegisterField: Value(true),
            ),
          );
      final taxon = await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              genus: Value('Rana'),
              specificEpithet: Value('temporaria'),
            ),
          );
      final site = await database
          .into(database.site)
          .insert(
            const SiteCompanion(
              projectUuid: Value('project-a'),
              siteID: Value('Camp A'),
            ),
          );
      final coordinate = await database
          .into(database.coordinate)
          .insert(
            CoordinateCompanion(
              siteID: Value(site),
              decimalLatitude: const Value(12.3),
              decimalLongitude: const Value(-45.6),
            ),
          );
      final event = await database
          .into(database.collEvent)
          .insert(
            CollEventCompanion(
              projectUuid: const Value('project-a'),
              siteID: Value(site),
            ),
          );
      final specimenUuid = 'specimen-a';
      await database
          .into(database.specimen)
          .insert(
            SpecimenCompanion(
              uuid: Value(specimenUuid),
              projectUuid: const Value('project-a'),
              speciesID: Value(taxon),
              coordinateID: Value(coordinate),
              collEventID: Value(event),
              catalogerID: const Value('person-a'),
              fieldNumber: const Value(17),
            ),
          );
      await database
          .into(database.mammalAttribute)
          .insert(
            MammalAttributeCompanion.insert(
              specimenUuid: specimenUuid,
              weight: Value(2.5),
            ),
          );
      await database
          .into(database.specimenPart)
          .insert(
            SpecimenPartCompanion.insert(
              specimenUuid: Value(specimenUuid),
              personnelId: Value('person-a'),
              type: Value('Tissue'),
            ),
          );
      await database
          .into(database.associatedData)
          .insert(
            AssociatedDataCompanion.insert(
              specimenUuid: Value(specimenUuid),
              name: Value('Field note'),
              description: Value('Collected beside stream'),
            ),
          );

      final payload = await service.exportSpecimen(specimenUuid);
      expect(payload.type, RecordExchangeType.specimen);
      expect(payload.partCount, 1);
      expect(payload.associatedDataCount, 1);
      expect(payload.data['taxonomy'], isNotNull);
      expect(payload.data['event'], isNotNull);

      final parsed = RecordExchangePayload.parse(payload.compactEncoded);
      final result = await service.importPayload(
        parsed,
        references: SpecimenImportReferences(eventId: event, taxonomyId: taxon),
      );

      expect(result.recordUuid, isNot(specimenUuid));
      final imported = await (database.select(
        database.specimen,
      )..where((row) => row.uuid.equals(result.recordUuid!))).getSingle();
      expect(imported.fieldNumber, 17);
      expect(imported.collEventID, event);
      expect(imported.speciesID, taxon);
      expect(imported.coordinateID, isNot(coordinate));
      expect(
        await (database.select(database.mammalAttribute)
              ..where((row) => row.specimenUuid.equals(result.recordUuid!)))
            .getSingle()
            .then((value) => value.weight),
        2.5,
      );
      expect(
        await (database.select(
          database.specimenPart,
        )..where((row) => row.specimenUuid.equals(result.recordUuid!))).get(),
        hasLength(1),
      );
      expect(
        await (database.select(
          database.associatedData,
        )..where((row) => row.specimenUuid.equals(result.recordUuid!))).get(),
        hasLength(1),
      );
    },
  );
}
