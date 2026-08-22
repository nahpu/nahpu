import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/actions/preset_actions.dart';

void main() {
  testWidgets('exposes the plus button and every preset menu action', (
    tester,
  ) async {
    var createCount = 0;
    var scanCount = 0;
    var importCount = 0;
    var exportCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              PresetAppBarActions(
                onCreate: () => createCount++,
                onScanQr: () => scanCount++,
                onImport: () => importCount++,
                onExport: () => exportCount++,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Create new preset'));
    expect(createCount, 1);

    Future<void> selectMenuItem(String label) async {
      await tester.tap(find.byTooltip('Preset options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await selectMenuItem('Create new');
    await selectMenuItem('Scan QR');
    await selectMenuItem('Import');
    await selectMenuItem('Export');

    expect(createCount, 2);
    expect(scanCount, 1);
    expect(importCount, 1);
    expect(exportCount, 1);
  });
}
