import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/application/file_tree.dart';
import 'package:nahpu/services/providers/file_explorer.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:nahpu/services/types/file_format.dart';

NahpuFileNode buildFile(
  String name, {
  required NahpuFileStatus status,
  NahpuLockReason? reason,
  int size = 1024,
}) {
  return NahpuFileNode(
    path: '/root/$name',
    name: name,
    sizeBytes: size,
    format: NahpuFileFormat.image,
    status: status,
    lockReason: reason,
  );
}

NahpuDirectoryNode buildDir(
  String name,
  List<NahpuTreeNode> children, {
  String? subtitle,
  bool isStructural = false,
}) {
  final files = children.whereType<NahpuFileNode>();
  final dangling = files.where((e) => e.isDangling).length;
  final deletable = files.where((e) => e.isManuallyDeletable).toList();
  return NahpuDirectoryNode(
    path: '/root/$name',
    name: name,
    subtitle: subtitle ?? '${files.length} files',
    sizeBytes: children.fold(0, (sum, e) => sum + e.sizeBytes),
    children: children,
    fileCount: files.length,
    danglingCount: dangling,
    danglingBytes: dangling * 1024,
    unmanagedCount: files
        .where((e) => e.status == NahpuFileStatus.unmanaged)
        .length,
    deletableCount: deletable.length,
    deletableBytes: deletable.fold(0, (sum, e) => sum + e.sizeBytes),
    isEntirelyDangling: false,
    isStructural: isStructural,
  );
}

void main() {
  Future<void> pump(
    WidgetTester tester,
    NahpuDirectoryNode root, {
    ValueChanged<NahpuFileNode>? onDelete,
    ValueChanged<NahpuFileNode>? onSaveCopy,
    bool isSelecting = false,
    Set<String> selected = const <String>{},
    ValueChanged<NahpuFileNode>? onSelectionChanged,
    ValueChanged<NahpuDirectoryNode>? onDirectorySelectionChanged,
    ValueChanged<NahpuDirectoryNode>? onDeleteDirectory,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NahpuFileTreeView(
              root: root,
              onDeleteFile: onDelete ?? (_) {},
              onSaveCopy: onSaveCopy,
              isSelecting: isSelecting,
              selected: selected,
              onSelectionChanged: onSelectionChanged,
              onDirectorySelectionChanged: onDirectorySelectionChanged,
              onDeleteDirectory: onDeleteDirectory,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('collapsing a directory hides its files', (tester) async {
    final root = buildDir('root', [
      buildDir('media', [buildFile('a.jpg', status: NahpuFileStatus.dangling)]),
    ]);

    await pump(tester, root);
    expect(find.text('a.jpg'), findsOneWidget);

    await tester.tap(find.text('media'));
    await tester.pumpAndSettle();
    expect(find.text('a.jpg'), findsNothing);

    await tester.tap(find.text('media'));
    await tester.pumpAndSettle();
    expect(find.text('a.jpg'), findsOneWidget);
  });

  testWidgets('a linked file offers no delete control', (tester) async {
    final root = buildDir('root', [
      buildDir('media', [
        buildFile(
          'locked.jpg',
          status: NahpuFileStatus.linked,
          reason: NahpuLockReason.mediaRecord,
        ),
      ]),
    ]);

    await pump(tester, root);

    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
  });

  testWidgets('a dangling file offers delete and reports the node', (
    tester,
  ) async {
    NahpuFileNode? deleted;
    final root = buildDir('root', [
      buildDir('media', [
        buildFile('orphan.jpg', status: NahpuFileStatus.dangling),
      ]),
    ]);

    await pump(tester, root, onDelete: (node) => deleted = node);

    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pump();
    expect(deleted?.name, 'orphan.jpg');
  });

  testWidgets('an unmanaged file can still be removed by hand', (tester) async {
    // Bulk pruning never touches these, but a file the user picks out
    // themselves is theirs to remove.
    final root = buildDir('root', [
      buildDir('media', [
        buildFile(
          'export.csv',
          status: NahpuFileStatus.unmanaged,
          reason: NahpuLockReason.unmanagedLocation,
        ),
      ]),
    ]);

    await pump(tester, root);

    expect(find.text('export.csv'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
  });

  testWidgets('the live database offers neither delete nor save', (
    tester,
  ) async {
    final root = buildDir('root', [
      buildDir('media', [
        buildFile(
          'nahpu.db',
          status: NahpuFileStatus.locked,
          reason: NahpuLockReason.database,
        ),
      ]),
    ]);

    await pump(tester, root, onSaveCopy: (_) {});

    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    expect(find.byIcon(Icons.download_outlined), findsNothing);
  });

  testWidgets('a removable file offers a save-a-copy action', (tester) async {
    NahpuFileNode? saved;
    final root = buildDir('root', [
      buildDir('media', [
        buildFile('orphan.jpg', status: NahpuFileStatus.dangling),
      ]),
    ]);

    await pump(tester, root, onSaveCopy: (node) => saved = node);

    await tester.tap(find.byIcon(Icons.download_outlined));
    await tester.pump();
    expect(saved?.name, 'orphan.jpg');
  });

  testWidgets('selection mode swaps file actions for checkboxes', (
    tester,
  ) async {
    NahpuFileNode? toggled;
    final root = buildDir('root', [
      buildDir('media', [
        buildFile('orphan.jpg', status: NahpuFileStatus.dangling),
        buildFile(
          'kept.jpg',
          status: NahpuFileStatus.linked,
          reason: NahpuLockReason.mediaRecord,
        ),
      ]),
    ]);

    await pump(
      tester,
      root,
      isSelecting: true,
      onSelectionChanged: (node) => toggled = node,
    );

    // One box for the removable file, one for the folder holding it; the
    // linked file keeps its lock instead.
    expect(find.byType(Checkbox), findsNWidgets(2));
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pump();
    expect(toggled?.name, 'orphan.jpg');
  });

  testWidgets('a folder with nothing removable offers no checkbox', (
    tester,
  ) async {
    final root = buildDir('root', [
      buildDir('media', [
        buildFile(
          'nahpu.db',
          status: NahpuFileStatus.locked,
          reason: NahpuLockReason.database,
        ),
      ]),
    ]);

    await pump(tester, root, isSelecting: true);

    expect(find.byType(Checkbox), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('a mixed folder reports only its removable files', (
    tester,
  ) async {
    NahpuDirectoryNode? toggled;
    final root = buildDir('root', [
      buildDir('media', [
        buildFile('orphan.jpg', status: NahpuFileStatus.dangling),
        buildFile(
          'kept.jpg',
          status: NahpuFileStatus.linked,
          reason: NahpuLockReason.mediaRecord,
        ),
      ]),
    ]);

    await pump(
      tester,
      root,
      isSelecting: true,
      onDirectorySelectionChanged: (node) => toggled = node,
    );

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    expect(toggled?.name, 'media');
    expect(collectDeletablePaths(toggled!), ['/root/orphan.jpg']);
  });

  testWidgets('a partly selected folder shows the indeterminate box', (
    tester,
  ) async {
    final root = buildDir('root', [
      buildDir('media', [
        buildFile('a.jpg', status: NahpuFileStatus.dangling),
        buildFile('b.jpg', status: NahpuFileStatus.dangling),
      ]),
    ]);

    await pump(
      tester,
      root,
      isSelecting: true,
      selected: const {'/root/a.jpg'},
    );

    final folderBox = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(folderBox.value, isNull);

    await pump(
      tester,
      root,
      isSelecting: true,
      selected: const {'/root/a.jpg', '/root/b.jpg'},
    );
    final allBox = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(allBox.value, isTrue);
  });

  testWidgets('directory and file rows share one row height', (tester) async {
    final root = buildDir('root', [
      buildDir('media', [buildFile('a.jpg', status: NahpuFileStatus.dangling)]),
    ]);

    await pump(tester, root);

    final folder = tester.getSize(find.text('media'));
    final file = tester.getSize(find.text('a.jpg'));
    expect(folder.height, greaterThan(0));
    expect(file.height, greaterThan(0));
    // Both rows sit in the same fixed-height container.
    final folderRow = tester.getRect(
      find
          .ancestor(
            of: find.text('media'),
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );
    final fileRow = tester.getRect(
      find
          .ancestor(
            of: find.text('a.jpg'),
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );
    expect(fileRow.height, folderRow.height);
  });

  testWidgets('an empty folder offers a delete action', (tester) async {
    NahpuDirectoryNode? removed;
    final root = buildDir('root', [buildDir('stale', const [])]);

    await pump(tester, root, onDeleteDirectory: (node) => removed = node);

    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pump();
    expect(removed?.name, 'stale');
  });

  testWidgets('a structural folder offers no delete even when empty', (
    tester,
  ) async {
    final root = buildDir('root', [
      buildDir('specimen', const [], isStructural: true),
    ]);

    await pump(tester, root, onDeleteDirectory: (_) {});

    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
  });

  testWidgets('a folder with files offers no folder delete', (tester) async {
    final root = buildDir('root', [
      buildDir('media', [
        buildFile(
          'kept.jpg',
          status: NahpuFileStatus.linked,
          reason: NahpuLockReason.mediaRecord,
        ),
      ]),
    ]);

    await pump(tester, root, onDeleteDirectory: (_) {});

    // The linked file has no delete either, so the row shows none at all.
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
  });

  testWidgets('selection mode hides the empty-folder delete', (tester) async {
    final root = buildDir('root', [buildDir('stale', const [])]);

    await pump(tester, root, isSelecting: true, onDeleteDirectory: (_) {});

    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
  });

  testWidgets('a directory reports its unlinked count', (tester) async {
    final root = buildDir('root', [
      buildDir('media', [
        buildFile('a.jpg', status: NahpuFileStatus.dangling),
        buildFile('b.jpg', status: NahpuFileStatus.linked),
      ]),
    ]);

    await pump(tester, root);
    expect(find.textContaining('1 unlinked'), findsOneWidget);
  });
}
