import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_link_service.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Picks an existing site or event for a group to link to.
class BatchLinkExistingDialog extends StatefulWidget {
  const BatchLinkExistingDialog({
    super.key,
    required this.title,
    required this.options,
  });

  final String title;
  final Future<List<DataTableLinkOption>> options;

  @override
  State<BatchLinkExistingDialog> createState() =>
      _BatchLinkExistingDialogState();
}

class _BatchLinkExistingDialogState extends State<BatchLinkExistingDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: NahpuContentWidth.dialog,
        height: NahpuContentWidth.dialog,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search',
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
            const SizedBox(height: NahpuSpacing.md),
            Expanded(
              child: FutureBuilder<List<DataTableLinkOption>>(
                future: widget.options,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Couldn\'t load records: ${snapshot.error}');
                  }
                  final options = snapshot.data;
                  if (options == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final shown = [
                    for (final option in options)
                      if (option.id != null &&
                          ('${option.label} ${option.detail ?? ''}')
                              .toLowerCase()
                              .contains(_query))
                        option,
                  ];
                  if (shown.isEmpty) {
                    return const Center(child: Text('No matching records.'));
                  }
                  return ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (context, index) {
                      final option = shown[index];
                      final detail = option.detail;
                      return ListTile(
                        title: Text(option.label),
                        subtitle: detail == null || detail.isEmpty
                            ? null
                            : Text(detail),
                        onTap: () => Navigator.of(context).pop(option),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Edits the site ID or event suffix a new record gets.
class BatchRenameGroupDialog extends StatefulWidget {
  const BatchRenameGroupDialog({
    super.key,
    required this.title,
    required this.label,
    required this.initialValue,
  });

  final String title;
  final String label;
  final String initialValue;

  @override
  State<BatchRenameGroupDialog> createState() => _BatchRenameGroupDialogState();
}

class _BatchRenameGroupDialogState extends State<BatchRenameGroupDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: NahpuContentWidth.dialog,
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(labelText: widget.label),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Picks the group another one merges into.
class BatchMergeGroupDialog extends StatelessWidget {
  const BatchMergeGroupDialog({
    super.key,
    required this.title,
    required this.groups,
  });

  final String title;

  /// Candidate groups as (id, label, detail).
  final List<(String, String, String)> groups;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: NahpuContentWidth.dialog,
        child: groups.isEmpty
            ? const Text('There is no other group to merge with.')
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final (id, label, detail) in groups)
                    ListTile(
                      title: Text(label),
                      subtitle: Text(detail),
                      onTap: () => Navigator.of(context).pop(id),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Picks the rows that move out of a group into a new one.
class BatchSplitGroupDialog extends StatefulWidget {
  const BatchSplitGroupDialog({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;

  /// The group's rows as (table row index, description).
  final List<(int, String)> rows;

  @override
  State<BatchSplitGroupDialog> createState() => _BatchSplitGroupDialogState();
}

class _BatchSplitGroupDialogState extends State<BatchSplitGroupDialog> {
  final _selected = <int>{};

  @override
  Widget build(BuildContext context) {
    // Moving every row would leave the group empty.
    final valid = _selected.isNotEmpty && _selected.length < widget.rows.length;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: NahpuContentWidth.dialog,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final (row, description) in widget.rows)
              CheckboxListTile(
                value: _selected.contains(row),
                title: Text(description),
                onChanged: (checked) => setState(() {
                  if (checked ?? false) {
                    _selected.add(row);
                  } else {
                    _selected.remove(row);
                  }
                }),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: valid
              ? () => Navigator.of(context).pop(Set<int>.of(_selected))
              : null,
          child: const Text('Move to new group'),
        ),
      ],
    );
  }
}
