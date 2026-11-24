import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';

/// Records made outside the app can lack their attribute row. Loading one
/// must not fail, and the first edit must create the row instead of being
/// dropped.
void main() {
  late Database database;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('proj-a'), name: Value('A')),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('bird-1'),
            projectUuid: Value('proj-a'),
            taxonGroup: Value('Birds'),
          ),
        );
  });

  tearDown(() => database.close());

  test('a missing bird attribute row loads as an empty record', () async {
    final data = await BirdSpecimenQuery(
      database,
    ).getBirdAttributeByUuid('bird-1');

    expect(data.specimenUuid, 'bird-1');
    expect(data.weight, isNull);
    expect(await database.select(database.birdAttribute).get(), isEmpty);
  });

  test('saving to a missing bird attribute row creates it', () async {
    final query = BirdSpecimenQuery(database);

    await query.updateBirdAttributes(
      'bird-1',
      const BirdAttributeCompanion(weight: Value(12.5)),
    );
    await query.updateBirdAttributes(
      'bird-1',
      const BirdAttributeCompanion(wingspan: Value(30)),
    );

    final rows = await database.select(database.birdAttribute).get();
    expect(rows, hasLength(1));
    expect(rows.single.specimenUuid, 'bird-1');
    expect(rows.single.weight, 12.5);
    expect(rows.single.wingspan, 30);
  });

  test('every attribute table tolerates a missing row', () async {
    expect(
      (await MammalSpecimenQuery(
        database,
      ).getMammalAttributeByUuid('bird-1')).specimenUuid,
      'bird-1',
    );
    expect(
      (await HerpSpecimenQuery(
        database,
      ).getHerpAttributeByUuid('bird-1')).specimenUuid,
      'bird-1',
    );
    expect(
      (await InvertebrateSpecimenQuery(
        database,
      ).getInvertebrateAttributeByUuid('bird-1')).specimenUuid,
      'bird-1',
    );
    expect(
      (await FishSpecimenQuery(
        database,
      ).getFishAttributeByUuid('bird-1')).specimenUuid,
      'bird-1',
    );
  });
}
