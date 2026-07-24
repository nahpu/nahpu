// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coordinate_queries.dart';

// ignore_for_file: type=lint
mixin _$CoordinateQueryMixin on DatabaseAccessor<Database> {
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
  CoordinateQueryManager get managers => CoordinateQueryManager(this);
}

class CoordinateQueryManager {
  final _$CoordinateQueryMixin _db;
  CoordinateQueryManager(this._db);
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
        _db.attachedDatabase,
        _db.mammalMeasurement,
      );
  $AvianMeasurementTableManager get avianMeasurement =>
      $AvianMeasurementTableManager(_db.attachedDatabase, _db.avianMeasurement);
  $HerpMeasurementTableManager get herpMeasurement =>
      $HerpMeasurementTableManager(_db.attachedDatabase, _db.herpMeasurement);
  $SpecimenPartTableManager get specimenPart =>
      $SpecimenPartTableManager(_db.attachedDatabase, _db.specimenPart);
}
