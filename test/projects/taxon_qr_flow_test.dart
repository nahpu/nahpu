import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/projects/taxonomy/add_taxon.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_qr_import.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';

import '../helpers/taxon_camera.dart';

void main() => taxonQrFlowTests();

void taxonQrFlowTests() => group('QR import', () {
  late FakeTaxonCamera camera;
  late Database database;
  late MobileScannerPlatform previousCamera;

  setUp(() {
    previousCamera = MobileScannerPlatform.instance;
    MobileScannerPlatform.instance = camera = FakeTaxonCamera();
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async {
    MobileScannerPlatform.instance = previousCamera;
    debugDefaultTargetPlatformOverride = null;
    await camera.captures.close();
    await database.close();
  });

  Future<void> open(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
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
  }

  Future<void> scanMode(WidgetTester tester, String mode) async {
    await tester.tap(find.text('Scan QR'));
    await tester.pumpAndSettle();
    expect(find.text('Single taxon'), findsOneWidget);
    expect(find.text('Multiple taxa'), findsOneWidget);
    await tester.tap(find.text(mode));
    await tester.pumpAndSettle();
  }

  Future<void> emit(WidgetTester tester, String payload) async {
    await tester.runAsync(() async {
      camera.captures.add(
        BarcodeCapture(
          barcodes: [Barcode(format: BarcodeFormat.qrCode, rawValue: payload)],
        ),
      );
      // Allow the real in-memory database query to complete.
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    });
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(390, 844), const Size(1280, 900)]) {
    testWidgets('QR batch preview, selection, and confirmation at $size', (
      tester,
    ) async {
      await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              taxonRank: Value('genus'),
              genus: Value('Rattus'),
              authors: Value('Original'),
            ),
          );
      await open(tester, size);
      expect(
        find.text('CSV (.csv), TSV (.tsv), Excel (.xlsx), NAHPU taxon QR'),
        findsOneWidget,
      );
      expect(find.text('Parsing details'), findsNothing);
      await scanMode(tester, 'Multiple taxa');
      expect(find.byType(ScannerCameraOverlay), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Done'))
            .onPressed,
        isNull,
      );
      await emit(tester, 'https://example.org');
      expect(find.textContaining('Not a valid NAHPU'), findsOneWidget);
      expect(camera.stops, 0);
      await emit(tester, _qr('Rattus'));
      expect(find.text('Already registered: Rattus'), findsOneWidget);
      expect(find.text('0 taxa ready'), findsOneWidget);
      await emit(tester, _qr('Bunomys'));
      await emit(tester, _qr('Bunomys'));
      expect(find.text('1 taxa ready'), findsOneWidget);
      await emit(tester, _qr(' RATTUS '));
      expect(find.text('Duplicate: RATTUS'), findsOneWidget);
      await emit(tester, _qr('Crocidura'));
      expect(find.text('2 taxa ready'), findsOneWidget);
      expect(find.byType(TaxonQrImportScreen), findsOneWidget);
      expect(await database.select(database.taxonomy).get(), hasLength(1));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(TaxonQrImportScreen), findsNothing);
      expect(camera.stops, 1);
      expect(find.text('Import 2 selected'), findsOneWidget);
      final existing = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Rattus'),
      );
      expect(existing.onChanged, isNull);
      expect(existing.value, isFalse);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Crocidura'));
      await tester.pumpAndSettle();
      expect(find.text('Import 1 selected'), findsOneWidget);
      if (size.width < 900) {
        await tester.tap(find.text('Setup'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Map columns'), findsNothing);
      expect(find.text('Advanced options'), findsNothing);
      expect(
        find.byKey(const ValueKey('taxon-import-class-selection')),
        findsNothing,
      );
      // Cancelling a new batch, including accepted scans, preserves the old selection.
      await scanMode(tester, 'Multiple taxa');
      await emit(tester, _qr('Mus'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Import 1 selected'), findsOneWidget);
      expect(await database.select(database.taxonomy).get(), hasLength(1));
      final importButton = tester.widget<PrimaryButton>(
        find.widgetWithText(PrimaryButton, 'Import 1 selected'),
      );
      await tester.runAsync(importButton.onPressed as Future<void> Function());
      await tester.pumpAndSettle();
      final rows = await database.select(database.taxonomy).get();
      expect(rows.map((r) => r.genus), ['Rattus', 'Bunomys']);
      expect(rows.first.authors, 'Original');
      expect(rows.last.taxonClass, isNull);
      expect(find.text('Open taxonomy'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
    'single QR returns after valid scan and replaces previous QR source',
    (tester) async {
      await open(tester, const Size(1280, 900));
      await scanMode(tester, 'Single taxon');
      await emit(tester, '{"nahpu_specimen":1}');
      expect(find.byType(TaxonQrImportScreen), findsOneWidget);
      await emit(tester, _qr('Bunomys'));
      expect(find.byType(TaxonQrImportScreen), findsNothing);
      expect(find.text('Bunomys'), findsOneWidget);
      await scanMode(tester, 'Single taxon');
      await emit(tester, _qr('Crocidura'));
      expect(find.text('Bunomys'), findsNothing);
      expect(find.text('Crocidura'), findsOneWidget);
      expect(find.text('Import 1 selected'), findsOneWidget);
      expect(await database.select(database.taxonomy).get(), isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'camera permission error supports retry and lifecycle stop/resume',
    (tester) async {
      camera.permissionDenied = true;
      await open(tester, const Size(390, 844));
      await scanMode(tester, 'Multiple taxa');
      expect(find.textContaining('Camera access is denied'), findsOneWidget);
      expect(find.byType(ScannerCameraOverlay), findsNothing);
      camera.permissionDenied = false;
      await tester.tap(find.text('Retry camera'));
      await tester.pumpAndSettle();
      expect(find.byType(ScannerCameraOverlay), findsOneWidget);
      expect(camera.starts, 2);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      expect(camera.stops, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(camera.starts, 3);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(camera.stops, 2);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('unsupported platforms disable scanning with an explanation', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    await open(tester, const Size(1280, 900));
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Scan QR'),
          )
          .onPressed,
      isNull,
    );
    expect(
      find.text('QR scanning is unavailable on this platform.'),
      findsOneWidget,
    );
    expect(camera.starts, 0);
    debugDefaultTargetPlatformOverride = null;
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
});

String _qr(String genus) => jsonEncode({
  'nahpu_taxon': 1,
  'taxon': {'taxonRank': 'genus', 'genus': genus},
});
