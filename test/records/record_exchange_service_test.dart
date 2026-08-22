import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/custom_fields/custom_field_service.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/record_exchange/record_exchange_service.dart';
import 'package:nahpu/services/types/custom_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Database database;
  late Directory tempAppDir;
  late WidgetRef widgetRef;
  late RecordExchangeService service;

  Future<void> setUpService(WidgetTester tester) async {
    tempAppDir = Directory.systemTemp.createTempSync(
      'nahpu-record-exchange-test',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (_) async {
          return tempAppDir.path;
        });
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await database.close();
    if (tempAppDir.existsSync()) {
      await tempAppDir.delete(recursive: true);
    }
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
        .into(database.siteAttribute)
        .insert(
          SiteAttributeCompanion(
            siteID: Value(sourceSite),
            habitatType: const Value('Forest'),
            habitatCondition: const Value('Intact'),
            habitatDescription: const Value('Lowland rainforest'),
            canopyCover: const Value('75%'),
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
    final sourceData = await AssociatedDataQuery(database)
        .createProjectAssociatedData(
          const AssociatedDataCompanion(
            projectUuid: Value('project-a'),
            name: Value('Site recording'),
          ),
        );
    await AssociatedDataQuery(database).linkToSite(sourceData, sourceSite);

    final payload = await service.exportSite(sourceSite);
    expect(payload.associatedDataCount, 1);
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
    final importedAttribute = await (database.select(
      database.siteAttribute,
    )..where((row) => row.siteID.equals(result.recordId))).getSingle();
    expect(importedAttribute.habitatType, 'Forest');
    expect(importedAttribute.habitatCondition, 'Intact');
    expect(importedAttribute.habitatDescription, 'Lowland rainforest');
    expect(importedAttribute.canopyCover, '75%');

    final coordinates = await (database.select(
      database.coordinate,
    )..where((row) => row.siteID.equals(result.recordId))).get();
    expect(coordinates, hasLength(1));
    expect(coordinates.single.decimalLatitude, 12.3);
    expect(
      await AssociatedDataQuery(
        database,
      ).getAssociatedDataForSite(result.recordId),
      hasLength(1),
    );
    expect(
      await (database.select(
        database.personnel,
      )..where((row) => row.uuid.equals('person-a'))).get(),
      hasLength(1),
    );
  });

  testWidgets(
    'event package round-trips effort, personnel, environment, and site',
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
              primaryCollMethod: const Value('Recording'),
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
          .into(database.environment)
          .insert(
            EnvironmentCompanion(
              eventID: Value(sourceEvent),
              lowestDayTempC: const Value(18.5),
              highestDayTempC: const Value(27.0),
              moonPhase: const Value('Full moon'),
              cloudCover: const Value('7'),
              rainfallInMm: const Value(12.5),
              ambientHumidity: const Value(88.0),
              pH: const Value(6.8),
            ),
          );
      final associatedDataId = await AssociatedDataQuery(database)
          .createProjectAssociatedData(
            const AssociatedDataCompanion(
              projectUuid: Value('project-a'),
              name: Value('Event field notes'),
              type: Value('Link'),
              uri: Value('https://example.org/event-notes'),
            ),
          );
      await AssociatedDataQuery(
        database,
      ).linkToEvent(associatedDataId, sourceEvent);
      final customFieldService = CustomFieldService(database);
      final windField = await customFieldService.createDefinition(
        const CustomFieldDraft(
          name: 'Wind direction',
          type: FieldType.text,
          placement: FieldUISection.environmentalData,
          scope: FieldScope.project,
          projectUuid: 'project-a',
        ),
      );
      await customFieldService.setValue(
        CustomFieldOwner.environment(sourceEvent),
        windField.id!,
        'Northwest',
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
      expect(importedEvent.primaryCollMethod, 'Recording');
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
      final environment = await (database.select(
        database.environment,
      )..where((row) => row.eventID.equals(result.recordId))).getSingle();
      expect(environment.highestDayTempC, 27.0);
      expect(environment.moonPhase, 'Full moon');
      expect(environment.cloudCover, '7');
      expect(environment.rainfallInMm, 12.5);
      expect(environment.ambientHumidity, 88.0);
      expect(environment.pH, 6.8);
      final importedCustomValues = await customFieldService.getEntries(
        CustomFieldOwner.environment(result.recordId),
      );
      expect(importedCustomValues, hasLength(1));
      expect(importedCustomValues.single.definition.name, 'Wind direction');
      expect(importedCustomValues.single.value?.value, 'Northwest');
      final associatedData = await AssociatedDataQuery(
        database,
      ).getAssociatedDataForEvent(result.recordId);
      expect(associatedData, hasLength(1));
      expect(associatedData.single.name, 'Event field notes');
      expect(associatedData.single.uri, 'https://example.org/event-notes');
    },
  );

  testWidgets('legacy v3 event imports weather as environmental data', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final payload = RecordExchangePayload.parse(
      '{"nahpu_record":"event","version":3,"data":{'
      '"event":{"startDate":"2026-08-16"},'
      '"weather":{"lowestDayTempC":19.5,"averageHumidity":82,'
      '"notes":"Legacy weather note"}}}',
    );

    final result = await service.importPayload(payload);
    final environment = await (database.select(
      database.environment,
    )..where((row) => row.eventID.equals(result.recordId))).getSingle();
    expect(environment.lowestDayTempC, 19.5);
    expect(environment.averageHumidity, 82);
    expect(environment.notes, 'Legacy weather note');
  });

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

  testWidgets('event replacement safely detaches prior associated data', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final sourceEvent = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion(projectUuid: Value('project-a')));
    final targetEvent = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion(projectUuid: Value('project-a')));
    final retainingSite = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('project-a')));
    final replacementId = await AssociatedDataQuery(database)
        .createEventDataAssociation(
          sourceEvent,
          const AssociatedDataCompanion(name: Value('Replacement notes')),
        );
    final priorId = await AssociatedDataQuery(database)
        .createEventDataAssociation(
          targetEvent,
          const AssociatedDataCompanion(name: Value('Prior shared notes')),
        );
    await AssociatedDataQuery(database).linkToSite(priorId, retainingSite);

    final payload = await service.exportEvent(sourceEvent);
    final result = await service.importPayload(payload, targetId: targetEvent);

    expect(result.recordId, targetEvent);
    final targetData = await AssociatedDataQuery(
      database,
    ).getAssociatedDataForEvent(targetEvent);
    expect(targetData.map((entry) => entry.name), ['Replacement notes']);
    expect(
      await AssociatedDataQuery(database).getAssociatedDataById(priorId),
      isNotNull,
    );
    expect(
      await AssociatedDataQuery(database).getAssociatedDataById(replacementId),
      isNotNull,
    );
  });

  testWidgets(
    'event archive carries media and only media payloads replace target media',
    (tester) async {
      await setUpService(tester);
      addTearDown(tearDownService);
      await database
          .into(database.personnel)
          .insert(
            const PersonnelCompanion(
              uuid: Value('photographer-a'),
              name: Value('Photographer A'),
            ),
          );
      final sourceEvent = await database
          .into(database.collEvent)
          .insert(
            const CollEventCompanion(
              projectUuid: Value('project-a'),
              idSuffix: Value('MEDIA'),
            ),
          );
      final sourceMediaId = await database
          .into(database.media)
          .insert(
            const MediaCompanion(
              projectUuid: Value('project-a'),
              category: Value('event'),
              fileName: Value('event-photo.jpg'),
              caption: Value('Habitat overview'),
              tag: Value('habitat'),
              taken: Value('2026-08-09 14:30:00'),
              camera: Value('NAHPU Camera'),
              lenses: Value('35 mm'),
              additionalExif: Value('ISO: 200'),
              personnelId: Value('photographer-a'),
            ),
          );
      await CollEventQuery(database).createEventMedia(
        EventMediaCompanion(
          eventID: Value(sourceEvent),
          mediaId: Value(sourceMediaId),
        ),
      );
      final eventMediaDirectory = Directory(
        path.join(tempAppDir.path, 'nahpu', 'project-a', 'media', 'event'),
      )..createSync(recursive: true);
      File(
        path.join(eventMediaDirectory.path, 'event-photo.jpg'),
      ).writeAsBytesSync([1, 2, 3, 4]);

      final mediaPayload = (await tester.runAsync(
        () => service.exportEvent(sourceEvent, includeMedia: true),
      ))!;
      expect(mediaPayload.mediaCount, 1);
      expect(mediaPayload.mediaFiles, hasLength(1));
      expect(
        RecordExchangePayload.mapList(
          mediaPayload.data['personnel'],
        ).single['uuid'],
        'photographer-a',
      );

      final targetEvent = await database
          .into(database.collEvent)
          .insert(const CollEventCompanion(projectUuid: Value('project-a')));
      final oldMediaId = await MediaDbQuery(database).createMedia(
        const MediaCompanion(
          projectUuid: Value('project-a'),
          category: Value('event'),
          fileName: Value('old.jpg'),
        ),
      );
      await CollEventQuery(database).createEventMedia(
        EventMediaCompanion(
          eventID: Value(targetEvent),
          mediaId: Value(oldMediaId),
        ),
      );

      final metadataPayload = await service.exportEvent(sourceEvent);
      await service.importPayload(metadataPayload, targetId: targetEvent);
      expect(
        (await CollEventQuery(
          database,
        ).getEventMedia(targetEvent)).single.mediaId,
        oldMediaId,
      );

      final extraction = Directory(path.join(tempAppDir.path, 'extracted'));
      final entry = RecordExchangePayload.mapList(
        mediaPayload.data['media'],
      ).single;
      final archivePath = entry['archivePath'] as String;
      final extractedFile = File(
        path.joinAll([extraction.path, ...path.posix.split(archivePath)]),
      );
      extractedFile.parent.createSync(recursive: true);
      extractedFile.writeAsBytesSync([1, 2, 3, 4]);

      await tester.runAsync(
        () => service.importPayload(
          mediaPayload,
          targetId: targetEvent,
          extractedMediaDirectory: extraction,
        ),
      );

      final targetLinks = await CollEventQuery(
        database,
      ).getEventMedia(targetEvent);
      expect(targetLinks, hasLength(1));
      expect(targetLinks.single.mediaId, isNot(oldMediaId));
      expect(
        () => MediaDbQuery(database).getMedia(oldMediaId),
        throwsA(isA<StateError>()),
      );
      final importedMedia = await MediaDbQuery(
        database,
      ).getMedia(targetLinks.single.mediaId!);
      expect(importedMedia.category, 'event');
      expect(importedMedia.caption, 'Habitat overview');
      expect(importedMedia.tag, 'habitat');
      expect(importedMedia.camera, 'NAHPU Camera');
      expect(importedMedia.lenses, '35 mm');
      expect(importedMedia.additionalExif, 'ISO: 200');
      expect(importedMedia.personnelId, 'photographer-a');
      expect(
        File(
          path.join(eventMediaDirectory.path, importedMedia.fileName),
        ).existsSync(),
        isTrue,
      );
    },
  );

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
        '{"nahpu_record":"site","version":99,"data":{}}',
      ),
      throwsFormatException,
    );
  });

  testWidgets('specimen package round-trips arthropod attributes', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('arthropod-a'),
            projectUuid: Value('project-a'),
            taxonGroup: Value('Arthropods'),
          ),
        );
    await database
        .into(database.arthropodAttribute)
        .insert(
          const ArthropodAttributeCompanion(
            specimenUuid: Value('arthropod-a'),
            bodyLength: Value(12.5),
            hostOrganism: Value('Quercus alba'),
            lifeStage: Value('Nymph'),
          ),
        );

    final payload = await service.exportSpecimen('arthropod-a');
    expect(payload.version, recordExchangeVersion);
    final measurements = Map<String, dynamic>.from(
      payload.data['measurements'] as Map,
    );
    expect(
      (measurements['arthropod'] as Map<String, dynamic>)['bodyLength'],
      12.5,
    );

    final result = await service.importPayload(
      RecordExchangePayload.parse(payload.compactEncoded),
    );
    final imported = await (database.select(
      database.arthropodAttribute,
    )..where((row) => row.specimenUuid.equals(result.recordUuid!))).getSingle();
    expect(imported.bodyLength, 12.5);
    expect(imported.hostOrganism, 'Quercus alba');
    expect(imported.lifeStage, 'Nymph');
  });

  testWidgets('legacy v3 specimen imports integer age as life stage', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final payload = RecordExchangePayload.parse(
      '{"nahpu_record":"specimen","version":3,"data":{'
      '"specimen":{"uuid":"legacy-mammal","taxonGroup":"Mammals"},'
      '"measurements":{"mammal":{"age":2,"weight":14.5}}}}',
    );

    final result = await service.importPayload(payload);
    final imported = await (database.select(
      database.mammalAttribute,
    )..where((row) => row.specimenUuid.equals(result.recordUuid!))).getSingle();
    expect(imported.lifeStage, 'Juvenile');
    expect(imported.weight, 14.5);
    expect(imported.weightUnit, 'g');
  });

  testWidgets(
    'specimen package round-trips measurements, parts, associated data, '
    'coordinates, taxonomy, event, and personnel',
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
            uuid: Value('identifier-a'),
            name: Value('Identifier A'),
            role: Value('Determiner only'),
            orcid: Value('0000-0002-1825-0097'),
          ),
        ]);
      });
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
              verbatimLatitude: const Value("12° 18' 0\" N"),
              verbatimLongitude: const Value("45° 36' 0\" W"),
              verbatimCoordinateSystem: const Value('degrees minutes seconds'),
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
              determinerID: const Value('identifier-a'),
              coordinateExtentMeters: const Value(3.5),
              fieldNumber: const Value(17),
            ),
          );
      await database
          .into(database.mammalAttribute)
          .insert(
            MammalAttributeCompanion.insert(
              specimenUuid: specimenUuid,
              weight: Value(2.5),
              weightUnit: Value('kg'),
              accuracy: Value('inaccurate:tailLength,weight'),
              accuracySpecify: Value('Tail cropped'),
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
      await AssociatedDataQuery(database).createSpecimenDataAssociation(
        specimenUuid,
        const AssociatedDataCompanion(
          name: Value('Field note'),
          description: Value('Collected beside stream'),
          uri: Value('https://example.org/field-note'),
        ),
      );

      final payload = await service.exportSpecimen(specimenUuid);
      expect(payload.type, RecordExchangeType.specimen);
      expect(payload.partCount, 1);
      expect(payload.associatedDataCount, 1);
      final exportedAssociatedData = RecordExchangePayload.mapList(
        payload.data['associatedData'],
      ).single;
      expect(exportedAssociatedData['url'], 'https://example.org/field-note');
      expect(exportedAssociatedData, isNot(contains('uri')));
      expect(payload.data['taxonomy'], isNotNull);
      expect(payload.data['event'], isNotNull);
      expect(
        RecordExchangePayload.mapList(
          payload.data['personnel'],
        ).map((person) => person['uuid']),
        contains('identifier-a'),
      );

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
      expect(imported.determinerID, 'identifier-a');
      expect(imported.coordinateExtentMeters, 3.5);
      final importedCoordinate =
          (await database.select(database.coordinate).get()).singleWhere(
            (row) => row.id == imported.coordinateID,
          );
      expect(importedCoordinate.verbatimLatitude, "12° 18' 0\" N");
      expect(
        importedCoordinate.verbatimCoordinateSystem,
        'degrees minutes seconds',
      );
      expect(
        (await database.select(database.personnel).get())
            .singleWhere((person) => person.uuid == 'identifier-a')
            .orcid,
        '0000-0002-1825-0097',
      );
      final importedMammalAttribute =
          await (database.select(database.mammalAttribute)
                ..where((row) => row.specimenUuid.equals(result.recordUuid!)))
              .getSingle();
      expect(importedMammalAttribute.weight, 2.5);
      expect(importedMammalAttribute.weightUnit, 'kg');
      expect(importedMammalAttribute.accuracy, 'inaccurate:tailLength,weight');
      expect(importedMammalAttribute.accuracySpecify, 'Tail cropped');
      expect(
        await (database.select(
          database.specimenPart,
        )..where((row) => row.specimenUuid.equals(result.recordUuid!))).get(),
        hasLength(1),
      );
      final importedAssociatedData = await AssociatedDataQuery(
        database,
      ).getAllAssociatedData(result.recordUuid!);
      expect(importedAssociatedData, hasLength(1));
      expect(
        importedAssociatedData.single.uri,
        'https://example.org/field-note',
      );

      final embeddedResult = await service.importPayload(
        parsed,
        references: SpecimenImportReferences(
          taxonomyId: taxon,
          createEmbeddedEvent: true,
          createEmbeddedSite: true,
        ),
      );
      expect(embeddedResult.createdEventId, isNotNull);
      expect(embeddedResult.createdSiteId, isNotNull);
      final embeddedEvent =
          await (database.select(database.collEvent)
                ..where((row) => row.id.equals(embeddedResult.createdEventId!)))
              .getSingle();
      expect(embeddedEvent.siteID, embeddedResult.createdSiteId);
      final embeddedSpecimen =
          await (database.select(database.specimen)
                ..where((row) => row.uuid.equals(embeddedResult.recordUuid!)))
              .getSingle();
      expect(embeddedSpecimen.collEventID, embeddedResult.createdEventId);
    },
  );
}
