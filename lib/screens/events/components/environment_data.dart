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
  });

  final bool useHorizontalLayout;
  final int eventID;
  final CollEnvironmentCtrModel environmentCtr;

  @override
  EnvironmentDataFormState createState() => EnvironmentDataFormState();
}

class EnvironmentDataFormState extends ConsumerState<EnvironmentDataForm> {
  String? _averageHumidityError;
  String? _ambientHumidityError;
  String? _pHError;

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
        CommonPadding(
          child: Text(
            'Temperature (°C)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
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
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
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
        const SizedBox(height: 8),
        CommonPadding(
          child: Text(
            'Humidity (%)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: widget.environmentCtr.averageHumidityCtr,
              key: const ValueKey('environment-average-humidity'),
              labelText: 'Average',
              hintText: 'Enter average humidity',
              isLastField: false,
              errorText: _averageHumidityError,
              onChanged: _updateAverageHumidity,
            ),
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
        const SizedBox(height: 8),
        CommonPadding(
          child: Text(
            'Environmental measurements',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            DropdownButtonFormField<String?>(
              key: const ValueKey('environment-cloud-cover'),
              initialValue: widget.environmentCtr.cloudCoverCtr,
              decoration: const InputDecoration(
                labelText: 'Cloud cover (oktas)',
                hintText: 'Select cloud cover',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: CommonDropdownText(text: 'Not recorded'),
                ),
                ...List.generate(9, (index) {
                  return DropdownMenuItem<String?>(
                    value: '$index',
                    child: CommonDropdownText(text: '$index — $index/8'),
                  );
                }),
                const DropdownMenuItem<String?>(
                  value: '9',
                  child: CommonDropdownText(text: '9 — Sky obscured'),
                ),
              ],
              onChanged: (value) {
                setState(() => widget.environmentCtr.cloudCoverCtr = value);
                _updateEnvironmentData(
                  EnvironmentCompanion(cloudCover: db.Value(value)),
                );
              },
            ),
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
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: widget.environmentCtr.ambientTemperatureCtr,
              labelText: 'Ambient temperature (°C)',
              hintText: 'Enter ambient temperature',
              isDouble: true,
              isSigned: true,
              isLastField: false,
              onChanged: (value) => _updateDouble(
                value,
                (parsed) =>
                    EnvironmentCompanion(ambientTemperature: db.Value(parsed)),
              ),
            ),
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
        const SizedBox(height: 8),
        CommonPadding(
          child: Text(
            'Aquatic Data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: widget.environmentCtr.waterTemperatureCtr,
              labelText: 'Water temperature (°C)',
              hintText: 'Enter water temperature',
              isDouble: true,
              isSigned: true,
              isLastField: false,
              onChanged: (value) => _updateDouble(
                value,
                (parsed) =>
                    EnvironmentCompanion(waterTemperature: db.Value(parsed)),
              ),
            ),
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
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
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
        const SizedBox(height: 8),
        CommonPadding(
          child: Text(
            'Astronomy',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
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
                    EnvironmentCompanion(sunriseTime: db.Value(formattedTime)),
                  );
                }
              },
            ),
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
                    EnvironmentCompanion(sunsetTime: db.Value(formattedTime)),
                  );
                }
              },
            ),
          ],
        ),
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
