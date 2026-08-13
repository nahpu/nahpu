import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';

void main() {
  testWidgets('switches from Export to Share after export completes',
      (tester) async {
    var exportCount = 0;
    var shareCount = 0;

    Future<void> pumpButton({required bool hasExported}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportShareButton(
              hasExported: hasExported,
              isRunning: false,
              onExport: () => exportCount++,
              onShare: () => shareCount++,
            ),
          ),
        ),
      );
    }

    await pumpButton(hasExported: false);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Share'), findsNothing);
    await tester.tap(find.text('Export'));
    expect(exportCount, 1);

    await pumpButton(hasExported: true);
    expect(find.text('Export'), findsNothing);
    expect(find.text('Share'), findsOneWidget);
    await tester.tap(find.text('Share'));
    expect(shareCount, 1);
  });
}
