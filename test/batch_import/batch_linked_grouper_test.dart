import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/batch/batch_column_matcher.dart';
import 'package:nahpu/services/import/batch/batch_import_index.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';
import 'package:nahpu/services/import/batch/batch_linked_grouper.dart';
import 'package:nahpu/services/import/batch/batch_linked_models.dart';

const _headers = [
  'locality',
  'country',
  'decimalLatitude',
  'decimalLongitude',
  'eventDate',
  'samplingProtocol',
  'catalogNumber',
  'scientificName',
  'materialSampleID',
];

const _index = BatchImportIndex(
  taxa: [TaxonomyData(id: 1, genus: 'Rattus', specificEpithet: 'tiomanicus')],
  siteRefs: [
    BatchSiteRef(
      id: 7,
      label: 'BK-1',
      siteId: 'BK-1',
      country: 'Indonesia',
      locality: 'Camp 1',
      latitude: 4.1,
      longitude: 96.2,
    ),
  ],
  eventRefs: [
    BatchEventRef(
      id: 9,
      label: 'BK-1-2026-03-14',
      siteId: 7,
      startDate: '2026-03-14',
      method: 'Live trap',
    ),
  ],
);

BatchLinkedPlan _group(List<List<String>> rows, {List<String>? headers}) {
  final table = BatchImportTable(
    fileName: 'mixed.csv',
    headers: headers ?? _headers,
    rows: rows,
    rowNumbers: [for (var i = 0; i < rows.length; i++) i + 2],
  );
  final matches = BatchColumnMatcher(
    targets: batchLinkedTargets(),
    dwcTerms: const {
      'geography::country': 'dwc:country',
      'coordinate::decimalLatitude': 'dwc:decimalLatitude',
      'coordinate::decimalLongitude': 'dwc:decimalLongitude',
      'event::startDate': 'dwc:eventDate',
      'event::Activity': 'dwc:samplingProtocol',
      'part::tissueID': 'dwc:materialSampleID',
      ...batchExtraDwcTerms,
    },
  ).match(table.headers);
  return BatchLinkedGrouper(index: _index).group(table, matches);
}

void main() {
  test('rows group into sites, events, and specimens with parts', () {
    final plan = _group([
      [
        'Camp 3', 'Indonesia', '4.2', '96.3', '2026-04-01', 'Live trap', //
        'A1', 'Rattus tiomanicus', 'T-10',
      ],
      [
        'Camp 3', 'Indonesia', '4.2', '96.3', '2026-04-01', 'Live trap', //
        'A1', 'Rattus tiomanicus', 'T-11',
      ],
      [
        'Camp 3', 'Indonesia', '4.2', '96.3', '2026-04-02', 'Mist net', //
        'A2', 'Rattus tiomanicus', '',
      ],
      [
        'Camp 4', 'Indonesia', '4.5', '96.1', '2026-04-02', 'Mist net', //
        'A3', 'Rattus tiomanicus', '',
      ],
    ]);

    expect(plan.sites.map((s) => s.rows), [
      [0, 1, 2],
      [3],
    ]);
    expect(plan.sites.first.coordinate, {
      'coordinate::decimalLatitude': '4.2',
      'coordinate::decimalLongitude': '96.3',
    });
    expect(plan.sites.first.action, BatchGroupAction.create);
    expect(plan.events.map((e) => e.rows), [
      [0, 1],
      [2],
      [3],
    ]);
    expect(plan.events.map((e) => e.siteGroupId), [
      'site-1',
      'site-1',
      'site-2',
    ]);
    expect(plan.specimens.map((s) => s.rows), [
      [0, 1],
      [2],
      [3],
    ]);
    final first = plan.specimens.first;
    expect(first.plan.status, BatchRowStatus.ready);
    expect(first.eventGroupId, 'event-1');
    expect(first.parts.map((p) => p.plan.values['part::tissueID']), [
      'T-10',
      'T-11',
    ]);

    final counts = plan.counts();
    expect(
      (counts.newSites, counts.newEvents, counts.specimens, counts.parts),
      (2, 3, 3, 2),
    );
  });

  test('sites and events the project has start linked', () {
    final plan = _group(
      [
        ['BK-1', '2026-03-14', 'Live trap', 'A1'],
        ['bk 1', '2026-03-15', 'Live trap', 'A2'],
      ],
      headers: const [
        'Site ID',
        'eventDate',
        'samplingProtocol',
        'catalogNumber',
      ],
    );
    expect(plan.sites.single.action, BatchGroupAction.linkExisting);
    expect(plan.sites.single.existingId, 7);
    expect(plan.events.map((e) => (e.action, e.existingId)), [
      (BatchGroupAction.linkExisting, 9),
      (BatchGroupAction.create, null),
    ]);
  });

  test('a site matches by locality, country, and coordinates', () {
    final plan = _group([
      ['Camp 1', 'Indonesia', '4.1', '96.2', '', '', 'A1', '', ''],
    ]);
    expect(plan.sites.single.existingLabel, 'BK-1');
  });

  test('rows that disagree on a site field are reported', () {
    final plan = _group(
      [
        ['S9', 'Indonesia', 'A1'],
        ['S9', 'Indonesia', 'A2'],
        ['S9', 'Malaysia', 'A3'],
      ],
      headers: const ['Site ID', 'country', 'catalogNumber'],
    );
    final site = plan.sites.single;
    expect(site.values['geography::country'], 'Indonesia');
    expect(site.conflicts.single, contains('Malaysia (1)'));
  });

  test('bad coordinates and unknown taxa are flagged', () {
    final plan = _group([
      ['Camp 5', 'Indonesia', '95', '96', '', '', 'B1', 'Mus caroli', ''],
    ]);
    expect(plan.sites.single.problems.single, contains('Latitude'));
    expect(plan.specimens.single.plan.status, BatchRowStatus.missingLink);
  });

  group('overrides', () {
    BatchLinkedPlan twoSites() => _group([
      [
        'Camp 3',
        'Indonesia',
        '4.2',
        '96.3',
        '2026-04-01',
        'Trap',
        'A1',
        '',
        '',
      ],
      [
        'Camp 3b',
        'Indonesia',
        '4.2',
        '96.3',
        '2026-04-01',
        'Trap',
        'A2',
        '',
        '',
      ],
      [
        'Camp 3b',
        'Indonesia',
        '4.2',
        '96.3',
        '2026-04-02',
        'Trap',
        'A3',
        '',
        '',
      ],
    ]);

    test('merging sites merges events that become alike', () {
      final plan = twoSites().mergeSites('site-2', 'site-1');
      expect(plan.sites.single.rows, [0, 1, 2]);
      expect(plan.events.map((e) => e.rows), [
        [0, 1],
        [2],
      ]);
      expect(plan.specimens.map((s) => s.eventGroupId), [
        'event-1',
        'event-1',
        'event-3',
      ]);
    });

    test('splitting a site moves its rows, events, and specimens', () {
      final merged = twoSites().mergeSites('site-2', 'site-1');
      final plan = merged.splitSite('site-1', {1});
      expect(plan.sites.map((s) => s.rows), [
        [0, 2],
        [1],
      ]);
      final moved = plan.events.last;
      expect(moved.rows, [1]);
      expect(moved.siteGroupId, plan.sites.last.id);
      expect(plan.specimens[1].eventGroupId, moved.id);
    });

    test('link, rename, and exclude', () {
      var plan = twoSites()
          .linkSite('site-1', 7, 'BK-1')
          .renameSite('site-2', 'BK-9')
          .renameEvent('event-2', 'b')
          .excludeRow(2);
      expect(plan.sites.first.action, BatchGroupAction.linkExisting);
      expect(plan.sites.last.siteName, 'BK-9');
      expect(plan.event('event-2')!.idSuffix, 'b');
      var counts = plan.counts();
      expect(
        (counts.newSites, counts.linkedSites, counts.newEvents),
        (1, 1, 2),
      );
      expect((counts.specimens, counts.skippedRows), (2, 1));

      plan = plan.createSite('site-1').includeRow(2);
      counts = plan.counts();
      expect((counts.newSites, counts.specimens), (2, 3));
    });
  });
}
