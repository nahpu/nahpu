import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/templates/print_specimen_table_columns.dart';

void main() {
  late Database database;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => database.close());

  test('offers the geography columns in the field catalog', () {
    final ids = labelTemplateAvailableFieldIds(database);
    expect(ids, contains('geography::country'));
    expect(ids, contains('geography::locality'));
    expect(ids, contains('site::siteID'));
    expect(ids, isNot(contains('site::country')));
  });

  test('rewrites saved geography columns instead of dropping them', () {
    // A column saved before geography moved to its own table must survive the
    // catalog filter, not disappear from the user's print table.
    expect(
      normalizePrintSpecimenTableColumnIds([
        'site::siteID',
        'site::country',
        'site::stateProvince',
        'site::locality',
      ], database),
      [
        'site::siteID',
        'geography::country',
        'geography::stateProvince',
        'geography::locality',
      ],
    );
  });

  test('still drops ids that no longer exist anywhere', () {
    expect(
      normalizePrintSpecimenTableColumnIds([
        'specimen::fieldNumber',
        'site::notAColumn',
      ], database),
      ['specimen::fieldNumber'],
    );
  });
}
