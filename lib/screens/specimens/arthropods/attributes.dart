import 'package:drift/drift.dart' as db;
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/types/arthropods.dart';

typedef _ArthropodCompanionBuilder =
    ArthropodAttributeCompanion Function(double? value);

class ArthropodAttributeForms extends ConsumerStatefulWidget {
  const ArthropodAttributeForms({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;

  @override
  ConsumerState<ArthropodAttributeForms> createState() =>
      _ArthropodAttributeFormsState();
}

class _ArthropodAttributeFormsState
    extends ConsumerState<ArthropodAttributeForms> {
  ArthropodAttributeCtrModel _ctr = ArthropodAttributeCtrModel.empty();
  Key _sexDropdownKey = UniqueKey();
  bool _showMorphometrics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttributes();
    });
  }

  @override
  void didUpdateWidget(covariant ArthropodAttributeForms oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.specimenUuid != widget.specimenUuid) {
      _loadAttributes();
    }
  }

  @override
  void dispose() {
    _ctr.dispose();
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
              currentCode: _ctr.sexCtr,
              onChanged: _updateSex,
            ),
            LifeStageDropdown(
              currentValue: _ctr.lifeStageCtr,
              onChanged: (value) {
                setState(() => _ctr.lifeStageCtr = value);
                _updateAttribute(
                  ArthropodAttributeCompanion(lifeStage: db.Value(value)),
                );
              },
            ),
            DropdownButtonFormField<int?>(
              initialValue: _ctr.casteCtr,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Caste',
                hintText: 'Select caste',
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: CommonDropdownText(text: 'Not assigned'),
                ),
                ...arthropodCasteList.indexed.map(
                  (entry) => DropdownMenuItem<int?>(
                    value: entry.$1,
                    child: CommonDropdownText(text: entry.$2),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _ctr.casteCtr = value);
                _updateAttribute(
                  ArthropodAttributeCompanion(caste: db.Value(value)),
                );
              },
            ),
          ],
        ),
        const FormCardSectionLabel(text: 'Ecological interactions'),
        _EcologicalInteractionSection(
          ctr: _ctr,
          useHorizontalLayout: widget.useHorizontalLayout,
          onHostOrganismChanged: (value) => _updateAttribute(
            ArthropodAttributeCompanion(
              hostOrganism: db.Value(_optionalText(value)),
            ),
          ),
          onHostPartChanged: (value) => _updateAttribute(
            ArthropodAttributeCompanion(
              hostPart: db.Value(_optionalText(value)),
            ),
          ),
        ),
        const CommonDivider(),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            SwitchField(
              label: 'Show specimen morphometrics',
              value: _showMorphometrics,
              onPressed: (value) {
                setState(() => _showMorphometrics = value);
              },
            ),
          ],
        ),
        if (_showMorphometrics) ...[
          const FormCardSectionLabel(text: 'Specimen morphometrics'),
          _MorphometricsSection(
            ctr: _ctr,
            useHorizontalLayout: widget.useHorizontalLayout,
            onHeadWidthChanged: (value) => _updateDouble(
              value,
              (parsed) =>
                  ArthropodAttributeCompanion(headWidth: db.Value(parsed)),
            ),
            onBodyLengthChanged: (value) => _updateDouble(
              value,
              (parsed) =>
                  ArthropodAttributeCompanion(bodyLength: db.Value(parsed)),
            ),
            onUpperWingspanChanged: (value) => _updateDouble(
              value,
              (parsed) =>
                  ArthropodAttributeCompanion(wingspanUpper: db.Value(parsed)),
            ),
            onLowerWingspanChanged: (value) => _updateDouble(
              value,
              (parsed) =>
                  ArthropodAttributeCompanion(wingspanLower: db.Value(parsed)),
            ),
          ),
        ],
        const CommonDivider(),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonTextField(
              controller: _ctr.remarkCtr,
              labelText: 'Remarks',
              hintText: 'Add additional information about the specimen',
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              isLastField: true,
              onChanged: (value) => _updateAttribute(
                ArthropodAttributeCompanion(
                  remark: db.Value(_optionalText(value)),
                ),
              ),
            ),
          ],
        ),
        CustomFieldForm(owner: CustomFieldOwner.specimen(widget.specimenUuid)),
      ],
    );
  }

  Future<void> _loadAttributes() async {
    final data = await SpecimenServices(
      ref: ref,
    ).getArthropodAttributeData(widget.specimenUuid);
    final nextCtr = ArthropodAttributeCtrModel.fromData(data);

    if (!mounted) {
      nextCtr.dispose();
      return;
    }

    final previousCtr = _ctr;
    setState(() {
      _ctr = nextCtr;
      _showMorphometrics = nextCtr.hasMorphometricData;
      _sexDropdownKey = UniqueKey();
    });
    previousCtr.dispose();
  }

  void _updateSex(SpecimenSex? value) {
    final code = value == null ? null : getSpecimenSexCode(value);
    setState(() => _ctr.sexCtr = code);
    _updateAttribute(ArthropodAttributeCompanion(sex: db.Value(code)));
  }

  void _updateDouble(String? value, _ArthropodCompanionBuilder builder) {
    final parsed = double.tryParse(value ?? '');
    if (value?.isNotEmpty == true && parsed == null) return;
    _updateAttribute(builder(parsed));
  }

  void _updateAttribute(ArthropodAttributeCompanion attribute) {
    SpecimenServices(
      ref: ref,
    ).updateArthropodAttribute(widget.specimenUuid, attribute);
  }

  String? _optionalText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class _EcologicalInteractionSection extends StatelessWidget {
  const _EcologicalInteractionSection({
    required this.ctr,
    required this.useHorizontalLayout,
    required this.onHostOrganismChanged,
    required this.onHostPartChanged,
  });

  final ArthropodAttributeCtrModel ctr;
  final bool useHorizontalLayout;
  final ValueChanged<String?> onHostOrganismChanged;
  final ValueChanged<String?> onHostPartChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonTextField(
              controller: ctr.hostOrganismCtr,
              labelText: 'Host organism',
              hintText: 'Enter the associated host taxon',
              isLastField: false,
              onChanged: onHostOrganismChanged,
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonTextField(
              controller: ctr.hostPartCtr,
              labelText: 'Host part',
              hintText: 'Enter the occupied host part',
              isLastField: false,
              onChanged: onHostPartChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class _MorphometricsSection extends StatelessWidget {
  const _MorphometricsSection({
    required this.ctr,
    required this.useHorizontalLayout,
    required this.onHeadWidthChanged,
    required this.onBodyLengthChanged,
    required this.onUpperWingspanChanged,
    required this.onLowerWingspanChanged,
  });

  final ArthropodAttributeCtrModel ctr;
  final bool useHorizontalLayout;
  final ValueChanged<String?> onHeadWidthChanged;
  final ValueChanged<String?> onBodyLengthChanged;
  final ValueChanged<String?> onUpperWingspanChanged;
  final ValueChanged<String?> onLowerWingspanChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.headWidthCtr,
              labelText: 'Head width (mm)',
              hintText: 'Enter head width',
              isDouble: true,
              isLastField: false,
              onChanged: onHeadWidthChanged,
            ),
            CommonNumField(
              controller: ctr.bodyLengthCtr,
              labelText: 'Body length (mm)',
              hintText: 'Enter body length',
              isDouble: true,
              isLastField: false,
              onChanged: onBodyLengthChanged,
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.wingspanUpperCtr,
              labelText: 'Upper wingspan (mm)',
              hintText: 'Enter upper wingspan',
              isDouble: true,
              isLastField: false,
              onChanged: onUpperWingspanChanged,
            ),
            CommonNumField(
              controller: ctr.wingspanLowerCtr,
              labelText: 'Lower wingspan (mm)',
              hintText: 'Enter lower wingspan',
              isDouble: true,
              isLastField: false,
              onChanged: onLowerWingspanChanged,
            ),
          ],
        ),
      ],
    );
  }
}
