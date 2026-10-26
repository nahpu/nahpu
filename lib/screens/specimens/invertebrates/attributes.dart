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
import 'package:nahpu/services/types/invertebrates.dart';
import 'package:nahpu/services/localization/l10n.dart';

typedef _InvertebrateCompanionBuilder =
    InvertebrateAttributeCompanion Function(double? value);

class InvertebrateAttributeForms extends ConsumerStatefulWidget {
  const InvertebrateAttributeForms({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;

  @override
  ConsumerState<InvertebrateAttributeForms> createState() =>
      _InvertebrateAttributeFormsState();
}

class _InvertebrateAttributeFormsState
    extends ConsumerState<InvertebrateAttributeForms> {
  InvertebrateAttributeCtrModel _ctr = InvertebrateAttributeCtrModel.empty();
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
  void didUpdateWidget(covariant InvertebrateAttributeForms oldWidget) {
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
                  InvertebrateAttributeCompanion(lifeStage: db.Value(value)),
                );
              },
            ),
            DropdownButtonFormField<int?>(
              initialValue: _ctr.casteCtr,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.l10n.invertCaste,
                hintText: context.l10n.invertCasteHint,
              ),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: CommonDropdownText(
                    text: context.l10n.parasiteNotAssigned,
                  ),
                ),
                ...invertebrateCasteList.indexed.map(
                  (entry) => DropdownMenuItem<int?>(
                    value: entry.$1,
                    child: CommonDropdownText(text: entry.$2),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _ctr.casteCtr = value);
                _updateAttribute(
                  InvertebrateAttributeCompanion(caste: db.Value(value)),
                );
              },
            ),
          ],
        ),
        FormCardSectionLabel(text: context.l10n.invertEcologicalInteractions),
        _EcologicalInteractionSection(
          ctr: _ctr,
          useHorizontalLayout: widget.useHorizontalLayout,
          onHostOrganismChanged: (value) => _updateAttribute(
            InvertebrateAttributeCompanion(
              hostOrganism: db.Value(_optionalText(value)),
            ),
          ),
          onHostPartChanged: (value) => _updateAttribute(
            InvertebrateAttributeCompanion(
              hostPart: db.Value(_optionalText(value)),
            ),
          ),
        ),
        const CommonDivider(),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            SwitchField(
              label: context.l10n.invertShowMorphometrics,
              value: _showMorphometrics,
              onPressed: (value) {
                setState(() => _showMorphometrics = value);
              },
            ),
          ],
        ),
        if (_showMorphometrics) ...[
          FormCardSectionLabel(text: context.l10n.invertMorphometrics),
          _MorphometricsSection(
            ctr: _ctr,
            useHorizontalLayout: widget.useHorizontalLayout,
            onHeadWidthChanged: (value) => _updateDouble(
              value,
              (parsed) =>
                  InvertebrateAttributeCompanion(headWidth: db.Value(parsed)),
            ),
            onBodyLengthChanged: (value) => _updateDouble(
              value,
              (parsed) =>
                  InvertebrateAttributeCompanion(bodyLength: db.Value(parsed)),
            ),
            onUpperWingspanChanged: (value) => _updateDouble(
              value,
              (parsed) => InvertebrateAttributeCompanion(
                wingspanUpper: db.Value(parsed),
              ),
            ),
            onLowerWingspanChanged: (value) => _updateDouble(
              value,
              (parsed) => InvertebrateAttributeCompanion(
                wingspanLower: db.Value(parsed),
              ),
            ),
          ),
        ],
        const CommonDivider(),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonTextField(
              controller: _ctr.remarkCtr,
              labelText: context.l10n.specimenRemarks,
              hintText: context.l10n.specimenRemarksHint,
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              isLastField: true,
              onChanged: (value) => _updateAttribute(
                InvertebrateAttributeCompanion(
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
    ).getInvertebrateAttributeData(widget.specimenUuid);
    final nextCtr = InvertebrateAttributeCtrModel.fromData(data);

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
    _updateAttribute(InvertebrateAttributeCompanion(sex: db.Value(code)));
  }

  void _updateDouble(String? value, _InvertebrateCompanionBuilder builder) {
    final parsed = double.tryParse(value ?? '');
    if (value?.isNotEmpty == true && parsed == null) return;
    _updateAttribute(builder(parsed));
  }

  void _updateAttribute(InvertebrateAttributeCompanion attribute) {
    SpecimenServices(
      ref: ref,
    ).updateInvertebrateAttribute(widget.specimenUuid, attribute);
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

  final InvertebrateAttributeCtrModel ctr;
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
              labelText: context.l10n.invertHostOrganism,
              hintText: context.l10n.invertHostOrganismHint,
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
              labelText: context.l10n.invertHostPart,
              hintText: context.l10n.invertHostPartHint,
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

  final InvertebrateAttributeCtrModel ctr;
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
              labelText: context.l10n.invertHeadWidth,
              hintText: context.l10n.invertHeadWidthHint,
              isDouble: true,
              isLastField: false,
              onChanged: onHeadWidthChanged,
            ),
            CommonNumField(
              controller: ctr.bodyLengthCtr,
              labelText: context.l10n.invertBodyLength,
              hintText: context.l10n.invertBodyLengthHint,
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
              labelText: context.l10n.invertUpperWingspan,
              hintText: context.l10n.invertUpperWingspanHint,
              isDouble: true,
              isLastField: false,
              onChanged: onUpperWingspanChanged,
            ),
            CommonNumField(
              controller: ctr.wingspanLowerCtr,
              labelText: context.l10n.invertLowerWingspan,
              hintText: context.l10n.invertLowerWingspanHint,
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
