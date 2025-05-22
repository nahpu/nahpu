import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/specimens/shared/measurements.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/mammals.dart';
import 'package:drift/drift.dart' as db;

class MammalMeasurementForms extends ConsumerStatefulWidget {
  const MammalMeasurementForms({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
    required this.isBats,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;
  final bool isBats;

  @override
  MammalMeasurementFormsState createState() => MammalMeasurementFormsState();
}

class MammalMeasurementFormsState
    extends ConsumerState<MammalMeasurementForms> {
  MammalMeasurementCtrModel ctr = MammalMeasurementCtrModel.empty();
  TextEditingController headBodyLengthCtr = TextEditingController();
  TextEditingController tailHeadBodyPercentCtr = TextEditingController();

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
    headBodyLengthCtr.dispose();
    tailHeadBodyPercentCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MeasurementForm(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.totalLengthCtr,
              labelText: 'Total length (mm)',
              hintText: 'Enter TTL',
              isLastField: false,
              isDouble: true,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    _getHBTailPercent();
                    SpecimenServices(ref: ref).updateMammalMeasurement(
                      widget.specimenUuid,
                      MammalMeasurementCompanion(
                        totalLength: db.Value(double.tryParse(value) ?? 0),
                      ),
                    );
                  });
                }
              },
            ),
            CommonNumField(
              controller: ctr.tailLengthCtr,
              labelText: 'Tail length (mm)',
              hintText: 'Enter TL',
              isDouble: true,
              isLastField: false,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    _getHBTailPercent();
                    SpecimenServices(ref: ref).updateMammalMeasurement(
                      widget.specimenUuid,
                      MammalMeasurementCompanion(
                        tailLength: db.Value(double.tryParse(value)),
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
            Tooltip(
              message: 'Automatically calculated',
              child: CommonNumField(
                controller: headBodyLengthCtr,
                labelText: 'Head and body length (mm)',
                hintText: 'Enter HBL',
                enabled: false,
                isDouble: true,
                isLastField: false,
                onChanged: null,
              ),
            ),
            Tooltip(
              message: 'Automatically calculated',
              child: CommonNumField(
                controller: tailHeadBodyPercentCtr,
                labelText: 'Tail/HB length',
                hintText: 'Enter TL/HBL',
                enabled: false,
                isDouble: true,
                isLastField: false,
                onChanged: null,
              ),
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.hindFootCtr,
              labelText: 'Hind foot length (mm)',
              hintText: 'Enter HF length',
              isDouble: true,
              isLastField: false,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    SpecimenServices(ref: ref).updateMammalMeasurement(
                      widget.specimenUuid,
                      MammalMeasurementCompanion(
                        hindFootLength: db.Value(double.tryParse(value)),
                      ),
                    );
                  });
                }
              },
            ),
            CommonNumField(
              controller: ctr.earCtr,
              labelText: 'Ear length (mm)',
              hintText: 'Enter ER length',
              isLastField: false,
              isDouble: true,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    SpecimenServices(ref: ref).updateMammalMeasurement(
                      widget.specimenUuid,
                      MammalMeasurementCompanion(
                        earLength: db.Value(double.tryParse(value)),
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
              CommonNumField(
                controller: ctr.weightCtr,
                labelText: 'Weight (grams)',
                hintText: 'Enter specimen weight',
                isDouble: true,
                isLastField: false,
                onChanged: (value) {
                  if (value != null && value.isNotEmpty) {
                    setState(() {
                      SpecimenServices(ref: ref).updateMammalMeasurement(
                        widget.specimenUuid,
                        MammalMeasurementCompanion(
                          weight: db.Value(double.tryParse(value)),
                        ),
                      );
                    });
                  }
                },
              ),
              Visibility(
                visible: widget.isBats,
                child: CommonNumField(
                  controller: ctr.forearmCtr,
                  labelText: 'Forearm Length (mm)',
                  hintText: 'Enter FL length',
                  isLastField: true,
                  isDouble: true,
                  onChanged: (value) {
                    if (value != null && value.isNotEmpty) {
                      setState(() {
                        SpecimenServices(ref: ref).updateMammalMeasurement(
                          widget.specimenUuid,
                          MammalMeasurementCompanion(
                            forearm: db.Value(double.tryParse(value)),
                          ),
                        );
                      });
                    }
                  },
                ),
              ),
            ]),
        Padding(
          padding: const EdgeInsets.all(5),
          child: DropdownButtonFormField(
              value: ctr.accuracyCtr,
              decoration: const InputDecoration(
                labelText: 'Accuracy',
                hintText: 'Select measurement accuracy',
              ),
              items: accuracyList
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                ctr.accuracyCtr = newValue;
                SpecimenServices(ref: ref).updateMammalMeasurement(
                  widget.specimenUuid,
                  MammalMeasurementCompanion(
                    accuracy: db.Value(newValue),
                  ),
                );
              }),
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            DropdownButtonFormField<SpecimenSex>(
                value: getSpecimenSex(ctr.sexCtr),
                decoration: const InputDecoration(
                  labelText: 'Sex',
                  hintText: 'Select specimen sex',
                ),
                items: specimenSexList
                    .map((e) => DropdownMenuItem(
                          value: SpecimenSex.values[specimenSexList.indexOf(e)],
                          child: CommonDropdownText(text: e),
                        ))
                    .toList(),
                onChanged: (SpecimenSex? newValue) {
                  if (newValue != null) {
                    setState(() {
                      ctr.sexCtr = newValue.index;
                      SpecimenServices(ref: ref).updateMammalMeasurement(
                        widget.specimenUuid,
                        MammalMeasurementCompanion(
                          sex: db.Value(
                            newValue.index,
                          ),
                        ),
                      );
                    });
                  }
                }),
            Expanded(
              child: DropdownButtonFormField<SpecimenAge>(
                value: getSpecimenAge(ctr.ageCtr),
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'Select specimen age',
                ),
                items: specimenAgeList
                    .map((e) => DropdownMenuItem(
                          value: SpecimenAge.values[specimenAgeList.indexOf(e)],
                          child: CommonDropdownText(text: e),
                        ))
                    .toList(),
                onChanged: (SpecimenAge? newValue) {
                  if (newValue != null) {
                    setState(
                      () {
                        ctr.ageCtr = newValue.index;
                        SpecimenServices(ref: ref).updateMammalMeasurement(
                          widget.specimenUuid,
                          MammalMeasurementCompanion(
                            age: db.Value(
                              newValue.index,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
        MaleGonadForm(
          specimenUuid: widget.specimenUuid,
          specimenSex: getSpecimenSex(ctr.sexCtr),
          useHorizontalLayout: widget.useHorizontalLayout,
          ctr: ctr,
        ),
        OvaryOpeningField(
          specimenUuid: widget.specimenUuid,
          specimenSex: getSpecimenSex(ctr.sexCtr),
          specimenAge: getSpecimenAge(ctr.ageCtr),
          useHorizontalLayout: widget.useHorizontalLayout,
          ctr: ctr,
        ),
        FemaleGonadForm(
          specimenUuid: widget.specimenUuid,
          specimenSex: getSpecimenSex(ctr.sexCtr),
          specimenAge: getSpecimenAge(ctr.ageCtr),
          useHorizontalLayout: widget.useHorizontalLayout,
          ctr: ctr,
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: CommonTextField(
            controller: ctr.remarksCtr,
            maxLines: 5,
            labelText: 'Remarks',
            hintText: 'Write notes about the measurements (optional)',
            isLastField: true,
            onChanged: (value) {
              SpecimenServices(ref: ref).updateMammalMeasurement(
                widget.specimenUuid,
                MammalMeasurementCompanion(
                  remark: db.Value(value),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _updateCtr(String specimenUuid) async {
    MammalMeasurementData data =
        await SpecimenServices(ref: ref).getMammalMeasurementData(specimenUuid);

    setState(() {
      ctr = MammalMeasurementCtrModel.fromData(data);
      _getHBTailPercent();
    });
  }

  void _getHBTailPercent() {
    MammalMeasurementServices service = MammalMeasurementServices(
      totalLengthText: ctr.totalLengthCtr.text,
      tailLengthText: ctr.tailLengthCtr.text,
    );

    ({String headAndBodyText, String percentTailText})? results =
        service.getHBandTailPercentage();

    headBodyLengthCtr.text = results?.headAndBodyText ?? '';
    tailHeadBodyPercentCtr.text = results?.percentTailText ?? '';
  }
}

class MaleGonadForm extends ConsumerStatefulWidget {
  const MaleGonadForm({
    super.key,
    required this.specimenUuid,
    required this.specimenSex,
    required this.useHorizontalLayout,
    required this.ctr,
  });

  final String specimenUuid;
  final SpecimenSex? specimenSex;
  final bool useHorizontalLayout;
  final MammalMeasurementCtrModel ctr;

  @override
  MaleGonadFormState createState() => MaleGonadFormState();
}

class MaleGonadFormState extends ConsumerState<MaleGonadForm> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.specimenSex == SpecimenSex.male,
      child: Column(
        children: [
          const CommonDivider(),
          Text('Testes', style: Theme.of(context).textTheme.titleLarge),
          Padding(
            padding: const EdgeInsets.all(5),
            child: DropdownButtonFormField<TestisPosition>(
              value: getTestisPosition(widget.ctr.testisPosCtr),
              decoration: const InputDecoration(
                labelText: 'Position',
                hintText: 'Select testis position',
              ),
              items: testisPositionList
                  .map((e) => DropdownMenuItem(
                        value: TestisPosition
                            .values[testisPositionList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (TestisPosition? newValue) {
                if (newValue != null) {
                  setState(
                    () {
                      widget.ctr.testisPosCtr = newValue.index;
                      SpecimenServices(ref: ref).updateMammalMeasurement(
                        widget.specimenUuid,
                        MammalMeasurementCompanion(
                          testisPosition: db.Value(
                            newValue.index,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          ScrotalMaleForm(
            specimenUuid: widget.specimenUuid,
            visible: getTestisPosition(widget.ctr.testisPosCtr) ==
                TestisPosition.scrotal,
            useHorizontalLayout: widget.useHorizontalLayout,
            ctr: widget.ctr,
          ),
        ],
      ),
    );
  }
}

class ScrotalMaleForm extends ConsumerStatefulWidget {
  const ScrotalMaleForm({
    super.key,
    required this.specimenUuid,
    required this.visible,
    required this.useHorizontalLayout,
    required this.ctr,
  });

  final String specimenUuid;
  final bool visible;
  final bool useHorizontalLayout;
  final MammalMeasurementCtrModel ctr;

  @override
  ScrotalMaleFormState createState() => ScrotalMaleFormState();
}

class ScrotalMaleFormState extends ConsumerState<ScrotalMaleForm> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: Column(
        children: [
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              CommonNumField(
                controller: widget.ctr.testisLengthCtr,
                labelText: 'Length (mm)',
                hintText: 'Enter the length of the right testes ',
                isLastField: false,
                isDouble: true,
                onChanged: (String? value) {
                  SpecimenServices(ref: ref).updateMammalMeasurement(
                    widget.specimenUuid,
                    MammalMeasurementCompanion(
                      testisLength: db.Value(
                        double.tryParse(value ?? '0'),
                      ),
                    ),
                  );
                },
              ),
              CommonNumField(
                controller: widget.ctr.testisWidthCtr,
                labelText: 'Width (mm)',
                hintText: 'Enter the width of the right testes ',
                isLastField: true,
                isDouble: true,
                onChanged: (String? value) {
                  SpecimenServices(ref: ref).updateMammalMeasurement(
                    widget.specimenUuid,
                    MammalMeasurementCompanion(
                      testisWidth: db.Value(
                        double.tryParse(value ?? '0'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: DropdownButtonFormField<EpididymisAppearance>(
              value: _getEpididymisAppearance(),
              decoration: const InputDecoration(
                labelText: 'Epididymis',
                hintText: 'Select epididymis appearance',
              ),
              items: epididymisAppearanceList
                  .map((e) => DropdownMenuItem(
                        value: EpididymisAppearance
                            .values[epididymisAppearanceList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  SpecimenServices(ref: ref).updateMammalMeasurement(
                    widget.specimenUuid,
                    MammalMeasurementCompanion(
                      epididymisAppearance: db.Value(
                        value.index,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  EpididymisAppearance? _getEpididymisAppearance() {
    if (widget.ctr.epididymisCtr != null) {
      return EpididymisAppearance.values[widget.ctr.epididymisCtr!];
    }
    return null;
  }
}

class OvaryOpeningField extends ConsumerWidget {
  const OvaryOpeningField({
    super.key,
    required this.specimenUuid,
    required this.specimenSex,
    required this.specimenAge,
    required this.useHorizontalLayout,
    required this.ctr,
  });

  final String specimenUuid;
  final SpecimenSex? specimenSex;
  final SpecimenAge? specimenAge;
  final bool useHorizontalLayout;
  final MammalMeasurementCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(
      useHorizontalLayout: useHorizontalLayout,
      children: [
        Visibility(
          visible: specimenSex == SpecimenSex.female,
          child: DropdownButtonFormField<VaginaOpening>(
            value: _getVaginaOpening(),
            decoration: const InputDecoration(
              labelText: 'Vagina opening',
              hintText: 'Select vagina opening',
            ),
            items: vaginaOpeningList
                .map((e) => DropdownMenuItem(
                      value: VaginaOpening.values[vaginaOpeningList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ))
                .toList(),
            onChanged: (VaginaOpening? newValue) {
              if (newValue != null) {
                SpecimenServices(ref: ref).updateMammalMeasurement(
                  specimenUuid,
                  MammalMeasurementCompanion(
                    vaginaOpening: db.Value(
                      newValue.index,
                    ),
                  ),
                );
              }
            },
          ),
        ),
        Visibility(
          visible: specimenSex == SpecimenSex.female &&
              specimenAge == SpecimenAge.adult,
          child: DropdownButtonFormField<PubicSymphysis>(
            value: _getPubicSymphysis(),
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Pubic symphysis',
              hintText: 'Select pubic symphysis condition',
            ),
            items: pubicSymphysisList
                .map((e) => DropdownMenuItem(
                      value:
                          PubicSymphysis.values[pubicSymphysisList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ))
                .toList(),
            onChanged: (PubicSymphysis? newValue) {
              if (newValue != null) {
                SpecimenServices(ref: ref).updateMammalMeasurement(
                  specimenUuid,
                  MammalMeasurementCompanion(
                    pubicSymphysis: db.Value(
                      newValue.index,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  VaginaOpening? _getVaginaOpening() {
    if (ctr.vaginaOpeningCtr != null) {
      return VaginaOpening.values[ctr.vaginaOpeningCtr!];
    }
    return null;
  }

  PubicSymphysis? _getPubicSymphysis() {
    if (ctr.pubicSymphysisCtr != null) {
      return PubicSymphysis.values[ctr.pubicSymphysisCtr!];
    }
    return null;
  }
}

class FemaleGonadForm extends ConsumerWidget {
  const FemaleGonadForm({
    super.key,
    required this.specimenUuid,
    required this.specimenSex,
    required this.specimenAge,
    required this.useHorizontalLayout,
    required this.ctr,
  });

  final String specimenUuid;
  final SpecimenSex? specimenSex;
  final SpecimenAge? specimenAge;
  final bool useHorizontalLayout;
  final MammalMeasurementCtrModel ctr;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible:
          specimenSex == SpecimenSex.female && specimenAge == SpecimenAge.adult,
      child: Column(
        children: [
          const CommonDivider(),
          Padding(
            padding: const EdgeInsets.all(5),
            child: DropdownButtonFormField<ReproductiveStage>(
              value: _getReproductiveStage(),
              decoration: const InputDecoration(
                labelText: 'Reproductive stage',
                hintText: 'Select reproductive stage',
              ),
              items: reproductiveStageList
                  .map((e) => DropdownMenuItem(
                        value: ReproductiveStage
                            .values[reproductiveStageList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (ReproductiveStage? newValue) {
                if (newValue != null) {
                  SpecimenServices(ref: ref).updateMammalMeasurement(
                    specimenUuid,
                    MammalMeasurementCompanion(
                      reproductiveStage: db.Value(
                        newValue.index,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const CommonDivider(),
          Text('Mammae Counts (pairs)',
              style: Theme.of(context).textTheme.titleLarge),
          MammaeForm(
            useHorizontalLayout: useHorizontalLayout,
            specimenUuid: specimenUuid,
            ctr: ctr,
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: DropdownButtonFormField<MammaeCondition>(
              value: _getMammaeCondition(),
              decoration: const InputDecoration(
                labelText: 'Mammae condition',
                hintText: 'Select mammae condition',
              ),
              items: mammaeConditionList
                  .map((e) => DropdownMenuItem(
                        value: MammaeCondition
                            .values[mammaeConditionList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (MammaeCondition? newValue) {
                if (newValue != null) {
                  SpecimenServices(ref: ref).updateMammalMeasurement(
                    specimenUuid,
                    MammalMeasurementCompanion(
                      mammaeCondition: db.Value(
                        newValue.index,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const CommonDivider(),
          Text(
            'Embryo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          EmbryoForm(
            useHorizontalLayout: useHorizontalLayout,
            specimenUuid: specimenUuid,
            ctr: ctr,
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: CommonNumField(
              controller: ctr.embryoCRCtr,
              labelText: 'CR length (mm)',
              hintText: 'Enter crown-rump length',
              isLastField: true,
              onChanged: (String? value) {
                if (value != null) {
                  SpecimenServices(ref: ref).updateMammalMeasurement(
                    specimenUuid,
                    MammalMeasurementCompanion(
                      embryoCR: db.Value(
                        int.tryParse(value),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const CommonDivider(),
          Text('Placental Scars',
              style: Theme.of(context).textTheme.titleLarge),
          PlacentalScarForm(
            useHorizontalLayout: useHorizontalLayout,
            specimenUuid: specimenUuid,
            ctr: ctr,
          ),
        ],
      ),
    );
  }

  ReproductiveStage? _getReproductiveStage() {
    if (ctr.reproductiveStageCtr != null) {
      return ReproductiveStage.values[ctr.reproductiveStageCtr!];
    }
    return null;
  }

  MammaeCondition? _getMammaeCondition() {
    if (ctr.mammaeConditionCtr != null) {
      return MammaeCondition.values[ctr.mammaeConditionCtr!];
    }
    return null;
  }
}

class MammaeForm extends ConsumerWidget {
  const MammaeForm({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
    required this.ctr,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;
  final MammalMeasurementCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(useHorizontalLayout: useHorizontalLayout, children: [
      CommonNumField(
        controller: ctr.mammaeAxCtr,
        labelText: 'Axillary',
        hintText: 'Enter the axillary pair number',
        isLastField: false,
        onChanged: (String? value) {
          if (value != null) {
            SpecimenServices(ref: ref).updateMammalMeasurement(
              specimenUuid,
              MammalMeasurementCompanion(
                mammaeAxillaryCount: db.Value(
                  int.tryParse(value),
                ),
              ),
            );
          }
        },
      ),
      CommonNumField(
        controller: ctr.mammaeAbdCtr,
        labelText: 'Abdominal',
        hintText: 'Enter the abdominal pair number',
        isLastField: false,
        onChanged: (String? value) {
          if (value != null) {
            SpecimenServices(ref: ref).updateMammalMeasurement(
              specimenUuid,
              MammalMeasurementCompanion(
                mammaeAbdominalCount: db.Value(
                  int.tryParse(value),
                ),
              ),
            );
          }
        },
      ),
      CommonNumField(
        controller: ctr.mammaeIngCtr,
        labelText: 'Inguinal',
        hintText: 'Enter the inguinal pair number',
        isLastField: false,
        onChanged: (String? value) {
          if (value != null) {
            SpecimenServices(ref: ref).updateMammalMeasurement(
              specimenUuid,
              MammalMeasurementCompanion(
                mammaeInguinalCount: db.Value(
                  int.tryParse(value),
                ),
              ),
            );
          }
        },
      ),
    ]);
  }
}

class EmbryoForm extends ConsumerWidget {
  const EmbryoForm({
    super.key,
    required this.useHorizontalLayout,
    required this.ctr,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String? specimenUuid;
  final MammalMeasurementCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(useHorizontalLayout: useHorizontalLayout, children: [
      CommonNumField(
        controller: ctr.embryoLeftCtr,
        labelText: 'Left',
        hintText: 'Left',
        isLastField: false,
        onChanged: (String? value) {
          if (value != null) {
            SpecimenServices(ref: ref).updateMammalMeasurement(
              specimenUuid!,
              MammalMeasurementCompanion(
                embryoLeftCount: db.Value(
                  int.tryParse(value),
                ),
              ),
            );
          }
        },
      ),
      CommonNumField(
        controller: ctr.embryoRightCtr,
        labelText: 'Right',
        hintText: 'Right',
        isLastField: true,
        onChanged: (String? value) {
          if (value != null) {
            SpecimenServices(ref: ref).updateMammalMeasurement(
              specimenUuid!,
              MammalMeasurementCompanion(
                embryoRightCount: db.Value(
                  int.tryParse(value),
                ),
              ),
            );
          }
        },
      ),
    ]);
  }
}

class PlacentalScarForm extends ConsumerWidget {
  const PlacentalScarForm({
    super.key,
    required this.useHorizontalLayout,
    required this.ctr,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;
  final MammalMeasurementCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(useHorizontalLayout: useHorizontalLayout, children: [
      CommonNumField(
        controller: ctr.leftPlacentaCtr,
        labelText: 'Left',
        hintText: 'Left',
        isLastField: false,
        onChanged: (String? value) {
          if (value != null) {
            SpecimenServices(ref: ref).updateMammalMeasurement(
              specimenUuid,
              MammalMeasurementCompanion(
                leftPlacentalScars: db.Value(
                  int.tryParse(value),
                ),
              ),
            );
          }
        },
      ),
      CommonNumField(
        controller: ctr.rightPlacentaCtr,
        labelText: 'Right',
        hintText: 'Right',
        isLastField: true,
        onChanged: (String? value) {
          if (value != null) {
            SpecimenServices(ref: ref).updateMammalMeasurement(
              specimenUuid,
              MammalMeasurementCompanion(
                rightPlacentalScars: db.Value(
                  int.tryParse(value),
                ),
              ),
            );
          }
        },
      ),
    ]);
  }
}
