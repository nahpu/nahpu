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

  test('specimen templates can insert collecting effort fields', () {
    for (final type in [RecordType.specimenRecord, RecordType.specimenParts]) {
      expect(
        availableTemplateFieldGroups(db, type)['collEffort'],
        containsAll([
          'collEffort::method',
          'collEffort::brand',
          'collEffort::count',
          'collEffort::size',
          'collEffort::notes',
        ]),
        reason: '$type',
      );
    }
  });

  test('templates without collecting events do not offer effort fields', () {
    for (final type in [
      RecordType.none,
      RecordType.site,
      RecordType.narrative,
    ]) {
      expect(
        availableTemplateFieldGroups(db, type).containsKey('collEffort'),
        isFalse,
        reason: '$type',
      );
    }
  });
}
