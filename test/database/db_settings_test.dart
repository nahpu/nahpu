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
      // The current database is a real read, so the page is checked without
      // settling on its progress indicator.
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

    testWidgets('compares with the current database before a file is chosen', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.text('Current and replacement'), findsOneWidget);
      expect(find.text('Choose a file to compare.'), findsOneWidget);
    });

    testWidgets('turning off the backup warns beside the toggle', (
      tester,
    ) async {
      await pumpPage(tester);
      expect(find.textContaining('No safety backup'), findsNothing);

      await tester.tap(find.text('Back up current data first'));
      await tester.pump();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(find.textContaining('No safety backup'), findsOneWidget);
      expect(find.text('Current and replacement'), findsOneWidget);
    });

    testWidgets('large screens put the comparison beside the options', (
      tester,
    ) async {
      await pumpPage(tester);

      final source = tester.getTopLeft(find.text('Replace with'));
      final comparison = tester.getTopLeft(
        find.text('Current and replacement'),
      );
      expect(comparison.dx, greaterThan(source.dx));
      expect((comparison.dy - source.dy).abs(), lessThan(NahpuSpacing.xl));
    });

    testWidgets('small screens stack the comparison below', (tester) async {
      await pumpPage(tester, size: const Size(420, 2400));

      final source = tester.getTopLeft(find.text('Replace with'));
      final comparison = tester.getTopLeft(
        find.text('Current and replacement'),
      );
      expect(comparison.dy, greaterThan(source.dy));
      expect((comparison.dx - source.dx).abs(), lessThan(1));
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

  group('DatabaseComparisonPanel', () {
    const current = DbBackupSummary(
      entries: {
        'Projects': 7,
        'Personnel': 3,
        'Taxa': 10,
        'Sites': 4,
        'Collection events': 6,
        'Specimens': 5,
        'Narratives': 2,
        'Media records': 8,
        'Associated files': 9,
      },
      associatedFileBytes: 1000,
      databaseBytes: 1000,
      schemaVersion: kSchemaVersion,
    );

    DbReplacementPreview previewWith({
      required int schemaVersion,
      DbReplacementIssue? issue,
    }) {
      return DbReplacementPreview(
        contents: DbContentsSummary(
          entries: const {
            'Projects': 3,
            'Personnel': 3,
            'Taxa': 10,
            'Sites': 4,
            'Collection events': 6,
            'Specimens': 12,
            'Narratives': null,
            'Media records': 8,
          },
          associatedFiles: 9,
          totalBytes: 500,
          schemaVersion: schemaVersion,
        ),
        issue: issue,
      );
    }

    Future<void> pumpPanel(
      WidgetTester tester,
      DbReplacementPreview? replacement,
    ) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DatabaseComparisonPanel(
                current: current,
                currentError: null,
                replacement: replacement,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows both columns with the change for each count', (
      tester,
    ) async {
      await pumpPanel(tester, previewWith(schemaVersion: kSchemaVersion));

      expect(find.text('Replacement'), findsOneWidget);
      expect(find.text('-4'), findsOneWidget);
      expect(find.text('+7'), findsOneWidget);
      // Narratives is missing from the replacement.
      expect(find.text('—'), findsOneWidget);
      expect(find.text('v$kSchemaVersion'), findsNWidgets(2));
      expect(find.textContaining('after restore'), findsNothing);
      expect(find.text('Newer than this app'), findsNothing);
    });

    testWidgets('an older replacement schema is upgraded after restore', (
      tester,
    ) async {
      await pumpPanel(tester, previewWith(schemaVersion: kSchemaVersion - 1));

      expect(find.text('v${kSchemaVersion - 1}'), findsOneWidget);
      expect(
        find.text('Upgraded to v$kSchemaVersion after restore'),
        findsOneWidget,
      );
    });

    testWidgets('a newer replacement schema is blocked with an update hint', (
      tester,
    ) async {
      await pumpPanel(
        tester,
        previewWith(
          schemaVersion: kSchemaVersion + 1,
          issue: DbReplacementIssue.newerSchema,
        ),
      );

      expect(find.textContaining('Update NAHPU'), findsOneWidget);
      expect(find.text('Newer than this app'), findsOneWidget);
    });

    testWidgets('a non-NAHPU file hides its replacement counts', (
      tester,
    ) async {
      await pumpPanel(
        tester,
        previewWith(
          schemaVersion: 0,
          issue: DbReplacementIssue.notNahpuDatabase,
        ),
      );

      expect(find.textContaining('not a NAHPU database'), findsOneWidget);
      expect(find.text('+7'), findsNothing);
      expect(find.text('Newer than this app'), findsNothing);
    });

    testWidgets('without a file only the current column shows', (tester) async {
      await pumpPanel(tester, null);

      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Replacement'), findsNothing);
      expect(find.text('Choose a file to compare.'), findsOneWidget);
    });
  });
}
