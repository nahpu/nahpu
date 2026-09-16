import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:path/path.dart' as p;

void main() {
  testWidgets('switches from Export to Share after export completes', (
    tester,
  ) async {
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

  group('the action beside Share', () {
    late Directory root;
    late File output;

    setUp(() {
      root = Directory.systemTemp.createTempSync('nahpu-share-button-');
      output = File(p.join(root.path, 'records.csv'))..writeAsStringSync('x');
    });
    tearDown(() async {
      if (root.existsSync()) await root.delete(recursive: true);
    });

    Future<void> pumpButton(
      WidgetTester tester, {
      required SavedFileAction action,
      VoidCallback? onRevealFile,
      VoidCallback? onSaveCopy,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportShareButton(
              hasExported: true,
              isRunning: false,
              onExport: () {},
              onShare: () {},
              output: output,
              savedFileAction: action,
              onRevealFile: onRevealFile,
              onSaveCopy: onSaveCopy,
            ),
          ),
        ),
      );
    }

    testWidgets('reveals the folder on desktop', (tester) async {
      var revealed = 0;
      await pumpButton(
        tester,
        action: SavedFileAction.reveal,
        onRevealFile: () => revealed++,
      );

      expect(find.text('Save to device'), findsNothing);
      await tester.tap(find.text('Open directory'));

      expect(revealed, 1);
    });

    testWidgets('offers the system save dialog on Android', (tester) async {
      var saved = 0;
      await pumpButton(
        tester,
        action: SavedFileAction.saveCopy,
        onSaveCopy: () => saved++,
      );

      expect(find.text('Open directory'), findsNothing);
      await tester.tap(find.text('Save to device'));

      expect(saved, 1);
    });

    testWidgets('leaves Share alone on iOS', (tester) async {
      await pumpButton(tester, action: SavedFileAction.none);

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Open directory'), findsNothing);
      expect(find.text('Save to device'), findsNothing);
    });

    testWidgets('drops an action the caller never wired up', (tester) async {
      // Better no button than one that silently does nothing.
      await pumpButton(tester, action: SavedFileAction.reveal);

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Open directory'), findsNothing);
    });

    testWidgets('keeps the lone Share button without a file', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportShareButton(
              hasExported: true,
              isRunning: false,
              onExport: () {},
              onShare: () {},
              savedFileAction: SavedFileAction.reveal,
              onRevealFile: () {},
            ),
          ),
        ),
      );

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Open directory'), findsNothing);
    });
  });
}
