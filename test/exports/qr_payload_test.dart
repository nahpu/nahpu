import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/styles/design_tokens.dart';

void main() {
  test('QR capacity helper detects oversized payloads', () {
    expect(canEncodeQrPayload('NAHPU record'), isTrue);
    expect(canEncodeQrPayload(List.filled(60000, 'x').join()), isFalse);
  });

  testWidgets('oversized QR payload displays an error instead of throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: QrImageView(data: List.filled(60000, 'x').join())),
    );

    expect(
      find.textContaining('Data is too large for a QR code.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('QR view centers the padded code in a non-square layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 120,
          height: 140,
          child: QrImageView(
            data: 'NAHPU record',
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );

    expect(find.byType(QrImageView), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(QrImageView),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared QR viewer uses black on white and stays square', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 120,
            height: 140,
            child: QrCodeViewer(data: 'NAHPU project', maxSize: 400),
          ),
        ),
      ),
    );

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.color, Colors.black);
    expect(qr.backgroundColor, Colors.white);
    expect(qr.padding, NahpuSpacing.sm);
    expect(tester.getSize(find.byType(QrImageView)), const Size(120, 120));
    expect(tester.takeException(), isNull);
  });
}
