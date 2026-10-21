import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_edits.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';

/// View or edit mode, auto-save, Discard and Save, and the save status.
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
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DataTableEditModeToggle(
            isEditMode: isEditMode,
            onChanged: onModeChanged,
          ),
          if (isEditMode) ...[
            const SizedBox(width: NahpuSpacing.md),
            Tooltip(
              message:
                  'Save each change as you commit it. Undo with Ctrl+Z or ⌘Z '
                  'while this table is open.',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(value: edits.autoSave, onChanged: onAutoSaveChanged),
                  const SizedBox(width: NahpuSpacing.xs),
                  Text('Auto-save', style: theme.textTheme.labelMedium),
                ],
              ),
            ),
          ],
          if (edits.hasPending) ...[
            const SizedBox(width: NahpuSpacing.xs),
            IconButton(
              tooltip: 'Discard changes',
              icon: const Icon(Icons.undo),
              onPressed: onDiscard,
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: NahpuTheme.primaryAction,
                foregroundColor: NahpuTheme.onPrimaryAction,
              ),
              icon: const Icon(
                Icons.save_outlined,
                size: NahpuControlSize.iconSmall,
              ),
              label: Text(edits.failedCount > 0 ? 'Retry save' : 'Save'),
              onPressed: edits.isSaving ? null : onSave,
            ),
          ],
          const SizedBox(width: NahpuSpacing.lg),
          DataTableSaveStatus(isEditMode: isEditMode, edits: edits),
        ],
      ),
    );
  }
}

/// One pill that turns edit mode on and off.
class DataTableEditModeToggle extends StatelessWidget {
  const DataTableEditModeToggle({
    super.key,
    required this.isEditMode,
    required this.onChanged,
  });

  final bool isEditMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isEditMode
          ? 'Edit mode is on (Ctrl+E or ⌘E)'
          : 'Edit mode is off (Ctrl+E or ⌘E)',
      child: FilterChip(
        avatar: Icon(
          isEditMode ? Icons.edit : Icons.edit_outlined,
          size: NahpuControlSize.iconMedium,
        ),
        showCheckmark: false,
        label: const Text('Edit'),
        selected: isEditMode,
        shape: const StadiumBorder(),
        onSelected: onChanged,
      ),
    );
  }
}

/// Saving progress, unsaved or failed edits, and, with auto-save on in
/// edit mode, that everything is saved. Shows nothing otherwise.
class DataTableSaveStatus extends StatelessWidget {
  const DataTableSaveStatus({
    super.key,
    required this.isEditMode,
    required this.edits,
  });

  final bool isEditMode;
  final DataTableEditController edits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: edits,
      builder: (context, _) {
        final status = _status(theme.colorScheme);
        if (status == null) return const SizedBox.shrink();
        final (text, color) = status;
        return Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        );
      },
    );
  }

  (String, Color)? _status(ColorScheme colorScheme) {
    final failed = edits.failedCount;
    final pending = edits.pendingCount;
    if (edits.isSaving) return ('Saving…', colorScheme.onSurfaceVariant);
    if (failed > 0) {
      return (
        failed == 1 ? '1 cell needs attention' : '$failed cells need attention',
        colorScheme.error,
      );
    }
    if (pending > 0) {
      return (
        pending == 1 ? '1 unsaved change' : '$pending unsaved changes',
        NahpuTheme.pendingChange(colorScheme),
      );
    }
    if (isEditMode && edits.autoSave) {
      return ('All changes saved', colorScheme.onSurfaceVariant);
    }
    return null;
  }
}
