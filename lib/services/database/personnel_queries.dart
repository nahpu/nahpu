import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

part 'personnel_queries.g.dart';

@DriftAccessor(
  include: {'tables.drift'},
)
class PersonnelQuery extends DatabaseAccessor<Database>
    with _$PersonnelQueryMixin {
  PersonnelQuery(super.db);

  // Personnel table
  Future<int> createPersonnel(PersonnelCompanion form) =>
      into(personnel).insert(form);

  Future<List<PersonnelListData>> getAllPersonnelListedInProjects() async {
    return await select(personnelList).get();
  }

  Future<List<PersonnelListData>> getProjectPersonnelLinks(
      String projectUuid) async {
    return (select(personnelList)
          ..where((t) => t.projectUuid.equals(projectUuid)))
        .get();
  }

  Future<bool> isImageUsed(String baseName) async {
    final PersonnelData? personnelList = await (select(personnel)
          ..where((tbl) => tbl.photoPath.equals(baseName))
          ..limit(1))
        .getSingleOrNull();
    return personnelList != null;
  }

  Future<int> updatePersonnelEntry(String id, PersonnelCompanion entry) {
    return (update(personnel)..where((t) => t.uuid.equals(id))).write(entry);
  }

  Future<String?> getPersonnelName(String personnelUuid) async {
    PersonnelData? personnel = await getPersonnelByUuid(personnelUuid);
    return personnel.name;
  }

  Future<List<PersonnelData>> searchPersonnel(String search) {
    return (select(personnel)..where((t) => t.name.like('%$search%'))).get();
  }

  Future<List<String>> rawSearchPersonnel(String query) async {
    List<String> personnelUuid = [];
    List<QueryRow> result = await customSelect(
            'SELECT * FROM personnel WHERE name LIKE \'%$query%\'')
        .get();
    for (final row in result) {
      personnelUuid.add(row.read<String>('uuid'));
    }
    return personnelUuid;
  }

  Future<void> createProjectPersonnelEntry(PersonnelListCompanion form) =>
      into(personnelList).insert(form);

  Future<int?> getCurrentFieldNumberByUuid(String personnelUuid) async {
    return await (select(personnel)..where((t) => t.uuid.equals(personnelUuid)))
        .map((e) => e.currentFieldNumber)
        .getSingle();
  }

  Future<String?> getInitial(String personnelUuid) {
    return (select(personnel)..where((t) => t.uuid.equals(personnelUuid)))
        .map((e) => e.initial)
        .getSingle();
  }

  Future<void> deletePersonnel(String uuid) {
    return (delete(personnel)..where((t) => t.uuid.equals(uuid))).go();
  }

  Future<PersonnelData> getPersonnelByUuid(String uuid) async {
    return await (select(personnel)..where((t) => t.uuid.equals(uuid)))
        .getSingle();
  }

  Future<bool> isPersonnelUsedBySpecimenRecords(
      {required String projectUuid, required String personnelUuid}) async {
    SpecimenData? specimenRecords = await (select(specimen)
          ..where((t) => t.projectUuid.equals(projectUuid))
          ..where((t) =>
              t.catalogerID.equals(personnelUuid) |
              t.preparatorID.equals(personnelUuid))
          ..limit(1))
        .getSingleOrNull();

    if (specimenRecords != null) {
      return true;
    }
    return false;
  }

  Future<bool> isPersonnelUsedByCollEvents(
      {required String projectUuid, required String personnelUuid}) async {
    List<CollEventData> eventRecords = await (select(collEvent)
          ..where((t) => t.projectUuid.equals(projectUuid))
          ..limit(1))
        .get();
    List<String> personnel = [];

    for (final record in eventRecords) {
      CollPersonnelData? person = await (select(collPersonnel)
            ..where((tbl) =>
                tbl.eventID.equals(record.id) &
                tbl.personnelId.equals(personnelUuid)))
          .getSingleOrNull();
      if (person != null) {
        personnel.add(person.personnelId ?? '');
      }
    }
    eventRecords.clear();

    if (personnel.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> deleteProjectPersonnel(
      {required projectUuid, required personnelUuid}) {
    return (delete(personnelList)
          ..where((t) =>
              t.projectUuid.equals(projectUuid) &
              t.personnelUuid.equals(personnelUuid)))
        .go();
  }

  Future<void> deleteAllProjectPersonnel({required String projectUuid}) {
    return (delete(personnelList)
          ..where((t) => t.projectUuid.equals(projectUuid)))
        .go();
  }

  Future<List<PersonnelData>> getPersonnelByProjectUuid(
      String projectUuid) async {
    List<PersonnelListData> personnelByProject = await (select(personnelList)
          ..where((t) => t.projectUuid.equals(projectUuid)))
        .get();
    List<PersonnelData> personnelData = [];
    for (PersonnelListData personnel in personnelByProject) {
      if (personnel.personnelUuid != null) {
        personnelData.add(await getPersonnelByUuid(personnel.personnelUuid!));
      }
    }
    return personnelData;
  }

  Future<List<PersonnelData>> getAllPersonnel() {
    return select(personnel).get();
  }

  Future<void> deleteAllPersonnel() {
    return delete(personnel).go();
  }
}
