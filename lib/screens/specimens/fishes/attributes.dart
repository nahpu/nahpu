import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/specimens/fishes/individuals.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/screens/specimens/shared/weight_field.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/specimens/fish_lot_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/nahpu_icons.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

const Map<FishSpecimenType, String> fishSpecimenTypeLabels = {
  FishSpecimenType.individual: 'Individual',
  FishSpecimenType.lot: 'Lot',
};

const Map<FishSpecimenType, String> fishSpecimenTypeDescriptions = {
  FishSpecimenType.individual: 'One fish with its own measurements',
  FishSpecimenType.lot: 'Many individuals stored together',
};

const Map<FishSpecimenType, IconData> fishSpecimenTypeIcons = {
  FishSpecimenType.individual: NahpuIcons.fishOutlined,
  FishSpecimenType.lot: Icons.layers_outlined,
};

class FishAttributeForms extends ConsumerStatefulWidget {
  const FishAttributeForms({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;

  @override
  FishAttributeFormsState createState() => FishAttributeFormsState();
}

class FishAttributeFormsState extends ConsumerState<FishAttributeForms> {
  FishAttributeCtrModel ctr = FishAttributeCtrModel.empty();
  Key _formKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCtr(widget.specimenUuid);
    });
  }

  @override
  void dispose() {
    ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Automatic lot ranges are written by the service whenever an individual
    // changes, so the form follows the stored lot columns.
    ref.listen(fishAttributeProvider(widget.specimenUuid), (_, next) {
      final data = next.asData?.value;
      if (data == null || !mounted) return;
      setState(() => ctr.syncLot(data));
    });
    final isLot = ctr.specimenType == FishSpecimenType.lot;
    final lifeStageField = LifeStageDropdown(
      currentValue: ctr.lifeStageCtr,
      onChanged: (value) {
        setState(() => ctr.lifeStageCtr = value);
        _update(FishAttributeCompanion(lifeStage: db.Value(value)));
      },
    );
    return AttributeForm(
      key: _formKey,
      children: [
        CommonPadding(
          child: FishSpecimenTypeField(
            value: ctr.specimenType,
            onChanged: _updateSpecimenType,
          ),
        ),
        // Separates the type's helper text from the fields that follow.
        const SizedBox(height: NahpuSpacing.lg),
        if (isLot)
          _FishLotFields(
            specimenUuid: widget.specimenUuid,
            ctr: ctr,
            useHorizontalLayout: widget.useHorizontalLayout,
            lifeStageField: lifeStageField,
            onAutoRangeChanged: _updateAutoRange,
            onWeightUnitChanged: _updateLotWeightUnit,
            onChanged: _update,
          )
        else
          _FishIndividualFields(
            ctr: ctr,
            useHorizontalLayout: widget.useHorizontalLayout,
            lifeStageField: lifeStageField,
            onSexChanged: _updateSex,
            onWeightUnitChanged: (unit) {
              setState(() => ctr.weightUnitCtr = unit);
              _update(FishAttributeCompanion(weightUnit: db.Value(unit)));
            },
            onChanged: _update,
          ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonTextField(
              controller: ctr.remarkCtr,
              maxLines: 6,
              labelText: 'Remarks',
              hintText: 'Add additional information about the specimen',
              isLastField: false,
              keyboardType: TextInputType.multiline,
              onChanged: (String? value) {
                _update(FishAttributeCompanion(remark: db.Value(value)));
              },
            ),
          ],
        ),
        ParasiteDetectionForm(specimenUuid: widget.specimenUuid),
        CustomFieldForm(owner: CustomFieldOwner.specimen(widget.specimenUuid)),
      ],
    );
  }

  Future<void> _updateCtr(String specimenUuid) async {
    final data = await FishLotServices(ref: ref).getAttribute(specimenUuid);
    if (!mounted) return;
    final previous = ctr;
    setState(() {
      ctr = FishAttributeCtrModel.fromData(data);
      _formKey = UniqueKey();
    });
    // The replaced fields detach from these controllers during the rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
  }

  Future<void> _update(FishAttributeCompanion entries) async {
    await FishLotServices(
      ref: ref,
    ).updateAttribute(widget.specimenUuid, entries);
  }

  Future<void> _updateSpecimenType(FishSpecimenType? type) async {
    if (type == null || type == ctr.specimenType) return;
    setState(() => ctr.specimenType = type);
    await _update(FishAttributeCompanion(specimenType: db.Value(type.index)));
    if (type == FishSpecimenType.lot) {
      await FishLotServices(ref: ref).recomputeRange(widget.specimenUuid);
    }
  }

  Future<void> _updateAutoRange(bool isAuto) async {
    setState(() => ctr.isAutoRange = isAuto);
    await FishLotServices(ref: ref).setAutoRange(widget.specimenUuid, isAuto);
  }

  Future<void> _updateLotWeightUnit(String unit) async {
    setState(() => ctr.weightUnitCtr = unit);
    await FishLotServices(ref: ref).updateWeightUnit(widget.specimenUuid, unit);
  }

  void _updateSex(SpecimenSex? newSex) {
    if (newSex == null || newSex == getSpecimenSex(ctr.sexCtr)) return;
    final code = getSpecimenSexCode(newSex);
    setState(() => ctr.sexCtr = code);
    _update(FishAttributeCompanion(sex: db.Value(code)));
  }
}

class _FishIndividualFields extends StatelessWidget {
  const _FishIndividualFields({
    required this.ctr,
    required this.useHorizontalLayout,
    required this.onSexChanged,
    required this.onWeightUnitChanged,
    required this.onChanged,
    required this.lifeStageField,
  });

  final FishAttributeCtrModel ctr;
  final bool useHorizontalLayout;
  final Widget lifeStageField;
  final ValueChanged<SpecimenSex?> onSexChanged;
  final ValueChanged<String> onWeightUnitChanged;
  final ValueChanged<FishAttributeCompanion> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            SpecimenSexDropdown(
              currentCode: ctr.sexCtr,
              onChanged: onSexChanged,
            ),
            lifeStageField,
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonNumField(
              key: const ValueKey('fish-standard-length'),
              controller: ctr.standardLengthCtr,
              labelText: 'Standard length (mm)',
              hintText: 'Enter standard length',
              isDouble: true,
              isLastField: false,
              onChanged: (value) => onChanged(
                FishAttributeCompanion(
                  standardLength: db.Value(parseMeasurement(value)),
                ),
              ),
            ),
            CommonNumField(
              key: const ValueKey('fish-total-length'),
              controller: ctr.totalLengthCtr,
              labelText: 'Total length (mm)',
              hintText: 'Enter total length',
              isDouble: true,
              isLastField: false,
              onChanged: (value) => onChanged(
                FishAttributeCompanion(
                  totalLength: db.Value(parseMeasurement(value)),
                ),
              ),
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            WeightField(
              controller: ctr.weightCtr,
              unit: ctr.weightUnitCtr,
              onUnitChanged: onWeightUnitChanged,
              onChanged: (value) => onChanged(
                FishAttributeCompanion(
                  weight: db.Value(parseMeasurement(value)),
                  weightUnit: db.Value(ctr.weightUnitCtr),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FishLotFields extends StatelessWidget {
  const _FishLotFields({
    required this.specimenUuid,
    required this.ctr,
    required this.useHorizontalLayout,
    required this.onAutoRangeChanged,
    required this.onWeightUnitChanged,
    required this.onChanged,
    required this.lifeStageField,
  });

  final String specimenUuid;
  final FishAttributeCtrModel ctr;
  final bool useHorizontalLayout;
  final Widget lifeStageField;
  final ValueChanged<bool> onAutoRangeChanged;
  final ValueChanged<String> onWeightUnitChanged;
  final ValueChanged<FishAttributeCompanion> onChanged;

  @override
  Widget build(BuildContext context) {
    final isManual = !ctr.isAutoRange;
    // The list tiles below paint on the nearest Material, which the form
    // card's decorated background would otherwise cover.
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          AdaptiveLayout(
            useHorizontalLayout: useHorizontalLayout,
            children: [
              CommonNumField(
                key: const ValueKey('fish-individual-count'),
                controller: ctr.individualCountCtr,
                labelText: 'Total individuals',
                hintText: 'Enter the number of individuals in the lot',
                isLastField: false,
                onChanged: (value) => onChanged(
                  FishAttributeCompanion(
                    individualCount: db.Value(
                      int.tryParse(value?.trim() ?? ''),
                    ),
                  ),
                ),
              ),
              lifeStageField,
            ],
          ),
          SwitchListTile(
            key: const ValueKey('fish-auto-range'),
            // Matches the inset of the surrounding fields, which add
            // CommonPadding and no horizontal content padding of their own.
            contentPadding: const EdgeInsets.symmetric(
              horizontal: NahpuSpacing.xs,
            ),
            title: const Text('Auto-update min and max'),
            subtitle: const Text(
              'Fill the ranges from the individuals measured below',
            ),
            value: ctr.isAutoRange,
            onChanged: onAutoRangeChanged,
          ),
          AdaptiveLayout(
            useHorizontalLayout: useHorizontalLayout,
            children: [
              CommonNumField(
                key: const ValueKey('fish-min-standard-length'),
                controller: ctr.minStandardLengthCtr,
                labelText: 'Min. standard length (mm)',
                hintText: 'Enter minimum standard length',
                isDouble: true,
                enabled: isManual,
                isLastField: false,
                onChanged: (value) => onChanged(
                  FishAttributeCompanion(
                    minStandardLength: db.Value(parseMeasurement(value)),
                  ),
                ),
              ),
              CommonNumField(
                key: const ValueKey('fish-max-standard-length'),
                controller: ctr.maxStandardLengthCtr,
                labelText: 'Max. standard length (mm)',
                hintText: 'Enter maximum standard length',
                isDouble: true,
                enabled: isManual,
                isLastField: false,
                onChanged: (value) => onChanged(
                  FishAttributeCompanion(
                    maxStandardLength: db.Value(parseMeasurement(value)),
                  ),
                ),
              ),
            ],
          ),
          AdaptiveLayout(
            useHorizontalLayout: useHorizontalLayout,
            children: [
              CommonNumField(
                key: const ValueKey('fish-min-total-length'),
                controller: ctr.minTotalLengthCtr,
                labelText: 'Min. total length (mm)',
                hintText: 'Enter minimum total length',
                isDouble: true,
                enabled: isManual,
                isLastField: false,
                onChanged: (value) => onChanged(
                  FishAttributeCompanion(
                    minTotalLength: db.Value(parseMeasurement(value)),
                  ),
                ),
              ),
              CommonNumField(
                key: const ValueKey('fish-max-total-length'),
                controller: ctr.maxTotalLengthCtr,
                labelText: 'Max. total length (mm)',
                hintText: 'Enter maximum total length',
                isDouble: true,
                enabled: isManual,
                isLastField: false,
                onChanged: (value) => onChanged(
                  FishAttributeCompanion(
                    maxTotalLength: db.Value(parseMeasurement(value)),
                  ),
                ),
              ),
            ],
          ),
          AdaptiveLayout(
            useHorizontalLayout: useHorizontalLayout,
            children: [
              WeightField(
                key: const ValueKey('fish-min-weight'),
                controller: ctr.minWeightCtr,
                unit: ctr.weightUnitCtr,
                labelText: 'Min. weight',
                hintText: 'Enter minimum weight',
                enabled: isManual,
                onUnitChanged: onWeightUnitChanged,
                onChanged: (value) => onChanged(
                  FishAttributeCompanion(
                    minWeight: db.Value(parseMeasurement(value)),
                  ),
                ),
              ),
              WeightField(
                key: const ValueKey('fish-max-weight'),
                controller: ctr.maxWeightCtr,
                unit: ctr.weightUnitCtr,
                labelText: 'Max. weight',
                hintText: 'Enter maximum weight',
                enabled: isManual,
                onUnitChanged: onWeightUnitChanged,
                onChanged: (value) => onChanged(
                  FishAttributeCompanion(
                    maxWeight: db.Value(parseMeasurement(value)),
                  ),
                ),
              ),
            ],
          ),
          FishLotSummary(
            specimenUuid: specimenUuid,
            weightUnit: ctr.weightUnitCtr,
            totalIndividuals: int.tryParse(ctr.individualCountCtr.text.trim()),
          ),
          SpecimenIndividualList(
            specimenUuid: specimenUuid,
            weightUnit: ctr.weightUnitCtr,
            totalIndividuals: int.tryParse(ctr.individualCountCtr.text.trim()),
          ),
          const SizedBox(height: NahpuSpacing.md),
        ],
      ),
    );
  }
}

/// Full-width picker for whether a fish record is one individual or a lot.
///
/// The leading icon follows the selection so the record type reads at a
/// glance.
class FishSpecimenTypeField extends StatelessWidget {
  const FishSpecimenTypeField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final FishSpecimenType value;
  final ValueChanged<FishSpecimenType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<FishSpecimenType>(
      key: const ValueKey('fish-specimen-type'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Specimen type',
        helperText: fishSpecimenTypeDescriptions[value],
        prefixIcon: Icon(
          fishSpecimenTypeIcons[value],
          color: colorScheme.primary,
        ),
      ),
      selectedItemBuilder: (context) => [
        for (final type in FishSpecimenType.values)
          CommonDropdownText(text: fishSpecimenTypeLabels[type]!),
      ],
      items: [
        for (final type in FishSpecimenType.values)
          DropdownMenuItem(
            value: type,
            child: Row(
              children: [
                Icon(
                  fishSpecimenTypeIcons[type],
                  size: NahpuControlSize.iconMedium,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: NahpuSpacing.md),
                Expanded(
                  child: CommonDropdownText(
                    text: fishSpecimenTypeLabels[type]!,
                  ),
                ),
              ],
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
