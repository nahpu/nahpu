import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/specimens/fish_lot_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Read-only mean, standard deviation, and range of the lot individuals.
class FishLotSummary extends ConsumerWidget {
  const FishLotSummary({
    super.key,
    required this.specimenUuid,
    required this.weightUnit,
  });

  final String specimenUuid;
  final String weightUnit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final individuals =
        ref.watch(individualBySpecimenProvider(specimenUuid)).asData?.value ??
        const <SpecimenIndividualData>[];
    final stats = FishLotStats.fromIndividuals(
      individuals,
      weightUnit: weightUnit,
    );
    final rows = [
      ('Standard length', 'mm', stats.standardLength),
      ('Total length', 'mm', stats.totalLength),
      ('Weight', weightUnit, stats.weight),
    ];
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormCardSectionLabel(text: 'Lot summary'),
        if (rows.every((row) => row.$3 == null))
          Padding(
            padding: const EdgeInsets.all(NahpuSpacing.md),
            child: Text(
              'Measure individuals to see the mean and standard deviation.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          )
        else
          for (final (label, unit, summary) in rows)
            if (summary != null)
              _MeasurementSummaryTile(
                label: label,
                unit: unit,
                summary: summary,
              ),
      ],
    );
  }
}

class _MeasurementSummaryTile extends StatelessWidget {
  const _MeasurementSummaryTile({
    required this.label,
    required this.unit,
    required this.summary,
  });

  final String label;
  final String unit;
  final MeasurementSummary summary;

  @override
  Widget build(BuildContext context) {
    final sd = summary.standardDeviation;
    final mean = _format(summary.mean);
    return ListTile(
      dense: true,
      title: Text('$label ($unit)'),
      subtitle: Text(
        'Range ${_format(summary.min)}–${_format(summary.max)} · '
        'n = ${summary.count}',
      ),
      trailing: Text(
        sd == null ? 'Mean $mean' : 'Mean $mean ± ${_format(sd)} SD',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  String _format(double value) => value.truncateZeroFixed(2);
}

/// Individuals within a lot, with actions to add, edit, and remove them.
class SpecimenIndividualList extends ConsumerWidget {
  const SpecimenIndividualList({
    super.key,
    required this.specimenUuid,
    required this.weightUnit,
  });

  final String specimenUuid;
  final String weightUnit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final individuals = ref.watch(individualBySpecimenProvider(specimenUuid));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormCardSectionLabel(text: 'Individuals'),
        individuals.when(
          data: (data) => Column(
            children: [
              for (final individual in data)
                _IndividualTile(
                  specimenUuid: specimenUuid,
                  individual: individual,
                  weightUnit: weightUnit,
                ),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('Unable to load individuals: $error'),
        ),
        Center(
          child: TextButton.icon(
            key: const ValueKey('fish-add-individual'),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => IndividualFormDialog(
                specimenUuid: specimenUuid,
                weightUnit: weightUnit,
                suggestedId: '${(individuals.asData?.value.length ?? 0) + 1}',
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add individual'),
          ),
        ),
      ],
    );
  }
}

class _IndividualTile extends ConsumerWidget {
  const _IndividualTile({
    required this.specimenUuid,
    required this.individual,
    required this.weightUnit,
  });

  final String specimenUuid;
  final SpecimenIndividualData individual;
  final String weightUnit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      title: Text(individualLabel(individual)),
      subtitle: Text(_measurements()),
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => IndividualFormDialog(
          specimenUuid: specimenUuid,
          weightUnit: weightUnit,
          individual: individual,
        ),
      ),
      trailing: IconButton(
        tooltip: 'Delete individual',
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, ref),
      ),
    );
  }

  String _measurements() {
    final values = [
      if (individual.standardLength != null)
        'SL ${individual.standardLength!.truncateZero()} mm',
      if (individual.totalLength != null)
        'TL ${individual.totalLength!.truncateZero()} mm',
      if (individual.weight != null)
        '${individual.weight!.truncateZero()} ${individual.weightUnit ?? weightUnit}',
      ?getSpecimenSexLabel(individual.sex),
      if (individual.lifeStage?.isNotEmpty == true) individual.lifeStage!,
    ];
    return values.isEmpty ? 'No measurements' : values.join(' · ');
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete individual?'),
        content: Text(
          'Delete ${individualLabel(individual)} and unlink it from any '
          'specimen parts.',
        ),
        actions: [
          SecondaryButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          PrimaryButton(
            label: 'Delete',
            icon: Icons.delete_outline,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await FishLotServices(
      ref: ref,
    ).deleteIndividual(specimenUuid, individual.id);
  }
}

/// Adds a new individual to a lot or edits [individual].
class IndividualFormDialog extends ConsumerStatefulWidget {
  const IndividualFormDialog({
    super.key,
    required this.specimenUuid,
    required this.weightUnit,
    this.individual,
    this.suggestedId,
  });

  final String specimenUuid;
  final String weightUnit;
  final SpecimenIndividualData? individual;
  final String? suggestedId;

  @override
  IndividualFormDialogState createState() => IndividualFormDialogState();
}

class IndividualFormDialogState extends ConsumerState<IndividualFormDialog> {
  late final SpecimenIndividualCtrModel ctr = widget.individual == null
      ? SpecimenIndividualCtrModel.empty(individualId: widget.suggestedId)
      : SpecimenIndividualCtrModel.fromData(widget.individual!);
  bool _isSaving = false;

  @override
  void dispose() {
    ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.individual == null ? 'Add individual' : 'Edit individual',
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: NahpuBreakpoints.compact),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonTextField(
                key: const ValueKey('individual-id'),
                controller: ctr.individualIdCtr,
                labelText: 'Individual/Tag ID',
                hintText: 'Enter individual or tag ID',
                isLastField: false,
              ),
              CommonNumField(
                key: const ValueKey('individual-standard-length'),
                controller: ctr.standardLengthCtr,
                labelText: 'Standard length (mm)',
                hintText: 'Enter standard length',
                isDouble: true,
                isLastField: false,
              ),
              CommonNumField(
                key: const ValueKey('individual-total-length'),
                controller: ctr.totalLengthCtr,
                labelText: 'Total length (mm)',
                hintText: 'Enter total length',
                isDouble: true,
                isLastField: false,
              ),
              CommonNumField(
                key: const ValueKey('individual-weight'),
                controller: ctr.weightCtr,
                labelText: 'Weight (${widget.weightUnit})',
                hintText: 'Enter weight',
                isDouble: true,
                isLastField: false,
              ),
              SpecimenSexDropdown(
                currentCode: ctr.sexCtr,
                onChanged: (sex) => setState(
                  () =>
                      ctr.sexCtr = sex == null ? null : getSpecimenSexCode(sex),
                ),
              ),
              LifeStageDropdown(
                currentValue: ctr.lifeStageCtr,
                onChanged: (value) => setState(() => ctr.lifeStageCtr = value),
              ),
              CommonTextField(
                controller: ctr.remarkCtr,
                maxLines: 3,
                labelText: 'Remarks',
                hintText: 'Add notes about this individual',
                isLastField: true,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
      actions: [
        SecondaryButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        PrimaryButton(
          key: const ValueKey('individual-save'),
          label: 'Save',
          icon: Icons.save_alt_outlined,
          isRunning: _isSaving,
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final id = ctr.individualIdCtr.text.trim();
    final remark = ctr.remarkCtr.text.trim();
    final form = SpecimenIndividualCompanion(
      individualID: db.Value(id.isEmpty ? null : id),
      standardLength: db.Value(parseMeasurement(ctr.standardLengthCtr.text)),
      totalLength: db.Value(parseMeasurement(ctr.totalLengthCtr.text)),
      weight: db.Value(parseMeasurement(ctr.weightCtr.text)),
      weightUnit: db.Value(widget.weightUnit),
      sex: db.Value(ctr.sexCtr),
      lifeStage: db.Value(ctr.lifeStageCtr),
      remark: db.Value(remark.isEmpty ? null : remark),
    );
    final services = FishLotServices(ref: ref);
    final individual = widget.individual;
    if (individual == null) {
      await services.createIndividual(widget.specimenUuid, form);
    } else {
      await services.updateIndividual(widget.specimenUuid, individual.id, form);
    }
    if (mounted) Navigator.of(context).pop();
  }
}
