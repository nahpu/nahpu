import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late FilePickerPlatform previousPicker;
  late _FakeSavePickerPlatform picker;

  setUp(() {
    root = Directory.systemTemp.createTempSync('nahpu-save-copy-');
    previousPicker = FilePickerPlatform.instance;
    picker = _FakeSavePickerPlatform();
    FilePickerPlatform.instance = picker;
  });

  tearDown(() async {
    FilePickerPlatform.instance = previousPicker;
    if (root.existsSync()) await root.delete(recursive: true);
  });

  File write(String name, {int bytes = 3}) =>
      File(p.join(root.path, name))..writeAsBytesSync(List.filled(bytes, 0));

  /// A file of [length] bytes that costs no disk on a sparse filesystem, so
  /// the 100 MB boundary can be checked without writing 100 MB.
  File sparse(String name, int length) {
    final file = File(p.join(root.path, name));
    final handle = file.openSync(mode: FileMode.write);
    handle.setPositionSync(length - 1);
    handle.writeByteSync(0);
    handle.closeSync();
    return file;
  }

  test('save a copy passes the file name, bytes and a derived type', () async {
    final source = write('records-2026-09-15.csv');
    picker.result = Uri.file('/chosen/records.csv');

    final saved = await FilePickerServices().saveCopyToDevice(source);

    expect(saved, isTrue);
    expect(picker.lastFileName, 'records-2026-09-15.csv');
    expect(picker.lastMimeType, 'text/csv');
    expect(picker.lastBytes, source.readAsBytesSync());
  });

  test('save a copy falls back to a generic type for unknown files', () async {
    picker.result = Uri.file('/chosen/bundle.nahpu');

    await FilePickerServices().saveCopyToDevice(write('bundle.nahpu'));

    expect(picker.lastMimeType, 'application/octet-stream');
  });

  test('save a copy reports false when the dialog is canceled', () async {
    expect(
      await FilePickerServices().saveCopyToDevice(write('a.csv')),
      isFalse,
    );
  });

  test('the size limit is a hard boundary', () async {
    final services = FilePickerServices();
    const limit = FilePickerServices.maxSaveCopyBytes;

    expect(services.canSaveCopyOf(sparse('at-limit.bin', limit)), isTrue);
    expect(services.canSaveCopyOf(sparse('over.bin', limit + 1)), isFalse);
  });

  test('a file that is not there cannot be saved as a copy', () async {
    final missing = write('gone.csv')..deleteSync();

    expect(FilePickerServices().canSaveCopyOf(missing), isFalse);
  });
}

final class _FakeSavePickerPlatform extends FilePickerPlatform {
  Uri? result;
  String? lastFileName;
  String? lastMimeType;
  Uint8List? lastBytes;

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    lastFileName = fileName;
    lastMimeType = mimeType;
    lastBytes = bytes;
    return result;
  }
}
