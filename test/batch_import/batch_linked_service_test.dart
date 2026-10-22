import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/batch/batch_column_matcher.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';
import 'package:nahpu/services/import/batch/batch_linked_models.dart';
import 'package:nahpu/services/import/batch/batch_linked_service.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';

import '../data_table/data_table_test_db.dart';

void main() {
  late Database db;

  Future<List<Map<String, Object?>>> select(String sql) async {
    final rows = await db.customSelect(sql).get();
    return [for (final row in rows) row.data];
  }

  Future<void> withService(
    WidgetTester tester,
    Future<void> Function(BatchLinkedService service) body,
  ) async {
    db = (await tester.runAsync(seededDataTableDb))!;
    addTearDown(() => tester.runAsync(db.close));
    late WidgetRef widgetRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          fieldIdModeNotifierProvider.overrideWith(_PersonnelFieldIdMode.new),
          catalogFmtNotifierProvider.overrideWith(_MammalCatalogFmt.new),
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
    await tester.runAsync(() => body(BatchLinkedService(ref: widgetRef)));
  }

  testWidgets('a mixed file becomes linked sites, events, and specimens', (
    tester,
  ) async {
    await withService(tester, (service) async {
      const headers = [
        'Site ID',
        'locality',
        'country',
        'lat',
        'long',
        'start date',
        'method',
        'scientificName',
        'Collector',
        'Field no',
        'Tissue',
      ];
      final table = BatchImportTable(
        fileName: 'mixed.csv',
        headers: headers,
        rows: const [
          [
            'BK-5', 'Camp 5', 'Indonesia', '4.2', '96.3', '2026-04-01', //
            'Live trap', 'Rattus tiomanicus', 'Ana Vale', '31', 'T-20',
          ],
          [
            'BK-5', 'Camp 5', 'Indonesia', '4.2', '96.3', '2026-04-01', //
            'Live trap', 'Rattus tiomanicus', 'Ana Vale', '31', 'T-21',
          ],
          [
            'BK-1', '', '', '', '', '2026-03-14', //
            '', 'Rattus tiomanicus', 'Ben Oru', '6', '',
          ],
        ],
        rowNumbers: const [2, 3, 4],
      );
      final matches = BatchColumnMatcher(
        targets: batchLinkedTargets(),
        dwcTerms: batchExtraDwcTerms,
      ).match(headers);
      final plan = await service.group(table, matches);
      expect(plan.sites.map((s) => s.action), [
        BatchGroupAction.create,
        BatchGroupAction.linkExisting,
      ]);
      expect(plan.events.last.existingId, 1);

      final result = await service.apply(plan);
      expect(result.errors, isEmpty);
      expect(
        (result.newSites, result.linkedSites, result.newEvents),
        (1, 1, 1),
      );
      expect((result.specimens, result.parts), (2, 2));

      final site = await select(
        'SELECT s.id, g.locality, c.decimalLatitude, c.id AS coordinate '
        'FROM site s JOIN geography g ON g.id = s.geographyId '
        "JOIN coordinate c ON c.siteID = s.id WHERE s.siteID = 'BK-5'",
      );
      expect(site.single['locality'], 'Camp 5');
      expect(site.single['decimalLatitude'], 4.2);

      final specimens = await select(
        'SELECT s.uuid, s.fieldNumber, s.speciesID, s.coordinateID, '
        'e.siteID, e.startDate, e.primaryCollMethod FROM specimen s '
        'JOIN collEvent e ON e.id = s.collEventID '
        "WHERE s.fieldNumber IN (31, 6) AND s.projectUuid = 'p1' "
        'ORDER BY s.fieldNumber DESC',
      );
      expect(specimens.map((s) => s['siteID']), [site.single['id'], 1]);
      expect(specimens.first['startDate'], '2026-04-01');
      expect(specimens.first['primaryCollMethod'], 'Live trap');
      expect(specimens.first['speciesID'], 1);
      // The coordinate follows the event's site.
      expect(specimens.first['coordinateID'], site.single['coordinate']);

      final parts = await select(
        "SELECT tissueID FROM specimenPart WHERE specimenUuid = "
        "'${specimens.first['uuid']}' ORDER BY tissueID",
      );
      expect(parts.map((p) => p['tissueID']), ['T-20', 'T-21']);
    });
  });

  testWidgets('a site that fails skips its events and specimens', (
    tester,
  ) async {
    await withService(tester, (service) async {
      const plan = BatchLinkedPlan(
        rowNumbers: [2],
        sites: [
          BatchSiteGroup(
            id: 'site-1',
            rows: [0],
            // Not a site field, so the save is refused.
            values: {'specimen::condition': 'Good'},
          ),
        ],
        events: [
          BatchEventGroup(id: 'event-1', rows: [0], siteGroupId: 'site-1'),
        ],
        specimens: [
          BatchLinkedSpecimen(
            id: 'specimen-1',
            rows: [0],
            eventGroupId: 'event-1',
            plan: BatchRowPlan(rowNumber: 2, status: BatchRowStatus.ready),
          ),
        ],
      );
      final before = await select('SELECT COUNT(*) AS n FROM specimen');
      final result = await service.apply(plan);
      expect(result.specimens, 0);
      expect(result.errors.keys, [2]);
      expect(result.errors[2], startsWith('Site'));
      expect(await select('SELECT COUNT(*) AS n FROM specimen'), before);
      expect(await select("SELECT COUNT(*) AS n FROM site"), [
        {'n': 2},
      ]);
    });
  });
}

class _PersonnelFieldIdMode extends FieldIdModeNotifier {
  @override
  Future<FieldIdMode> build() async => FieldIdMode.personnel;
}

class _MammalCatalogFmt extends CatalogFmtNotifier {
  @override
  Future<CatalogFmt> build() async => CatalogFmt.mammalogy;
}
