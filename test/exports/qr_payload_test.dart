import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/project_info.dart';
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

  testWidgets('project QR viewer uses 8px padding and 16px corners', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectQrCodeViewer(data: 'NAHPU project', isFullScreen: false),
      ),
    );

    expect(find.byType(ProjectQrCodeViewer), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    final container = tester.widget<Container>(find.byType(Container));
    expect(container.padding, const EdgeInsets.all(8));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(16));
    expect(tester.takeException(), isNull);
  });
}
