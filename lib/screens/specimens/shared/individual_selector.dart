import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/specimens/fish_lot_services.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Chooses the lot individuals a part or parasite came from.
///
/// Linked individuals show as tags above an "Add individual" dropdown that
/// lists only the ones not yet linked. A tag is removed through its delete
/// icon after a confirmation, so a stray tap cannot unlink an individual.
/// [selectedIds] is updated in place. Renders nothing for specimens without
/// individuals, so any catalog format can host it.
class SpecimenIndividualSelector extends ConsumerStatefulWidget {
  const SpecimenIndividualSelector({
    super.key,
    required this.specimenUuid,
    required this.selectedIds,
  });

  final String specimenUuid;
  final Set<int> selectedIds;

  @override
  SpecimenIndividualSelectorState createState() =>
      SpecimenIndividualSelectorState();
}

class SpecimenIndividualSelectorState
    extends ConsumerState<SpecimenIndividualSelector> {
  /// Bumped after each pick so the dropdown returns to its hint.
  int _pickCount = 0;

  @override
  Widget build(BuildContext context) {
    final individuals =
        ref
            .watch(individualBySpecimenProvider(widget.specimenUuid))
            .asData
            ?.value ??
        const <SpecimenIndividualData>[];
    if (individuals.isEmpty) return const SizedBox.shrink();
    final selectedIds = widget.selectedIds;
    final selected = individuals
        .where((e) => selectedIds.contains(e.id))
        .toList(growable: false);
    final available = individuals
        .where((e) => !selectedIds.contains(e.id))
        .toList(growable: false);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    // Full width so the tags align to the start of a centred host column.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Individuals',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: NahpuSpacing.md),
          if (selected.isEmpty)
            Text('None selected', style: muted)
          else
            Wrap(
              spacing: NahpuSpacing.md,
              runSpacing: NahpuSpacing.md,
              children: [
                for (final individual in selected)
                  Tooltip(
                    message: _measurements(individual),
                    child: InputChip(
                      key: ValueKey('individual-selected-${individual.id}'),
                      label: Text(individualShortId(individual)),
                      deleteButtonTooltipMessage:
                          'Remove ${individualShortId(individual)}',
                      onDeleted: () => _confirmRemove(individual),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: NahpuSpacing.md),
          DropdownButtonFormField<int>(
            key: ValueKey('individual-add-$_pickCount'),
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Add individual',
              prefixIcon: const Icon(Icons.add),
              helperText: available.isEmpty ? 'All individuals added' : null,
            ),
            hint: const Text('Select an individual'),
            items: [
              for (final individual in available)
                DropdownMenuItem(
                  value: individual.id,
                  child: Row(
                    children: [
                      Text(individualShortId(individual)),
                      const SizedBox(width: NahpuSpacing.md),
                      Expanded(
                        child: Text(
                          _measurements(individual),
                          style: muted,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            selectedItemBuilder: (context) => [
              for (final individual in available)
                Text(individualShortId(individual)),
            ],
            onChanged: available.isEmpty
                ? null
                : (id) {
                    if (id == null) return;
                    setState(() {
                      selectedIds.add(id);
                      _pickCount++;
                    });
                  },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(SpecimenIndividualData individual) async {
    final label = individualShortId(individual);
    final confirmed = await showAdaptiveConfirmation(
      context: context,
      title: 'Remove $label?',
      message:
          'This record will no longer be linked to individual $label. '
          'The individual itself is kept.',
      confirmLabel: 'Remove',
      confirmIcon: Icons.link_off,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => widget.selectedIds.remove(individual.id));
  }

  String _measurements(SpecimenIndividualData individual) {
    final values = [
      if (individual.standardLength != null)
        'SL ${individual.standardLength!.truncateZero()} mm',
      if (individual.totalLength != null)
        'TL ${individual.totalLength!.truncateZero()} mm',
      if (individual.weight != null)
        '${individual.weight!.truncateZero()} ${individual.weightUnit ?? 'g'}',
    ];
    return values.isEmpty ? 'Not measured' : values.join(' · ');
  }
}
