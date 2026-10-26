import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/document/specimen_part_filter_dialog.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/export/specimen_part_filter.dart';
import 'package:nahpu/services/localization/l10n.dart';
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
    final l10n = context.l10n;
    final parts = ref.watch(specimenPartEntryProvider);
    return parts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text(l10n.documentPartsLoadError(error.toString()))),
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
                      decoration: InputDecoration(
                        labelText: l10n.documentPartsSearch,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  const SizedBox(width: NahpuSpacing.md),
                  IconButton(
                    tooltip: _filter.isActive
                        ? l10n.documentPartFilterActive
                        : l10n.documentPartFilterTitle,
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
                      child: Text(l10n.commonClear),
                    ),
                    TextButton(
                      onPressed: matchingIds.isEmpty || isExactSelection
                          ? null
                          : () => widget.onSelectionChanged(matchingIds),
                      child: Text(l10n.commonSelectAll),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xl),
              child: Text(
                hiddenSelectedCount > 0
                    ? l10n.documentPartsSummaryHidden(
                        filtered.length,
                        records.length,
                        widget.selectedIds.length,
                        hiddenSelectedCount,
                      )
                    : l10n.documentPartsSummary(
                        filtered.length,
                        records.length,
                        widget.selectedIds.length,
                      ),
              ),
            ),
            const SizedBox(height: NahpuSpacing.md),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(l10n.documentPartsEmpty))
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
                          title: Text(_title(record, l10n)),
                          subtitle: Text(_subtitle(record, l10n)),
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

  String _title(SpecimenPartProjectRecord record, AppLocalizations l10n) {
    final part = record.part;
    final identifier = part.tissueID?.trim().isNotEmpty == true
        ? part.tissueID!
        : part.barcodeID?.trim().isNotEmpty == true
        ? part.barcodeID!
        : l10n.documentPartFallbackTitle(part.id.toString());
    final type = part.type?.trim();
    return type == null || type.isEmpty ? identifier : '$identifier · $type';
  }

  String _subtitle(SpecimenPartProjectRecord record, AppLocalizations l10n) {
    final part = record.part;
    final specimen = record.specimen;
    final values = <String>[
      if (specimen.fieldNumber != null)
        l10n.documentPartFieldNumber(specimen.fieldNumber.toString()),
      if (specimen.projectFieldNumber != null)
        l10n.documentPartProjectNumber(specimen.projectFieldNumber.toString()),
      if (specimen.museumID?.isNotEmpty == true)
        l10n.documentPartCatalog(specimen.museumID!),
      if (part.treatment?.isNotEmpty == true) part.treatment!,
    ];
    return values.isEmpty
        ? l10n.documentPartSpecimenFallback(specimen.uuid)
        : values.join(' · ');
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
