import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/record_exchange/personnel_exchange_service.dart';

const _ada = PersonnelData(
  uuid: 'ada-uuid',
  name: 'Ada Lovelace',
  initial: 'AL',
  email: 'ada@example.org',
  role: 'Cataloger',
  currentFieldNumber: 42,
  notes: 'Mammals',
  photoPath: 'ada.jpg',
  isRegisterField: true,
);

void main() {
  late Database database;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => database.close());

  group('encode and decode', () {
    test('round-trips every shared field, including the field number', () {
      for (final payload in [
        PersonnelExchangeService.encodeQr(_ada),
        PersonnelExchangeService.encode(_ada),
      ]) {
        final decoded = PersonnelExchangeService.decode(payload);
        expect(decoded.uuid, 'ada-uuid');
        expect(decoded.name, 'Ada Lovelace');
        expect(decoded.initial, 'AL');
        expect(decoded.email, 'ada@example.org');
        expect(decoded.role, 'Cataloger');
        expect(decoded.currentFieldNumber, 42);
        expect(decoded.notes, 'Mammals');
        expect(decoded.isRegisterField, isTrue);
      }
    });

    test('never carries the photo', () {
      final payload = PersonnelExchangeService.encodeQr(_ada);
      expect(payload, isNot(contains('photoPath')));
      expect(payload, isNot(contains('ada.jpg')));
      expect(PersonnelExchangeService.decode(payload).photoPath, isNull);
    });

    test('rejects other payloads', () {
      String envelope(Object? marker, Map<String, Object?> person) =>
          jsonEncode({'nahpu_personnel': marker, 'personnel': person});

      for (final payload in [
        'not json',
        jsonEncode({'nahpu_taxon': 1, 'taxon': {}}),
        envelope(2, {'uuid': 'a', 'name': 'Ada'}),
        envelope(1, {'name': 'Ada'}),
        envelope(1, {'uuid': 'a', 'name': '  '}),
      ]) {
        expect(
          () => PersonnelExchangeService.decode(payload),
          throwsFormatException,
          reason: payload,
        );
      }
    });
  });

  group('import', () {
    late PersonnelImporter importer;

    setUp(() async {
      importer = PersonnelImporter(database);
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(
              uuid: Value('project-1'),
              name: Value('Field Project'),
            ),
          );
    });

    Future<PersonnelData> stored() => (database.select(
      database.personnel,
    )..where((row) => row.uuid.equals('ada-uuid'))).getSingle();

    Future<int> links() async =>
        (await database.select(database.personnelList).get()).length;

    test('adds a new person without a photo and links the project', () async {
      final incoming = PersonnelExchangeService.decode(
        PersonnelExchangeService.encode(_ada),
      );
      final preview = await importer.preview(incoming);
      expect(preview.isNew, isTrue);

      await importer.apply(
        incoming,
        updateExisting: false,
        projectUuid: 'project-1',
      );
      await importer.apply(
        incoming,
        updateExisting: false,
        projectUuid: 'project-1',
      );

      expect((await stored()).currentFieldNumber, 42);
      expect((await stored()).photoPath, isNull);
      expect(await links(), 1);
    });

    test('skips the project link when no project is open', () async {
      await importer.apply(_ada, updateExisting: false, projectUuid: '');
      expect(await links(), 0);
    });

    test('lists changes, then keeps or updates the existing person', () async {
      await database.into(database.personnel).insert(_ada);
      final incoming = _ada.copyWith(
        name: const Value('Ada King'),
        currentFieldNumber: const Value(50),
        photoPath: const Value(null),
      );

      final preview = await importer.preview(incoming);
      expect(preview.isNew, isFalse);
      expect(preview.changes.map((change) => change.field), [
        PersonnelField.name,
        PersonnelField.currentFieldNumber,
      ]);

      await importer.apply(
        incoming,
        updateExisting: false,
        projectUuid: 'project-1',
      );
      expect((await stored()).name, 'Ada Lovelace');
      expect(await links(), 1);

      await importer.apply(
        incoming,
        updateExisting: true,
        projectUuid: 'project-1',
      );
      final updated = await stored();
      expect(updated.name, 'Ada King');
      expect(updated.currentFieldNumber, 50);
      expect(updated.photoPath, 'ada.jpg');
      expect(await links(), 1);
    });
  });
}
