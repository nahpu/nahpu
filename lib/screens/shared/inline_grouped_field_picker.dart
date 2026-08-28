import 'package:material_ui/material_ui.dart';

/// A searchable grouped field picker that expands inside its current surface.
class InlineGroupedFieldPicker extends StatefulWidget {
  const InlineGroupedFieldPicker({
    super.key,
    required this.value,
    required this.groups,
    required this.decoration,
    required this.onChanged,
  });

  final String? value;
  final Map<String, List<String>> groups;
  final InputDecoration decoration;
  final ValueChanged<String> onChanged;

  @override
  State<InlineGroupedFieldPicker> createState() =>
      _InlineGroupedFieldPickerState();
}

class _InlineGroupedFieldPickerState extends State<InlineGroupedFieldPicker> {
  late final TextEditingController _searchController;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_refresh);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final value = widget.value?.trim();
    final displayValue = value == null || value.isEmpty
        ? null
        : _displayName(value);
    final tableName = value == null || value.isEmpty ? null : _tableName(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: widget.decoration.labelText,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => setState(() {
              _expanded = !_expanded;
              if (!_expanded) _searchController.clear();
            }),
            child: InputDecorator(
              decoration: widget.decoration.copyWith(
                hintText: displayValue == null ? 'Choose a field' : null,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: Icon(
                  _expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ),
              isEmpty: displayValue == null,
              child: displayValue == null
                  ? null
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(displayValue, overflow: TextOverflow.ellipsis),
                        Text(
                          tableName!,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: SizedBox(
              height: 280,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Search fields or tables',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const Divider(height: 2),
                  Expanded(child: _fieldList(context)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _fieldList(BuildContext context) {
    final groups = _filteredGroups();
    if (groups.isEmpty) return const Center(child: Text('No matching fields.'));
    return ListView(
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              entry.key,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          for (final field in entry.value)
            ListTile(
              dense: true,
              title: Text(_displayName(field)),
              subtitle: Text(entry.key),
              selected: field == widget.value,
              onTap: () {
                widget.onChanged(field);
                setState(() {
                  _expanded = false;
                  _searchController.clear();
                });
              },
            ),
        ],
      ],
    );
  }

  Map<String, List<String>> _filteredGroups() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.groups;
    final result = <String, List<String>>{};
    for (final entry in widget.groups.entries) {
      final tableMatches = entry.key.toLowerCase().contains(query);
      final fields = tableMatches
          ? entry.value
          : entry.value
                .where(
                  (field) => _displayName(field).toLowerCase().contains(query),
                )
                .toList(growable: false);
      if (fields.isNotEmpty) result[entry.key] = fields;
    }
    return result;
  }

  String _tableName(String value) {
    final separator = value.indexOf('::');
    return separator == -1 ? 'Other fields' : value.substring(0, separator);
  }

  String _displayName(String value) {
    final separator = value.lastIndexOf('::');
    return separator == -1 ? value : value.substring(separator + 2);
  }
}
