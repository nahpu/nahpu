import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/custom_fields/custom_field_service.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  late Database database;
  late CustomFieldService service;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    service = CustomFieldService(database);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-b'),
            name: Value('Project B'),
          ),
        );
    await database
        .into(database.site)
        .insert(
          const SiteCompanion(
            id: Value(1),
            siteID: Value('A-1'),
            projectUuid: Value('project-a'),
          ),
        );
    await database
        .into(database.collEvent)
        .insert(
          const CollEventCompanion(
            id: Value(30),
            projectUuid: Value('project-a'),
            siteID: Value(1),
          ),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('bird'),
            projectUuid: Value('project-a'),
            taxonGroup: Value('Birds'),
          ),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('mammal'),
            projectUuid: Value('project-a'),
            taxonGroup: Value('Mammals'),
          ),
        );
    await database
        .into(database.specimenPart)
        .insert(
          const SpecimenPartCompanion(
            id: Value(10),
            specimenUuid: Value('bird'),
          ),
        );
    await database
        .into(database.parasite)
        .insert(
          const ParasiteCompanion(
            id: Value(20),
            specimenUuid: Value('mammal'),
            parasiteUuid: Value('parasite-20'),
          ),
        );
  });

  tearDown(() => database.close());

  test('filters global and project definitions by catalog and order', () async {
    final global = await service.createDefinition(
      const CustomFieldDraft(
        name: 'Global first',
        type: FieldType.text,
        placement: FieldUISection.specimenAttribute,
        scope: FieldScope.global,
      ),
    );
    final project = await service.createDefinition(
      const CustomFieldDraft(
        name: 'Bird only',
        type: FieldType.text,
        placement: FieldUISection.specimenAttribute,
        scope: FieldScope.project,
        projectUuid: 'project-a',
        catalogFormat: CatalogFmt.birds,
      ),
    );

    expect(
      (await service.getDefinitionsForSpecimenContext(
        placement: FieldUISection.specimenAttribute,
        specimenUuid: 'bird',
      )).map((field) => field.id),
      [global.id, project.id],
    );
    expect(
      (await service.getDefinitionsForSpecimenContext(
        placement: FieldUISection.specimenAttribute,
        specimenUuid: 'mammal',
      )).map((field) => field.id),
      [global.id],
    );
  });

  test('creation context follows the actual owner and host specimen', () async {
    final site = await service.getCreationContext(
      const CustomFieldOwner.site(1),
    );
    final specimen = await service.getCreationContext(
      const CustomFieldOwner.specimen('bird'),
    );
    final part = await service.getCreationContext(
      const CustomFieldOwner.specimenPart(10),
    );
    final parasite = await service.getCreationContext(
      const CustomFieldOwner.parasite(20),
    );

    expect(site.projectUuid, 'project-a');
    expect(site.catalogFormat, null);
    expect(specimen.projectUuid, 'project-a');
    expect(specimen.catalogFormat, CatalogFmt.birds);
    expect(part.projectUuid, 'project-a');
    expect(part.catalogFormat, CatalogFmt.birds);
    expect(parasite.projectUuid, 'project-a');
    expect(parasite.catalogFormat, CatalogFmt.mammals);
  });

  test(
    'definitions can be reordered and archived within their location',
    () async {
      final first = await service.createDefinition(
        const CustomFieldDraft(
          name: 'First',
          type: FieldType.text,
          placement: FieldUISection.siteAttribute,
          scope: FieldScope.global,
        ),
      );
      final second = await service.createDefinition(
        const CustomFieldDraft(
          name: 'Second',
          type: FieldType.text,
          placement: FieldUISection.siteAttribute,
          scope: FieldScope.global,
        ),
      );

      await service.reorder([second.id!, first.id!]);
      expect(
        (await service.getDefinitions(
          placement: FieldUISection.siteAttribute,
        )).map((definition) => definition.name),
        ['Second', 'First'],
      );

      await service.setArchived(second.id!, true);
      expect(
        (await service.getDefinitions(
          placement: FieldUISection.siteAttribute,
        )).map((definition) => definition.name),
        ['First'],
      );
      expect(
        (await service.getDefinitions(
          placement: FieldUISection.siteAttribute,
          includeArchived: true,
        )).map((definition) => definition.name),
        ['Second', 'First'],
      );
    },
  );

  test('enforces owner placement, project, and one value per owner', () async {
    final definition = await service.createDefinition(
      const CustomFieldDraft(
        name: 'Canopy',
        type: FieldType.number,
        placement: FieldUISection.siteAttribute,
        scope: FieldScope.project,
        projectUuid: 'project-a',
      ),
    );
    await service.setValue(
      const CustomFieldOwner.site(1),
      definition.id!,
      '10',
    );
    await service.setValue(
      const CustomFieldOwner.site(1),
      definition.id!,
      '11',
    );
    expect(
      await database.select(database.customFieldValue).get(),
      hasLength(1),
    );
    expect(
      (await database.select(database.customFieldValue).getSingle()).value,
      '11',
    );
    await expectLater(
      service.setValue(
        const CustomFieldOwner.specimen('bird'),
        definition.id!,
        '12',
      ),
      throwsA(isA<CustomFieldValidationException>()),
    );
  });

  test(
    'environment fields use event ownership without catalog filtering',
    () async {
      final definition = await service.createDefinition(
        const CustomFieldDraft(
          name: 'Wind direction',
          type: FieldType.text,
          placement: FieldUISection.environmentalData,
          scope: FieldScope.project,
          projectUuid: 'project-a',
          catalogFormat: CatalogFmt.birds,
        ),
      );
      expect(definition.catalogFormat, isNull);

      const owner = CustomFieldOwner.environment(30);
      final context = await service.getCreationContext(owner);
      expect(context.projectUuid, 'project-a');
      expect(context.catalogFormat, isNull);

      await service.setValue(owner, definition.id!, 'North');
      await service.setValue(owner, definition.id!, 'South');
      final value = await database
          .select(database.customFieldValue)
          .getSingle();
      expect(value.eventId, 30);
      expect(value.value, 'South');
      expect(value.siteId, isNull);
    },
  );

  test('all to a specific catalog requires every value to match', () async {
    final definition = await service.createDefinition(
      const CustomFieldDraft(
        name: 'Score',
        type: FieldType.number,
        placement: FieldUISection.specimenAttribute,
        scope: FieldScope.global,
      ),
    );
    await service.setValue(
      const CustomFieldOwner.specimen('bird'),
      definition.id!,
      '1',
    );
    await service.setValue(
      const CustomFieldOwner.specimen('mammal'),
      definition.id!,
      '2',
    );
    await expectLater(
      service.updateDefinition(
        definition.id!,
        const CustomFieldDraft(
          name: 'Score',
          type: FieldType.number,
          placement: FieldUISection.specimenAttribute,
          scope: FieldScope.global,
          catalogFormat: CatalogFmt.birds,
        ),
      ),
      throwsA(isA<CustomFieldValidationException>()),
    );
  });

  test('safe conversions are atomic and report incompatible values', () async {
    final definition = await service.createDefinition(
      const CustomFieldDraft(
        name: 'Flag',
        type: FieldType.text,
        placement: FieldUISection.specimenAttribute,
        scope: FieldScope.global,
      ),
    );
    await service.setValue(
      const CustomFieldOwner.specimen('bird'),
      definition.id!,
      'yes',
    );
    await service.setValue(
      const CustomFieldOwner.specimen('mammal'),
      definition.id!,
      'maybe',
    );
    const booleanDraft = CustomFieldDraft(
      name: 'Flag',
      type: FieldType.boolean,
      placement: FieldUISection.specimenAttribute,
      scope: FieldScope.global,
    );
    await expectLater(
      service.updateDefinition(definition.id!, booleanDraft),
      throwsA(isA<CustomFieldValidationException>()),
    );
    expect(
      (await database.select(database.customFieldDefinition).getSingle()).type,
      'text',
    );
    final mammalValue = await (database.select(
      database.customFieldValue,
    )..where((row) => row.specimenUuid.equals('mammal'))).getSingle();
    await service.setValue(
      const CustomFieldOwner.specimen('mammal'),
      definition.id!,
      null,
    );
    expect(mammalValue.value, 'maybe');
    await service.updateDefinition(definition.id!, booleanDraft);
    expect(
      (await database.select(database.customFieldValue).getSingle()).value,
      'true',
    );
  });

  test(
    'dropdown renames retain stable selections and deletion is guarded',
    () async {
      final option = CustomFieldOption.create('Old label');
      final definition = await service.createDefinition(
        CustomFieldDraft(
          name: 'Habitat code',
          type: FieldType.dropdown,
          placement: FieldUISection.siteAttribute,
          scope: FieldScope.global,
          options: [option],
        ),
      );
      await service.setValue(
        const CustomFieldOwner.site(1),
        definition.id!,
        option.uuid,
      );
      await service.updateDefinition(
        definition.id!,
        CustomFieldDraft(
          name: 'Habitat code',
          type: FieldType.dropdown,
          placement: FieldUISection.siteAttribute,
          scope: FieldScope.global,
          options: [option.copyWith(label: 'New label')],
        ),
      );
      final updated = await database
          .select(database.customFieldDefinition)
          .getSingle();
      final value = await database
          .select(database.customFieldValue)
          .getSingle();
      expect(value.value, option.uuid);
      expect(updated.displayValue(value.value), 'New label');
      await expectLater(
        service.deleteDefinition(definition.id!),
        throwsA(isA<CustomFieldValidationException>()),
      );
      await service.setValue(
        const CustomFieldOwner.site(1),
        definition.id!,
        null,
      );
      await service.deleteDefinition(definition.id!);
      expect(
        await database.select(database.customFieldDefinition).get(),
        isEmpty,
      );
    },
  );
}
