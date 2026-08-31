import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/services/export/site_writer.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/record_exchange/record_exchange_service.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/templates/template_field_catalog.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/fossils.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Database database;
  late WidgetRef widgetRef;
  late int siteId;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await database.customStatement('PRAGMA foreign_keys = ON');
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('a'), name: Value('Project A')),
        );
    siteId = await database
        .into(database.site)
        .insert(
          const SiteCompanion(projectUuid: Value('a'), siteID: Value('Quarry')),
        );
  });
  tearDown(() => database.close());

  Future<void> pumpService(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: Consumer(
          builder: (context, ref, _) {
            widgetRef = ref;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    widgetRef.read(projectUuidProvider.notifier).updateProjectUuid('a');
  }

  test(
    'rapid first writes create one row and preserve independent fields',
    () async {
      final query = FossilSiteQuery(database);
      expect(await query.getFossilSiteBySiteId(siteId), isNull);
      await Future.wait([
        query.save(
          siteId,
          const FossilSiteCompanion(rockType: Value('Mudstone')),
        ),
        query.save(
          siteId,
          const FossilSiteCompanion(formation: Value('Hell Creek')),
        ),
        query.save(
          siteId,
          const FossilSiteCompanion(sedimentologyRemark: Value('Oxidized')),
        ),
      ]);
      final rows = await database.select(database.fossilSite).get();
      expect(rows, hasLength(1));
      expect(rows.single.rockType, 'Mudstone');
      expect(rows.single.formation, 'Hell Creek');
      expect(rows.single.sedimentologyRemark, 'Oxidized');
      expect(database.schemaVersion, 21);
    },
  );

  testWidgets('duplicate and delete retain geography and all fossil fields', (
    tester,
  ) async {
    await pumpService(tester);
    await FossilSiteQuery(database).save(
      siteId,
      const FossilSiteCompanion(
        rockType: Value('Limestone'),
        formation: Value('Formation'),
        depositionalEnvironmentType: Value(1),
        depositionalMarine: Value('Carbonate'),
        standardPreservationType: Value('Silicification'),
      ),
    );
    final service = SiteServices(ref: widgetRef);
    final copyId = (await service.duplicateSite(siteId))!;
    final copy = await FossilSiteQuery(database).getFossilSiteBySiteId(copyId);
    expect(copy!.siteID, copyId);
    expect(copy.formation, 'Formation');
    expect(copy.depositionalMarine, 'Carbonate');
    await service.deleteSite(copyId);
    expect(
      await FossilSiteQuery(database).getFossilSiteBySiteId(copyId),
      isNull,
    );
    expect(
      await FossilSiteQuery(database).getFossilSiteBySiteId(siteId),
      isNotNull,
    );
    await service.deleteAllSites('a');
    expect(await database.select(database.fossilSite).get(), isEmpty);
    expect(await database.select(database.site).get(), isEmpty);
  });

  testWidgets('site and event packages remap fossil-site ownership', (
    tester,
  ) async {
    await pumpService(tester);
    final query = FossilSiteQuery(database);
    await query.save(
      siteId,
      const FossilSiteCompanion(
        rockType: Value('Sandstone'),
        formation: Value('Formation'),
        sedimentologyRemark: Value('Cross-bedded'),
      ),
    );
    final exchange = RecordExchangeService(ref: widgetRef);
    final payload = await exchange.exportSite(siteId);
    expect(payload.data['fossilSite'], isNot(contains('siteID')));
    final parsed = RecordExchangePayload.parse(payload.compactEncoded);
    final imported = await exchange.importPayload(parsed);
    final importedFossil = await query.getFossilSiteBySiteId(imported.recordId);
    expect(imported.recordId, isNot(siteId));
    expect(importedFossil!.siteID, imported.recordId);
    expect(importedFossil.sedimentologyRemark, 'Cross-bedded');
    final eventId = await database
        .into(database.collEvent)
        .insert(
          CollEventCompanion(
            projectUuid: const Value('a'),
            siteID: Value(siteId),
          ),
        );
    final event = await exchange.exportEvent(eventId);
    final result = await exchange.importPayload(
      RecordExchangePayload.parse(event.compactEncoded),
      createEmbeddedSite: true,
    );
    final importedEvent = await (database.select(
      database.collEvent,
    )..where((row) => row.id.equals(result.recordId))).getSingle();
    expect(importedEvent.siteID, isNot(siteId));
    expect(
      (await query.getFossilSiteBySiteId(importedEvent.siteID!))!.rockType,
      'Sandstone',
    );
  });

  testWidgets(
    'older site packages remain accepted and replace fossil data cleanly',
    (tester) async {
      await pumpService(tester);
      await FossilSiteQuery(
        database,
      ).save(siteId, const FossilSiteCompanion(rockType: Value('Old')));
      final payload = RecordExchangePayload(
        type: RecordExchangeType.site,
        data: {
          'site': {'siteID': 'Legacy site'},
          'coordinates': <Object>[],
          'personnel': <Object>[],
        },
      );
      await RecordExchangeService(
        ref: widgetRef,
      ).importPayload(payload, targetId: siteId);
      expect(
        await FossilSiteQuery(database).getFossilSiteBySiteId(siteId),
        isNull,
      );
      expect(
        (await SiteQuery(database).getSiteById(siteId)).siteID,
        'Legacy site',
      );
    },
  );

  testWidgets('site exports and template fields include sedimentology', (
    tester,
  ) async {
    await pumpService(tester);
    await FossilSiteQuery(database).save(
      siteId,
      const FossilSiteCompanion(
        rockType: Value('Limestone'),
        sedimentologyRemark: Value('Reworked'),
      ),
    );
    final columns = await SiteWriterServices(
      ref: widgetRef,
    ).getSiteDetails(siteId);
    expect(columns, hasLength(siteExportList.length));
    expect(
      columns[siteExportList.indexOf('fossilSite::rockType')],
      'Limestone',
    );
    final site = await SiteQuery(database).getSiteById(siteId);
    final fields = await documentFieldValuesForSite(database, site, widgetRef);
    expect(fields['fossilSite::sedimentologyRemark'], 'Reworked');
    for (final type in [
      RecordType.site,
      RecordType.collEvent,
      RecordType.specimenRecord,
    ]) {
      expect(
        availableTemplateFieldGroups(database, type)['fossilSite'],
        contains('fossilSite::rockType'),
      );
    }
  });

  test(
    'fossil defaults supplement configured and stored site vocabulary',
    () async {
      SharedPreferences.setMockInitialValues({catalogFmtPrefKey: 'Fossils'});
      final prefs = await SharedPreferences.getInstance();
      await (database.update(database.site)
            ..where((row) => row.id.equals(siteId)))
          .write(const SiteCompanion(siteType: Value('Legacy outcrop')));
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(prefs),
          userDefinedFieldProvider(
            siteTypePrefKey,
          ).overrideWith((ref) async => ['Custom quarry']),
        ],
      );
      addTearDown(container.dispose);
      final options = await container.read(
        effectiveUserDefinedFieldProvider(siteTypePrefKey).future,
      );
      expect(options.first, 'Custom quarry');
      expect(
        options,
        containsAll([...defaultFossilSiteTypes, 'Legacy outcrop']),
      );
      await container
          .read(catalogFmtNotifierProvider.notifier)
          .set(CatalogFmt.birds);
      final extant = await container.read(
        effectiveUserDefinedFieldProvider(siteTypePrefKey).future,
      );
      expect(extant, ['Custom quarry', 'Legacy outcrop']);
    },
  );
}
