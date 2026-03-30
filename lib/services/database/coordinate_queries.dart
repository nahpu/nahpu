import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

part 'coordinate_queries.g.dart';

@DriftAccessor(
  include: {'tables.drift'},
)
class CoordinateQuery extends DatabaseAccessor<Database>
    with _$CoordinateQueryMixin {
  CoordinateQuery(super.db);

  Future<int> createCoordinate(CoordinateCompanion form) =>
      into(coordinate).insert(form);

  Future<List<CoordinateData>> getAllCoordinates() {
    return select(coordinate).get();
  }

  Future<CoordinateData> getCoordinateById(int id) {
    return (select(coordinate)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<List<CoordinateData>> getCoordinatesBySiteID(int siteID) {
    return (select(coordinate)..where((t) => t.siteID.equals(siteID))).get();
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
}
