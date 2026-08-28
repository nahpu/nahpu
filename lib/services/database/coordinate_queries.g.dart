// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coordinate_queries.dart';

// ignore_for_file: type=lint
mixin _$CoordinateQueryMixin on DatabaseAccessor<Database> {
  Project get project => attachedDatabase.project;
  Geography get geography => attachedDatabase.geography;
  Personnel get personnel => attachedDatabase.personnel;
  Media get media => attachedDatabase.media;
  Site get site => attachedDatabase.site;
  SiteAttribute get siteAttribute => attachedDatabase.siteAttribute;
  FossilSite get fossilSite => attachedDatabase.fossilSite;
  Coordinate get coordinate => attachedDatabase.coordinate;
  CollEvent get collEvent => attachedDatabase.collEvent;
  Environment get environment => attachedDatabase.environment;
  CollPersonnel get collPersonnel => attachedDatabase.collPersonnel;
  CollEffort get collEffort => attachedDatabase.collEffort;
  Narrative get narrative => attachedDatabase.narrative;
  NarrativeMedia get narrativeMedia => attachedDatabase.narrativeMedia;
  SiteMedia get siteMedia => attachedDatabase.siteMedia;
  EventMedia get eventMedia => attachedDatabase.eventMedia;
  Taxonomy get taxonomy => attachedDatabase.taxonomy;
  Specimen get specimen => attachedDatabase.specimen;
  SpecimenMedia get specimenMedia => attachedDatabase.specimenMedia;
  AssociatedData get associatedData => attachedDatabase.associatedData;
  SpecimenAssociatedData get specimenAssociatedData =>
      attachedDatabase.specimenAssociatedData;
  SiteAssociatedData get siteAssociatedData =>
      attachedDatabase.siteAssociatedData;
  EventAssociatedData get eventAssociatedData =>
      attachedDatabase.eventAssociatedData;
  PersonnelList get personnelList => attachedDatabase.personnelList;
  MammalAttribute get mammalAttribute => attachedDatabase.mammalAttribute;
  BirdAttribute get birdAttribute => attachedDatabase.birdAttribute;
  HerpAttribute get herpAttribute => attachedDatabase.herpAttribute;
  ArthropodAttribute get arthropodAttribute =>
      attachedDatabase.arthropodAttribute;
  FossilAttribute get fossilAttribute => attachedDatabase.fossilAttribute;
  ParasiteDetection get parasiteDetection => attachedDatabase.parasiteDetection;
  Parasite get parasite => attachedDatabase.parasite;
  SpecimenPart get specimenPart => attachedDatabase.specimenPart;
  CustomFieldDefinition get customFieldDefinition =>
      attachedDatabase.customFieldDefinition;
  CustomFieldValue get customFieldValue => attachedDatabase.customFieldValue;
  CoordinateQueryManager get managers => CoordinateQueryManager(this);
}

class CoordinateQueryManager {
  final _$CoordinateQueryMixin _db;
  CoordinateQueryManager(this._db);
  $ProjectTableManager get project =>
      $ProjectTableManager(_db.attachedDatabase, _db.project);
  $GeographyTableManager get geography =>
      $GeographyTableManager(_db.attachedDatabase, _db.geography);
  $PersonnelTableManager get personnel =>
      $PersonnelTableManager(_db.attachedDatabase, _db.personnel);
  $MediaTableManager get media =>
      $MediaTableManager(_db.attachedDatabase, _db.media);
  $SiteTableManager get site =>
      $SiteTableManager(_db.attachedDatabase, _db.site);
  $SiteAttributeTableManager get siteAttribute =>
      $SiteAttributeTableManager(_db.attachedDatabase, _db.siteAttribute);
  $FossilSiteTableManager get fossilSite =>
      $FossilSiteTableManager(_db.attachedDatabase, _db.fossilSite);
  $CoordinateTableManager get coordinate =>
      $CoordinateTableManager(_db.attachedDatabase, _db.coordinate);
  $CollEventTableManager get collEvent =>
      $CollEventTableManager(_db.attachedDatabase, _db.collEvent);
  $EnvironmentTableManager get environment =>
      $EnvironmentTableManager(_db.attachedDatabase, _db.environment);
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
  $EventMediaTableManager get eventMedia =>
      $EventMediaTableManager(_db.attachedDatabase, _db.eventMedia);
  $TaxonomyTableManager get taxonomy =>
      $TaxonomyTableManager(_db.attachedDatabase, _db.taxonomy);
  $SpecimenTableManager get specimen =>
      $SpecimenTableManager(_db.attachedDatabase, _db.specimen);
  $SpecimenMediaTableManager get specimenMedia =>
      $SpecimenMediaTableManager(_db.attachedDatabase, _db.specimenMedia);
  $AssociatedDataTableManager get associatedData =>
      $AssociatedDataTableManager(_db.attachedDatabase, _db.associatedData);
  $SpecimenAssociatedDataTableManager get specimenAssociatedData =>
      $SpecimenAssociatedDataTableManager(
        _db.attachedDatabase,
        _db.specimenAssociatedData,
      );
  $SiteAssociatedDataTableManager get siteAssociatedData =>
      $SiteAssociatedDataTableManager(
        _db.attachedDatabase,
        _db.siteAssociatedData,
      );
  $EventAssociatedDataTableManager get eventAssociatedData =>
      $EventAssociatedDataTableManager(
        _db.attachedDatabase,
        _db.eventAssociatedData,
      );
  $PersonnelListTableManager get personnelList =>
      $PersonnelListTableManager(_db.attachedDatabase, _db.personnelList);
  $MammalAttributeTableManager get mammalAttribute =>
      $MammalAttributeTableManager(_db.attachedDatabase, _db.mammalAttribute);
  $BirdAttributeTableManager get birdAttribute =>
      $BirdAttributeTableManager(_db.attachedDatabase, _db.birdAttribute);
  $HerpAttributeTableManager get herpAttribute =>
      $HerpAttributeTableManager(_db.attachedDatabase, _db.herpAttribute);
  $ArthropodAttributeTableManager get arthropodAttribute =>
      $ArthropodAttributeTableManager(
        _db.attachedDatabase,
        _db.arthropodAttribute,
      );
  $FossilAttributeTableManager get fossilAttribute =>
      $FossilAttributeTableManager(_db.attachedDatabase, _db.fossilAttribute);
  $ParasiteDetectionTableManager get parasiteDetection =>
      $ParasiteDetectionTableManager(
        _db.attachedDatabase,
        _db.parasiteDetection,
      );
  $ParasiteTableManager get parasite =>
      $ParasiteTableManager(_db.attachedDatabase, _db.parasite);
  $SpecimenPartTableManager get specimenPart =>
      $SpecimenPartTableManager(_db.attachedDatabase, _db.specimenPart);
  $CustomFieldDefinitionTableManager get customFieldDefinition =>
      $CustomFieldDefinitionTableManager(
        _db.attachedDatabase,
        _db.customFieldDefinition,
      );
  $CustomFieldValueTableManager get customFieldValue =>
      $CustomFieldValueTableManager(_db.attachedDatabase, _db.customFieldValue);
}
