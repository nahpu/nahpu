import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/network_statistics.dart';

/// Grouped counts behind the statistics network.
///
/// Every query works on a `scoped` table of the specimens in the project, or
/// in every project, and on one membership table per record type with the
/// columns `s` (specimen UUID), `k` (record key), and `l` (record label).
/// Counts are distinct specimens, so a record linked to a specimen more than
/// once still counts it once. No query reads individual records.
class NetworkStatisticsQuery extends DatabaseAccessor<Database> {
  NetworkStatisticsQuery(super.db);

  /// Watches the top [NetworkPageRequest.limit] records of a type.
  Stream<NetworkCountPage> watchPage(NetworkPageRequest request) {
    final source = request.source;
    final sourceFilter = source == null
        ? ''
        : 'WHERE m.s IN (SELECT s FROM src WHERE k = ?)';
    final sourceTable = source == null
        ? ''
        : ', src AS (${_membership(source.type)})';
    return customSelect(
      '''
      ${_scoped(request.projectUuid)},
      m AS (${_membership(request.type)})
      $sourceTable
      SELECT
        m.k AS k,
        MIN(m.l) AS l,
        COUNT(DISTINCT m.s) AS c,
        COUNT(*) OVER () AS records,
        SUM(COUNT(DISTINCT m.s)) OVER () AS total
      FROM m
      $sourceFilter
      GROUP BY m.k
      ORDER BY c DESC, l
      LIMIT ?
      ''',
      variables: [
        ..._projectVariables(request.projectUuid),
        if (source != null) Variable(source.id),
        Variable(request.limit),
      ],
      readsFrom: _tables,
    ).watch().map((rows) => _page(request.type, rows));
  }

  /// Watches the column pages and flows of the layered network. The
  /// request's focus is ignored; see [watchFocusFlows].
  Stream<NetworkLayeredData> watchLayered(NetworkLayeredRequest request) {
    return _onChange().asyncMap((_) async {
      final columns = await _columns(request);
      return NetworkLayeredData(
        columns: columns,
        flows: [
          for (var i = 0; i + 1 < columns.length; i++)
            await _flows(request.projectUuid, columns[i], columns[i + 1], null),
        ],
      );
    });
  }

  /// Watches the part of each layered flow carried by the specimens of the
  /// request's focus, or nothing without a focus.
  Stream<List<List<NetworkFlow>>> watchFocusFlows(
    NetworkLayeredRequest request,
  ) {
    final focus = request.focus;
    if (focus == null) return Stream.value(const []);
    return _onChange().asyncMap((_) async {
      final columns = await _columns(request);
      return [
        for (var i = 0; i + 1 < columns.length; i++)
          await _flows(request.projectUuid, columns[i], columns[i + 1], focus),
      ];
    });
  }

  /// Emits once now and again whenever a table behind the network changes.
  Stream<void> _onChange() =>
      customSelect('SELECT 1', readsFrom: _tables).watch();

  Future<List<NetworkCountPage>> _columns(
    NetworkLayeredRequest request,
  ) async => [
    for (var i = 0; i < request.columns.length; i++)
      await _pageOnce(
        NetworkPageRequest(
          projectUuid: request.projectUuid,
          type: request.columns[i],
          limit: request.limits[i],
        ),
      ),
  ];

  Future<NetworkCountPage> _pageOnce(NetworkPageRequest request) =>
      watchPage(request).first;

  /// Specimens shared by each pair of records in [from] and [to], with the
  /// records left out of either page merged into a null id.
  Future<List<NetworkFlow>> _flows(
    String? projectUuid,
    NetworkCountPage from,
    NetworkCountPage to,
    NetworkNodeKey? focus,
  ) async {
    final fromIds = from.items.map((item) => item.id).toList();
    final toIds = to.items.map((item) => item.id).toList();
    final focusTable = focus == null
        ? ''
        : ', f AS (${_membership(focus.type)})';
    final focusFilter = focus == null
        ? ''
        : 'WHERE a.s IN (SELECT s FROM f WHERE k = ?)';
    final rows = await customSelect(
      '''
      ${_scoped(projectUuid)},
      a AS (${_membership(from.type)}),
      b AS (${_membership(to.type)})
      $focusTable
      SELECT
        CASE WHEN a.k IN (${_placeholders(fromIds.length)}) THEN a.k END
          AS ak,
        CASE WHEN b.k IN (${_placeholders(toIds.length)}) THEN b.k END
          AS bk,
        COUNT(DISTINCT a.s) AS w
      FROM a
      INNER JOIN b ON b.s = a.s
      $focusFilter
      GROUP BY ak, bk
      ''',
      variables: [
        ..._projectVariables(projectUuid),
        for (final id in fromIds) Variable(id),
        for (final id in toIds) Variable(id),
        if (focus != null) Variable(focus.id),
      ],
      readsFrom: _tables,
    ).get();
    return [
      for (final row in rows)
        NetworkFlow(
          fromId: row.readNullable<String>('ak'),
          toId: row.readNullable<String>('bk'),
          weight: row.read<int>('w'),
        ),
    ];
  }

  static NetworkCountPage _page(NetworkNodeType type, List<QueryRow> rows) {
    if (rows.isEmpty) return NetworkCountPage.empty(type);
    return NetworkCountPage(
      type: type,
      items: [
        for (final row in rows)
          NetworkCount(
            id: row.read<String>('k'),
            label: row.read<String>('l'),
            count: row.read<int>('c'),
          ),
      ],
      totalRecords: rows.first.read<int>('records'),
      totalCount: rows.first.read<int>('total'),
    );
  }

  Set<ResultSetImplementation> get _tables => {
    db.specimen,
    db.collEvent,
    db.site,
    db.taxonomy,
    db.collPersonnel,
    db.personnel,
    db.media,
    db.specimenMedia,
    db.eventMedia,
    db.siteMedia,
    db.specimenPart,
    db.parasite,
  };

  /// Opens the `WITH` clause with the `scoped` specimen table. Carries one
  /// `?` placeholder for the project UUID, or none for every project.
  static String _scoped(String? projectUuid) =>
      '''
      WITH scoped AS (
        SELECT * FROM specimen
        WHERE ${projectUuid == null ? '1' : 'specimen.projectUuid = ?'}
      )''';

  static List<Variable> _projectVariables(String? projectUuid) =>
      projectUuid == null ? [] : [Variable(projectUuid)];

  static String _placeholders(int count) => List.filled(count, '?').join(', ');

  /// Membership table of [type]: one row per specimen and linked record.
  static String _membership(NetworkNodeType type) => switch (type) {
    NetworkNodeType.site =>
      '''
      SELECT scoped.uuid AS s, CAST(site.id AS TEXT) AS k, $_siteLabel AS l
      FROM scoped
      INNER JOIN collEvent ON collEvent.id = scoped.collEventID
      INNER JOIN site ON site.id = collEvent.siteID''',
    NetworkNodeType.event =>
      '''
      SELECT scoped.uuid AS s, CAST(collEvent.id AS TEXT) AS k,
        $_eventLabel AS l
      FROM scoped
      INNER JOIN collEvent ON collEvent.id = scoped.collEventID
      LEFT JOIN site ON site.id = collEvent.siteID''',
    NetworkNodeType.specimen =>
      '''
      SELECT scoped.uuid AS s, scoped.uuid AS k, $_specimenLabel AS l
      FROM scoped
      LEFT JOIN personnel ON personnel.uuid = scoped.catalogerID''',
    NetworkNodeType.taxon =>
      '''
      SELECT scoped.uuid AS s, CAST(taxonomy.id AS TEXT) AS k,
        $_taxonLabel AS l
      FROM scoped
      INNER JOIN taxonomy ON taxonomy.id = scoped.speciesID''',
    NetworkNodeType.collector =>
      '''
      SELECT scoped.uuid AS s,
        coalesce(collPersonnel.personnelId, 'name:' || trim(collPersonnel.name))
          AS k,
        coalesce(
          nullif(trim(personnel.name), ''),
          nullif(trim(collPersonnel.name), ''),
          'Unnamed collector'
        ) AS l
      FROM scoped
      INNER JOIN collPersonnel ON collPersonnel.id = scoped.collPersonnelID
      LEFT JOIN personnel ON personnel.uuid = collPersonnel.personnelId
      WHERE collPersonnel.personnelId IS NOT NULL
        OR trim(coalesce(collPersonnel.name, '')) != ''
      ''',
    NetworkNodeType.media =>
      '''
      SELECT scoped.uuid AS s, CAST(media.primaryId AS TEXT) AS k,
        $_mediaLabel AS l
      FROM scoped
      INNER JOIN specimenMedia ON specimenMedia.specimenUuid = scoped.uuid
      INNER JOIN media ON media.primaryId = specimenMedia.mediaId
      UNION ALL
      SELECT scoped.uuid, CAST(media.primaryId AS TEXT), $_mediaLabel
      FROM scoped
      INNER JOIN eventMedia ON eventMedia.eventID = scoped.collEventID
      INNER JOIN media ON media.primaryId = eventMedia.mediaId
      UNION ALL
      SELECT scoped.uuid, CAST(media.primaryId AS TEXT), $_mediaLabel
      FROM scoped
      INNER JOIN collEvent ON collEvent.id = scoped.collEventID
      INNER JOIN siteMedia ON siteMedia.siteId = collEvent.siteID
      INNER JOIN media ON media.primaryId = siteMedia.mediaId''',
    NetworkNodeType.part =>
      '''
      SELECT scoped.uuid AS s,
        lower(trim(coalesce(specimenPart.type, ''))) AS k,
        coalesce(nullif(trim(specimenPart.type), ''), 'Unspecified part') AS l
      FROM scoped
      INNER JOIN specimenPart ON specimenPart.specimenUuid = scoped.uuid''',
    NetworkNodeType.parasite =>
      '''
      SELECT scoped.uuid AS s,
        coalesce(CAST(taxonomy.id AS TEXT), '') AS k,
        $_taxonLabel AS l
      FROM scoped
      INNER JOIN parasite ON parasite.specimenUuid = scoped.uuid
      LEFT JOIN taxonomy ON taxonomy.id = parasite.speciesID''',
  };

  static const _siteLabel = '''
    CASE
      WHEN trim(coalesce(site.siteID, '')) = ''
      THEN 'Unnamed site (' || site.id || ')'
      ELSE trim(site.siteID)
    END''';

  static const _eventLabel = '''
    coalesce(nullif(trim(site.siteID), ''), 'No site') || ' · ' ||
    coalesce(nullif(trim(collEvent.startDate), ''), 'No date') ||
    coalesce('-' || nullif(trim(collEvent.idSuffix), ''), '')''';

  static const _specimenLabel = '''
    CASE
      WHEN scoped.fieldNumber IS NULL THEN substr(scoped.uuid, 1, 8)
      ELSE trim(
        coalesce(trim(personnel.initial), '') || ' ' || scoped.fieldNumber
      )
    END''';

  static const _taxonLabel = '''
    CASE
      WHEN trim(coalesce(taxonomy.genus, '')) = ''
        OR trim(coalesce(taxonomy.specificEpithet, '')) = ''
      THEN coalesce(
        nullif(trim(taxonomy.genus), ''),
        nullif(trim(taxonomy.taxonFamily), ''),
        'Unidentified taxon'
      )
      ELSE trim(taxonomy.genus) || ' ' || trim(taxonomy.specificEpithet)
    END''';

  static const _mediaLabel = '''
    coalesce(
      nullif(trim(media.caption), ''),
      nullif(trim(media.fileName), ''),
      'Media ' || media.primaryId
    )''';
}
