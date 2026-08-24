import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/templates/editor_service.dart';
import 'package:nahpu/services/templates/image_service.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory appDocumentsDirectory;
  late FilePickerPlatform previousPicker;
  late _FakeFilePickerPlatform picker;

  setUp(() {
    appDocumentsDirectory = Directory.systemTemp.createTempSync(
      'nahpu-file-picker-test',
    );
    previousPicker = FilePickerPlatform.instance;
    picker = _FakeFilePickerPlatform();
    FilePickerPlatform.instance = picker;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return appDocumentsDirectory.path;
          }
          return null;
        });
  });

  tearDown(() async {
    FilePickerPlatform.instance = previousPicker;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (appDocumentsDirectory.existsSync()) {
      await appDocumentsDirectory.delete(recursive: true);
    }
  });

  test(
    'single-file services return null when the picker is canceled',
    () async {
      final services = FilePickerServices();

      expect(await services.selectAnyFile(), isNull);
      expect(await services.selectJsonFile(), isNull);
      expect(await services.selectRecordFile(), isNull);
      expect(await services.selectUserConfigFile(), isNull);
    },
  );

  test('single-file services preserve filters and return XFiles', () async {
    final selectedPath = '${appDocumentsDirectory.path}/record.json';
    picker.result = _FakePlatformFile(selectedPath);
    final services = FilePickerServices();

    final anyFile = await services.selectAnyFile();
    expect(anyFile?.path, selectedPath);
    expect(picker.lastType, FileType.any);
    expect(picker.lastAllowedExtensions, isNull);

    final jsonFile = await services.selectJsonFile();
    expect(jsonFile?.path, selectedPath);
    expect(picker.lastType, FileType.custom);
    expect(picker.lastAllowedExtensions, ['json']);

    final recordFile = await services.selectRecordFile();
    expect(recordFile?.path, selectedPath);
    expect(picker.lastAllowedExtensions, ['json', 'zip', 'gz']);

    final configFile = await services.selectUserConfigFile();
    expect(configFile?.path, selectedPath);
    expect(picker.lastAllowedExtensions, ['json', 'gz']);
  });

  test('template logo import copies the selected local file', () async {
    final source = File('${appDocumentsDirectory.path}/logo.jpg')
      ..writeAsBytesSync([1, 2, 3]);
    picker.result = _FakePlatformFile(source.path);

    final copiedPath = await TemplateEditorService().copyPickedImageToLogos();

    expect(copiedPath, isNotNull);
    expect(copiedPath, endsWith('.jpg'));
    expect(
      path.dirname(copiedPath!),
      path.join(
        appDocumentsDirectory.path,
        nahpuAppDir,
        appMediaDirName,
        templateMediaDirName,
      ),
    );
    expect(File(copiedPath).readAsBytesSync(), [1, 2, 3]);
  });

  test('template media preserves names and suffixes collisions', () async {
    final source = File('${appDocumentsDirectory.path}/logo.jpg')
      ..writeAsBytesSync([1, 2, 3]);
    picker.result = _FakePlatformFile(source.path);

    final first = await TemplateEditorService().copyPickedImageToLogos();
    final second = await TemplateEditorService().copyPickedImageToLogos();
    final listed = await const TemplateImageService().listLogoPaths();

    expect(path.basename(first!), 'logo.jpg');
    expect(path.basename(second!), 'logo_1.jpg');
    expect(listed, [first, second]);
    expect(
      Directory(
        path.join(appDocumentsDirectory.path, 'template_images'),
      ).existsSync(),
      isFalse,
    );
  });

  test(
    'template logo import returns null when the picker is canceled',
    () async {
      expect(await TemplateEditorService().copyPickedImageToLogos(), isNull);
    },
  );
}

final class _FakeFilePickerPlatform extends FilePickerPlatform {
  PlatformFile? result;
  FileType? lastType;
  List<String>? lastAllowedExtensions;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    lastType = type;
    lastAllowedExtensions = allowedExtensions;
    return result;
  }
}

base class _FakePlatformFile extends PlatformFile {
  _FakePlatformFile(this._path);

  final String _path;

  @override
  String get name => _path.split('/').last;

  @override
  Uri get uri => Uri.file(_path);

  @override
  XFile get xFile => XFile(_path);

  @override
  Future<int> length() async => 0;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);

  @override
  Stream<Uint8List> readAsByteStream() => const Stream.empty();
}
