// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collevent_queries.dart';

// ignore_for_file: type=lint
mixin _$CollEventQueryMixin on DatabaseAccessor<Database> {
  Project get project => attachedDatabase.project;
  Personnel get personnel => attachedDatabase.personnel;
  Media get media => attachedDatabase.media;
  Site get site => attachedDatabase.site;
  Coordinate get coordinate => attachedDatabase.coordinate;
  CollEvent get collEvent => attachedDatabase.collEvent;
  Weather get weather => attachedDatabase.weather;
  CollPersonnel get collPersonnel => attachedDatabase.collPersonnel;
  CollEffort get collEffort => attachedDatabase.collEffort;
  Narrative get narrative => attachedDatabase.narrative;
  NarrativeMedia get narrativeMedia => attachedDatabase.narrativeMedia;
  SiteMedia get siteMedia => attachedDatabase.siteMedia;
  Taxonomy get taxonomy => attachedDatabase.taxonomy;
  Specimen get specimen => attachedDatabase.specimen;
  SpecimenMedia get specimenMedia => attachedDatabase.specimenMedia;
  AssociatedData get associatedData => attachedDatabase.associatedData;
  PersonnelList get personnelList => attachedDatabase.personnelList;
  MammalMeasurement get mammalMeasurement => attachedDatabase.mammalMeasurement;
  AvianMeasurement get avianMeasurement => attachedDatabase.avianMeasurement;
  HerpMeasurement get herpMeasurement => attachedDatabase.herpMeasurement;
  SpecimenPart get specimenPart => attachedDatabase.specimenPart;
  Selectable<ListProjectResult> listProject() {
    return customSelect('SELECT uuid, name, created, lastAccessed FROM project',
        variables: [],
        readsFrom: {
          project,
        }).map((QueryRow row) => ListProjectResult(
          uuid: row.read<String>('uuid'),
          name: row.read<String>('name'),
          created: row.readNullable<String>('created'),
          lastAccessed: row.readNullable<String>('lastAccessed'),
        ));
  }

  Selectable<SpecimenData> searchSpecimens(
      String? projectUuid,
      String searchQuery,
      bool hasCollectionDate,
      String? collectionStartDate,
      String? collectionEndDate,
      bool hasPrepDate,
      String? prepStartDate,
      String? prepEndDate,
      int limit,
      int offset) {
    return customSelect(
        'SELECT s.* FROM specimen AS s LEFT JOIN personnel AS c ON s.catalogerID = c.uuid LEFT JOIN personnel AS p ON s.preparatorID = p.uuid LEFT JOIN taxonomy AS t ON s.speciesID = t.id WHERE s.projectUuid = ?1 AND(?2 IS NULL OR ?2 = \'\' OR s.fieldNumber LIKE ?2 OR c.name LIKE ?2 OR p.name LIKE ?2 OR t.genus || \' \' || t.specificEpithet LIKE ?2)AND(?3 = FALSE OR(s.collectionDate >= ?4 AND s.collectionDate <= ?5))AND(?6 = FALSE OR(s.prepDate >= ?7 AND s.prepDate <= ?8))ORDER BY s.fieldNumber ASC LIMIT ?9 OFFSET ?10',
        variables: [
          Variable<String>(projectUuid),
          Variable<String>(searchQuery),
          Variable<bool>(hasCollectionDate),
          Variable<String>(collectionStartDate),
          Variable<String>(collectionEndDate),
          Variable<bool>(hasPrepDate),
          Variable<String>(prepStartDate),
          Variable<String>(prepEndDate),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          specimen,
          personnel,
          taxonomy,
        }).asyncMap(specimen.mapFromRow);
  }

  Selectable<int> countSpecimens(
      String? projectUuid,
      String searchQuery,
      bool hasCollectionDate,
      String? collectionStartDate,
      String? collectionEndDate,
      bool hasPrepDate,
      String? prepStartDate,
      String? prepEndDate) {
    return customSelect(
        'SELECT COUNT(s.uuid) AS _c0 FROM specimen AS s LEFT JOIN personnel AS c ON s.catalogerID = c.uuid LEFT JOIN personnel AS p ON s.preparatorID = p.uuid LEFT JOIN taxonomy AS t ON s.speciesID = t.id WHERE s.projectUuid = ?1 AND(?2 IS NULL OR ?2 = \'\' OR s.fieldNumber LIKE ?2 OR c.name LIKE ?2 OR p.name LIKE ?2 OR t.genus || \' \' || t.specificEpithet LIKE ?2)AND(?3 = FALSE OR(s.collectionDate >= ?4 AND s.collectionDate <= ?5))AND(?6 = FALSE OR(s.prepDate >= ?7 AND s.prepDate <= ?8))',
        variables: [
          Variable<String>(projectUuid),
          Variable<String>(searchQuery),
          Variable<bool>(hasCollectionDate),
          Variable<String>(collectionStartDate),
          Variable<String>(collectionEndDate),
          Variable<bool>(hasPrepDate),
          Variable<String>(prepStartDate),
          Variable<String>(prepEndDate)
        ],
        readsFrom: {
          specimen,
          personnel,
          taxonomy,
        }).map((QueryRow row) => row.read<int>('_c0'));
  }

  CollEventQueryManager get managers => CollEventQueryManager(this);
}

class CollEventQueryManager {
  final _$CollEventQueryMixin _db;
  CollEventQueryManager(this._db);
  $ProjectTableManager get project =>
      $ProjectTableManager(_db.attachedDatabase, _db.project);
  $PersonnelTableManager get personnel =>
      $PersonnelTableManager(_db.attachedDatabase, _db.personnel);
  $MediaTableManager get media =>
      $MediaTableManager(_db.attachedDatabase, _db.media);
  $SiteTableManager get site =>
      $SiteTableManager(_db.attachedDatabase, _db.site);
  $CoordinateTableManager get coordinate =>
      $CoordinateTableManager(_db.attachedDatabase, _db.coordinate);
  $CollEventTableManager get collEvent =>
      $CollEventTableManager(_db.attachedDatabase, _db.collEvent);
  $WeatherTableManager get weather =>
      $WeatherTableManager(_db.attachedDatabase, _db.weather);
  $CollPersonnelTableManager get collPersonnel =>
      $CollPersonnelTableManager(_db.attachedDatabase, _db.collPersonnel);
  $CollEffortTableManager get collEffort =>
      $CollEffortTableManager(_db.attachedDatabase, _db.collEffort);
  $NarrativeTableManager get narrative =>
      $NarrativeTableManager(_db.attachedDatabase, _db.narrative);
  $NarrativeMediaTableManager get narrativeMedia =>
      $NarrativeMediaTableManager(_db.attachedDatabase, _db.narrativeMedia);
  $SiteMediaTableManager get siteMedia =>
      $SiteMediaTableManager(_db.attachedDatabase, _db.siteMedia);
  $TaxonomyTableManager get taxonomy =>
      $TaxonomyTableManager(_db.attachedDatabase, _db.taxonomy);
  $SpecimenTableManager get specimen =>
      $SpecimenTableManager(_db.attachedDatabase, _db.specimen);
  $SpecimenMediaTableManager get specimenMedia =>
      $SpecimenMediaTableManager(_db.attachedDatabase, _db.specimenMedia);
  $AssociatedDataTableManager get associatedData =>
      $AssociatedDataTableManager(_db.attachedDatabase, _db.associatedData);
  $PersonnelListTableManager get personnelList =>
      $PersonnelListTableManager(_db.attachedDatabase, _db.personnelList);
  $MammalMeasurementTableManager get mammalMeasurement =>
      $MammalMeasurementTableManager(
          _db.attachedDatabase, _db.mammalMeasurement);
  $AvianMeasurementTableManager get avianMeasurement =>
      $AvianMeasurementTableManager(_db.attachedDatabase, _db.avianMeasurement);
  $HerpMeasurementTableManager get herpMeasurement =>
      $HerpMeasurementTableManager(_db.attachedDatabase, _db.herpMeasurement);
  $SpecimenPartTableManager get specimenPart =>
      $SpecimenPartTableManager(_db.attachedDatabase, _db.specimenPart);
}

class ListProjectResult {
  final String uuid;
  final String name;
  final String? created;
  final String? lastAccessed;
  ListProjectResult({
    required this.uuid,
    required this.name,
    this.created,
    this.lastAccessed,
  });
}
