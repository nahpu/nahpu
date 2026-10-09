import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/screens/specimens/shared/measurement_outlier_warnings.dart';
import 'package:nahpu/screens/specimens/shared/weight_field.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/specimens/measurement_outlier_services.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';

class HerpAttributeForms extends ConsumerStatefulWidget {
  const HerpAttributeForms({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;

  @override
  HerpAttributeFormsState createState() => HerpAttributeFormsState();
}

class HerpAttributeFormsState extends ConsumerState<HerpAttributeForms>
    with
        MeasurementOutlierWarnings<
          HerpAttributeForms,
          HerpMeasurementOutlierField
        > {
  HerpAttributeCtrModel ctr = HerpAttributeCtrModel.empty();
  final FocusNode _weightFocusNode = FocusNode();
  final FocusNode _svlFocusNode = FocusNode();
  final Key _sexDropdownKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    addOutlierListener(
      _weightFocusNode,
      HerpMeasurementOutlierField.weight,
      () => double.tryParse(ctr.weightCtr.text),
    );
    addOutlierListener(
      _svlFocusNode,
      HerpMeasurementOutlierField.svl,
      () => double.tryParse(ctr.svlCtr.text),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCtr(widget.specimenUuid);
    });
  }

  @override
  void dispose() {
    ctr.dispose();
    _weightFocusNode.dispose();
    _svlFocusNode.dispose();
    super.dispose();
  }

  @override
  String get outlierWeightUnit => ctr.weightUnitCtr;

  @override
  Future<MeasurementOutlierResult?> checkOutlierValue(
    HerpMeasurementOutlierField field,
    double value,
  ) => HerpMeasurementOutlierServices(ref: ref).checkValue(
    specimenUuid: widget.specimenUuid,
    field: field,
    value: value,
    weightUnit: outlierWeightUnit,
  );

  @override
  Widget build(BuildContext context) {
    return AttributeForm(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            SwitchField(
              label: 'Show outlier warnings',
              value: showOutlierWarnings,
              onPressed: setOutlierWarningsEnabled,
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            SpecimenSexDropdown(
              key: _sexDropdownKey,
              currentCode: ctr.sexCtr,
              onChanged: _handleSexUpdate,
            ),
            LifeStageDropdown(
              currentValue: ctr.lifeStageCtr,
              onChanged: (value) {
                setState(() => ctr.lifeStageCtr = value);
                SpecimenServices(ref: ref).updateHerpAttribute(
                  widget.specimenUuid,
                  HerpAttributeCompanion(lifeStage: db.Value(value)),
                );
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            WeightField(
              controller: ctr.weightCtr,
              focusNode: _weightFocusNode,
              unit: ctr.weightUnitCtr,
              onUnitChanged: (unit) {
                setState(() => ctr.weightUnitCtr = unit);
                SpecimenServices(ref: ref).updateHerpAttribute(
                  widget.specimenUuid,
                  HerpAttributeCompanion(weightUnit: db.Value(unit)),
                );
                scheduleOutlierWarning(
                  HerpMeasurementOutlierField.weight,
                  double.tryParse(ctr.weightCtr.text),
                );
              },
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    SpecimenServices(ref: ref).updateHerpAttribute(
                      widget.specimenUuid,
                      HerpAttributeCompanion(
                        weight: db.Value(double.tryParse(value)),
                        weightUnit: db.Value(ctr.weightUnitCtr),
                      ),
                    );
                  });
                  scheduleOutlierWarning(
                    HerpMeasurementOutlierField.weight,
                    double.tryParse(value),
                  );
                }
              },
            ),
            CommonNumField(
              controller: ctr.svlCtr,
              focusNode: _svlFocusNode,
              labelText: 'SVL (cm)',
              hintText: 'Enter snout-vent length',
              isDouble: true,
              isLastField: false,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    SpecimenServices(ref: ref).updateHerpAttribute(
                      widget.specimenUuid,
                      HerpAttributeCompanion(
                        svl: db.Value(double.tryParse(value)),
                      ),
                    );
                  });
                  scheduleOutlierWarning(
                    HerpMeasurementOutlierField.svl,
                    double.tryParse(value),
                  );
                }
              },
            ),
          ],
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
                if (value != null) {
                  SpecimenServices(ref: ref).updateHerpAttribute(
                    widget.specimenUuid,
                    HerpAttributeCompanion(remark: db.Value(value)),
                  );
                }
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
    HerpAttributeData data = await SpecimenServices(
      ref: ref,
    ).getHerpAttributeData(specimenUuid);

    setState(() {
      ctr = HerpAttributeCtrModel.fromData(data);
    });
  }

  void _handleSexUpdate(SpecimenSex? newSex) {
    if (newSex == null || newSex == getSpecimenSex(ctr.sexCtr)) return;
    _updateSex(newSex);
  }

  void _updateSex(SpecimenSex newSex) {
    final code = getSpecimenSexCode(newSex);
    setState(() {
      ctr.sexCtr = code;
      SpecimenServices(ref: ref).updateHerpAttribute(
        widget.specimenUuid,
        HerpAttributeCompanion(sex: db.Value(code)),
      );
    });
  }
}
