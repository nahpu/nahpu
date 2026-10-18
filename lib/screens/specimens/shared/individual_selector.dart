import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/specimens/fish_lot_services.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Chips for choosing the lot individuals a part or parasite came from.
///
/// [selectedIds] is updated in place as chips are toggled. Renders nothing for
/// specimens without individuals, so any catalog format can host it.
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
  @override
  Widget build(BuildContext context) {
    final individuals =
        ref
            .watch(individualBySpecimenProvider(widget.specimenUuid))
            .asData
            ?.value ??
        const <SpecimenIndividualData>[];
    if (individuals.isEmpty) return const SizedBox.shrink();
    final selected = widget.selectedIds;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Individuals', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: NahpuSpacing.xs),
          Wrap(
            spacing: NahpuSpacing.md,
            runSpacing: NahpuSpacing.xs,
            children: [
              for (final individual in individuals)
                FilterChip(
                  key: ValueKey('individual-chip-${individual.id}'),
                  label: Text(individualShortId(individual)),
                  selected: selected.contains(individual.id),
                  onSelected: (isSelected) => setState(() {
                    if (isSelected) {
                      selected.add(individual.id);
                    } else {
                      selected.remove(individual.id);
                    }
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
