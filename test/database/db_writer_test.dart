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
      expect(isAssociatedBackupArchivePath('backup/old.sqlite3'), isFalse);
      expect(isAssociatedBackupArchivePath('other/random.txt'), isFalse);
    });
  });

  test('global template media is collected by full backups', () {
    expect(
      globalBackupDirectoryPaths('/documents/nahpu'),
      contains(
        path.join('/documents/nahpu', appMediaDirName, templateMediaDirName),
      ),
    );
  });
}
