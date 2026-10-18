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
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

const Map<FishSpecimenType, String> fishSpecimenTypeLabels = {
  FishSpecimenType.individual: 'Individual',
  FishSpecimenType.lot: 'Lot',
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
    return AttributeForm(
      key: _formKey,
      children: [
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            DropdownButtonFormField<FishSpecimenType>(
              key: const ValueKey('fish-specimen-type'),
              initialValue: ctr.specimenType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Specimen type',
                hintText: 'Select individual or lot',
              ),
              items: [
                for (final type in FishSpecimenType.values)
                  DropdownMenuItem(
                    value: type,
                    child: CommonDropdownText(
                      text: fishSpecimenTypeLabels[type]!,
                    ),
                  ),
              ],
              onChanged: _updateSpecimenType,
            ),
            LifeStageDropdown(
              currentValue: ctr.lifeStageCtr,
              onChanged: (value) {
                setState(() => ctr.lifeStageCtr = value);
                _update(FishAttributeCompanion(lifeStage: db.Value(value)));
              },
            ),
          ],
        ),
        if (isLot)
          _FishLotFields(
            specimenUuid: widget.specimenUuid,
            ctr: ctr,
            useHorizontalLayout: widget.useHorizontalLayout,
            onAutoRangeChanged: _updateAutoRange,
            onWeightUnitChanged: _updateLotWeightUnit,
            onChanged: _update,
          )
        else
          _FishIndividualFields(
            ctr: ctr,
            useHorizontalLayout: widget.useHorizontalLayout,
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
  });

  final FishAttributeCtrModel ctr;
  final bool useHorizontalLayout;
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
  });

  final String specimenUuid;
  final FishAttributeCtrModel ctr;
  final bool useHorizontalLayout;
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
            ],
          ),
          SwitchListTile(
            key: const ValueKey('fish-auto-range'),
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
          ),
          SpecimenIndividualList(
            specimenUuid: specimenUuid,
            weightUnit: ctr.weightUnitCtr,
          ),
          const SizedBox(height: NahpuSpacing.md),
        ],
      ),
    );
  }
}
