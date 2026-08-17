import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

part 'site_queries.g.dart';

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

  /// Returns sites oldest-first so new records are the final form page.
  Future<List<SiteData>> getAllSites(String projectUuid) {
    return (select(site)
          ..where((t) => t.projectUuid.equals(projectUuid))
          ..orderBy([(row) => OrderingTerm.asc(row.id)]))
        .get();
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

  Future<SiteData> getSiteById(int id) async {
    return await (select(site)..where((t) => t.id.equals(id))).getSingle();
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
