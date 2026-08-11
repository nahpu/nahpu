import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/parasite_queries.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

const String tissueIDPrefixKey = 'tissueIDPrefix';
const String tissueIDNumberKey = 'tissueIDNumber';
String formatProjectFieldId(ProjectData project, int? number) {
  if (number == null) return '';
  return '${project.catalogNumberPrefix ?? ''}'
      '$number'
      '${project.catalogNumberSuffix ?? ''}';
}

/// Coordinates specimen persistence, including taxon-specific attribute rows.
///
/// Each specimen owns at most one taxon-specific attribute row, selected by
/// its active catalog format.
class SpecimenServices extends AppServices {
  const SpecimenServices({required super.ref});

  Future<String> createSpecimen() async {
    final CatalogFmt catalogFmt = await ref.watch(
      catalogFmtNotifierProvider.future,
    );
    final String specimenUuid = uuid;
    final FieldIdMode fieldIdMode = await ref.watch(
      fieldIdModeNotifierProvider.future,
    );
    await dbAccess.transaction(() async {
      final currentProjectNumber = fieldIdMode == FieldIdMode.project
          ? await ProjectFieldIdServices(ref: ref).takeNextNumber()
          : null;
      await SpecimenQuery(dbAccess).createSpecimen(
        SpecimenCompanion(
          uuid: db.Value(specimenUuid),
          projectUuid: db.Value(currentProjectUuid),
          taxonGroup: db.Value(matchCatFmtToTaxonGroup(catalogFmt)),
          projectFieldNumber: db.Value(currentProjectNumber),
        ),
      );
      switch (catalogFmt) {
        case CatalogFmt.birds:
          await _createBirdSpecimen(specimenUuid);
          break;
        case CatalogFmt.mammals:
          await _createMammalSpecimen(specimenUuid);
          break;
        case CatalogFmt.herpetofauna:
          await _createHerpSpecimen(specimenUuid);
          break;
        case CatalogFmt.arthropods:
          await _createArthropodSpecimen(specimenUuid);
          break;
      }
      if (supportsParasites(catalogFmt)) {
        await ParasiteQuery(dbAccess).ensureDetection(specimenUuid);
      }
    });
    invalidateSpecimenList();

    return specimenUuid;
  }

  String getIconPath() {
    return ref
        .watch(catalogFmtNotifierProvider)
        .when(
          data: (fmt) {
            return matchCatalogFmtToIconPath(fmt);
          },
          loading: () => matchCatalogFmtToIconPath(CatalogFmt.mammals),
          error: (error, stack) =>
              matchCatalogFmtToIconPath(CatalogFmt.mammals),
        );
  }

  /// Returns the new specimen's uuid, or null when the origin has no parts.
  Future<String?> createSpecimenDuplicatePart(String specimenUuid) async {
    List<SpecimenPartData> partData = await SpecimenPartQuery(
      dbAccess,
    ).getSpecimenParts(specimenUuid);
    if (partData.isEmpty) {
      return null;
    }
    String newSpecimenUuid = await createSpecimen();

    for (var part in partData) {
      SpecimenPartServices(ref: ref).createSpecimenPart(
        SpecimenPartCompanion(
          specimenUuid: db.Value(newSpecimenUuid),
          type: db.Value(part.type),
          count: db.Value(part.count),
          treatment: db.Value(part.treatment),
          additionalTreatment: db.Value(part.additionalTreatment),
          storage: db.Value(part.storage),
          storageLocation: db.Value(part.storageLocation),
          museumPermanent: db.Value(part.museumPermanent),
          museumLoan: db.Value(part.museumLoan),
        ),
      );
    }

    ref.invalidate(partBySpecimenProvider);
    return newSpecimenUuid;
  }

  Future<List<SpecimenData>> getAllSpecimens() async {
    return SpecimenQuery(dbAccess).getAllSpecimens(currentProjectUuid);
  }

  Future<List<String>> getAllSpecimenUuids() async {
    return SpecimenQuery(dbAccess).getAllSpecimenUuids(currentProjectUuid);
  }

  Future<SpecimenData> getSpecimen(String specimenUuid) async {
    return SpecimenQuery(dbAccess).getSpecimenByUuid(specimenUuid);
  }

  Future<List<String>> getRecordedGroupList() async {
    return SpecimenQuery(dbAccess).getUniqueTaxonGroup(currentProjectUuid);
  }

  Future<List<String>> getColumnNames() async {
    return SpecimenQuery(dbAccess).getColumnNames();
  }

  Future<void> createSpecimenMediaFromList(
    String specimenUuid,
    List<String> filePaths,
  ) async {
    for (String filePath in filePaths) {
      await createSpecimenMedia(specimenUuid, filePath);
    }
  }

  Future<void> createSpecimenMedia(String specimenUuid, String filePath) async {
    final metadata = await MediaMetadataServices().extract(File(filePath));
    int mediaId = await MediaDbQuery(dbAccess).createMedia(
      MediaCompanion(
        projectUuid: db.Value(currentProjectUuid),
        fileName: db.Value(basename(filePath)),
        category: db.Value(matchMediaCategory(MediaCategory.specimen)),
        taken: db.Value(metadata.taken),
        camera: db.Value(metadata.camera),
        lenses: db.Value(metadata.lenses),
        additionalExif: db.Value(metadata.additionalExif),
      ),
    );
    SpecimenMediaCompanion entries = SpecimenMediaCompanion(
      specimenUuid: db.Value(specimenUuid),
      mediaId: db.Value(mediaId),
    );
    await SpecimenQuery(dbAccess).createSpecimenMedia(entries);
    // ref.invalidate(specimenMediaProvider);
  }

  Future<SpecimenMediaData> getSpecimenMediaByMediaId(int mediaId) async {
    return await SpecimenQuery(dbAccess).getSpecimenMediaByMediaId(mediaId);
  }

  Future<List<SpecimenData>> getMammalSpecimens() async {
    return SpecimenQuery(dbAccess).getAllMammalSpecimens(currentProjectUuid);
  }

  Future<List<SpecimenData>> getBirdSpecimens() async {
    return SpecimenQuery(dbAccess).getAllAvianSpecimens(currentProjectUuid);
  }

  Future<List<SpecimenData>> getBatSpecimens() async {
    return SpecimenQuery(dbAccess).getAllBatSpecimens(currentProjectUuid);
  }

  Future<List<SpecimenData>> getSpecimenList() async {
    return SpecimenQuery(dbAccess).getAllSpecimens(currentProjectUuid);
  }

  Future<List<SpecimenData>> getSpecimenPerSite(int siteID) async {
    List<int> eventID = await CollEventServices(
      ref: ref,
    ).getEventPerSite(siteID);
    List<SpecimenData> allSpecimens = [];
    for (var id in eventID) {
      List<SpecimenData> specimenList = await SpecimenQuery(
        dbAccess,
      ).getSpecimenPerEvent(id);
      allSpecimens.addAll(specimenList);
    }
    return allSpecimens;
  }

  Future<List<SpecimenData>> getSpecimenListByTaxonGroup(
    String taxonGroup,
  ) async {
    List<SpecimenData> specimenList = await getSpecimenList();
    List<SpecimenData> filteredList = specimenList
        .where((element) => element.taxonGroup == taxonGroup)
        .toList();
    return filteredList;
  }

  Future<List<SpecimenData>> getSpecimenListForAllMammals() async {
    List<SpecimenData> specimenList = await getSpecimenList();
    List<SpecimenData> filteredList = specimenList
        .where(
          (element) =>
              element.taxonGroup == 'General Mammals' ||
              element.taxonGroup == 'Bats',
        )
        .toList();
    return filteredList;
  }

  Future<List<int?>> getAllSpecies() {
    return SpecimenQuery(dbAccess).getAllSpecies(currentProjectUuid);
  }

  Future<List<int>> getAllDistinctSpecies() async {
    final List<int?> speciesList = await getAllSpecies();
    return speciesList.toSet().whereType<int>().toList();
  }

  Future<TaxonomyData> getTaxonById(int id) {
    return TaxonomyQuery(dbAccess).getTaxonById(id);
  }

  Future<int> getSpecimenFieldNumber(String personnelUuid) async {
    int? fieldNumber = await PersonnelQuery(
      dbAccess,
    ).getCurrentFieldNumberByUuid(personnelUuid);
    return _getCurrentFieldNumber(fieldNumber);
  }

  int _getCurrentFieldNumber(int? currentFieldNum) {
    if (currentFieldNum == null) {
      return 0;
    } else {
      return currentFieldNum;
    }
  }

  Future<void> _createMammalSpecimen(String specimenUuid) async {
    await MammalSpecimenQuery(dbAccess).createMammalAttributes(
      MammalAttributeCompanion(
        specimenUuid: db.Value(specimenUuid),
        weightUnit: const db.Value('g'),
      ),
    );
  }

  Future<MammalAttributeData> getMammalAttributeData(String specimenUuid) {
    return MammalSpecimenQuery(dbAccess).getMammalAttributeByUuid(specimenUuid);
  }

  void updateMammalAttribute(
    String specimenUuid,
    MammalAttributeCompanion entries,
  ) {
    MammalSpecimenQuery(dbAccess).updateMammalAttributes(specimenUuid, entries);
  }

  void clearMammalSexAttributes(String specimenUuid) {
    updateMammalAttribute(
      specimenUuid,
      const MammalAttributeCompanion(
        testisPosition: db.Value(null),
        testisLength: db.Value(null),
        testisWidth: db.Value(null),
        epididymisAppearance: db.Value(null),
        vaginaOpening: db.Value(null),
        pubicSymphysis: db.Value(null),
        reproductiveStage: db.Value(null),
        mammaeAxillaryCount: db.Value(null),
        mammaeAbdominalCount: db.Value(null),
        mammaeInguinalCount: db.Value(null),
        mammaeCondition: db.Value(null),
        embryoLeftCount: db.Value(null),
        embryoRightCount: db.Value(null),
        embryoCR: db.Value(null),
        leftPlacentalScars: db.Value(null),
        rightPlacentalScars: db.Value(null),
      ),
    );
  }

  Future<void> _createHerpSpecimen(String specimenUuid) async {
    await HerpSpecimenQuery(dbAccess).createHerpAttributes(
      HerpAttributeCompanion(
        specimenUuid: db.Value(specimenUuid),
        weightUnit: const db.Value('g'),
      ),
    );
  }

  Future<HerpAttributeData> getHerpAttributeData(String specimenUuid) {
    return HerpSpecimenQuery(dbAccess).getHerpAttributeByUuid(specimenUuid);
  }

  void updateHerpAttribute(
    String specimenUuid,
    HerpAttributeCompanion entries,
  ) {
    HerpSpecimenQuery(dbAccess).updateHerpAttributes(specimenUuid, entries);
  }

  void clearHerpSexAttributes(String specimenUuid) {
    updateHerpAttribute(specimenUuid, const HerpAttributeCompanion());
  }

  Future<void> _createBirdSpecimen(String specimenUuid) async {
    await BirdSpecimenQuery(dbAccess).createBirdAttributes(
      BirdAttributeCompanion(
        specimenUuid: db.Value(specimenUuid),
        weightUnit: const db.Value('g'),
      ),
    );
  }

  Future<void> updateSpecimenSkipInvalidation(
    String uuid,
    SpecimenCompanion entries,
  ) async {
    await _updateSpecimen(uuid, entries);
  }

  Future<void> updateSpecimen(String uuid, SpecimenCompanion entries) async {
    await _updateSpecimen(uuid, entries);
    invalidateSpecimenList();
  }

  Future<void> setPersonnelFieldIdentifier({
    required String specimenUuid,
    required String catalogerUuid,
    required int fieldNumber,
  }) async {
    await dbAccess.transaction(() async {
      final currentNumber = await PersonnelQuery(
        dbAccess,
      ).getCurrentFieldNumberByUuid(catalogerUuid);
      final nextNumber = currentNumber != null && currentNumber > fieldNumber
          ? currentNumber
          : fieldNumber + 1;
      await PersonnelQuery(dbAccess).updatePersonnelEntry(
        catalogerUuid,
        PersonnelCompanion(currentFieldNumber: db.Value(nextNumber)),
      );
      await SpecimenQuery(dbAccess).updateSpecimenEntry(
        specimenUuid,
        SpecimenCompanion(
          fieldNumber: db.Value(fieldNumber),
          projectFieldNumber: const db.Value(null),
        ),
      );
    });
    invalidateSpecimenList();
  }

  Future<void> setProjectFieldIdentifier({
    required String specimenUuid,
    required int projectFieldNumber,
  }) async {
    await dbAccess.transaction(() async {
      if (await ProjectFieldIdServices(ref: ref).isAutoIncrementEnabled()) {
        final project = await ProjectQuery(
          dbAccess,
        ).getProjectByUuid(currentProjectUuid);
        final nextNumber =
            project.currentCatalogNumber != null &&
                project.currentCatalogNumber! > projectFieldNumber
            ? project.currentCatalogNumber
            : projectFieldNumber + 1;
        await ProjectQuery(dbAccess).updateProjectEntry(
          currentProjectUuid,
          ProjectCompanion(currentCatalogNumber: db.Value(nextNumber)),
        );
      }
      await SpecimenQuery(dbAccess).updateSpecimenEntry(
        specimenUuid,
        SpecimenCompanion(
          fieldNumber: const db.Value(null),
          projectFieldNumber: db.Value(projectFieldNumber),
        ),
      );
    });
    invalidateSpecimenList();
  }

  Future<void> _updateSpecimen(String uuid, SpecimenCompanion entries) async {
    try {
      await SpecimenQuery(dbAccess).updateSpecimenEntry(uuid, entries);
    } catch (_) {
      rethrow;
    }
  }

  Future<BirdAttributeData> getBirdAttributeData(String specimenUuid) {
    return BirdSpecimenQuery(dbAccess).getBirdAttributeByUuid(specimenUuid);
  }

  Future<List<SpecimenMediaData>> getSpecimenMedia(String specimenUuid) async {
    return await SpecimenQuery(dbAccess).getSpecimenMedia(specimenUuid);
  }

  void updateBirdAttribute(
    String specimenUuid,
    BirdAttributeCompanion entries,
  ) {
    BirdSpecimenQuery(dbAccess).updateBirdAttributes(specimenUuid, entries);
  }

  void clearBirdSexAttributes(String specimenUuid) {
    updateBirdAttribute(
      specimenUuid,
      const BirdAttributeCompanion(
        testisLength: db.Value(null),
        testisWidth: db.Value(null),
        testisRemark: db.Value(null),
        ovaryLength: db.Value(null),
        ovaryWidth: db.Value(null),
        ovaryAppearance: db.Value(null),
        firstOvaSize: db.Value(null),
        secondOvaSize: db.Value(null),
        thirdOvaSize: db.Value(null),
        oviductWidth: db.Value(null),
        oviductAppearance: db.Value(null),
        ovaryRemark: db.Value(null),
      ),
    );
  }

  Future<void> _createArthropodSpecimen(String specimenUuid) async {
    await ArthropodSpecimenQuery(dbAccess).createArthropodAttributes(
      ArthropodAttributeCompanion(specimenUuid: db.Value(specimenUuid)),
    );
  }

  Future<ArthropodAttributeData> getArthropodAttributeData(
    String specimenUuid,
  ) {
    return ArthropodSpecimenQuery(
      dbAccess,
    ).getArthropodAttributeByUuid(specimenUuid);
  }

  Future<void> updateArthropodAttribute(
    String specimenUuid,
    ArthropodAttributeCompanion entries,
  ) {
    return ArthropodSpecimenQuery(
      dbAccess,
    ).updateArthropodAttributes(specimenUuid, entries);
  }

  Future<void> deleteBirdAttributes(String specimenUuid) async {
    await BirdSpecimenQuery(dbAccess).deleteBirdAttributes(specimenUuid);
  }

  Future<void> deleteMammalAttributes(String specimenUuid) async {
    await MammalSpecimenQuery(dbAccess).deleteMammalAttributes(specimenUuid);
  }

  Future<void> deleteHerpAttributes(String specimenUuid) async {
    await HerpSpecimenQuery(dbAccess).deleteHerpAttributes(specimenUuid);
  }

  Future<void> deleteArthropodAttributes(String specimenUuid) async {
    await ArthropodSpecimenQuery(
      dbAccess,
    ).deleteArthropodAttributes(specimenUuid);
  }

  Future<void> deleteSpecimen(
    String specimenUuid,
    CatalogFmt catalogFmt,
  ) async {
    await deleteAllSpecimenParts(specimenUuid);
    await ParasiteQuery(dbAccess).deleteAllForSpecimen(specimenUuid);
    await AssociatedDataQuery(dbAccess).deleteAllAssociatedData(specimenUuid);
    switch (catalogFmt) {
      case CatalogFmt.birds:
        await deleteBirdAttributes(specimenUuid);
        break;
      case CatalogFmt.mammals:
        await deleteMammalAttributes(specimenUuid);
        break;
      case CatalogFmt.herpetofauna:
        await deleteHerpAttributes(specimenUuid);
        break;
      case CatalogFmt.arthropods:
        await deleteArthropodAttributes(specimenUuid);
        break;
    }
    await SpecimenQuery(dbAccess).deleteAllSpecimenMedias(specimenUuid);
    await SpecimenQuery(dbAccess).deleteSpecimen(specimenUuid);
    invalidateSpecimenList();
  }

  Future<void> deleteAllSpecimens(String projectUuid) async {
    List<SpecimenData> specimenList = await SpecimenQuery(
      dbAccess,
    ).getAllSpecimens(projectUuid);
    for (var specimen in specimenList) {
      await deleteAllSpecimenParts(specimen.uuid);
      await ParasiteQuery(dbAccess).deleteAllForSpecimen(specimen.uuid);
      await AssociatedDataQuery(
        dbAccess,
      ).deleteAllAssociatedData(specimen.uuid);
      await SpecimenQuery(dbAccess).deleteAllSpecimenMedias(specimen.uuid);
      CatalogFmt catalogFmt = matchTaxonGroupToCatFmt(specimen.taxonGroup);
      switch (catalogFmt) {
        case CatalogFmt.birds:
          await deleteBirdAttributes(specimen.uuid);
          break;
        case CatalogFmt.mammals:
          await deleteMammalAttributes(specimen.uuid);
          break;
        case CatalogFmt.herpetofauna:
          await deleteHerpAttributes(specimen.uuid);
          break;
        case CatalogFmt.arthropods:
          await deleteArthropodAttributes(specimen.uuid);
          break;
      }
    }
    await SpecimenQuery(dbAccess).deleteAllSpecimens(projectUuid);
    invalidateSpecimenList();
  }

  Future<void> deleteAllSpecimenParts(String specimenUuid) async {
    await SpecimenPartQuery(dbAccess).deleteAllSpecimenParts(specimenUuid);
    _invalidateParts();
  }

  Future<void> deleteSpecimenPart(int partId) async {
    await SpecimenPartQuery(dbAccess).deleteSpecimenPart(partId);
    _invalidateParts();
  }

  Future<void> deleteSpecimenPartsFromList(List<int> partIds) async {
    await SpecimenPartQuery(dbAccess).deleteSpecimenPartsFromList(partIds);
    _invalidateParts();
  }

  void invalidateSpecimenList() {
    ref.invalidate(specimenEntryProvider);
    ref.invalidate(taxonDataProvider);
    ref.invalidate(projectPersonnelProvider);
  }

  void _invalidateParts() {
    ref.invalidate(partBySpecimenProvider);
    ref.invalidate(specimenPartEntryProvider);
  }
}

class SpecimenSearchServices {
  SpecimenSearchServices({
    required this.db,
    required this.specimenEntries,
    required this.searchOption,
  });

  final List<SpecimenData> specimenEntries;
  final Database db;
  final SpecimenSearchOption searchOption;

  Future<List<SpecimenData>> search(String query) async {
    switch (searchOption) {
      case SpecimenSearchOption.all:
        return await searchAll(query);
      case SpecimenSearchOption.fieldNumber:
        return specimenEntries
            .where((element) => _isMatchFieldNum(element.fieldNumber, query))
            .toList();
      case SpecimenSearchOption.cataloger:
        List<String> matchedPersons = await _searchPersonnel(query);
        return specimenEntries
            .where(
              (element) =>
                  _isMatchedPerson(matchedPersons, element.catalogerID),
            )
            .toList();
      case SpecimenSearchOption.preparator:
        List<String> matchedPersons = await _searchPersonnel(query);
        return specimenEntries
            .where(
              (element) =>
                  _isMatchedPerson(matchedPersons, element.preparatorID),
            )
            .toList();
      case SpecimenSearchOption.collector:
        List<String> matchedPersons = await _searchPersonnel(query);
        List<int> matchedColPersons = await _searchColPersonnel(
          matchedPersons,
          query,
        );
        return specimenEntries
            .where(
              (element) => _isMatchedColPerson(
                matchedColPersons,
                element.collPersonnelID,
              ),
            )
            .toList();
      case SpecimenSearchOption.condition:
        return specimenEntries
            .where((element) => element.condition.isContain(query))
            .toList();
      case SpecimenSearchOption.prepDate:
        return specimenEntries
            .where((element) => element.prepDate.isContain(query))
            .toList();
      case SpecimenSearchOption.prepTime:
        return specimenEntries
            .where((element) => element.prepTime.isContain(query))
            .toList();
      case SpecimenSearchOption.taxa:
        List<int> matchedTaxa = await _searchTaxa(query);
        return specimenEntries
            .where((element) => _isMatchTaxa(matchedTaxa, element.speciesID))
            .toList();
      case SpecimenSearchOption.prepType:
        List<String> matchedPrepType = await _searchPrepType(query);
        return specimenEntries
            .where((element) => _isMatchPrepType(matchedPrepType, element.uuid))
            .toList();
    }
  }

  Future<List<SpecimenData>> searchAll(String query) async {
    List<String> matchedPersons = await _searchPersonnel(query);
    List<int> matchedColPersons = await _searchColPersonnel(
      matchedPersons,
      query,
    );
    List<String> matchedPrepType = await _searchPrepType(query);
    List<int> matchedTaxa = await _searchTaxa(query);
    List<SpecimenData> filteredList = specimenEntries
        .where(
          (e) =>
              _isMatchFieldNum(e.fieldNumber, query) ||
              _isMatchedPerson(matchedPersons, e.catalogerID) ||
              _isMatchedPerson(matchedPersons, e.preparatorID) ||
              _isMatchedColPerson(matchedColPersons, e.collPersonnelID) ||
              e.condition.isContain(query) ||
              e.prepDate.isContain(query) ||
              e.prepTime.isContain(query) ||
              _isMatchTaxa(matchedTaxa, e.speciesID) ||
              _isMatchPrepType(matchedPrepType, e.uuid),
        )
        .toList();
    return filteredList;
  }

  bool _isMatchFieldNum(int? fieldNum, String query) {
    return fieldNum.toString().isContain(query);
  }

  bool _isMatchedPerson(List<String> matchedPersons, String? personnelUuid) {
    if (matchedPersons.isEmpty || personnelUuid == null) {
      return false;
    }
    return matchedPersons.contains(personnelUuid);
  }

  bool _isMatchedColPerson(List<int> matchedColPersons, int? colPersonId) {
    if (matchedColPersons.isEmpty || colPersonId == null) {
      return false;
    }
    return matchedColPersons.contains(colPersonId);
  }

  bool _isMatchPrepType(List<String> matchedPrepType, String specimenUuid) {
    if (matchedPrepType.isEmpty) {
      return false;
    }
    return matchedPrepType.contains(specimenUuid);
  }

  bool _isMatchTaxa(List<int> matchedSpecies, int? speciesId) {
    if (matchedSpecies.isEmpty || speciesId == null) {
      return false;
    }
    return matchedSpecies.contains(speciesId);
  }

  Future<List<String>> _searchPersonnel(String query) async {
    final person = await PersonnelQuery(db).searchPersonnel(query);
    return person.map((e) => e.uuid).toList();
  }

  Future<List<int>> _searchTaxa(String query) async {
    final listSpecies = await TaxonomyQuery(db).searchTaxon(query);
    return listSpecies.map((e) => e.id).toList();
  }

  Future<List<String>> _searchPrepType(String query) async {
    final prepType = await SpecimenPartQuery(db).searchPrepType(query);
    return prepType;
  }

  Future<List<int>> _searchColPersonnel(
    List<String> matchedPersons,
    String query,
  ) async {
    if (matchedPersons.isEmpty) {
      return [];
    }
    final person = await CollPersonnelQuery(
      db,
    ).searchCollectingPersonnel(matchedPersons, query);
    return person.map((e) => e.id).toList();
  }
}

class ProjectFieldIdServices extends AppServices {
  const ProjectFieldIdServices({required super.ref});

  Future<ProjectData> getProject() {
    return ProjectQuery(dbAccess).getProjectByUuid(currentProjectUuid);
  }

  Future<int?> takeNextNumber() async {
    if (!await isAutoIncrementEnabled()) return null;
    final project = await getProject();
    final number = project.currentCatalogNumber;
    if (number == null) return null;
    await ProjectQuery(dbAccess).updateProjectEntry(
      currentProjectUuid,
      ProjectCompanion(currentCatalogNumber: db.Value(number + 1)),
    );
    return number;
  }

  Future<bool> isAutoIncrementEnabled() async {
    final value = await rust_config.getUserConfigString(
      key: projectFieldIdAutoIncrementPrefKey,
    );
    return value == true.toString();
  }

  Future<void> updateSettings({
    required String prefix,
    required String suffix,
    required int? currentNumber,
  }) {
    return ProjectQuery(dbAccess).updateProjectEntry(
      currentProjectUuid,
      ProjectCompanion(
        catalogNumberPrefix: db.Value(prefix),
        currentCatalogNumber: db.Value(currentNumber),
        catalogNumberSuffix: db.Value(suffix),
      ),
    );
  }

  Future<bool> hasAssignedProjectNumbers() {
    return ProjectQuery(dbAccess).hasProjectFieldNumbers(currentProjectUuid);
  }
}

class TissueIdServices extends AppServices {
  const TissueIdServices({required super.ref});

  SharedPreferences get _prefs => ref.read(settingProvider);

  Future<String> getNewNumber() async {
    String prefix = getPrefix();
    int? number = _getSettingNumber();
    String numberString = getNumberString();
    await incrementNumber(number ?? 0);
    return '$prefix$numberString';
  }

  String getPrefix() {
    return _geSettingPrefix() ?? '';
  }

  String getNumberString() {
    return _getSettingNumber() == null ? '' : _getSettingNumber().toString();
  }

  Future<String?> repeatNumber(String specimenUuid) async {
    return SpecimenPartQuery(dbAccess).getLastEnteredTissueID(specimenUuid);
  }

  Future<String> setTissueID(String prefix, String number) async {
    await setPrefix(prefix);
    await setNumber(number);
    return '$prefix$number';
  }

  Future<void> incrementNumber(int number) async {
    await setNumber((number + 1).toString());
  }

  Future<void> setPrefix(String prefix) async {
    await _prefs.setString(tissueIDPrefixKey, prefix);
  }

  Future<void> setNumber(String number) async {
    await _prefs.setInt(tissueIDNumberKey, int.tryParse(number) ?? 0);
  }

  String? _geSettingPrefix() {
    return _prefs.getString(tissueIDPrefixKey);
  }

  int? _getSettingNumber() {
    return _prefs.getInt(tissueIDNumberKey);
  }
}

class SpecimenPartServices extends AppServices {
  const SpecimenPartServices({required super.ref});

  Future<void> createSpecimenPart(SpecimenPartCompanion form) async {
    await SpecimenPartQuery(dbAccess).createSpecimenPart(form);
    ref.invalidate(partBySpecimenProvider);
    ref.invalidate(specimenPartEntryProvider);
  }

  Future<List<SpecimenPartData>> getSpecimenParts(String specimenUuid) {
    return SpecimenPartQuery(dbAccess).getSpecimenParts(specimenUuid);
  }

  Future<List<SpecimenPartProjectRecord>> getProjectSpecimenParts() {
    return SpecimenPartQuery(
      dbAccess,
    ).getSpecimenPartsForProject(currentProjectUuid);
  }

  Future<void> updateSpecimenPart(
    int partId,
    SpecimenPartCompanion form,
  ) async {
    await SpecimenPartQuery(dbAccess).updateSpecimenPart(partId, form);
    ref.invalidate(partBySpecimenProvider);
    ref.invalidate(specimenPartEntryProvider);
  }
}

const String collectorFieldKey = 'isCollectorFieldAlwaysShown';
const String batFieldsKey = 'isBatFieldsAlwaysShown';

class SpecimenSettingServices {
  SpecimenSettingServices({required this.ref});

  final WidgetRef ref;

  SharedPreferences get _prefs => ref.read(settingProvider);

  Future<void> setSpecimenSettingField(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getSpecimenSettingField(String key) {
    return _prefs.getBool(key) ?? false;
  }
}

class AssociatedDataServices extends AppServices {
  const AssociatedDataServices({required super.ref});

  Future<List<AssociatedDataData>> getAssociatedData(
    String specimenUuid,
  ) async {
    return await AssociatedDataQuery(
      dbAccess,
    ).getAllAssociatedData(specimenUuid);
  }

  Future<List<AssociatedDataData>> getAssociatedDataForSite(int siteId) {
    return AssociatedDataQuery(dbAccess).getAssociatedDataForSite(siteId);
  }

  Future<List<AssociatedDataData>> getProjectAssociatedData() {
    return AssociatedDataQuery(
      dbAccess,
    ).getAssociatedDataForProject(currentProjectUuid);
  }

  Future<void> createAssociatedData(
    String specimenUuid,
    AssociatedDataCompanion form,
  ) async {
    await AssociatedDataQuery(
      dbAccess,
    ).createSpecimenDataAssociation(specimenUuid, form);
    _invalidateData();
  }

  Future<int> createProjectAssociatedData(AssociatedDataCompanion form) async {
    final id = await AssociatedDataQuery(dbAccess).createProjectAssociatedData(
      form.copyWith(projectUuid: db.Value(currentProjectUuid)),
    );
    _invalidateData();
    return id;
  }

  Future<void> linkToSpecimen(int id, String specimenUuid) async {
    await AssociatedDataQuery(dbAccess).linkToSpecimen(id, specimenUuid);
    _invalidateData();
  }

  Future<void> linkToSite(int id, int siteId) async {
    await AssociatedDataQuery(dbAccess).linkToSite(id, siteId);
    _invalidateData();
  }

  Future<void> unlinkFromSpecimen(int id, String specimenUuid) async {
    await AssociatedDataQuery(dbAccess).unlinkFromSpecimen(id, specimenUuid);
    _invalidateData();
  }

  Future<void> unlinkFromSite(int id, int siteId) async {
    await AssociatedDataQuery(dbAccess).unlinkFromSite(id, siteId);
    _invalidateData();
  }

  Future<void> updateAssociatedData(
    int associatedDataId,
    AssociatedDataCompanion form,
  ) async {
    await AssociatedDataQuery(
      dbAccess,
    ).updateAssociatedData(associatedDataId, form);
    _invalidateData();
  }

  Future<bool> isFileUsed(File file) async {
    return await AssociatedDataQuery(dbAccess).isFileUsed(basename(file.path));
  }

  Future<void> deleteAssociatedData(int associatedDataId) async {
    final query = AssociatedDataQuery(dbAccess);
    final data = await query.getAssociatedDataById(associatedDataId);
    await query.deleteAssociatedData(associatedDataId);
    if (data?.type == 'File' &&
        data?.projectUuid != null &&
        data?.uri?.isNotEmpty == true &&
        !await query.isFileUsed(data!.uri!)) {
      final projectDir = await FileServices(
        ref: ref,
      ).getProjectDirByUUID(data.projectUuid!);
      final file = File(join(projectDir.path, 'associatedData', data.uri));
      if (file.existsSync()) {
        await file.delete();
      }
    }
    _invalidateData();
  }

  Future<File> copyAssociatedDataFile(File path) async {
    final dataDir = Directory('associatedData');

    File dataPath = await FileServices(
      ref: ref,
    ).copyFileToProjectDir(path, dataDir);
    return dataPath;
  }

  void _invalidateData() {
    ref.invalidate(associatedDataProvider);
  }
}

/// Calculates derived values from standard mammal length measurements.
class MammalMeasurementServices {
  const MammalMeasurementServices({
    required this.totalLengthText,
    required this.tailLengthText,
  });

  final String totalLengthText;
  final String tailLengthText;

  ({String headAndBodyText, String percentTailText, String errorText})?
  getHBandTailPercentage() {
    double? totalLength = totalLengthText.isNotEmpty
        ? double.tryParse(totalLengthText)
        : null;
    double? tailLength = tailLengthText.isNotEmpty
        ? double.tryParse(tailLengthText)
        : null;
    if (totalLength == null || tailLength == null || totalLength < 1) {
      return null;
    }

    double? headBodyLength = totalLength - tailLength;
    if (headBodyLength <= 0) {
      return (
        headAndBodyText: '',
        percentTailText: '',
        errorText:
            'Total length should not be less than or equal to tail length.',
      );
    } else {
      String headAndBodyText = headBodyLength.truncateZeroFixed(1);
      String tailHeadBodyPercent = (tailLength / headBodyLength * 100)
          .truncateZeroFixed(1);
      String percentTailText = '$tailHeadBodyPercent%';

      return (
        headAndBodyText: headAndBodyText,
        percentTailText: percentTailText,
        errorText: '',
      );
    }
  }
}
