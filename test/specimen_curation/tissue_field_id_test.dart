import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_service.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_entry.dart';

const _project = 'project-a';
const _types = ['Liver', 'Muscle', 'Skin'];
const _treatments = ['ETOH', 'DMSO', 'RNA later'];

void main() {
  group('parseTissueEntry', () {
    TissueQuery parse(String text) =>
        parseTissueEntry(text, types: _types, treatments: _treatments);

    test('reads type and treatment after the ID, ignoring case', () {
      final query = parse('ABC101 liver etoh');
      expect(query.id, 'ABC101');
      expect(query.partType, 'Liver');
      expect(query.preservation, 'ETOH');
    });

    test('accepts label separators and either order', () {
      final query = parse('ABC 101 · DMSO | Muscle');
      expect(query.id, 'ABC 101');
      expect(query.partType, 'Muscle');
      expect(query.preservation, 'DMSO');
    });

    test('matches multi-word treatments', () {
      final query = parse('HS-5 liver rna later');
      expect(query.id, 'HS-5');
      expect(query.preservation, 'RNA later');
    });

    test('leaves plain IDs alone', () {
      final query = parse('ABC101');
      expect(query.id, 'ABC101');
      expect(query.partType, isNull);
      expect(query.preservation, isNull);
    });

    test('never takes the whole entry as a type', () {
      expect(parse('liver').id, 'liver');
    });
  });

  group('field ID workflows', () {
    late Database database;
    late TissueCheckService service;

    setUp(() async {
      database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      await _seed(database);
      service = TissueCheckService(database: database, projectUuid: _project);
    });

    tearDown(() => database.close());

    TissueCheckSession createSession([
      TissueCheckSettings settings = const TissueCheckSettings(
        value: 'EXM',
        identifyBy: TissueIdentifyBy.fieldId,
      ),
    ]) {
      return TissueCheckSession(
          service: service,
          settings: settings,
          saveSettings: (_) async {},
        )
        ..partTypes = _types
        ..treatments = _treatments;
    }

    Future<TissueCheckMatch> findField(
      String id, {
      String? partType,
      String? preservation,
    }) {
      return service.find(
        TissueQuery(id),
        identifyBy: TissueIdentifyBy.fieldId,
        partTypes: {?partType},
        preservations: {?preservation},
      );
    }

    test('finds cataloger and project field IDs in any spelling', () async {
      expect((await findField('abc-102')).status, TissueMatchStatus.matched);
      expect((await findField('ABC 102')).status, TissueMatchStatus.matched);
      final project = await findField('hs5');
      expect(project.records.single.specimen.uuid, 'specimen-hs5');
    });

    test('a bare number can match several catalogers', () async {
      final match = await findField('101', partType: 'Liver');
      expect(match.status, TissueMatchStatus.ambiguous);
      expect(
        match.records.map((e) => e.specimen.uuid),
        unorderedEquals(['specimen-abc101', 'specimen-xyz101']),
      );
    });

    test('type and preservation narrow a specimen to one part', () async {
      expect((await findField('ABC101')).status, TissueMatchStatus.ambiguous);
      final liver = await findField('ABC101', partType: 'liver');
      expect(liver.records.single.type, 'Liver');
      final dmso = await findField('ABC101', preservation: 'DMSO');
      expect(dmso.records.single.type, 'Muscle');
    });

    test('placed parts stay in ambiguous results', () async {
      final match = await findField('ABC103');
      expect(match.status, TissueMatchStatus.ambiguous);
      expect(
        match.records.map((e) => e.storageLocation),
        contains('Box 9: A1'),
      );
    });

    test('a sticky type places field IDs without a picker', () async {
      final session = createSession(
        const TissueCheckSettings(
          value: 'EXM',
          identifyBy: TissueIdentifyBy.fieldId,
          partTypes: {'Liver'},
        ),
      );
      await session.load();
      final outcome = await session.scan(
        'ABC101',
        pickPart: (_) async => fail('no picker expected'),
      );
      expect(outcome.status, TissueScanStatus.checked);
      expect(session.entries.single.label, 'ABC101 · Liver · ETOH');
      expect(session.entries.single.location, 'Box 1: A1');
    });

    test('smart entry overrides the sticky filter for one scan', () async {
      final session = createSession(
        const TissueCheckSettings(
          value: 'EXM',
          identifyBy: TissueIdentifyBy.fieldId,
          partTypes: {'Liver'},
        ),
      );
      await session.load();
      await session.scan('ABC101 muscle dmso');
      expect(session.entries.single.label, 'ABC101 · Muscle · DMSO');
      expect(session.settings.partTypes, {'Liver'});
    });

    test(
      'the work list runs in field ID order and skips placed parts',
      () async {
        final session = createSession(
          const TissueCheckSettings(
            value: 'EXM',
            identifyBy: TissueIdentifyBy.fieldId,
            partTypes: {'Liver'},
          ),
        );
        await session.load();
        final list = await session.workList();
        expect(list.map(session.labelFor), [
          'ABC101 · Liver · ETOH',
          'ABC102 · Liver · ETOH',
          'ABC103 · Liver · ETOH',
          'HS-5 · Liver · RNA later',
          'XYZ101 · Liver · ETOH',
        ]);

        final outcome = await session.place(list.first);
        expect(outcome.status, TissueScanStatus.checked);
        expect(session.nextLocation, 'Box 1: A2');
        final after = await session.workList();
        expect(
          after.map(session.labelFor),
          isNot(contains('ABC101 · Liver · ETOH')),
        );
        expect(after, hasLength(4));
      },
    );
  });
}

Future<void> _seed(Database database) async {
  await database
      .into(database.project)
      .insert(
        const ProjectCompanion(
          uuid: Value(_project),
          name: Value('Demo'),
          catalogNumberPrefix: Value('HS-'),
        ),
      );
  for (final (uuid, initial) in [('p-abc', 'ABC'), ('p-xyz', 'XYZ')]) {
    await database
        .into(database.personnel)
        .insert(PersonnelCompanion(uuid: Value(uuid), initial: Value(initial)));
  }
  final specimens = [
    ('specimen-abc101', 'p-abc', 101, null),
    ('specimen-abc102', 'p-abc', 102, null),
    ('specimen-abc103', 'p-abc', 103, null),
    ('specimen-xyz101', 'p-xyz', 101, null),
    ('specimen-hs5', null, null, 5),
  ];
  for (final (uuid, cataloger, number, projectNumber) in specimens) {
    await database
        .into(database.specimen)
        .insert(
          SpecimenCompanion(
            uuid: Value(uuid),
            projectUuid: const Value(_project),
            catalogerID: Value(cataloger),
            fieldNumber: Value(number),
            projectFieldNumber: Value(projectNumber),
          ),
        );
  }
  final parts = [
    ('specimen-abc101', 'Liver', 'ETOH', null),
    ('specimen-abc101', 'Muscle', 'DMSO', null),
    ('specimen-abc102', 'Liver', 'ETOH', null),
    ('specimen-abc103', 'Liver', 'ETOH', null),
    ('specimen-abc103', 'Muscle', 'ETOH', 'Box 9: A1'),
    ('specimen-xyz101', 'Liver', 'ETOH', null),
    ('specimen-hs5', 'Liver', 'RNA later', null),
  ];
  for (final (specimen, type, treatment, location) in parts) {
    await database
        .into(database.specimenPart)
        .insert(
          SpecimenPartCompanion(
            specimenUuid: Value(specimen),
            type: Value(type),
            treatment: Value(treatment),
            storageLocation: Value(location),
          ),
        );
  }
}
