import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/parasite_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/settings/user_config_settings_service.dart';
import 'package:nahpu/services/settings/user_config_transfer_service.dart';
import 'package:nahpu/services/custom_fields/custom_field_service.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

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

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('nahpu_config_transfer_');
    await rust_config.initConfigDb(path: '${tempDir.path}/nahpu_configs.db');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('JSON.GZ transfer is inspected and imported as JSON', () async {
    const key = 'siteTypes';
    const section = rust_config.UserConfigSection.userConfigs;
    await rust_config.setUserConfigList(key: key, value: ['Forest']);
    final output = File('${tempDir.path}/configs.json.gz');
    const service = UserConfigTransferService();

    await service.export(
      output: output,
      format: UserConfigFileFormat.jsonGzip,
      sections: const {section},
    );
    final bytes = await output.readAsBytes();
    expect(bytes.take(2), [0x1f, 0x8b]);

    final source = await service.inspect(XFile(output.path));
    addTearDown(source.dispose);
    expect(source.preview.includedSections, contains(section));
    expect(
      source.preview.userConfigs.firstWhere((entry) => entry.key == key).values,
      ['Forest'],
    );

    await rust_config.setUserConfigList(key: key, value: ['Ocean']);
    await service.import(source, const {section});
    expect(await rust_config.getUserConfigList(key: key), ['Forest']);
  });

  test('parasite ID settings and vocabularies are redb-backed', () async {
    const service = ParasiteIdServices();
    await service.setPrefix('P-');
    await service.setNumber('7');
    expect(await service.getNewNumber(), 'P-7');
    expect(
      await rust_config.getUserConfigString(key: parasiteIdNumberPrefKey),
      '8',
    );

    await rust_config.setUserConfigList(
      key: parasiteCategoryPrefKey,
      value: ['Ectoparasite'],
    );
    final preview = await rust_config.getConfigExportPreview(
      customFieldTemplates: const [],
    );
    final category = preview.userConfigs.firstWhere(
      (entry) => entry.key == parasiteCategoryPrefKey,
    );
    expect(category.label, 'Parasite categories');
    expect(category.values, ['Ectoparasite']);
    expect(category.isControlledVocabulary, isTrue);
  });

  test('datum defaults are redb-backed and exportable', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final datums = await container.read(
      userDefinedFieldProvider(datumPrefKey).future,
    );
    expect(datums, ['WGS84', 'NAD83', 'NAD27']);
    expect(datums, isNot(contains('Other')));

    final preview = await rust_config.getConfigExportPreview(
      customFieldTemplates: const [],
    );
    final datum = preview.userConfigs.firstWhere(
      (entry) => entry.key == datumPrefKey,
    );
    expect(datum.label, 'Datums');
    expect(datum.values, datums);
    expect(datum.isControlledVocabulary, isTrue);
  });

  test('user config settings service persists options and formats', () async {
    const service = UserConfigSettingsService();
    const optionKey = 'testOptions';
    const formatKey = 'testFormat';

    expect(await service.loadOptions(optionKey, const ['Forest']), const [
      'Forest',
    ]);
    await service.addOption(optionKey, 'forest');
    await service.addOption(optionKey, 'Ocean');
    expect(await rust_config.getUserConfigList(key: optionKey), [
      'Forest',
      'Ocean',
    ]);

    await service.removeOption(optionKey, 'Ocean');
    expect(await rust_config.getUserConfigList(key: optionKey), ['Forest']);
    await service.replaceOptions(optionKey, const ['Desert']);
    expect(await rust_config.getUserConfigList(key: optionKey), ['Desert']);
    await service.clearOptions(optionKey);
    expect(await rust_config.getUserConfigList(key: optionKey), isNull);

    expect(await service.loadTextCaseFormat(formatKey, 'anyCase'), 'anyCase');
    await service.setTextCaseFormat(formatKey, 'titleCase');
    expect(await rust_config.getUserConfigString(key: formatKey), 'titleCase');
  });

  test('project field ID auto-increment is a labeled user config', () async {
    await rust_config.setUserConfigString(
      key: projectFieldIdAutoIncrementPrefKey,
      value: true.toString(),
    );

    final preview = await rust_config.getConfigExportPreview(
      customFieldTemplates: const [],
    );
    final setting = preview.userConfigs.firstWhere(
      (entry) => entry.key == projectFieldIdAutoIncrementPrefKey,
    );
    expect(setting.label, 'Auto-increment project field ID');
    expect(setting.value, 'true');
  });

  test(
    'custom field templates strip scope and import to one destination',
    () async {
      final database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(
              uuid: Value('project-a'),
              name: Value('Project A'),
            ),
          );
      final customFields = CustomFieldService(database);
      final definition = await customFields.createDefinition(
        const CustomFieldDraft(
          name: 'Canopy cover',
          type: FieldType.number,
          placement: FieldUISection.siteAttribute,
          scope: FieldScope.global,
        ),
      );
      const transfer = UserConfigTransferService();
      final output = File('${tempDir.path}/custom-fields.json');
      await transfer.export(
        output: output,
        format: UserConfigFileFormat.json,
        sections: const {rust_config.UserConfigSection.customFields},
        database: database,
        selectedDefinitionIds: {definition.id!},
      );
      final source = await transfer.inspect(XFile(output.path));
      addTearDown(source.dispose);
      expect(source.preview.schemaVersion, 4);
      expect(source.preview.customFields.single.label, 'Canopy cover');
      await customFields.deleteDefinition(definition.id!);

      await transfer.import(
        source,
        const {rust_config.UserConfigSection.customFields},
        database: database,
        destination: UserConfigImportDestination.currentProject,
        projectUuid: 'project-a',
      );
      final definitions = await database
          .select(database.customFieldDefinition)
          .get();
      expect(definitions, hasLength(1));
      final imported = definitions.single;
      expect(imported.projectUuid, 'project-a');
      expect(imported.sourceTemplateUuid, definition.uuid);
      expect(imported.isArchived, 0);

      await transfer.import(
        source,
        const {rust_config.UserConfigSection.customFields},
        database: database,
        destination: UserConfigImportDestination.currentProject,
        projectUuid: 'project-a',
      );
      expect(
        await database.select(database.customFieldDefinition).get(),
        hasLength(1),
      );
    },
  );

  test('custom field QR payload contains only selected templates', () async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final customFields = CustomFieldService(database);
    final included = await customFields.createDefinition(
      const CustomFieldDraft(
        name: 'Included field',
        type: FieldType.text,
        placement: FieldUISection.siteAttribute,
        scope: FieldScope.global,
      ),
    );
    await customFields.createDefinition(
      const CustomFieldDraft(
        name: 'Excluded field',
        type: FieldType.boolean,
        placement: FieldUISection.siteAttribute,
        scope: FieldScope.global,
      ),
    );

    const transfer = UserConfigTransferService();
    final payload = await transfer.exportCustomFieldPayload(
      database: database,
      projectUuid: null,
      selectedDefinitionIds: {included.id!},
    );
    final source = await transfer.inspectCustomFieldPayload(payload);
    addTearDown(source.dispose);

    expect(source.preview.schemaVersion, 4);
    expect(source.preview.customFields, hasLength(1));
    expect(source.preview.customFields.single.label, 'Included field');
  });

  testWidgets(
    'project field IDs preserve separators and increment atomically',
    (tester) async {
      final database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
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
      await tester.pump();
      widgetRef!
          .read(projectUuidProvider.notifier)
          .updateProjectUuid('project-a');
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(
              uuid: Value('project-a'),
              name: Value('Project A'),
              catalogNumberPrefix: Value('P '),
              currentCatalogNumber: Value(12),
              catalogNumberSuffix: Value(' X'),
            ),
          );
      await database
          .into(database.personnel)
          .insert(
            const PersonnelCompanion(
              uuid: Value('cataloger-a'),
              name: Value('Cataloger A'),
              currentFieldNumber: Value(20),
              isRegisterField: Value(true),
            ),
          );
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('specimen-a'),
              projectUuid: Value('project-a'),
              fieldNumber: Value(4),
            ),
          );
      await tester.runAsync(() async {
        await rust_config.setUserConfigString(
          key: projectFieldIdAutoIncrementPrefKey,
          value: true.toString(),
        );

        final service = ProjectFieldIdServices(ref: widgetRef!);
        expect(await service.takeNextNumber(), 12);
        final project = await service.getProject();
        expect(project.currentCatalogNumber, 13);
        expect(formatProjectFieldId(project, 12), 'P 12 X');

        final specimenService = SpecimenServices(ref: widgetRef!);
        await specimenService.setProjectFieldIdentifier(
          specimenUuid: 'specimen-a',
          projectFieldNumber: 2,
        );
        var specimen = await specimenService.getSpecimen('specimen-a');
        expect(specimen.fieldNumber, isNull);
        expect(specimen.projectFieldNumber, 2);
        expect((await service.getProject()).currentCatalogNumber, 13);

        await specimenService.setPersonnelFieldIdentifier(
          specimenUuid: 'specimen-a',
          catalogerUuid: 'cataloger-a',
          fieldNumber: 1,
        );
        specimen = await specimenService.getSpecimen('specimen-a');
        expect(specimen.fieldNumber, 1);
        expect(specimen.projectFieldNumber, isNull);
        final cataloger = await (database.select(
          database.personnel,
        )..where((row) => row.uuid.equals('cataloger-a'))).getSingle();
        expect(cataloger.currentFieldNumber, 20);
      });
    },
  );

  test('project mode is reset to the default off state once', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await rust_config.setUserConfigString(
      key: fieldIdModePrefKey,
      value: FieldIdMode.project.name,
    );
    final container = ProviderContainer(
      overrides: [settingProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(fieldIdModeNotifierProvider.future),
      FieldIdMode.personnel,
    );
    expect(
      await rust_config.getUserConfigString(key: fieldIdModePrefKey),
      FieldIdMode.personnel.name,
    );
    expect(prefs.getBool(fieldIdModeDefaultMigratedPrefKey), isTrue);
  });
}
