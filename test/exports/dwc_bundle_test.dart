import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:nahpu/screens/exports/bundle_records.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/dwc_bundle.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final dylibPath = Platform.isMacOS
          ? 'rust/target/debug/librust_lib_nahpu.dylib'
          : Platform.isWindows
          ? 'rust/target/debug/rust_lib_nahpu.dll'
          : 'rust/target/debug/librust_lib_nahpu.so';
      await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
    } else {
      await RustLib.init();
    }
  });

  test('normalizes current and legacy bundle taxon labels', () {
    expect(normalizeBundleTaxonGroup('Avians'), 'Birds');
    expect(normalizeBundleTaxonGroup('General Mammals'), 'Mammals');
    expect(normalizeBundleTaxonGroup('Non-Bat Mammals'), 'Mammals');
    expect(normalizeBundleTaxonGroup('Bats'), 'Bats');
    expect(normalizeBundleTaxonGroup('Herpetofauna'), 'Herpetofauna');
    expect(normalizeBundleTaxonGroup('Arthropoda'), 'Arthropods');
    expect(normalizeBundleTaxonGroup('Insects'), 'Arthropods');
  });

  test('bundle types expose valid archive choices and extensions', () {
    expect(DwcBundleFormat.darwinCoreArchive.allowedArchives, {
      BundleArchiveFormat.zip,
    });
    expect(
      DwcBundleFormat.darwinCoreDataPackage.defaultArchive,
      BundleArchiveFormat.tarGzip,
    );
    expect(DwcBundleFormat.nahpuDataPackage.usesTaxonSelection, isFalse);
    expect(
      DwcBundleFormat.darwinCoreDataPackage.outputExtension(
        BundleArchiveFormat.tarGzip,
      ),
      'dwc-dp.tar.gz',
    );
    expect(
      DwcBundleFormat.nahpuDataPackage.outputExtension(BundleArchiveFormat.zip),
      'nahpu-dp.zip',
    );
  });

  testWidgets('DwC-DP plan includes aligned occurrence and material fields', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-dwc'),
            name: Value('Darwin Core project'),
          ),
        );
    final eventId = await database
        .into(database.collEvent)
        .insert(
          const CollEventCompanion(
            projectUuid: Value('project-dwc'),
            startDate: Value('2026-08-20'),
          ),
        );
    await database
        .into(database.environment)
        .insert(
          EnvironmentCompanion(
            eventID: Value(eventId),
            ambientTemperature: const Value(24.5),
            notes: const Value('Dry forest edge'),
          ),
        );
    await database
        .into(database.personnel)
        .insert(
          const PersonnelCompanion(
            uuid: Value('identifier-a'),
            name: Value('Identifier A'),
          ),
        );
    final taxonId = await database
        .into(database.taxonomy)
        .insert(
          const TaxonomyCompanion(
            taxonClass: Value('Mammalia'),
            genus: Value('Mus'),
            specificEpithet: Value('musculus'),
          ),
        );
    await database
        .into(database.specimen)
        .insert(
          SpecimenCompanion(
            uuid: const Value('specimen-dwc'),
            projectUuid: const Value('project-dwc'),
            speciesID: Value(taxonId),
            iDConfidence: const Value(2),
            iDMethod: const Value('morphology'),
            taxonGroup: const Value('Mammals'),
            collEventID: Value(eventId),
          ),
        );
    await database
        .into(database.mammalAttribute)
        .insert(
          const MammalAttributeCompanion(
            specimenUuid: Value('specimen-dwc'),
            reproductiveStage: Value(2),
          ),
        );
    await database
        .into(database.specimenPart)
        .insert(
          const SpecimenPartCompanion(
            specimenUuid: Value('specimen-dwc'),
            type: Value('tissue'),
            count: Value('2'),
            remark: Value('Frozen aliquots'),
          ),
        );
    await database
        .into(database.parasite)
        .insert(
          ParasiteCompanion(
            specimenUuid: const Value('specimen-dwc'),
            speciesID: Value(taxonId),
            identifierID: const Value('identifier-a'),
            parasiteID: const Value('P-1'),
            parasiteUuid: const Value('parasite-dwc'),
            count: const Value(3),
            preparationMethod: const Value('slide'),
            treatment: const Value('stained'),
            anatomicalLocation: const Value('fur'),
            category: const Value('ectoparasite'),
            associationStatus: const Value(1),
            detectionMethod: const Value('visual inspection'),
            dateCollected: const Value('2026-08-20'),
          ),
        );

    WidgetRef? widgetRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, child) {
              widgetRef = ref;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    widgetRef!
        .read(projectUuidProvider.notifier)
        .updateProjectUuid('project-dwc');

    final manifest = (await tester.runAsync(
      () => DwcBundleWriter(ref: widgetRef!).plan(
        format: DwcBundleFormat.darwinCoreDataPackage,
        archiveFormat: BundleArchiveFormat.tarGzip,
        selectedTaxonGroups: const {'Mammals'},
      ),
    ))!;
    final files = {for (final file in manifest.files) file.path: file};

    expect(
      files['occurrence.csv']!.columns,
      containsAll(<String>{
        'identificationVerificationStatus',
        'reproductiveCondition',
        'catalogNumber',
        'individualCount',
        'samplingProtocol',
        'identifiedByID',
      }),
    );
    expect(files['event.csv']!.columns, contains('eventRemarks'));
    expect(
      files['material.csv']!.columns,
      containsAll(<String>{
        'materialEntityRemarks',
        'objectQuantity',
        'objectQuantityType',
      }),
    );
    expect(
      files['organism-interaction.csv']!.columns,
      containsAll(<String>{
        'subjectOccurrence_fk',
        'relatedOccurrence_fk',
        'relatedOrganismPart',
      }),
    );
  });

  test('NAHPU package maps every SQLite enum index with table context', () {
    final mappings = buildNahpuSqliteEnumMappings();
    final keys = mappings
        .map(
          (mapping) =>
              '${mapping['table']}.${mapping['column']}:${mapping['sqlite_index']}',
        )
        .toSet();

    expect(mappings, hasLength(76));
    expect(keys, hasLength(mappings.length));
    final qcf = mappings.singleWhere(
      (mapping) =>
          mapping['table'] == 'mammalAttribute' &&
          mapping['column'] == 'echolocation' &&
          mapping['sqlite_index'] == 2,
    );
    expect(qcf['enum_type'], 'mammals.Echolocation');
    expect(qcf['enum_name'], 'qcf');
    expect(qcf['display_name'], 'QCF');

    final highConfidence = mappings.singleWhere(
      (mapping) =>
          mapping['table'] == 'specimen' &&
          mapping['column'] == 'iDConfidence' &&
          mapping['sqlite_index'] == 2,
    );
    expect(highConfidence['enum_type'], 'IdentificationConfidence');
    expect(highConfidence['enum_name'], 'high');
    expect(highConfidence['display_name'], 'High');

    final arthropodFemale = mappings.singleWhere(
      (mapping) =>
          mapping['table'] == 'arthropodAttribute' &&
          mapping['column'] == 'sex' &&
          mapping['sqlite_index'] == 1,
    );
    expect(arthropodFemale['enum_name'], 'female');
    expect(arthropodFemale['display_name'], 'Female');

    final arthropodWorker = mappings.singleWhere(
      (mapping) =>
          mapping['table'] == 'arthropodAttribute' &&
          mapping['column'] == 'caste' &&
          mapping['sqlite_index'] == 8,
    );
    expect(arthropodWorker['enum_type'], 'ArthropodCaste');
    expect(arthropodWorker['enum_name'], 'worker');
    expect(arthropodWorker['display_name'], 'worker');

    final birdMaleUncertain = mappings.singleWhere(
      (mapping) =>
          mapping['table'] == 'birdAttribute' &&
          mapping['column'] == 'sex' &&
          mapping['sqlite_index'] == 6,
    );
    expect(birdMaleUncertain['enum_name'], 'maleUncertain');
    expect(birdMaleUncertain['display_name'], 'Male?');
  });

  testWidgets('users can switch to selected taxa and change the selection', (
    tester,
  ) async {
    var mode = BundleTaxonSelectionMode.all;
    var selected = <String>{'Birds', 'Mammals', 'Bats'};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => BundleTaxonSelectionCard(
              availableTaxonGroups: const {'Birds', 'Mammals', 'Bats'},
              selectedTaxonGroups: selected,
              selectionMode: mode,
              isLoading: false,
              onModeChanged: (value) => setState(() => mode = value),
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Selected taxa'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Birds'));
    await tester.pump();

    expect(mode, BundleTaxonSelectionMode.selected);
    expect(selected, isNot(contains('Birds')));
    expect(selected, containsAll(<String>{'Mammals', 'Bats'}));
    final batsTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Bats'),
    );
    expect(batsTile.value, isTrue);
    expect(batsTile.onChanged, isNull);
  });

  testWidgets('only files with fields show an expansion control', (
    tester,
  ) async {
    const manifest = DwcBundleManifest(
      files: [
        DwcBundleFile(
          path: 'datapackage.json',
          mediaType: 'application/json',
          records: 0,
          columns: [],
        ),
        DwcBundleFile(
          path: 'occurrence.csv',
          mediaType: 'text/csv',
          records: 1,
          columns: ['occurrenceID'],
        ),
      ],
      warnings: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BundleContentsPane(
            manifest: manifest,
            isLoading: false,
            error: null,
          ),
        ),
      ),
    );

    expect(find.byType(ExpansionTile), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'datapackage.json'), findsOneWidget);
  });

  testWidgets('all taxa selection keeps the taxa card at the panel width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: BundleTaxonSelectionCard(
                availableTaxonGroups: {'Birds', 'Herpetofauna', 'Mammals'},
                selectedTaxonGroups: {'Birds', 'Herpetofauna', 'Mammals'},
                selectionMode: BundleTaxonSelectionMode.all,
                isLoading: false,
                onChanged: _ignoreTaxonGroups,
                onModeChanged: _ignoreSelectionMode,
              ),
            ),
          ),
        ),
      ),
    );

    final card = find.byType(Card);
    expect(tester.getSize(card).width, 500);
    expect(
      tester
          .getCenter(find.byType(SegmentedButton<BundleTaxonSelectionMode>))
          .dx,
      closeTo(tester.getCenter(card).dx, 0.1),
    );
  });

  testWidgets('package contents uses media-type icons', (tester) async {
    const manifest = DwcBundleManifest(
      files: [
        DwcBundleFile(
          path: 'media/specimen.jpg',
          mediaType: 'image/jpeg',
          records: 0,
          columns: [],
        ),
        DwcBundleFile(
          path: 'media/call.wav',
          mediaType: 'audio/wav',
          records: 0,
          columns: [],
        ),
        DwcBundleFile(
          path: 'media/behavior.mp4',
          mediaType: 'video/mp4',
          records: 0,
          columns: [],
        ),
      ],
      warnings: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BundleContentsPane(
            manifest: manifest,
            isLoading: false,
            error: null,
          ),
        ),
      ),
    );

    final icons = tester
        .widgetList<Icon>(find.byType(Icon))
        .map((icon) => icon.icon)
        .toSet();
    expect(icons, contains(Icons.image_outlined));
    expect(icons, contains(Icons.audio_file_outlined));
    expect(icons, contains(Icons.video_file_outlined));
  });

  testWidgets('NAHPU package export handles missing optional tables', (
    tester,
  ) async {
    final tempDir = Directory.systemTemp.createTempSync('nahpu-dp-test-');
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => tempDir.path,
        );
    PackageInfo.setMockInitialValues(
      appName: 'NAHPU',
      packageName: 'org.nahpu.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await tester.runAsync(
      () => rust_config.initConfigDb(path: '${tempDir.path}/configs.db'),
    );
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
    WidgetRef? widgetRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, child) {
              widgetRef = ref;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    widgetRef!
        .read(projectUuidProvider.notifier)
        .updateProjectUuid('project-a');

    final writer = DwcBundleWriter(ref: widgetRef!);
    final manifest = (await tester.runAsync(
      () => writer.plan(
        format: DwcBundleFormat.nahpuDataPackage,
        archiveFormat: BundleArchiveFormat.zip,
        selectedTaxonGroups: const {},
      ),
    ))!;
    final paths = manifest.files.map((file) => file.path).toSet();

    expect(paths, contains('nahpu-project.json'));
    expect(paths, isNot(contains('database/nahpu.sqlite3')));
    expect(paths, contains('mappings/sqlite_enums.csv'));
    expect(paths, contains('vocabularies/parasites.csv'));
    expect(paths, isNot(contains('tables/environment.csv')));
    expect(paths, isNot(contains('tables/parasite.csv')));
    expect(paths, isNot(contains('tables/fossilSite.csv')));
    expect(
      manifest.files
          .where((file) => file.path.startsWith('tables/'))
          .every((file) => file.records > 0),
      isTrue,
    );

    for (final archive in BundleArchiveFormat.values) {
      final extension = archive == BundleArchiveFormat.zip ? 'zip' : 'tar.gz';
      final outputPath = '${tempDir.path}/empty.nahpu-dp.$extension';
      final written = await tester.runAsync(
        () => writer.write(
          format: DwcBundleFormat.nahpuDataPackage,
          archiveFormat: archive,
          selectedTaxonGroups: const {},
          outputPath: outputPath,
        ),
      );

      expect(File(outputPath).existsSync(), isTrue);
      expect(
        written!.files.any((file) => file.path == 'tables/environment.csv'),
        isFalse,
      );
      expect(
        written.files.any((file) => file.path == 'tables/parasite.csv'),
        isFalse,
      );
      expect(
        written.files.any((file) => file.path == 'tables/fossilSite.csv'),
        isFalse,
      );
      expect(
        written.files
            .where((file) => file.path.startsWith('tables/'))
            .every((file) => file.records > 0),
        isTrue,
      );
      expect(
        written.files.any((file) => file.path == 'tables/geography.csv'),
        isFalse,
      );
    }
  });
}

void _ignoreTaxonGroups(Set<String> _) {}

void _ignoreSelectionMode(BundleTaxonSelectionMode _) {}
