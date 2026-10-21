import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_edits.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// View or edit mode, auto-save, save status, and Save and Discard.
class DataTableEditToolbar extends StatelessWidget {
  const DataTableEditToolbar({
    super.key,
    required this.isEditMode,
    required this.edits,
    required this.onModeChanged,
    required this.onAutoSaveChanged,
    required this.onSave,
    required this.onDiscard,
  });

  final bool isEditMode;
  final DataTableEditController edits;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<bool> onAutoSaveChanged;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: edits,
      builder: (context, _) => Wrap(
        spacing: NahpuSpacing.lg,
        runSpacing: NahpuSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(shape: const StadiumBorder()),
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.visibility_outlined),
                label: Text('View'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.edit_outlined),
                label: Text('Edit'),
              ),
            ],
            selected: {isEditMode},
            onSelectionChanged: (value) => onModeChanged(value.first),
          ),
          if (isEditMode)
            Tooltip(
              message:
                  'Save each change as you commit it. Undo with Ctrl+Z or ⌘Z '
                  'while this table is open.',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(value: edits.autoSave, onChanged: onAutoSaveChanged),
                  const SizedBox(width: NahpuSpacing.xs),
                  Text('Auto-save', style: theme.textTheme.labelLarge),
                ],
              ),
            ),
          if (isEditMode || edits.hasPending) DataTableSaveStatus(edits: edits),
          if (edits.hasPending) ...[
            TextButton(onPressed: onDiscard, child: const Text('Discard')),
            FilledButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: Text(edits.failedCount > 0 ? 'Retry save' : 'Save'),
              onPressed: edits.isSaving ? null : onSave,
            ),
          ],
        ],
      ),
    );
  }
}

class DataTableSaveStatus extends StatelessWidget {
  const DataTableSaveStatus({super.key, required this.edits});

  final DataTableEditController edits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final failed = edits.failedCount;
    final pending = edits.pendingCount;
    final (text, color) = edits.isSaving
        ? ('Saving…', theme.colorScheme.onSurfaceVariant)
        : failed > 0
        ? (
            failed == 1
                ? '1 cell needs attention'
                : '$failed cells need attention',
            theme.colorScheme.error,
          )
        : pending > 0
        ? (
            pending == 1 ? '1 unsaved change' : '$pending unsaved changes',
            theme.colorScheme.tertiary,
          )
        : ('All changes saved', theme.colorScheme.onSurfaceVariant);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(color: color),
    );
  }
}
