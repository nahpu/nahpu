import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/document/specimen_part_filter_dialog.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/export/specimen_part_filter.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Part-level document selection. A row represents one specimenPart record,
/// while the subtitle retains enough parent context to select tissues safely.
class SpecimenPartSelectionView extends ConsumerStatefulWidget {
  const SpecimenPartSelectionView({
    super.key,
    required this.selectedIds,
    required this.onSelectionChanged,
    this.isSingleSelection = false,
  });

  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final bool isSingleSelection;

  @override
  ConsumerState<SpecimenPartSelectionView> createState() =>
      _SpecimenPartSelectionViewState();
}

class _SpecimenPartSelectionViewState
    extends ConsumerState<SpecimenPartSelectionView> {
  String _query = '';
  SpecimenPartFilter _filter = const SpecimenPartFilter.empty();

  @override
  Widget build(BuildContext context) {
    final parts = ref.watch(specimenPartEntryProvider);
    return parts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Unable to load parts: $error')),
      data: (records) {
        final filtered = records
            .where((record) => _filter.matches(record, query: _query))
            .toList(growable: false);
        final matchingIds = filtered
            .map((record) => record.recordId)
            .whereType<String>()
            .toSet();
        final hiddenSelectedCount = widget.selectedIds
            .difference(matchingIds)
            .length;
        final isExactSelection =
            widget.selectedIds.length == matchingIds.length &&
            widget.selectedIds.containsAll(matchingIds);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(NahpuSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search parts or specimen numbers',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  const SizedBox(width: NahpuSpacing.md),
                  IconButton(
                    tooltip: _filter.isActive
                        ? 'Filter specimen parts (active)'
                        : 'Filter specimen parts',
                    onPressed: () => _openFilters(records),
                    icon: Badge(
                      isLabelVisible: _filter.isActive,
                      child: const Icon(Icons.filter_alt_outlined),
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.isSingleSelection)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NahpuSpacing.md,
                ),
                child: Wrap(
                  spacing: NahpuSpacing.md,
                  children: [
                    TextButton(
                      onPressed: widget.selectedIds.isEmpty
                          ? null
                          : () => widget.onSelectionChanged(<String>{}),
                      child: const Text('Clear'),
                    ),
                    TextButton(
                      onPressed: matchingIds.isEmpty || isExactSelection
                          ? null
                          : () => widget.onSelectionChanged(matchingIds),
                      child: const Text('Select All'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xl),
              child: Text(
                'Showing ${filtered.length} of ${records.length} parts · '
                'Selected ${widget.selectedIds.length}'
                '${hiddenSelectedCount > 0 ? ' ($hiddenSelectedCount hidden)' : ''}',
              ),
            ),
            const SizedBox(height: NahpuSpacing.md),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No specimen parts found'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final record = filtered[index];
                        final id = record.recordId;
                        if (id == null) return const SizedBox.shrink();
                        final selected = widget.selectedIds.contains(id);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (value) => _toggle(id, value == true),
                          title: Text(_title(record)),
                          subtitle: Text(_subtitle(record)),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openFilters(List<SpecimenPartProjectRecord> records) async {
    FocusScope.of(context).unfocus();
    final filter = await showSpecimenPartFilterDialog(
      context: context,
      filter: _filter,
      typeOptions: SpecimenPartFilter.typeOptionsFor(records),
    );
    if (filter != null && mounted) setState(() => _filter = filter);
  }

  String _title(SpecimenPartProjectRecord record) {
    final part = record.part;
    final identifier = part.tissueID?.trim().isNotEmpty == true
        ? part.tissueID!
        : part.barcodeID?.trim().isNotEmpty == true
        ? part.barcodeID!
        : 'Part ${part.id}';
    final type = part.type?.trim();
    return type == null || type.isEmpty ? identifier : '$identifier · $type';
  }

  String _subtitle(SpecimenPartProjectRecord record) {
    final part = record.part;
    final specimen = record.specimen;
    final values = <String>[
      if (specimen.fieldNumber != null) 'Field no. ${specimen.fieldNumber}',
      if (specimen.projectFieldNumber != null)
        'Project no. ${specimen.projectFieldNumber}',
      if (specimen.museumID?.isNotEmpty == true) 'Catalog ${specimen.museumID}',
      if (part.treatment?.isNotEmpty == true) part.treatment!,
    ];
    return values.isEmpty ? 'Specimen ${specimen.uuid}' : values.join(' · ');
  }

  void _toggle(String id, bool selected) {
    final next = Set<String>.from(widget.selectedIds);
    if (selected) {
      if (widget.isSingleSelection) next.clear();
      next.add(id);
    } else {
      next.remove(id);
    }
    widget.onSelectionChanged(next);
  }
}
