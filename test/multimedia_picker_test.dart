import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/file_format.dart';

void main() {
  test('pickMultiFiles accepts iOS-safe media type groups', () async {
    List<XTypeGroup>? lastAcceptedTypeGroups;

    final selected = await FilePickerServices(
      openFiles: ({
        List<XTypeGroup>? acceptedTypeGroups,
        String? initialDirectory,
        String? confirmButtonText,
      }) async {
        lastAcceptedTypeGroups = acceptedTypeGroups;
        return [
          XFile('/tmp/voice.mp3'),
          XFile('/tmp/clip.mp4'),
        ];
      },
    ).pickMultiFiles([mediaFmt]);

    expect(selected, hasLength(2));
    expect(lastAcceptedTypeGroups, isNotNull);
    expect(lastAcceptedTypeGroups, hasLength(1));
    expect(
      lastAcceptedTypeGroups!.single.extensions,
      containsAll(['jpg', 'mp3', 'mp4']),
    );
    for (final group in lastAcceptedTypeGroups!) {
      expect(
        group.allowsAny ||
            ((group.uniformTypeIdentifiers?.isNotEmpty ?? false) == true),
        isTrue,
      );
    }
  });

  test('validateSupportedMediaPaths rejects unsupported selections', () {
    expect(
      () => ImageServices.validateSupportedMediaPaths([
        '/tmp/photo.jpg',
        '/tmp/notes.txt',
      ]),
      throwsA(
        isA<UnsupportedMediaFileException>()
            .having(
              (error) => error.paths,
              'paths',
              contains('/tmp/notes.txt'),
            )
            .having(
              (error) => error.toString(),
              'message',
              allOf(
                contains('Unsupported media file'),
                contains('notes.txt'),
              ),
            ),
      ),
    );

    expect(
      () => ImageServices.validateSupportedMediaPaths([
        '/tmp/photo.jpg',
        '/tmp/voice.mp3',
        '/tmp/clip.mp4',
      ]),
      returnsNormally,
    );
  });
}
