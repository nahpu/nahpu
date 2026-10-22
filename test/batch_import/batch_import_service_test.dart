import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/batch/batch_column_matcher.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_service.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';

import '../data_table/data_table_test_db.dart';

void main() {
  late Database db;

  Future<List<Map<String, Object?>>> select(
    String sql, [
    List<Object?> args = const [],
  ]) async {
    final rows = await db
        .customSelect(sql, variables: [for (final arg in args) Variable(arg)])
        .get();
    return [for (final row in rows) row.data];
  }

  /// Runs [body] with a service scoped to project p1 of the seeded database.
  Future<void> withService(
    WidgetTester tester,
    Future<void> Function(BatchImportService service) body,
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
    await tester.runAsync(() => body(BatchImportService(ref: widgetRef)));
  }

  /// A file with [headers] and [rows], matched by column names.
  (BatchImportTable, List<BatchColumnMatch>) file(
    DataTableRecordType type,
    List<String> headers,
    List<List<String>> rows,
  ) {
    final table = BatchImportTable(
      fileName: 'test.csv',
      headers: headers,
      rows: rows,
      rowNumbers: [for (var i = 0; i < rows.length; i++) i + 2],
    );
    final matches = BatchColumnMatcher(
      targets: batchImportTargets(type),
      dwcTerms: batchExtraDwcTerms,
    ).match(headers);
    return (table, matches);
  }

  group('update', () {
    testWidgets('writes fields of the record each key names', (tester) async {
      await withService(tester, (service) async {
        final (table, matches) = file(
          DataTableRecordType.specimenRecords,
          ['specimenUUID', 'condition', 'weight', 'sex', 'TL'],
          [
            ['s1', 'Fair', '50.5', 'Female', ''],
            ['s2', '', '', '', '120'],
          ],
        );
        final review = await service.review(
          table: table,
          type: DataTableRecordType.specimenRecords,
          mode: BatchImportMode.update,
          matches: matches,
          key: BatchImportKey.specimenUuid,
        );
        expect(review.rows.map((r) => r.status), [
          BatchRowStatus.ready,
          BatchRowStatus.invalid,
        ]);
        // A bird has no total length.
        final result = await service.apply(review);
        expect(result.written, 1);
        expect(result.skipped, 1);
        expect(
          await select(
            'SELECT s.condition, m.weight, m.sex, m.remark FROM specimen s '
            "JOIN mammalAttribute m ON m.specimenUuid = s.uuid WHERE s.uuid = 's1'",
          ),
          [
            {'condition': 'Fair', 'weight': 50.5, 'sex': 1, 'remark': 'adult'},
          ],
        );
      });
    });

    testWidgets('matches by cataloger and field number', (tester) async {
      await withService(tester, (service) async {
        final (table, matches) = file(
          DataTableRecordType.specimenRecords,
          ['Collector', 'Field no', 'condition'],
          [
            ['Ana Vale', '10', 'Poor'],
            ['Ana Vale', '99', 'Poor'],
            ['Ana Vale', '10', 'Good'],
            ['', '10', 'Good'],
          ],
        );
        final review = await service.review(
          table: table,
          type: DataTableRecordType.specimenRecords,
          mode: BatchImportMode.update,
          matches: matches,
          key: BatchImportKey.catalogerFieldNumber,
        );
        expect(review.rows.map((r) => r.status), [
          BatchRowStatus.ready,
          BatchRowStatus.noMatch,
          BatchRowStatus.duplicateInFile,
          BatchRowStatus.noMatch,
        ]);
        expect(review.rows.first.recordKey, 's1');
        // The cataloger is the key, so it isn't re-linked.
        expect(review.rows.first.links, isEmpty);
      });
    });

    testWidgets('a locality edit keeps the rest of the locality', (
      tester,
    ) async {
      await withService(tester, (service) async {
        final (table, matches) = file(
          DataTableRecordType.sites,
          ['Site ID', 'county', 'habitat'],
          [
            ['BK-1', 'Gayo Lues', 'Peat swamp'],
          ],
        );
        final review = await service.review(
          table: table,
          type: DataTableRecordType.sites,
          mode: BatchImportMode.update,
          matches: matches,
          key: BatchImportKey.siteId,
        );
        final result = await service.apply(review);
        expect(result.errors, isEmpty);
        expect(
          await select(
            'SELECT g.country, g.stateProvince, g.county, g.locality, '
            'sa.habitatType FROM site s JOIN geography g ON g.id = s.geographyId '
            'JOIN siteAttribute sa ON sa.siteID = s.id WHERE s.id = 1',
          ),
          [
            {
              'country': 'Indonesia',
              'stateProvince': 'Aceh',
              'county': 'Gayo Lues',
              'locality': 'Camp 1',
              'habitatType': 'Peat swamp',
            },
          ],
        );
        // The other site still shares the old locality.
        expect(await select('SELECT geographyId FROM site WHERE id = 2'), [
          {'geographyId': 1},
        ]);
      });
    });
  });

  group('create', () {
    testWidgets('adds specimens linked to taxa and catalogers', (tester) async {
      await withService(tester, (service) async {
        final (table, matches) = file(
          DataTableRecordType.specimenRecords,
          ['scientificName', 'Collector', 'Field no', 'HF', 'sex'],
          [
            ['Rattus tiomanicus', 'Ana Vale', '31', '35', 'M'],
            ['Mus caroli', 'Ben Oru', '', '18', ''],
            ['Rattus tiomanicus', 'Ana Vale', '10', '', ''],
            ['Rattus tiomanicus', 'Ana Vale', '31', '', ''],
          ],
        );
        final review = await service.review(
          table: table,
          type: DataTableRecordType.specimenRecords,
          mode: BatchImportMode.create,
          matches: matches,
        );
        expect(review.rows.map((r) => r.status), [
          BatchRowStatus.ready,
          BatchRowStatus.missingLink,
          BatchRowStatus.exists,
          BatchRowStatus.duplicateInFile,
        ]);
        expect(review.rows[1].messages.single, contains('Mus caroli'));

        final result = await service.apply(review);
        expect(result.written, 2);
        expect(result.errors, isEmpty);
        final added = await select(
          'SELECT s.catalogerID, s.fieldNumber, s.speciesID, m.hindFootLength, '
          'm.sex FROM specimen s JOIN mammalAttribute m '
          "ON m.specimenUuid = s.uuid WHERE s.uuid NOT IN ('s1', 's2', 's3') "
          "AND s.projectUuid = 'p1' ORDER BY m.hindFootLength DESC",
        );
        expect(added, [
          {
            'catalogerID': 'ana',
            'fieldNumber': 31,
            'speciesID': 1,
            'hindFootLength': 35.0,
            'sex': 0,
          },
          {
            'catalogerID': 'ben',
            // Ben's next number, as the specimen form gives it.
            'fieldNumber': 5,
            'speciesID': null,
            'hindFootLength': 18.0,
            'sex': null,
          },
        ]);
        expect(
          await select(
            "SELECT currentFieldNumber FROM personnel WHERE uuid = 'ana'",
          ),
          [
            {'currentFieldNumber': 32},
          ],
        );
      });
    });

    testWidgets('rows with missing links can be left out', (tester) async {
      await withService(tester, (service) async {
        final (table, matches) = file(
          DataTableRecordType.specimenRecords,
          ['genus', 'specificEpithet', 'condition'],
          [
            ['Mus', 'caroli', 'Good'],
          ],
        );
        final review = await service.review(
          table: table,
          type: DataTableRecordType.specimenRecords,
          mode: BatchImportMode.create,
          matches: matches,
        );
        final result = await service.apply(review, includeMissingLinks: false);
        expect(result.written, 0);
        expect(result.skipped, 1);
      });
    });

    testWidgets('adds sites with localities, and events at them', (
      tester,
    ) async {
      await withService(tester, (service) async {
        final (sites, siteMatches) = file(
          DataTableRecordType.sites,
          ['Site ID', 'Country', 'State', 'Locality'],
          [
            ['BK-3', 'Indonesia', 'Aceh', 'Camp 3'],
            ['BK-1', 'Indonesia', 'Aceh', 'Camp 1'],
          ],
        );
        final siteReview = await service.review(
          table: sites,
          type: DataTableRecordType.sites,
          mode: BatchImportMode.create,
          matches: siteMatches,
        );
        expect(siteReview.rows.map((r) => r.status), [
          BatchRowStatus.ready,
          BatchRowStatus.exists,
        ]);
        expect((await service.apply(siteReview)).written, 1);
        expect(
          await select(
            'SELECT g.country, g.locality FROM site s JOIN geography g '
            "ON g.id = s.geographyId WHERE s.siteID = 'BK-3'",
          ),
          [
            {'country': 'Indonesia', 'locality': 'Camp 3'},
          ],
        );

        final (events, eventMatches) = file(
          DataTableRecordType.events,
          ['site', 'start date', 'method'],
          [
            ['BK-3', '2026/03/20', 'Live trap'],
          ],
        );
        final eventReview = await service.review(
          table: events,
          type: DataTableRecordType.events,
          mode: BatchImportMode.create,
          matches: eventMatches,
        );
        expect(eventReview.rows.single.status, BatchRowStatus.ready);
        expect((await service.apply(eventReview)).written, 1);
        expect(
          await select(
            'SELECT s.siteID, e.startDate, e.primaryCollMethod FROM collEvent e '
            "JOIN site s ON s.id = e.siteID WHERE e.startDate = '2026-03-20'",
          ),
          [
            {
              'siteID': 'BK-3',
              'startDate': '2026-03-20',
              'primaryCollMethod': 'Live trap',
            },
          ],
        );
      });
    });

    testWidgets('adds parts to the specimen each row names', (tester) async {
      await withService(tester, (service) async {
        final (table, matches) = file(
          DataTableRecordType.specimenParts,
          ['specimenUUID', 'Tissue', 'Part', 'count'],
          [
            ['s1', 'T-2', 'Muscle', '1'],
            ['s1', 'T-1', 'Liver', '1'],
            ['nope', 'T-3', 'Skin', '1'],
          ],
        );
        final review = await service.review(
          table: table,
          type: DataTableRecordType.specimenParts,
          mode: BatchImportMode.create,
          matches: matches,
        );
        expect(review.rows.map((r) => r.status), [
          BatchRowStatus.ready,
          BatchRowStatus.exists,
          BatchRowStatus.noMatch,
        ]);
        expect((await service.apply(review)).written, 1);
        expect(
          await select(
            'SELECT specimenUuid, type, count FROM specimenPart '
            "WHERE tissueID = 'T-2'",
          ),
          [
            {'specimenUuid': 's1', 'type': 'Muscle', 'count': '1'},
          ],
        );
      });
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
