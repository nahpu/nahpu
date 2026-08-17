import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:nahpu/services/common/utility_services.dart';

part 'specimen_queries.g.dart';

@DriftAccessor(include: {'tables.drift'})
class SpecimenQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  SpecimenQuery(super.db);

  // Specimen General table
  Future<int> createSpecimen(SpecimenCompanion form) =>
      into(specimen).insert(form);

  /// Returns specimens oldest-first so new records are the final form page.
  Future<List<SpecimenData>> getAllSpecimens(String projectUuid) {
    return (select(specimen)
          ..where((t) => t.projectUuid.equals(projectUuid))
          ..orderBy([(row) => OrderingTerm.asc(row.rowId)]))
        .get();
  }

  Future<List<SpecimenData>> searchSpecimens(
    SpecimenSearchCriteria criteria, {
    required int limit,
    required int offset,
  }) async {
    final cataloger = alias(personnel, 'cataloger');
    final preparator = alias(personnel, 'preparator');
    final query =
        select(specimen).join([
            leftOuterJoin(
              cataloger,
              specimen.catalogerID.equalsExp(cataloger.uuid),
            ),
            leftOuterJoin(
              preparator,
              specimen.preparatorID.equalsExp(preparator.uuid),
            ),
            leftOuterJoin(taxonomy, specimen.speciesID.equalsExp(taxonomy.id)),
          ])
          ..where(_searchPredicate(criteria, cataloger, preparator))
          ..orderBy([OrderingTerm.asc(specimen.fieldNumber)])
          ..limit(limit, offset: offset);

    final rows = await query.get();
    return rows.map((row) => row.readTable(specimen)).toList(growable: false);
  }

  Future<int> countSpecimens(SpecimenSearchCriteria criteria) async {
    final cataloger = alias(personnel, 'cataloger');
    final preparator = alias(personnel, 'preparator');
    final count = specimen.uuid.count();
    final query =
        selectOnly(specimen).join([
            leftOuterJoin(
              cataloger,
              specimen.catalogerID.equalsExp(cataloger.uuid),
            ),
            leftOuterJoin(
              preparator,
              specimen.preparatorID.equalsExp(preparator.uuid),
            ),
            leftOuterJoin(taxonomy, specimen.speciesID.equalsExp(taxonomy.id)),
          ])
          ..addColumns([count])
          ..where(_searchPredicate(criteria, cataloger, preparator));

    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<List<SpecimenData>> getSpecimenPerEvent(int eventID) {
    return (select(
      specimen,
    )..where((t) => t.collEventID.equals(eventID))).get();
  }

  Future<List<String>> getColumnNames() async {
    List<String> columnNames = db.specimen.$columns
        .map((e) => e.$name)
        .toList();
    return columnNames;
  }

  Future<List<String>> getAllSpecimenUuids(String projectUuid) {
    return (select(specimen, distinct: true)
          ..where((t) => t.projectUuid.equals(projectUuid)))
        .map((e) => e.uuid)
        .get();
  }

  Future<SpecimenData> getSpecimenByUuid(String uuid) async {
    return await (select(
      specimen,
    )..where((t) => t.uuid.equals(uuid))).getSingle();
  }

  Future<List<String>> getUniqueTaxonGroup(String projectUuid) async {
    final specimenData =
        await (select(specimen, distinct: true)
              ..where((t) => t.projectUuid.equals(projectUuid))
              ..where((tbl) => tbl.taxonGroup.isNotNull()))
            .get();
    return getDistinctList(specimenData.map((e) => e.taxonGroup).toList());
  }

  Future<List<String>> getDistinctConditions() async {
    final query = selectOnly(specimen)
      ..addColumns([specimen.condition])
      ..where(specimen.condition.isNotNull())
      ..groupBy([specimen.condition]);
    final result = await query.get();
    return result
        .map((row) => row.read(specimen.condition)!)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<String>> getDistinctIdMethods() async {
    final query = selectOnly(specimen, distinct: true)
      ..addColumns([specimen.iDMethod])
      ..where(specimen.iDMethod.isNotNull());
    return (await query.get())
        .map((row) => row.read(specimen.iDMethod))
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<List<String>> getDistinctLifeStages() async {
    final values = await Future.wait([
      (selectOnly(mammalAttribute, distinct: true)
            ..addColumns([mammalAttribute.lifeStage])
            ..where(mammalAttribute.lifeStage.isNotNull()))
          .map((row) => row.read(mammalAttribute.lifeStage))
          .get(),
      (selectOnly(birdAttribute, distinct: true)
            ..addColumns([birdAttribute.lifeStage])
            ..where(birdAttribute.lifeStage.isNotNull()))
          .map((row) => row.read(birdAttribute.lifeStage))
          .get(),
      (selectOnly(herpAttribute, distinct: true)
            ..addColumns([herpAttribute.lifeStage])
            ..where(herpAttribute.lifeStage.isNotNull()))
          .map((row) => row.read(herpAttribute.lifeStage))
          .get(),
      (selectOnly(arthropodAttribute, distinct: true)
            ..addColumns([arthropodAttribute.lifeStage])
            ..where(arthropodAttribute.lifeStage.isNotNull()))
          .map((row) => row.read(arthropodAttribute.lifeStage))
          .get(),
    ]);
    return values
        .expand((entries) => entries)
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  Future<Set<int>> getDistinctSexCodes() async {
    final codes = <int>{};
    final mammalQuery = selectOnly(mammalAttribute, distinct: true)
      ..addColumns([mammalAttribute.sex])
      ..where(mammalAttribute.sex.isNotNull());
    final birdQuery = selectOnly(birdAttribute, distinct: true)
      ..addColumns([birdAttribute.sex])
      ..where(birdAttribute.sex.isNotNull());
    final herpQuery = selectOnly(herpAttribute, distinct: true)
      ..addColumns([herpAttribute.sex])
      ..where(herpAttribute.sex.isNotNull());
    final arthropodQuery = selectOnly(arthropodAttribute, distinct: true)
      ..addColumns([arthropodAttribute.sex])
      ..where(arthropodAttribute.sex.isNotNull());

    final results = await Future.wait([
      mammalQuery.map((row) => row.read(mammalAttribute.sex)).get(),
      birdQuery.map((row) => row.read(birdAttribute.sex)).get(),
      herpQuery.map((row) => row.read(herpAttribute.sex)).get(),
      arthropodQuery.map((row) => row.read(arthropodAttribute.sex)).get(),
    ]);
    codes.addAll(results.expand((values) => values).whereType<int>());
    return codes;
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
    return (select(
      specimen,
    )..where((t) => t.projectUuid.equals(uuid))).map((e) => e.speciesID).get();
  }

  Future<int?> getSpeciesByUuid(String uuid) async {
    SpecimenData? specimenData = await (select(
      specimen,
    )..where((t) => t.uuid.equals(uuid))).getSingle();

    return specimenData.speciesID;
  }

  Future<SpecimenData?> getLastCatFieldNumber(
    String projectUuid,
    String specimenUuid,
    String catalogerUuid,
  ) async {
    try {
      return await (select(specimen)
            ..where((t) => t.projectUuid.equals(projectUuid))
            ..where((t) => t.uuid.equals(specimenUuid))
            ..where((t) => t.catalogerID.equals(catalogerUuid))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.fieldNumber,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingle();
    } catch (e) {
      return null;
    }
  }

  Future<void> createSpecimenMedia(
    SpecimenMediaCompanion specimenMediaCompanion,
  ) {
    return into(specimenMedia).insert(specimenMediaCompanion);
  }

  Future<List<SpecimenMediaData>> getSpecimenMedia(String specimenUuid) async {
    return await (select(
      specimenMedia,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).get();
  }

  Future<SpecimenMediaData> getSpecimenMediaByMediaId(int mediaId) async {
    return await (select(specimenMedia)
          ..where((t) => t.mediaId.equals(mediaId))
          ..limit(1))
        .getSingle();
  }

  Future<void> deleteSpecimenMedia(int mediaId) {
    return (delete(
      specimenMedia,
    )..where((t) => t.mediaId.equals(mediaId))).go();
  }

  Future<void> deleteAllSpecimenMedias(String specimenUuid) {
    return (delete(
      specimenMedia,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).go();
  }

  Future<void> updateSpecimenMedia(
    String specimenUuid,
    SpecimenMediaCompanion specimenMediaCompanion,
  ) {
    return (update(specimenMedia)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .write(specimenMediaCompanion);
  }

  Future<void> deleteSpecimen(String uuid) {
    return (delete(specimen)..where((t) => t.uuid.equals(uuid))).go();
  }

  Future<void> deleteAllSpecimens(String projectUuid) {
    return (delete(
      specimen,
    )..where((t) => t.projectUuid.equals(projectUuid))).go();
  }

  Future<int> updateSpecimenEntry(String uuid, SpecimenCompanion entry) async {
    return await (update(
      specimen,
    )..where((t) => t.uuid.equals(uuid))).write(entry);
  }

  Expression<bool> _searchPredicate(
    SpecimenSearchCriteria criteria,
    Personnel cataloger,
    Personnel preparator,
  ) {
    Expression<bool> predicate = specimen.projectUuid.equals(
      criteria.projectUuid,
    );

    if (criteria.searchQuery.isNotEmpty) {
      final pattern = '%${criteria.searchQuery}%';
      final scientificName =
          taxonomy.genus +
          const Constant<String>(' ') +
          taxonomy.specificEpithet;
      predicate =
          predicate &
          (specimen.fieldNumber.cast<String>().like(pattern) |
              cataloger.name.like(pattern) |
              preparator.name.like(pattern) |
              scientificName.like(pattern));
    }

    if (criteria.hasCollectionDate) {
      predicate =
          predicate &
          specimen.collectionDate.isBiggerOrEqualValue(
            criteria.collectionStartDate,
          ) &
          specimen.collectionDate.isSmallerOrEqualValue(
            criteria.collectionEndDate,
          );
    }

    if (criteria.hasPrepDate) {
      predicate =
          predicate &
          specimen.prepDate.isBiggerOrEqualValue(criteria.prepStartDate) &
          specimen.prepDate.isSmallerOrEqualValue(criteria.prepEndDate);
    }

    return predicate;
  }
}

class SpecimenSearchCriteria {
  const SpecimenSearchCriteria({
    required this.projectUuid,
    this.searchQuery = '',
    this.hasCollectionDate = false,
    this.collectionStartDate = '',
    this.collectionEndDate = '',
    this.hasPrepDate = false,
    this.prepStartDate = '',
    this.prepEndDate = '',
  });

  final String projectUuid;
  final String searchQuery;
  final bool hasCollectionDate;
  final String collectionStartDate;
  final String collectionEndDate;
  final bool hasPrepDate;
  final String prepStartDate;
  final String prepEndDate;
}

class MammalSpecimenQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  MammalSpecimenQuery(super.db);

  Future<int> createMammalAttributes(MammalAttributeCompanion form) =>
      into(mammalAttribute).insert(form);

  Future updateMammalAttributes(
    String specimenUuid,
    MammalAttributeCompanion form,
  ) {
    return (update(
      mammalAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).write(form);
  }

  Future<MammalAttributeData> getMammalAttributeByUuid(
    String specimenUuid,
  ) async {
    return await (select(
      mammalAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).getSingle();
  }

  Future<List<MammalAttributeData>> getMammalAttributesBySpecimenUuids(
    List<String> specimenUuids,
  ) {
    if (specimenUuids.isEmpty) return Future.value([]);

    return (select(
      mammalAttribute,
    )..where((t) => t.specimenUuid.isIn(specimenUuids))).get();
  }

  Future<void> deleteMammalAttributes(String specimenUuid) {
    return (delete(
      mammalAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).go();
  }
}

class BirdSpecimenQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  BirdSpecimenQuery(super.db);

  Future<int> createBirdAttributes(BirdAttributeCompanion form) =>
      into(birdAttribute).insert(form);

  Future updateBirdAttributes(
    String specimenUuid,
    BirdAttributeCompanion entry,
  ) {
    return (update(
      birdAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).write(entry);
  }

  Future<BirdAttributeData> getBirdAttributeByUuid(String specimenUuid) async {
    return await (select(
      birdAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).getSingle();
  }

  Future<void> deleteBirdAttributes(String specimenUuid) {
    return (delete(
      birdAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).go();
  }
}

class HerpSpecimenQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  HerpSpecimenQuery(super.db);

  Future<int> createHerpAttributes(HerpAttributeCompanion form) =>
      into(herpAttribute).insert(form);

  Future updateHerpAttributes(
    String specimenUuid,
    HerpAttributeCompanion entry,
  ) {
    return (update(
      herpAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).write(entry);
  }

  Future<HerpAttributeData> getHerpAttributeByUuid(String specimenUuid) async {
    return await (select(
      herpAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).getSingle();
  }

  Future<void> deleteHerpAttributes(String specimenUuid) {
    return (delete(
      herpAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).go();
  }
}

class ArthropodSpecimenQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  ArthropodSpecimenQuery(super.db);

  Future<int> createArthropodAttributes(ArthropodAttributeCompanion form) =>
      into(arthropodAttribute).insert(form);

  Future<void> updateArthropodAttributes(
    String specimenUuid,
    ArthropodAttributeCompanion entry,
  ) async {
    await (update(
      arthropodAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).write(entry);
  }

  Future<ArthropodAttributeData> getArthropodAttributeByUuid(
    String specimenUuid,
  ) {
    return (select(
      arthropodAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).getSingle();
  }

  Future<void> deleteArthropodAttributes(String specimenUuid) async {
    await (delete(
      arthropodAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).go();
  }
}

class SpecimenPartQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  SpecimenPartQuery(super.db);

  Future<int> createSpecimenPart(SpecimenPartCompanion form) =>
      into(specimenPart).insert(form);

  Future<List<String>> searchPrepType(String query) async {
    List<SpecimenPartData> data = await (select(
      specimenPart,
    )..where((t) => t.type.like('%$query%'))).get();

    // Get specimen uuid only
    List<String> prepType = data
        .where((element) => element.specimenUuid != null)
        .map((e) => e.specimenUuid!)
        .toList();
    return prepType;
  }

  Future<List<SpecimenPartData>> getSpecimenParts(String specimenUuid) {
    return (select(
      specimenPart,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).get();
  }

  /// Returns printable parts in a project together with their parent specimen.
  /// The inner join intentionally excludes orphaned part rows.
  Future<List<SpecimenPartProjectRecord>> getSpecimenPartsForProject(
    String projectUuid,
  ) async {
    final query =
        select(specimenPart).join([
            innerJoin(
              specimen,
              specimen.uuid.equalsExp(specimenPart.specimenUuid),
            ),
          ])
          ..where(specimen.projectUuid.equals(projectUuid))
          ..orderBy([
            OrderingTerm.asc(specimen.fieldNumber),
            OrderingTerm.asc(specimenPart.tissueID),
            OrderingTerm.asc(specimenPart.barcodeID),
            OrderingTerm.asc(specimenPart.id),
          ]);

    final rows = await query.get();
    return rows
        .map(
          (row) => SpecimenPartProjectRecord(
            part: row.readTable(specimenPart),
            specimen: row.readTable(specimen),
          ),
        )
        .toList(growable: false);
  }

  Future<String?> getLastEnteredTissueID(String uuid) async {
    SpecimenPartData data =
        await (select(specimenPart)
              ..where((t) => t.specimenUuid.equals(uuid))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.tissueID,
                  mode: OrderingMode.desc,
                ),
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
    List<String> treatments = getDistinctList(
      data.map((e) => e.treatment).toList(),
    );
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
    return (delete(
      specimenPart,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).go();
  }

  Future updateSpecimenPartEntry(String uuid, SpecimenPartCompanion entry) {
    return (update(
      specimenPart,
    )..where((t) => t.specimenUuid.equals(uuid))).write(entry);
  }
}

class SpecimenPartDistinctTypes {
  SpecimenPartDistinctTypes({required this.type, required this.treatment});

  final List<String> type;
  final List<String> treatment;
}

/// A specimen part paired with the specimen that owns it.
class SpecimenPartProjectRecord {
  const SpecimenPartProjectRecord({required this.part, required this.specimen});

  final SpecimenPartData part;
  final SpecimenData specimen;

  String? get recordId => part.id?.toString();
}

class AssociatedDataQuery extends DatabaseAccessor<Database>
    with _$SpecimenQueryMixin {
  AssociatedDataQuery(super.db);

  Future<int> createSpecimenDataAssociation(
    String specimenUuid,
    AssociatedDataCompanion form,
  ) async {
    final specimenRow = await (select(
      specimen,
    )..where((row) => row.uuid.equals(specimenUuid))).getSingle();
    final projectUuid = specimenRow.projectUuid;
    if (projectUuid == null) {
      throw StateError('Associated data requires a specimen project.');
    }

    return transaction(() async {
      final id = await into(
        associatedData,
      ).insert(form.copyWith(projectUuid: Value(projectUuid)));
      await into(specimenAssociatedData).insert(
        SpecimenAssociatedDataCompanion.insert(
          specimenUuid: specimenUuid,
          associatedDataId: id,
        ),
      );
      return id;
    });
  }

  Future<int> createSiteDataAssociation(
    int siteId,
    AssociatedDataCompanion form,
  ) async {
    final siteRow = await (select(
      site,
    )..where((row) => row.id.equals(siteId))).getSingle();
    final projectUuid = siteRow.projectUuid;
    if (projectUuid == null) {
      throw StateError('Associated data requires a site project.');
    }

    return transaction(() async {
      final id = await into(
        associatedData,
      ).insert(form.copyWith(projectUuid: Value(projectUuid)));
      await into(siteAssociatedData).insert(
        SiteAssociatedDataCompanion.insert(
          siteId: siteId,
          associatedDataId: id,
        ),
      );
      return id;
    });
  }

  Future<int> createEventDataAssociation(
    int eventId,
    AssociatedDataCompanion form,
  ) async {
    final eventRow = await (select(
      collEvent,
    )..where((row) => row.id.equals(eventId))).getSingle();
    final projectUuid = eventRow.projectUuid;
    if (projectUuid == null) {
      throw StateError('Associated data requires an event project.');
    }

    return transaction(() async {
      final id = await into(
        associatedData,
      ).insert(form.copyWith(projectUuid: Value(projectUuid)));
      await into(eventAssociatedData).insert(
        EventAssociatedDataCompanion.insert(
          eventID: eventId,
          associatedDataId: id,
        ),
      );
      return id;
    });
  }

  Future<int> createDataAssociation(
    AssociatedDataTarget target,
    AssociatedDataCompanion form,
  ) => switch (target) {
    SpecimenAssociatedDataTarget(:final specimenUuid) =>
      createSpecimenDataAssociation(specimenUuid, form),
    SiteAssociatedDataTarget(:final siteId) => createSiteDataAssociation(
      siteId,
      form,
    ),
    EventAssociatedDataTarget(:final eventId) => createEventDataAssociation(
      eventId,
      form,
    ),
  };

  Future<int> createProjectAssociatedData(AssociatedDataCompanion form) async {
    if (!form.projectUuid.present || form.projectUuid.value == null) {
      throw ArgumentError('Associated data requires a project.');
    }
    return into(associatedData).insert(form);
  }

  Future<void> linkToSpecimen(int id, String specimenUuid) {
    return into(specimenAssociatedData).insert(
      SpecimenAssociatedDataCompanion.insert(
        specimenUuid: specimenUuid,
        associatedDataId: id,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> linkToSite(int id, int siteId) {
    return into(siteAssociatedData).insert(
      SiteAssociatedDataCompanion.insert(siteId: siteId, associatedDataId: id),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> linkToEvent(int id, int eventId) {
    return into(eventAssociatedData).insert(
      EventAssociatedDataCompanion.insert(
        eventID: eventId,
        associatedDataId: id,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> linkToTarget(int id, AssociatedDataTarget target) =>
      switch (target) {
        SpecimenAssociatedDataTarget(:final specimenUuid) => linkToSpecimen(
          id,
          specimenUuid,
        ),
        SiteAssociatedDataTarget(:final siteId) => linkToSite(id, siteId),
        EventAssociatedDataTarget(:final eventId) => linkToEvent(id, eventId),
      };

  Future<int> updateAssociatedData(int id, AssociatedDataCompanion form) async {
    return (update(
      associatedData,
    )..where((t) => t.primaryId.equals(id))).write(form);
  }

  Future<List<AssociatedDataData>> getAllAssociatedData(
    String specimenUuid,
  ) async {
    final linkedIds = selectOnly(specimenAssociatedData)
      ..addColumns([specimenAssociatedData.associatedDataId])
      ..where(specimenAssociatedData.specimenUuid.equals(specimenUuid));
    return (select(
      associatedData,
    )..where((row) => row.primaryId.isInQuery(linkedIds))).get();
  }

  Future<List<AssociatedDataData>> getAssociatedDataForSite(int siteId) {
    final query = select(associatedData).join([
      innerJoin(
        siteAssociatedData,
        siteAssociatedData.associatedDataId.equalsExp(associatedData.primaryId),
      ),
    ])..where(siteAssociatedData.siteId.equals(siteId));
    return query.map((row) => row.readTable(associatedData)).get();
  }

  Future<List<AssociatedDataData>> getAssociatedDataForEvent(int eventId) {
    final query = select(associatedData).join([
      innerJoin(
        eventAssociatedData,
        eventAssociatedData.associatedDataId.equalsExp(
          associatedData.primaryId,
        ),
      ),
    ])..where(eventAssociatedData.eventID.equals(eventId));
    return query.map((row) => row.readTable(associatedData)).get();
  }

  Future<List<AssociatedDataData>> getAssociatedDataForTarget(
    AssociatedDataTarget target,
  ) => switch (target) {
    SpecimenAssociatedDataTarget(:final specimenUuid) => getAllAssociatedData(
      specimenUuid,
    ),
    SiteAssociatedDataTarget(:final siteId) => getAssociatedDataForSite(siteId),
    EventAssociatedDataTarget(:final eventId) => getAssociatedDataForEvent(
      eventId,
    ),
  };

  Future<List<AssociatedDataData>> getAssociatedDataForProject(
    String projectUuid,
  ) {
    return (select(
      associatedData,
    )..where((row) => row.projectUuid.equals(projectUuid))).get();
  }

  Future<AssociatedDataData?> getAssociatedDataById(int id) {
    return (select(
      associatedData,
    )..where((row) => row.primaryId.equals(id))).getSingleOrNull();
  }

  Future<bool> isFileUsed(String storageKey, {String? projectUuid}) async {
    final query = select(associatedData)
      ..where((row) => row.uri.equals(storageKey));
    if (projectUuid != null) {
      query.where((row) => row.projectUuid.equals(projectUuid));
    }
    query.limit(1);
    final data = await query.getSingleOrNull();
    return data != null;
  }

  Future<void> deleteAssociatedData(int id) {
    return (delete(associatedData)..where((t) => t.primaryId.equals(id))).go();
  }

  Future<void> deleteAllAssociatedData(String specimenUuid) {
    return (delete(
      specimenAssociatedData,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).go();
  }

  Future<void> unlinkFromSpecimen(int id, String specimenUuid) {
    return (delete(specimenAssociatedData)
          ..where((row) => row.associatedDataId.equals(id))
          ..where((row) => row.specimenUuid.equals(specimenUuid)))
        .go();
  }

  Future<void> unlinkFromSite(int id, int siteId) {
    return (delete(siteAssociatedData)
          ..where((row) => row.associatedDataId.equals(id))
          ..where((row) => row.siteId.equals(siteId)))
        .go();
  }

  Future<void> unlinkFromEvent(int id, int eventId) {
    return (delete(eventAssociatedData)
          ..where((row) => row.associatedDataId.equals(id))
          ..where((row) => row.eventID.equals(eventId)))
        .go();
  }

  Future<void> unlinkFromTarget(int id, AssociatedDataTarget target) =>
      switch (target) {
        SpecimenAssociatedDataTarget(:final specimenUuid) => unlinkFromSpecimen(
          id,
          specimenUuid,
        ),
        SiteAssociatedDataTarget(:final siteId) => unlinkFromSite(id, siteId),
        EventAssociatedDataTarget(:final eventId) => unlinkFromEvent(
          id,
          eventId,
        ),
      };

  Future<bool> detachFromTarget(int id, AssociatedDataTarget target) async {
    return transaction(() async {
      await unlinkFromTarget(id, target);
      final isStillLinked = await _isLinked(id);
      if (!isStillLinked) {
        await deleteAssociatedData(id);
      }
      return !isStillLinked;
    });
  }

  Future<List<int>> getAssociatedDataIdsForTarget(
    AssociatedDataTarget target,
  ) async {
    switch (target) {
      case SpecimenAssociatedDataTarget(:final specimenUuid):
        final rows = await (select(
          specimenAssociatedData,
        )..where((row) => row.specimenUuid.equals(specimenUuid))).get();
        return rows.map((row) => row.associatedDataId).toList();
      case SiteAssociatedDataTarget(:final siteId):
        final rows = await (select(
          siteAssociatedData,
        )..where((row) => row.siteId.equals(siteId))).get();
        return rows.map((row) => row.associatedDataId).toList();
      case EventAssociatedDataTarget(:final eventId):
        final rows = await (select(
          eventAssociatedData,
        )..where((row) => row.eventID.equals(eventId))).get();
        return rows.map((row) => row.associatedDataId).toList();
    }
  }

  Future<void> unlinkAllFromSite(int siteId) {
    return (delete(
      siteAssociatedData,
    )..where((row) => row.siteId.equals(siteId))).go();
  }

  Future<void> unlinkAllFromEvent(int eventId) {
    return (delete(
      eventAssociatedData,
    )..where((row) => row.eventID.equals(eventId))).go();
  }

  Future<void> deleteAllAssociatedDataForProject(String projectUuid) {
    return (delete(
      associatedData,
    )..where((row) => row.projectUuid.equals(projectUuid))).go();
  }

  Future<bool> _isLinked(int id) async {
    final specimenLink =
        await (select(specimenAssociatedData)
              ..where((row) => row.associatedDataId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (specimenLink != null) return true;

    final siteLink =
        await (select(siteAssociatedData)
              ..where((row) => row.associatedDataId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (siteLink != null) return true;

    final eventLink =
        await (select(eventAssociatedData)
              ..where((row) => row.associatedDataId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    return eventLink != null;
  }
}
