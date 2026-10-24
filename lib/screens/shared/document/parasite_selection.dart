import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/parasite_queries.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Parasite-level document selection. A row represents one parasite record,
/// while the subtitle retains the host specimen's numbers.
class ParasiteSelectionView extends ConsumerStatefulWidget {
  const ParasiteSelectionView({
    super.key,
    required this.selectedIds,
    required this.onSelectionChanged,
    this.isSingleSelection = false,
  });

  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final bool isSingleSelection;

  @override
  ConsumerState<ParasiteSelectionView> createState() =>
      _ParasiteSelectionViewState();
}

class _ParasiteSelectionViewState extends ConsumerState<ParasiteSelectionView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final parasites = ref.watch(parasiteEntryProvider);
    return parasites.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(l10n.documentParasitesLoadError(error.toString())),
      ),
      data: (records) {
        final filtered = records
            .where((record) => _matches(record, l10n))
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
              child: TextField(
                decoration: InputDecoration(
                  labelText: l10n.documentParasitesSearch,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _query = value),
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
                    ? l10n.documentParasitesSummaryHidden(
                        filtered.length,
                        records.length,
                        widget.selectedIds.length,
                        hiddenSelectedCount,
                      )
                    : l10n.documentParasitesSummary(
                        filtered.length,
                        records.length,
                        widget.selectedIds.length,
                      ),
              ),
            ),
            const SizedBox(height: NahpuSpacing.md),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(l10n.documentParasitesEmpty))
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

  bool _matches(ParasiteProjectRecord record, AppLocalizations l10n) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    return '${_title(record, l10n)} ${_subtitle(record, l10n)}'
        .toLowerCase()
        .contains(query);
  }

  String _title(ParasiteProjectRecord record, AppLocalizations l10n) {
    final parasite = record.parasite;
    final identifier = parasite.parasiteID?.trim().isNotEmpty == true
        ? parasite.parasiteID!
        : l10n.documentParasiteFallbackTitle(parasite.id.toString());
    final category = parasite.category?.trim();
    return category == null || category.isEmpty
        ? identifier
        : '$identifier · $category';
  }

  String _subtitle(ParasiteProjectRecord record, AppLocalizations l10n) {
    final parasite = record.parasite;
    final specimen = record.specimen;
    final values = <String>[
      if (specimen.fieldNumber != null)
        l10n.documentPartFieldNumber(specimen.fieldNumber.toString()),
      if (specimen.projectFieldNumber != null)
        l10n.documentPartProjectNumber(specimen.projectFieldNumber.toString()),
      if (specimen.museumID?.isNotEmpty == true)
        l10n.documentPartCatalog(specimen.museumID!),
      if (parasite.anatomicalLocation?.isNotEmpty == true)
        parasite.anatomicalLocation!,
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
