import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/application/file_tree.dart';
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

NahpuDirectoryNode buildDir(String name, List<NahpuTreeNode> children) {
  final dangling = children
      .whereType<NahpuFileNode>()
      .where((e) => e.isDangling)
      .length;
  return NahpuDirectoryNode(
    path: '/root/$name',
    name: name,
    sizeBytes: children.fold(0, (sum, e) => sum + e.sizeBytes),
    children: children,
    fileCount: children.whereType<NahpuFileNode>().length,
    danglingCount: dangling,
    danglingBytes: dangling * 1024,
    unmanagedCount: children
        .whereType<NahpuFileNode>()
        .where((e) => e.status == NahpuFileStatus.unmanaged)
        .length,
    isEntirelyDangling: false,
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

  testWidgets('selection mode swaps row actions for checkboxes', (
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

    // Only the removable file gets a checkbox; the linked one keeps its lock.
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(toggled?.name, 'orphan.jpg');
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
