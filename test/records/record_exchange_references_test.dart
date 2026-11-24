import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/record_exchange/record_exchange_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Database database;
  late Directory tempAppDir;
  late RecordExchangeService service;

  Future<void> setUpService(WidgetTester tester) async {
    tempAppDir = Directory.systemTemp.createTempSync('nahpu-record-refs-test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProviderChannel,
          (_) async => tempAppDir.path,
        );
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
    capturedRef!
        .read(projectUuidProvider.notifier)
        .updateProjectUuid('project-a');
    service = RecordExchangeService(ref: capturedRef!);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
    await database
        .into(database.personnel)
        .insert(
          const PersonnelCompanion(
            uuid: Value('person-a'),
            name: Value('Person A'),
            initial: Value('PA'),
            isRegisterField: Value(true),
          ),
        );
  }

  Future<void> tearDownService() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await database.close();
    if (tempAppDir.existsSync()) await tempAppDir.delete(recursive: true);
  }

  Future<int> insertSite(String code) {
    return database
        .into(database.site)
        .insert(
          SiteCompanion(
            projectUuid: const Value('project-a'),
            siteID: Value(code),
            leadStaffId: const Value('person-a'),
          ),
        );
  }

  Future<int> insertEvent(int siteId) async {
    final eventId = await database
        .into(database.collEvent)
        .insert(
          CollEventCompanion(
            projectUuid: const Value('project-a'),
            idSuffix: const Value('1'),
            siteID: Value(siteId),
          ),
        );
    await database
        .into(database.collPersonnel)
        .insert(
          CollPersonnelCompanion(
            eventID: Value(eventId),
            personnelId: const Value('person-a'),
            name: const Value('Person A'),
            role: const Value('Collector'),
          ),
        );
    return eventId;
  }

  RecordExchangePayload roundTrip(RecordExchangePayload payload) =>
      RecordExchangePayload.parse(payload.compactEncoded);

  RecordExchangePayload withData(
    RecordExchangePayload payload,
    Map<String, dynamic> Function(Map<String, dynamic>) edit,
  ) {
    return RecordExchangePayload(
      type: payload.type,
      version: payload.version,
      data: edit(Map<String, dynamic>.from(payload.data)),
    );
  }

  testWidgets('full payloads stay readable by older versions', (tester) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final payload = await service.exportSite(await insertSite('Camp A'));

    expect(payload.version, 8);
    expect(payload.usesReferences, isFalse);
    final same = payload.withReferences(
      includePersonnelDetails: true,
      includeSiteDetails: true,
      projectUuid: 'project-a',
    );
    expect(identical(same, payload), isTrue);
  });

  testWidgets('site names its lead staff and imports where they exist', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final full = await service.exportSite(await insertSite('Camp A'));
    final reduced = roundTrip(
      full.withReferences(
        includePersonnelDetails: false,
        includeSiteDetails: true,
        projectUuid: 'project-a',
      ),
    );

    expect(reduced.version, 9);
    expect(reduced.data.containsKey('personnel'), isFalse);
    expect(reduced.personnelRefs.single, {
      'uuid': 'person-a',
      'name': 'Person A',
      'initial': 'PA',
    });
    expect(reduced.compactEncoded.length, lessThan(full.compactEncoded.length));
    expect((await service.checkReferences(reduced)).blocksImport, isFalse);

    final result = await service.importPayload(reduced);
    final site = await (database.select(
      database.site,
    )..where((row) => row.id.equals(result.recordId))).getSingle();
    expect(site.leadStaffId, 'person-a');
  });

  testWidgets('a missing referenced person blocks the import', (tester) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final full = await service.exportSite(await insertSite('Camp A'));
    final reduced = withData(
      full.withReferences(
        includePersonnelDetails: false,
        includeSiteDetails: true,
        projectUuid: 'project-a',
      ),
      (data) => data
        ..['site'] = {...data['site'] as Map, 'leadStaffId': 'ghost'}
        ..['personnelRefs'] = [
          {'uuid': 'ghost', 'name': 'Ghost', 'initial': 'GH'},
        ],
    );

    final check = await service.checkReferences(reduced);
    expect(check.blocksImport, isTrue);
    expect(check.missingPersonnel.single.label, 'Ghost (GH)');

    final sitesBefore = await database.select(database.site).get();
    await expectLater(
      service.importPayload(reduced),
      throwsA(isA<FormatException>()),
    );
    expect(await database.select(database.site).get(), sitesBefore);
  });

  testWidgets('a person on this device but not in the payload is accepted', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final full = await service.exportSite(await insertSite('Camp A'));
    final withoutPersonnel = withData(
      full,
      (data) => data..remove('personnel'),
    );

    expect(
      (await service.checkReferences(withoutPersonnel)).blocksImport,
      isFalse,
    );
    await service.importPayload(withoutPersonnel);
  });

  testWidgets('event names its site by code and links the single match', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final siteId = await insertSite('Camp A');
    final full = await service.exportEvent(await insertEvent(siteId));
    expect(full.canReferenceSite, isTrue);
    final reduced = roundTrip(
      full.withReferences(
        includePersonnelDetails: false,
        includeSiteDetails: false,
        projectUuid: 'project-a',
      ),
    );

    expect(reduced.hasLinkedSite, isFalse);
    expect(reduced.siteRef, {'projectUuid': 'project-a', 'siteID': 'Camp A'});
    final check = await service.checkReferences(reduced);
    expect(check.siteStatus, SiteReferenceStatus.match);
    expect(check.matchedSiteId, siteId);

    final result = await service.importPayload(reduced);
    final event = await (database.select(
      database.collEvent,
    )..where((row) => row.id.equals(result.recordId))).getSingle();
    expect(event.siteID, siteId);
  });

  testWidgets('event site reference needs a choice when codes repeat', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final siteId = await insertSite('Camp A');
    final reduced = (await service.exportEvent(await insertEvent(siteId)))
        .withReferences(
          includePersonnelDetails: true,
          includeSiteDetails: false,
          projectUuid: 'project-a',
        );
    final duplicate = await insertSite('Camp A');

    final check = await service.checkReferences(reduced);
    expect(check.siteStatus, SiteReferenceStatus.ambiguous);
    expect(check.siteMatchIds, unorderedEquals([siteId, duplicate]));
    expect(check.blocksImport, isFalse);
    await expectLater(
      service.importPayload(reduced),
      throwsA(isA<FormatException>()),
    );

    final result = await service.importPayload(
      reduced,
      linkedSiteId: duplicate,
    );
    final event = await (database.select(
      database.collEvent,
    )..where((row) => row.id.equals(result.recordId))).getSingle();
    expect(event.siteID, duplicate);
  });

  testWidgets('event site reference blocks a missing or foreign site', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final siteId = await insertSite('Camp A');
    final reduced = (await service.exportEvent(await insertEvent(siteId)))
        .withReferences(
          includePersonnelDetails: true,
          includeSiteDetails: false,
          projectUuid: 'project-a',
        );

    final missing = withData(
      reduced,
      (data) =>
          data..['siteRef'] = {'projectUuid': 'project-a', 'siteID': 'Nowhere'},
    );
    final missingCheck = await service.checkReferences(missing);
    expect(missingCheck.siteStatus, SiteReferenceStatus.missing);
    expect(missingCheck.blocksImport, isTrue);
    final eventsBefore = await database.select(database.collEvent).get();
    await expectLater(
      service.importPayload(missing),
      throwsA(isA<FormatException>()),
    );
    expect(await database.select(database.collEvent).get(), eventsBefore);

    final foreign = withData(
      reduced,
      (data) =>
          data..['siteRef'] = {'projectUuid': 'project-b', 'siteID': 'Camp A'},
    );
    final foreignCheck = await service.checkReferences(foreign);
    expect(foreignCheck.siteStatus, SiteReferenceStatus.otherProject);
    expect(foreignCheck.blocksImport, isTrue);
  });

  testWidgets('a site without a code cannot be referenced', (tester) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    final siteId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('project-a')));
    final full = await service.exportEvent(await insertEvent(siteId));

    expect(full.hasLinkedSite, isTrue);
    expect(full.canReferenceSite, isFalse);
    final same = full.withReferences(
      includePersonnelDetails: true,
      includeSiteDetails: false,
      projectUuid: 'project-a',
    );
    expect(same.siteRef, isNull);
    expect(same.hasLinkedSite, isTrue);
  });

  testWidgets('a specimen with a missing cataloger is reported', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(tearDownService);
    const payload = RecordExchangePayload(
      type: RecordExchangeType.specimen,
      data: {
        'specimen': {'catalogerID': 'ghost', 'preparatorID': 'person-a'},
      },
    );

    final check = await service.checkReferences(payload);
    expect(check.missingPersonnel.map((person) => person.uuid), ['ghost']);
  });

  test('version 9 rejects a site reference without a code', () {
    expect(
      () => RecordExchangePayload.parse(
        '{"nahpu_record":"event","version":9,"data":'
        '{"event":{},"siteRef":{"projectUuid":"p"}}}',
      ),
      throwsFormatException,
    );
    expect(
      () => RecordExchangePayload.parse(
        '{"nahpu_record":"site","version":9,"data":'
        '{"site":{},"personnelRefs":[{"name":"No ID"}]}}',
      ),
      throwsFormatException,
    );
  });
}
