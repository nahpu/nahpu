import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/templates/template_field_catalog.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  late Database db;

  setUp(() {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  test('specimen templates can insert collection method fields', () {
    for (final type in [RecordType.specimenRecord, RecordType.specimenParts]) {
      expect(
        availableTemplateFieldGroups(db, type)['collMethod'],
        containsAll([
          'collMethod::method',
          'collMethod::brand',
          'collMethod::count',
          'collMethod::size',
          'collMethod::notes',
        ]),
        reason: '$type',
      );
    }
  });

  test(
    'templates without collecting events do not offer collection method fields',
    () {
      for (final type in [
        RecordType.none,
        RecordType.site,
        RecordType.narrative,
      ]) {
        expect(
          availableTemplateFieldGroups(db, type).containsKey('collMethod'),
          isFalse,
          reason: '$type',
        );
      }
    },
  );
}
