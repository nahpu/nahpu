// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narrative_queries.dart';

// ignore_for_file: type=lint
mixin _$NarrativeQueryMixin on DatabaseAccessor<Database> {
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
  MammalAttribute get mammalAttribute => attachedDatabase.mammalAttribute;
  BirdAttribute get birdAttribute => attachedDatabase.birdAttribute;
  HerpAttribute get herpAttribute => attachedDatabase.herpAttribute;
  SpecimenPart get specimenPart => attachedDatabase.specimenPart;
  NarrativeQueryManager get managers => NarrativeQueryManager(this);
}

class NarrativeQueryManager {
  final _$NarrativeQueryMixin _db;
  NarrativeQueryManager(this._db);
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
  $MammalAttributeTableManager get mammalAttribute =>
      $MammalAttributeTableManager(_db.attachedDatabase, _db.mammalAttribute);
  $BirdAttributeTableManager get birdAttribute =>
      $BirdAttributeTableManager(_db.attachedDatabase, _db.birdAttribute);
  $HerpAttributeTableManager get herpAttribute =>
      $HerpAttributeTableManager(_db.attachedDatabase, _db.herpAttribute);
  $SpecimenPartTableManager get specimenPart =>
      $SpecimenPartTableManager(_db.attachedDatabase, _db.specimenPart);
}
