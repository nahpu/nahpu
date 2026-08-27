import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/geography.dart';

part 'geography_queries.g.dart';

/// The geography field a suggestion list is built from.
enum GeographyField {
  country,
  islandGroup,
  stateProvince,
  county,
  municipality,
  locality,
}

/// Reads and writes the shared, project-independent `geography` table.
///
/// [resolve] is the only place geography rows are created. Routing every writer
/// through it is what keeps `matchKey` in sync with the six columns, and what
/// makes an identical locality reuse an existing row instead of duplicating it.
@DriftAccessor(include: {'tables.drift'})
class GeographyQuery extends DatabaseAccessor<Database>
    with _$GeographyQueryMixin {
  GeographyQuery(super.db);

  /// Returns the row matching [draft], or null when the locality is new.
  Future<GeographyData?> findMatch(GeographyDraft draft) {
    if (draft.isEmpty) return Future.value();
    return getByMatchKey(draft.matchKey);
  }

  Future<GeographyData?> getByMatchKey(String key) {
    return (select(
      geography,
    )..where((row) => row.matchKey.equals(key))).getSingleOrNull();
  }

  Future<GeographyData?> getById(int? id) {
    if (id == null) return Future.value();
    return (select(
      geography,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  /// Returns the id of the row for [draft], inserting one when it is new.
  ///
  /// Returns null for an empty draft so a site with no locality keeps a null
  /// `geographyId` rather than pointing at a blank row.
  Future<int?> resolve(GeographyDraft draft) async {
    if (draft.isEmpty) return null;
    final existing = await getByMatchKey(draft.matchKey);
    if (existing != null) return existing.id;
    return into(geography).insert(draft.toCompanion());
  }

  Future<List<GeographyData>> getAll() {
    return (select(geography)..orderBy([
          (row) => OrderingTerm.asc(row.country),
          (row) => OrderingTerm.asc(row.stateProvince),
          (row) => OrderingTerm.asc(row.county),
          (row) => OrderingTerm.asc(row.municipality),
          (row) => OrderingTerm.asc(row.locality),
        ]))
        .get();
  }

  Future<Map<int, GeographyData>> getByIds(Iterable<int> ids) async {
    final wanted = ids.toList(growable: false);
    if (wanted.isEmpty) return const {};
    final rows = await (select(
      geography,
    )..where((row) => row.id.isIn(wanted))).get();
    return {for (final row in rows) row.id: row};
  }

  /// Returns the distinct non-blank values recorded for [field].
  Future<List<String>> getDistinctValues(GeographyField field) async {
    final column = _columnFor(field);
    final query = selectOnly(geography)
      ..addColumns([column])
      ..where(column.isNotNull())
      ..groupBy([column])
      ..orderBy([OrderingTerm.asc(column)]);
    final result = await query.get();
    return result
        .map((row) => row.read(column))
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: false);
  }

  /// Deletes geography rows no site points at.
  ///
  /// Never called automatically: unreferenced rows are kept on purpose so a
  /// locality typed once stays available to the field autocomplete. This backs
  /// an explicit maintenance action.
  Future<int> deleteUnreferenced() {
    return customUpdate(
      'DELETE FROM geography WHERE id NOT IN '
      '(SELECT geographyId FROM site WHERE geographyId IS NOT NULL)',
      updates: {geography},
      updateKind: UpdateKind.delete,
    );
  }

  GeneratedColumn<String> _columnFor(GeographyField field) => switch (field) {
    GeographyField.country => geography.country,
    GeographyField.islandGroup => geography.islandGroup,
    GeographyField.stateProvince => geography.stateProvince,
    GeographyField.county => geography.county,
    GeographyField.municipality => geography.municipality,
    GeographyField.locality => geography.locality,
  };
}
