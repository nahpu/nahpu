import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_service.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_entry.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';

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
      final match = await service.find(TissueQuery('QR-1'));
      expect(match.status, TissueMatchStatus.matched);
      expect(match.records.single.code, 'T-2');
    });

    test('matches tissue IDs within the project only', () async {
      final match = await service.find(TissueQuery(' T-1 '));
      expect(match.status, TissueMatchStatus.matched);
      expect(match.records.single.specimen.uuid, 'specimen-a');
      expect(
        (await service.find(TissueQuery('T-OTHER'))).status,
        TissueMatchStatus.notFound,
      );
    });

    test('reports codes shared by several parts', () async {
      final match = await service.find(TissueQuery('T-DUP'));
      expect(match.status, TissueMatchStatus.ambiguous);
      expect(match.records, hasLength(2));
    });

    test('writes only the chosen field and the location', () async {
      final part = (await service.find(TissueQuery('T-1'))).records.single;
      final write = await service.apply(
        part,
        field: TissueCheckField.museumLoan,
        value: 'EXM',
        location: 'Box 1: A1',
        overwrite: false,
      );
      expect(write.status, TissueWriteStatus.written);
      final stored = await _part(database, part.id);
      expect(stored.museumLoan, 'EXM');
      expect(stored.museumPermanent, isNull);
      expect(stored.storageLocation, 'Box 1: A1');
      expect(stored.remark, 'keep');
    });

    test('keeps a stored location unless overwriting', () async {
      final part = (await service.find(TissueQuery('T-STORED'))).records.single;
      final write = await service.apply(
        part,
        field: TissueCheckField.museumPermanent,
        value: 'EXM',
        location: 'Box 1: A1',
        overwrite: false,
      );
      expect(write.status, TissueWriteStatus.conflict);
      expect((await _part(database, part.id)).storageLocation, 'Shelf 2');

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

  group('TissueCheckService parasites', () {
    test('finds parasites by parasite ID only when included', () async {
      expect(
        (await service.find(TissueQuery('P-1'))).status,
        TissueMatchStatus.notFound,
      );
      final match = await service.find(
        TissueQuery('P-1'),
        includeParasites: true,
      );
      expect(match.status, TissueMatchStatus.matched);
      expect(match.records.single.isParasite, isTrue);
      expect(match.records.single.treatment, 'ETOH');
    });

    test('type filters pass parasites; treatment filters apply', () async {
      final kept = await service.find(
        TissueQuery('P-1'),
        partTypes: {'Liver'},
        preservations: {'DMSO', 'etoh'},
        includeParasites: true,
      );
      expect(kept.status, TissueMatchStatus.matched);
      final dropped = await service.find(
        TissueQuery('P-1'),
        preservations: {'DMSO'},
        includeParasites: true,
      );
      expect(dropped.status, TissueMatchStatus.notFound);
    });

    test('field ID mode also matches parasite IDs', () async {
      final match = await service.find(
        TissueQuery('P-1'),
        identifyBy: TissueIdentifyBy.fieldId,
        includeParasites: true,
      );
      expect(match.records.single.code, 'P-1');
      expect(
        (await service.find(
          TissueQuery('P-1'),
          identifyBy: TissueIdentifyBy.fieldId,
        )).status,
        TissueMatchStatus.notFound,
      );
    });

    test('the category filter applies to parasites only', () async {
      await (database.update(database.parasite)
            ..where((row) => row.parasiteID.equals('P-1')))
          .write(const ParasiteCompanion(category: Value('Ectoparasite')));
      Future<List<String?>> codes(Set<String> categories) async {
        final list = await service.workList(
          includeParasites: true,
          parasiteCategories: categories,
        );
        return list.map((e) => e.code).toList();
      }

      expect(await codes({'ectoparasite'}), contains('P-1'));
      expect(await codes({'ectoparasite'}), contains('T-1'));
      expect(await codes({'Endoparasite'}), isNot(contains('P-1')));
    });

    test('suggests tissue IDs and barcodes, or field IDs', () async {
      expect(await service.scanCodes(), [
        'QR-1',
        'T-1',
        'T-2',
        'T-DUP',
        'T-STORED',
      ]);
      expect(
        await service.scanCodes(includeParasites: true),
        containsAll(['P-1', 'P-STORED']),
      );
      expect(
        await service.scanCodes(includeParasites: true),
        isNot(contains('P-OTHER')),
      );
      expect(
        await service.scanCodes(identifyBy: TissueIdentifyBy.fieldId),
        isNot(contains('T-1')),
      );
    });

    test('the work list adds unplaced parasites', () async {
      final parts = await service.workList();
      expect(parts.where((e) => e.isParasite), isEmpty);
      final all = await service.workList(includeParasites: true);
      expect(all.where((e) => e.isParasite).map((e) => e.code), ['P-1']);
    });

    test('parasite locations fill box cells', () async {
      await (database.update(database.parasite)
            ..where((row) => row.parasiteID.equals('P-STORED')))
          .write(const ParasiteCompanion(storageLocation: Value('Box 1: A2')));
      final items = await service.itemsInBox('Box 1');
      expect(items.map((e) => e.code), ['P-STORED']);
      expect(items.single.isParasite, isTrue);
    });

    test('box contents match the box name exactly', () async {
      await _setLocation(database, 'T-1', 'Box 1: A1');
      await _setLocation(database, 'T-2', 'Box 10: A1');
      await _setLocation(database, 'QR-1', '  Box 1: B1');
      final items = await service.itemsInBox('Box 1');
      expect(items.map((e) => e.code), unorderedEquals(['T-1', 'QR-1']));
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
      final stored = (await service.find(
        TissueQuery('T-1'),
      )).records.single.part!;
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

    test('places and undoes parasites', () async {
      final session = createSession(
        const TissueCheckSettings(value: 'EXM', includeParasites: true),
      );
      await session.load();
      final outcome = await session.scan('P-1');
      expect(outcome.status, TissueScanStatus.checked);
      expect(session.entries.single.kind, TissueItemKind.parasite);
      var stored = await _parasite(database, 'P-1');
      expect(stored.museumPermanent, 'EXM');
      expect(stored.storageLocation, 'Box 1: A1');

      await session.undoLast();
      stored = await _parasite(database, 'P-1');
      expect(stored.museumPermanent, isNull);
      expect(stored.storageLocation, isNull);
      expect(stored.remark, 'keep');
    });

    test('a part and a parasite with the same id are not duplicates', () async {
      final session = createSession(
        const TissueCheckSettings(value: 'EXM', includeParasites: true),
      );
      await session.load();
      final part = (await service.find(TissueQuery('T-1'))).records.single;
      final parasite = (await service.find(
        TissueQuery('P-1'),
        includeParasites: true,
      )).records.single;
      expect((await session.place(part)).status, TissueScanStatus.checked);
      expect((await session.place(parasite)).status, TissueScanStatus.checked);
    });

    test('labels a parasite without an ID by field ID and treatment', () async {
      await (database.update(database.parasite)
            ..where((row) => row.parasiteID.equals('P-1')))
          .write(const ParasiteCompanion(parasiteID: Value(null)));
      final session = createSession(
        const TissueCheckSettings(includeParasites: true),
      )..parasiteLabel = 'Parasit';
      final list = await session.workList();
      final parasite = list.singleWhere((e) => e.isParasite);
      expect(session.labelFor(parasite), '1 · Parasit · ETOH');
    });

    test('skips are logged until the tube is placed', () async {
      final session = createSession();
      await session.load();
      await session.scan('T-DUP', pickPart: (_) async => null);
      final part = (await service.find(TissueQuery('T-1'))).records.single;
      session
        ..skip(part)
        ..skip(part);
      expect(session.skipped.map((e) => e.label), ['T-1', 'T-DUP']);

      await session.place(part);
      expect(session.skipped.map((e) => e.label), ['T-DUP']);
      await session.scan('T-DUP', pickPart: (records) async => records.first);
      expect(session.skipped, isEmpty);
    });

    test('steps back a box but not before box 1', () async {
      final session = createSession(
        const TissueCheckSettings(value: 'EXM', boxNumber: 2),
      );
      await session.load();
      await session.previousBox();
      expect(session.settings.boxNumber, 1);
      await session.previousBox();
      expect(session.settings.boxNumber, 1);
      expect(saved.last.boxNumber, 1);
    });

    test('cells filled outside the tool show their tube', () async {
      await _setLocation(database, 'T-1', 'Box 1: A1');
      await (database.update(database.parasite)
            ..where((row) => row.parasiteID.equals('P-1')))
          .write(const ParasiteCompanion(storageLocation: Value('Box 1: A2')));
      final session = createSession();
      await session.load();
      final a1 = session.itemsAt(const TissueCell(0, 0)).single;
      final a2 = session.itemsAt(const TissueCell(0, 1)).single;
      expect(session.labelFor(a1), 'T-1');
      expect(session.shortLabelFor(a1), 'T-1');
      expect(a2.isParasite, isTrue);
      expect(session.shortLabelFor(a2), 'P-1');
      expect(session.nextLocation, 'Box 1: A3');
    });

    test('tubes sharing a hand-typed cell are all listed', () async {
      await _setLocation(database, 'T-1', 'Box 1: A1');
      await _setLocation(database, 'T-2', 'Box 1: A1');
      final session = createSession();
      await session.load();
      expect(session.itemsAt(const TissueCell(0, 0)), hasLength(2));
      expect(session.filledCount, 1);
    });

    test('a placed tube shows in its cell until undone', () async {
      final session = createSession();
      await session.load();
      await session.scan('T-1');
      final cell = session.itemsAt(const TissueCell(0, 0)).single;
      expect(cell.code, 'T-1');
      expect(cell.storageLocation, 'Box 1: A1');
      expect(cell.readField(TissueCheckField.museumPermanent), 'EXM');

      await session.undoLast();
      expect(session.itemsAt(const TissueCell(0, 0)), isEmpty);
    });

    test('short labels keep the end of the ID and mark parasites', () async {
      final session = createSession();
      final part = (await service.find(TissueQuery('T-STORED'))).records.single;
      expect(session.shortLabelFor(part), 'ORED');
      await (database.update(database.parasite)
            ..where((row) => row.parasiteID.equals('P-1')))
          .write(const ParasiteCompanion(parasiteID: Value('XYZ-12345')));
      final parasite = (await service.find(
        TissueQuery('XYZ-12345'),
        includeParasites: true,
      )).records.single;
      expect(session.shortLabelFor(parasite), 'P345');
    });

    test('custom labels write and read their own locations', () async {
      await _setLocation(database, 'T-2', 'Box 1 / A02');
      await _setLocation(database, 'QR-1', 'Box 1: A03');
      final session = createSession(
        const TissueCheckSettings(
          value: 'EXM',
          customLabels: true,
          layout: TissueBoxLayout(
            labelFormat: TissueLabelFormat(boxSeparator: ' / ', zeroPad: true),
          ),
        ),
      );
      await session.load();
      // QR-1 uses the standard format, so its cell reads as free.
      expect(session.occupied.keys, [const TissueCell(0, 1)]);
      expect(session.nextLocation, 'Box 1 / A01');
      await session.scan('T-1');
      expect(
        (await _part(database, session.entries.single.itemId)).storageLocation,
        'Box 1 / A01',
      );
      expect(session.nextLocation, 'Box 1 / A03');
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
      final part = (await service.find(
        TissueQuery('T-1'),
      )).records.single.part!;
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

  final parasites = [
    ('specimen-a', 'P-1', 'ETOH', null),
    ('specimen-a', 'P-STORED', 'ETOH', 'Shelf 3'),
    ('specimen-b', 'P-OTHER', 'ETOH', null),
  ];
  for (final (specimen, id, treatment, location) in parasites) {
    await database
        .into(database.parasite)
        .insert(
          ParasiteCompanion(
            specimenUuid: Value(specimen),
            parasiteID: Value(id),
            parasiteUuid: Value('uuid-$id'),
            treatment: Value(treatment),
            storageLocation: Value(location),
            remark: const Value('keep'),
          ),
        );
  }
}

Future<ParasiteData> _parasite(Database database, String parasiteId) {
  return (database.select(
    database.parasite,
  )..where((row) => row.parasiteID.equals(parasiteId))).getSingle();
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
