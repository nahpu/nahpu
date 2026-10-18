import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
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
    this.totalIndividuals,
  });

  final String specimenUuid;
  final String weightUnit;

  /// Individuals recorded for the whole lot, measured or not.
  final int? totalIndividuals;

  /// Below this width the tiles stack instead of sharing a row.
  static const double _stackedWidth = 480;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final individuals =
        ref.watch(individualBySpecimenProvider(specimenUuid)).asData?.value ??
        const <SpecimenIndividualData>[];
    final stats = FishLotStats.fromIndividuals(
      individuals,
      weightUnit: weightUnit,
    );
    final measured = individuals
        .where(
          (e) =>
              e.standardLength != null ||
              e.totalLength != null ||
              e.weight != null,
        )
        .length;
    final total = totalIndividuals;
    final textTheme = Theme.of(context).textTheme;
    final tiles = [
      _MeasurementStatTile(
        label: 'Standard length',
        unit: 'mm',
        summary: stats.standardLength,
        fractionDigits: 1,
      ),
      _MeasurementStatTile(
        label: 'Total length',
        unit: 'mm',
        summary: stats.totalLength,
        fractionDigits: 1,
      ),
      _MeasurementStatTile(
        label: 'Weight',
        unit: weightUnit,
        summary: stats.weight,
        fractionDigits: 2,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NahpuSpacing.xs,
        vertical: NahpuSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text('Lot summary', style: textTheme.titleMedium),
              ),
              Text(
                total == null
                    ? '$measured measured'
                    : '$measured of $total individuals measured',
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: NahpuSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _stackedWidth) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, tile) in tiles.indexed) ...[
                      if (index > 0) const SizedBox(height: NahpuSpacing.md),
                      tile,
                    ],
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, tile) in tiles.indexed) ...[
                      if (index > 0) const SizedBox(width: NahpuSpacing.md),
                      Expanded(child: tile),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// One measurement in the lot summary: the mean with its unit, then the
/// spread, then the range.
class _MeasurementStatTile extends StatelessWidget {
  const _MeasurementStatTile({
    required this.label,
    required this.unit,
    required this.summary,
    required this.fractionDigits,
  });

  final String label;
  final String unit;
  final MeasurementSummary? summary;
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final summary = this.summary;
    final sd = summary?.standardDeviation;
    return Container(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(NahpuRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: muted),
          const SizedBox(height: NahpuSpacing.xxs),
          Text.rich(
            TextSpan(
              text: summary == null ? '–' : _format(summary.mean),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              children: [
                if (summary != null)
                  TextSpan(
                    text: ' $unit',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            summary == null
                ? 'Not measured'
                : [
                    if (sd != null) '± ${_format(sd)} SD',
                    'n = ${summary.count}',
                  ].join(' · '),
            style: muted,
          ),
          if (summary != null) ...[
            const Divider(height: NahpuSpacing.lg),
            Text(
              'Range ${_format(summary.min)}–${_format(summary.max)} $unit',
              style: muted,
            ),
          ],
        ],
      ),
    );
  }

  String _format(double value) => value.truncateZeroFixed(fractionDigits);
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
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: NahpuSpacing.xs,
        vertical: NahpuSpacing.md,
      ),
      padding: const EdgeInsets.all(NahpuSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: NahpuStroke.thin,
        ),
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
      ),
      child: Column(
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
      ),
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
    final confirmed = await showAdaptiveConfirmation(
      context: context,
      title: 'Delete ${individualLabel(individual)}?',
      message:
          'This deletes the individual and unlinks it from any specimen parts '
          'and parasites.',
      confirmLabel: 'Delete',
      confirmIcon: Icons.delete_outline,
      isDestructive: true,
    );
    if (!confirmed) return;
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
