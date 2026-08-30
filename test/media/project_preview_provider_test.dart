import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/media.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:path/path.dart' as path;

const _projectUuid = 'preview-project';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory documents;
  late Database database;
  late ProviderContainer container;

  setUp(() async {
    documents = Directory.systemTemp.createTempSync('nahpu-project-preview');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => documents.path);
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    for (final uuid in [_projectUuid, 'other-project']) {
      await ProjectQuery(
        database,
      ).createProject(ProjectCompanion(uuid: Value(uuid), name: Value(uuid)));
    }
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    container.listen(projectPreviewImageFilesProvider(_projectUuid), (_, _) {});
    container
        .read(projectUuidProvider.notifier)
        .updateProjectUuid('other-project');
  });

  tearDown(() async {
    container.dispose();
    await database.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await documents.delete(recursive: true);
  });

  Future<File> addMedia(
    String? fileName, {
    String category = 'site',
    String projectUuid = _projectUuid,
    bool exists = true,
  }) async {
    await MediaDbQuery(database).createMedia(
      MediaCompanion(
        projectUuid: Value(projectUuid),
        category: Value(category),
        fileName: Value(fileName),
        uri: fileName == null
            ? const Value('https://example.com/image.png')
            : const Value(null),
      ),
    );
    final file = File(
      path.join(
        documents.path,
        nahpuAppDir,
        projectUuid,
        mediaDir,
        category,
        fileName ?? 'unused',
      ),
    );
    if (exists && fileName != null) {
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync([1, 2, 3]);
    }
    return file;
  }

  Future<List<File>> load() {
    container.invalidate(projectPreviewImageFilesProvider(_projectUuid));
    return container.read(
      projectPreviewImageFilesProvider(_projectUuid).future,
    );
  }

  test(
    'returns only unique existing project images across record categories',
    () async {
      final expected = <String>{};
      for (final category in ['site', 'specimen', 'event', 'narrative']) {
        expected.add(
          (await addMedia('$category.PNG', category: category)).path,
        );
      }
      await addMedia('site.PNG');
      await addMedia('missing.jpg', exists: false);
      await addMedia('audio.wav');
      await addMedia('video.mp4');
      await addMedia('notes.pdf');
      await addMedia('../outside.png');
      await addMedia('unknown.png', category: 'unknown');
      await addMedia('person.png', category: 'personnel');
      await addMedia('other.png', projectUuid: 'other-project');
      await addMedia(null);

      final files = await load();

      expect(files.map((file) => file.path).toSet(), expected);
      expect(files, hasLength(4));
      expect(files.every((file) => file.existsSync()), isTrue);
      expect(container.read(projectUuidProvider), 'other-project');
    },
  );

  test(
    'caps the shuffled set at five and keeps it stable until refreshed',
    () async {
      final candidates = <String>{};
      for (var index = 0; index < 8; index++) {
        candidates.add((await addMedia('image-$index.jpg')).path);
      }
      final files = await load();
      final again = await container.read(
        projectPreviewImageFilesProvider(_projectUuid).future,
      );

      expect(files, hasLength(5));
      expect(files.map((file) => file.path).toSet(), hasLength(5));
      expect(files.every((file) => candidates.contains(file.path)), isTrue);
      expect(again, same(files));
    },
  );

  test(
    'returns no previews for audio, video, remote, or missing-only projects',
    () async {
      await addMedia('audio.wav');
      await addMedia('video.mp4');
      await addMedia('missing.png', exists: false);
      await addMedia(null);

      expect(await load(), isEmpty);
      expect(
        await container.read(projectPreviewImageFilesProvider('').future),
        isEmpty,
      );
    },
  );

  test(
    'refresh replaces deleted files and includes newly added images',
    () async {
      final oldImage = await addMedia('old.png');
      expect((await load()).single.path, oldImage.path);

      oldImage.deleteSync();
      final newImage = await addMedia('new.png', category: 'event');

      expect((await load()).single.path, newImage.path);
    },
  );
}
