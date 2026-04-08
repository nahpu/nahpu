import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/utility_services.dart';

part 'specimen_queries.g.dart';

@DriftAccessor(
  include: {'tables.drift'},
)
class SpecimenQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  SpecimenQuery(super.db);

  // Specimen General table
  Future<int> createSpecimen(SpecimenCompanion form) =>
      into(specimen).insert(form);

  Future<List<SpecimenData>> getAllSpecimens(String projectUuid) {
    return (select(specimen)..where((t) => t.projectUuid.equals(projectUuid)))
        .get();
  }

  Future<List<SpecimenData>> getSpecimenPerEvent(int eventID) {
    return (select(specimen)..where((t) => t.collEventID.equals(eventID)))
        .get();
  }

  Future<List<String>> getColumnNames() async {
    List<String> columnNames =
        db.specimen.$columns.map((e) => e.$name).toList();
    return columnNames;
  }

  Future<List<String>> getAllSpecimenUuids(String projectUuid) {
    return (select(specimen, distinct: true)
          ..where((t) => t.projectUuid.equals(projectUuid)))
        .map((e) => e.uuid)
        .get();
  }

  Future<SpecimenData> getSpecimenByUuid(String uuid) async {
    return await (select(specimen)..where((t) => t.uuid.equals(uuid)))
        .getSingle();
  }

  Future<List<String>> getUniqueTaxonGroup(String projectUuid) async {
    final specimenData = await (select(specimen, distinct: true)
          ..where((t) => t.projectUuid.equals(projectUuid))
          ..where((tbl) => tbl.taxonGroup.isNotNull()))
        .get();
    return getDistinctList(specimenData.map((e) => e.taxonGroup).toList());
  }

  Future<List<SpecimenData>> getAllAvianSpecimens(String projectUuid) {
    return (select(specimen)
          ..where((t) => t.projectUuid.equals(projectUuid))
          ..where((t) => t.taxonGroup.equals('Avians')))
        .get();
  }

  Future<List<SpecimenData>> getAllMammalSpecimens(String projectUuid) {
    return (select(specimen)
          ..where((t) => t.projectUuid.equals(projectUuid))
          ..where((t) => t.taxonGroup.equals('Non-Bat Mammals')))
        .get();
  }

  Future<List<SpecimenData>> getAllBatSpecimens(String projectUuid) {
    return (select(specimen)
          ..where((t) => t.projectUuid.equals(projectUuid))
          ..where((t) => t.taxonGroup.equals('Bats')))
        .get();
  }

  Future<List<int?>> getAllSpecies(String uuid) {
    return (select(specimen)..where((t) => t.projectUuid.equals(uuid)))
        .map((e) => e.speciesID)
        .get();
  }

  Future<int?> getSpeciesByUuid(String uuid) async {
    SpecimenData? specimenData =
        await (select(specimen)..where((t) => t.uuid.equals(uuid))).getSingle();

    return specimenData.speciesID;
  }

  Future<SpecimenData?> getLastCatFieldNumber(
      String projectUuid, String specimenUuid, String catalogerUuid) async {
    try {
      return await (select(specimen)
            ..where((t) => t.projectUuid.equals(projectUuid))
            ..where((t) => t.uuid.equals(specimenUuid))
            ..where((t) => t.catalogerID.equals(catalogerUuid))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.fieldNumber, mode: OrderingMode.desc)
            ])
            ..limit(1))
          .getSingle();
    } catch (e) {
      return null;
    }
  }

  Future<void> createSpecimenMedia(
      SpecimenMediaCompanion specimenMediaCompanion) {
    return into(specimenMedia).insert(specimenMediaCompanion);
  }

  Future<List<SpecimenMediaData>> getSpecimenMedia(String specimenUuid) async {
    return await (select(specimenMedia)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .get();
  }

  Future<SpecimenMediaData> getSpecimenMediaByMediaId(int mediaId) async {
    return await (select(specimenMedia)
          ..where((t) => t.mediaId.equals(mediaId))
          ..limit(1))
        .getSingle();
  }

  Future<void> deleteSpecimenMedia(int mediaId) {
    return (delete(specimenMedia)..where((t) => t.mediaId.equals(mediaId)))
        .go();
  }

  Future<void> deleteAllSpecimenMedias(String specimenUuid) {
    return (delete(specimenMedia)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .go();
  }

  Future<void> updateSpecimenMedia(
      String specimenUuid, SpecimenMediaCompanion specimenMediaCompanion) {
    return (update(specimenMedia)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .write(specimenMediaCompanion);
  }

  Future<void> deleteSpecimen(String uuid) {
    return (delete(specimen)..where((t) => t.uuid.equals(uuid))).go();
  }

  Future<void> deleteAllSpecimens(String projectUuid) {
    return (delete(specimen)..where((t) => t.projectUuid.equals(projectUuid)))
        .go();
  }

  Future<int> updateSpecimenEntry(String uuid, SpecimenCompanion entry) async {
    return await (update(specimen)..where((t) => t.uuid.equals(uuid)))
        .write(entry);
  }
}

class MammalSpecimenQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  MammalSpecimenQuery(super.db);

  Future<int> createMammalMeasurements(MammalMeasurementCompanion form) =>
      into(mammalMeasurement).insert(form);

  Future updateMammalMeasurements(
      String specimenUuid, MammalMeasurementCompanion form) {
    return (update(mammalMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .write(form);
  }

  Future<MammalMeasurementData> getMammalMeasurementByUuid(
      String specimenUuid) async {
    return await (select(mammalMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .getSingle();
  }

  Future<void> deleteMammalMeasurements(String specimenUuid) {
    return (delete(mammalMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .go();
  }
}

class AvianSpecimenQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  AvianSpecimenQuery(super.db);

  Future<int> createAvianMeasurements(AvianMeasurementCompanion form) =>
      into(avianMeasurement).insert(form);

  Future updateAvianMeasurements(
      String specimenUuid, AvianMeasurementCompanion entry) {
    return (update(avianMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .write(entry);
  }

  Future<AvianMeasurementData> getAvianMeasurementByUuid(
      String specimenUuid) async {
    return await (select(avianMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .getSingle();
  }

  Future<void> deleteAvianMeasurements(String specimenUuid) {
    return (delete(avianMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .go();
  }
}

class HerpSpecimenQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  HerpSpecimenQuery(super.db);

  Future<int> createHerpMeasurements(HerpMeasurementCompanion form) =>
      into(herpMeasurement).insert(form);

  Future updateHerpMeasurements(
      String specimenUuid, HerpMeasurementCompanion entry) {
    return (update(herpMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .write(entry);
  }

  Future<HerpMeasurementData> getHerpMeasurementByUuid(
      String specimenUuid) async {
    return await (select(herpMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .getSingle();
  }

  Future<void> deleteHerpMeasurements(String specimenUuid) {
    return (delete(herpMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .go();
  }
}

class SpecimenPartQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  SpecimenPartQuery(super.db);

  Future<int> createSpecimenPart(SpecimenPartCompanion form) =>
      into(specimenPart).insert(form);

  Future<List<String>> searchPrepType(String query) async {
    List<SpecimenPartData> data = await (select(specimenPart)
          ..where((t) => t.type.like('%$query%')))
        .get();

    // Get specimen uuid only
    List<String> prepType = data
        .where((element) => element.specimenUuid != null)
        .map((e) => e.specimenUuid!)
        .toList();
    return prepType;
  }

  Future<List<SpecimenPartData>> getSpecimenParts(String specimenUuid) {
    return (select(specimenPart)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .get();
  }

  Future<String?> getLastEnteredTissueID(String uuid) async {
    SpecimenPartData data = await (select(specimenPart)
          ..where((t) => t.specimenUuid.equals(uuid))
          ..orderBy([
            (t) => OrderingTerm(expression: t.tissueID, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingle();
    return data.tissueID;
  }

  Future<List<String>> getDistinctTypes() async {
    List<SpecimenPartData> data = await (select(specimenPart)).get();
    List<String> types = getDistinctList(data.map((e) => e.type).toList());
    List<String> sortedTypes = _sortType(types);
    return sortedTypes;
  }

  Future<List<String>> getDistinctTreatments() async {
    List<SpecimenPartData> data = await (select(specimenPart)).get();
    List<String> treatments =
        getDistinctList(data.map((e) => e.treatment).toList());
    List<String> sortedTreatments = _sortTreatment(treatments);
    return sortedTreatments;
  }

  // Sort by priority
  List<String> _sortTreatment(List<String> treatmentList) {
    List<String> mainTreatment = [];
    List<String> subTreatment = [];
    for (var treatment in treatmentList) {
      if (priorityTreatment.contains(treatment)) {
        mainTreatment = [...mainTreatment, treatment];
      } else {
        subTreatment = [...subTreatment, treatment];
      }
    }
    subTreatment.sort();
    return [...mainTreatment, ...subTreatment];
  }

  // Sort by main nature first
  List<String> _sortType(List<String> typeList) {
    List<String> mainType = [];
    List<String> subType = [];
    for (var type in typeList) {
      if (priorityType.contains(type)) {
        mainType = [...mainType, type];
      } else {
        subType = [...subType, type];
      }
    }
    subType.sort();
    return [...mainType, ...subType];
  }

  Future<void> updateSpecimenPart(int id, SpecimenPartCompanion entry) {
    return (update(specimenPart)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> deleteSpecimenPart(int partId) {
    return (delete(specimenPart)..where((t) => t.id.equals(partId))).go();
  }

  Future<void> deleteSpecimenPartsFromList(List<int> partIds) {
    return (delete(specimenPart)..where((t) => t.id.isIn(partIds))).go();
  }

  Future<void> deleteAllSpecimenParts(String specimenUuid) {
    return (delete(specimenPart)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .go();
  }

  Future updateSpecimenPartEntry(String uuid, SpecimenPartCompanion entry) {
    return (update(specimenPart)..where((t) => t.specimenUuid.equals(uuid)))
        .write(entry);
  }
}

class SpecimenPartDistinctTypes {
  SpecimenPartDistinctTypes({required this.type, required this.treatment});

  final List<String> type;
  final List<String> treatment;
}

class AssociatedDataQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  AssociatedDataQuery(super.db);

  Future<int> createSpecimenDataAssociation(
          AssociatedDataCompanion form) async =>
      await into(associatedData).insert(form);

  Future<int> updateAssociatedData(int id, AssociatedDataCompanion form) async {
    return (update(associatedData)..where((t) => t.primaryId.equals(id)))
        .write(form);
  }

  Future<List<AssociatedDataData>> getAllAssociatedData(
      String specimenUuid) async {
    return await (select(associatedData)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .get();
  }

  Future<bool> isFileUsed(String baseName) async {
    AssociatedDataData? data = await (select(associatedData)
          ..where((t) => t.url.equals(baseName))
          ..limit(1))
        .getSingleOrNull();
    return data != null;
  }

  Future<void> deleteAssociatedData(int id) {
    return (delete(associatedData)..where((t) => t.primaryId.equals(id))).go();
  }

  Future<void> deleteAllAssociatedData(String specimenUuid) {
    return (delete(associatedData)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .go();
  }
}
