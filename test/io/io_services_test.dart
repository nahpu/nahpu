import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  late Directory tempAppDir;
  late Database db;

  test('formats and appends a zero-padded file date suffix', () {
    final date = DateTime(2026, 1, 5);

    expect(formatFileDateSuffix(date), '-2026-01-05');
    expect(appendDateToFileStem('backup', date), 'backup-2026-01-05');
    expect(
      appendDateToFileStem('backup-2026-01-05', date),
      'backup-2026-01-05',
    );
  });

  setUp(() {
    tempAppDir = Directory.systemTemp.createTempSync('nahpu-io-services-test');
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
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await db.close();
    if (tempAppDir.existsSync()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  testWidgets('copyFileToProjectDir keeps duplicate basenames', (tester) async {
    const projectUuid = 'project-copy-test';
    final ref = await _buildRef(tester, db, projectUuid: projectUuid);
    final sourceRoot = Directory.systemTemp.createTempSync(
      'nahpu-io-services-src',
    );
    addTearDown(() {
      if (sourceRoot.existsSync()) {
        sourceRoot.deleteSync(recursive: true);
      }
    });
    final sources = _writeDuplicateSources(sourceRoot, 'sample.jpg', [
      [1],
      [2],
      [3],
    ]);

    final copied = await tester.runAsync<List<File>>(() async {
      final service = FileServices(ref: ref);
      return [
        await service.copyFileToProjectDir(sources[0], Directory('media/site')),
        await service.copyFileToProjectDir(sources[1], Directory('media/site')),
        await service.copyFileToProjectDir(sources[2], Directory('media/site')),
      ];
    });
    final copiedFiles = copied!;

    expect(copiedFiles.map((file) => path.basename(file.path)), [
      'sample.jpg',
      'sample_1.jpg',
      'sample_2.jpg',
    ]);
    expect(copiedFiles[0].readAsBytesSync(), [1]);
    expect(copiedFiles[1].readAsBytesSync(), [2]);
    expect(copiedFiles[2].readAsBytesSync(), [3]);
  });

  testWidgets('copyFileToAppDir keeps duplicate basenames', (tester) async {
    final ref = await _buildRef(tester, db);
    final sourceRoot = Directory.systemTemp.createTempSync(
      'nahpu-io-services-src',
    );
    addTearDown(() {
      if (sourceRoot.existsSync()) {
        sourceRoot.deleteSync(recursive: true);
      }
    });
    final sources = _writeDuplicateSources(sourceRoot, 'avatar.png', [
      [4],
      [5],
    ]);

    final copied = await tester.runAsync<List<File>>(() async {
      final service = FileServices(ref: ref);
      return [
        await service.copyFileToAppDir(sources[0], Directory('appMedia')),
        await service.copyFileToAppDir(sources[1], Directory('appMedia')),
      ];
    });
    final copiedFiles = copied!;

    expect(copiedFiles.map((file) => path.basename(file.path)), [
      'avatar.png',
      'avatar_1.png',
    ]);
    expect(copiedFiles[0].readAsBytesSync(), [4]);
    expect(copiedFiles[1].readAsBytesSync(), [5]);
  });

  testWidgets('fileList marks database formats as non-deletable', (
    tester,
  ) async {
    final ref = await _buildRef(tester, db);
    final nahpuDir = Directory(path.join(tempAppDir.path, nahpuAppDir))
      ..createSync(recursive: true);
    final dbFile = File(path.join(nahpuDir.path, 'main.db'));
    final sqliteFile = File(path.join(nahpuDir.path, 'backup.sqlite3'));
    dbFile.writeAsBytesSync([1]);
    sqliteFile.writeAsBytesSync([2]);

    final files = await tester.runAsync<List<NahpuFile>>(() {
      return DataUsageServices(ref: ref).fileList;
    });
    final byName = {
      for (final file in files!) path.basename(file.path.path): file,
    };

    expect(byName['main.db']?.isDeletable, isFalse);
    expect(byName['backup.sqlite3']?.isDeletable, isFalse);
  });

  group('Directory Paths Verification', () {
    testWidgets('nahpuDocumentDir path is correct', (tester) async {
      final dir = await tester.runAsync(() => nahpuDocumentDir);
      expect(dir!.path, path.join(tempAppDir.path, 'nahpu'));
    });

    testWidgets('backupDir path is correct', (tester) async {
      final ref = await _buildRef(tester, db);
      final file = await tester.runAsync(() => AppServices(ref: ref).backupDir);
      final backupFile = file!;
      expect(
        backupFile.parent.path,
        path.join(tempAppDir.path, 'nahpu', 'backup'),
      );
      expect(path.basename(backupFile.path), startsWith('nahpu_backup'));
      expect(path.extension(backupFile.path), '.sqlite3');
    });

    testWidgets('tempDirectory path is correct', (tester) async {
      final ref = await _buildRef(tester, db);
      final dir = await tester.runAsync(
        () => AppServices(ref: ref).tempDirectory,
      );
      expect(dir!.path, path.join(Directory.systemTemp.path, 'NahpuTemp'));
    });

    testWidgets('getMediaDir paths are correct', (tester) async {
      final ref = await _buildRef(tester, db);
      final services = AppServices(ref: ref);
      expect(services.getMediaDir(MediaCategory.site).path, 'media/site');
      expect(
        services.getMediaDir(MediaCategory.specimen).path,
        'media/specimen',
      );
      expect(
        services.getMediaDir(MediaCategory.narrative).path,
        'media/narrative',
      );
      expect(
        services.getMediaDir(MediaCategory.personnel).path,
        'appMedia/personnel',
      );
    });

    testWidgets('userConfigDir and userFontDir paths are correct', (
      tester,
    ) async {
      final ref = await _buildRef(tester, db);
      final services = AppServices(ref: ref);
      final directories = await tester.runAsync(() async {
        return (
          userConfig: await services.userConfigDir,
          userFont: await services.userFontDir,
          userMap: await services.userMapDir,
        );
      });
      expect(
        directories!.userConfig.path,
        path.join(tempAppDir.path, 'nahpu', 'UserConfigs'),
      );
      expect(
        directories.userFont.path,
        path.join(tempAppDir.path, 'nahpu', 'UserConfigs', 'fonts'),
      );
      expect(
        directories.userMap.path,
        path.join(tempAppDir.path, 'nahpu', 'UserConfigs', 'maps'),
      );
    });
  });
}

Future<WidgetRef> _buildRef(
  WidgetTester tester,
  Database db, {
  String projectUuid = '',
}) async {
  WidgetRef? widgetRef;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, child) {
            widgetRef = ref;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );

  await tester.pump();
  widgetRef!.read(projectUuidProvider.notifier).updateProjectUuid(projectUuid);
  return widgetRef!;
}

List<File> _writeDuplicateSources(
  Directory sourceRoot,
  String fileName,
  List<List<int>> byteSets,
) {
  final files = <File>[];
  for (int i = 0; i < byteSets.length; i++) {
    final sourceDir = Directory(path.join(sourceRoot.path, 'source_$i'));
    sourceDir.createSync(recursive: true);
    final file = File(path.join(sourceDir.path, fileName));
    file.writeAsBytesSync(byteSets[i]);
    files.add(file);
  }
  return files;
}
