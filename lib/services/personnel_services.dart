import 'dart:io';
import 'dart:math';

import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/utility_services.dart';
import 'package:path/path.dart' as path;

class PersonnelServices extends AppServices {
  const PersonnelServices({required super.ref});

  Future<int> createPersonnel(PersonnelCompanion personnel) async {
    int id = await PersonnelQuery(dbAccess).createPersonnel(personnel);
    return id;
  }

  Future<List<String>> getAllPersonnelListedInProjects() async {
    List<PersonnelListData> personnel =
        await PersonnelQuery(dbAccess).getAllPersonnelListedInProjects();

    return getDistinctList(personnel.map((e) => e.personnelUuid).toList());
  }

  Future<bool> isImageUsedInPersonnelPhoto(File file) async {
    String baseName = path.basename(file.path);
    return await PersonnelQuery(dbAccess).isImageUsed(baseName);
  }

  Future<String?> getPersonnelName(String uuid) async {
    PersonnelData? personnel =
        await PersonnelQuery(dbAccess).getPersonnelByUuid(uuid);
    return personnel.name;
  }

  Future<List<String>> searchPersonnel(String search) async {
    List<PersonnelData> data =
        await PersonnelQuery(dbAccess).searchPersonnel(search);

    return data.map((e) => e.uuid).toList();
  }

  Future<void> addMultiplePersonnelToProject(
      List<PersonnelData> personnel) async {
    for (final person in personnel) {
      await addPersonnelToProject(PersonnelListCompanion(
          personnelUuid: db.Value(person.uuid),
          projectUuid: db.Value(currentProjectUuid)));
    }
    invalidatePersonnel();
  }

  Future<void> addPersonnelToProject(PersonnelListCompanion form) async {
    await PersonnelQuery(dbAccess).createProjectPersonnelEntry(form);
    invalidatePersonnel();
  }

  Future<void> updatePersonnelEntry(
      String uuid, PersonnelCompanion personnel) async {
    await PersonnelQuery(dbAccess).updatePersonnelEntry(uuid, personnel);
    invalidatePersonnel();
  }

  Future<int?> getCurrentPersonnelFieldNumber(String personnelUuid) async {
    return await PersonnelQuery(dbAccess)
        .getCurrentFieldNumberByUuid(personnelUuid);
  }

  Future<PersonnelData> getPersonnelByUuid(String uuid) async {
    return await PersonnelQuery(dbAccess).getPersonnelByUuid(uuid);
  }

  Future<List<PersonnelData>> getAllPersonnel() async {
    return await PersonnelQuery(dbAccess).getAllPersonnel();
  }

  Future<List<PersonnelData>> getPersonnelByProjectUuid(String projectUuid) async {
    return await PersonnelQuery(dbAccess).getPersonnelByProjectUuid(projectUuid);
  }  

  Future<void> deleteProjectPersonnel(String personnelUuid) async {
    bool isUsedInPersonnel = await PersonnelQuery(dbAccess)
        .isPersonnelUsedBySpecimenRecords(
            projectUuid: currentProjectUuid, personnelUuid: personnelUuid);
    bool isUsedInCollEvent = await PersonnelQuery(dbAccess)
        .isPersonnelUsedByCollEvents(
            projectUuid: currentProjectUuid, personnelUuid: personnelUuid);
    if (isUsedInPersonnel || isUsedInCollEvent) {
      String recordType = isUsedInPersonnel ? 'specimen' : 'collection event';
      recordType = isUsedInPersonnel && isUsedInCollEvent
          ? 'specimen and collection event'
          : recordType;
      throw Exception(
          'Failed to delete! Personnel is being used in the $recordType records.');
    } else {
      await PersonnelQuery(dbAccess).deleteProjectPersonnel(
          projectUuid: currentProjectUuid, personnelUuid: personnelUuid);
      invalidatePersonnel();
    }
  }

  Future<void> deletePersonnel(String uuid) async {
    await PersonnelQuery(dbAccess).deletePersonnel(uuid);
    invalidatePersonnel();
  }

  Future<void> deletePersonnelFromList(List<String> personnelList) async {
    for (final personnel in personnelList) {
      await deletePersonnel(personnel);
    }
    invalidatePersonnel();
  }

  void deleteAllPersonnelDb() {
    PersonnelQuery(dbAccess).deleteAllPersonnel();
    invalidatePersonnel();
  }

  void invalidatePersonnel() {
    ref.invalidate(projectPersonnelProvider);
    ref.invalidate(allPersonnelProvider);
  }
}

const String avatarPath = 'assets/avatars/';

const List<String> availableBirdAvatar = [
  'canton_lep_esquisita.png',
  'canton_lep_hybrid2.png',
  'canton_lep_velutina.png',
];

const List<String> availableMammalAvatar = [
  'handika_crocidura.png',
  'handika_dasypus.png',
  'handika_haeromys.png',
];

const List<String> availableBatAvatar = [
  'handika_rhinolophus.png',
  'hnadika_rousettus.png',
];

class PersonnelImageService {
  PersonnelImageService();

  final random = Random();

  String getDefaultAvatar(CatalogFmt catalogFmt) {
    switch (catalogFmt) {
      case CatalogFmt.birds:
        return _getBirdAvatar();
      case CatalogFmt.generalMammals:
        return _getMammalAvatar();
      case CatalogFmt.bats:
        return _getBatAvatar();
    }
  }

  String _getBirdAvatar() {
    final index = random.nextInt(availableBirdAvatar.length);
    return '$avatarPath${availableBirdAvatar[index]}';
  }

  String _getMammalAvatar() {
    final index = random.nextInt(availableMammalAvatar.length);
    return '$avatarPath${availableMammalAvatar[index]}';
  }

  String _getBatAvatar() {
    final index = random.nextInt(availableBatAvatar.length);
    return '$avatarPath${availableBatAvatar[index]}';
  }
}

class PersonnelSearchService {
  PersonnelSearchService({required this.data});
  final List<PersonnelData> data;

  List<PersonnelData> search(String query) {
    return data.where((element) => _isPersonnelMatch(element, query)).toList();
  }

  bool _isPersonnelMatch(PersonnelData data, String query) {
    return _isNameMatch(data.name, query) ||
        _isAffiliationMatch(data.affiliation, query);
  }

  bool _isNameMatch(String? name, String query) {
    if (name != null) {
      return name.toLowerCase().contains(query);
    }
    return false;
  }

  bool _isAffiliationMatch(String? affiliation, String query) {
    if (affiliation != null) {
      return affiliation.toLowerCase().contains(query);
    }
    return false;
  }
}
