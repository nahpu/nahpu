import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/shared/media/qr.dart';

void main() {
  group('scanner mode filtering', () {
    test('classifies QR and barcode formats', () {
      expect(scannerModeForBarcodeFormat(BarcodeFormat.qrCode), ScannerMode.qr);
      expect(
        scannerModeForBarcodeFormat(BarcodeFormat.microQrCode),
        ScannerMode.qr,
      );
      expect(
        scannerModeForBarcodeFormat(BarcodeFormat.code128),
        ScannerMode.barcode,
      );
      expect(
        scannerModeForBarcodeFormat(BarcodeFormat.dataMatrix),
        ScannerMode.barcode,
      );
      expect(scannerModeForBarcodeFormat(BarcodeFormat.unknown), isNull);
      expect(scannerModeForBarcodeFormat(BarcodeFormat.all), isNull);
    });

    test('keeps only codes matching the selected mode', () {
      const capture = BarcodeCapture(
        barcodes: [
          Barcode(format: BarcodeFormat.qrCode, rawValue: 'qr'),
          Barcode(format: BarcodeFormat.code39, rawValue: 'barcode'),
          Barcode(format: BarcodeFormat.unknown, rawValue: 'unknown'),
        ],
      );

      final qrCapture = filterScannerCapture(capture, ScannerMode.qr);
      final barcodeCapture = filterScannerCapture(capture, ScannerMode.barcode);

      expect(qrCapture.barcodes.map((barcode) => barcode.rawValue), ['qr']);
      expect(barcodeCapture.barcodes.map((barcode) => barcode.rawValue), [
        'barcode',
      ]);
    });

    test('scanner configuration requires a valid initial mode', () {
      expect(
        () => ScannerScreen(supportedModes: const {}, onDetect: (_) {}),
        throwsAssertionError,
      );
      expect(
        () => ScannerScreen(
          supportedModes: const {ScannerMode.barcode},
          initialMode: ScannerMode.qr,
          onDetect: (_) {},
        ),
        throwsAssertionError,
      );
    });
  });

  group('scanner camera overlay', () {
    testWidgets('switches between square QR and wide barcode frames', (
      tester,
    ) async {
      var mode = ScannerMode.qr;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 700,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ScannerCameraOverlay(
                    mode: mode,
                    supportedModes: const {ScannerMode.qr, ScannerMode.barcode},
                    onModeChanged: (value) => setState(() => mode = value),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('scanner-mode-selector')),
        findsOneWidget,
      );
      expect(find.text('Align the QR code within the frame'), findsOneWidget);
      final qrSize = tester.getSize(
        find.byKey(const ValueKey('scanner-frame-qr')),
      );
      expect(qrSize.width, qrSize.height);

      await tester.tap(find.text('Barcode'));
      await tester.pumpAndSettle();

      expect(find.text('Align the barcode within the frame'), findsOneWidget);
      final barcodeSize = tester.getSize(
        find.byKey(const ValueKey('scanner-frame-barcode')),
      );
      expect(barcodeSize.width, greaterThan(barcodeSize.height));
    });

    testWidgets('QR-only overlay hides the mode selector', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 700,
              child: ScannerCameraOverlay(
                mode: ScannerMode.qr,
                supportedModes: {ScannerMode.qr},
                onModeChanged: _ignoreModeChange,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('scanner-mode-selector')), findsNothing);
      expect(find.text('Align the QR code within the frame'), findsOneWidget);
    });

    testWidgets('dual-mode overlay fits a compact landscape viewport', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 260,
              child: ScannerCameraOverlay(
                mode: ScannerMode.qr,
                supportedModes: {ScannerMode.qr, ScannerMode.barcode},
                onModeChanged: _ignoreModeChange,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('scanner-mode-selector')),
        findsOneWidget,
      );
    });
  });
}

void _ignoreModeChange(ScannerMode _) {}
