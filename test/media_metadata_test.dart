import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/utility_services.dart';

void main() {
  const metadataService = MediaMetadataServices();

  test('extract falls back to file metadata for audio', () async {
    final file = await _createTempFile('voice.mp3', [1, 2, 3]);
    addTearDown(() async => _safeDelete(file));

    final metadata = await metadataService.extract(file);

    expect(metadata.taken, isEmpty);
    expect(metadata.camera, isEmpty);
    expect(metadata.lenses, isEmpty);
    expect(metadata.additionalExif, contains('Type: Audio'));
    expect(metadata.additionalExif, contains('Format: MP3'));
    expect(metadata.additionalExif, contains('Size: '));
    expect(metadata.additionalExif, contains('Modified: '));
  });

  test('extract falls back to file metadata for video', () async {
    final file = await _createTempFile('clip.mp4', [10, 11, 12, 13]);
    addTearDown(() async => _safeDelete(file));

    final metadata = await metadataService.extract(file);

    expect(metadata.taken, isEmpty);
    expect(metadata.camera, isEmpty);
    expect(metadata.lenses, isEmpty);
    expect(metadata.additionalExif, contains('Type: Video'));
    expect(metadata.additionalExif, contains('Format: MP4'));
    expect(metadata.additionalExif, contains('Size: '));
    expect(metadata.additionalExif, contains('Modified: '));
  });

  test('extract falls back to file metadata for pdf', () async {
    final file = await _createTempFile('doc.pdf', [20, 21, 22, 23]);
    addTearDown(() async => _safeDelete(file));

    final metadata = await metadataService.extract(file);

    expect(metadata.taken, isEmpty);
    expect(metadata.camera, isEmpty);
    expect(metadata.lenses, isEmpty);
    expect(metadata.additionalExif, contains('Type: Other'));
    expect(metadata.additionalExif, contains('Format: PDF'));
    expect(metadata.additionalExif, contains('Size: '));
    expect(metadata.additionalExif, contains('Modified: '));
  });

  test('formatAdditionalMetadataForExport removes UI separators and newlines',
      () {
    final rawMetadata = 'Type: Audio${listTileSeparator}Format: MP3\nSize: 3 B';

    expect(
      metadataService.formatAdditionalMetadataForExport(rawMetadata),
      'Type: Audio Format: MP3 Size: 3 B',
    );
    expect(metadataService.formatAdditionalMetadataForExport(null), isEmpty);
    expect(metadataService.formatAdditionalMetadataForExport(''), isEmpty);
  });
}

Future<File> _createTempFile(String name, List<int> bytes) async {
  final dir =
      await Directory.systemTemp.createTemp('nahpu-media-metadata-test');
  final file = File('${dir.path}${Platform.pathSeparator}$name');
  await file.writeAsBytes(bytes);
  return file;
}

Future<void> _safeDelete(File file) async {
  final dir = file.parent;
  if (dir.existsSync()) {
    await dir.delete(recursive: true);
  }
}
