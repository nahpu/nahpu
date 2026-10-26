import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_link_service.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';

import 'data_table_test_db.dart';

void main() {
  late Database db;

  Future<Map<String, Object?>> select(
    String sql, [
    List<Object?> args = const [],
  ]) async {
    final rows = await db
        .customSelect(sql, variables: [for (final arg in args) Variable(arg)])
        .get();
    return rows.single.data;
  }

  /// Runs [body] with a [WidgetRef] scoped to project p1 of the seeded
  /// database, as the data table screen would.
  Future<void> withService(
    WidgetTester tester,
    Future<void> Function(DataTableLinkService service) body,
  ) async {
    db = (await tester.runAsync(seededDataTableDb))!;
    addTearDown(() => tester.runAsync(db.close));
    late WidgetRef widgetRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          fieldIdModeNotifierProvider.overrideWith(_PersonnelFieldIdMode.new),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            widgetRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );
    widgetRef.read(projectUuidProvider.notifier).updateProjectUuid('p1');
    await tester.runAsync(() => body(DataTableLinkService(ref: widgetRef)));
  }

  DataTableRecordRow row(Object key) =>
      DataTableRecordRow(key: key, values: const {});

  testWidgets('lists people by the roles the forms allow', (tester) async {
    await withService(tester, (service) async {
      final catalogers = await service.options(DataTableLink.cataloger);
      expect(catalogers.map((o) => o.id), unorderedEquals(['ana', 'ben']));
      final preparators = await service.options(DataTableLink.preparator);
      expect(preparators.map((o) => o.id), contains('cara'));
    });
  });

  testWidgets('a new cataloger brings their next field number', (tester) async {
    await withService(tester, (service) async {
      await db.customStatement(
        "UPDATE specimen SET preparatorID = 'cara' WHERE uuid = 's1'",
      );
      await service.relink(
        DataTableRecordType.specimenRecords,
        row('s1'),
        DataTableLink.cataloger,
        'ben',
      );
      expect(
        await select(
          'SELECT catalogerID, determinerID, preparatorID, fieldNumber '
          "FROM specimen WHERE uuid = 's1'",
        ),
        {
          'catalogerID': 'ben',
          'determinerID': 'ben',
          'preparatorID': 'cara',
          'fieldNumber': 5,
        },
      );
      expect(
        (await select(
          "SELECT currentFieldNumber FROM personnel WHERE uuid = 'ben'",
        ))['currentFieldNumber'],
        6,
      );
    });
  });

  testWidgets('a new event clears method and personnel', (tester) async {
    await withService(tester, (service) async {
      await db.customStatement(
        'INSERT INTO collMethod (id, eventID) VALUES (7, 1)',
      );
      await db.customStatement(
        'INSERT INTO collPersonnel (id, eventID) VALUES (8, 1)',
      );
      await db.customStatement(
        "UPDATE specimen SET collMethodID = 7, collPersonnelID = 8 "
        "WHERE uuid = 's2'",
      );
      final events = await service.options(DataTableLink.event);
      expect(events.first.id, isNull, reason: 'offers "No event"');
      expect(events.last.label, 'BK-1-2026-03-14');

      await service.relink(
        DataTableRecordType.specimenRecords,
        row('s2'),
        DataTableLink.event,
        1,
      );
      expect(
        await select(
          'SELECT collEventID, collMethodID, collPersonnelID '
          "FROM specimen WHERE uuid = 's2'",
        ),
        {'collEventID': 1, 'collMethodID': null, 'collPersonnelID': null},
      );
    });
  });

  testWidgets('taxon, narrative site, and event site re-links', (tester) async {
    await withService(tester, (service) async {
      await service.relink(
        DataTableRecordType.specimenRecords,
        row('s3'),
        DataTableLink.taxon,
        2,
      );
      await service.relink(
        DataTableRecordType.narrative,
        row(2),
        DataTableLink.site,
        2,
      );
      await service.relink(
        DataTableRecordType.events,
        row(1),
        DataTableLink.site,
        2,
      );
      expect(
        (await select(
          "SELECT speciesID FROM specimen WHERE uuid = 's3'",
        )).values.single,
        2,
      );
      expect(
        (await select(
          'SELECT siteID FROM narrative WHERE id = 2',
        )).values.single,
        2,
      );
      expect(
        (await select(
          'SELECT siteID FROM collEvent WHERE id = 1',
        )).values.single,
        2,
      );
    });
  });

  testWidgets('edits a shared site and counts who shares it', (tester) async {
    await withService(tester, (service) async {
      expect(
        await service.sharingCount(
          DataTableRecordType.specimenRecords,
          DataTableLink.linkedSite,
          1,
        ),
        1,
      );
      final (type, columns, raw) = await service.linkedRecord(
        DataTableLink.linkedSite,
        1,
      );
      expect(type, DataTableRecordType.sites);
      expect(columns.map((c) => c.key), contains('siteAttribute::habitatType'));
      expect(raw['geography::country'], 'Indonesia');

      final result = await service.saveLinked(type, [
        DataTableEdit(
          cell: const DataTableCellId(1, 'siteAttribute::habitatType'),
          field: dataTableField('siteAttribute::habitatType'),
          value: 'Peat swamp',
          row: raw,
        ),
      ]);
      expect(result.errors, isEmpty);
      expect(
        await select('SELECT habitatType FROM siteAttribute WHERE siteID = 1'),
        {'habitatType': 'Peat swamp'},
      );
    });
  });
}

class _PersonnelFieldIdMode extends FieldIdModeNotifier {
  @override
  Future<FieldIdMode> build() async => FieldIdMode.personnel;
}
