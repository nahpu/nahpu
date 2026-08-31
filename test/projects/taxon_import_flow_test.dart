import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/taxonomy/add_taxon.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:path/path.dart' as p;

import '../helpers/taxon_camera.dart';

void main() => taxonImportFlowTests();

void taxonImportFlowTests({bool useAppLibrary = false}) {
  setUpAll(() async {
    if (useAppLibrary) {
      await RustLib.init();
    } else {
      final libraryName = Platform.isMacOS
          ? 'librust_lib_nahpu.dylib'
          : Platform.isWindows
          ? 'rust_lib_nahpu.dll'
          : 'librust_lib_nahpu.so';
      final libraryPath = p.join('rust', 'target', 'debug', libraryName);
      await RustLib.init(externalLibrary: ExternalLibrary.open(libraryPath));
    }
  });

  test('picker preserves native paths and file names', () {
    final filePath = p.join(
      Directory.systemTemp.path,
      'nahpu-taxon-flow',
      'taxa.csv',
    );
    final file = _TaxonPlatformFile(filePath);

    expect(file.path, filePath);
    expect(file.name, 'taxa.csv');
    expect(file.xFile.name, 'taxa.csv');
    expect(file.uri.toFilePath(), filePath);
  });

  testWidgets('table import requires class selection and resets stale reviews', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final directory = Directory.systemTemp.createTempSync('nahpu-taxon-flow-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File(p.join(directory.path, 'taxa.csv'))
      ..writeAsStringSync(
        'Order,Family,Genus,Specific epithet\nRodentia,Muridae,Rattus,rattus\n',
      );
    final previousPicker = FilePickerPlatform.instance;
    FilePickerPlatform.instance = _TaxonFilePicker(file.path);
    addTearDown(() => FilePickerPlatform.instance = previousPicker);
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AddTaxon()),
                ),
                child: const Text('Open taxonomy'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open taxonomy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    await _chooseFile(tester);

    final selector = find.byKey(const ValueKey('taxon-import-class-selection'));
    await _scrollTo(tester, selector, 350);
    expect(
      tester.widget<DropdownButton<InferableTaxonClass>>(selector).value,
      isNull,
    );
    final reviewButton = find.widgetWithText(PrimaryButton, 'Review taxa');
    await _scrollTo(tester, reviewButton, 350);
    expect(tester.widget<PrimaryButton>(reviewButton).onPressed, isNull);
    expect(await database.select(database.taxonomy).get(), isEmpty);

    await _scrollTo(tester, selector, -350);
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mammalia').last);
    await tester.pumpAndSettle();
    await _scrollTo(tester, reviewButton, 350);
    await _runButton(tester, reviewButton);
    expect(find.text('Rattus rattus'), findsOneWidget);
    expect(find.text('Species · Mammalia · Muridae'), findsOneWidget);
    expect(find.text('Import 1 selected'), findsOneWidget);
    expect(await database.select(database.taxonomy).get(), isEmpty);

    await tester.tap(find.text('Setup'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, selector, -350);
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aves').last);
    await tester.pumpAndSettle();
    expect(find.text('Import 0 selected'), findsOneWidget);
    expect(
      tester
          .widget<PrimaryButton>(
            find.widgetWithText(PrimaryButton, 'Import 0 selected'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mammalia').last);
    await tester.pumpAndSettle();
    await _scrollTo(tester, reviewButton, 350);
    await _runButton(tester, reviewButton);
    await _runButton(
      tester,
      find.widgetWithText(PrimaryButton, 'Import 1 selected'),
    );
    expect(find.text('Open taxonomy'), findsOneWidget);
    final imported = await database.select(database.taxonomy).getSingle();
    expect(imported.taxonRank, 'species');
    expect(imported.kingdom, 'Animalia');
    expect(imported.phylum, 'Chordata');
    expect(imported.taxonClass, 'Mammalia');

    // A new import must ask again rather than reuse the previous class.
    await tester.tap(find.text('Open taxonomy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    await _chooseFile(tester);
    await _scrollTo(tester, selector, 350);
    expect(
      tester.widget<DropdownButton<InferableTaxonClass>>(selector).value,
      isNull,
    );
    expect(find.text('Import 0 selected'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('QR and file sources replace each other only after selection', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final directory = Directory.systemTemp.createTempSync(
      'nahpu-taxon-sources-',
    );
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File(p.join(directory.path, 'taxa.csv'))
      ..writeAsStringSync('Taxon rank,Class\nclass,Mammalia\n');
    final previousPicker = FilePickerPlatform.instance;
    final picker = _TaxonFilePicker(file.path);
    FilePickerPlatform.instance = picker;
    addTearDown(() => FilePickerPlatform.instance = previousPicker);
    final previousCamera = MobileScannerPlatform.instance;
    final camera = FakeTaxonCamera();
    MobileScannerPlatform.instance = camera;
    addTearDown(() async {
      MobileScannerPlatform.instance = previousCamera;
      await camera.captures.close();
    });
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: AddTaxon()),
      ),
    );
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    await _chooseFile(tester);
    expect(find.text('Parsing details'), findsNothing);
    await tester.tap(find.text('Advanced options'));
    await tester.pumpAndSettle();
    expect(find.text('Parsing details'), findsOneWidget);
    await tester.tap(find.text('Hide advanced options'));
    await tester.pumpAndSettle();
    expect(find.text('Parsing details'), findsNothing);
    await _runButton(tester, find.widgetWithText(PrimaryButton, 'Review taxa'));
    expect(find.text('Mammalia'), findsOneWidget);
    expect(find.text('Import 1 selected'), findsOneWidget);

    // Cancel the mode dialog and then an actual scan session.
    await tester.tap(find.text('Scan QR'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Single taxon'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Mammalia'), findsOneWidget);
    await tester.tap(find.text('Scan QR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Multiple taxa'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Mammalia'), findsOneWidget);
    expect(find.text('taxa.csv'), findsOneWidget);

    await tester.tap(find.text('Scan QR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Single taxon'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      camera.captures.add(
        BarcodeCapture(
          barcodes: [
            const Barcode(
              format: BarcodeFormat.qrCode,
              rawValue: '{"nahpu_taxon":1,"taxon":{"genus":"Rattus"}}',
            ),
          ],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(find.text('Rattus'), findsOneWidget);
    expect(find.text('Mammalia'), findsNothing);
    expect(find.text('taxa.csv'), findsNothing);
    expect(find.text('Map columns'), findsNothing);
    expect(find.text('Advanced options'), findsNothing);
    picker.path = null;
    await _chooseFile(tester);
    expect(find.text('Rattus'), findsOneWidget);
    expect(find.text('Import 1 selected'), findsOneWidget);
    picker.path = file.path;
    await _chooseFile(tester);
    expect(find.text('Rattus'), findsNothing);
    expect(find.text('taxa.csv'), findsOneWidget);
    expect(find.text('Map columns'), findsOneWidget);
    expect(find.text('Import 0 selected'), findsOneWidget);
    expect(await database.select(database.taxonomy).get(), isEmpty);
    // Failed parsing opens recovery options automatically.
    file.writeAsStringSync('');
    await _chooseFile(tester);
    expect(find.text('Parsing error'), findsOneWidget);
    expect(find.text('Hide advanced options'), findsOneWidget);
    expect(find.text('Retry parse'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}

Future<void> _chooseFile(WidgetTester tester) async {
  final field = tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, 'Select file'),
  );
  await tester.runAsync(field.onPressed as Future<void> Function());
  await tester.pumpAndSettle();
}

Future<void> _runButton(WidgetTester tester, Finder finder) async {
  final button = tester.widget<PrimaryButton>(finder);
  expect(button.onPressed, isNotNull);
  await tester.runAsync(button.onPressed as Future<void> Function());
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder, double delta) async {
  final setup = find.byKey(const ValueKey('taxon-import-setup'));
  tester.widget<ListView>(setup).controller!.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(
    finder,
    delta.abs(),
    scrollable: find.descendant(of: setup, matching: find.byType(Scrollable)),
  );
  await tester.pumpAndSettle();
}

final class _TaxonFilePicker extends FilePickerPlatform {
  _TaxonFilePicker(this.path);
  String? path;

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
  }) async => path == null ? null : _TaxonPlatformFile(path!);
}

base class _TaxonPlatformFile extends PlatformFile {
  _TaxonPlatformFile(this.path);
  @override
  final String path;

  @override
  String get name => p.basename(path);
  @override
  Uri get uri => Uri.file(path);
  @override
  XFile get xFile => XFile(path);
  @override
  Future<int> length() => File(path).length();
  @override
  Future<Uint8List> readAsBytes() => File(path).readAsBytes();
  @override
  Stream<Uint8List> readAsByteStream() =>
      File(path).openRead().map(Uint8List.fromList);
}
