import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/providers/specimens.dart';

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

  @override
  Widget build(BuildContext context) {
    final parts = ref.watch(specimenPartEntryProvider);
    return parts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Unable to load parts: $error')),
      data: (records) {
        final filtered = records.where(_matches).toList(growable: false);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search tissue ID, barcode, type, field no.',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  if (!widget.isSingleSelection) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Select all matching parts',
                      icon: const Icon(Icons.select_all),
                      onPressed: filtered.isEmpty
                          ? null
                          : () => widget.onSelectionChanged(
                              filtered
                                  .map((e) => e.recordId)
                                  .whereType<String>()
                                  .toSet(),
                            ),
                    ),
                    IconButton(
                      tooltip: 'Clear selection',
                      icon: const Icon(Icons.clear_all),
                      onPressed: widget.selectedIds.isEmpty
                          ? null
                          : () => widget.onSelectionChanged(<String>{}),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selected ${widget.selectedIds.length} of ${records.length} parts',
                ),
              ),
            ),
            const SizedBox(height: 8),
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

  bool _matches(SpecimenPartProjectRecord record) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    final part = record.part;
    final specimen = record.specimen;
    final text = [
      part.tissueID,
      part.barcodeID,
      part.type,
      part.treatment,
      specimen.fieldNumber?.toString(),
      specimen.museumID,
    ].whereType<String>().join(' ').toLowerCase();
    return text.contains(query);
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
