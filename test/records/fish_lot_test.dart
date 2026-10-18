import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/parasite_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/specimens/fish_lot_services.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  group('MeasurementSummary', () {
    test('ignores missing values and reports the sample SD', () {
      final summary = MeasurementSummary.fromValues([
        2,
        null,
        4,
        4,
        4,
        5,
        5,
        7,
        9,
      ])!;

      expect(summary.count, 8);
      expect(summary.min, 2);
      expect(summary.max, 9);
      expect(summary.mean, 5);
      expect(summary.standardDeviation, closeTo(2.138, 0.001));
    });

    test('has no SD for a single value', () {
      final summary = MeasurementSummary.fromValues([12.5])!;

      expect(summary.count, 1);
      expect(summary.mean, 12.5);
      expect(summary.standardDeviation, isNull);
    });

    test('is null when nothing is measured', () {
      expect(MeasurementSummary.fromValues([null, null]), isNull);
    });
  });

  group('FishLotStats', () {
    test('converts individual weights to the lot unit', () {
      final stats = FishLotStats.fromIndividuals([
        _individual(1, weight: 1, weightUnit: 'kg'),
        _individual(2, weight: 500, weightUnit: 'g'),
      ], weightUnit: 'g');

      expect(stats.weight!.min, 500);
      expect(stats.weight!.max, 1000);
      expect(stats.individualCount, 2);
    });

    test('auto range raises but never lowers the individual count', () {
      final stats = FishLotStats.fromIndividuals([
        _individual(1, standardLength: 40, totalLength: 52),
        _individual(2, standardLength: 46, totalLength: 58),
      ]);

      final fromEmpty = stats.toAutoRange(null);
      expect(fromEmpty.individualCount, const Value(2));
      expect(fromEmpty.minStandardLength, const Value(40.0));
      expect(fromEmpty.maxTotalLength, const Value(58.0));
      expect(fromEmpty.minWeight, const Value<double?>(null));

      expect(stats.toAutoRange(1).individualCount, const Value(2));
      expect(stats.toAutoRange(25).individualCount, const Value<int>.absent());
    });
  });

  test('converts between specimen weight units', () {
    expect(convertSpecimenWeight(2, 'kg', 'g'), 2000);
    expect(convertSpecimenWeight(453.59237, 'g', 'lbs'), closeTo(1, 1e-9));
    expect(convertSpecimenWeight(5, null, 'g'), 5);
    expect(convertSpecimenWeight(5, 'oz', 'g'), isNull);
  });

  test('reads stored specimen types defensively', () {
    expect(fishSpecimenTypeFromCode(null), FishSpecimenType.individual);
    expect(fishSpecimenTypeFromCode(1), FishSpecimenType.lot);
    expect(fishSpecimenTypeFromCode(9), FishSpecimenType.individual);
  });

  group('part individual links', () {
    late Database db;

    setUp(() async {
      db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
      await db
          .into(db.project)
          .insert(
            const ProjectCompanion(uuid: Value('project'), name: Value('P')),
          );
      await db
          .into(db.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('fish'),
              projectUuid: Value('project'),
              taxonGroup: Value('Fishes'),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('replaces the individuals linked to a part', () async {
      final partId = await SpecimenPartQuery(db).createSpecimenPart(
        const SpecimenPartCompanion(
          specimenUuid: Value('fish'),
          tissueID: Value('T1'),
        ),
      );
      final individuals = SpecimenIndividualQuery(db);
      final first = await individuals.createIndividual(
        const SpecimenIndividualCompanion(
          specimenUuid: Value('fish'),
          individualID: Value('A1'),
        ),
      );
      final second = await individuals.createIndividual(
        const SpecimenIndividualCompanion(
          specimenUuid: Value('fish'),
          individualID: Value('A2'),
        ),
      );
      final links = SpecimenPartIndividualQuery(db);

      await links.setIndividualsForPart(partId, [first, second]);
      expect(
        (await links.getIndividualsForPart(partId)).map((e) => e.individualID),
        ['A1', 'A2'],
      );

      await links.setIndividualsForPart(partId, [second]);
      expect(await links.getIndividualIdsForPart(partId), [second]);
      expect(await links.getLinksForSpecimen('fish'), hasLength(1));
    });

    test('deleting a part or an individual removes its links', () async {
      final parts = SpecimenPartQuery(db);
      final keptPart = await parts.createSpecimenPart(
        const SpecimenPartCompanion(specimenUuid: Value('fish')),
      );
      final deletedPart = await parts.createSpecimenPart(
        const SpecimenPartCompanion(specimenUuid: Value('fish')),
      );
      final individual = await SpecimenIndividualQuery(db).createIndividual(
        const SpecimenIndividualCompanion(specimenUuid: Value('fish')),
      );
      final links = SpecimenPartIndividualQuery(db);
      await links.setIndividualsForPart(keptPart, [individual]);
      await links.setIndividualsForPart(deletedPart, [individual]);

      await parts.deleteSpecimenPart(deletedPart);
      expect(await links.getPartIdsForIndividual(individual), [keptPart]);

      await SpecimenIndividualQuery(db).deleteIndividual(individual);
      expect(await links.getIndividualIdsForPart(keptPart), isEmpty);

      await links.setIndividualsForPart(keptPart, const []);
      await parts.deleteAllSpecimenParts('fish');
      expect(await parts.getSpecimenParts('fish'), isEmpty);
    });

    test('parasites link to individuals and unlink on delete', () async {
      final parasiteId = await db
          .into(db.parasite)
          .insert(
            const ParasiteCompanion(
              specimenUuid: Value('fish'),
              parasiteUuid: Value('parasite-1'),
            ),
          );
      final individuals = SpecimenIndividualQuery(db);
      final first = await individuals.createIndividual(
        const SpecimenIndividualCompanion(
          specimenUuid: Value('fish'),
          individualID: Value('A1'),
        ),
      );
      final second = await individuals.createIndividual(
        const SpecimenIndividualCompanion(
          specimenUuid: Value('fish'),
          individualID: Value('A2'),
        ),
      );
      final links = ParasiteIndividualQuery(db);

      await links.setIndividualsForParasite(parasiteId, [first, second]);
      expect(
        (await links.getIndividualsForParasite(
          parasiteId,
        )).map((e) => e.individualID),
        ['A1', 'A2'],
      );
      expect(await links.getLinksForSpecimen('fish'), hasLength(2));

      await individuals.deleteIndividual(first);
      expect(await links.getIndividualIdsForParasite(parasiteId), [second]);

      await ParasiteQuery(db).deleteParasites([parasiteId]);
      expect(await db.select(db.parasiteIndividual).get(), isEmpty);
    });
  });
}

SpecimenIndividualData _individual(
  int id, {
  double? standardLength,
  double? totalLength,
  double? weight,
  String? weightUnit,
}) {
  return SpecimenIndividualData(
    id: id,
    specimenUuid: 'fish',
    standardLength: standardLength,
    totalLength: totalLength,
    weight: weight,
    weightUnit: weightUnit,
  );
}
