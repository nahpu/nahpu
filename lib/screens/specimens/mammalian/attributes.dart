import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/screens/specimens/shared/weight_field.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/measurement_outlier_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/mammals.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/localization/l10n.dart';

class MammalAttributeForms extends ConsumerStatefulWidget {
  const MammalAttributeForms({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;

  @override
  MammalAttributeFormsState createState() => MammalAttributeFormsState();
}

class MammalAttributeFormsState extends ConsumerState<MammalAttributeForms> {
  MammalAttributeCtrModel ctr = MammalAttributeCtrModel.empty();
  TextEditingController headBodyLengthCtr = TextEditingController();
  TextEditingController tailHeadBodyPercentCtr = TextEditingController();
  final FocusNode _totalLengthFocusNode = FocusNode();
  final FocusNode _tailLengthFocusNode = FocusNode();
  final FocusNode _hindFootFocusNode = FocusNode();
  final FocusNode _earFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();
  final Set<String> _shownOutlierWarnings = {};
  final Map<MammalMeasurementOutlierField, Timer> _outlierWarningTimers = {};
  // String? _hblErrorText;
  bool _isShowingOutlierWarning = false;
  bool _showOutlierWarnings = true;
  bool _showBatFields = false;
  bool _hasStoredBatData = false;
  int _accuracyDropdownVersion = 0;
  String? _storedAccuracy;
  String? _storedAccuracySpecify;
  Key _sexDropdownKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _addOutlierListener(
      _totalLengthFocusNode,
      MammalMeasurementOutlierField.totalLength,
      () => double.tryParse(ctr.totalLengthCtr.text),
    );
    _addOutlierListener(
      _tailLengthFocusNode,
      MammalMeasurementOutlierField.tailLength,
      () => double.tryParse(ctr.tailLengthCtr.text),
    );
    _addOutlierListener(
      _hindFootFocusNode,
      MammalMeasurementOutlierField.hindFootLength,
      () => double.tryParse(ctr.hindFootCtr.text),
    );
    _addOutlierListener(
      _earFocusNode,
      MammalMeasurementOutlierField.earLength,
      () => double.tryParse(ctr.earCtr.text),
    );
    _addOutlierListener(
      _weightFocusNode,
      MammalMeasurementOutlierField.weight,
      () => double.tryParse(ctr.weightCtr.text),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCtr(widget.specimenUuid);
    });
  }

  @override
  void dispose() {
    ctr.dispose();
    headBodyLengthCtr.dispose();
    tailHeadBodyPercentCtr.dispose();
    _totalLengthFocusNode.dispose();
    _tailLengthFocusNode.dispose();
    _hindFootFocusNode.dispose();
    _earFocusNode.dispose();
    _weightFocusNode.dispose();
    for (final timer in _outlierWarningTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AttributeForm(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            SwitchField(
              label: context.l10n.specimenShowOutlierWarnings,
              value: _showOutlierWarnings,
              onPressed: (value) {
                setState(() {
                  _showOutlierWarnings = value;
                });
                if (!value) {
                  for (final timer in _outlierWarningTimers.values) {
                    timer.cancel();
                  }
                  _outlierWarningTimers.clear();
                }
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.totalLengthCtr,
              focusNode: _totalLengthFocusNode,
              isBracketed:
                  _isMeasurementInaccurate('totalLength') &&
                  ctr.totalLengthCtr.text.isNotEmpty,
              labelText: context.l10n.mammalTotalLength,
              hintText: context.l10n.mammalTotalLengthHint,
              isLastField: false,
              isDouble: true,
              // errorText: _hblErrorText,
              onChanged: (String? value) {
                final measurement = double.tryParse(value ?? '');
                setState(() {
                  _getHBTailPercent();
                });
                SpecimenServices(ref: ref).updateMammalAttribute(
                  widget.specimenUuid,
                  MammalAttributeCompanion(
                    totalLength: db.Value(measurement ?? 0),
                  ),
                );
                _scheduleOutlierWarning(
                  MammalMeasurementOutlierField.totalLength,
                  measurement,
                );
              },
            ),
            CommonNumField(
              controller: ctr.tailLengthCtr,
              focusNode: _tailLengthFocusNode,
              isBracketed:
                  _isMeasurementInaccurate('tailLength') &&
                  ctr.tailLengthCtr.text.isNotEmpty,
              labelText: context.l10n.mammalTailLength,
              hintText: context.l10n.mammalTailLengthHint,
              isDouble: true,
              isLastField: false,
              // errorText: _hblErrorText,
              onChanged: (String? value) {
                final measurement = double.tryParse(value ?? '');
                setState(() {
                  _getHBTailPercent();
                });
                SpecimenServices(ref: ref).updateMammalAttribute(
                  widget.specimenUuid,
                  MammalAttributeCompanion(
                    tailLength: db.Value(measurement ?? 0),
                  ),
                );
                _scheduleOutlierWarning(
                  MammalMeasurementOutlierField.tailLength,
                  measurement,
                );
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            Tooltip(
              message: context.l10n.specimenAutoCalculated,
              child: CommonNumField(
                controller: headBodyLengthCtr,
                labelText: context.l10n.mammalHeadBodyLength,
                hintText: context.l10n.mammalHeadBodyLengthHint,
                enabled: false,
                isDouble: true,
                isLastField: false,
                onChanged: null,
              ),
            ),
            Tooltip(
              message: context.l10n.specimenAutoCalculated,
              child: CommonNumField(
                controller: tailHeadBodyPercentCtr,
                labelText: context.l10n.mammalTailHeadBodyRatio,
                hintText: context.l10n.mammalTailHeadBodyRatioHint,
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
              focusNode: _hindFootFocusNode,
              isBracketed:
                  _isMeasurementInaccurate('hindFootLength') &&
                  ctr.hindFootCtr.text.isNotEmpty,
              labelText: context.l10n.mammalHindFootLength,
              hintText: context.l10n.mammalHindFootLengthHint,
              isDouble: true,
              isLastField: false,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    widget.specimenUuid,
                    MammalAttributeCompanion(
                      hindFootLength: db.Value(double.tryParse(value)),
                    ),
                  );
                  _scheduleOutlierWarning(
                    MammalMeasurementOutlierField.hindFootLength,
                    double.tryParse(value),
                  );
                }
              },
            ),
            CommonNumField(
              controller: ctr.earCtr,
              focusNode: _earFocusNode,
              isBracketed:
                  _isMeasurementInaccurate('earLength') &&
                  ctr.earCtr.text.isNotEmpty,
              labelText: context.l10n.mammalEarLength,
              hintText: context.l10n.mammalEarLengthHint,
              isLastField: false,
              isDouble: true,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    widget.specimenUuid,
                    MammalAttributeCompanion(
                      earLength: db.Value(double.tryParse(value)),
                    ),
                  );
                  _scheduleOutlierWarning(
                    MammalMeasurementOutlierField.earLength,
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
            WeightField(
              controller: ctr.weightCtr,
              focusNode: _weightFocusNode,
              isBracketed:
                  _isMeasurementInaccurate('weight') &&
                  ctr.weightCtr.text.isNotEmpty,
              unit: ctr.weightUnitCtr,
              onUnitChanged: (unit) {
                setState(() => ctr.weightUnitCtr = unit);
                SpecimenServices(ref: ref).updateMammalAttribute(
                  widget.specimenUuid,
                  MammalAttributeCompanion(weightUnit: db.Value(unit)),
                );
              },
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    widget.specimenUuid,
                    MammalAttributeCompanion(
                      weight: db.Value(double.tryParse(value)),
                      weightUnit: db.Value(ctr.weightUnitCtr),
                    ),
                  );
                  _scheduleOutlierWarning(
                    MammalMeasurementOutlierField.weight,
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
            SwitchField(
              label: context.l10n.mammalShowBatFields,
              value: _showBatFields,
              disabled: _isBatSectionForced,
              onPressed: (value) {
                setState(() {
                  _showBatFields = value;
                  ctr.accuracyCtr = parseMammalAccuracy(
                    _storedAccuracy,
                    accuracySpecify: _storedAccuracySpecify,
                    includeBatFields: value,
                  );
                });
                SpecimenServices(ref: ref).updateMammalAttribute(
                  widget.specimenUuid,
                  MammalAttributeCompanion(
                    showBatFields: db.Value(value ? 1 : 0),
                  ),
                );
              },
            ),
          ],
        ),
        Visibility(
          visible: _showBatFields,
          child: BatForm(
            useHorizontalLayout: widget.useHorizontalLayout,
            ctr: ctr,
            specimenUuid: widget.specimenUuid,
            inaccurateFields: ctr.accuracyCtr.inaccurateFields,
            onBatDataEntered: _markBatDataStored,
          ),
        ),
        MammalAccuracyField(
          key: ValueKey(
            '${_accuracyDropdownVersion}_${ctr.accuracyCtr.status.name}',
          ),
          details: ctr.accuracyCtr,
          onStatusChanged: _onAccuracyStatusChanged,
          onEditPressed: _editAccuracy,
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
                SpecimenServices(ref: ref).updateMammalAttribute(
                  widget.specimenUuid,
                  MammalAttributeCompanion(lifeStage: db.Value(value)),
                );
              },
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
          lifeStage: ctr.lifeStageCtr,
          useHorizontalLayout: widget.useHorizontalLayout,
          ctr: ctr,
        ),
        FemaleGonadForm(
          specimenUuid: widget.specimenUuid,
          specimenSex: getSpecimenSex(ctr.sexCtr),
          lifeStage: ctr.lifeStageCtr,
          useHorizontalLayout: widget.useHorizontalLayout,
          ctr: ctr,
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: CommonTextField(
            controller: ctr.remarksCtr,
            maxLines: 5,
            labelText: context.l10n.specimenRemarks,
            hintText: context.l10n.specimenMeasurementRemarksHint,
            isLastField: true,
            onChanged: (value) {
              SpecimenServices(ref: ref).updateMammalAttribute(
                widget.specimenUuid,
                MammalAttributeCompanion(remark: db.Value(value)),
              );
            },
          ),
        ),
        ParasiteDetectionForm(specimenUuid: widget.specimenUuid),
        CustomFieldForm(owner: CustomFieldOwner.specimen(widget.specimenUuid)),
      ],
    );
  }

  bool get isBatFieldsAlwaysShown {
    return SpecimenSettingServices(
      ref: ref,
    ).getSpecimenSettingField(batFieldsKey);
  }

  bool get _isBatSectionForced => isBatFieldsAlwaysShown || _hasStoredBatData;

  Future<void> _updateCtr(String specimenUuid) async {
    MammalAttributeData data = await SpecimenServices(
      ref: ref,
    ).getMammalAttributeData(specimenUuid);
    if (!mounted) return;

    final hasStoredBatData = _hasBatData(data);
    final showBatFields =
        isBatFieldsAlwaysShown || hasStoredBatData || data.showBatFields == 1;
    final previousCtr = ctr;

    setState(() {
      ctr = MammalAttributeCtrModel.fromData(
        data,
        includeBatFields: showBatFields,
      );
      _storedAccuracy = data.accuracy;
      _storedAccuracySpecify = data.accuracySpecify;
      _hasStoredBatData = hasStoredBatData;
      _getHBTailPercent();
      _showBatFields = showBatFields;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => previousCtr.dispose());
  }

  bool _isMeasurementInaccurate(String field) {
    return ctr.accuracyCtr.isInaccurate &&
        ctr.accuracyCtr.inaccurateFields.contains(field);
  }

  bool _hasBatData(MammalAttributeData data) {
    return data.forearm != null ||
        data.tibia != null ||
        data.showEchoFields == 1 ||
        data.echolocation != null ||
        data.frequencyMax != null ||
        data.frequencyMin != null ||
        data.frequencyAtMaxEnergy != null ||
        data.duration != null;
  }

  void _markBatDataStored() {
    if (_hasStoredBatData) return;
    setState(() {
      _hasStoredBatData = true;
      _showBatFields = true;
      ctr.accuracyCtr = parseMammalAccuracy(
        _storedAccuracy,
        accuracySpecify: _storedAccuracySpecify,
        includeBatFields: true,
      );
    });
  }

  Future<void> _onAccuracyStatusChanged(MammalAccuracyStatus? status) async {
    if (status == null || status == ctr.accuracyCtr.status) return;
    if (status == MammalAccuracyStatus.inaccurate) {
      await _editAccuracy();
      return;
    }

    final details = MammalAccuracyDetails(
      status: MammalAccuracyStatus.accurate,
    );
    setState(() {
      ctr.accuracyCtr = details;
      _storedAccuracy = 'accurate';
      _storedAccuracySpecify = null;
      _accuracyDropdownVersion++;
    });
    SpecimenServices(ref: ref).updateMammalAttribute(
      widget.specimenUuid,
      const MammalAttributeCompanion(
        accuracy: db.Value('accurate'),
        accuracySpecify: db.Value(null),
      ),
    );
  }

  Future<void> _editAccuracy() async {
    final details = await showDialog<MammalAccuracyDetails>(
      context: context,
      builder: (context) => MammalAccuracyDialog(
        initialDetails: ctr.accuracyCtr.copyWith(
          status: MammalAccuracyStatus.inaccurate,
        ),
        includeBatFields: _showBatFields,
      ),
    );
    if (!mounted) return;
    if (details == null) {
      setState(() => _accuracyDropdownVersion++);
      return;
    }

    final storedAccuracy = serializeMammalAccuracy(details);
    final storedRemark = details.remark.trim();
    setState(() {
      ctr.accuracyCtr = details.copyWith(remark: storedRemark);
      _storedAccuracy = storedAccuracy;
      _storedAccuracySpecify = storedRemark.isEmpty ? null : storedRemark;
      _accuracyDropdownVersion++;
    });
    SpecimenServices(ref: ref).updateMammalAttribute(
      widget.specimenUuid,
      MammalAttributeCompanion(
        accuracy: db.Value(storedAccuracy),
        accuracySpecify: db.Value(storedRemark.isEmpty ? null : storedRemark),
      ),
    );
  }

  void _getHBTailPercent() {
    MammalMeasurementServices service = MammalMeasurementServices(
      totalLengthText: ctr.totalLengthCtr.text,
      tailLengthText: ctr.tailLengthCtr.text,
    );

    ({String headAndBodyText, String percentTailText, String errorText})?
    results = service.getHBandTailPercentage();

    headBodyLengthCtr.text = results?.headAndBodyText ?? '';
    tailHeadBodyPercentCtr.text = results?.percentTailText ?? '';
    // _hblErrorText = results?.errorText ?? '';
  }

  void _addOutlierListener(
    FocusNode focusNode,
    MammalMeasurementOutlierField field,
    double? Function() getValue,
  ) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        _showOutlierWarning(field, getValue());
      }
    });
  }

  void _scheduleOutlierWarning(
    MammalMeasurementOutlierField field,
    double? value,
  ) {
    if (!_showOutlierWarnings) return;

    _outlierWarningTimers[field]?.cancel();
    _outlierWarningTimers[field] = Timer(
      const Duration(milliseconds: 800),
      () => _showOutlierWarning(field, value),
    );
  }

  Future<void> _showOutlierWarning(
    MammalMeasurementOutlierField field,
    double? value,
  ) async {
    if (!_showOutlierWarnings || value == null || _isShowingOutlierWarning) {
      return;
    }

    final result = await MammalMeasurementOutlierServices(
      ref: ref,
    ).checkValue(specimenUuid: widget.specimenUuid, field: field, value: value);

    if (!mounted || !_showOutlierWarnings || result == null) return;

    final warningKey =
        '${field.name}:${result.value}:${result.lowerBound}:${result.upperBound}';
    if (!_shownOutlierWarnings.add(warningKey)) return;

    _isShowingOutlierWarning = true;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.specimenUnusualMeasurement),
        content: Text(result.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    _isShowingOutlierWarning = false;
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
          titleText: context.l10n.mammalChangeSexTitle,
          descText: context.l10n.mammalChangeSexBody,
          confirmFunction: () {
            ctr.clearSexControllers(male: clearMale, female: clearFemale);
            SpecimenServices(ref: ref).clearMammalSexAttributes(
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
    });
    SpecimenServices(ref: ref).updateMammalAttribute(
      widget.specimenUuid,
      MammalAttributeCompanion(sex: db.Value(code)),
    );
  }
}

class MammalAccuracyField extends StatelessWidget {
  const MammalAccuracyField({
    super.key,
    required this.details,
    required this.onStatusChanged,
    required this.onEditPressed,
  });

  final MammalAccuracyDetails details;
  final ValueChanged<MammalAccuracyStatus?> onStatusChanged;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    final selectedLabels = mammalAccuracyFieldOrder
        .where(details.inaccurateFields.contains)
        .map((field) => mammalAccuracyFieldLabels[field]!)
        .join(', ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<MammalAccuracyStatus>(
            initialValue: details.status,
            decoration: InputDecoration(
              labelText: context.l10n.specimenAccuracy,
              hintText: context.l10n.specimenAccuracyHint,
            ),
            items: MammalAccuracyStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: CommonDropdownText(text: accuracyList[status.index]),
                  ),
                )
                .toList(),
            onChanged: onStatusChanged,
          ),
          if (details.isInaccurate) ...[
            const SizedBox(height: 8),
            Text(
              selectedLabels.isEmpty
                  ? context.l10n.specimenNoInaccurateSelected
                  : context.l10n.specimenInaccurateList(selectedLabels),
            ),
            if (details.remark.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                context.l10n.specimenAccuracyRemarkValue(details.remark.trim()),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onEditPressed,
                icon: const Icon(Icons.edit_outlined),
                label: Text(context.l10n.specimenSelectInaccurate),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class MammalAccuracyDialog extends StatefulWidget {
  const MammalAccuracyDialog({
    super.key,
    required this.initialDetails,
    required this.includeBatFields,
  });

  final MammalAccuracyDetails initialDetails;
  final bool includeBatFields;

  @override
  State<MammalAccuracyDialog> createState() => _MammalAccuracyDialogState();
}

class _MammalAccuracyDialogState extends State<MammalAccuracyDialog> {
  late final Set<String> _selectedFields;
  late final TextEditingController _remarkController;
  bool _showSelectionError = false;

  @override
  void initState() {
    super.initState();
    _selectedFields = {...widget.initialDetails.inaccurateFields};
    _remarkController = TextEditingController(
      text: widget.initialDetails.remark,
    );
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableFields = availableMammalAccuracyFields(
      includeBatFields: widget.includeBatFields,
    );

    return AlertDialog(
      title: Text(context.l10n.specimenInaccurateMeasurements),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.specimenSelectEveryInaccurate),
              const SizedBox(height: 8),
              for (final field in availableFields)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(mammalAccuracyFieldLabels[field]!),
                  value: _selectedFields.contains(field),
                  onChanged: (selected) {
                    setState(() {
                      if (selected ?? false) {
                        _selectedFields.add(field);
                      } else {
                        _selectedFields.remove(field);
                      }
                      _showSelectionError = false;
                    });
                  },
                ),
              if (_showSelectionError)
                Text(
                  context.l10n.specimenSelectAtLeastOneInaccurate,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _remarkController,
                decoration: InputDecoration(
                  labelText: context.l10n.specimenAccuracyRemark,
                  hintText: context.l10n.specimenAccuracyRemarkHint,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(onPressed: _save, child: Text(context.l10n.commonSave)),
      ],
    );
  }

  void _save() {
    if (_selectedFields.isEmpty) {
      setState(() => _showSelectionError = true);
      return;
    }
    Navigator.pop(
      context,
      MammalAccuracyDetails(
        status: MammalAccuracyStatus.inaccurate,
        inaccurateFields: _selectedFields,
        remark: _remarkController.text.trim(),
      ),
    );
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
  final MammalAttributeCtrModel ctr;

  @override
  MaleGonadFormState createState() => MaleGonadFormState();
}

class MaleGonadFormState extends ConsumerState<MaleGonadForm> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.specimenSex?.supportsMaleAttributes == true,
      child: Column(
        children: [
          const CommonDivider(),
          FormCardSectionLabel(text: context.l10n.mammalTestes),
          Padding(
            padding: const EdgeInsets.all(4),
            child: DropdownButtonFormField<TestisPosition>(
              initialValue: getTestisPosition(widget.ctr.testisPosCtr),
              decoration: InputDecoration(
                labelText: context.l10n.mammalTestisPosition,
                hintText: context.l10n.mammalTestisPositionHint,
              ),
              items: testisPositionList
                  .map(
                    (e) => DropdownMenuItem(
                      value:
                          TestisPosition.values[testisPositionList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: (TestisPosition? newValue) {
                if (newValue != null) {
                  setState(() {
                    widget.ctr.testisPosCtr = newValue.index;
                  });
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    widget.specimenUuid,
                    MammalAttributeCompanion(
                      testisPosition: db.Value(newValue.index),
                    ),
                  );
                }
              },
            ),
          ),
          ScrotalMaleForm(
            specimenUuid: widget.specimenUuid,
            visible:
                getTestisPosition(widget.ctr.testisPosCtr) ==
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
  final MammalAttributeCtrModel ctr;

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
                labelText: context.l10n.specimenLengthMm,
                hintText: context.l10n.mammalTestisLengthHint,
                isLastField: false,
                isDouble: true,
                onChanged: (String? value) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    widget.specimenUuid,
                    MammalAttributeCompanion(
                      testisLength: db.Value(double.tryParse(value ?? '0')),
                    ),
                  );
                },
              ),
              CommonNumField(
                controller: widget.ctr.testisWidthCtr,
                labelText: context.l10n.specimenWidthMm,
                hintText: context.l10n.mammalTestisWidthHint,
                isLastField: true,
                isDouble: true,
                onChanged: (String? value) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    widget.specimenUuid,
                    MammalAttributeCompanion(
                      testisWidth: db.Value(double.tryParse(value ?? '0')),
                    ),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: DropdownButtonFormField<EpididymisAppearance>(
              initialValue: _getEpididymisAppearance(),
              decoration: InputDecoration(
                labelText: context.l10n.mammalEpididymis,
                hintText: context.l10n.mammalEpididymisHint,
              ),
              items: epididymisAppearanceList
                  .map(
                    (e) => DropdownMenuItem(
                      value: EpididymisAppearance
                          .values[epididymisAppearanceList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    widget.specimenUuid,
                    MammalAttributeCompanion(
                      epididymisAppearance: db.Value(value.index),
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
    required this.lifeStage,
    required this.useHorizontalLayout,
    required this.ctr,
  });

  final String specimenUuid;
  final SpecimenSex? specimenSex;
  final String? lifeStage;
  final bool useHorizontalLayout;
  final MammalAttributeCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(
      useHorizontalLayout: useHorizontalLayout,
      children: [
        Visibility(
          visible: specimenSex?.supportsFemaleAttributes == true,
          child: DropdownButtonFormField<VaginaOpening>(
            isExpanded: true,
            initialValue: _getVaginaOpening(),
            decoration: InputDecoration(
              labelText: context.l10n.mammalVaginaOpening,
              hintText: context.l10n.mammalVaginaOpeningHint,
            ),
            items: vaginaOpeningList
                .map(
                  (e) => DropdownMenuItem(
                    value: VaginaOpening.values[vaginaOpeningList.indexOf(e)],
                    child: CommonDropdownText(text: e),
                  ),
                )
                .toList(),
            onChanged: (VaginaOpening? newValue) {
              if (newValue != null) {
                SpecimenServices(ref: ref).updateMammalAttribute(
                  specimenUuid,
                  MammalAttributeCompanion(
                    vaginaOpening: db.Value(newValue.index),
                  ),
                );
              }
            },
          ),
        ),
        Visibility(
          visible:
              specimenSex?.supportsFemaleAttributes == true &&
              lifeStage?.toLowerCase() == 'adult',
          child: DropdownButtonFormField<PubicSymphysis>(
            initialValue: _getPubicSymphysis(),
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.l10n.mammalPubicSymphysis,
              hintText: context.l10n.mammalPubicSymphysisHint,
            ),
            items: pubicSymphysisList
                .map(
                  (e) => DropdownMenuItem(
                    value: PubicSymphysis.values[pubicSymphysisList.indexOf(e)],
                    child: CommonDropdownText(text: e),
                  ),
                )
                .toList(),
            onChanged: (PubicSymphysis? newValue) {
              if (newValue != null) {
                SpecimenServices(ref: ref).updateMammalAttribute(
                  specimenUuid,
                  MammalAttributeCompanion(
                    pubicSymphysis: db.Value(newValue.index),
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
    required this.lifeStage,
    required this.useHorizontalLayout,
    required this.ctr,
  });

  final String specimenUuid;
  final SpecimenSex? specimenSex;
  final String? lifeStage;
  final bool useHorizontalLayout;
  final MammalAttributeCtrModel ctr;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible:
          specimenSex?.supportsFemaleAttributes == true &&
          lifeStage?.toLowerCase() == 'adult',
      child: Column(
        children: [
          const CommonDivider(),
          FormCardSectionLabel(text: context.l10n.mammalFemaleReproductive),
          Padding(
            padding: const EdgeInsets.all(4),
            child: DropdownButtonFormField<ReproductiveStage>(
              initialValue: _getReproductiveStage(),
              decoration: InputDecoration(
                labelText: context.l10n.mammalReproductiveStage,
                hintText: context.l10n.mammalReproductiveStageHint,
              ),
              items: reproductiveStageList
                  .map(
                    (e) => DropdownMenuItem(
                      value: ReproductiveStage
                          .values[reproductiveStageList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: (ReproductiveStage? newValue) {
                if (newValue != null) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    specimenUuid,
                    MammalAttributeCompanion(
                      reproductiveStage: db.Value(newValue.index),
                    ),
                  );
                }
              },
            ),
          ),
          const CommonDivider(),
          FormCardSectionLabel(text: context.l10n.mammalMammaeCounts),
          MammaeForm(
            useHorizontalLayout: useHorizontalLayout,
            specimenUuid: specimenUuid,
            ctr: ctr,
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: DropdownButtonFormField<MammaeCondition>(
              initialValue: _getMammaeCondition(),
              decoration: InputDecoration(
                labelText: context.l10n.mammalMammaeCondition,
                hintText: context.l10n.mammalMammaeConditionHint,
              ),
              items: mammaeConditionList
                  .map(
                    (e) => DropdownMenuItem(
                      value: MammaeCondition
                          .values[mammaeConditionList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: (MammaeCondition? newValue) {
                if (newValue != null) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    specimenUuid,
                    MammalAttributeCompanion(
                      mammaeCondition: db.Value(newValue.index),
                    ),
                  );
                }
              },
            ),
          ),
          const CommonDivider(),
          FormCardSectionLabel(text: context.l10n.mammalEmbryo),
          EmbryoForm(
            useHorizontalLayout: useHorizontalLayout,
            specimenUuid: specimenUuid,
            ctr: ctr,
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: CommonNumField(
              controller: ctr.embryoCRCtr,
              labelText: context.l10n.mammalCrownRumpLength,
              hintText: context.l10n.mammalCrownRumpLengthHint,
              isLastField: true,
              onChanged: (String? value) {
                if (value != null) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    specimenUuid,
                    MammalAttributeCompanion(
                      embryoCR: db.Value(int.tryParse(value)),
                    ),
                  );
                }
              },
            ),
          ),
          const CommonDivider(),
          FormCardSectionLabel(text: context.l10n.mammalPlacentalScars),
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
  final MammalAttributeCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(
      useHorizontalLayout: useHorizontalLayout,
      children: [
        CommonNumField(
          controller: ctr.mammaeAxCtr,
          labelText: context.l10n.mammalAxillary,
          hintText: context.l10n.mammalAxillaryHint,
          isLastField: false,
          onChanged: (String? value) {
            if (value != null) {
              SpecimenServices(ref: ref).updateMammalAttribute(
                specimenUuid,
                MammalAttributeCompanion(
                  mammaeAxillaryCount: db.Value(int.tryParse(value)),
                ),
              );
            }
          },
        ),
        CommonNumField(
          controller: ctr.mammaeAbdCtr,
          labelText: context.l10n.mammalAbdominal,
          hintText: context.l10n.mammalAbdominalHint,
          isLastField: false,
          onChanged: (String? value) {
            if (value != null) {
              SpecimenServices(ref: ref).updateMammalAttribute(
                specimenUuid,
                MammalAttributeCompanion(
                  mammaeAbdominalCount: db.Value(int.tryParse(value)),
                ),
              );
            }
          },
        ),
        CommonNumField(
          controller: ctr.mammaeIngCtr,
          labelText: context.l10n.mammalInguinal,
          hintText: context.l10n.mammalInguinalHint,
          isLastField: false,
          onChanged: (String? value) {
            if (value != null) {
              SpecimenServices(ref: ref).updateMammalAttribute(
                specimenUuid,
                MammalAttributeCompanion(
                  mammaeInguinalCount: db.Value(int.tryParse(value)),
                ),
              );
            }
          },
        ),
      ],
    );
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
  final MammalAttributeCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(
      useHorizontalLayout: useHorizontalLayout,
      children: [
        CommonNumField(
          controller: ctr.embryoLeftCtr,
          labelText: context.l10n.specimenLeft,
          hintText: context.l10n.specimenLeft,
          isLastField: false,
          onChanged: (String? value) {
            if (value != null) {
              SpecimenServices(ref: ref).updateMammalAttribute(
                specimenUuid!,
                MammalAttributeCompanion(
                  embryoLeftCount: db.Value(int.tryParse(value)),
                ),
              );
            }
          },
        ),
        CommonNumField(
          controller: ctr.embryoRightCtr,
          labelText: context.l10n.specimenRight,
          hintText: context.l10n.specimenRight,
          isLastField: true,
          onChanged: (String? value) {
            if (value != null) {
              SpecimenServices(ref: ref).updateMammalAttribute(
                specimenUuid!,
                MammalAttributeCompanion(
                  embryoRightCount: db.Value(int.tryParse(value)),
                ),
              );
            }
          },
        ),
      ],
    );
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
  final MammalAttributeCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(
      useHorizontalLayout: useHorizontalLayout,
      children: [
        CommonNumField(
          controller: ctr.leftPlacentaCtr,
          labelText: context.l10n.specimenLeft,
          hintText: context.l10n.specimenLeft,
          isLastField: false,
          onChanged: (String? value) {
            if (value != null) {
              SpecimenServices(ref: ref).updateMammalAttribute(
                specimenUuid,
                MammalAttributeCompanion(
                  leftPlacentalScars: db.Value(int.tryParse(value)),
                ),
              );
            }
          },
        ),
        CommonNumField(
          controller: ctr.rightPlacentaCtr,
          labelText: context.l10n.specimenRight,
          hintText: context.l10n.specimenRight,
          isLastField: true,
          onChanged: (String? value) {
            if (value != null) {
              SpecimenServices(ref: ref).updateMammalAttribute(
                specimenUuid,
                MammalAttributeCompanion(
                  rightPlacentalScars: db.Value(int.tryParse(value)),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class BatForm extends ConsumerStatefulWidget {
  const BatForm({
    super.key,
    required this.useHorizontalLayout,
    required this.ctr,
    required this.specimenUuid,
    required this.inaccurateFields,
    required this.onBatDataEntered,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;
  final MammalAttributeCtrModel ctr;
  final Set<String> inaccurateFields;
  final VoidCallback onBatDataEntered;

  @override
  BatFormState createState() => BatFormState();
}

class BatFormState extends ConsumerState<BatForm> {
  bool _echolocate = false;
  bool _hasStoredEcholocationData = false;

  @override
  void initState() {
    super.initState();
    _hasStoredEcholocationData = _hasEcholocationData;
    _echolocate =
        (widget.ctr.showEchoFieldsCtr ?? false) || _hasStoredEcholocationData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: widget.ctr.forearmCtr,
              isBracketed:
                  widget.inaccurateFields.contains('forearm') &&
                  widget.ctr.forearmCtr.text.isNotEmpty,
              labelText: context.l10n.mammalForearmLength,
              hintText: context.l10n.mammalForearmLengthHint,
              isLastField: false,
              isDouble: true,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    widget.specimenUuid,
                    MammalAttributeCompanion(
                      forearm: db.Value(double.tryParse(value)),
                    ),
                  );
                  widget.onBatDataEntered();
                }
              },
            ),
            CommonNumField(
              controller: widget.ctr.tibiaCtr,
              isBracketed:
                  widget.inaccurateFields.contains('tibia') &&
                  widget.ctr.tibiaCtr.text.isNotEmpty,
              labelText: context.l10n.mammalTibiaLength,
              hintText: context.l10n.mammalTibiaLengthHint,
              isLastField: false,
              isDouble: true,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    widget.specimenUuid,
                    MammalAttributeCompanion(
                      tibia: db.Value(double.tryParse(value)),
                    ),
                  );
                  widget.onBatDataEntered();
                }
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            SwitchField(
              label: context.l10n.mammalEcholocate,
              value: _echolocate,
              disabled: _hasStoredEcholocationData,
              onPressed: (value) {
                setState(() {
                  _echolocate = value;
                });
                SpecimenServices(ref: ref).updateMammalAttribute(
                  widget.specimenUuid,
                  MammalAttributeCompanion(
                    showEchoFields: db.Value(value ? 1 : 0),
                  ),
                );
                if (value) widget.onBatDataEntered();
              },
            ),
          ],
        ),
        Visibility(
          visible: _echolocate,
          child: EcholocateForm(
            useHorizontalLayout: widget.useHorizontalLayout,
            ctr: widget.ctr,
            specimenUuid: widget.specimenUuid,
            onBatDataEntered: _markEcholocationDataStored,
          ),
        ),
      ],
    );
  }

  bool get _hasEcholocationData =>
      widget.ctr.echolocationCtr != null ||
      widget.ctr.frequencyMaxCtr.text.isNotEmpty ||
      widget.ctr.frequencyMinCtr.text.isNotEmpty ||
      widget.ctr.frequencyAtMaxEnergyCtr.text.isNotEmpty ||
      widget.ctr.durationCtr.text.isNotEmpty;

  void _markEcholocationDataStored() {
    if (!_hasStoredEcholocationData) {
      setState(() => _hasStoredEcholocationData = true);
    }
    widget.onBatDataEntered();
  }
}

class EcholocateForm extends ConsumerWidget {
  const EcholocateForm({
    super.key,
    required this.useHorizontalLayout,
    required this.ctr,
    required this.specimenUuid,
    required this.onBatDataEntered,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;
  final MammalAttributeCtrModel ctr;
  final VoidCallback onBatDataEntered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            DropdownButtonFormField<Echolocation>(
              initialValue: getEcholocation(ctr.echolocationCtr),
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.l10n.mammalEcholocation,
                hintText: context.l10n.mammalEcholocationHint,
              ),
              items: echolocationList
                  .map(
                    (e) => DropdownMenuItem(
                      value: Echolocation.values[echolocationList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: (Echolocation? newValue) {
                if (newValue != null) {
                  ctr.echolocationCtr = newValue.index;
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    specimenUuid,
                    MammalAttributeCompanion(
                      echolocation: db.Value(newValue.index),
                    ),
                  );
                  onBatDataEntered();
                }
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.frequencyMaxCtr,
              labelText: context.l10n.mammalFrequencyMax,
              hintText: context.l10n.mammalFrequencyMaxHint,
              isLastField: false,
              isDouble: true,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    specimenUuid,
                    MammalAttributeCompanion(
                      frequencyMax: db.Value(double.tryParse(value)),
                    ),
                  );
                  onBatDataEntered();
                }
              },
            ),
            CommonNumField(
              controller: ctr.frequencyMinCtr,
              labelText: context.l10n.mammalFrequencyMin,
              hintText: context.l10n.mammalFrequencyMinHint,
              isLastField: false,
              isDouble: true,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    specimenUuid,
                    MammalAttributeCompanion(
                      frequencyMin: db.Value(double.tryParse(value)),
                    ),
                  );
                  onBatDataEntered();
                }
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.frequencyAtMaxEnergyCtr,
              labelText: context.l10n.mammalFrequencyMaxEnergy,
              hintText: context.l10n.mammalFrequencyMaxEnergyHint,
              isLastField: false,
              isDouble: true,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    specimenUuid,
                    MammalAttributeCompanion(
                      frequencyAtMaxEnergy: db.Value(double.tryParse(value)),
                    ),
                  );
                  onBatDataEntered();
                }
              },
            ),
            CommonNumField(
              controller: ctr.durationCtr,
              labelText: context.l10n.mammalEcholocationDuration,
              hintText: context.l10n.mammalEcholocationDurationHint,
              isLastField: false,
              isDouble: true,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  SpecimenServices(ref: ref).updateMammalAttribute(
                    specimenUuid,
                    MammalAttributeCompanion(
                      duration: db.Value(double.tryParse(value)),
                    ),
                  );
                  onBatDataEntered();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
