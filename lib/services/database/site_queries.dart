import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/record_sort_terms.dart';
import 'package:nahpu/services/types/geography.dart';
import 'package:nahpu/services/types/record_sort.dart';

part 'site_queries.g.dart';

/// Optional sedimentological and stratigraphic data belonging to a site.
class FossilSiteQuery extends DatabaseAccessor<Database> with _$SiteQueryMixin {
  FossilSiteQuery(super.db);

  Future<FossilSiteData?> getFossilSiteBySiteId(int siteId) {
    return (select(
      fossilSite,
    )..where((row) => row.siteID.equals(siteId))).getSingleOrNull();
  }

  /// The legacy table has no unique key, so update-or-insert must be atomic.
  Future<void> save(int siteId, FossilSiteCompanion entries) {
    return transaction(() async {
      final form = entries.copyWith(siteID: Value(siteId));
      final updated = await (update(
        fossilSite,
      )..where((row) => row.siteID.equals(siteId))).write(form);
      if (updated == 0) await into(fossilSite).insert(form);
    });
  }

  Future<void> duplicate(int sourceId, int targetId) async {
    final source = await getFossilSiteBySiteId(sourceId);
    if (source != null) await save(targetId, source.toCompanion(true));
  }

  Future<void> deleteFossilSite(int siteId) async {
    await (delete(fossilSite)..where((row) => row.siteID.equals(siteId))).go();
  }
}

@DriftAccessor(include: {'tables.drift'})
class SiteQuery extends DatabaseAccessor<Database> with _$SiteQueryMixin {
  SiteQuery(super.db);

  Future<int> createSite(SiteCompanion form) => into(site).insert(form);

  Future<int> createSiteAttribute(SiteAttributeCompanion form) =>
      into(siteAttribute).insert(form);

  Future updateSiteEntry(int id, SiteCompanion entry) {
    return (update(site)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<int> updateSiteAttributeEntry(
    int siteId,
    SiteAttributeCompanion entry,
  ) {
    return (update(
      siteAttribute,
    )..where((table) => table.siteID.equals(siteId))).write(entry);
  }

  Future<SiteAttributeData?> getSiteAttribute(int siteId) {
    return (select(
      siteAttribute,
    )..where((table) => table.siteID.equals(siteId))).getSingleOrNull();
  }

  Future<Map<int, SiteAttributeData>> getSiteAttributes(
    Iterable<int> siteIds,
  ) async {
    final ids = siteIds.toList(growable: false);
    if (ids.isEmpty) return const {};
    final rows = await (select(
      siteAttribute,
    )..where((table) => table.siteID.isIn(ids))).get();
    final bySite = <int, SiteAttributeData>{};
    for (final row in rows) {
      final id = row.siteID;
      if (id != null) bySite[id] = row;
    }
    return bySite;
  }

  /// Returns sites in [sort] order, each joined with its shared geography row.
  ///
  /// The default sort keeps insertion order, so new records are the final form
  /// page.
  Future<List<SiteRecord>> getAllSites(
    String projectUuid, {
    RecordSort sort = RecordSort.defaultSort,
  }) async {
    // Geography lives in its own table now, so every read joins it rather than
    // fetching one row per site.
    final query = select(site).join([
      leftOuterJoin(geography, geography.id.equalsExp(site.geographyId)),
    ])..where(site.projectUuid.equals(projectUuid));
    query.orderBy(
      sort.isDefault ? [OrderingTerm.asc(site.id)] : _orderingTerms(sort),
    );
    final rows = await query.get();
    return rows
        .map(
          (row) => SiteRecord(
            site: row.readTable(site),
            geography: row.readTableOrNull(geography),
          ),
        )
        .toList(growable: false);
  }

  List<OrderingTerm> _orderingTerms(RecordSort sort) {
    final direction = sort.direction;
    return [
      ...switch (sort.field) {
        RecordSortField.siteName => textSortTerms(site.siteID, direction),
        RecordSortField.stateProvince => textSortTerms(
          geography.stateProvince,
          direction,
        ),
        RecordSortField.locality => textSortTerms(
          geography.locality,
          direction,
        ),
        // Insertion order, and any field this viewer does not offer.
        _ => [
          OrderingTerm(expression: site.id, mode: orderingModeFor(direction)),
        ],
      },
      // Ties must break the same way on every refetch (see record_sort_terms).
      OrderingTerm.asc(site.id),
    ];
  }

  Future<void> createSiteMedia(SiteMediaCompanion form) {
    return into(siteMedia).insert(form);
  }

  Future<List<SiteMediaData>> getSiteMedia(int siteId) async {
    return await (select(
      siteMedia,
    )..where((t) => t.siteId.equals(siteId))).get();
  }

  Future<SiteMediaData> getSiteMediaById(int mediaId) async {
    return await (select(
      siteMedia,
    )..where((t) => t.mediaId.equals(mediaId))).getSingle();
  }

  Future<void> updateSiteMedia(int siteId, SiteMediaCompanion form) {
    return (update(
      siteMedia,
    )..where((t) => t.siteId.equals(siteId))).write(form);
  }

  Future<void> deleteSiteMedia(int mediaId) {
    return (delete(siteMedia)..where((t) => t.mediaId.equals(mediaId))).go();
  }

  Future<void> deleteAllSiteMedias(int siteID) {
    return (delete(siteMedia)..where((t) => t.siteId.equals(siteID))).go();
  }

  Future<void> deleteSite(int id) {
    return (delete(site)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteSiteAttribute(int siteId) {
    return (delete(
      siteAttribute,
    )..where((table) => table.siteID.equals(siteId))).go();
  }

  Future<SiteRecord> getSiteById(int id) async {
    final row = await (select(site).join([
      leftOuterJoin(geography, geography.id.equalsExp(site.geographyId)),
    ])..where(site.id.equals(id))).getSingle();
    return SiteRecord(
      site: row.readTable(site),
      geography: row.readTableOrNull(geography),
    );
  }

  Future<void> deleteAllSites(String projectUuid) {
    return (delete(site)..where((t) => t.projectUuid.equals(projectUuid))).go();
  }

  Future<List<String>> getDistinctHabitatTypes() async {
    final query = selectOnly(siteAttribute)
      ..addColumns([siteAttribute.habitatType])
      ..where(siteAttribute.habitatType.isNotNull())
      ..groupBy([siteAttribute.habitatType]);

    final result = await query.get();
    return result.map((row) => row.read(siteAttribute.habitatType)!).toList();
  }

  Future<List<String>> getDistinctSiteTypes() async {
    final query = selectOnly(site)
      ..addColumns([site.siteType])
      ..where(site.siteType.isNotNull())
      ..groupBy([site.siteType]);

    final result = await query.get();
    return result.map((row) => row.read(site.siteType)!).toList();
  }
}
