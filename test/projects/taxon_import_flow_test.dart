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
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/src/rust/frb_generated.dart';

void main() => taxonImportFlowTests();

void taxonImportFlowTests({bool useAppLibrary = false}) {
  setUpAll(() async {
    if (useAppLibrary) {
      await RustLib.init();
    } else {
      final libraryPath = Platform.isMacOS
          ? 'rust/target/debug/librust_lib_nahpu.dylib'
          : Platform.isWindows
          ? 'rust/target/debug/rust_lib_nahpu.dll'
          : 'rust/target/debug/librust_lib_nahpu.so';
      await RustLib.init(externalLibrary: ExternalLibrary.open(libraryPath));
    }
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
    final file = File('${directory.path}/taxa.csv')
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
}

Future<void> _chooseFile(WidgetTester tester) async {
  final field = tester.widget<SelectFileField>(find.byType(SelectFileField));
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
  final String path;

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
  }) async => _TaxonPlatformFile(path);
}

base class _TaxonPlatformFile extends PlatformFile {
  _TaxonPlatformFile(this.path);
  @override
  final String path;

  @override
  String get name => path.split('/').last;
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
