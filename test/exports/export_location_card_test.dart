import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;

  setUp(() => root = Directory.systemTemp.createTempSync('nahpu-location-'));
  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  File write(String name) =>
      File(p.join(root.path, name))..writeAsStringSync('x');

  /// A file past the save-copy limit that costs no disk on a sparse
  /// filesystem, so the oversize branch can be checked without writing 100 MB.
  File oversize(String name) {
    final file = File(p.join(root.path, name));
    final handle = file.openSync(mode: FileMode.write);
    handle.setPositionSync(FilePickerServices.maxSaveCopyBytes);
    handle.writeByteSync(0);
    handle.closeSync();
    return file;
  }

  Future<void> pumpCard(
    WidgetTester tester, {
    required ExportDestinationMode mode,
    required SavedFileAction action,
    File? output,
    Directory? selectedDir,
    VoidCallback? onDismiss,
    VoidCallback? onSaveCopy,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExportLocationCard(
              destinationMode: mode,
              savedFileAction: action,
              selectedDir: selectedDir,
              output: output,
              outputBytes: 1717986918,
              duration: const Duration(minutes: 3, seconds: 42),
              onSelectDir: () {},
              onClearDir: () {},
              onShare: () {},
              onOpenFolder: () {},
              onSaveCopy: onSaveCopy ?? () {},
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
                      destinationMode: ExportDestinationMode.chooseDirectory,
                      savedFileAction: SavedFileAction.reveal,
                      selectedDir: null,
                      output: output,
                      onSelectDir: () {},
                      onClearDir: () {},
                      onShare: () {},
                      onOpenFolder: () {},
                      onSaveCopy: () {},
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
      await pumpScreen(tester, output: write('project.tar.gz'));

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
      await pumpCard(
        tester,
        mode: ExportDestinationMode.chooseDirectory,
        action: SavedFileAction.reveal,
      );

      expect(find.text('Save to'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('states the saved file once, with folder and share actions', (
      tester,
    ) async {
      final output = write('records-2026-08-22.csv');
      await pumpCard(
        tester,
        mode: ExportDestinationMode.chooseDirectory,
        action: SavedFileAction.reveal,
        selectedDir: root,
        output: output,
      );

      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('records-2026-08-22.csv'), findsOneWidget);
      expect(find.text('1.6 GB in 3 min 42 s'), findsOneWidget);
      expect(find.text(output.path), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Open directory'), findsOneWidget);
      expect(find.text('Save to device'), findsNothing);
    });

    testWidgets('describes app storage rather than printing its path', (
      tester,
    ) async {
      // Nothing was browsed, so the file sits in an app-private directory
      // whose path would only mislead. The card says so instead.
      final output = write('records.csv');
      await pumpCard(
        tester,
        mode: ExportDestinationMode.chooseDirectory,
        action: SavedFileAction.reveal,
        output: output,
      );

      expect(find.text('Saved'), findsOneWidget);
      expect(find.textContaining('Saved in NAHPU app storage'), findsOneWidget);
      expect(find.text(output.path), findsNothing);
    });

    testWidgets('closing the result asks the screen to clear the destination', (
      tester,
    ) async {
      var dismissed = 0;
      await pumpCard(
        tester,
        mode: ExportDestinationMode.chooseDirectory,
        action: SavedFileAction.reveal,
        output: write('records.csv'),
        onDismiss: () => dismissed++,
      );

      await tester.tap(find.byTooltip('Hide save location'));
      expect(dismissed, 1);
    });
  });

  group('Android', () {
    testWidgets('browses for a folder but cannot reveal one', (tester) async {
      // A file:// intent is blocked from API 24 on, so the saved file is
      // reachable through the system save dialog instead.
      final output = write('records.csv');
      await pumpCard(
        tester,
        mode: ExportDestinationMode.chooseDirectory,
        action: SavedFileAction.saveCopy,
        selectedDir: root,
        output: output,
      );

      expect(find.text('Saved'), findsOneWidget);
      expect(find.text(output.path), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Save to device'), findsOneWidget);
      expect(find.text('Open directory'), findsNothing);
    });

    testWidgets('Save to device reaches the screen', (tester) async {
      var saved = 0;
      await pumpCard(
        tester,
        mode: ExportDestinationMode.chooseDirectory,
        action: SavedFileAction.saveCopy,
        output: write('records.csv'),
        onSaveCopy: () => saved++,
      );

      await tester.tap(find.text('Save to device'));

      expect(saved, 1);
    });

    testWidgets('explains itself instead of offering an impossible save', (
      tester,
    ) async {
      await pumpCard(
        tester,
        mode: ExportDestinationMode.chooseDirectory,
        action: SavedFileAction.saveCopy,
        output: oversize('media.tar.gz'),
      );

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Save to device'), findsNothing);
      expect(find.textContaining('Too large to save'), findsOneWidget);
      expect(find.textContaining('100 MB'), findsOneWidget);
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
                destinationMode: ExportDestinationMode.chooseDirectory,
                savedFileAction: SavedFileAction.reveal,
                selectedDir: selectedDir,
                output: output,
                onSelectDir: () {},
                onClearDir: clearDestination,
                onShare: () {},
                onOpenFolder: () {},
                onSaveCopy: () {},
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

  group('iOS', () {
    testWidgets('names the temporary destination instead of a picker', (
      tester,
    ) async {
      await pumpCard(
        tester,
        mode: ExportDestinationMode.temporary,
        action: SavedFileAction.none,
      );

      expect(find.text('Share after export'), findsOneWidget);
      expect(find.text('Browse'), findsNothing);
      expect(
        find.textContaining('only until your next export'),
        findsOneWidget,
      );
    });

    testWidgets('leads with Share and warns the file will not last', (
      tester,
    ) async {
      final output = write('records.csv');
      await pumpCard(
        tester,
        mode: ExportDestinationMode.temporary,
        action: SavedFileAction.none,
        output: output,
      );

      // Exactly one Share, on the button, and no second action of any kind.
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Export complete'), findsOneWidget);
      expect(find.text('Saved'), findsNothing);
      expect(find.text('Open directory'), findsNothing);
      expect(find.text('Save to device'), findsNothing);
      expect(
        find.textContaining('removes it when you export again'),
        findsOneWidget,
      );
      // The full path means nothing on a phone; the file name does.
      expect(find.text('records.csv'), findsOneWidget);
      expect(find.text(output.path), findsNothing);
    });
  });
}
