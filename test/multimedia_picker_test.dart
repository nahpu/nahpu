import 'package:file_selector/file_selector.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/file_format.dart';

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

    final selected = await FilePickerServices().pickMultiFiles(mediaFmt);

    expect(selected, hasLength(3));
    expect(fakePlatform.lastAcceptedTypeGroups, isNotNull);
    expect(fakePlatform.lastAcceptedTypeGroups, hasLength(mediaFmt.length));
    for (final group in fakePlatform.lastAcceptedTypeGroups!) {
      expect(
        group.allowsAny ||
            ((group.uniformTypeIdentifiers?.isNotEmpty ?? false) == true),
        isTrue,
      );
    }
  });
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
