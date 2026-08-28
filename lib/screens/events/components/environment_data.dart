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
                useHorizontalLayout: useHorizontalLayout,
                eventID: eventID,
                environmentCtr: _getEnvironmentData(environmentData),
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
              error: (error, stack) => const Center(child: Text('Error')),
            ),
      ],
    );
  }

  CollEnvironmentCtrModel _getEnvironmentData(EnvironmentData environmentData) {
    return CollEnvironmentCtrModel.fromData(environmentData);
  }
}

class EnvironmentDataForm extends ConsumerStatefulWidget {
  const EnvironmentDataForm({
    super.key,
    required this.useHorizontalLayout,
    required this.eventID,
    required this.environmentCtr,
    this.visibleFields,
  });

  final bool useHorizontalLayout;
  final int eventID;
  final CollEnvironmentCtrModel environmentCtr;
  final Set<String>? visibleFields;

  @override
  EnvironmentDataFormState createState() => EnvironmentDataFormState();
}

class EnvironmentDataFormState extends ConsumerState<EnvironmentDataForm> {
  String? _averageHumidityError;
  String? _ambientHumidityError;
  String? _pHError;

  Set<String> get _visibleFields =>
      widget.visibleFields ?? defaultVisibleEnvironmentalDataFields.toSet();

  bool _isVisible(String field) => _visibleFields.contains(field);

  bool _hasAny(Iterable<String> fields) => fields.any(_isVisible);

  @override
  void dispose() {
    widget.environmentCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> moonPhase = [
      'New Moon',
      'Waxing Crescent',
      'First Quarter',
      'Waxing Gibbous',
      'Full Moon',
      'Waning Gibbous',
      'Last Quarter',
      'Waning Crescent',
    ];
    return Column(
      children: [
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
                  controller: widget.environmentCtr.lowestDayTempCtr,
                  labelText: 'Day Lowest',
                  hintText: 'Enter lowest temperature',
                  isLastField: false,
                  onChanged: (String? value) {
                    if (value != null) {
                      CollEventServices(ref: ref).updateEnvironmentData(
                        widget.eventID,
                        EnvironmentCompanion(
                          lowestDayTempC: db.Value(double.tryParse(value)),
                        ),
                      );
                    }
                  },
                ),
              if (_isVisible('highestDayTempC'))
                CommonNumField(
                  controller: widget.environmentCtr.highestDayTempCtr,
                  labelText: 'Day Highest',
                  hintText: 'Enter highest temperature',
                  isLastField: false,
                  onChanged: (String? value) {
                    if (value != null) {
                      CollEventServices(ref: ref).updateEnvironmentData(
                        widget.eventID,
                        EnvironmentCompanion(
                          highestDayTempC: db.Value(double.tryParse(value)),
                        ),
                      );
                    }
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
                  controller: widget.environmentCtr.lowestNightTempCtr,
                  labelText: 'Night Lowest',
                  hintText: 'Enter lowest temperature',
                  isLastField: false,
                  onChanged: (String? value) {
                    if (value != null) {
                      CollEventServices(ref: ref).updateEnvironmentData(
                        widget.eventID,
                        EnvironmentCompanion(
                          lowestNightTempC: db.Value(double.tryParse(value)),
                        ),
                      );
                    }
                  },
                ),
              if (_isVisible('highestNightTempC'))
                CommonNumField(
                  controller: widget.environmentCtr.highestNightTempCtr,
                  labelText: 'Night Highest',
                  hintText: 'Enter highest temperature',
                  isLastField: false,
                  onChanged: (String? value) {
                    if (value != null) {
                      CollEventServices(ref: ref).updateEnvironmentData(
                        widget.eventID,
                        EnvironmentCompanion(
                          highestNightTempC: db.Value(double.tryParse(value)),
                        ),
                      );
                    }
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
                  controller: widget.environmentCtr.averageHumidityCtr,
                  key: const ValueKey('environment-average-humidity'),
                  labelText: 'Average',
                  hintText: 'Enter average humidity',
                  isLastField: false,
                  errorText: _averageHumidityError,
                  onChanged: _updateAverageHumidity,
                ),
              if (_isVisible('dewPointTemp'))
                CommonNumField(
                  controller: widget.environmentCtr.dewPointCtr,
                  labelText: 'Dew Point',
                  hintText: 'Enter dew point',
                  isLastField: false,
                  onChanged: (String? value) {
                    if (value != null) {
                      CollEventServices(ref: ref).updateEnvironmentData(
                        widget.eventID,
                        EnvironmentCompanion(
                          dewPointTemp: db.Value(double.tryParse(value)),
                        ),
                      );
                    }
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
                  initialValue: widget.environmentCtr.cloudCoverCtr,
                  decoration: const InputDecoration(
                    labelText: 'Cloud cover (oktas)',
                    hintText: 'Select cloud cover',
                    helperText:
                        'One okta represents one eighth of the visible sky.',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: CommonDropdownText(text: 'Not recorded'),
                    ),
                    for (final option in oktaOptionLabels.entries)
                      DropdownMenuItem<String?>(
                        value: option.key,
                        child: CommonDropdownText(text: option.value),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() => widget.environmentCtr.cloudCoverCtr = value);
                    _updateEnvironmentData(
                      EnvironmentCompanion(cloudCover: db.Value(value)),
                    );
                  },
                ),
              if (_isVisible('rainfallInMm'))
                CommonNumField(
                  controller: widget.environmentCtr.rainfallInMmCtr,
                  labelText: 'Rainfall (mm)',
                  hintText: 'Enter rainfall',
                  isDouble: true,
                  isLastField: false,
                  onChanged: (value) => _updateDouble(
                    value,
                    (parsed) =>
                        EnvironmentCompanion(rainfallInMm: db.Value(parsed)),
                  ),
                ),
            ],
          ),
        if (_hasAny(const ['ambientTemperature', 'ambientHumidity']))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              if (_isVisible('ambientTemperature'))
                CommonNumField(
                  controller: widget.environmentCtr.ambientTemperatureCtr,
                  labelText: 'Ambient temperature (°C)',
                  hintText: 'Enter ambient temperature',
                  isDouble: true,
                  isSigned: true,
                  isLastField: false,
                  onChanged: (value) => _updateDouble(
                    value,
                    (parsed) => EnvironmentCompanion(
                      ambientTemperature: db.Value(parsed),
                    ),
                  ),
                ),
              if (_isVisible('ambientHumidity'))
                CommonNumField(
                  controller: widget.environmentCtr.ambientHumidityCtr,
                  key: const ValueKey('environment-ambient-humidity'),
                  labelText: 'Ambient humidity (%)',
                  hintText: 'Enter relative humidity',
                  isDouble: true,
                  isLastField: false,
                  errorText: _ambientHumidityError,
                  onChanged: _updateAmbientHumidity,
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
                  controller: widget.environmentCtr.waterTemperatureCtr,
                  labelText: 'Water temperature (°C)',
                  hintText: 'Enter water temperature',
                  isDouble: true,
                  isSigned: true,
                  isLastField: false,
                  onChanged: (value) => _updateDouble(
                    value,
                    (parsed) => EnvironmentCompanion(
                      waterTemperature: db.Value(parsed),
                    ),
                  ),
                ),
              if (_isVisible('pH'))
                CommonNumField(
                  controller: widget.environmentCtr.pHCtr,
                  key: const ValueKey('environment-ph'),
                  labelText: 'pH',
                  hintText: 'Enter pH',
                  isDouble: true,
                  isLastField: false,
                  errorText: _pHError,
                  onChanged: _updatePH,
                ),
            ],
          ),
        if (_hasAny(const ['dissolvedOxygen', 'flowVelocity']))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              if (_isVisible('dissolvedOxygen'))
                CommonNumField(
                  controller: widget.environmentCtr.dissolvedOxygenCtr,
                  labelText: 'Dissolved oxygen (mg/L)',
                  hintText: 'Enter dissolved oxygen',
                  isDouble: true,
                  isLastField: false,
                  onChanged: (value) => _updateDouble(
                    value,
                    (parsed) =>
                        EnvironmentCompanion(dissolvedOxygen: db.Value(parsed)),
                  ),
                ),
              if (_isVisible('flowVelocity'))
                CommonNumField(
                  controller: widget.environmentCtr.flowVelocityCtr,
                  labelText: 'Flow velocity (m/s)',
                  hintText: 'Enter flow velocity',
                  isDouble: true,
                  isLastField: false,
                  onChanged: (value) => _updateDouble(
                    value,
                    (parsed) =>
                        EnvironmentCompanion(flowVelocity: db.Value(parsed)),
                  ),
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
                  controller: widget.environmentCtr.sunriseTimeCtr,
                  decoration: const InputDecoration(
                    labelText: 'Sunrise',
                    hintText: 'Enter sunrise time',
                  ),
                  onTap: () async {
                    final value = await _showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (value != null && mounted) {
                      final formattedTime = _formatTimeOfDay(value);
                      widget.environmentCtr.sunriseTimeCtr.text = formattedTime;
                      CollEventServices(ref: ref).updateEnvironmentData(
                        widget.eventID,
                        EnvironmentCompanion(
                          sunriseTime: db.Value(formattedTime),
                        ),
                      );
                    }
                  },
                ),
              if (_isVisible('sunsetTime'))
                TextField(
                  controller: widget.environmentCtr.sunsetTimeCtr,
                  decoration: const InputDecoration(
                    labelText: 'Sunset',
                    hintText: 'Enter sunset time',
                  ),
                  onTap: () async {
                    final value = await _showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (value != null && mounted) {
                      final formattedTime = _formatTimeOfDay(value);
                      widget.environmentCtr.sunsetTimeCtr.text = formattedTime;
                      _updateEnvironmentData(
                        EnvironmentCompanion(
                          sunsetTime: db.Value(formattedTime),
                        ),
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
              DropdownButtonFormField(
                initialValue: widget.environmentCtr.moonPhaseCtr,
                decoration: const InputDecoration(
                  labelText: 'Moon Phase',
                  hintText: 'Select moon phase',
                ),
                items: moonPhase
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: CommonDropdownText(text: e),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    widget.environmentCtr.moonPhaseCtr = value;
                    CollEventServices(ref: ref).updateEnvironmentData(
                      widget.eventID,
                      EnvironmentCompanion(moonPhase: db.Value(value)),
                    );
                  }
                },
              ),
            ],
          ),
        if (_isVisible('notes'))
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              CommonTextField(
                controller: widget.environmentCtr.noteCtr,
                labelText: 'Notes',
                hintText: 'Enter notes',
                maxLines: 3,
                isLastField: true,
                onChanged: (String? value) {
                  if (value != null) {
                    CollEventServices(ref: ref).updateEnvironmentData(
                      widget.eventID,
                      EnvironmentCompanion(notes: db.Value(value)),
                    );
                  }
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

  void _updateEnvironmentData(EnvironmentCompanion environmentData) {
    CollEventServices(
      ref: ref,
    ).updateEnvironmentData(widget.eventID, environmentData);
  }

  void _updateDouble(
    String? value,
    EnvironmentCompanion Function(double? value) companion,
  ) {
    final parsed = double.tryParse(value ?? '');
    if (value?.isNotEmpty == true && parsed == null) return;
    _updateEnvironmentData(companion(parsed));
  }

  void _updateAmbientHumidity(String? value) {
    final parsed = double.tryParse(value ?? '');
    final isValid =
        value?.trim().isEmpty != false ||
        (parsed != null && parsed >= 0 && parsed <= 100);
    setState(() {
      _ambientHumidityError = isValid ? null : 'Enter a value from 0 to 100';
    });
    if (isValid) {
      _updateEnvironmentData(
        EnvironmentCompanion(ambientHumidity: db.Value(parsed)),
      );
    }
  }

  void _updateAverageHumidity(String? value) {
    final parsed = double.tryParse(value ?? '');
    final isValid =
        value?.trim().isEmpty != false ||
        (parsed != null && parsed >= 0 && parsed <= 100);
    setState(() {
      _averageHumidityError = isValid ? null : 'Enter a value from 0 to 100';
    });
    if (isValid) {
      _updateEnvironmentData(
        EnvironmentCompanion(averageHumidity: db.Value(parsed)),
      );
    }
  }

  void _updatePH(String? value) {
    final parsed = double.tryParse(value ?? '');
    final isValid =
        value?.trim().isEmpty != false ||
        (parsed != null && parsed >= 0 && parsed <= 14);
    setState(() {
      _pHError = isValid ? null : 'Enter a value from 0 to 14';
    });
    if (isValid) {
      _updateEnvironmentData(EnvironmentCompanion(pH: db.Value(parsed)));
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return time.format(context);
  }
}
