import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/database/db_settings.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/db_writer.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/styles/design_tokens.dart';

void main() {
  testWidgets('database candidate dialog returns the selected root file', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              selected = await showDialog<String>(
                context: context,
                builder: (context) => const DatabaseCandidateDialog(
                  candidates: [
                    DbArchiveDatabaseCandidate(
                      archivePath: 'nahpu.sqlite3',
                      displayName: 'nahpu.sqlite3',
                    ),
                    DbArchiveDatabaseCandidate(
                      archivePath: 'legacy.db',
                      displayName: 'legacy.db',
                    ),
                  ],
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Choose database'), findsOneWidget);
    await tester.tap(find.text('legacy.db'));
    await tester.pumpAndSettle();

    expect(selected, 'legacy.db');
  });

  test('the pre-replace safety backup is a full archive, not a bare db', () {
    // The snapshot taken before a restore used to be a `.sqlite3` holding no
    // media at all, which made the safety net under the most destructive
    // operation in the app useless for photos.
    expect(
      DbArchiveFormat.values,
      contains(preReplaceBackupFormat),
      reason: 'the safety backup must be one of the archive formats',
    );
    expect(preReplaceBackupFormat.extension, anyOf('zip', 'tar.gz'));
  });

  test('a restore reports a stage for the safety backup', () {
    // Writing a full archive can take minutes, so it needs its own labelled
    // stage rather than hiding inside "Replace database".
    final labels = DbWriter.restorePhases.map((step) => step.label).toList();
    expect(labels, contains('Back up current data'));
    expect(
      labels.indexOf('Back up current data'),
      lessThan(labels.indexOf('Replace database')),
    );
  });

  testWidgets('the confirmation says whether a backup is taken', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: DbWarningText(isBackup: false)),
    );
    expect(find.textContaining('No backup will be made'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: DbWarningText(isBackup: true)),
    );
    expect(find.textContaining('backup of your current data'), findsOneWidget);
  });

  /// The page used to offer both a backup switch and a link to the backup
  /// window, which write the same archive. It is now laid out like the backup
  /// window instead.
  group('Replace database page', () {
    const pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );

    late Directory tempAppDir;
    late Database db;

    setUp(() {
      tempAppDir = Directory.systemTemp.createTempSync(
        'nahpu-db-settings-test',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, (call) async {
            switch (call.method) {
              case 'getApplicationDocumentsDirectory':
                return tempAppDir.path;
              case 'getTemporaryDirectory':
                return Directory.systemTemp.path;
              default:
                return null;
            }
          });
      db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, null);
      await db.close();
      if (tempAppDir.existsSync()) {
        await tempAppDir.delete(recursive: true);
      }
    });

    Future<void> pumpPage(
      WidgetTester tester, {
      Size size = const Size(1200, 1600),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: DatabaseSettings()),
        ),
      );
      // The summary is a real read, so the page is checked without settling
      // on its progress indicator.
      await tester.pump();
    }

    testWidgets('keeps the backup toggle and drops the backup window link', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.text('Back up current data first'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(find.text('Open the backup window'), findsNothing);
    });

    testWidgets('offers Browse before a file is chosen', (tester) async {
      await pumpPage(tester);

      expect(find.text('No file selected'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Browse'), findsOneWidget);
      expect(find.byTooltip('Clear file'), findsNothing);
    });

    testWidgets('shows the backup contents only while the toggle is on', (
      tester,
    ) async {
      await pumpPage(tester);
      expect(find.text('Entire database contents'), findsOneWidget);
      expect(find.text('No safety backup'), findsNothing);

      await tester.tap(find.text('Back up current data first'));
      await tester.pump();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(find.text('Entire database contents'), findsNothing);
      expect(find.text('No safety backup'), findsOneWidget);

      await tester.tap(find.text('Back up current data first'));
      await tester.pump();

      expect(find.text('Entire database contents'), findsOneWidget);
    });

    testWidgets('large screens put the backup contents beside the options', (
      tester,
    ) async {
      await pumpPage(tester);

      final source = tester.getTopLeft(find.text('Replace with'));
      final contents = tester.getTopLeft(find.text('Entire database contents'));
      expect(contents.dx, greaterThan(source.dx));
      expect((contents.dy - source.dy).abs(), lessThan(NahpuSpacing.xl));
    });

    testWidgets('small screens stack the backup contents below', (
      tester,
    ) async {
      await pumpPage(tester, size: const Size(420, 2400));

      final source = tester.getTopLeft(find.text('Replace with'));
      final contents = tester.getTopLeft(find.text('Entire database contents'));
      expect(contents.dy, greaterThan(source.dy));
      expect((contents.dx - source.dx).abs(), lessThan(1));
    });

    testWidgets('the replace button is pinned and waits for a file', (
      tester,
    ) async {
      await pumpPage(tester);

      final bar = find.byType(ExportActionBar);
      expect(bar, findsOneWidget);
      expect(
        find.ancestor(of: bar, matching: find.byType(SingleChildScrollView)),
        findsNothing,
      );
      final button = tester.widget<PrimaryButton>(
        find.descendant(of: bar, matching: find.byType(PrimaryButton)),
      );
      expect(button.label, 'Replace database');
      expect(button.onPressed, isNull);
    });
  });
}
