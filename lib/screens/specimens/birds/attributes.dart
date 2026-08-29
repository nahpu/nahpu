import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/birds.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/screens/specimens/shared/weight_field.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';

class BirdAttributeForms extends ConsumerStatefulWidget {
  const BirdAttributeForms({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;

  @override
  BirdAttributeFormsState createState() => BirdAttributeFormsState();
}

class BirdAttributeFormsState extends ConsumerState<BirdAttributeForms> {
  BirdAttributeCtrModel ctr = BirdAttributeCtrModel.empty();
  bool _hasBursa = false;
  Key _sexDropdownKey = UniqueKey();

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
            WeightField(
              controller: ctr.weightCtr,
              unit: ctr.weightUnitCtr,
              onUnitChanged: (unit) {
                setState(() => ctr.weightUnitCtr = unit);
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(weightUnit: db.Value(unit)),
                );
              },
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  final double weight = double.tryParse(value) ?? 0.0;
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(
                      weight: db.Value(weight),
                      weightUnit: db.Value(ctr.weightUnitCtr),
                    ),
                  );
                }
              },
            ),
            CommonNumField(
              controller: ctr.wingspanCtr,
              labelText: 'Wingspan (mm)',
              hintText: 'Enter wingspan length',
              isDouble: true,
              isLastField: false,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(
                      wingspan: db.Value(double.tryParse(value) ?? 0),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        CommonPadding(
          child: CommonTextField(
            controller: ctr.billCtr,
            labelText: 'Bill color',
            hintText: 'Enter bill color',
            isLastField: false,
            onChanged: (String? value) {
              if (value != null && value.isNotEmpty) {
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(billColor: db.Value(value)),
                );
              }
            },
          ),
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonTextField(
              controller: ctr.maxillaCtr,
              labelText: 'Maxilla color',
              hintText: 'Enter maxilla color',
              isLastField: false,
              onChanged: (value) {
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(
                    maxillaColor: db.Value(
                      value == null || value.isEmpty ? null : value,
                    ),
                  ),
                );
              },
            ),
            CommonTextField(
              controller: ctr.mandibleCtr,
              labelText: 'Mandible color',
              hintText: 'Enter mandible color',
              isLastField: false,
              onChanged: (value) {
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(
                    mandibleColor: db.Value(
                      value == null || value.isEmpty ? null : value,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonTextField(
              controller: ctr.irisCtr,
              labelText: 'Iris color',
              hintText: 'Enter iris color',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(irisColor: db.Value(value)),
                  );
                }
              },
            ),
            CommonTextField(
              controller: ctr.tarsusCtr,
              labelText: 'Tarsus color',
              hintText: 'Enter tarsus color',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(tarsusColor: db.Value(value)),
                  );
                }
              },
            ),
            CommonTextField(
              controller: ctr.toeCtr,
              labelText: 'Toe color',
              hintText: 'Enter toe color',
              isLastField: true,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(toeColor: db.Value(value)),
                  );
                }
              },
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
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(lifeStage: db.Value(value)),
                );
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            DropdownButtonFormField<int?>(
              initialValue: ctr.broodPatchCtr,
              decoration: const InputDecoration(
                labelText: 'Brood patch',
                hintText: 'Choose one',
              ),
              items: DropDownMenuItems.booleanDropDownItems(),
              onChanged: (int? newValue) {
                setState(() {
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(broodPatch: db.Value(newValue)),
                  );
                });
              },
            ),
            DropdownButtonFormField<int?>(
              initialValue: ctr.hasBursaCtr,
              decoration: const InputDecoration(
                labelText: 'Bursa present',
                hintText: 'Choose one',
              ),
              items: DropDownMenuItems.booleanDropDownItems(),
              onChanged: (int? newValue) {
                setState(() {
                  _hasBursa = newValue == 1;
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(hasBursa: db.Value(newValue)),
                  );
                });
              },
            ),
          ],
        ),
        BursaField(
          specimenUuid: widget.specimenUuid,
          useHorizontalLayout: widget.useHorizontalLayout,
          hasBursa: _hasBursa,
          ctr: ctr,
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            SkullOssField(specimenUuid: widget.specimenUuid, ctr: ctr),
            FatField(specimenUuid: widget.specimenUuid, ctr: ctr),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: CommonTextField(
            controller: ctr.stomachContentCtr,
            maxLines: 3,
            labelText: 'Stomach contents',
            hintText: 'Enter stomach contents',
            isLastField: false,
            onChanged: (String? value) {
              if (value != null && value.isNotEmpty) {
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(stomachContent: db.Value(value)),
                );
              }
            },
          ),
        ),
        MaleGonadForm(
          specimenUuid: widget.specimenUuid,
          ctr: ctr,
          useHorizontalLayout: widget.useHorizontalLayout,
          sex: getSpecimenSex(ctr.sexCtr),
        ),
        FemaleGonadForm(
          specimenUuid: widget.specimenUuid,
          ctr: ctr,
          useHorizontalLayout: widget.useHorizontalLayout,
          sex: getSpecimenSex(ctr.sexCtr),
        ),
        MoltingForm(
          specimenUuid: widget.specimenUuid,
          ctr: ctr,
          useHorizontalLayout: widget.useHorizontalLayout,
        ),
        Notes(specimenUuid: widget.specimenUuid, ctr: ctr),
        ParasiteDetectionForm(specimenUuid: widget.specimenUuid),
        CustomFieldForm(owner: CustomFieldOwner.specimen(widget.specimenUuid)),
      ],
    );
  }

  Future<void> _updateCtr(String specimenUuid) async {
    BirdAttributeData data = await SpecimenServices(
      ref: ref,
    ).getBirdAttributeData(specimenUuid);
    setState(() {
      ctr = BirdAttributeCtrModel.fromData(data);
    });
  }

  Future<void> _handleSexUpdate(SpecimenSex? newSex) async {
    final currentSex = getSpecimenSex(ctr.sexCtr);
    if (newSex == null || newSex == currentSex) return;

    final clearMale =
        currentSex?.supportsMaleAttributes == true &&
        !newSex.supportsMaleAttributes;
    final clearFemale =
        currentSex?.supportsFemaleAttributes == true &&
        !newSex.supportsFemaleAttributes;
    if (!clearMale && !clearFemale) {
      _updateSex(newSex);
      return;
    }

    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CommonAlertDialog(
          titleText: 'Change sex?',
          descText:
              'Changing the sex will clear reproductive data that does not '
              'apply to the new selection.',
          confirmFunction: () {
            ctr.clearSexControllers(male: clearMale, female: clearFemale);
            SpecimenServices(ref: ref).clearBirdSexAttributes(
              widget.specimenUuid,
              male: clearMale,
              female: clearFemale,
            );
            _updateSex(newSex);
          },
          cancelFunction: () {
            setState(() {
              // Trigger a rebuild of the dropdown to revert the displayed value
              _sexDropdownKey = UniqueKey();
            });
          },
        );
      },
    );
  }

  void _updateSex(SpecimenSex newSex) {
    final code = getSpecimenSexCode(newSex);
    setState(() {
      ctr.sexCtr = code;
      SpecimenServices(ref: ref).updateBirdAttribute(
        widget.specimenUuid,
        BirdAttributeCompanion(sex: db.Value(code)),
      );
    });
  }
}

class BursaField extends ConsumerStatefulWidget {
  const BursaField({
    super.key,
    required this.specimenUuid,
    required this.useHorizontalLayout,
    required this.hasBursa,
    required this.ctr,
  });

  final String specimenUuid;
  final bool useHorizontalLayout;
  final bool hasBursa;
  final BirdAttributeCtrModel ctr;

  @override
  BursaFieldState createState() => BursaFieldState();
}

class BursaFieldState extends ConsumerState<BursaField> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.hasBursa,
      child: AdaptiveLayout(
        useHorizontalLayout: widget.useHorizontalLayout,
        children: [
          CommonNumField(
            controller: widget.ctr.bursaLengthCtr,
            labelText: 'Bursa length (mm)',
            hintText: 'Enter bursa length',
            isDouble: true,
            isLastField: false,
            onChanged: (String? value) {
              if (value != null && value.isNotEmpty) {
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(
                    bursaLength: db.Value(double.tryParse(value) ?? 0),
                  ),
                );
              }
            },
          ),
          CommonNumField(
            controller: widget.ctr.bursaWidthCtr,
            labelText: 'Bursa width (mm)',
            hintText: 'Enter bursa width',
            isDouble: true,
            isLastField: false,
            onChanged: (String? value) {
              if (value != null && value.isNotEmpty) {
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(
                    bursaWidth: db.Value(double.tryParse(value) ?? 0),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class MaleGonadForm extends ConsumerStatefulWidget {
  const MaleGonadForm({
    super.key,
    required this.specimenUuid,
    required this.useHorizontalLayout,
    required this.ctr,
    required this.sex,
  });

  final String specimenUuid;
  final bool useHorizontalLayout;
  final BirdAttributeCtrModel ctr;
  final SpecimenSex? sex;

  @override
  ConsumerState<MaleGonadForm> createState() => _MaleGonadFormState();
}

class _MaleGonadFormState extends ConsumerState<MaleGonadForm> {
  bool _showTestisSize = false;

  @override
  void initState() {
    super.initState();

    _showTestisSize =
        widget.ctr.testisLengthCtr.text.isNotEmpty ||
        widget.ctr.testisWidthCtr.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.sex?.supportsMaleAttributes == true,
      child: Column(
        children: [
          const CommonDivider(),
          const FormCardSectionLabel(text: 'Male gonads'),
          Text(
            'Left testis size (mm)',
            style: Theme.of(context).textTheme.titleSmall,
          ),

          DropdownButtonFormField<bool>(
            initialValue: _showTestisSize,
            decoration: const InputDecoration(labelText: 'Size'),
            items: const [
              DropdownMenuItem(
                value: false,
                child: CommonDropdownText(text: 'minute'),
              ),
              DropdownMenuItem(
                value: true,
                child: CommonDropdownText(text: '1 mm or greater'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _showTestisSize = value ?? false;
              });

              if (!_showTestisSize) {
                widget.ctr.testisLengthCtr.clear();
                widget.ctr.testisWidthCtr.clear();

                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  const BirdAttributeCompanion(
                    testisLength: db.Value(null),
                    testisWidth: db.Value(null),
                  ),
                );
              }
            },
          ),

          if (_showTestisSize)
            AdaptiveLayout(
              useHorizontalLayout: widget.useHorizontalLayout,
              children: [
                CommonNumField(
                  controller: widget.ctr.testisLengthCtr,
                  labelText: 'Length',
                  hintText: 'Enter length',
                  isDouble: true,
                  isLastField: false,
                  onChanged: (String? value) {
                    final parsed = double.tryParse(value ?? '');
                    if (value?.isNotEmpty == true && parsed == null) return;
                    SpecimenServices(ref: ref).updateBirdAttribute(
                      widget.specimenUuid,
                      BirdAttributeCompanion(testisLength: db.Value(parsed)),
                    );
                  },
                ),
                CommonNumField(
                  controller: widget.ctr.testisWidthCtr,
                  labelText: 'Width',
                  hintText: 'Enter width',
                  isDouble: true,
                  isLastField: false,
                  onChanged: (String? value) {
                    final parsed = double.tryParse(value ?? '');
                    if (value?.isNotEmpty == true && parsed == null) return;
                    SpecimenServices(ref: ref).updateBirdAttribute(
                      widget.specimenUuid,
                      BirdAttributeCompanion(testisWidth: db.Value(parsed)),
                    );
                  },
                ),
              ],
            ),
          // Remarks
          Padding(
            padding: const EdgeInsets.all(4),
            child: CommonTextField(
              controller: widget.ctr.testisRemarkCtr,
              maxLines: 3,
              labelText: 'Remarks',
              hintText: 'Enter remarks, e.g. right testis size',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(testisRemark: db.Value(value)),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FemaleGonadForm extends ConsumerStatefulWidget {
  const FemaleGonadForm({
    super.key,
    required this.specimenUuid,
    required this.ctr,
    required this.useHorizontalLayout,
    required this.sex,
  });

  final String specimenUuid;
  final BirdAttributeCtrModel ctr;
  final bool useHorizontalLayout;
  final SpecimenSex? sex;

  @override
  FemaleGonadFormState createState() => FemaleGonadFormState();
}

class FemaleGonadFormState extends ConsumerState<FemaleGonadForm> {
  bool _isLargeOvum = false;

  @override
  void initState() {
    super.initState();
    _syncLargeOvumVisibility();
  }

  @override
  void didUpdateWidget(covariant FemaleGonadForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncLargeOvumVisibility();
  }

  void _syncLargeOvumVisibility() {
    _isLargeOvum = widget.ctr.ovaryAppearanceCtr == OvaryAppearance.large.index;
  }

  @override
  Widget build(BuildContext context) {
    final ovaryApperanceItems = _birdEncodedDropdownItems(
      ovaryAppearanceList,
      widget.ctr.ovaryAppearanceCtr,
    );

    return Visibility(
      visible: widget.sex?.supportsFemaleAttributes == true,
      child: Column(
        children: [
          const CommonDivider(),
          const FormCardSectionLabel(text: 'Female gonads'),
          const FormCardSectionLabel(text: 'Ovary size'),
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              CommonNumField(
                controller: widget.ctr.ovaryLengthCtr,
                labelText: 'Length (mm)',
                hintText: 'Enter length',
                isDouble: true,
                isLastField: false,
                onChanged: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    SpecimenServices(ref: ref).updateBirdAttribute(
                      widget.specimenUuid,
                      BirdAttributeCompanion(
                        ovaryLength: db.Value(double.tryParse(value) ?? 0),
                      ),
                    );
                  }
                },
              ),
              CommonNumField(
                controller: widget.ctr.ovaryWidthCtr,
                labelText: 'Width (mm)',
                hintText: 'Enter width',
                isDouble: true,
                isLastField: false,
                onChanged: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    SpecimenServices(ref: ref).updateBirdAttribute(
                      widget.specimenUuid,
                      BirdAttributeCompanion(
                        ovaryWidth: db.Value(double.tryParse(value) ?? 0),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: DropdownButtonFormField<int?>(
              initialValue: widget.ctr.ovaryAppearanceCtr,
              decoration: const InputDecoration(labelText: 'Appearance'),
              items: DropDownMenuItems.addChooseOneToList(ovaryApperanceItems),
              onChanged: (int? newValue) {
                setState(() {
                  widget.ctr.ovaryAppearanceCtr = newValue;
                  if (kDebugMode) print(OvaryAppearance.large.index);
                  _isLargeOvum = (newValue == OvaryAppearance.large.index);
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(ovaryAppearance: db.Value(newValue)),
                  );
                });
              },
            ),
          ),
          Visibility(
            visible: _isLargeOvum,
            child: OvumSizeForm(
              specimenUuid: widget.specimenUuid,
              ctr: widget.ctr,
              useHorizontalLayout: widget.useHorizontalLayout,
            ),
          ),
          const FormCardSectionLabel(text: 'Oviduct'),
          OviductForm(
            specimenUuid: widget.specimenUuid,
            ctr: widget.ctr,
            useHorizontalLayout: widget.useHorizontalLayout,
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: CommonTextField(
              controller: widget.ctr.ovaryRemarkCtr,
              maxLines: 3,
              labelText: 'Remarks',
              hintText: 'Add additional information about the gonads',
              isLastField: true,
              onChanged: (String? value) {
                if (value != null) {
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(ovaryRemark: db.Value(value)),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SkullOssField extends ConsumerWidget {
  const SkullOssField({
    super.key,
    required this.specimenUuid,
    required this.ctr,
  });

  final String specimenUuid;
  final BirdAttributeCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<DropdownMenuItem<int?>> skullOssItems = skullOssificationList
        .map(
          (e) => DropdownMenuItem<int?>(
            value: e,
            child: CommonDropdownText(text: '$e %'),
          ),
        )
        .toList();

    return DropdownButtonFormField<int?>(
      initialValue: ctr.skullOssCtr,
      decoration: const InputDecoration(
        labelText: 'Skull ossification (%)',
        hintText: 'Enter percentage',
      ),
      items: DropDownMenuItems.addChooseOneToList(skullOssItems),
      onChanged: (int? newValue) {
        ctr.skullOssCtr = newValue;
        SpecimenServices(ref: ref).updateBirdAttribute(
          specimenUuid,
          BirdAttributeCompanion(skullOssification: db.Value(newValue)),
        );
      },
    );
  }
}

class FatField extends ConsumerWidget {
  const FatField({super.key, required this.specimenUuid, required this.ctr});

  final String specimenUuid;
  final BirdAttributeCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fatCategoryItems = _birdEncodedDropdownItems(
      fatCategoryList,
      ctr.fatCtr,
    );

    return DropdownButtonFormField<int?>(
      initialValue: ctr.fatCtr,
      decoration: const InputDecoration(labelText: 'Fat'),
      items: DropDownMenuItems.addChooseOneToList(fatCategoryItems),
      onChanged: (int? newValue) {
        SpecimenServices(ref: ref).updateBirdAttribute(
          specimenUuid,
          BirdAttributeCompanion(fat: db.Value(newValue)),
        );
      },
    );
  }
}

class OvumSizeForm extends ConsumerWidget {
  const OvumSizeForm({
    super.key,
    required this.specimenUuid,
    required this.ctr,
    required this.useHorizontalLayout,
  });

  final String specimenUuid;
  final BirdAttributeCtrModel ctr;
  final bool useHorizontalLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const FormCardSectionLabel(text: 'Diameter of three largest ova (mm)'),
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.firstOvaSizeCtr,
              labelText: 'First',
              hintText: 'Enter size',
              isDouble: true,
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    specimenUuid,
                    BirdAttributeCompanion(
                      firstOvaSize: db.Value(double.parse(value)),
                    ),
                  );
                }
              },
            ),
            CommonNumField(
              controller: ctr.secondOvaSizeCtr,
              labelText: 'Second',
              hintText: 'Enter size',
              isDouble: true,
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    specimenUuid,
                    BirdAttributeCompanion(
                      secondOvaSize: db.Value(double.parse(value)),
                    ),
                  );
                }
              },
            ),
            CommonNumField(
              controller: ctr.thirdOvaSizeCtr,
              labelText: 'Third',
              hintText: 'Enter size',
              isDouble: true,
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    specimenUuid,
                    BirdAttributeCompanion(
                      thirdOvaSize: db.Value(double.parse(value)),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class OviductForm extends ConsumerStatefulWidget {
  const OviductForm({
    super.key,
    required this.specimenUuid,
    required this.ctr,
    required this.useHorizontalLayout,
  });

  final String specimenUuid;
  final BirdAttributeCtrModel ctr;
  final bool useHorizontalLayout;

  @override
  ConsumerState<OviductForm> createState() => _OviductFormState();
}

class _OviductFormState extends ConsumerState<OviductForm> {
  late bool _showWidthField;

  @override
  void initState() {
    super.initState();
    _showWidthField = widget.ctr.oviductWidthCtr.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final oviductAppearanceItems = _birdEncodedDropdownItems(
      oviductAppearanceList,
      widget.ctr.oviductAppearanceCtr,
    );

    return Column(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            DropdownButtonFormField<bool>(
              initialValue: _showWidthField,
              decoration: const InputDecoration(labelText: 'Width'),
              items: const [
                DropdownMenuItem(
                  value: false,
                  child: CommonDropdownText(text: 'minute'),
                ),
                DropdownMenuItem(
                  value: true,
                  child: CommonDropdownText(text: '1 mm or greater'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _showWidthField = value ?? false;
                });

                if (!_showWidthField) {
                  widget.ctr.oviductWidthCtr.clear();

                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(oviductWidth: const db.Value(null)),
                  );
                }
              },
            ),

            if (_showWidthField)
              CommonNumField(
                controller: widget.ctr.oviductWidthCtr,
                labelText: 'Width (mm)',
                hintText: 'Enter width',
                isDouble: true,
                isLastField: false,
                onChanged: (String? value) {
                  final parsed = double.tryParse(value ?? '');
                  if (value?.isNotEmpty == true && parsed == null) return;
                  SpecimenServices(ref: ref).updateBirdAttribute(
                    widget.specimenUuid,
                    BirdAttributeCompanion(oviductWidth: db.Value(parsed)),
                  );
                },
              ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            DropdownButtonFormField<int?>(
              initialValue: widget.ctr.oviductAppearanceCtr,
              decoration: const InputDecoration(labelText: 'Appearance'),
              items: DropDownMenuItems.addChooseOneToList(
                oviductAppearanceItems,
              ),
              onChanged: (int? newValue) {
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(oviductAppearance: db.Value(newValue)),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class MoltingForm extends ConsumerStatefulWidget {
  const MoltingForm({
    super.key,
    required this.specimenUuid,
    required this.ctr,
    required this.useHorizontalLayout,
  });

  final String specimenUuid;
  final BirdAttributeCtrModel ctr;
  final bool useHorizontalLayout;

  @override
  MoltingFormState createState() => MoltingFormState();
}

class MoltingFormState extends ConsumerState<MoltingForm> {
  bool _wingMolting = false;
  bool _tailMolting = false;

  @override
  void initState() {
    super.initState();
    _syncMoltVisibility();
  }

  @override
  void didUpdateWidget(covariant MoltingForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMoltVisibility();
  }

  void _syncMoltVisibility() {
    _wingMolting = widget.ctr.wingIsMoltCtr == 1;
    _tailMolting = widget.ctr.tailIsMoltCtr == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          const CommonDivider(),
          const FormCardSectionLabel(text: 'Molt'),
          BodyMoltForm(specimenUuid: widget.specimenUuid, ctr: widget.ctr),
          DropdownButtonFormField<int?>(
            initialValue: widget.ctr.wingIsMoltCtr,
            decoration: const InputDecoration(labelText: 'Wing molt'),
            items: DropDownMenuItems.booleanDropDownItems(),
            onChanged: (int? newValue) {
              setState(() {
                widget.ctr.wingIsMoltCtr = newValue;
                _wingMolting = newValue == 1;
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(wingIsMolt: db.Value(newValue)),
                );
              });
            },
          ),
          Visibility(
            visible: _wingMolting,
            child: WingMoltForm(
              specimenUuid: widget.specimenUuid,
              ctr: widget.ctr,
              useHorizontalLayout: widget.useHorizontalLayout,
            ),
          ),
          DropdownButtonFormField<int?>(
            initialValue: widget.ctr.tailIsMoltCtr,
            decoration: const InputDecoration(labelText: 'Tail molt'),
            items: DropDownMenuItems.booleanDropDownItems(),
            onChanged: (int? newValue) {
              setState(() {
                widget.ctr.tailIsMoltCtr = newValue;
                _tailMolting = newValue == 1;
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(tailIsMolt: db.Value(newValue)),
                );
              });
            },
          ),
          Visibility(
            visible: _tailMolting,
            child: TailMoltForm(
              specimenUuid: widget.specimenUuid,
              ctr: widget.ctr,
              useHorizontalLayout: widget.useHorizontalLayout,
            ),
          ),
          CommonTextField(
            controller: widget.ctr.moltRemarkCtr,
            maxLines: 3,
            labelText: 'Remarks',
            hintText: 'Add additional molt information',
            isLastField: true,
            onChanged: (String? value) {
              if (value != null) {
                SpecimenServices(ref: ref).updateBirdAttribute(
                  widget.specimenUuid,
                  BirdAttributeCompanion(moltRemark: db.Value(value)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class WingMoltForm extends ConsumerWidget {
  const WingMoltForm({
    super.key,
    required this.specimenUuid,
    required this.ctr,
    required this.useHorizontalLayout,
  });

  final String specimenUuid;
  final BirdAttributeCtrModel ctr;
  final bool useHorizontalLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonTextField(
      controller: ctr.wingMoltCtr,
      labelText: 'Wing molt',
      hintText: 'Enter wing molt',
      isLastField: false,
      maxLines: 2,
      onChanged: (String? value) {
        if (value != null) {
          SpecimenServices(ref: ref).updateBirdAttribute(
            specimenUuid,
            BirdAttributeCompanion(wingMolt: db.Value(value)),
          );
        }
      },
    );
  }
}

class TailMoltForm extends ConsumerWidget {
  const TailMoltForm({
    super.key,
    required this.specimenUuid,
    required this.ctr,
    required this.useHorizontalLayout,
  });

  final String specimenUuid;
  final BirdAttributeCtrModel ctr;
  final bool useHorizontalLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonTextField(
      controller: ctr.tailMoltCtr,
      labelText: 'Tail molt',
      hintText: 'Enter tail molt',
      maxLines: 2,
      isLastField: false,
      onChanged: (String? value) {
        if (value != null) {
          SpecimenServices(ref: ref).updateBirdAttribute(
            specimenUuid,
            BirdAttributeCompanion(tailMolt: db.Value(value)),
          );
        }
      },
    );
  }
}

class BodyMoltForm extends ConsumerWidget {
  const BodyMoltForm({
    super.key,
    required this.specimenUuid,
    required this.ctr,
  });

  final String specimenUuid;
  final BirdAttributeCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyMoltItems = _birdEncodedDropdownItems(
      bodyMoltList,
      ctr.bodyMoltCtr,
    );

    return DropdownButtonFormField<int?>(
      initialValue: ctr.bodyMoltCtr,
      decoration: const InputDecoration(labelText: 'Body molt'),
      items: DropDownMenuItems.addChooseOneToList(bodyMoltItems),
      onChanged: (int? newValue) {
        SpecimenServices(ref: ref).updateBirdAttribute(
          specimenUuid,
          BirdAttributeCompanion(bodyMolt: db.Value(newValue)),
        );
      },
    );
  }
}

List<DropdownMenuItem<int?>> _birdEncodedDropdownItems(
  List<String> labels,
  int? currentValue,
) {
  return [
    for (final (index, label) in labels.indexed)
      DropdownMenuItem<int?>(
        value: index,
        child: CommonDropdownText(text: label),
      ),
    if (currentValue != null &&
        (currentValue < 0 || currentValue >= labels.length))
      DropdownMenuItem<int?>(
        value: currentValue,
        child: CommonDropdownText(text: birdLabelForCode(labels, currentValue)),
      ),
  ];
}

class Notes extends ConsumerWidget {
  const Notes({super.key, required this.specimenUuid, required this.ctr});

  final String specimenUuid;
  final BirdAttributeCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          const FormCardSectionLabel(text: 'Notes'),
          CommonTextField(
            controller: ctr.habitatRemarkCtr,
            maxLines: 3,
            labelText: 'Habitat',
            hintText: 'Add additional information about the habitat',
            isLastField: true,
            onChanged: (String? value) {
              if (value != null) {
                SpecimenServices(ref: ref).updateBirdAttribute(
                  specimenUuid,
                  BirdAttributeCompanion(habitatRemark: db.Value(value)),
                );
              }
            },
          ),
          CommonTextField(
            controller: ctr.specimenRemarkCtr,
            maxLines: 3,
            labelText: 'Specimen',
            hintText: 'Add additional information about the specimen',
            isLastField: true,
            onChanged: (String? value) {
              if (value != null) {
                SpecimenServices(ref: ref).updateBirdAttribute(
                  specimenUuid,
                  BirdAttributeCompanion(specimenRemark: db.Value(value)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
