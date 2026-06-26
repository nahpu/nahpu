import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/services/types/import.dart';

void main() {
  late FileSelectorPlatform previousPlatform;
  late FakeFileSelectorPlatform fakePlatform;

  setUp(() {
    previousPlatform = FileSelectorPlatform.instance;
    fakePlatform = FakeFileSelectorPlatform();
    FileSelectorPlatform.instance = fakePlatform;
  });

  tearDown(() {
    FileSelectorPlatform.instance = previousPlatform;
  });

  test('pickMultiFiles accepts iOS-safe media type groups', () async {
    fakePlatform.filesToReturn = [
      XFile('/tmp/voice.mp3'),
      XFile('/tmp/clip.mp4'),
      XFile('/tmp/doc.pdf'),
    ];

    final selected = await FilePickerServices().pickMultiFiles([mediaFmt]);

    expect(selected, hasLength(3));
    expect(fakePlatform.lastAcceptedTypeGroups, isNotNull);
    expect(fakePlatform.lastAcceptedTypeGroups, hasLength(1));
    for (final group in fakePlatform.lastAcceptedTypeGroups!) {
      expect(
        group.allowsAny ||
            ((group.uniformTypeIdentifiers?.isNotEmpty ?? false) == true),
        isTrue,
      );
    }
  });

  test('pickMediaFromFiles rejects unsupported selections before copying',
      () async {
    fakePlatform.filesToReturn = [
      XFile('/tmp/photo.jpg'),
      XFile('/tmp/notes.txt'),
    ];

    await expectLater(
      ImageServices(
        ref: FakeWidgetRef(),
        category: MediaCategory.site,
      ).pickMediaFromFiles(),
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

    expect(fakePlatform.lastAcceptedTypeGroups, hasLength(1));
    expect(
      fakePlatform.lastAcceptedTypeGroups!.single.extensions,
      containsAll(['jpg', 'mp3', 'mp4', 'pdf']),
    );
  });
}

class FakeWidgetRef implements WidgetRef {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnsupportedError('FakeWidgetRef should not be used');
  }
}

class FakeFileSelectorPlatform extends FileSelectorPlatform {
  List<XFile> filesToReturn = [];
  List<XTypeGroup>? lastAcceptedTypeGroups;

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    lastAcceptedTypeGroups = acceptedTypeGroups;

    for (final group in acceptedTypeGroups ?? <XTypeGroup>[]) {
      final hasIosSupportedFilter = group.allowsAny ||
          (group.uniformTypeIdentifiers?.isNotEmpty ?? false);
      if (!hasIosSupportedFilter) {
        throw ArgumentError(
          'The provided type group should either allow all files, '
          'or have a non-empty "uniformTypeIdentifiers"',
        );
      }
    }
    return filesToReturn;
  }
}
