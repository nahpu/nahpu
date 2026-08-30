import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/application/selection_review.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:path/path.dart' as path;

void main() {
  const root = '/app/nahpu';
  const projectUuid = '3f2b1c9e-0000-4000-8000-000000000001';

  NahpuFileNode file(String relative, {int size = 1024}) {
    return NahpuFileNode(
      path: path.join(root, relative),
      name: path.basename(relative),
      sizeBytes: size,
      format: matchNahpuFormatFromPath(relative),
      status: NahpuFileStatus.dangling,
    );
  }

  NahpuDirectoryNode dir(
    String name,
    List<NahpuTreeNode> children, {
    String? subtitle,
    bool isStructural = false,
  }) {
    return NahpuDirectoryNode(
      path: name.isEmpty ? root : path.join(root, name),
      name: name.isEmpty ? 'nahpu' : name,
      subtitle: subtitle,
      sizeBytes: children.fold(0, (sum, e) => sum + e.sizeBytes),
      children: children,
      fileCount: children.whereType<NahpuFileNode>().length,
      danglingCount: 0,
      danglingBytes: 0,
      unmanagedCount: 0,
      deletableCount: children.whereType<NahpuFileNode>().length,
      deletableBytes: children.fold(0, (sum, e) => sum + e.sizeBytes),
      isEntirelyDangling: false,
      isStructural: isStructural,
    );
  }

  group('summarizeSelection', () {
    test('groups by top-level folder, largest first', () {
      final projectPhoto = file(
        '$projectUuid/media/specimen/a.jpg',
        size: 5000,
      );
      final backup = file('backup/old.sqlite3', size: 900);
      final stray = file('notes.csv', size: 100);

      final tree = dir('', [
        dir(projectUuid, [projectPhoto], subtitle: '1 files · Test Project'),
        dir('backup', [backup], subtitle: '1 files'),
        stray,
      ]);

      final groups = summarizeSelection(
        root: root,
        paths: [projectPhoto.path, backup.path, stray.path],
        tree: tree,
      );

      expect(groups.map((g) => g.label), [
        projectUuid,
        'backup',
        'Application folder',
      ]);
      expect(groups.first.sizeBytes, 5000);
      expect(groups.first.fileCount, 1);
      // The project name comes from the folder's description line.
      expect(groups.first.detail, contains('Test Project'));
      expect(groups.last.label, 'Application folder');
    });

    test('counts file kinds within a group', () {
      final one = file('$projectUuid/media/specimen/a.jpg');
      final two = file('$projectUuid/media/specimen/b.jpg');
      final audio = file('$projectUuid/media/specimen/c.wav');

      final tree = dir('', [
        dir(projectUuid, [one, two, audio], subtitle: '3 files · Test Project'),
      ]);

      final groups = summarizeSelection(
        root: root,
        paths: [one.path, two.path, audio.path],
        tree: tree,
      );

      expect(groups.single.fileCount, 3);
      expect(groups.single.detail, contains('2 image'));
      expect(groups.single.detail, contains('1 audio'));
    });
  });

  group('SelectionReviewDialog', () {
    Future<SelectionReviewResult?> pumpAndTap(
      WidgetTester tester,
      String buttonText, {
      Directory? initialDirectory,
      bool? isDesktop,
    }) async {
      SelectionReviewResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showSelectionReview(
                    context: context,
                    groups: const [
                      SelectionGroup(
                        label: 'backup',
                        detail: '2 other',
                        fileCount: 2,
                        sizeBytes: 2048,
                      ),
                    ],
                    fileCount: 2,
                    sizeBytes: 2048,
                    initialDirectory: initialDirectory,
                    isDesktop: isDesktop,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('shows the total and each group', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SelectionReviewDialog(
            groups: const [
              SelectionGroup(
                label: 'backup',
                detail: '2 other',
                fileCount: 2,
                sizeBytes: 2048,
              ),
            ],
            fileCount: 2,
            sizeBytes: 2048,
          ),
        ),
      );

      expect(find.text('2 selected files'), findsOneWidget);
      expect(find.text('backup'), findsOneWidget);
      expect(find.textContaining('2 ·'), findsOneWidget);
      expect(find.text('File Settings'), findsOneWidget);
      expect(find.text('nahpu_export'), findsOneWidget);
      expect(find.text('Append current date'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('Delete permanently'), findsOneWidget);

      final delete = tester.getCenter(find.text('Delete permanently'));
      final export = tester.getCenter(find.text('Export'));
      expect(delete.dx, lessThan(export.dx));
    });

    testWidgets('returns the export choice', (tester) async {
      final result = await pumpAndTap(
        tester,
        'Export',
        initialDirectory: Directory('/tmp/exports'),
      );
      expect(result?.action, SelectionAction.export);
      expect(result?.exportSettings?.format, DbArchiveFormat.tarGzip);
      expect(result?.exportSettings?.fileStem, 'nahpu_export');
      expect(result?.exportSettings?.appendDate, isTrue);
      expect(result?.exportSettings?.destination.path, '/tmp/exports');
    });

    testWidgets('returns the delete choice', (tester) async {
      expect(
        await pumpAndTap(tester, 'Delete permanently'),
        isA<SelectionReviewResult>().having(
          (result) => result.action,
          'action',
          SelectionAction.delete,
        ),
      );
    });

    testWidgets('cancel returns nothing', (tester) async {
      expect(await pumpAndTap(tester, 'Cancel'), isNull);
    });

    testWidgets('uses a scrollable bottom sheet on compact screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SelectionReviewResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showSelectionReview(
                    context: context,
                    groups: [
                      const SelectionGroup(
                        label:
                            'a-very-long-folder-name-that-must-not-overflow-the-review-surface',
                        detail:
                            'a-very-long-project-description-and-file-kind-summary',
                        fileCount: 2,
                        sizeBytes: 2048,
                      ),
                    ],
                    fileCount: 2,
                    sizeBytes: 2048,
                    initialDirectory: Directory('/tmp/exports'),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.textContaining('a-very-long-folder-name'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(tester.takeException(), isNull);
    });
  });
}
