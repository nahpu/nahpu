import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/record_sort.dart';
import 'package:nahpu/services/types/record_sort.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Opens the page sort picker for [viewer].
///
/// Resolves to the applied sort, or null when the user cancels. Applying
/// writes [recordSortProvider], which the viewer's record list watches, so the
/// pages reorder as soon as this returns.
Future<RecordSort?> showRecordSortDialog({
  required BuildContext context,
  required RecordViewer viewer,
}) {
  return showDialog<RecordSort>(
    context: context,
    builder: (context) => RecordSortDialog(viewer: viewer),
  );
}

class RecordSortDialog extends ConsumerStatefulWidget {
  const RecordSortDialog({super.key, required this.viewer});

  final RecordViewer viewer;

  @override
  ConsumerState<RecordSortDialog> createState() => _RecordSortDialogState();
}

class _RecordSortDialogState extends ConsumerState<RecordSortDialog> {
  /// The pending choice. Held locally and committed on Apply so that tapping
  /// through the options does not refetch the record list behind the dialog.
  late RecordSort _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(recordSortProvider(widget.viewer));
  }

  @override
  Widget build(BuildContext context) {
    final fields = recordSortFields[widget.viewer] ?? const <RecordSortField>[];
    return AlertDialog(
      title: const Text('Sort records'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: NahpuContentWidth.form),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioGroup<RecordSortField>(
                groupValue: _draft.field,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _draft = _draft.copyWith(field: value));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final field in fields)
                      RadioListTile<RecordSortField>(
                        value: field,
                        title: Text(field.labelFor(widget.viewer)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: NahpuSpacing.md),
              Text(
                'Order',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: NahpuSpacing.sm),
              SegmentedButton<RecordSortDirection>(
                segments: [
                  for (final direction in RecordSortDirection.values)
                    ButtonSegment<RecordSortDirection>(
                      value: direction,
                      label: Text(direction.label),
                      icon: Icon(
                        direction == RecordSortDirection.ascending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                      ),
                    ),
                ],
                selected: {_draft.direction},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  setState(
                    () => _draft = _draft.copyWith(direction: selection.first),
                  );
                },
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
        FilledButton(
          onPressed: () {
            ref.read(recordSortProvider(widget.viewer).notifier).set(_draft);
            Navigator.pop(context, _draft);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
