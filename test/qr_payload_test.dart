import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/media/qr.dart';

void main() {
  testWidgets('oversized QR payload displays an error instead of throwing',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QrImageView(data: List.filled(30000, 'x').join()),
      ),
    );

    expect(find.text('QR data is too large'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
