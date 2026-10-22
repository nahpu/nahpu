import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// App bar search across every project. Opens the search sheet, then the
/// data table with the search and filters picked there.
class GlobalSearchButton extends StatelessWidget {
  const GlobalSearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('home-global-search'),
      tooltip: 'Search records',
      icon: const Icon(Icons.search),
      onPressed: () => _search(context),
    );
  }

  Future<void> _search(BuildContext context) async {
    final request = await showAdaptiveSheetDialog<DataTableSearchRequest>(
      context: context,
      builder: (context, isSheet) => GlobalSearchSheet(isSheet: isSheet),
    );
    if (request == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            DataTableScreen(allProjects: true, initialSearch: request),
      ),
    );
  }
}

/// Search text with the record type, field, project, and filter options it
/// runs with. Closes with the [DataTableSearchRequest] to open.
class GlobalSearchSheet extends ConsumerStatefulWidget {
  const GlobalSearchSheet({super.key, required this.isSheet});

  /// Shown as a bottom sheet, which closes with its drag handle.
  final bool isSheet;

  @override
  ConsumerState<GlobalSearchSheet> createState() => _GlobalSearchSheetState();
}

class _GlobalSearchSheetState extends ConsumerState<GlobalSearchSheet> {
  final _searchController = TextEditingController();
  DataTableRecordType _type = DataTableRecordType.specimenRecords;
  String? _searchField;
  SpecimenRecordType _specimenType = SpecimenRecordType.allTaxa;
  Set<DataTableQuickFilter> _quickFilters = const {};
  Set<String> _projectUuids = const {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectListProvider).asData?.value ?? const [];
    return AdaptiveSheetDialogBody(
      title: 'Search records',
      showCloseButton: !widget.isSheet,
      actions: [
        TextButton(onPressed: _reset, child: const Text('Reset')),
        FilledButton.icon(
          key: const ValueKey('global-search-submit'),
          onPressed: _submit,
          icon: const Icon(Icons.table_view_outlined),
          label: const Text('Show results'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('global-search-field'),
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Field number, taxon, site, or any value',
            ),
          ),
          const SizedBox(height: NahpuSpacing.lg),
          _SearchSection(
            label: 'Record type',
            child: Wrap(
              spacing: NahpuSpacing.xs,
              runSpacing: NahpuSpacing.xs,
              children: [
                for (final type in DataTableRecordType.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: type == _type,
                    onSelected: (_) => _selectType(type),
                  ),
              ],
            ),
          ),
          _SearchSection(
            label: 'Search in',
            child: DropdownButtonFormField<String?>(
              key: ValueKey('global-search-in-${_type.name}'),
              initialValue: _searchField,
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text('All fields')),
                for (final key in dataTableSearchFieldKeys(_type))
                  DropdownMenuItem(
                    value: key,
                    child: Text(dataTableFieldLabel(key)),
                  ),
              ],
              onChanged: (value) => setState(() => _searchField = value),
            ),
          ),
          if (projects.length > 1)
            _SearchSection(
              label: 'Projects',
              child: Wrap(
                spacing: NahpuSpacing.xs,
                runSpacing: NahpuSpacing.xs,
                children: [
                  FilterChip(
                    label: const Text('All projects'),
                    selected: _projectUuids.isEmpty,
                    onSelected: (_) => setState(() => _projectUuids = const {}),
                  ),
                  for (final project in projects)
                    FilterChip(
                      label: Text(project.name),
                      selected: _projectUuids.contains(project.uuid),
                      onSelected: (selected) => _toggleProject(project.uuid),
                    ),
                ],
              ),
            ),
          if (_type == DataTableRecordType.specimenRecords)
            _SearchSection(
              label: 'Taxa',
              child: DropdownButtonFormField<SpecimenRecordType>(
                initialValue: _specimenType,
                isExpanded: true,
                items: [
                  for (final type in SpecimenRecordType.values)
                    DropdownMenuItem(
                      value: type,
                      child: Text(type.dataTableLabel),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _specimenType = value);
                },
              ),
            ),
          if (_typeQuickFilters.isNotEmpty)
            _SearchSection(
              label: 'Quick filters',
              child: Wrap(
                spacing: NahpuSpacing.xs,
                runSpacing: NahpuSpacing.xs,
                children: [
                  for (final filter in _typeQuickFilters)
                    FilterChip(
                      label: Text(filter.label),
                      selected: _quickFilters.contains(filter),
                      onSelected: (_) => _toggleQuickFilter(filter),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<DataTableQuickFilter> get _typeQuickFilters => [
    for (final filter in DataTableQuickFilter.values)
      if (filter.recordType == _type) filter,
  ];

  void _selectType(DataTableRecordType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      // Fields and quick filters belong to the type they were picked for.
      _searchField = null;
      _quickFilters = const {};
    });
  }

  void _toggleProject(String uuid) {
    setState(() {
      _projectUuids = _projectUuids.contains(uuid)
          ? ({..._projectUuids}..remove(uuid))
          : {..._projectUuids, uuid};
    });
  }

  void _toggleQuickFilter(DataTableQuickFilter filter) {
    setState(() {
      _quickFilters = _quickFilters.contains(filter)
          ? ({..._quickFilters}..remove(filter))
          : {..._quickFilters, filter};
    });
  }

  void _reset() {
    _searchController.clear();
    setState(() {
      _type = DataTableRecordType.specimenRecords;
      _searchField = null;
      _specimenType = SpecimenRecordType.allTaxa;
      _quickFilters = const {};
      _projectUuids = const {};
    });
  }

  void _submit() {
    Navigator.of(context).pop(
      DataTableSearchRequest(
        type: _type,
        search: _searchController.text.trim(),
        searchField: _searchField,
        specimenType: _type == DataTableRecordType.specimenRecords
            ? _specimenType
            : SpecimenRecordType.allTaxa,
        quickFilters: _quickFilters,
        projectUuids: _projectUuids,
      ),
    );
  }
}

/// A labelled group of options in the search sheet.
class _SearchSection extends StatelessWidget {
  const _SearchSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: NahpuSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: NahpuSpacing.sm),
          child,
        ],
      ),
    );
  }
}
