import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/exports/bundle_records.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/dwc_bundle.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/src/rust/api/dwc.dart' as rust_dwc;
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/rust_library.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(initRustLibForTest);

  test('normalizes current and legacy bundle taxon labels', () {
    expect(normalizeBundleTaxonGroup('Avians'), 'Birds');
    expect(normalizeBundleTaxonGroup('General Mammals'), 'Mammals');
    expect(normalizeBundleTaxonGroup('Non-Bat Mammals'), 'Mammals');
    expect(normalizeBundleTaxonGroup('Bats'), 'Bats');
    expect(normalizeBundleTaxonGroup('Herpetofauna'), 'Herpetofauna');
    expect(normalizeBundleTaxonGroup('Fishes'), 'Fishes');
    expect(normalizeBundleTaxonGroup('Ichthyology'), 'Fishes');
    expect(normalizeBundleTaxonGroup('Arthropoda'), 'Invertebrates');
    expect(normalizeBundleTaxonGroup('Arthropods'), 'Invertebrates');
    expect(normalizeBundleTaxonGroup('Invertebrates'), 'Invertebrates');
    expect(normalizeBundleTaxonGroup('Insects'), 'Invertebrates');
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

    for (final definition in <List<Object?>>[
      ['cf-unmapped', 'Field notebook page', null, null, null],
      [
        'cf-direct',
        'Collector note',
        'occurrence',
        'dwc:occurrenceRemarks',
        'direct',
      ],
      [
        'cf-assertion',
        'Tail condition',
        'occurrence',
        'dwc:occurrenceRemarks',
        'assertion',
      ],
    ]) {
      final id = await database
          .into(database.customFieldDefinition)
          .insert(
            CustomFieldDefinitionCompanion(
              uuid: Value(definition[0]! as String),
              name: Value(definition[1]! as String),
              type: const Value('text'),
              uiSection: const Value('specimenAttribute'),
              scope: const Value('project'),
              projectUuid: const Value('project-dwc'),
              dwcTarget: Value(definition[2] as String?),
              dwcField: Value(definition[3] as String?),
              dwcMode: Value(definition[4] as String?),
            ),
          );
      await database
          .into(database.customFieldValue)
          .insert(
            CustomFieldValueCompanion(
              fieldDefinitionId: Value(id),
              projectUuid: const Value('project-dwc'),
              specimenUuid: const Value('specimen-dwc'),
              value: Value('value for ${definition[0]}'),
            ),
          );
    }

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
        'occurrence_pk',
        'identificationVerificationStatus',
        'reproductiveCondition',
        'identifiedByID',
      }),
    );
    // The Data Package Occurrence class is thin: determination ranks belong to
    // `identification`, and location and collecting values belong to `event`.
    expect(
      files['occurrence.csv']!.columns,
      isNot(
        anyOf(
          contains('catalogNumber'),
          contains('basisOfRecord'),
          contains('genus'),
          contains('decimalLatitude'),
          contains('samplingProtocol'),
        ),
      ),
    );
    expect(
      files['identification.csv']!.columns,
      containsAll(<String>{'occurrence_fk', 'genus', 'scientificName'}),
    );
    expect(files['event.csv']!.columns, contains('eventRemarks'));
    expect(
      files['event.csv']!.columns,
      isNot(anyOf(contains('eventConductedBy'), contains('samplingProtocol'))),
    );
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

    // A custom field with no Darwin Core term is withheld, not blobbed into
    // dynamicProperties, and the user is told where the value still lives.
    expect(
      files['occurrence.csv']!.columns,
      isNot(contains('dynamicProperties')),
    );
    final withheld = manifest.warnings.singleWhere(
      (warning) => warning.contains('Field notebook page'),
    );
    expect(withheld, contains('NAHPU Data Package'));
    expect(withheld, isNot(contains('Collector note')));
    expect(withheld, isNot(contains('Tail condition')));
    expect(files['occurrence.csv']!.columns, contains('occurrenceRemarks'));
    expect(
      files['occurrence-assertion.csv']!.columns,
      containsAll(<String>{'assertionType', 'assertionValue'}),
    );
  });

  testWidgets('every planned bundle column is a registered term', (
    tester,
  ) async {
    final registered = <String>{};
    for (final column
        in await tester.runAsync(rust_dwc.dwcBundleColumns) ?? []) {
      registered.add('${column.profile}:${column.table}:${column.header}');
    }
    expect(registered, isNotEmpty);

    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-guard'),
            name: Value('Guard project'),
          ),
        );
    final eventId = await database
        .into(database.collEvent)
        .insert(
          const CollEventCompanion(
            projectUuid: Value('project-guard'),
            startDate: Value('2026-08-20'),
          ),
        );
    await database
        .into(database.specimen)
        .insert(
          SpecimenCompanion(
            uuid: const Value('specimen-guard'),
            projectUuid: const Value('project-guard'),
            taxonGroup: const Value('Mammals'),
            collEventID: Value(eventId),
          ),
        );
    await database
        .into(database.specimenPart)
        .insert(
          const SpecimenPartCompanion(
            specimenUuid: Value('specimen-guard'),
            type: Value('tissue'),
            count: Value('1'),
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
        .updateProjectUuid('project-guard');

    for (final format in <DwcBundleFormat>[
      DwcBundleFormat.darwinCoreArchive,
      DwcBundleFormat.darwinCoreDataPackage,
    ]) {
      final profile = format == DwcBundleFormat.darwinCoreArchive
          ? 'archive'
          : 'data_package';
      final manifest = (await tester.runAsync(
        () => DwcBundleWriter(ref: widgetRef!).plan(
          format: format,
          archiveFormat: format.defaultArchive,
          selectedTaxonGroups: const {'Mammals'},
        ),
      ))!;
      var checked = 0;
      for (final file in manifest.files) {
        if (!file.path.endsWith('.csv')) continue;
        final table = file.path.substring(0, file.path.length - 4);
        for (final header in file.columns) {
          expect(
            registered,
            contains('$profile:$table:$header'),
            reason: '$profile $table.$header is not a registered term',
          );
          checked++;
        }
      }
      expect(checked, greaterThan(10), reason: '$profile planned no columns');
      if (format == DwcBundleFormat.darwinCoreArchive) {
        final paths = manifest.files.map((file) => file.path).toSet();
        expect(paths, isNot(contains('event.csv')));
        expect(paths, isNot(contains('agent.csv')));
        expect(paths, isNot(contains('identification.csv')));
      }
    }
  });

  test('NAHPU package maps every SQLite enum index with table context', () {
    final mappings = buildNahpuSqliteEnumMappings();
    final keys = mappings
        .map(
          (mapping) =>
              '${mapping['table']}.${mapping['column']}:${mapping['sqlite_index']}',
        )
        .toSet();

    expect(mappings, hasLength(92));
    expect(keys, hasLength(mappings.length));
    expect(
      buildNahpuSqliteEnumMappings(
        tables: const {'specimen'},
      ).map((mapping) => mapping['table']).toSet(),
      <String>{'specimen'},
    );
    expect(buildNahpuSqliteEnumMappings(tables: const {}), isEmpty);
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

    final invertebrateFemale = mappings.singleWhere(
      (mapping) =>
          mapping['table'] == 'invertebrateAttribute' &&
          mapping['column'] == 'sex' &&
          mapping['sqlite_index'] == 1,
    );
    expect(invertebrateFemale['enum_name'], 'female');
    expect(invertebrateFemale['display_name'], 'Female');

    final invertebrateWorker = mappings.singleWhere(
      (mapping) =>
          mapping['table'] == 'invertebrateAttribute' &&
          mapping['column'] == 'caste' &&
          mapping['sqlite_index'] == 8,
    );
    expect(invertebrateWorker['enum_type'], 'InvertebrateCaste');
    expect(invertebrateWorker['enum_name'], 'worker');
    expect(invertebrateWorker['display_name'], 'worker');

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
