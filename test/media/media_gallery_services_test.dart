import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/media/media_gallery_services.dart';
import 'package:nahpu/services/types/import.dart';

void main() {
  const services = MediaGalleryServices();

  test('filters by category and all searchable metadata tokens', () {
    final media = [
      _media(
        id: 1,
        category: 'specimen',
        fileName: 'bat-12.jpg',
        caption: 'Wing detail',
        camera: 'Canon R5',
        personnelId: 'person-1',
      ),
      _media(
        id: 2,
        category: 'site',
        fileName: 'forest.jpg',
        caption: 'Habitat overview',
        camera: 'Nikon Z8',
      ),
    ];

    final specimenResults = services.filterAndSort(
      media: media,
      category: MediaCategory.specimen,
      query: '',
      sort: MediaGallerySort.addedNewest,
    );
    expect(specimenResults.map((item) => item.primaryId), [1]);

    final metadataResults = services.filterAndSort(
      media: media,
      category: MediaCategory.all,
      query: 'wing ada canon',
      sort: MediaGallerySort.addedNewest,
      personnelNames: const {'person-1': 'Ada Lovelace'},
    );
    expect(metadataResults.map((item) => item.primaryId), [1]);
  });

  test('filters by project and matches project names', () {
    final media = [
      _media(id: 1, projectUuid: 'project-a'),
      _media(id: 2, projectUuid: 'project-b'),
      _media(id: 3, projectUuid: 'project-b'),
    ];

    final projectResults = services.filterAndSort(
      media: media,
      category: MediaCategory.all,
      query: '',
      sort: MediaGallerySort.addedOldest,
      projectUuid: 'project-b',
    );
    expect(projectResults.map((item) => item.primaryId), [2, 3]);

    final allResults = services.filterAndSort(
      media: media,
      category: MediaCategory.all,
      query: '',
      sort: MediaGallerySort.addedOldest,
    );
    expect(allResults.map((item) => item.primaryId), [1, 2, 3]);

    final nameResults = services.filterAndSort(
      media: media,
      category: MediaCategory.all,
      query: 'borneo',
      sort: MediaGallerySort.addedOldest,
      projectNames: const {'project-a': 'Borneo survey'},
    );
    expect(nameResults.map((item) => item.primaryId), [1]);
  });

  test('search index returns the same results as unindexed search', () {
    final media = [
      _media(id: 1, projectUuid: 'project-a', caption: 'Wing detail'),
      _media(
        id: 2,
        projectUuid: 'project-b',
        category: 'specimen',
        camera: 'Canon R5',
        personnelId: 'person-1',
      ),
      _media(id: 3, projectUuid: 'project-b', fileName: 'forest.jpg'),
    ];
    const personnelNames = {'person-1': 'Ada Lovelace'};
    const projectNames = {'project-b': 'Borneo survey'};
    final index = MediaSearchIndex.build(
      media,
      personnelNames: personnelNames,
      projectNames: projectNames,
    );

    for (final category in [MediaCategory.all, MediaCategory.specimen]) {
      for (final query in ['', 'canon', 'borneo', 'ada wing', 'forest']) {
        for (final projectUuid in [null, 'project-b']) {
          List<int> run(MediaSearchIndex? index) => services
              .filterAndSort(
                media: media,
                category: category,
                query: query,
                sort: MediaGallerySort.addedOldest,
                projectUuid: projectUuid,
                personnelNames: personnelNames,
                projectNames: projectNames,
                index: index,
              )
              .map((item) => item.primaryId)
              .toList();
          expect(run(index), run(null), reason: '$category "$query"');
        }
      }
    }
  });

  test('sorts added order and file names naturally', () {
    final media = [
      _media(id: 2, fileName: 'photo10.jpg'),
      _media(id: 3, fileName: null),
      _media(id: 1, fileName: 'photo2.jpg'),
    ];

    expect(_ids(services, media, MediaGallerySort.addedNewest), [3, 2, 1]);
    expect(_ids(services, media, MediaGallerySort.addedOldest), [1, 2, 3]);
    expect(_ids(services, media, MediaGallerySort.fileNameAscending), [
      1,
      2,
      3,
    ]);
    expect(_ids(services, media, MediaGallerySort.fileNameDescending), [
      2,
      1,
      3,
    ]);
  });

  test('sorts taken dates and keeps missing or invalid values last', () {
    final media = [
      _media(id: 1, taken: '2024:01:01 10:00:00'),
      _media(id: 2, taken: ''),
      _media(id: 3, taken: '2025:03:02 09:00:00'),
      _media(id: 4, taken: 'not-a-date'),
    ];

    expect(_ids(services, media, MediaGallerySort.takenNewest), [3, 1, 4, 2]);
    expect(_ids(services, media, MediaGallerySort.takenOldest), [1, 3, 4, 2]);
  });
}

List<int> _ids(
  MediaGalleryServices services,
  List<MediaData> media,
  MediaGallerySort sort,
) {
  return services
      .filterAndSort(
        media: media,
        category: MediaCategory.all,
        query: '',
        sort: sort,
      )
      .map((item) => item.primaryId)
      .toList();
}

MediaData _media({
  required int id,
  String projectUuid = 'project',
  String category = 'site',
  String? fileName = 'media.jpg',
  String? caption,
  String? camera,
  String? personnelId,
  String? taken,
}) {
  return MediaData(
    primaryId: id,
    projectUuid: projectUuid,
    category: category,
    fileName: fileName,
    caption: caption,
    camera: camera,
    personnelId: personnelId,
    taken: taken,
  );
}
