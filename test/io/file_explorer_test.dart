import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/file_explorer_services.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:path/path.dart' as path;

/// Files that must never be offered for deletion are the point of this suite:
/// a wrong answer here destroys data the user cannot get back.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  const projectUuid = 'project-uuid-1';

  late Directory tempAppDir;
  late Directory nahpuDir;
  late Database db;

  setUp(() {
    tempAppDir = Directory.systemTemp.createTempSync('nahpu-file-explorer');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          switch (call.method) {
            case 'getApplicationDocumentsDirectory':
              return tempAppDir.path;
            case 'getTemporaryDirectory':
              return Directory.systemTemp.path;
            default:
              return null;
          }
        });
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    nahpuDir = Directory(path.join(tempAppDir.path, nahpuAppDir))
      ..createSync(recursive: true);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await db.close();
    if (tempAppDir.existsSync()) tempAppDir.deleteSync(recursive: true);
  });

  /// Writes a file under the app dir, backdated past the safety window so it
  /// is eligible for pruning unless a rule says otherwise.
  File writeFile(
    List<String> segments, {
    String content = 'x',
    bool old = true,
  }) {
    final file = File(path.join(nahpuDir.path, path.joinAll(segments)));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    if (old) {
      file.setLastModifiedSync(
        DateTime.now().subtract(const Duration(days: 2)),
      );
    }
    return file;
  }

  Future<void> insertProject() async {
    await db
        .into(db.project)
        .insert(
          ProjectCompanion.insert(uuid: projectUuid, name: 'Test Project'),
        );
  }

  Future<AppFileTree> scan() async {
    final services = FileExplorerServices(db: db);
    final index = await services.buildIndex();
    final root = await services.canonicalRoot();
    return AppFileTreeScanner(index: index, root: root).scan();
  }

  Map<String, NahpuFileNode> filesByName(AppFileTree tree) {
    final out = <String, NahpuFileNode>{};
    void visit(NahpuTreeNode node) {
      switch (node) {
        case NahpuFileNode():
          out[node.name] = node;
        case NahpuDirectoryNode():
          node.children.forEach(visit);
      }
    }

    visit(tree.root);
    return out;
  }

  group('locked application files', () {
    test(
      'database, config database, and sidecars are never deletable',
      () async {
        await insertProject();
        writeFile(['nahpu.db']);
        writeFile(['nahpu_configs.db']);
        writeFile(['nahpu.db-wal']);
        writeFile(['nahpu.db-shm']);
        writeFile(['nahpu.db-journal']);

        final files = filesByName(await scan());

        for (final name in [
          'nahpu.db',
          'nahpu_configs.db',
          'nahpu.db-wal',
          'nahpu.db-shm',
          'nahpu.db-journal',
        ]) {
          expect(
            files[name]?.status,
            NahpuFileStatus.locked,
            reason: '$name must never be offered for deletion',
          );
        }
      },
    );

    test('backups are locked whatever the archive format', () async {
      await insertProject();
      writeFile([nahpuBackupDir, 'nahpu_backup-2026-01-01.sqlite3']);
      // A .zip or .tar.gz backup has no database extension to recognise.
      writeFile([nahpuBackupDir, 'nahpu_backup-2026-01-02.zip']);
      writeFile([nahpuBackupDir, 'nahpu_backup-2026-01-03.tar.gz']);

      final files = filesByName(await scan());

      expect(
        files['nahpu_backup-2026-01-01.sqlite3']?.status,
        NahpuFileStatus.locked,
      );
      expect(
        files['nahpu_backup-2026-01-02.zip']?.status,
        NahpuFileStatus.locked,
      );
      expect(
        files['nahpu_backup-2026-01-03.tar.gz']?.status,
        NahpuFileStatus.locked,
      );
    });

    test('custom fonts and map layers are locked without a catalog', () async {
      await insertProject();
      writeFile([userConfigDirName, userFontDirName, 'custom.ttf']);
      // Deliberately no catalog.json: a layer directory is populated before
      // its catalog entry is written, so the catalog cannot gate deletion.
      writeFile([
        userConfigDirName,
        userMapDirName,
        'layer-1',
        'tiles.pmtiles',
      ]);
      writeFile([userConfigDirName, userMapDirName, 'catalog.json']);

      final files = filesByName(await scan());

      expect(files['custom.ttf']?.status, NahpuFileStatus.locked);
      expect(files['tiles.pmtiles']?.status, NahpuFileStatus.locked);
      expect(files['catalog.json']?.status, NahpuFileStatus.locked);
    });
  });

  group('linked files', () {
    test(
      'media, personnel, and associated data references lock a file',
      () async {
        await insertProject();
        await db
            .into(db.media)
            .insert(
              MediaCompanion.insert(
                projectUuid: const Value(projectUuid),
                fileName: const Value('linked.jpg'),
                category: const Value('specimen'),
              ),
            );
        await db
            .into(db.personnel)
            .insert(
              PersonnelCompanion.insert(
                uuid: 'personnel-1',
                photoPath: const Value('portrait.jpg'),
              ),
            );
        await db
            .into(db.associatedData)
            .insert(
              AssociatedDataCompanion.insert(
                projectUuid: const Value(projectUuid),
                type: const Value('File'),
                uri: const Value('sites/notes.pdf'),
              ),
            );

        writeFile([projectUuid, mediaDir, 'specimen', 'linked.jpg']);
        writeFile(['appMedia', 'personnel', 'portrait.jpg']);
        writeFile([projectUuid, associatedDataDir, 'sites', 'notes.pdf']);

        final files = filesByName(await scan());

        expect(files['linked.jpg']?.status, NahpuFileStatus.linked);
        expect(files['portrait.jpg']?.status, NahpuFileStatus.linked);
        expect(files['notes.pdf']?.status, NahpuFileStatus.linked);
      },
    );

    test(
      'an absolute file:// reference locks a file inside the app dir',
      () async {
        await insertProject();
        final target = writeFile([
          projectUuid,
          associatedDataDir,
          'specimens',
          'scan.pdf',
        ]);
        await db
            .into(db.associatedData)
            .insert(
              AssociatedDataCompanion.insert(
                projectUuid: const Value(projectUuid),
                type: const Value('File'),
                uri: Value(Uri.file(target.path).toString()),
              ),
            );

        final files = filesByName(await scan());
        expect(files['scan.pdf']?.status, NahpuFileStatus.linked);
      },
    );

    test('a personnel asset path does not lock an unrelated file', () async {
      await insertProject();
      await db
          .into(db.personnel)
          .insert(
            PersonnelCompanion.insert(
              uuid: 'personnel-2',
              photoPath: const Value('assets/avatars/bird.png'),
            ),
          );
      writeFile([projectUuid, mediaDir, 'specimen', 'bird.png']);

      final files = filesByName(await scan());
      expect(files['bird.png']?.status, NahpuFileStatus.dangling);
    });
  });

  group('dangling files', () {
    test(
      'an unreferenced media file in a managed folder is dangling',
      () async {
        await insertProject();
        // At least one reference must exist, or the empty-index guard correctly
        // refuses to trust the scan.
        await db
            .into(db.media)
            .insert(
              MediaCompanion.insert(
                projectUuid: const Value(projectUuid),
                fileName: const Value('kept.jpg'),
                category: const Value('specimen'),
              ),
            );
        writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
        writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);

        final tree = await scan();
        expect(
          filesByName(tree)['orphan.jpg']?.status,
          NahpuFileStatus.dangling,
        );
        expect(tree.danglingCount, 1);
        expect(tree.canPrune, isTrue);
      },
    );

    test('a recently modified file is held back', () async {
      await insertProject();
      writeFile([projectUuid, mediaDir, 'specimen', 'fresh.jpg'], old: false);

      final files = filesByName(await scan());
      expect(files['fresh.jpg']?.status, NahpuFileStatus.locked);
      expect(files['fresh.jpg']?.lockReason, NahpuLockReason.recentlyModified);
    });
  });

  group('files outside managed folders are left alone', () {
    test('a folder of an unknown project is never dangling', () async {
      await insertProject();
      // Indistinguishable from a database restored to an older backup, where
      // this media is the only remaining copy.
      writeFile(['unknown-project-uuid', mediaDir, 'specimen', 'photo.jpg']);

      final tree = await scan();
      expect(filesByName(tree)['photo.jpg']?.status, NahpuFileStatus.unmanaged);
      expect(tree.danglingCount, 0);
    });

    test('a file saved at the app root is unmanaged', () async {
      await insertProject();
      writeFile(['my_export.csv']);

      final tree = await scan();
      expect(
        filesByName(tree)['my_export.csv']?.status,
        NahpuFileStatus.unmanaged,
      );
    });

    test('map import staging is unmanaged despite its odd name', () async {
      await insertProject();
      // `.<id>.import` breaks extension parsing, which is why location is
      // decided from path segments rather than from the detected format.
      writeFile([userConfigDirName, userMapDirName, '.abc.import', 'data']);

      final files = filesByName(await scan());
      expect(files['data']?.status, NahpuFileStatus.locked);
    });
  });

  group('prune', () {
    test('deletes only dangling files and keeps structural folders', () async {
      await insertProject();
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('keep.jpg'),
              category: const Value('specimen'),
            ),
          );
      final keep = writeFile([projectUuid, mediaDir, 'specimen', 'keep.jpg']);
      final drop = writeFile([projectUuid, mediaDir, 'specimen', 'drop.jpg']);
      final database = writeFile(['nahpu.db']);
      final font = writeFile([userConfigDirName, userFontDirName, 'f.ttf']);
      final nested = writeFile([projectUuid, mediaDir, 'site', 'sub', 'a.jpg']);

      final services = FileExplorerServices(db: db);
      final index = await services.buildIndex();
      final root = await services.canonicalRoot();
      final tree = await AppFileTreeScanner(index: index, root: root).scan();

      final result = await AppFilePruner(
        index: index,
        root: root,
        structuralDirs: buildStructuralDirs(root, index.knownProjectUuids),
      ).prune(tree.prunablePaths);

      expect(result.deletedCount, 2);
      expect(result.failedPaths, isEmpty);
      expect(keep.existsSync(), isTrue);
      expect(database.existsSync(), isTrue);
      expect(font.existsSync(), isTrue);
      expect(drop.existsSync(), isFalse);
      expect(nested.existsSync(), isFalse);
      // The emptied non-structural folder goes; the category folder stays.
      expect(Directory(path.dirname(nested.path)).existsSync(), isFalse);
      expect(
        Directory(
          path.join(nahpuDir.path, projectUuid, mediaDir, 'site'),
        ).existsSync(),
        isTrue,
      );
    });

    test('refuses a path that was not in the scan', () async {
      await insertProject();
      final outside = writeFile([projectUuid, mediaDir, 'specimen', 'x.jpg']);
      final services = FileExplorerServices(db: db);
      final index = await services.buildIndex();
      final root = await services.canonicalRoot();

      // A path that became linked between the scan and the delete.
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('x.jpg'),
              category: const Value('specimen'),
            ),
          );
      final freshIndex = await FileExplorerServices(db: db).buildIndex();

      final result = await AppFilePruner(
        index: freshIndex,
        root: root,
        structuralDirs: buildStructuralDirs(root, index.knownProjectUuids),
      ).prune([outside.path]);

      expect(result.deletedCount, 0);
      expect(result.failedPaths, [outside.path]);
      expect(outside.existsSync(), isTrue);
    });
  });

  group('directory rollups', () {
    test('deletableCount counts only removable files', () async {
      await insertProject();
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('kept.jpg'),
              category: const Value('specimen'),
            ),
          );
      writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
      writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);

      final tree = await scan();
      final specimenDir = _findDir(tree.root, 'specimen');

      expect(specimenDir.fileCount, 2);
      // The linked photo is not selectable; the orphan is.
      expect(specimenDir.deletableCount, 1);
      expect(specimenDir.isSelectable, isTrue);
    });

    test('a folder holding only the database is not selectable', () async {
      await insertProject();
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('kept.jpg'),
              category: const Value('specimen'),
            ),
          );
      writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);

      final tree = await scan();
      final root = tree.root;
      final databaseFiles = root.children.whereType<NahpuFileNode>();

      expect(databaseFiles.every((f) => !f.isManuallyDeletable), isTrue);
      final specimenDir = _findDir(root, 'specimen');
      expect(specimenDir.deletableCount, 0);
      expect(specimenDir.isSelectable, isFalse);
    });

    test(
      'a project folder keeps its UUID name and names the project',
      () async {
        await insertProject();
        await db
            .into(db.media)
            .insert(
              MediaCompanion.insert(
                projectUuid: const Value(projectUuid),
                fileName: const Value('kept.jpg'),
                category: const Value('specimen'),
              ),
            );
        writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);

        final tree = await scan();
        final projectDir = _findDir(tree.root, projectUuid);

        // The folder is named with a v4 UUID on disk, so that is what shows.
        expect(projectDir.name, projectUuid);
        expect(projectDir.subtitle, '1 file · Test Project');
      },
    );
  });

  group('empty directories', () {
    test('an empty non-structural folder is removable', () async {
      await insertProject();
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('kept.jpg'),
              category: const Value('specimen'),
            ),
          );
      writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
      final stale = Directory(
        path.join(nahpuDir.path, projectUuid, mediaDir, 'site', 'old'),
      )..createSync(recursive: true);

      final tree = await scan();
      final node = _findDir(tree.root, 'old');

      expect(node.isEmpty, isTrue);
      expect(node.isStructural, isFalse);
      expect(node.isRemovableWhenEmpty, isTrue);

      final result = await _prunerFor(
        db,
      ).then((pruner) => pruner.deleteDirectories([stale.path]));
      expect(result.deletedCount, 1);
      expect(stale.existsSync(), isFalse);
      // Its structural parent stays.
      expect(
        Directory(
          path.join(nahpuDir.path, projectUuid, mediaDir, 'site'),
        ).existsSync(),
        isTrue,
      );
    });

    test('a structural folder is never removable, even when empty', () async {
      await insertProject();
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('kept.jpg'),
              category: const Value('specimen'),
            ),
          );
      writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
      final structural = Directory(
        path.join(nahpuDir.path, projectUuid, mediaDir, 'site'),
      )..createSync(recursive: true);

      final tree = await scan();
      final node = _findDir(tree.root, 'site');
      expect(node.isEmpty, isTrue);
      expect(node.isStructural, isTrue);
      expect(node.isRemovableWhenEmpty, isFalse);

      final pruner = await _prunerFor(db);
      final result = await pruner.deleteDirectories([structural.path]);
      expect(result.deletedCount, 0);
      expect(result.failedPaths, [structural.path]);
      expect(structural.existsSync(), isTrue);
    });

    test('a folder holding files is refused', () async {
      await insertProject();
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('kept.jpg'),
              category: const Value('specimen'),
            ),
          );
      writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
      final occupied = File(
        path.join(nahpuDir.path, projectUuid, mediaDir, 'site', 'a', 'x.jpg'),
      )..createSync(recursive: true);

      final pruner = await _prunerFor(db);
      final result = await pruner.deleteDirectories([occupied.parent.path]);

      expect(result.deletedCount, 0);
      expect(occupied.existsSync(), isTrue);
    });

    test('a folder holding only bookkeeping files still goes', () async {
      await insertProject();
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('kept.jpg'),
              category: const Value('specimen'),
            ),
          );
      writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
      // The tree hides these, so the folder is shown as empty; refusing would
      // contradict what the user was told.
      final noisy = Directory(
        path.join(nahpuDir.path, projectUuid, mediaDir, 'site', 'b'),
      )..createSync(recursive: true);
      File(path.join(noisy.path, '.DS_Store')).writeAsStringSync('x');

      final tree = await scan();
      expect(_findDir(tree.root, 'b').isRemovableWhenEmpty, isTrue);

      final pruner = await _prunerFor(db);
      final result = await pruner.deleteDirectories([noisy.path]);

      expect(result.deletedCount, 1);
      expect(noisy.existsSync(), isFalse);
    });

    test('nested empty folders go deepest first in one pass', () async {
      await insertProject();
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('kept.jpg'),
              category: const Value('specimen'),
            ),
          );
      writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
      final outer = Directory(
        path.join(nahpuDir.path, projectUuid, mediaDir, 'site', 'outer'),
      );
      final inner = Directory(path.join(outer.path, 'inner'))
        ..createSync(recursive: true);

      final pruner = await _prunerFor(db);
      final result = await pruner.deleteDirectories([outer.path, inner.path]);

      expect(result.deletedCount, 2);
      expect(inner.existsSync(), isFalse);
      expect(outer.existsSync(), isFalse);
    });
  });

  group('manual deletion', () {
    test('a backup can be deleted by hand but is never pruned', () async {
      await insertProject();
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('kept.jpg'),
              category: const Value('specimen'),
            ),
          );
      writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
      final backup = writeFile([nahpuBackupDir, 'old_backup.sqlite3']);

      final services = FileExplorerServices(db: db);
      final index = await services.buildIndex();
      final root = await services.canonicalRoot();
      final tree = await AppFileTreeScanner(index: index, root: root).scan();

      // Not a prune candidate.
      expect(tree.prunablePaths, isNot(contains(backup.path)));

      final pruner = AppFilePruner(
        index: index,
        root: root,
        structuralDirs: buildStructuralDirs(root, index.knownProjectUuids),
      );
      final result = await pruner.deleteSelected([backup.path]);

      expect(result.deletedCount, 1);
      expect(backup.existsSync(), isFalse);
      // The backup folder itself survives.
      expect(
        Directory(path.join(nahpuDir.path, nahpuBackupDir)).existsSync(),
        isTrue,
      );
    });

    test('the live database is refused even by hand', () async {
      await insertProject();
      final live = writeFile(['nahpu.db']);
      final wal = writeFile(['nahpu.db-wal']);

      final services = FileExplorerServices(db: db);
      final index = await services.buildIndex();
      final root = await services.canonicalRoot();
      final result = await AppFilePruner(
        index: index,
        root: root,
        structuralDirs: buildStructuralDirs(root, index.knownProjectUuids),
      ).deleteSelected([live.path, wal.path]);

      expect(result.deletedCount, 0);
      expect(result.failedPaths, hasLength(2));
      expect(live.existsSync(), isTrue);
      expect(wal.existsSync(), isTrue);
    });

    test('a linked file is refused even by hand', () async {
      await insertProject();
      await db
          .into(db.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: const Value(projectUuid),
              fileName: const Value('kept.jpg'),
              category: const Value('specimen'),
            ),
          );
      final kept = writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);

      final services = FileExplorerServices(db: db);
      final index = await services.buildIndex();
      final root = await services.canonicalRoot();
      final result = await AppFilePruner(
        index: index,
        root: root,
        structuralDirs: buildStructuralDirs(root, index.knownProjectUuids),
      ).deleteSelected([kept.path]);

      expect(result.deletedCount, 0);
      expect(kept.existsSync(), isTrue);
    });
  });

  test('the flutter engine cache is not shown at all', () async {
    await insertProject();
    writeFile(['flutter_engine', 'cache.bin']);
    writeFile([projectUuid, mediaDir, 'specimen', 'a.jpg']);

    final tree = await scan();

    expect(filesByName(tree).containsKey('cache.bin'), isFalse);
    expect(tree.fileCount, 1);
  });

  group('fail closed', () {
    test('an unreadable reference blocks pruning entirely', () async {
      await insertProject();
      await db
          .into(db.associatedData)
          .insert(
            AssociatedDataCompanion.insert(
              projectUuid: const Value(projectUuid),
              type: const Value('File'),
              uri: const Value('../../escape.pdf'),
            ),
          );
      writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);

      final tree = await scan();

      expect(tree.pruneBlockedReason, isNotNull);
      expect(tree.canPrune, isFalse);
    });

    test('an empty index does not mark managed files dangling', () async {
      await insertProject();
      writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);

      final tree = await scan();

      // No media, personnel, or associated data rows exist at all, which is
      // indistinguishable from a failed read.
      expect(tree.canPrune, isFalse);
      expect(tree.pruneBlockedReason, isNotNull);
    });
  });
}

/// Finds the first directory named [name] anywhere in the tree.
NahpuDirectoryNode _findDir(NahpuDirectoryNode root, String name) {
  if (root.name == name) return root;
  for (final child in root.children.whereType<NahpuDirectoryNode>()) {
    final found = _tryFindDir(child, name);
    if (found != null) return found;
  }
  throw StateError('No directory named $name in the tree.');
}

NahpuDirectoryNode? _tryFindDir(NahpuDirectoryNode node, String name) {
  if (node.name == name) return node;
  for (final child in node.children.whereType<NahpuDirectoryNode>()) {
    final found = _tryFindDir(child, name);
    if (found != null) return found;
  }
  return null;
}

/// Builds a pruner against the current database state.
Future<AppFilePruner> _prunerFor(Database db) async {
  final services = FileExplorerServices(db: db);
  final index = await services.buildIndex();
  final root = await services.canonicalRoot();
  return AppFilePruner(
    index: index,
    root: root,
    structuralDirs: buildStructuralDirs(root, index.knownProjectUuids),
  );
}
