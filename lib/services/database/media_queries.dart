import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

part 'media_queries.g.dart';

@DriftAccessor(
  include: {'tables.drift'},
)
class MediaDbQuery extends DatabaseAccessor<Database> with _$MediaDbQueryMixin {
  MediaDbQuery(super.db);

  Future<int> createMedia(MediaCompanion form) {
    return into(media).insert(form);
  }

  Future<List<MediaData>> getAllMedia() {
    return select(media).get();
  }

  Future<bool> isMediaUsed(String baseName) async {
    final MediaData? mediaList = await (select(media)
          ..where((tbl) => tbl.fileName.equals(baseName))
          ..limit(1))
        .getSingleOrNull();
    return mediaList != null;
  }

  Future<List<MediaData>> getMediaByProject(String projectUuid) async {
    return (select(media)..where((t) => t.projectUuid.equals(projectUuid)))
        .get();
  }

  Future<List<MediaData>> getRecordMediaByProject(String projectUuid) {
    return (select(media)..where(
          (t) =>
              t.projectUuid.equals(projectUuid) &
              t.category.isIn(const [
                'event',
                'narrative',
                'site',
                'specimen',
              ]),
        ))
        .get();
  }

  Future<void> updateMedia(int mediaId, MediaCompanion form) {
    return (update(media)..where((t) => t.primaryId.equals(mediaId)))
        .write(form);
  }

  Future<MediaData> getMedia(int id) {
    return (select(media)..where((t) => t.primaryId.equals(id))).getSingle();
  }

  Future<void> deleteMedia(int id) {
    return (delete(media)..where((t) => t.primaryId.equals(id))).go();
  }

  Future<void> deleteMediaReferences(int id) async {
    await (delete(
      narrativeMedia,
    )..where((t) => t.mediaId.equals(id))).go();
    await (delete(siteMedia)..where((t) => t.mediaId.equals(id))).go();
    await (delete(eventMedia)..where((t) => t.mediaId.equals(id))).go();
    await (delete(
      specimenMedia,
    )..where((t) => t.mediaId.equals(id))).go();
    await (update(taxonomy)..where((t) => t.mediaId.equals(id))).write(
      const TaxonomyCompanion(mediaId: Value(null)),
    );
  }

  Future<void> deleteMediaByProject(String projectUuid) {
    return (delete(media)..where((t) => t.projectUuid.equals(projectUuid)))
        .go();
  }

  Future<bool> isMediaReferencedByTaxonomy(int mediaId) async {
    final taxonomyRow = await (select(taxonomy)
          ..where((t) => t.mediaId.equals(mediaId))
          ..limit(1))
        .getSingleOrNull();
    return taxonomyRow != null;
  }

  Future<void> detachMediaFromProject(int mediaId) {
    return (update(media)..where((t) => t.primaryId.equals(mediaId))).write(
      const MediaCompanion(projectUuid: Value(null)),
    );
  }
}
