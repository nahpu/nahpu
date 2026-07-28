import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/controlled_vocabulary_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';

void main() {
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
}
