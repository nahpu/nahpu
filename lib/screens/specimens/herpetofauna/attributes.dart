import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/screens/specimens/shared/weight_field.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/herps.dart';
import 'package:drift/drift.dart' as db;

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

class HerpAttributeFormsState extends ConsumerState<HerpAttributeForms> {
  HerpAttributeCtrModel ctr = HerpAttributeCtrModel.empty();
  final Key _sexDropdownKey = UniqueKey();

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
    return AttributeForm(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            SpecimenSexDropdown(
              key: _sexDropdownKey,
              currentCode: ctr.sexCtr,
              onChanged: _handleSexUpdate,
            ),
            DropdownButtonFormField<SpecimenAge>(
              initialValue: getSpecimenAge(ctr.ageCtr),
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Age',
                hintText: 'Select specimen age',
              ),
              items: specimenAgeList
                  .map(
                    (e) => DropdownMenuItem(
                      value: SpecimenAge.values[specimenAgeList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: (SpecimenAge? newValue) {
                if (newValue != null) {
                  setState(() {
                    ctr.ageCtr = newValue.index;
                    SpecimenServices(ref: ref).updateHerpAttribute(
                      widget.specimenUuid,
                      HerpAttributeCompanion(age: db.Value(newValue.index)),
                    );
                  });
                }
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            WeightField(
              controller: ctr.weightCtr,
              unit: ctr.weightUnitCtr,
              onUnitChanged: (unit) {
                setState(() => ctr.weightUnitCtr = unit);
                SpecimenServices(ref: ref).updateHerpAttribute(
                  widget.specimenUuid,
                  HerpAttributeCompanion(weightUnit: db.Value(unit)),
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
                }
              },
            ),
            CommonNumField(
              controller: ctr.svlCtr,
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
