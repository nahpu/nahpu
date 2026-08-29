import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required bool isDesktop,
    File? output,
    Directory? selectedDir,
    VoidCallback? onDismiss,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExportLocationCard(
              isDesktop: isDesktop,
              selectedDir: selectedDir,
              output: output,
              outputBytes: 1717986918,
              duration: const Duration(minutes: 3, seconds: 42),
              onSelectDir: () {},
              onClearDir: () {},
              onShare: () {},
              onOpenFolder: () {},
              onDismiss: onDismiss ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  group('export footer', () {
    Future<void> pumpScreen(WidgetTester tester, {required File? output}) {
      // Mirrors how the screens compose it: the destination sits with the file
      // settings, the single primary action sits in the footer below.
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: ExportLocationCard(
                      isDesktop: true,
                      selectedDir: null,
                      output: output,
                      onSelectDir: () {},
                      onClearDir: () {},
                      onShare: () {},
                      onOpenFolder: () {},
                      onDismiss: () {},
                    ),
                  ),
                ),
                ExportActionBar(
                  label: 'Export project',
                  repeatLabel: 'Export another',
                  icon: Icons.archive_outlined,
                  canExport: true,
                  isRunning: false,
                  hasOutput: output != null,
                  onExport: () {},
                ),
              ],
            ),
          ),
        ),
      );
    }

    // The bug this whole layout exists to kill: a finished export used to
    // offer Share from the result panel *and* again beside "Export another".
    testWidgets('offers Share once, and not beside the repeat action', (
      tester,
    ) async {
      await pumpScreen(tester, output: File('/tmp/nahpu/project.tar.gz'));

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Export another'), findsOneWidget);
      expect(find.text('Export project'), findsNothing);
      // Share belongs to the location card, above the repeat action.
      final shareY = tester.getCenter(find.text('Share')).dy;
      final repeatY = tester.getCenter(find.text('Export another')).dy;
      expect(shareY, lessThan(repeatY));
    });

    testWidgets('names the export action until a file exists', (tester) async {
      await pumpScreen(tester, output: null);

      expect(find.text('Export project'), findsOneWidget);
      expect(find.text('Export another'), findsNothing);
      expect(find.text('Share'), findsNothing);
    });
  });

  group('desktop', () {
    testWidgets('offers a directory to browse before anything is written', (
      tester,
    ) async {
      await pumpCard(tester, isDesktop: true);

      expect(find.text('Save to'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('states the saved file once, with folder and share actions', (
      tester,
    ) async {
      await pumpCard(
        tester,
        isDesktop: true,
        output: File('/tmp/nahpu/records-2026-08-22.csv'),
      );

      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('records-2026-08-22.csv'), findsOneWidget);
      expect(find.text('1.6 GB in 3 min 42 s'), findsOneWidget);
      expect(find.text('/tmp/nahpu/records-2026-08-22.csv'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Open directory'), findsOneWidget);
    });

    testWidgets('closing the result asks the screen to clear the destination', (
      tester,
    ) async {
      var dismissed = 0;
      await pumpCard(
        tester,
        isDesktop: true,
        output: File('/tmp/nahpu/records.csv'),
        onDismiss: () => dismissed++,
      );

      await tester.tap(find.byTooltip('Hide save location'));
      expect(dismissed, 1);
    });
  });

  testWidgets('closing a result lands straight on the directory input', (
    tester,
  ) async {
    // The screens wire onDismiss and onClearDir to the same reset, so closing
    // a finished export drops the directory too. Two closes to reach the
    // picker was the complaint.
    Directory? selectedDir = Directory('/Users/someone/Downloads');
    File? output = File('/Users/someone/Downloads/records.xlsx');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              void clearDestination() => setState(() {
                selectedDir = null;
                output = null;
              });
              return ExportLocationCard(
                isDesktop: true,
                selectedDir: selectedDir,
                output: output,
                onSelectDir: () {},
                onClearDir: clearDestination,
                onShare: () {},
                onOpenFolder: () {},
                onDismiss: clearDestination,
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('records.xlsx'), findsOneWidget);

    await tester.tap(find.byTooltip('Hide save location'));
    await tester.pump();

    expect(find.text('Select directory'), findsOneWidget);
    expect(find.text('Browse'), findsOneWidget);
    expect(find.text('/Users/someone/Downloads'), findsNothing);
  });

  group('mobile', () {
    testWidgets('names app storage instead of offering a picker', (
      tester,
    ) async {
      await pumpCard(tester, isDesktop: false);

      expect(find.text('NAHPU app storage'), findsOneWidget);
      expect(find.text('Browse'), findsNothing);
      expect(find.textContaining('device storage'), findsOneWidget);
    });

    testWidgets('leads with Share and points at local storage', (tester) async {
      await pumpCard(
        tester,
        isDesktop: false,
        output: File('/tmp/nahpu/records.csv'),
      );

      // Exactly one Share, on the button, and no desktop-only affordances.
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Export complete'), findsOneWidget);
      expect(find.text('Saved'), findsNothing);
      expect(find.text('Open directory'), findsNothing);
      expect(
        find.textContaining('save this file to your device storage'),
        findsOneWidget,
      );
      // The full path means nothing on a phone; the file name does.
      expect(find.text('records.csv'), findsOneWidget);
      expect(find.text('/tmp/nahpu/records.csv'), findsNothing);
    });
  });
}
