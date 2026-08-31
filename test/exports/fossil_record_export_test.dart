import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/export/record_writer.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Database database;
  late Directory outputDirectory;
  late SharedPreferences preferences;
  late WidgetRef widgetRef;

  setUpAll(() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final libraryPath = Platform.isMacOS
          ? 'rust/target/debug/librust_lib_nahpu.dylib'
          : Platform.isWindows
          ? 'rust/target/debug/rust_lib_nahpu.dll'
          : 'rust/target/debug/librust_lib_nahpu.so';
      await RustLib.init(externalLibrary: ExternalLibrary.open(libraryPath));
    } else {
      await RustLib.init();
    }
  });

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await database.customStatement('PRAGMA foreign_keys = ON');
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project'),
            name: Value('Project'),
          ),
        );
    outputDirectory = Directory.systemTemp.createTempSync(
      'nahpu-fossil-export-',
    );
    SharedPreferences.setMockInitialValues({catalogFmtPrefKey: 'Fossils'});
    preferences = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await database.close();
    await outputDirectory.delete(recursive: true);
  });

  Future<void> pumpService(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(preferences),
          fieldIdModeNotifierProvider.overrideWith(_PersonnelFieldIds.new),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            widgetRef = ref;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    widgetRef.read(projectUuidProvider.notifier).updateProjectUuid('project');
  }

  Future<Map<String, dynamic>> exportRecord(
    WidgetTester tester,
    SpecimenRecordType type,
  ) async {
    final file = File('${outputDirectory.path}/${type.name}.json');
    await tester.runAsync(
      () => SpecimenRecordWriter(
        ref: widgetRef,
        recordType: type,
      ).writeRecordDelimited(file, ExportFmt.json),
    );
    final rows = jsonDecode(file.readAsStringSync()) as List;
    return Map<String, dynamic>.from(rows.single as Map);
  }

  testWidgets(
    'standard fossil export preserves native fields and sedimentology',
    (tester) async {
      await pumpService(tester);
      final service = SpecimenServices(ref: widgetRef);
      final uuid = await service.createSpecimen();
      await service.updateFossilAttribute(
        uuid,
        const FossilAttributeCompanion(
          fossilType: Value('Body fossil'),
          ontogeneticStage: Value('Juvenile'),
          weight: Value(2.5),
          weightUnit: Value('kg'),
          specimenDescription: Value('Partial skeleton'),
          remark: Value('Unidentified'),
        ),
      );
      final siteId = await database
          .into(database.site)
          .insert(const SiteCompanion(projectUuid: Value('project')));
      await FossilSiteQuery(database).save(
        siteId,
        const FossilSiteCompanion(
          rockType: Value('Mudstone'),
          sedimentologyRemark: Value('Cross-bedded'),
        ),
      );
      final eventId = await database
          .into(database.collEvent)
          .insert(
            CollEventCompanion(
              projectUuid: const Value('project'),
              siteID: Value(siteId),
            ),
          );
      await (database.update(database.specimen)
            ..where((row) => row.uuid.equals(uuid)))
          .write(SpecimenCompanion(collEventID: Value(eventId)));

      final record = await exportRecord(tester, SpecimenRecordType.fossils);
      expect(record['measurement::fossilType'], 'Body fossil');
      expect(record['measurement::ontogeneticStage'], 'Juvenile');
      expect(record['measurement::weightUnit'], 'kg');
      expect(record['fossilSite::rockType'], 'Mudstone');
      expect(record['fossilSite::sedimentologyRemark'], 'Cross-bedded');
      expect(record['specimen::genus'], '');
      expect(record.keys, isNot(contains('measurement::totalLength')));
      expect(record.keys.any((key) => key.startsWith('parasite')), isFalse);
      expect(await database.select(database.mammalAttribute).get(), isEmpty);
      final allTaxa = await exportRecord(tester, SpecimenRecordType.allTaxa);
      expect(allTaxa['measurement::fossilType'], 'Body fossil');
    },
  );

  for (final catalog in CatalogFmt.values.where(
    (value) => value != CatalogFmt.fossils,
  )) {
    testWidgets(
      'standard ${catalog.name} export keeps incomplete records aligned',
      (tester) async {
        await pumpService(tester);
        await widgetRef.read(catalogFmtNotifierProvider.notifier).set(catalog);
        final uuid = await SpecimenServices(ref: widgetRef).createSpecimen();
        final recordType = matchCatalogFmtToRecordType(catalog);
        // Retain dev's existing extant export-group labels.
        await (database.update(
          database.specimen,
        )..where((row) => row.uuid.equals(uuid))).write(
          SpecimenCompanion(
            taxonGroup: Value(matchRecordTypeToTaxonGroup(recordType)),
          ),
        );
        final record = await exportRecord(tester, recordType);
        expect(record['specimen::specimenUUID'], uuid);
        expect(record['specimen::genus'], '');
        expect(record['fossilSite::rockType'], '');
        expect(record['media::media'], '');
        expect(record.keys, isNot(contains('measurement::fossilType')));
      },
    );
  }
}

class _PersonnelFieldIds extends FieldIdModeNotifier {
  @override
  Future<FieldIdMode> build() async => FieldIdMode.personnel;
}
