import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/actions/preset_actions.dart';

void main() {
  Future<void> selectMenuItem(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Preset options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('exposes the plus button and every preset menu action', (
    tester,
  ) async {
    var createCount = 0;
    var scanCount = 0;
    var importCount = 0;
    var exportAllCount = 0;
    var exportSelectedCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              PresetAppBarActions(
                onCreate: () => createCount++,
                onScanQr: () => scanCount++,
                onImport: () => importCount++,
                onExportAll: () => exportAllCount++,
                onExportSelected: () => exportSelectedCount++,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Create new preset'));
    expect(createCount, 1);

    await selectMenuItem(tester, 'Create new');
    await selectMenuItem(tester, 'Scan QR');
    await selectMenuItem(tester, 'Import');
    await selectMenuItem(tester, 'Export this preset');
    await selectMenuItem(tester, 'Export all presets');

    expect(createCount, 2);
    expect(scanCount, 1);
    expect(importCount, 1);
    expect(exportSelectedCount, 1);
    expect(exportAllCount, 1);
  });

  testWidgets('offers a single Export entry when nothing is selected', (
    tester,
  ) async {
    var exportAllCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              PresetAppBarActions(
                onCreate: () {},
                onScanQr: () {},
                onImport: () {},
                onExportAll: () => exportAllCount++,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Preset options'));
    await tester.pumpAndSettle();
    expect(find.text('Export this preset'), findsNothing);
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(exportAllCount, 1);
  });

  testWidgets('names the scopes after the item type', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              PresetAppBarActions(
                itemName: 'template',
                onCreate: () {},
                onScanQr: () {},
                onImport: () {},
                onExportAll: () {},
                onExportSelected: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byTooltip('Create new template'), findsOneWidget);
    await tester.tap(find.byTooltip('Template options'));
    await tester.pumpAndSettle();
    expect(find.text('Export this template'), findsOneWidget);
    expect(find.text('Export all templates'), findsOneWidget);
  });
}
