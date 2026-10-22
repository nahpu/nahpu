import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_service.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';

const _project = 'project-a';
const _otherProject = 'project-b';

void main() {
  late Database database;
  late TissueCheckService service;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await _seed(database);
    service = TissueCheckService(database: database, projectUuid: _project);
  });

  tearDown(() => database.close());

  group('TissueCheckService', () {
    test('matches barcode IDs before tissue IDs', () async {
      final match = await service.find('QR-1');
      expect(match.status, TissueMatchStatus.matched);
      expect(match.records.single.part.tissueID, 'T-2');
    });

    test('matches tissue IDs within the project only', () async {
      final match = await service.find(' T-1 ');
      expect(match.status, TissueMatchStatus.matched);
      expect(match.records.single.part.specimenUuid, 'specimen-a');
      expect(
        (await service.find('T-OTHER')).status,
        TissueMatchStatus.notFound,
      );
    });

    test('reports codes shared by several parts', () async {
      final match = await service.find('T-DUP');
      expect(match.status, TissueMatchStatus.ambiguous);
      expect(match.records, hasLength(2));
    });

    test('writes only the chosen field and the location', () async {
      final part = (await service.find('T-1')).records.single.part;
      final write = await service.apply(
        part,
        field: TissueCheckField.museumLoan,
        value: 'EXM',
        location: 'Box 1: A1',
        overwrite: false,
      );
      expect(write.status, TissueWriteStatus.written);
      final stored = await _part(database, part.id!);
      expect(stored.museumLoan, 'EXM');
      expect(stored.museumPermanent, isNull);
      expect(stored.storageLocation, 'Box 1: A1');
      expect(stored.remark, 'keep');
    });

    test('keeps a stored location unless overwriting', () async {
      final part = (await service.find('T-STORED')).records.single.part;
      final write = await service.apply(
        part,
        field: TissueCheckField.museumPermanent,
        value: 'EXM',
        location: 'Box 1: A1',
        overwrite: false,
      );
      expect(write.status, TissueWriteStatus.conflict);
      expect((await _part(database, part.id!)).storageLocation, 'Shelf 2');

      final replaced = await service.apply(
        part,
        field: TissueCheckField.museumPermanent,
        value: 'EXM',
        location: 'Box 1: A1',
        overwrite: true,
      );
      expect(replaced.status, TissueWriteStatus.written);
      expect(replaced.previousLocation, 'Shelf 2');
    });
  });

  group('TissueCheckSession', () {
    late List<TissueCheckSettings> saved;

    TissueCheckSession createSession([
      TissueCheckSettings settings = const TissueCheckSettings(value: 'EXM'),
    ]) {
      saved = [];
      return TissueCheckSession(
        service: service,
        settings: settings,
        saveSettings: (settings) async => saved.add(settings),
      );
    }

    test('fills cells in order and skips cells taken earlier', () async {
      await _setLocation(database, 'T-STORED', 'Box 1: A1');
      final session = createSession();
      await session.load();
      expect(session.occupied.keys, [const TissueCell(0, 0)]);
      expect(session.nextLocation, 'Box 1: A2');

      final outcome = await session.scan('T-1');
      expect(outcome.status, TissueScanStatus.checked);
      expect(session.nextLocation, 'Box 1: A3');
      final stored = (await service.find('T-1')).records.single.part;
      expect(stored.museumPermanent, 'EXM');
      expect(stored.storageLocation, 'Box 1: A2');
    });

    test('does not use a cell for unknown or repeated codes', () async {
      final session = createSession();
      await session.load();
      expect((await session.scan('NOPE')).status, TissueScanStatus.notFound);
      await session.scan('T-1');
      expect((await session.scan('T-1')).status, TissueScanStatus.duplicate);
      expect(session.filledCount, 1);
      expect(session.nextLocation, 'Box 1: A2');
    });

    test('asks for a value before writing', () async {
      final session = createSession(const TissueCheckSettings());
      await session.load();
      final outcome = await session.scan('T-1');
      expect(outcome.status, TissueScanStatus.invalid);
      expect(outcome.message, contains('Museum permanent'));
    });

    test('uses the picked part for an ambiguous code', () async {
      final session = createSession();
      await session.load();
      final skipped = await session.scan('T-DUP', pickPart: (_) async => null);
      expect(skipped.status, TissueScanStatus.skipped);

      final checked = await session.scan(
        'T-DUP',
        pickPart: (records) async => records.last,
      );
      expect(checked.status, TissueScanStatus.checked);
      expect(session.entries.single.location, 'Box 1: A1');
    });

    test('a tapped cell becomes the next cell', () async {
      final session = createSession();
      await session.load();
      session.selectCell(const TissueCell(4, 4));
      await session.scan('T-1');
      expect(session.entries.single.location, 'Box 1: E5');
      expect(session.nextLocation, 'Box 1: E6');
    });

    test('moves to the next box when the box is full', () async {
      final session = createSession(
        const TissueCheckSettings(value: 'EXM', boxNumber: 7),
      );
      await session.load();
      session.selectCell(const TissueCell(8, 8));
      await session.scan('T-1');
      expect(session.isFull, isTrue);

      await session.scan('QR-1');
      expect(session.settings.boxNumber, 8);
      expect(session.entries.first.location, 'Box 8: A1');
      expect(saved.last.boxNumber, 8);
    });

    test('undo restores the part and the cell', () async {
      final session = createSession();
      await session.load();
      await session.scan('T-1');
      final outcome = await session.undoLast();
      expect(outcome?.status, TissueScanStatus.undone);
      expect(session.entries, isEmpty);
      expect(session.occupied, isEmpty);
      expect(session.nextLocation, 'Box 1: A1');
      final part = (await service.find('T-1')).records.single.part;
      expect(part.museumPermanent, isNull);
      expect(part.storageLocation, isNull);
    });
  });
}

Future<void> _seed(Database database) async {
  for (final uuid in [_project, _otherProject]) {
    await database
        .into(database.project)
        .insert(ProjectCompanion(uuid: Value(uuid), name: Value(uuid)));
  }
  await database
      .into(database.specimen)
      .insert(
        const SpecimenCompanion(
          uuid: Value('specimen-a'),
          projectUuid: Value(_project),
          fieldNumber: Value(1),
        ),
      );
  await database
      .into(database.specimen)
      .insert(
        const SpecimenCompanion(
          uuid: Value('specimen-b'),
          projectUuid: Value(_otherProject),
        ),
      );
  final parts = [
    ('specimen-a', 'T-1', null, null),
    ('specimen-a', 'T-2', 'QR-1', null),
    ('specimen-a', 'QR-1', null, null),
    ('specimen-a', 'T-DUP', null, null),
    ('specimen-a', 'T-DUP', null, null),
    ('specimen-a', 'T-STORED', null, 'Shelf 2'),
    ('specimen-b', 'T-OTHER', null, null),
  ];
  for (final (specimen, tissue, barcode, location) in parts) {
    await database
        .into(database.specimenPart)
        .insert(
          SpecimenPartCompanion(
            specimenUuid: Value(specimen),
            tissueID: Value(tissue),
            barcodeID: Value(barcode),
            storageLocation: Value(location),
            remark: const Value('keep'),
          ),
        );
  }
}

Future<SpecimenPartData> _part(Database database, int id) {
  return (database.select(
    database.specimenPart,
  )..where((row) => row.id.equals(id))).getSingle();
}

Future<void> _setLocation(Database database, String tissue, String location) {
  return (database.update(database.specimenPart)
        ..where((row) => row.tissueID.equals(tissue)))
      .write(SpecimenPartCompanion(storageLocation: Value(location)));
}
