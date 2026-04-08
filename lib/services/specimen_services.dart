import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String tissueIDPrefixKey = 'tissueIDPrefix';
const String tissueIDNumberKey = 'tissueIDNumber';
const String projectFieldIDNumberKey = 'projectFieldIdNumber';

class SpecimenServices extends AppServices {
  const SpecimenServices({required super.ref});

  Future<String> createSpecimen() async {
    final CatalogFmt catalogFmt =
        await ref.watch(catalogFmtNotifierProvider.future);
    final String specimenUuid = uuid;
    final FieldIdMode fieldIdMode =
        await ref.watch(fieldIdModeNotifierProvider.future);
    String? currentProjectNumber;

    if (fieldIdMode == FieldIdMode.project) {
      currentProjectNumber =
          await ProjectFieldIdServices(ref: ref).getNewNumber();
    }

    await SpecimenQuery(dbAccess).createSpecimen(SpecimenCompanion(
      uuid: db.Value(specimenUuid),
      projectUuid: db.Value(currentProjectUuid),
      taxonGroup: db.Value(matchCatFmtToTaxonGroup(catalogFmt)),
      projectFieldNumber: db.Value(int.tryParse(currentProjectNumber ?? '')),
    ));

    switch (catalogFmt) {
      case CatalogFmt.birds:
        _createBirdSpecimen(specimenUuid);
        break;
      case CatalogFmt.mammals:
        _createMammalSpecimen(specimenUuid);
        break;
      case CatalogFmt.herpetofauna:
        _createHerpSpecimen(specimenUuid);
        break;
    }
    invalidateSpecimenList();

    return specimenUuid;
  }

  String getIconPath() {
    return ref.watch(catalogFmtNotifierProvider).when(
          data: (fmt) {
            return matchCatalogFmtToIconPath(fmt);
          },
          loading: () => 'assets/icons/mouse.svg',
          error: (error, stack) => 'assets/icons/mouse.svg',
        );
  }

  Future<void> createSpecimenDuplicatePart(String specimenUuid) async {
    List<SpecimenPartData> partData =
        await SpecimenPartQuery(dbAccess).getSpecimenParts(specimenUuid);
    if (partData.isEmpty) {
      return;
    }
    String newSpecimenUuid = await createSpecimen();

    for (var part in partData) {
      SpecimenPartServices(ref: ref).createSpecimenPart(SpecimenPartCompanion(
        specimenUuid: db.Value(newSpecimenUuid),
        type: db.Value(part.type),
        count: db.Value(part.count),
        treatment: db.Value(part.treatment),
        additionalTreatment: db.Value(part.additionalTreatment),
        museumPermanent: db.Value(part.museumPermanent),
        museumLoan: db.Value(part.museumLoan),
      ));
    }

    ref.invalidate(partBySpecimenProvider);
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

  Future<void> createSpecimenMedia(
    String specimenUuid,
    String filePath,
  ) async {
    ExifData exifData = ExifData.empty();
    await exifData.readExif(File(filePath));
    int mediaId = await MediaDbQuery(dbAccess).createMedia(MediaCompanion(
      projectUuid: db.Value(currentProjectUuid),
      fileName: db.Value(basename(filePath)),
      category: db.Value(matchMediaCategory(MediaCategory.specimen)),
      taken: db.Value(exifData.dateTaken),
      camera: db.Value(exifData.camera),
      lenses: db.Value(exifData.lenseModel),
      additionalExif: db.Value(exifData.additionalExif),
    ));
    SpecimenMediaCompanion entries = SpecimenMediaCompanion(
      specimenUuid: db.Value(specimenUuid),
      mediaId: db.Value(mediaId),
    );
    await SpecimenQuery(dbAccess).createSpecimenMedia(entries);
    ref.invalidate(specimenMediaProvider);
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
    List<int> eventID =
        await CollEventServices(ref: ref).getEventPerSite(siteID);
    List<SpecimenData> allSpecimens = [];
    for (var id in eventID) {
      List<SpecimenData> specimenList =
          await SpecimenQuery(dbAccess).getSpecimenPerEvent(id);
      allSpecimens.addAll(specimenList);
    }
    return allSpecimens;
  }

  Future<List<SpecimenData>> getSpecimenListByTaxonGroup(
      String taxonGroup) async {
    List<SpecimenData> specimenList = await getSpecimenList();
    List<SpecimenData> filteredList = specimenList
        .where((element) => element.taxonGroup == taxonGroup)
        .toList();
    return filteredList;
  }

  Future<List<SpecimenData>> getSpecimenListForAllMammals() async {
    List<SpecimenData> specimenList = await getSpecimenList();
    List<SpecimenData> filteredList = specimenList
        .where((element) =>
            element.taxonGroup == 'General Mammals' ||
            element.taxonGroup == 'Bats')
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

  Future<int> getSpecimenFieldNumber(
    String personnelUuid,
  ) async {
    int? fieldNumber = await PersonnelQuery(dbAccess)
        .getCurrentFieldNumberByUuid(personnelUuid);
    return _getCurrentFieldNumber(fieldNumber);
  }

  int _getCurrentFieldNumber(int? currentFieldNum) {
    if (currentFieldNum == null) {
      return 0;
    } else {
      return currentFieldNum;
    }
  }

  void _createMammalSpecimen(String specimenUuid) {
    MammalSpecimenQuery(dbAccess).createMammalMeasurements(
        MammalMeasurementCompanion(specimenUuid: db.Value(specimenUuid)));
  }

  Future<MammalMeasurementData> getMammalMeasurementData(String specimenUuid) {
    return MammalSpecimenQuery(dbAccess)
        .getMammalMeasurementByUuid(specimenUuid);
  }

  void updateMammalMeasurement(
      String specimenUuid, MammalMeasurementCompanion entries) {
    MammalSpecimenQuery(dbAccess)
        .updateMammalMeasurements(specimenUuid, entries);
  }

  void _createHerpSpecimen(String specimenUuid) {
    HerpSpecimenQuery(dbAccess).createHerpMeasurements(
        HerpMeasurementCompanion(specimenUuid: db.Value(specimenUuid)));
  }

  Future<HerpMeasurementData> getHerpMeasurementData(String specimenUuid) {
    return HerpSpecimenQuery(dbAccess).getHerpMeasurementByUuid(specimenUuid);
  }

  void updateHerpMeasurement(
      String specimenUuid, HerpMeasurementCompanion entries) {
    HerpSpecimenQuery(dbAccess).updateHerpMeasurements(specimenUuid, entries);
  }

  void _createBirdSpecimen(String specimenUuid) {
    AvianSpecimenQuery(dbAccess).createAvianMeasurements(
        AvianMeasurementCompanion(specimenUuid: db.Value(specimenUuid)));
  }

  Future<void> updateSpecimenSkipInvalidation(
      String uuid, SpecimenCompanion entries) async {
    await _updateSpecimen(uuid, entries);
  }

  Future<void> updateSpecimen(String uuid, SpecimenCompanion entries) async {
    _updateSpecimen(uuid, entries);
    invalidateSpecimenList();
  }

  Future<void> _updateSpecimen(String uuid, SpecimenCompanion entries) async {
    try {
      await SpecimenQuery(dbAccess).updateSpecimenEntry(uuid, entries);
    } catch (_) {
      rethrow;
    }
  }

  Future<AvianMeasurementData> getAvianMeasurementData(String specimenUuid) {
    return AvianSpecimenQuery(dbAccess).getAvianMeasurementByUuid(specimenUuid);
  }

  Future<List<SpecimenMediaData>> getSpecimenMedia(String specimenUuid) async {
    return await SpecimenQuery(dbAccess).getSpecimenMedia(specimenUuid);
  }

  void updateAvianMeasurement(
      String specimenUuid, AvianMeasurementCompanion entries) {
    AvianSpecimenQuery(dbAccess).updateAvianMeasurements(specimenUuid, entries);
  }

  Future<void> deleteAvianMeasurements(String specimenUuid) async {
    await AvianSpecimenQuery(dbAccess).deleteAvianMeasurements(specimenUuid);
  }

  Future<void> deleteMammalMeasurements(String specimenUuid) async {
    await MammalSpecimenQuery(dbAccess).deleteMammalMeasurements(specimenUuid);
  }

  Future<void> deleteHerpMeasurements(String specimenUuid) async {
    await HerpSpecimenQuery(dbAccess).deleteHerpMeasurements(specimenUuid);
  }

  Future<void> deleteSpecimen(
      String specimenUuid, CatalogFmt catalogFmt) async {
    await deleteAllSpecimenParts(specimenUuid);
    switch (catalogFmt) {
      case CatalogFmt.birds:
        await deleteAvianMeasurements(specimenUuid);
        break;
      case CatalogFmt.mammals:
        await deleteMammalMeasurements(specimenUuid);
        break;
      case CatalogFmt.herpetofauna:
        await deleteHerpMeasurements(specimenUuid);
        break;
    }
    await SpecimenQuery(dbAccess).deleteAllSpecimenMedias(specimenUuid);
    await SpecimenQuery(dbAccess).deleteSpecimen(specimenUuid);
    invalidateSpecimenList();
  }

  Future<void> deleteAllSpecimens() async {
    List<SpecimenData> specimenList = await getSpecimenList();
    for (var specimen in specimenList) {
      await deleteAllSpecimenParts(specimen.uuid);
      await SpecimenQuery(dbAccess).deleteAllSpecimenMedias(specimen.uuid);
      CatalogFmt catalogFmt = matchTaxonGroupToCatFmt(specimen.taxonGroup);
      switch (catalogFmt) {
        case CatalogFmt.birds:
          await deleteAvianMeasurements(specimen.uuid);
          break;
        case CatalogFmt.mammals:
          await deleteMammalMeasurements(specimen.uuid);
          break;
        case CatalogFmt.herpetofauna:
          await deleteHerpMeasurements(specimen.uuid);
          break;
      }
    }
    await SpecimenQuery(dbAccess).deleteAllSpecimens(currentProjectUuid);
    invalidateSpecimenList();
  }

  Future<void> deleteAllSpecimenParts(String specimenUuid) async {
    await SpecimenPartQuery(dbAccess).deleteAllSpecimenParts(specimenUuid);
  }

  Future<void> deleteSpecimenPart(int partId) async {
    await SpecimenPartQuery(dbAccess).deleteSpecimenPart(partId);
    ref.invalidate(partBySpecimenProvider);
  }

  Future<void> deleteSpecimenPartsFromList(List<int> partIds) async {
    await SpecimenPartQuery(dbAccess).deleteSpecimenPartsFromList(partIds);
    ref.invalidate(partBySpecimenProvider);
  }

  void invalidateSpecimenList() {
    ref.invalidate(specimenEntryProvider);
    ref.invalidate(taxonDataProvider);
    ref.invalidate(projectPersonnelProvider);
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
            .where((element) => _isMatchFieldNum(
                  element.fieldNumber,
                  query,
                ))
            .toList();
      case SpecimenSearchOption.cataloger:
        List<String> matchedPersons = await _searchPersonnel(query);
        return specimenEntries
            .where((element) => _isMatchedPerson(
                  matchedPersons,
                  element.catalogerID,
                ))
            .toList();
      case SpecimenSearchOption.preparator:
        List<String> matchedPersons = await _searchPersonnel(query);
        return specimenEntries
            .where((element) => _isMatchedPerson(
                  matchedPersons,
                  element.preparatorID,
                ))
            .toList();
      case SpecimenSearchOption.collector:
        List<String> matchedPersons = await _searchPersonnel(query);
        List<int> matchedColPersons =
            await _searchColPersonnel(matchedPersons, query);
        return specimenEntries
            .where((element) => _isMatchedColPerson(
                  matchedColPersons,
                  element.collPersonnelID,
                ))
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
            .where((element) => _isMatchTaxa(
                  matchedTaxa,
                  element.speciesID,
                ))
            .toList();
      case SpecimenSearchOption.prepType:
        List<String> matchedPrepType = await _searchPrepType(query);
        return specimenEntries
            .where((element) => _isMatchPrepType(
                  matchedPrepType,
                  element.uuid,
                ))
            .toList();
    }
  }

  Future<List<SpecimenData>> searchAll(String query) async {
    List<String> matchedPersons = await _searchPersonnel(query);
    List<int> matchedColPersons =
        await _searchColPersonnel(matchedPersons, query);
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
      List<String> matchedPersons, String query) async {
    if (matchedPersons.isEmpty) {
      return [];
    }
    final person = await CollPersonnelQuery(db)
        .searchCollectingPersonnel(matchedPersons, query);
    return person.map((e) => e.id).toList();
  }
}

class ProjectFieldIdServices extends AppServices {
  const ProjectFieldIdServices({required super.ref});

  SharedPreferences get _prefs => ref.read(settingProvider);

  Future<String> getNewNumber() async {
    int? number = _getSettingNumber();
    String numberString = getNumberString();
    await incrementNumber(number ?? 0);
    return numberString;
  }

  String getNumberString() {
    return _getSettingNumber() == null ? '1' : _getSettingNumber().toString();
  }

  Future<void> incrementNumber(int number) async {
    await setNumber((number + 1).toString());
  }

  Future<void> setNumber(String number) async {
    await _prefs.setInt(projectFieldIDNumberKey, int.tryParse(number) ?? 1);
  }

  int? _getSettingNumber() {
    return _prefs.getInt(projectFieldIDNumberKey);
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
    SpecimenPartQuery(dbAccess).createSpecimenPart(form);
    ref.invalidate(partBySpecimenProvider);
  }

  Future<List<SpecimenPartData>> getSpecimenParts(String specimenUuid) {
    return SpecimenPartQuery(dbAccess).getSpecimenParts(specimenUuid);
  }

  Future<void> updateSpecimenPart(
      int partId, SpecimenPartCompanion form) async {
    SpecimenPartQuery(dbAccess).updateSpecimenPart(partId, form);
    ref.invalidate(partBySpecimenProvider);
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
      String specimenUuid) async {
    return await AssociatedDataQuery(dbAccess)
        .getAllAssociatedData(specimenUuid);
  }

  Future<void> createAssociatedData(AssociatedDataCompanion form) async {
    await AssociatedDataQuery(dbAccess).createSpecimenDataAssociation(form);
    _invalidateData();
  }

  Future<void> updateAssociatedData(
      int associatedDataId, AssociatedDataCompanion form) async {
    await AssociatedDataQuery(dbAccess)
        .updateAssociatedData(associatedDataId, form);
    _invalidateData();
  }

  Future<bool> isFileUsed(File file) async {
    return await AssociatedDataQuery(dbAccess).isFileUsed(
      basename(file.path),
    );
  }

  Future<void> deleteAssociatedData(int associatedDataId) async {
    await AssociatedDataQuery(dbAccess).deleteAssociatedData(associatedDataId);
    _invalidateData();
  }

  Future<File> copyAssociatedDataFile(File path) async {
    final dataDir = Directory('associatedData');

    File dataPath =
        await FileServices(ref: ref).copyFileToProjectDir(path, dataDir);
    return dataPath;
  }

  void _invalidateData() {
    ref.invalidate(associatedDataProvider);
  }
}

class MammalMeasurementServices {
  const MammalMeasurementServices({
    required this.totalLengthText,
    required this.tailLengthText,
  });

  final String totalLengthText;
  final String tailLengthText;

  ({String headAndBodyText, String percentTailText, String errorText})?
      getHBandTailPercentage() {
    double? totalLength =
        totalLengthText.isNotEmpty ? double.tryParse(totalLengthText) : null;
    double? tailLength =
        tailLengthText.isNotEmpty ? double.tryParse(tailLengthText) : null;
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
      String tailHeadBodyPercent =
          (tailLength / headBodyLength * 100).truncateZeroFixed(1);
      String percentTailText = '$tailHeadBodyPercent%';

      return (
        headAndBodyText: headAndBodyText,
        percentTailText: percentTailText,
        errorText: '',
      );
    }
  }
}
