import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/export/db_writer.dart';
import 'package:path/path.dart' as path;

void main() {
  group('databaseCandidatesFromRelativePaths', () {
    test('returns only root database files', () {
      final candidates = databaseCandidatesFromRelativePaths([
        'backup.sqlite3',
        'nahpu.db',
        'backup/old.sqlite3',
        'project-a/media/photo.sqlite3',
        'UserConfigs/maps/world.mbtiles',
      ]);

      expect(candidates.map((candidate) => candidate.archivePath), [
        'backup.sqlite3',
        'nahpu.db',
      ]);
    });

    test('matches database extensions case-insensitively', () {
      final candidates = databaseCandidatesFromRelativePaths([
        'NAHPU.SQLITE3',
        'legacy.DB',
        'notes.txt',
      ]);

      expect(candidates, hasLength(2));
    });
  });

  group('isAssociatedBackupArchivePath', () {
    test('allows known NAHPU asset paths and rejects database artifacts', () {
      expect(
        isAssociatedBackupArchivePath('project-a/media/site/photo.jpg'),
        isTrue,
      );
      expect(
        isAssociatedBackupArchivePath('project-a/associatedData/specimen.pdf'),
        isTrue,
      );
      expect(
        isAssociatedBackupArchivePath(
          'project-a/associatedData/sites/site-notes.pdf',
        ),
        isTrue,
      );
      expect(
        isAssociatedBackupArchivePath('appMedia/personnel/person.jpg'),
        isTrue,
      );
      expect(
        isAssociatedBackupArchivePath('appMedia/template/shared-image.png'),
        isTrue,
      );
      expect(
        isAssociatedBackupArchivePath('UserConfigs/maps/world.mbtiles'),
        isTrue,
      );
      expect(
        isAssociatedBackupArchivePath('UserConfigs/fonts/custom.ttf'),
        isTrue,
      );
      expect(
        isAssociatedBackupArchivePath('UserConfigs/document_layouts/a.json'),
        isTrue,
      );
      expect(isAssociatedBackupArchivePath('UserConfigs/notes.txt'), isTrue);
      expect(isAssociatedBackupArchivePath('UserConfigs/legacy.db'), isFalse);
      expect(isAssociatedBackupArchivePath('backup/old.sqlite3'), isFalse);
      expect(isAssociatedBackupArchivePath('other/random.txt'), isFalse);
    });
  });

  test('full backups sweep the whole managed directories', () {
    final root = path.join('documents', 'nahpu');

    // The two roots subsume personnel, template media, fonts, and maps, so
    // files the database no longer points at still reach the archive.
    expect(globalBackupDirectoryPaths(root), [
      path.join(root, userConfigDirName),
      path.join(root, appMediaDirName),
    ]);
  });

  test('full backups sweep every project directory', () {
    final root = path.join('documents', 'nahpu');

    expect(projectBackupDirectoryPaths(root, const ['uuid-a', 'uuid-b']), [
      path.join(root, 'uuid-a', mediaDir),
      path.join(root, 'uuid-a', associatedDataDir),
      path.join(root, 'uuid-b', mediaDir),
      path.join(root, 'uuid-b', associatedDataDir),
    ]);
  });

  group('hasIdenticalFileContent', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('db_writer_test');
    });

    tearDown(() async {
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });

    File write(String name, List<int> bytes) {
      final file = File(path.join(tempDir.path, name));
      file.writeAsBytesSync(bytes);
      return file;
    }

    test('is false when the target does not exist', () async {
      final source = write('source.bin', [1, 2, 3]);
      final target = File(path.join(tempDir.path, 'missing.bin'));

      expect(await hasIdenticalFileContent(source, target), isFalse);
    });

    test('is false when the lengths differ', () async {
      final source = write('source.bin', [1, 2, 3]);
      final target = write('target.bin', [1, 2]);

      expect(await hasIdenticalFileContent(source, target), isFalse);
    });

    test('is false when the bytes differ at the same length', () async {
      final source = write('source.bin', List.filled(64 * 1024, 7));
      final target = write('target.bin', [...List.filled(64 * 1024 - 1, 7), 8]);

      expect(await hasIdenticalFileContent(source, target), isFalse);
    });

    test('is true for byte-identical files', () async {
      final bytes = List<int>.generate(96 * 1024, (index) => index % 256);
      final source = write('source.bin', bytes);
      final target = write('target.bin', bytes);

      expect(await hasIdenticalFileContent(source, target), isTrue);
    });

    test('is true for two empty files', () async {
      final source = write('source.bin', const []);
      final target = write('target.bin', const []);

      expect(await hasIdenticalFileContent(source, target), isTrue);
    });
  });
}
