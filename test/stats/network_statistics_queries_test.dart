import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/network_statistics_queries.dart';
import 'package:nahpu/services/types/network_statistics.dart';

import '../data/network_fixture.dart';

void main() {
  late Database db;
  late NetworkStatisticsQuery query;
  late NetworkFixture fixture;

  setUp(() async {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    query = NetworkStatisticsQuery(db);
    fixture = await seedNetworkStatistics(db);
  });

  tearDown(() => db.close());

  Future<NetworkCountPage> page(
    NetworkNodeType type, {
    String? projectUuid = 'project-a',
    int limit = 12,
    NetworkNodeKey? source,
  }) => query
      .watchPage(
        NetworkPageRequest(
          projectUuid: projectUuid,
          type: type,
          limit: limit,
          source: source,
        ),
      )
      .first;

  Map<String, int> counts(NetworkCountPage page) => {
    for (final item in page.items) item.label: item.count,
  };

  test('top-level pages count linked specimens per record', () async {
    expect(counts(await page(NetworkNodeType.taxon)), {
      'Myotis lucifugus': 3,
      'Eptesicus fuscus': 2,
    });
    expect(counts(await page(NetworkNodeType.site)), {'HHA-1': 3, 'HHA-2': 2});
    expect(counts(await page(NetworkNodeType.collector)), {
      'Ana Lee': 3,
      'Bo Smith': 2,
    });
    expect(
      counts(await page(NetworkNodeType.event)).values,
      orderedEquals([2, 2, 1]),
    );
    expect(await page(NetworkNodeType.specimen), isA<NetworkCountPage>());
    expect((await page(NetworkNodeType.specimen)).items.first.label, 'AL 1');
  });

  test('media counts specimens linked directly or through a site', () async {
    expect(counts(await page(NetworkNodeType.media)), {
      'Site photo': 3,
      'Specimen photo': 1,
    });
  });

  test('neighbor pages are limited to the source record', () async {
    final site = NetworkNodeKey(NetworkNodeType.site, '${fixture.firstSite}');
    expect(counts(await page(NetworkNodeType.taxon, source: site)), {
      'Myotis lucifugus': 2,
      'Eptesicus fuscus': 1,
    });
    final myotis = NetworkNodeKey(NetworkNodeType.taxon, '${fixture.myotis}');
    expect(counts(await page(NetworkNodeType.collector, source: myotis)), {
      'Ana Lee': 2,
      'Bo Smith': 1,
    });
  });

  test('a short page reports what it left out', () async {
    final taxa = await page(NetworkNodeType.taxon, limit: 1);

    expect(taxa.items, hasLength(1));
    expect(taxa.totalRecords, 2);
    expect(taxa.hiddenRecords, 1);
    expect(taxa.hiddenCount, 2);
  });

  test('without a project the network covers every project', () async {
    expect(counts(await page(NetworkNodeType.taxon, projectUuid: null)), {
      'Myotis lucifugus': 4,
      'Eptesicus fuscus': 2,
    });
    expect(
      (await page(NetworkNodeType.site, projectUuid: 'project-b')).totalCount,
      1,
    );
  });

  test('layered flows merge left-out records into the overflow', () async {
    const request = NetworkLayeredRequest(
      projectUuid: 'project-a',
      columns: [NetworkNodeType.site, NetworkNodeType.taxon],
      limits: [1, 12],
    );
    final data = await query.watchLayered(request).first;

    expect(data.columns.first.items.single.label, 'HHA-1');
    final first = '${fixture.firstSite}';
    final flows = {
      for (final flow in data.flows.single)
        (flow.fromId, flow.toId): flow.weight,
    };
    expect(flows, {
      (first, '${fixture.myotis}'): 2,
      (first, '${fixture.eptesicus}'): 1,
      (null, '${fixture.myotis}'): 1,
      (null, '${fixture.eptesicus}'): 1,
    });
  });

  test('focus flows keep only the focused record\'s specimens', () async {
    const request = NetworkLayeredRequest(
      projectUuid: 'project-a',
      columns: [NetworkNodeType.site, NetworkNodeType.taxon],
      limits: [12, 12],
      focus: NetworkNodeKey(NetworkNodeType.collector, 'bo'),
    );
    final focus = await query.watchFocusFlows(request).first;

    expect(
      {for (final flow in focus.single) (flow.fromId, flow.toId): flow.weight},
      {
        ('${fixture.secondSite}', '${fixture.myotis}'): 1,
        ('${fixture.secondSite}', '${fixture.eptesicus}'): 1,
      },
    );
  });
}
