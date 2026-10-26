import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/statistics_sql.dart';
import 'package:nahpu/services/types/network_statistics.dart';

/// Grouped counts behind the statistics network.
///
/// Every query works on a `scoped` table of the specimens in the project, or
/// in every project, and on one membership table per record type with the
/// columns `s` (specimen UUID), `k` (record key), and `l` (record label). A
/// field column has one membership row per specimen and field value.
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
        : ', src AS (${_membership(source.type, source.field)})';
    return customSelect(
      '''
      ${_scoped(request.projectUuid)},
      m AS (${_membership(request.type, request.field)})
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
    ).watch().map((rows) => _page(request.type, request.field, rows));
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

  /// Watches the facts about the site or specimen behind [key], or emits
  /// null for any other node.
  Stream<NetworkRecordDetails?> watchRecordDetails(NetworkNodeKey key) {
    if (!key.isRecord) return Stream.value(null);
    return switch (key.type) {
      NetworkNodeType.site => _watchSiteDetails(key.id),
      NetworkNodeType.specimen => _watchSpecimenDetails(key.id),
      _ => Stream.value(null),
    };
  }

  Stream<NetworkSiteDetails?> _watchSiteDetails(String id) {
    return customSelect(
      '''
      SELECT
        site.siteID AS site_id,
        site.siteType AS site_type,
        geography.locality AS locality,
        geography.municipality AS municipality,
        geography.county AS county,
        geography.stateProvince AS state_province,
        geography.country AS country,
        (SELECT habitatType FROM siteAttribute
          WHERE siteAttribute.siteID = site.id LIMIT 1) AS habitat_type,
        (SELECT habitatCondition FROM siteAttribute
          WHERE siteAttribute.siteID = site.id LIMIT 1) AS habitat_condition,
        coordinate.decimalLatitude AS latitude,
        coordinate.decimalLongitude AS longitude,
        coordinate.elevationInMeter AS elevation,
        (SELECT COUNT(*) FROM collEvent WHERE collEvent.siteID = site.id)
          AS events
      FROM site
      LEFT JOIN geography ON geography.id = site.geographyId
      LEFT JOIN coordinate ON coordinate.id = (
        SELECT MIN(id) FROM coordinate WHERE coordinate.siteID = site.id
      )
      WHERE CAST(site.id AS TEXT) = ?
      ''',
      variables: [Variable(id)],
      readsFrom: _tables,
    ).watch().map((rows) {
      if (rows.isEmpty) return null;
      final row = rows.first;
      String? text(String column) =>
          _blankToNull(row.readNullable<String>(column));
      final locality = [
        for (final column in [
          'locality',
          'municipality',
          'county',
          'state_province',
          'country',
        ])
          ?text(column),
      ];
      return NetworkSiteDetails(
        siteId: text('site_id'),
        siteType: text('site_type'),
        locality: locality.isEmpty ? null : locality.join(', '),
        habitatType: text('habitat_type'),
        habitatCondition: text('habitat_condition'),
        latitude: row.readNullable<double>('latitude'),
        longitude: row.readNullable<double>('longitude'),
        elevation: row.readNullable<double>('elevation'),
        eventCount: row.read<int>('events'),
      );
    });
  }

  Stream<NetworkSpecimenDetails?> _watchSpecimenDetails(String uuid) {
    return customSelect(
      '''
      WITH scoped AS (SELECT * FROM specimen WHERE uuid = ?),
      ${StatisticsSql.attributeCte}
      SELECT
        scoped.museumID AS museum_id,
        CASE WHEN taxonomy.id IS NULL THEN NULL ELSE $_taxonLabel END
          AS species,
        normalized_attributes.sex AS sex,
        normalized_attributes.life_stage AS life_stage,
        scoped.condition AS condition,
        collEvent.startDate AS event_date,
        site.siteID AS site_id,
        (SELECT group_concat(t, ', ') FROM (
          SELECT DISTINCT trim(specimenPart.type) AS t
          FROM specimenPart
          WHERE specimenPart.specimenUuid = scoped.uuid
            AND trim(coalesce(specimenPart.type, '')) != ''
          ORDER BY specimenPart.id
        )) AS parts,
        (SELECT group_concat(t, ', ') FROM (
          SELECT DISTINCT $_taxonLabel AS t
          FROM parasite
          LEFT JOIN taxonomy ON taxonomy.id = parasite.speciesID
          WHERE parasite.specimenUuid = scoped.uuid
          ORDER BY parasite.id
        )) AS parasites
      FROM scoped
      LEFT JOIN taxonomy ON taxonomy.id = scoped.speciesID
      LEFT JOIN normalized_attributes
        ON normalized_attributes.specimenUuid = scoped.uuid
      LEFT JOIN collEvent ON collEvent.id = scoped.collEventID
      LEFT JOIN site ON site.id = collEvent.siteID
      ''',
      variables: [Variable(uuid)],
      readsFrom: _tables,
    ).watch().map((rows) {
      if (rows.isEmpty) return null;
      final row = rows.first;
      String? text(String column) =>
          _blankToNull(row.readNullable<String>(column));
      return NetworkSpecimenDetails(
        museumId: text('museum_id'),
        species: text('species'),
        sexCode: row.readNullable<int>('sex'),
        lifeStage: text('life_stage'),
        condition: text('condition'),
        eventDate: text('event_date'),
        siteId: text('site_id'),
        parts: text('parts'),
        parasites: text('parasites'),
      );
    });
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
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
          type: request.columns[i].type,
          field: request.columns[i].field,
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
        : ', f AS (${_membership(focus.type, focus.field)})';
    final focusFilter = focus == null
        ? ''
        : 'WHERE a.s IN (SELECT s FROM f WHERE k = ?)';
    final rows = await customSelect(
      '''
      ${_scoped(projectUuid)},
      a AS (${_membership(from.type, from.field)}),
      b AS (${_membership(to.type, to.field)})
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

  static NetworkCountPage _page(
    NetworkNodeType type,
    NetworkField? field,
    List<QueryRow> rows,
  ) {
    if (rows.isEmpty) return NetworkCountPage.empty(type, field: field);
    return NetworkCountPage(
      type: type,
      field: field,
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
    db.personnel,
    db.geography,
    db.siteAttribute,
    db.coordinate,
    db.mammalAttribute,
    db.birdAttribute,
    db.herpAttribute,
    db.invertebrateAttribute,
    db.fishAttribute,
    db.fossilAttribute,
    db.media,
    db.specimenMedia,
    db.eventMedia,
    db.siteMedia,
    db.specimenPart,
    db.parasite,
  };

  /// Opens the `WITH` clause with the `scoped` specimen table and the
  /// specimen attributes. Carries one `?` placeholder for the project UUID,
  /// or none for every project.
  static String _scoped(String? projectUuid) =>
      '''
      WITH scoped AS (
        SELECT * FROM specimen
        WHERE ${projectUuid == null ? '1' : 'specimen.projectUuid = ?'}
      ),
      ${StatisticsSql.attributeCte}''';

  static List<Variable> _projectVariables(String? projectUuid) =>
      projectUuid == null ? [] : [Variable(projectUuid)];

  static String _placeholders(int count) => List.filled(count, '?').join(', ');

  /// Membership table of [type], or of [field] when set: one row per
  /// specimen and linked record or field value.
  static String _membership(NetworkNodeType type, [NetworkField? field]) =>
      field == null ? _recordMembership(type) : _fieldMembership(field);

  static String _recordMembership(NetworkNodeType type) => switch (type) {
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
    NetworkNodeType.media => _mediaMembership(
      'CAST(media.primaryId AS TEXT)',
      _mediaLabel,
    ),
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

  /// Membership of the media linked to a specimen directly, through its
  /// event, or through its site, keyed by [key] and labeled by [label].
  static String _mediaMembership(String key, String label) =>
      '''
      SELECT scoped.uuid AS s, $key AS k, $label AS l
      FROM scoped
      INNER JOIN specimenMedia ON specimenMedia.specimenUuid = scoped.uuid
      INNER JOIN media ON media.primaryId = specimenMedia.mediaId
      UNION ALL
      SELECT scoped.uuid, $key, $label
      FROM scoped
      INNER JOIN eventMedia ON eventMedia.eventID = scoped.collEventID
      INNER JOIN media ON media.primaryId = eventMedia.mediaId
      UNION ALL
      SELECT scoped.uuid, $key, $label
      FROM scoped
      INNER JOIN collEvent ON collEvent.id = scoped.collEventID
      INNER JOIN siteMedia ON siteMedia.siteId = collEvent.siteID
      INNER JOIN media ON media.primaryId = siteMedia.mediaId''';

  /// Membership of [field]: each specimen and its value, keyed by the value
  /// ignoring case and labeled `Not recorded` when blank.
  static String _fieldMembership(NetworkField field) {
    const site = '''
      INNER JOIN collEvent ON collEvent.id = scoped.collEventID
      INNER JOIN site ON site.id = collEvent.siteID''';
    const event = 'INNER JOIN collEvent ON collEvent.id = scoped.collEventID';
    const taxon = 'INNER JOIN taxonomy ON taxonomy.id = scoped.speciesID';
    const attributes = '''
      LEFT JOIN normalized_attributes
        ON normalized_attributes.specimenUuid = scoped.uuid''';
    final (joins, label) = switch (field) {
      NetworkField.siteCountry => (
        '$site LEFT JOIN geography ON geography.id = site.geographyId',
        _valueLabel('geography.country'),
      ),
      NetworkField.siteStateProvince => (
        '$site LEFT JOIN geography ON geography.id = site.geographyId',
        _valueLabel('geography.stateProvince'),
      ),
      NetworkField.siteType => (site, _valueLabel('site.siteType')),
      NetworkField.siteHabitatType => (
        '$site LEFT JOIN siteAttribute ON siteAttribute.siteID = site.id',
        _valueLabel('siteAttribute.habitatType'),
      ),
      NetworkField.eventMethod => (
        event,
        _valueLabel('collEvent.primaryCollMethod'),
      ),
      NetworkField.eventYear => (
        event,
        _valueLabel('substr(trim(collEvent.startDate), 1, 4)'),
      ),
      NetworkField.specimenSex => (attributes, StatisticsSql.sexLabel),
      NetworkField.specimenLifeStage => (
        attributes,
        StatisticsSql.lifeStageLabel,
      ),
      NetworkField.specimenCondition => ('', _valueLabel('scoped.condition')),
      NetworkField.taxonOrder => (taxon, _valueLabel('taxonomy.taxonOrder')),
      NetworkField.taxonFamily => (taxon, _valueLabel('taxonomy.taxonFamily')),
      NetworkField.taxonGenus => (taxon, _valueLabel('taxonomy.genus')),
      NetworkField.partTreatment => (
        'INNER JOIN specimenPart ON specimenPart.specimenUuid = scoped.uuid',
        _valueLabel('specimenPart.treatment'),
      ),
      NetworkField.parasiteCategory => (
        'INNER JOIN parasite ON parasite.specimenUuid = scoped.uuid',
        _valueLabel('parasite.category'),
      ),
      NetworkField.parasiteLocation => (
        'INNER JOIN parasite ON parasite.specimenUuid = scoped.uuid',
        _valueLabel('parasite.anatomicalLocation'),
      ),
      NetworkField.mediaCategory => (null, _valueLabel('media.category')),
    };
    if (joins == null) return _mediaMembership('lower($label)', label);
    return '''
      SELECT scoped.uuid AS s, lower($label) AS k, $label AS l
      FROM scoped
      $joins''';
  }

  /// Trimmed [column], or `Not recorded` when blank.
  static String _valueLabel(String column) =>
      '''
    CASE
      WHEN trim(coalesce($column, '')) = '' THEN 'Not recorded'
      ELSE trim($column)
    END''';

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
