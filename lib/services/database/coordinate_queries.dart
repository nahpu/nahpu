import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

part 'coordinate_queries.g.dart';

/// SQL expression resolving a specimen's coordinate id.
///
/// Mirrors [CoordinateQuery.resolveSpecimenCoordinate]: the stored
/// `specimen.coordinateID` wins; otherwise the only coordinate of the
/// specimen's event site is used. Sites with several coordinates stay
/// unresolved because the choice is ambiguous.
const String kResolvedSpecimenCoordinateIdSql = '''
coalesce(specimen.coordinateID, (
  SELECT min(siteCoordinate.id)
  FROM collEvent resolvedEvent
  INNER JOIN coordinate siteCoordinate
    ON siteCoordinate.siteID = resolvedEvent.siteID
  WHERE resolvedEvent.id = specimen.collEventID
  GROUP BY resolvedEvent.id
  HAVING count(siteCoordinate.id) = 1
))''';

@DriftAccessor(include: {'tables.drift'})
class CoordinateQuery extends DatabaseAccessor<Database>
    with _$CoordinateQueryMixin {
  CoordinateQuery(super.db);

  Future<int> createCoordinate(CoordinateCompanion form) =>
      into(coordinate).insert(form);

  Future<List<CoordinateData>> getAllCoordinates() {
    return select(coordinate).get();
  }

  Future<List<CoordinateData>> getCoordinatesByProject(String projectUuid) {
    final query = select(coordinate).join([
      innerJoin(site, site.id.equalsExp(coordinate.siteID)),
    ])..where(site.projectUuid.equals(projectUuid));
    return query.map((row) => row.readTable(coordinate)).get();
  }

  Future<CoordinateData> getCoordinateById(int id) {
    return (select(coordinate)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<List<CoordinateData>> getCoordinatesBySiteID(int siteID) {
    return (select(coordinate)..where((t) => t.siteID.equals(siteID))).get();
  }

  /// Returns the stored coordinate, or the only coordinate of the event site.
  Future<CoordinateData?> resolveSpecimenCoordinate(
    int? coordinateId,
    int? collEventId,
  ) async {
    if (coordinateId != null) {
      return (select(
        coordinate,
      )..where((t) => t.id.equals(coordinateId))).getSingleOrNull();
    }
    final siteId = await _siteIdForEvent(collEventId);
    if (siteId == null) return null;
    final coordinates = await getCoordinatesBySiteID(siteId);
    return coordinates.length == 1 ? coordinates.single : null;
  }

  /// Returns the coordinate id a specimen should use after moving to an event.
  ///
  /// Keeps [currentCoordinateId] when it belongs to the event site, otherwise
  /// selects the site's only coordinate.
  Future<int?> coordinateIdForEvent(
    int? collEventId, {
    int? currentCoordinateId,
  }) async {
    final siteId = await _siteIdForEvent(collEventId);
    if (siteId == null) return null;
    final coordinates = await getCoordinatesBySiteID(siteId);
    if (coordinates.any((c) => c.id == currentCoordinateId)) {
      return currentCoordinateId;
    }
    return coordinates.length == 1 ? coordinates.single.id : null;
  }

  Future<List<String>> getDistinctDatums() async {
    final query = selectOnly(coordinate)
      ..addColumns([coordinate.datum])
      ..where(coordinate.datum.isNotNull() & coordinate.datum.isNotValue(''))
      ..groupBy([coordinate.datum]);

    final result = await query.get();
    return result.map((row) => row.read(coordinate.datum)!).toList();
  }

  Future<void> updateCoordinate(int id, CoordinateCompanion entry) {
    return (update(coordinate)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> deleteCoordinateBySiteID(int siteID) {
    return (delete(coordinate)..where((t) => t.siteID.equals(siteID))).go();
  }

  Future<void> deleteCoordinate(int id) {
    return (delete(coordinate)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteCoordinates(List<int> ids) {
    return (delete(coordinate)..where((t) => t.id.isIn(ids))).go();
  }

  Future<void> deleteAllCoordinates() {
    return delete(coordinate).go();
  }

  Future<int?> _siteIdForEvent(int? collEventId) async {
    if (collEventId == null) return null;
    final event = await (select(
      collEvent,
    )..where((t) => t.id.equals(collEventId))).getSingleOrNull();
    return event?.siteID;
  }
}
