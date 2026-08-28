import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as path;

/// What the user chose to do with a selection.
enum SelectionAction { export, delete }

/// One top-level location in the selection summary.
///
/// Grouping by location rather than by file type is deliberate: "clear up
/// space" is a question about which project or folder is holding the bytes, and
/// a flat list of two hundred filenames answers nothing.
class SelectionGroup {
  const SelectionGroup({
    required this.label,
    required this.detail,
    required this.fileCount,
    required this.sizeBytes,
  });

  final String label;

  /// Secondary line: the project name, and the mix of file kinds.
  final String detail;
  final int fileCount;
  final int sizeBytes;
}

/// Summarises [paths] by their top-level folder under the app directory.
List<SelectionGroup> summarizeSelection({
  required String root,
  required List<String> paths,
  required NahpuDirectoryNode tree,
}) {
  final sizes = <String, int>{};
  final counts = <String, int>{};
  final kinds = <String, Map<MediaKind, int>>{};
  final subtitles = <String, String>{};

  final nodesByPath = <String, NahpuFileNode>{};
  final directoryLabels = <String, String>{};
  void index(NahpuTreeNode node) {
    switch (node) {
      case NahpuFileNode():
        nodesByPath[node.path] = node;
      case NahpuDirectoryNode():
        directoryLabels[node.path] = node.subtitle ?? '';
        node.children.forEach(index);
    }
  }

  index(tree);

  for (final filePath in paths) {
    final relative = path.isWithin(root, filePath)
        ? path.relative(filePath, from: root)
        : filePath;
    final segments = path.split(relative);
    // A file sitting directly in the app folder has no folder to group under.
    final key = segments.length > 1 ? segments.first : '.';

    counts[key] = (counts[key] ?? 0) + 1;
    sizes[key] = (sizes[key] ?? 0) + (nodesByPath[filePath]?.sizeBytes ?? 0);

    final kind = matchMediaKindFromPath(filePath);
    kinds.putIfAbsent(key, () => <MediaKind, int>{});
    kinds[key]![kind] = (kinds[key]![kind] ?? 0) + 1;

    if (key != '.' && !subtitles.containsKey(key)) {
      final label = directoryLabels[path.join(root, key)] ?? '';
      // The scanner writes "12 files · Project Name"; only the name is wanted.
      final parts = label.split(' · ');
      if (parts.length > 1) subtitles[key] = parts.sublist(1).join(' · ');
    }
  }

  final groups = counts.keys.map((key) {
    final detail = <String>[];
    final name = subtitles[key];
    if (name != null && name.isNotEmpty) detail.add(name);
    final kindCounts = kinds[key] ?? const <MediaKind, int>{};
    final ordered = kindCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    detail.addAll(
      ordered.map(
        (entry) =>
            '${entry.value} ${matchMediaKindLabel(entry.key).toLowerCase()}',
      ),
    );
    return SelectionGroup(
      label: key == '.' ? 'Application folder' : key,
      detail: detail.join(' · '),
      fileCount: counts[key]!,
      sizeBytes: sizes[key]!,
    );
  }).toList();

  groups.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
  return groups;
}

/// Shows what the user selected and offers the two ways out of it.
Future<SelectionAction?> showSelectionReview({
  required BuildContext context,
  required List<SelectionGroup> groups,
  required int fileCount,
  required int sizeBytes,
}) {
  return showDialog<SelectionAction>(
    context: context,
    builder: (context) => SelectionReviewDialog(
      groups: groups,
      fileCount: fileCount,
      sizeBytes: sizeBytes,
    ),
  );
}

class SelectionReviewDialog extends StatelessWidget {
  const SelectionReviewDialog({
    super.key,
    required this.groups,
    required this.fileCount,
    required this.sizeBytes,
  });

  final List<SelectionGroup> groups;
  final int fileCount;
  final int sizeBytes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('$fileCount selected ${fileCount == 1 ? 'file' : 'files'}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: NahpuContentWidth.form),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatByteSize(sizeBytes),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: NahpuSpacing.lg),
              for (final group in groups) _GroupRow(group: group),
              const SizedBox(height: NahpuSpacing.lg),
              Text(
                'Exporting writes these files to one compressed archive outside '
                'NAHPU, then offers to remove the originals. Deleting removes '
                'them straight away and cannot be undone.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: colors.error),
          onPressed: () => Navigator.pop(context, SelectionAction.delete),
          child: const Text('Delete permanently'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, SelectionAction.export),
          icon: const Icon(Icons.archive_outlined),
          label: const Text('Export'),
        ),
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group});

  final SelectionGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (group.detail.isNotEmpty)
                  Text(
                    group.detail,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: NahpuSpacing.lg),
          Text(
            '${group.fileCount} · ${formatByteSize(group.sizeBytes)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
