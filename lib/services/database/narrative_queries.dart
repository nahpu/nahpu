import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/record_sort_terms.dart';
import 'package:nahpu/services/types/record_sort.dart';

part 'narrative_queries.g.dart';

@DriftAccessor(include: {'tables.drift'})
class NarrativeQuery extends DatabaseAccessor<Database>
    with _$NarrativeQueryMixin {
  NarrativeQuery(super.db);

  Future<int> createNarrative(NarrativeCompanion form) =>
      into(narrative).insert(form);

  Future updateNarrativeEntry(int id, NarrativeCompanion entry) {
    return (update(narrative)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<List<NarrativeData>> searchNarrative(String query) async {
    return await (select(
          narrative,
        )..where((t) => t.narrative.like('%$query%') | t.date.like('%$query%')))
        .get();
  }

  /// Returns narratives in [sort] order. The default keeps insertion order, so
  /// new records are the final form page.
  Future<List<NarrativeData>> getAllNarrative(
    String projectUuid, {
    RecordSort sort = RecordSort.defaultSort,
  }) async {
    if (sort.isDefault) {
      return (select(narrative)
            ..where((t) => t.projectUuid.equals(projectUuid))
            ..orderBy([(row) => OrderingTerm.asc(row.id)]))
          .get();
    }
    // `writerId` carries no foreign key in the schema, but the join is still
    // valid — it is a plain personnel uuid.
    final query =
        select(narrative).join([
            leftOuterJoin(site, narrative.siteID.equalsExp(site.id)),
            leftOuterJoin(
              personnel,
              narrative.writerId.equalsExp(personnel.uuid),
            ),
          ])
          ..where(narrative.projectUuid.equals(projectUuid))
          ..orderBy(_orderingTerms(sort));
    final rows = await query.get();
    return rows.map((row) => row.readTable(narrative)).toList(growable: false);
  }

  List<OrderingTerm> _orderingTerms(RecordSort sort) {
    final direction = sort.direction;
    return [
      ...switch (sort.field) {
        // Dates are ISO `yyyy-MM-dd` text, so lexicographic is chronological.
        RecordSortField.narrativeDate => textSortTerms(
          narrative.date,
          direction,
        ),
        // Order by the site id the user reads on the form, not by the raw
        // integer foreign key, which means nothing to them.
        RecordSortField.narrativeSite => [
          ...textSortTerms(site.siteID, direction),
          OrderingTerm(
            expression: narrative.siteID,
            mode: orderingModeFor(direction),
          ),
        ],
        RecordSortField.writer => textSortTerms(personnel.name, direction),
        // Insertion order, and any field this viewer does not offer.
        _ => [
          OrderingTerm(
            expression: narrative.id,
            mode: orderingModeFor(direction),
          ),
        ],
      },
      // Ties must break the same way on every refetch (see record_sort_terms).
      OrderingTerm.asc(narrative.id),
    ];
  }

  Future<NarrativeData> getNarrativeById(int id) async {
    return await (select(narrative)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> createNarrativeMedia(NarrativeMediaCompanion form) {
    return into(narrativeMedia).insert(form);
  }

  Future<List<NarrativeMediaData>> getNarrativeMedia(int narrativeId) async {
    return await (select(
      narrativeMedia,
    )..where((t) => t.narrativeId.equals(narrativeId))).get();
  }

  Future<NarrativeMediaData> getNarrativeMediaById(int mediaId) async {
    return await (select(
      narrativeMedia,
    )..where((t) => t.mediaId.equals(mediaId))).getSingle();
  }

  Future<void> updateNarrativeMedia(
    int narrativeId,
    NarrativeMediaCompanion form,
  ) {
    return (update(
      narrativeMedia,
    )..where((t) => t.narrativeId.equals(narrativeId))).write(form);
  }

  Future<void> deleteNarrativeMedia(int mediaId) {
    return (delete(
      narrativeMedia,
    )..where((t) => t.mediaId.equals(mediaId))).go();
  }

  Future<void> deleteAllNarrativeMedia(int narrativeId) {
    return (delete(
      narrativeMedia,
    )..where((t) => t.narrativeId.equals(narrativeId))).go();
  }

  Future<void> deleteNarrative(int id) {
    return (delete(narrative)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAllNarrative(String projectUuid) {
    return (delete(
      narrative,
    )..where((t) => t.projectUuid.equals(projectUuid))).go();
  }

  /// Update only the writerId for a narrative using Drift's update API.
  Future<void> updateNarrativeWriter(int id, String? writerUuid) {
    return (update(narrative)..where((t) => t.id.equals(id))).write(
      NarrativeCompanion(
        writerId: writerUuid == null ? const Value.absent() : Value(writerUuid),
      ),
    );
  }
}
