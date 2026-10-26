import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_log_export_dialog.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_service.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';
import 'package:nahpu/services/specimen_curation/tissue_log_export.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

import '../helpers/rust_library.dart';

const _project = 'project-a';

final _labels = TissueLogLabels(
  column: (column) => column.name,
  field: (field) => field.label,
  checked: 'Checked',
  skipped: 'Skipped',
  part: 'Part',
  parasite: 'Parasite',
  customFieldName: (key) => key == 'customSpecimenPart::def-1' ? 'Vial' : null,
);

void main() {
  late Database database;
  late TissueCheckService service;
  late Map<(TissueItemKind, int), TissueItemRecord> records;

  setUpAll(initRustLibForTest);

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await _seed(database);
    service = TissueCheckService(database: database, projectUuid: _project);
    records = await service.recordsFor([
      (TissueItemKind.part, 1),
      (TissueItemKind.part, 2),
      (TissueItemKind.parasite, 1),
    ]);
  });

  tearDown(() => database.close());

  TissueCheckEntry entry(TissueItemKind kind, int id, String label, int row) {
    return TissueCheckEntry(
      code: label,
      label: label,
      kind: kind,
      itemId: id,
      field: TissueCheckField.museumPermanent,
      value: 'EXM',
      boxNumber: 2,
      cell: TissueCell(row, 0),
      location: 'Box 2: ${String.fromCharCode(65 + row)}1',
      previousLocation: row == 1 ? 'Shelf 1' : null,
    );
  }

  TissueLogExportService exportService({
    Future<Map<String, String>> Function(TissueItemRecord record)? valuesFor,
  }) {
    return TissueLogExportService(
      recordsFor: service.recordsFor,
      fieldIdOf: (uuid) => 'ABC1',
      valuesFor: valuesFor ?? (record) async => _values(record),
    );
  }

  // Newest first, as the session lists them.
  List<TissueCheckEntry> entries() => [
    entry(TissueItemKind.parasite, 1, 'P-1', 1),
    entry(TissueItemKind.part, 1, 'T-1', 0),
  ];
  const skipped = [
    TissueSkipEntry(label: 'T-DUP'),
    TissueSkipEntry(label: 'T-2', key: (TissueItemKind.part, 2)),
  ];

  test('records are read fresh by kind and id', () {
    expect(records[(TissueItemKind.part, 1)]!.code, 'T-1');
    expect(records[(TissueItemKind.parasite, 1)]!.code, 'P-1');
    expect(records[(TissueItemKind.parasite, 1)]!.isParasite, isTrue);
  });

  test('curation columns list checked tubes in order, then skips', () async {
    final rows = await exportService().collectRows(
      entries: entries(),
      skipped: skipped,
    );
    final table = buildTissueLogTable(rows: rows, labels: _labels);

    expect(table.headers, [for (final c in TissueLogColumn.values) c.name]);
    expect(table.rows.map((row) => row[3]), ['T-1', 'P-1', 'T-2', 'T-DUP']);
    expect(table.rows.first, [
      'Checked',
      '1',
      'ABC1',
      'T-1',
      'Part',
      'Liver',
      'ETOH',
      'Museum permanent',
      'EXM',
      'Box 2: A1',
      '2',
      'A1',
      '',
      '',
      '',
    ]);
    // Parasites name their category as the type.
    expect(table.rows[1].sublist(4, 6), ['Parasite', 'Ectoparasite']);
    expect(table.rows[1][13], 'Shelf 1');
    // Skipped tubes leave the curation fields blank.
    expect(table.rows[2].sublist(0, 5), [
      'Skipped',
      '3',
      'ABC1',
      'T-2',
      'Part',
    ]);
    expect(table.rows[2].sublist(7), everyElement(''));
    // A skipped ambiguous scan keeps its code only.
    expect(table.rows[3].sublist(2, 5), ['', 'T-DUP', '']);
  });

  test(
    'added columns read part values, parasites from their own columns',
    () async {
      final rows = await exportService().collectRows(
        entries: entries(),
        skipped: const [],
        withValues: true,
      );
      final table = buildTissueLogTable(
        rows: rows,
        labels: _labels,
        customColumns: const [
          'specimenPart::tissueID',
          'specimenPart::remark',
          'customSpecimenPart::def-1',
          'parasite::scientificName',
          'specimen::catalogNumber',
        ],
      );
      final part = table.rows[0].sublist(TissueLogColumn.values.length);
      final parasite = table.rows[1].sublist(TissueLogColumn.values.length);
      expect(part, ['T-1', 'part remark', 'V-9', '', 'MUS-1']);
      expect(parasite, ['P-1', 'parasite remark', '', 'Ixodes', 'MUS-1']);
    },
  );

  test('the replaced column names the tubes moved out', () {
    final table = buildTissueLogTable(
      labels: _labels,
      rows: [
        TissueLogRow(
          label: 'T-1',
          entry: TissueCheckEntry(
            code: 'T-1',
            label: 'T-1',
            kind: TissueItemKind.part,
            itemId: 1,
            field: TissueCheckField.museumPermanent,
            value: 'EXM',
            boxNumber: 1,
            cell: const TissueCell(0, 0),
            location: 'Box 1: A1',
            displaced: const [
              TissueDisplacedTube(
                kind: TissueItemKind.part,
                itemId: 2,
                label: 'T-2',
                location: 'Box 1: A1',
              ),
              TissueDisplacedTube(
                kind: TissueItemKind.parasite,
                itemId: 1,
                label: 'P-1',
                location: 'Box 1: A1',
              ),
            ],
          ),
        ),
      ],
    );
    expect(table.headers.last, 'replaced');
    expect(table.rows.single.last, 'T-2, P-1');
  });

  test('added headers use field names, unique, or NAHPU keys', () async {
    const columns = [
      'specimenPart::remark',
      'specimen::remark',
      'customSpecimenPart::def-1',
    ];
    final names = buildTissueLogTable(
      rows: const [],
      labels: _labels,
      customColumns: columns,
    ).headers.sublist(TissueLogColumn.values.length);
    expect(names, ['remark', 'specimen::remark', 'Vial']);
    final keys = buildTissueLogTable(
      rows: const [],
      labels: _labels,
      customColumns: columns,
      header: TissueLogHeader.nahpuKey,
    ).headers.sublist(TissueLogColumn.values.length);
    expect(keys, columns);
  });

  test('values are read only when columns are added', () async {
    var reads = 0;
    final export = exportService(
      valuesFor: (record) async {
        reads++;
        return _values(record);
      },
    );
    await export.collectRows(entries: entries(), skipped: skipped);
    expect(reads, 0);
    await export.collectRows(
      entries: entries(),
      skipped: skipped,
      withValues: true,
    );
    expect(reads, 3);
  });

  test('writes a CSV with the curation and added columns', () async {
    final directory = await Directory.systemTemp.createTemp('tissue-log-');
    addTearDown(() => directory.delete(recursive: true));
    final file = await exportService().write(
      entries: entries(),
      skipped: skipped,
      labels: _labels,
      format: ExportFmt.csv,
      fileStem: 'tissue_log_Box 2',
      customColumns: const ['specimen::catalogNumber'],
      directory: directory,
    );
    expect(p.dirname(file.path), directory.path);
    expect(p.extension(file.path), '.csv');
    final lines = await file.readAsLines();
    expect(lines.first, startsWith('status,order,fieldId,tubeId'));
    expect(lines.first, endsWith(',catalogNumber'));
    expect(lines, hasLength(5));
  });

  test('field groups lead with part fields and include parasites', () {
    final groups = tissueLogFieldGroups(database);
    expect(groups.keys.first, 'specimenPart');
    expect(groups['specimenPart'], contains('specimenPart::tissueID'));
    expect(groups['parasite'], contains('parasite::parasiteID'));
    expect(groups['specimen'], contains('specimen::catalogerID'));
    expect(groups.keys.toList().indexOf('parasite'), lessThan(3));
  });

  test('settings keep the added columns and header style', () {
    const settings = TissueCheckSettings(
      logColumns: ['specimen::catalogNumber', 'specimenPart::remark'],
      logHeader: TissueLogHeader.nahpuKey,
    );
    final decoded = TissueCheckSettings.decode(settings.encode());
    expect(decoded.logColumns, settings.logColumns);
    expect(decoded.logHeader, TissueLogHeader.nahpuKey);

    final legacy = TissueCheckSettings.decode('{"value": "EXM"}');
    expect(legacy.logColumns, isEmpty);
    expect(legacy.logHeader, TissueLogHeader.fieldName);
  });

  testWidgets('the dialog adds picked columns and exports with them', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    List<String>? exported;
    List<String>? saved;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TissueLogExportDialog(
            checkedCount: 2,
            skippedCount: 1,
            defaultFileStem: 'tissue_log',
            fieldGroups: const {
              'specimenPart': [
                'specimenPart::tissueID',
                'specimenPart::remark',
              ],
              'specimen': ['specimen::catalogNumber'],
            },
            columns: const ['specimen::catalogNumber'],
            onColumnsChanged: (columns, header) => saved = columns,
            onExport:
                ({
                  required format,
                  required fileStem,
                  required directory,
                  required columns,
                  required header,
                }) async {
                  exported = columns;
                  return File(p.join(Directory.systemTemp.path, 'log.csv'));
                },
          ),
        ),
      ),
    );
    expect(find.text('2 checked, 1 skipped'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('tissue-log-column-specimen::catalogNumber')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('tissue-log-add-columns')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('tissue-log-column-search')),
      'rem',
    );
    await tester.pumpAndSettle();
    expect(find.text('tissueID'), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('tissue-log-pick-specimenPart::remark')),
    );
    await tester.tap(find.byKey(const ValueKey('tissue-log-pick-done')));
    await tester.pumpAndSettle();

    expect(saved, ['specimen::catalogNumber', 'specimenPart::remark']);
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
    expect(exported, ['specimen::catalogNumber', 'specimenPart::remark']);
  });
}

/// What the part and parasite exports read, keyed as they key it.
Map<String, String> _values(TissueItemRecord record) => {
  'specimen::catalogNumber': 'MUS-1',
  'specimen::remark': 'specimen remark',
  if (record.isParasite) ...{
    'parasite::parasiteID': record.code ?? '',
    'parasite::remark': 'parasite remark',
    'parasite::scientificName': 'Ixodes',
  } else ...{
    'specimenPart::tissueID': record.code ?? '',
    'specimenPart::remark': 'part remark',
    'customSpecimenPart::def-1': 'V-9',
    // The part export joins the specimen's parasites into each part row.
    'parasite::scientificName': 'Ixodes',
  },
};

Future<void> _seed(Database database) async {
  await database
      .into(database.project)
      .insert(const ProjectCompanion(uuid: Value(_project), name: Value('A')));
  await database
      .into(database.specimen)
      .insert(
        const SpecimenCompanion(
          uuid: Value('specimen-a'),
          projectUuid: Value(_project),
        ),
      );
  for (final tissue in ['T-1', 'T-2']) {
    await database
        .into(database.specimenPart)
        .insert(
          SpecimenPartCompanion(
            specimenUuid: const Value('specimen-a'),
            tissueID: Value(tissue),
            type: const Value('Liver'),
            treatment: const Value('ETOH'),
          ),
        );
  }
  await database
      .into(database.parasite)
      .insert(
        const ParasiteCompanion(
          specimenUuid: Value('specimen-a'),
          parasiteID: Value('P-1'),
          parasiteUuid: Value('uuid-P-1'),
          category: Value('Ectoparasite'),
          treatment: Value('ETOH'),
        ),
      );
}
