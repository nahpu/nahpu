import 'package:drift/drift.dart' as db;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';

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
  String? _ambientHumidityError;
  String? _pHError;

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
        const _ArthropodSectionTitle(text: 'Ecological interactions'),
        _EcologicalInteractionSection(
          ctr: _ctr,
          sexDropdownKey: _sexDropdownKey,
          useHorizontalLayout: widget.useHorizontalLayout,
          onSexChanged: _updateSex,
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
          onCanopyAffinityChanged: (value) => _updateAttribute(
            ArthropodAttributeCompanion(
              canopyAffinity: db.Value(_optionalText(value)),
            ),
          ),
        ),
        const CommonDivider(),
        const _ArthropodSectionTitle(text: 'Environmental parameters'),
        _EnvironmentalParameterSection(
          ctr: _ctr,
          useHorizontalLayout: widget.useHorizontalLayout,
          ambientHumidityError: _ambientHumidityError,
          pHError: _pHError,
          onCanopyCoverChanged: (value) => _updateAttribute(
            ArthropodAttributeCompanion(
              canopyCover: db.Value(_optionalText(value)),
            ),
          ),
          onAmbientTemperatureChanged: (value) => _updateDouble(
            value,
            (parsed) => ArthropodAttributeCompanion(
              ambientTemperature: db.Value(parsed),
            ),
          ),
          onAmbientHumidityChanged: _updateAmbientHumidity,
          onWaterTemperatureChanged: (value) => _updateDouble(
            value,
            (parsed) =>
                ArthropodAttributeCompanion(waterTemperature: db.Value(parsed)),
          ),
          onPHChanged: _updatePH,
          onDissolvedOxygenChanged: (value) => _updateDouble(
            value,
            (parsed) =>
                ArthropodAttributeCompanion(dissolvedOxygen: db.Value(parsed)),
          ),
          onFlowVelocityChanged: (value) => _updateDouble(
            value,
            (parsed) =>
                ArthropodAttributeCompanion(flowVelocity: db.Value(parsed)),
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
          const _ArthropodSectionTitle(text: 'Specimen morphometrics'),
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
      _ambientHumidityError = null;
      _pHError = null;
    });
    previousCtr.dispose();
  }

  void _updateSex(SpecimenSex? value) {
    setState(() => _ctr.sexCtr = value?.index);
    _updateAttribute(ArthropodAttributeCompanion(sex: db.Value(value?.index)));
  }

  void _updateDouble(String? value, _ArthropodCompanionBuilder builder) {
    final parsed = double.tryParse(value ?? '');
    if (value?.isNotEmpty == true && parsed == null) return;
    _updateAttribute(builder(parsed));
  }

  void _updateAmbientHumidity(String? value) {
    final hasValue = value?.trim().isNotEmpty == true;
    final parsed = double.tryParse(value ?? '');
    final isValid =
        !hasValue || (parsed != null && parsed >= 0 && parsed <= 100);
    setState(() {
      _ambientHumidityError = isValid ? null : 'Enter a value from 0 to 100';
    });
    if (isValid) {
      _updateAttribute(
        ArthropodAttributeCompanion(ambientHumidity: db.Value(parsed)),
      );
    }
  }

  void _updatePH(String? value) {
    final hasValue = value?.trim().isNotEmpty == true;
    final parsed = double.tryParse(value ?? '');
    final isValid =
        !hasValue || (parsed != null && parsed >= 0 && parsed <= 14);
    setState(() {
      _pHError = isValid ? null : 'Enter a value from 0 to 14';
    });
    if (isValid) {
      _updateAttribute(ArthropodAttributeCompanion(pH: db.Value(parsed)));
    }
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

class _ArthropodSectionTitle extends StatelessWidget {
  const _ArthropodSectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _EcologicalInteractionSection extends StatelessWidget {
  const _EcologicalInteractionSection({
    required this.ctr,
    required this.sexDropdownKey,
    required this.useHorizontalLayout,
    required this.onSexChanged,
    required this.onHostOrganismChanged,
    required this.onHostPartChanged,
    required this.onCanopyAffinityChanged,
  });

  final ArthropodAttributeCtrModel ctr;
  final Key sexDropdownKey;
  final bool useHorizontalLayout;
  final ValueChanged<SpecimenSex?> onSexChanged;
  final ValueChanged<String?> onHostOrganismChanged;
  final ValueChanged<String?> onHostPartChanged;
  final ValueChanged<String?> onCanopyAffinityChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            DropdownButtonFormField<SpecimenSex>(
              key: sexDropdownKey,
              initialValue: getSpecimenSex(ctr.sexCtr),
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Sex',
                hintText: 'Select specimen sex',
              ),
              items: SpecimenSex.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: CommonDropdownText(
                        text: specimenSexList[value.index],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onSexChanged,
            ),
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
            CommonTextField(
              controller: ctr.canopyAffinityCtr,
              labelText: 'Canopy affinity',
              hintText: 'Enter canopy association',
              isLastField: false,
              onChanged: onCanopyAffinityChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class _EnvironmentalParameterSection extends StatelessWidget {
  const _EnvironmentalParameterSection({
    required this.ctr,
    required this.useHorizontalLayout,
    required this.ambientHumidityError,
    required this.pHError,
    required this.onCanopyCoverChanged,
    required this.onAmbientTemperatureChanged,
    required this.onAmbientHumidityChanged,
    required this.onWaterTemperatureChanged,
    required this.onPHChanged,
    required this.onDissolvedOxygenChanged,
    required this.onFlowVelocityChanged,
  });

  final ArthropodAttributeCtrModel ctr;
  final bool useHorizontalLayout;
  final String? ambientHumidityError;
  final String? pHError;
  final ValueChanged<String?> onCanopyCoverChanged;
  final ValueChanged<String?> onAmbientTemperatureChanged;
  final ValueChanged<String?> onAmbientHumidityChanged;
  final ValueChanged<String?> onWaterTemperatureChanged;
  final ValueChanged<String?> onPHChanged;
  final ValueChanged<String?> onDissolvedOxygenChanged;
  final ValueChanged<String?> onFlowVelocityChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonTextField(
              controller: ctr.canopyCoverCtr,
              labelText: 'Canopy cover',
              hintText: 'Enter canopy cover',
              isLastField: false,
              onChanged: onCanopyCoverChanged,
            ),
            CommonNumField(
              controller: ctr.ambientTemperatureCtr,
              labelText: 'Ambient temperature (°C)',
              hintText: 'Enter ambient temperature',
              isDouble: true,
              isSigned: true,
              isLastField: false,
              onChanged: onAmbientTemperatureChanged,
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.ambientHumidityCtr,
              labelText: 'Ambient humidity (%)',
              hintText: 'Enter relative humidity',
              isDouble: true,
              isLastField: false,
              errorText: ambientHumidityError,
              onChanged: onAmbientHumidityChanged,
            ),
            CommonNumField(
              controller: ctr.waterTemperatureCtr,
              labelText: 'Water temperature (°C)',
              hintText: 'Enter water temperature',
              isDouble: true,
              isSigned: true,
              isLastField: false,
              onChanged: onWaterTemperatureChanged,
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.pHCtr,
              labelText: 'pH',
              hintText: 'Enter pH',
              isDouble: true,
              isLastField: false,
              errorText: pHError,
              onChanged: onPHChanged,
            ),
            CommonNumField(
              controller: ctr.dissolvedOxygenCtr,
              labelText: 'Dissolved oxygen (mg/L)',
              hintText: 'Enter dissolved oxygen',
              isDouble: true,
              isLastField: false,
              onChanged: onDissolvedOxygenChanged,
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.flowVelocityCtr,
              labelText: 'Flow velocity (m/s)',
              hintText: 'Enter flow velocity',
              isDouble: true,
              isLastField: false,
              onChanged: onFlowVelocityChanged,
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
