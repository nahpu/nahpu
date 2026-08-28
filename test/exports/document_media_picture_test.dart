import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  const projectUuid = 'picture-project';
  late Directory documentsDir;
  late Database db;

  setUp(() async {
    documentsDir = Directory.systemTemp.createTempSync(
      'nahpu-document-media-picture',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return documentsDir.path;
          }
          return null;
        });
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await db
        .into(db.project)
        .insert(ProjectCompanion.insert(uuid: projectUuid, name: 'Pictures'));
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await db.close();
    if (documentsDir.existsSync()) {
      documentsDir.deleteSync(recursive: true);
    }
  });

  testWidgets('document media values keep metadata and only resolve images', (
    tester,
  ) async {
    final mediaDirectory = Directory(
      path.join(
        documentsDir.path,
        nahpuAppDir,
        projectUuid,
        mediaDir,
        'specimen',
      ),
    )..createSync(recursive: true);
    final pngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final firstImage = File(path.join(mediaDirectory.path, 'first.png'))
      ..writeAsBytesSync(pngBytes);
    final audio = File(path.join(mediaDirectory.path, 'recording.mp3'))
      ..writeAsBytesSync([0x49, 0x44, 0x33, 0x04]);
    final secondImage = File(path.join(mediaDirectory.path, 'second.jpg'))
      ..writeAsBytesSync(pngBytes);

    final firstId = await db
        .into(db.media)
        .insert(
          MediaCompanion.insert(
            projectUuid: const Value(projectUuid),
            category: const Value('specimen'),
            fileName: Value(path.basename(firstImage.path)),
          ),
        );
    final audioId = await db
        .into(db.media)
        .insert(
          MediaCompanion.insert(
            projectUuid: const Value(projectUuid),
            category: const Value('specimen'),
            fileName: Value(path.basename(audio.path)),
          ),
        );
    final secondId = await db
        .into(db.media)
        .insert(
          MediaCompanion.insert(
            projectUuid: const Value(projectUuid),
            category: const Value('specimen'),
            fileName: Value(path.basename(secondImage.path)),
          ),
        );

    late WidgetRef widgetRef;
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

    final values = await tester.runAsync(
      () => DocumentWriter.mediaValuesForTesting(
        ref: widgetRef,
        mediaIds: [secondId, audioId, firstId],
      ),
    );
    final resolved = resolveTemplatePicturePaths('[media::media]', values!);

    expect(resolved, [firstImage.path, secondImage.path]);
    expect(values[kTemplateMediaField], contains('first.png'));
    expect(values[kTemplateMediaField], contains('recording.mp3'));
    expect(values[kTemplateMediaField], contains('second.jpg'));
  });
}
