import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/events.dart';
import 'package:nahpu/styles/design_tokens.dart';

const Map<String, String> oktaOptionLabels = {
  '0': '0 — Clear sky',
  '1': '1 — Up to 1/8 covered',
  '2': '2 — 2/8 covered',
  '3': '3 — 3/8 covered',
  '4': '4 — Half covered',
  '5': '5 — 5/8 covered',
  '6': '6 — 6/8 covered',
  '7': '7 — At least 7/8, not overcast',
  '8': '8 — Fully overcast',
  '9': '9 — Sky obscured',
};

class EnvironmentDataView extends ConsumerWidget {
  const EnvironmentDataView({
    super.key,
    required this.useHorizontalLayout,
    required this.eventID,
  });

  final bool useHorizontalLayout;
  final int eventID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const TitleForm(
          text: 'Environmental Data',
          infoTopic: InfoTopic.eventWeather,
        ),
        ref
            .watch(environmentDataProvider(eventID))
            .when(
              data: (environmentData) => EnvironmentDataForm(
                key: ValueKey(eventID),
                useHorizontalLayout: useHorizontalLayout,
                eventID: eventID,
                environmentData: environmentData,
                visibleFields: ref
                    .watch(
                      userDefinedFieldProvider(environmentalDataFieldsPrefKey),
                    )
                    .when(
                      data: (fields) => fields.toSet(),
                      loading: () => null,
                      error: (_, _) => null,
                    ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Center(
                child: Text('Unable to load environmental data: $error'),
              ),
            ),
      ],
    );
  }
}

class EnvironmentDataForm extends ConsumerStatefulWidget {
  const EnvironmentDataForm({
    super.key,
    required this.useHorizontalLayout,
    required this.eventID,
    required this.environmentData,
    this.visibleFields,
  });

  final bool useHorizontalLayout;
  final int eventID;
  final EditableEnvironmentData environmentData;
  final Set<String>? visibleFields;

  @override
  EnvironmentDataFormState createState() => EnvironmentDataFormState();
}

class EnvironmentDataFormState extends ConsumerState<EnvironmentDataForm> {
  /// Owned here rather than rebuilt from the record on every build: replacing
  /// the controllers mid-edit drops the caret, and the superseded set leaked.
  late final CollEnvironmentCtrModel _environmentCtr =
      CollEnvironmentCtrModel.fromEditableData(widget.environmentData);
  late final Map<String, String> _fieldErrors;
  late final Set<String> _temporarilyVisibleFields;
  final Map<String, int> _editVersions = {};

  Set<String> get _visibleFields => {
    ...?widget.visibleFields,
    if (widget.visibleFields == null) ...defaultVisibleEnvironmentalDataFields,
    ..._temporarilyVisibleFields,
  };

  bool _isVisible(String field) => _visibleFields.contains(field);

  bool _hasAny(Iterable<String> fields) => fields.any(_isVisible);

  int get _recoveryIssueCount =>
      _temporarilyVisibleFields.where(_fieldErrors.containsKey).length;

  @override
  void initState() {
    super.initState();
    _fieldErrors = Map.of(_environmentCtr.initialErrors);
    _temporarilyVisibleFields = _environmentCtr.initialErrors.keys.toSet();
  }

  @override
  void didUpdateWidget(covariant EnvironmentDataForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.environmentData == widget.environmentData) return;
    _environmentCtr.syncFrom(widget.environmentData);
  }

  @override
  void dispose() {
    _environmentCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_recoveryIssueCount > 0) _buildErrorSummary(context),
        if (_hasAny(const [
          'lowestDayTempC',
          'highestDayTempC',
          'lowestNightTempC',
          'highestNightTempC',
        ]))
          CommonPadding(
            child: Text(
              'Temperature (°C)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        if (_hasAny(const ['lowestDayTempC', 'highestDayTempC']))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              if (_isVisible('lowestDayTempC'))
                CommonNumField(
                  key: const ValueKey('environment-lowest-day-temperature'),
                  controller: _environmentCtr.lowestDayTempCtr,
                  labelText: 'Day Lowest',
                  hintText: 'Enter lowest temperature',
                  isDouble: true,
                  isSigned: true,
                  isLastField: false,
                  errorText: _fieldErrors['lowestDayTempC'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'lowestDayTempC',
                      value,
                      (parsed) => EnvironmentCompanion(
                        lowestDayTempC: db.Value(parsed),
                      ),
                    );
                  },
                ),
              if (_isVisible('highestDayTempC'))
                CommonNumField(
                  key: const ValueKey('environment-highest-day-temperature'),
                  controller: _environmentCtr.highestDayTempCtr,
                  labelText: 'Day Highest',
                  hintText: 'Enter highest temperature',
                  isDouble: true,
                  isSigned: true,
                  isLastField: false,
                  errorText: _fieldErrors['highestDayTempC'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'highestDayTempC',
                      value,
                      (parsed) => EnvironmentCompanion(
                        highestDayTempC: db.Value(parsed),
                      ),
                    );
                  },
                ),
            ],
          ),
        if (_hasAny(const ['lowestNightTempC', 'highestNightTempC']))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              if (_isVisible('lowestNightTempC'))
                CommonNumField(
                  key: const ValueKey('environment-lowest-night-temperature'),
                  controller: _environmentCtr.lowestNightTempCtr,
                  labelText: 'Night Lowest',
                  hintText: 'Enter lowest temperature',
                  isDouble: true,
                  isSigned: true,
                  isLastField: false,
                  errorText: _fieldErrors['lowestNightTempC'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'lowestNightTempC',
                      value,
                      (parsed) => EnvironmentCompanion(
                        lowestNightTempC: db.Value(parsed),
                      ),
                    );
                  },
                ),
              if (_isVisible('highestNightTempC'))
                CommonNumField(
                  key: const ValueKey('environment-highest-night-temperature'),
                  controller: _environmentCtr.highestNightTempCtr,
                  labelText: 'Night Highest',
                  hintText: 'Enter highest temperature',
                  isDouble: true,
                  isSigned: true,
                  isLastField: false,
                  errorText: _fieldErrors['highestNightTempC'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'highestNightTempC',
                      value,
                      (parsed) => EnvironmentCompanion(
                        highestNightTempC: db.Value(parsed),
                      ),
                    );
                  },
                ),
            ],
          ),
        if (_hasAny(const ['averageHumidity', 'dewPointTemp']))
          const SizedBox(height: 8),
        if (_hasAny(const ['averageHumidity', 'dewPointTemp']))
          CommonPadding(
            child: Text(
              'Humidity (%)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        if (_hasAny(const ['averageHumidity', 'dewPointTemp']))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              if (_isVisible('averageHumidity'))
                CommonNumField(
                  controller: _environmentCtr.averageHumidityCtr,
                  key: const ValueKey('environment-average-humidity'),
                  labelText: 'Average',
                  hintText: 'Enter average humidity',
                  isDouble: true,
                  isLastField: false,
                  errorText: _fieldErrors['averageHumidity'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'averageHumidity',
                      value,
                      (parsed) => EnvironmentCompanion(
                        averageHumidity: db.Value(parsed),
                      ),
                      minimum: 0,
                      maximum: 100,
                    );
                  },
                ),
              if (_isVisible('dewPointTemp'))
                CommonNumField(
                  key: const ValueKey('environment-dew-point-temperature'),
                  controller: _environmentCtr.dewPointCtr,
                  labelText: 'Dew Point',
                  hintText: 'Enter dew point',
                  isDouble: true,
                  isSigned: true,
                  isLastField: false,
                  errorText: _fieldErrors['dewPointTemp'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'dewPointTemp',
                      value,
                      (parsed) =>
                          EnvironmentCompanion(dewPointTemp: db.Value(parsed)),
                    );
                  },
                ),
            ],
          ),
        if (_hasAny(const ['cloudCover', 'rainfallInMm']))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              if (_isVisible('cloudCover'))
                DropdownButtonFormField<String?>(
                  key: const ValueKey('environment-cloud-cover'),
                  initialValue: _environmentCtr.cloudCoverCtr,
                  decoration: InputDecoration(
                    labelText: 'Cloud cover (oktas)',
                    hintText: 'Select cloud cover',
                    errorText: _fieldErrors['cloudCover'],
                    errorMaxLines: 3,
                    helperText:
                        'One okta represents one eighth of the visible sky.',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: CommonDropdownText(text: 'Not recorded'),
                    ),
                    if (_environmentCtr.cloudCoverCtr case final value?
                        when !oktaOptionLabels.containsKey(value))
                      DropdownMenuItem<String?>(
                        value: value,
                        child: CommonDropdownText(
                          text: '$value — Invalid stored value',
                        ),
                      ),
                    for (final option in oktaOptionLabels.entries)
                      DropdownMenuItem<String?>(
                        value: option.key,
                        child: CommonDropdownText(text: option.value),
                      ),
                  ],
                  onChanged: (value) async {
                    final version = _beginEdit('cloudCover');
                    setState(() => _environmentCtr.cloudCoverCtr = value);
                    await _saveField(
                      'cloudCover',
                      EnvironmentCompanion(cloudCover: db.Value(value)),
                      version,
                    );
                  },
                ),
              if (_isVisible('rainfallInMm'))
                CommonNumField(
                  key: const ValueKey('environment-rainfall'),
                  controller: _environmentCtr.rainfallInMmCtr,
                  labelText: 'Rainfall (mm)',
                  hintText: 'Enter rainfall',
                  isDouble: true,
                  isLastField: false,
                  errorText: _fieldErrors['rainfallInMm'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'rainfallInMm',
                      value,
                      (parsed) =>
                          EnvironmentCompanion(rainfallInMm: db.Value(parsed)),
                    );
                  },
                ),
            ],
          ),
        if (_hasAny(const ['ambientTemperature', 'ambientHumidity']))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              if (_isVisible('ambientTemperature'))
                CommonNumField(
                  key: const ValueKey('environment-ambient-temperature'),
                  controller: _environmentCtr.ambientTemperatureCtr,
                  labelText: 'Ambient temperature (°C)',
                  hintText: 'Enter ambient temperature',
                  isDouble: true,
                  isSigned: true,
                  isLastField: false,
                  errorText: _fieldErrors['ambientTemperature'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'ambientTemperature',
                      value,
                      (parsed) => EnvironmentCompanion(
                        ambientTemperature: db.Value(parsed),
                      ),
                    );
                  },
                ),
              if (_isVisible('ambientHumidity'))
                CommonNumField(
                  controller: _environmentCtr.ambientHumidityCtr,
                  key: const ValueKey('environment-ambient-humidity'),
                  labelText: 'Ambient humidity (%)',
                  hintText: 'Enter relative humidity',
                  isDouble: true,
                  isLastField: false,
                  errorText: _fieldErrors['ambientHumidity'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'ambientHumidity',
                      value,
                      (parsed) => EnvironmentCompanion(
                        ambientHumidity: db.Value(parsed),
                      ),
                      minimum: 0,
                      maximum: 100,
                    );
                  },
                ),
            ],
          ),
        if (_hasAny(const [
          'waterTemperature',
          'pH',
          'dissolvedOxygen',
          'flowVelocity',
        ]))
          const SizedBox(height: 8),
        if (_hasAny(const [
          'waterTemperature',
          'pH',
          'dissolvedOxygen',
          'flowVelocity',
        ]))
          CommonPadding(
            child: Text(
              'Aquatic Data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        if (_hasAny(const ['waterTemperature', 'pH']))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              if (_isVisible('waterTemperature'))
                CommonNumField(
                  key: const ValueKey('environment-water-temperature'),
                  controller: _environmentCtr.waterTemperatureCtr,
                  labelText: 'Water temperature (°C)',
                  hintText: 'Enter water temperature',
                  isDouble: true,
                  isSigned: true,
                  isLastField: false,
                  errorText: _fieldErrors['waterTemperature'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'waterTemperature',
                      value,
                      (parsed) => EnvironmentCompanion(
                        waterTemperature: db.Value(parsed),
                      ),
                    );
                  },
                ),
              if (_isVisible('pH'))
                CommonNumField(
                  controller: _environmentCtr.pHCtr,
                  key: const ValueKey('environment-ph'),
                  labelText: 'pH',
                  hintText: 'Enter pH',
                  isDouble: true,
                  isLastField: false,
                  errorText: _fieldErrors['pH'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'pH',
                      value,
                      (parsed) => EnvironmentCompanion(pH: db.Value(parsed)),
                      minimum: 0,
                      maximum: 14,
                    );
                  },
                ),
            ],
          ),
        if (_hasAny(const ['dissolvedOxygen', 'flowVelocity']))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              if (_isVisible('dissolvedOxygen'))
                CommonNumField(
                  key: const ValueKey('environment-dissolved-oxygen'),
                  controller: _environmentCtr.dissolvedOxygenCtr,
                  labelText: 'Dissolved oxygen (mg/L)',
                  hintText: 'Enter dissolved oxygen',
                  isDouble: true,
                  isLastField: false,
                  errorText: _fieldErrors['dissolvedOxygen'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'dissolvedOxygen',
                      value,
                      (parsed) => EnvironmentCompanion(
                        dissolvedOxygen: db.Value(parsed),
                      ),
                    );
                  },
                ),
              if (_isVisible('flowVelocity'))
                CommonNumField(
                  key: const ValueKey('environment-flow-velocity'),
                  controller: _environmentCtr.flowVelocityCtr,
                  labelText: 'Flow velocity (m/s)',
                  hintText: 'Enter flow velocity',
                  isDouble: true,
                  isLastField: false,
                  errorText: _fieldErrors['flowVelocity'],
                  onChanged: (value) async {
                    await _updateNumber(
                      'flowVelocity',
                      value,
                      (parsed) =>
                          EnvironmentCompanion(flowVelocity: db.Value(parsed)),
                    );
                  },
                ),
            ],
          ),
        if (_hasAny(const ['sunriseTime', 'sunsetTime', 'moonPhase']))
          const SizedBox(height: 8),
        if (_hasAny(const ['sunriseTime', 'sunsetTime', 'moonPhase']))
          CommonPadding(
            child: Text(
              'Astronomy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        if (_hasAny(const ['sunriseTime', 'sunsetTime']))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              if (_isVisible('sunriseTime'))
                TextField(
                  key: const ValueKey('environment-sunrise-time'),
                  controller: _environmentCtr.sunriseTimeCtr,
                  decoration: InputDecoration(
                    labelText: 'Sunrise',
                    hintText: 'Enter sunrise time',
                    errorText: _fieldErrors['sunriseTime'],
                    errorMaxLines: 3,
                  ),
                  onChanged: (value) async {
                    await _updateText(
                      'sunriseTime',
                      value,
                      (text) =>
                          EnvironmentCompanion(sunriseTime: db.Value(text)),
                    );
                  },
                  onTap: () async {
                    final value = await _showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (value != null && mounted) {
                      final formattedTime = _formatTimeOfDay(value);
                      final version = _beginEdit('sunriseTime');
                      _environmentCtr.sunriseTimeCtr.text = formattedTime;
                      await _saveField(
                        'sunriseTime',
                        EnvironmentCompanion(
                          sunriseTime: db.Value(formattedTime),
                        ),
                        version,
                      );
                    }
                  },
                ),
              if (_isVisible('sunsetTime'))
                TextField(
                  key: const ValueKey('environment-sunset-time'),
                  controller: _environmentCtr.sunsetTimeCtr,
                  decoration: InputDecoration(
                    labelText: 'Sunset',
                    hintText: 'Enter sunset time',
                    errorText: _fieldErrors['sunsetTime'],
                    errorMaxLines: 3,
                  ),
                  onChanged: (value) async {
                    await _updateText(
                      'sunsetTime',
                      value,
                      (text) =>
                          EnvironmentCompanion(sunsetTime: db.Value(text)),
                    );
                  },
                  onTap: () async {
                    final value = await _showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (value != null && mounted) {
                      final formattedTime = _formatTimeOfDay(value);
                      final version = _beginEdit('sunsetTime');
                      _environmentCtr.sunsetTimeCtr.text = formattedTime;
                      await _saveField(
                        'sunsetTime',
                        EnvironmentCompanion(
                          sunsetTime: db.Value(formattedTime),
                        ),
                        version,
                      );
                    }
                  },
                ),
            ],
          ),
        if (_isVisible('moonPhase'))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              DropdownButtonFormField<String?>(
                key: const ValueKey('environment-moon-phase'),
                initialValue: _environmentCtr.moonPhaseCtr,
                decoration: InputDecoration(
                  labelText: 'Moon Phase',
                  hintText: 'Select moon phase',
                  errorText: _fieldErrors['moonPhase'],
                  errorMaxLines: 3,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: CommonDropdownText(text: 'Not recorded'),
                  ),
                  if (_environmentCtr.moonPhaseCtr case final value?
                      when !environmentMoonPhaseOptions.contains(value))
                    DropdownMenuItem<String?>(
                      value: value,
                      child: CommonDropdownText(
                        text: '$value — Invalid stored value',
                      ),
                    ),
                  for (final phase in environmentMoonPhaseOptions)
                    DropdownMenuItem<String?>(
                      value: phase,
                      child: CommonDropdownText(text: phase),
                    ),
                ],
                onChanged: (value) async {
                  final version = _beginEdit('moonPhase');
                  setState(() => _environmentCtr.moonPhaseCtr = value);
                  await _saveField(
                    'moonPhase',
                    EnvironmentCompanion(moonPhase: db.Value(value)),
                    version,
                  );
                },
              ),
            ],
          ),
        if (_isVisible('notes'))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              CommonTextField(
                key: const ValueKey('environment-notes'),
                controller: _environmentCtr.noteCtr,
                labelText: 'Notes',
                hintText: 'Enter notes',
                maxLines: 3,
                isLastField: true,
                errorText: _fieldErrors['notes'],
                onChanged: (value) async {
                  await _updateText(
                    'notes',
                    value,
                    (text) => EnvironmentCompanion(notes: db.Value(text)),
                  );
                },
              ),
            ],
          ),
        CommonPadding(
          child: CustomFieldForm(
            owner: CustomFieldOwner.environment(widget.eventID),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Future<TimeOfDay?> _showTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
  }) async {
    return await showTimePicker(context: context, initialTime: initialTime);
  }

  Widget _buildErrorSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CommonPadding(
      child: Container(
        key: const ValueKey('environment-error-summary'),
        margin: const EdgeInsets.only(bottom: NahpuSpacing.md),
        padding: const EdgeInsets.all(NahpuSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(NahpuRadius.sm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: NahpuSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Some stored environmental values need attention '
                    '($_recoveryIssueCount)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: NahpuSpacing.xs),
                  Text(
                    'Correct or clear the highlighted fields. Other values '
                    'will not be changed.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _beginEdit(String field) {
    final version = (_editVersions[field] ?? 0) + 1;
    _editVersions[field] = version;
    return version;
  }

  Future<void> _saveField(
    String field,
    EnvironmentCompanion environmentData,
    int version,
  ) async {
    try {
      await CollEventServices(
        ref: ref,
      ).updateEnvironmentData(widget.eventID, environmentData);
      if (!mounted || _editVersions[field] != version) return;
      setState(() => _fieldErrors.remove(field));
    } catch (error) {
      if (!mounted || _editVersions[field] != version) return;
      setState(() {
        _fieldErrors[field] = 'Could not save this value: $error';
      });
    }
  }

  Future<void> _updateNumber(
    String field,
    String? value,
    EnvironmentCompanion Function(double? value) companion, {
    num? minimum,
    num? maximum,
  }) async {
    final version = _beginEdit(field);
    final text = value?.trim() ?? '';
    final parsed = text.isEmpty ? null : double.tryParse(text);
    String? error;
    if (text.isNotEmpty && (parsed == null || !parsed.isFinite)) {
      error = 'Enter a valid number.';
    } else if (parsed != null &&
        minimum != null &&
        maximum != null &&
        (parsed < minimum || parsed > maximum)) {
      error = 'Enter a value from $minimum to $maximum';
    }
    if (error != null) {
      if (mounted) setState(() => _fieldErrors[field] = error!);
      return;
    }
    await _saveField(field, companion(parsed), version);
  }

  Future<void> _updateText(
    String field,
    String? value,
    EnvironmentCompanion Function(String? value) companion,
  ) async {
    final version = _beginEdit(field);
    final text = value ?? '';
    await _saveField(field, companion(text.isEmpty ? null : text), version);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return time.format(context);
  }
}
