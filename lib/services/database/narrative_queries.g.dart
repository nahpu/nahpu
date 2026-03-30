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
