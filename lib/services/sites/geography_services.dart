import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/geography_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/types/geography.dart';

/// Resolves localities to shared `geography` rows.
///
/// Every writer goes through [resolve] so an identical locality reuses the
/// existing record instead of creating a duplicate. That is what lets the site
/// form, QR import, and project transfer all converge on one row.
class GeographyServices extends AppServices {
  const GeographyServices({required super.ref});

  /// Returns the id of the record for [draft], creating it when it is new.
  ///
  /// Returns null when [draft] carries no text, so a site with no locality
  /// keeps a null `geographyId`.
  Future<int?> resolve(GeographyDraft draft) async {
    final existing = await GeographyQuery(dbAccess).findMatch(draft);
    if (existing != null) return existing.id;
    final id = await GeographyQuery(dbAccess).resolve(draft);
    if (id != null) invalidateGeography();
    return id;
  }

  /// Points [siteId] at the record for [draft].
  ///
  /// Called when the geography card loses focus rather than on every keystroke:
  /// resolving per keystroke would create a row for every prefix the user types,
  /// and unreferenced rows are kept on purpose.
  Future<int?> resolveForSite(int siteId, GeographyDraft draft) async {
    final geographyId = await resolveForSiteIn(dbAccess, siteId, draft);
    invalidateGeography();
    ref.invalidate(siteEntryProvider);
    return geographyId;
  }

  /// Points [siteId] at the record for [draft] using [database] directly.
  ///
  /// Takes the database rather than reading it from a provider so a form card
  /// can still save while it is being disposed, when `ref` is no longer safe to
  /// touch. Callers that are still mounted should use [resolveForSite], which
  /// also refreshes the providers.
  static Future<int?> resolveForSiteIn(
    Database database,
    int siteId,
    GeographyDraft draft,
  ) async {
    final geographyId = await GeographyQuery(database).resolve(draft);
    await SiteQuery(database).updateSiteEntry(
      siteId,
      SiteCompanion(geographyId: db.Value(geographyId)),
    );
    return geographyId;
  }

  Future<GeographyData?> getById(int? id) async {
    if (id == null) return null;
    return GeographyQuery(dbAccess).getById(id);
  }

  Future<List<GeographyData>> getAll() => GeographyQuery(dbAccess).getAll();

  Future<List<String>> getDistinctValues(GeographyField field) =>
      GeographyQuery(dbAccess).getDistinctValues(field);

  /// Removes localities no site points at. Only ever called on request.
  Future<int> deleteUnreferenced() async {
    final removed = await GeographyQuery(dbAccess).deleteUnreferenced();
    invalidateGeography();
    return removed;
  }

  void invalidateGeography() {
    ref.invalidate(geographyListProvider);
  }
}
