import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/media/qr.dart';

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
      find.textContaining('Data is too large for QR code.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
