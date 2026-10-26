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

  test('parts group by type and parasites by taxon', () async {
    final parts = counts(await page(NetworkNodeType.part));
    expect(parts.values, unorderedEquals([2, 2]));
    expect(parts.keys.map((label) => label.trim().toLowerCase()), {
      'liver',
      'skin',
    });
    expect(counts(await page(NetworkNodeType.parasite)), {
      'Ctenophthalmus agyrtes': 2,
      'Unidentified taxon': 1,
    });
    final flea = NetworkNodeKey(NetworkNodeType.parasite, '${fixture.flea}');
    expect(counts(await page(NetworkNodeType.site, source: flea)), {
      'HHA-1': 1,
      'HHA-2': 1,
    });
  });

  test('neighbor pages are limited to the source record', () async {
    final site = NetworkNodeKey(NetworkNodeType.site, '${fixture.firstSite}');
    expect(counts(await page(NetworkNodeType.taxon, source: site)), {
      'Myotis lucifugus': 2,
      'Eptesicus fuscus': 1,
    });
    final myotis = NetworkNodeKey(NetworkNodeType.taxon, '${fixture.myotis}');
    expect(counts(await page(NetworkNodeType.site, source: myotis)), {
      'HHA-1': 2,
      'HHA-2': 1,
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
      columns: [
        NetworkColumn(NetworkNodeType.site),
        NetworkColumn(NetworkNodeType.taxon),
      ],
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
      columns: [
        NetworkColumn(NetworkNodeType.site),
        NetworkColumn(NetworkNodeType.taxon),
      ],
      limits: [12, 12],
    );
    final focus = await query
        .watchFocusFlows(
          NetworkLayeredRequest(
            projectUuid: request.projectUuid,
            columns: request.columns,
            limits: request.limits,
            focus: NetworkNodeKey(NetworkNodeType.parasite, '${fixture.flea}'),
          ),
        )
        .first;

    expect(
      {for (final flow in focus.single) (flow.fromId, flow.toId): flow.weight},
      {
        ('${fixture.firstSite}', '${fixture.myotis}'): 1,
        ('${fixture.secondSite}', '${fixture.myotis}'): 1,
      },
    );
  });

  group('field columns', () {
    Future<Map<String, int>> fieldCounts(NetworkField field) async => counts(
      await query
          .watchPage(
            NetworkPageRequest(
              projectUuid: 'project-a',
              type: field.owner,
              field: field,
              limit: 12,
            ),
          )
          .first,
    );

    test('count specimens per value, blanks as not recorded', () async {
      expect(await fieldCounts(NetworkField.siteCountry), {
        'Indonesia': 3,
        'Not recorded': 2,
      });
      expect(await fieldCounts(NetworkField.specimenSex), {
        'Not recorded': 3,
        'Female': 1,
        'Male': 1,
      });
      expect(await fieldCounts(NetworkField.partTreatment), {
        'Ethanol': 2,
        'Dried': 1,
        'Not recorded': 1,
      });
      expect(await fieldCounts(NetworkField.parasiteCategory), {
        'Ectoparasite': 2,
        'Not recorded': 1,
      });
    });

    test('flow from a record column into a field column', () async {
      final data = await query
          .watchLayered(
            NetworkLayeredRequest(
              projectUuid: 'project-a',
              columns: [
                const NetworkColumn(NetworkNodeType.site),
                NetworkColumn.field(NetworkField.specimenSex),
              ],
              limits: const [12, 12],
            ),
          )
          .first;

      expect(data.columns.last.field, NetworkField.specimenSex);
      expect(
        {
          for (final flow in data.flows.single)
            (flow.fromId, flow.toId): flow.weight,
        },
        {
          ('${fixture.firstSite}', 'male'): 1,
          ('${fixture.firstSite}', 'female'): 1,
          ('${fixture.firstSite}', 'not recorded'): 1,
          ('${fixture.secondSite}', 'not recorded'): 2,
        },
      );
    });
  });

  group('record details', () {
    test('a site shows its geography, habitat, and coordinate', () async {
      final details = await query
          .watchRecordDetails(
            NetworkNodeKey(NetworkNodeType.site, '${fixture.firstSite}'),
          )
          .first;

      expect(details, isA<NetworkSiteDetails>());
      final site = details! as NetworkSiteDetails;
      expect(site.siteId, 'HHA-1');
      expect(site.siteType, 'Camp');
      expect(site.locality, 'Sulawesi Selatan, Indonesia');
      expect(site.habitatType, 'Forest');
      expect(site.latitude, -5.25);
      expect(site.longitude, 119.5);
      expect(site.elevation, 120);
      expect(site.eventCount, 2);
    });

    test(
      'a specimen shows its taxon, attributes, parts, and parasites',
      () async {
        final details = await query
            .watchRecordDetails(
              const NetworkNodeKey(NetworkNodeType.specimen, 'sp1'),
            )
            .first;

        final specimen = details! as NetworkSpecimenDetails;
        expect(specimen.museumId, 'MUS-1');
        expect(specimen.species, 'Myotis lucifugus');
        expect(specimen.sexCode, 0);
        expect(specimen.lifeStage, 'Adult');
        expect(specimen.condition, 'Good');
        expect(specimen.eventDate, '2024-01-01');
        expect(specimen.siteId, 'HHA-1');
        expect(specimen.parts, 'Liver, Skin');
        expect(specimen.parasites, 'Ctenophthalmus agyrtes');
      },
    );

    test('other nodes have no details', () async {
      expect(
        await query
            .watchRecordDetails(
              NetworkNodeKey(NetworkNodeType.taxon, '${fixture.myotis}'),
            )
            .first,
        isNull,
      );
      expect(
        await query
            .watchRecordDetails(
              const NetworkNodeKey(
                NetworkNodeType.specimen,
                'male',
                field: NetworkField.specimenSex,
              ),
            )
            .first,
        isNull,
      );
    });
  });
}
