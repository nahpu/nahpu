import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/parasite_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  test('v19 specimen vocabularies keep their canonical default order', () {
    expect(getDefaultOptionsList(idMethodPrefKey), defaultIdMethods);
    expect(getDefaultOptionsList(lifeStagePrefKey), defaultLifeStages);
    expect(defaultIdMethods, [
      'morphology',
      'taxonomy',
      'genomics',
      'mtDNA',
      'unknown',
    ]);
  });

  test(
    'effective vocabulary keeps configured order and database-only terms',
    () {
      final result = mergeVocabularyOptions(
        const ['Freshly euthanized', 'Good', ''],
        const ['Custom condition', 'Freshly Euthanized', 'Good', 'alpha'],
      );

      expect(result, [
        'Freshly euthanized',
        'Good',
        'alpha',
        'Custom condition',
        'Freshly Euthanized',
      ]);
    },
  );

  test('current database value is appended without mutating options', () {
    const configured = ['Good', 'Fair'];
    final result = includeCurrentVocabularyValue(
      configured,
      'Legacy condition',
    );

    expect(result, ['Good', 'Fair', 'Legacy condition']);
    expect(configured, ['Good', 'Fair']);
  });

  test('condition query returns every nonblank stored value', () async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('project'), name: Value('Test')),
        );
    for (final (uuid, condition) in [
      ('one', 'Good'),
      ('two', 'Custom condition'),
      ('three', 'Good'),
      ('four', ''),
    ]) {
      await database
          .into(database.specimen)
          .insert(
            SpecimenCompanion(
              uuid: Value(uuid),
              projectUuid: const Value('project'),
              condition: Value(condition),
            ),
          );
    }

    expect((await SpecimenQuery(database).getDistinctConditions()).toSet(), {
      'Good',
      'Custom condition',
    });
  });

  test('datum query returns distinct nonblank stored values', () async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final siteId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('project')));
    for (final datum in ['WGS84', 'Custom datum', 'WGS84', '', null]) {
      await database
          .into(database.coordinate)
          .insert(
            CoordinateCompanion(datum: Value(datum), siteID: Value(siteId)),
          );
    }

    expect((await CoordinateQuery(database).getDistinctDatums()).toSet(), {
      'WGS84',
      'Custom datum',
    });
  });

  test('parasite vocabulary queries return distinct nonblank values', () async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    for (final (id, category, detection) in [
      ('one', 'Ectoparasite', 'Visual inspection'),
      ('two', 'Endoparasite', 'Microscopy'),
      ('three', 'Ectoparasite', ''),
    ]) {
      await database
          .into(database.parasite)
          .insert(
            ParasiteCompanion(
              parasiteUuid: Value(id),
              category: Value(category),
              detectionMethod: Value(detection),
              preparationMethod: const Value('Slide'),
              anatomicalLocation: const Value('Intestine'),
              storage: const Value('Ethanol'),
              treatment: const Value('Cleared'),
            ),
          );
    }

    final query = ParasiteQuery(database);
    expect(await query.getDistinctCategories(), [
      'Ectoparasite',
      'Endoparasite',
    ]);
    expect(await query.getDistinctDetectionMethods(), [
      'Microscopy',
      'Visual inspection',
    ]);
    expect(await query.getDistinctPreparationMethods(), ['Slide']);
    expect(await query.getDistinctAnatomicalLocations(), ['Intestine']);
    expect(await query.getDistinctStorageValues(), ['Ethanol']);
    expect(await query.getDistinctTreatments(), ['Cleared']);
  });

  test(
    'effective vocabulary completes after its provider is disposed',
    () async {
      final database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      final configured = Completer<List<String>>();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          userDefinedFieldProvider.overrideWith(
            (ref, prefKey) => configured.future,
          ),
        ],
      );
      addTearDown(database.close);
      addTearDown(container.dispose);

      final result = container.read(
        effectiveUserDefinedFieldProvider(siteTypePrefKey).future,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      configured.complete(const ['Configured site']);

      expect(await result, const ['Configured site']);
    },
  );
}
