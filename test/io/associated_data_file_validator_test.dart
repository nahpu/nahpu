import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/associated_data/associated_data_services.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDirectory;

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'nahpu-associated-data-validator',
    );
  });

  tearDown(() {
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test('rejects supported media by extension', () async {
    final file = File(path.join(tempDirectory.path, 'recording.mp3'))
      ..writeAsBytesSync([0, 1, 2]);

    await expectLater(
      const AssociatedDataFileValidator().validate(file),
      throwsA(
        isA<AssociatedDataMediaFileException>().having(
          (error) => error.toString(),
          'message',
          associatedDataMediaFileMessage,
        ),
      ),
    );
  });

  test('rejects disguised supported media by file signature', () async {
    final file = File(path.join(tempDirectory.path, 'notes.dat'))
      ..writeAsBytesSync([137, 80, 78, 71, 13, 10, 26, 10]);

    await expectLater(
      const AssociatedDataFileValidator().validate(file),
      throwsA(isA<AssociatedDataMediaFileException>()),
    );
  });

  test('accepts non-media files', () async {
    final file = File(path.join(tempDirectory.path, 'notes.pdf'))
      ..writeAsBytesSync('%PDF-1.7'.codeUnits);

    await const AssociatedDataFileValidator().validate(file);
  });
}
