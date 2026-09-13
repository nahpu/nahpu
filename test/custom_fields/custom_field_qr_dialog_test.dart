import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/transfer/custom_field_transfer.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/screens/shared/media/qr.dart';

void main() {
  testWidgets('custom fields use the standard black-on-white QR dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showCustomFieldQrDialog(
                  context: context,
                  payload: '{"custom_fields":[]}',
                  definitionCount: 2,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(QrCodeDialog), findsOneWidget);
    expect(find.byType(QrCodeViewer), findsOneWidget);
    final code = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(code.color, Colors.black);
    expect(code.backgroundColor, Colors.white);
    expect(find.textContaining('2 custom field definitions'), findsOneWidget);
  });
}
