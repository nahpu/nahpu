import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/numbered_id_fields.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
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
import 'package:nahpu/services/localization/l10n.dart';

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
        label: context.l10n.fishStandardLengthShort,
        unit: 'mm',
        summary: stats.standardLength,
        fractionDigits: 1,
      ),
      _MeasurementStatTile(
        label: context.l10n.fishTotalLengthShort,
        unit: 'mm',
        summary: stats.totalLength,
        fractionDigits: 1,
      ),
      _MeasurementStatTile(
        label: context.l10n.fishWeight,
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
                child: Text(
                  context.l10n.fishLotSummary,
                  style: textTheme.titleMedium,
                ),
              ),
              Text(
                total == null
                    ? context.l10n.fishMeasuredCount(measured)
                    : context.l10n.fishMeasuredOfTotal(measured, total),
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
                ? context.l10n.fishNotMeasured
                : [
                    if (sd != null)
                      context.l10n.fishStandardDeviation(_format(sd)),
                    'n = ${summary.count}',
                  ].join(' · '),
            style: muted,
          ),
          if (summary != null) ...[
            const Divider(height: NahpuSpacing.lg),
            Text(
              context.l10n.fishRange(
                _format(summary.min),
                _format(summary.max),
                unit,
              ),
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
    this.totalIndividuals,
  });

  final String specimenUuid;
  final String weightUnit;

  /// Individuals recorded for the whole lot, shown in the form header.
  final int? totalIndividuals;

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
          FormCardSectionLabel(text: context.l10n.fishIndividuals),
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
            error: (error, _) =>
                Text(context.l10n.fishIndividualsLoadError('$error')),
          ),
          Center(
            child: TextButton.icon(
              key: const ValueKey('fish-add-individual'),
              onPressed: () => showIndividualForm(
                context: context,
                specimenUuid: specimenUuid,
                weightUnit: weightUnit,
                enteredCount: individuals.asData?.value.length ?? 0,
                totalIndividuals: totalIndividuals,
                suggestedId: '${(individuals.asData?.value.length ?? 0) + 1}',
              ),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.fishAddIndividual),
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
      subtitle: Text(_measurements(context.l10n)),
      onTap: () => showIndividualForm(
        context: context,
        specimenUuid: specimenUuid,
        weightUnit: weightUnit,
        individual: individual,
      ),
      trailing: IconButton(
        tooltip: context.l10n.fishDeleteIndividual,
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, ref),
      ),
    );
  }

  String _measurements(AppLocalizations l10n) {
    final values = [
      if (individual.standardLength != null)
        l10n.fishStandardLengthValue(individual.standardLength!.truncateZero()),
      if (individual.totalLength != null)
        l10n.fishTotalLengthValue(individual.totalLength!.truncateZero()),
      if (individual.weight != null)
        '${individual.weight!.truncateZero()} ${individual.weightUnit ?? weightUnit}',
      ?getSpecimenSexLabel(individual.sex),
      if (individual.lifeStage?.isNotEmpty == true) individual.lifeStage!,
    ];
    return values.isEmpty ? l10n.fishNoMeasurements : values.join(' · ');
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAdaptiveConfirmation(
      context: context,
      title: context.l10n.fishDeleteIndividualTitle(
        individualLabel(individual),
      ),
      message: context.l10n.fishDeleteIndividualBody,
      confirmLabel: context.l10n.commonDelete,
      confirmIcon: Icons.delete_outline,
      isDestructive: true,
    );
    if (!confirmed) return;
    await FishLotServices(
      ref: ref,
    ).deleteIndividual(specimenUuid, individual.id);
  }
}

/// Opens the individual form: a wide two-column dialog, or a one-column
/// bottom sheet on compact screens. Edits [individual], or adds a new one.
Future<void> showIndividualForm({
  required BuildContext context,
  required String specimenUuid,
  required String weightUnit,
  SpecimenIndividualData? individual,
  int enteredCount = 0,
  int? totalIndividuals,
  String? suggestedId,
}) {
  return showAdaptiveSheetDialog<void>(
    context: context,
    isDismissible: false,
    maxWidth: NahpuContentWidth.projectForm,
    builder: (context, isSheet) => IndividualForm(
      specimenUuid: specimenUuid,
      weightUnit: weightUnit,
      individual: individual,
      enteredCount: enteredCount,
      totalIndividuals: totalIndividuals,
      suggestedId: suggestedId,
      isSheet: isSheet,
    ),
  );
}

/// Adds a new individual to a lot or edits [individual].
class IndividualForm extends ConsumerStatefulWidget {
  const IndividualForm({
    super.key,
    required this.specimenUuid,
    required this.weightUnit,
    required this.isSheet,
    this.individual,
    this.enteredCount = 0,
    this.totalIndividuals,
    this.suggestedId,
  });

  final String specimenUuid;
  final String weightUnit;
  final SpecimenIndividualData? individual;

  /// Individuals already entered for the lot, shown in the header.
  final int enteredCount;
  final int? totalIndividuals;

  /// Tag ID used when auto-numbering is not set up.
  final String? suggestedId;

  /// One column in a bottom sheet instead of two in a dialog.
  final bool isSheet;

  @override
  IndividualFormState createState() => IndividualFormState();
}

class IndividualFormState extends ConsumerState<IndividualForm> {
  late SpecimenIndividualCtrModel ctr = _newController();

  /// The auto-numbered tag the form offered, used to tell an override apart.
  String? _autoTag;
  int _savedCount = 0;

  /// Bumped to reset the dropdowns after context.l10n.fishSaveAndAddAnother.
  int _formVersion = 0;
  bool _isSaving = false;

  bool get _isAdding => widget.individual == null;

  @override
  void dispose() {
    ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.totalIndividuals;
    final entered = widget.enteredCount + _savedCount;
    final tagField = _IndividualTagField(
      controller: ctr.individualIdCtr,
      isAutoNumbered: _autoTag != null && ctr.individualIdCtr.text == _autoTag,
      onNewNumber: _applyNextTag,
      onChanged: () => setState(() {}),
    );
    final sexAndLifeStage = _FieldPair(
      first: SpecimenSexDropdown(
        currentCode: ctr.sexCtr,
        onChanged: (sex) => setState(
          () => ctr.sexCtr = sex == null ? null : getSpecimenSexCode(sex),
        ),
      ),
      second: LifeStageDropdown(
        currentValue: ctr.lifeStageCtr,
        onChanged: (value) => setState(() => ctr.lifeStageCtr = value),
      ),
    );
    final lengths = _FieldPair(
      first: CommonNumField(
        key: const ValueKey('individual-standard-length'),
        controller: ctr.standardLengthCtr,
        labelText: context.l10n.fishStandardLengthMm,
        hintText: context.l10n.fishStandardLengthShort,
        isDouble: true,
        isLastField: false,
      ),
      second: CommonNumField(
        key: const ValueKey('individual-total-length'),
        controller: ctr.totalLengthCtr,
        labelText: context.l10n.fishTotalLengthMm,
        hintText: context.l10n.fishTotalLengthShort,
        isDouble: true,
        isLastField: false,
      ),
    );
    final weightField = CommonNumField(
      key: const ValueKey('individual-weight'),
      controller: ctr.weightCtr,
      labelText: context.l10n.fishWeightWithUnit(widget.weightUnit),
      hintText: context.l10n.fishEnterWeight,
      isDouble: true,
      isLastField: false,
    );
    final remarkField = CommonTextField(
      controller: ctr.remarkCtr,
      maxLines: 3,
      labelText: context.l10n.specimenRemarks,
      hintText: context.l10n.fishIndividualRemarksHint,
      isLastField: true,
      keyboardType: TextInputType.multiline,
    );
    return AdaptiveSheetDialogBody(
      title: _isAdding
          ? context.l10n.fishAddIndividual
          : context.l10n.fishEditIndividual,
      description: _isAdding
          ? (total == null
                ? context.l10n.fishEnteredCount(entered)
                : context.l10n.fishEnteredOfTotal(entered, total))
          : null,
      showCloseButton: !widget.isSheet,
      isCloseEnabled: !_isSaving,
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        if (_isAdding)
          OutlinedButton(
            key: const ValueKey('individual-save-another'),
            onPressed: _isSaving ? null : () => _save(addAnother: true),
            child: Text(context.l10n.fishSaveAndAddAnother),
          ),
        PrimaryButton(
          key: const ValueKey('individual-save'),
          label: context.l10n.commonSave,
          icon: Icons.save_alt_outlined,
          isRunning: _isSaving,
          onPressed: () => _save(addAnother: false),
        ),
      ],
      child: KeyedSubtree(
        key: ValueKey('individual-form-$_formVersion'),
        child: widget.isSheet
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  tagField,
                  sexAndLifeStage,
                  lengths,
                  weightField,
                  remarkField,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _IndividualFormSection(
                          title: context.l10n.projectIdentity,
                          children: [tagField, sexAndLifeStage],
                        ),
                      ),
                      const SizedBox(width: NahpuSpacing.xxl),
                      Expanded(
                        child: _IndividualFormSection(
                          title: context.l10n.fishMeasurements,
                          children: [lengths, weightField],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NahpuSpacing.md),
                  remarkField,
                ],
              ),
      ),
    );
  }

  SpecimenIndividualCtrModel _newController() {
    final individual = widget.individual;
    if (individual != null) {
      return SpecimenIndividualCtrModel.fromData(individual);
    }
    _autoTag = IndividualTagIdServices(ref: ref).peekNextTag();
    return SpecimenIndividualCtrModel.empty(
      individualId: _autoTag ?? widget.suggestedId,
    );
  }

  void _applyNextTag() {
    final next = IndividualTagIdServices(ref: ref).peekNextTag();
    if (next == null) return;
    setState(() {
      _autoTag = next;
      ctr.individualIdCtr.text = next;
    });
  }

  Future<void> _save({required bool addAnother}) async {
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
      await IndividualTagIdServices(ref: ref).consumeIfMatches(id);
    } else {
      await services.updateIndividual(widget.specimenUuid, individual.id, form);
    }
    if (!mounted) return;
    if (!addAnother) {
      Navigator.of(context).pop();
      return;
    }
    final previous = ctr;
    setState(() {
      _savedCount++;
      _formVersion++;
      _isSaving = false;
      ctr = _newController();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
  }
}

class _FieldPair extends StatelessWidget {
  const _FieldPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: NahpuSpacing.lg),
        Expanded(child: second),
      ],
    );
  }
}

class _IndividualFormSection extends StatelessWidget {
  const _IndividualFormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        ...children,
      ],
    );
  }
}

enum _TagIdAction { newNumber, settings }

/// Tag ID field prefilled with the next auto-numbered tag. Typing overrides
/// it; the menu restores the next number or opens the numbering settings.
class _IndividualTagField extends ConsumerWidget {
  const _IndividualTagField({
    required this.controller,
    required this.isAutoNumbered,
    required this.onNewNumber,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isAutoNumbered;
  final VoidCallback onNewNumber;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      key: const ValueKey('individual-id'),
      controller: controller,
      decoration: InputDecoration(
        labelText: context.l10n.fishTagId,
        hintText: context.l10n.fishTagIdHint,
        helperText: isAutoNumbered ? context.l10n.fishAutoNumbered : null,
        suffixIcon: AdaptiveMenuButton<_TagIdAction>(
          tooltip: context.l10n.fishTagIdOptions,
          icon: const Icon(Icons.more_vert),
          itemBuilder: () => [
            AdaptiveMenuItem(
              value: _TagIdAction.newNumber,
              label: context.l10n.parasiteNewNumber,
              icon: Icons.pin_outlined,
            ),
            AdaptiveMenuItem(
              value: _TagIdAction.settings,
              label: context.l10n.parasiteSettings,
              icon: Icons.settings_outlined,
            ),
          ],
          onSelected: (action) async {
            switch (action) {
              case _TagIdAction.newNumber:
                onNewNumber();
              case _TagIdAction.settings:
                await _showSettings(context, ref);
                onNewNumber();
            }
          },
        ),
      ),
      onChanged: (_) => onChanged(),
    );
  }

  Future<void> _showSettings(BuildContext context, WidgetRef ref) {
    return showAdaptiveSheetDialog<void>(
      context: context,
      builder: (context, isSheet) => AdaptiveSheetDialogBody(
        title: context.l10n.fishTagIdSettings,
        showCloseButton: !isSheet,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.commonDone),
          ),
        ],
        child: NumberedIdFields(
          store: IndividualTagIdServices(ref: ref),
          useHorizontalLayout: false,
          previewLabel: context.l10n.recordsSpecimenNextTag,
          prefixHint: 'FT-',
          suffixHint: '-A',
        ),
      ),
    );
  }
}
