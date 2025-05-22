import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;

class WeatherDataView extends ConsumerWidget {
  const WeatherDataView({
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
          text: 'Weather Data',
          infoContent: WeatherInfoContent(),
        ),
        ref.watch(weatherDataProvider(eventID)).when(
              data: (weatherData) => WeatherDataForm(
                useHorizontalLayout: useHorizontalLayout,
                eventID: eventID,
                weatherCtr: _getWeatherData(weatherData),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => const Center(
                child: Text('Error'),
              ),
            ),
      ],
    );
  }

  CollWeatherCtrModel _getWeatherData(WeatherData weatherData) {
    return CollWeatherCtrModel.fromData(weatherData);
  }
}

class WeatherDataForm extends ConsumerStatefulWidget {
  const WeatherDataForm({
    super.key,
    required this.useHorizontalLayout,
    required this.eventID,
    required this.weatherCtr,
  });

  final bool useHorizontalLayout;
  final int eventID;
  final CollWeatherCtrModel weatherCtr;

  @override
  WeatherDataFormState createState() => WeatherDataFormState();
}

class WeatherDataFormState extends ConsumerState<WeatherDataForm> {
  @override
  void dispose() {
    widget.weatherCtr.dispose();
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
      'Waning Crescent'
    ];
    return Column(
      children: [
        Text('Temperature (°C)',
            style: Theme.of(context).textTheme.titleMedium),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: widget.weatherCtr.lowestDayTempCtr,
              labelText: 'Day Lowest',
              hintText: 'Enter lowest temperature',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  CollEventServices(ref: ref).updateWeatherData(
                      widget.eventID,
                      WeatherCompanion(
                        lowestDayTempC: db.Value(double.tryParse(value)),
                      ));
                }
              },
            ),
            CommonNumField(
              controller: widget.weatherCtr.highestDayTempCtr,
              labelText: 'Day Highest',
              hintText: 'Enter highest temperature',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  CollEventServices(ref: ref).updateWeatherData(
                      widget.eventID,
                      WeatherCompanion(
                        highestDayTempC: db.Value(double.tryParse(value)),
                      ));
                }
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: widget.weatherCtr.lowestNightTempCtr,
              labelText: 'Night Lowest',
              hintText: 'Enter lowest temperature',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  CollEventServices(ref: ref).updateWeatherData(
                      widget.eventID,
                      WeatherCompanion(
                        lowestNightTempC: db.Value(double.tryParse(value)),
                      ));
                }
              },
            ),
            CommonNumField(
              controller: widget.weatherCtr.highestNightTempCtr,
              labelText: 'Night Highest',
              hintText: 'Enter highest temperature',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  CollEventServices(ref: ref).updateWeatherData(
                      widget.eventID,
                      WeatherCompanion(
                        highestNightTempC: db.Value(double.tryParse(value)),
                      ));
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Humidity (%)', style: Theme.of(context).textTheme.titleMedium),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: widget.weatherCtr.averageHumidityCtr,
              labelText: 'Average',
              hintText: 'Enter average humidity',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  CollEventServices(ref: ref).updateWeatherData(
                      widget.eventID,
                      WeatherCompanion(
                        averageHumidity: db.Value(double.tryParse(value)),
                      ));
                }
              },
            ),
            CommonNumField(
              controller: widget.weatherCtr.dewPointCtr,
              labelText: 'Dew Point',
              hintText: 'Enter dew point',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  CollEventServices(ref: ref).updateWeatherData(
                      widget.eventID,
                      WeatherCompanion(
                        dewPointTemp: db.Value(double.tryParse(value)),
                      ));
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Astronomy', style: Theme.of(context).textTheme.titleMedium),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            TextField(
              controller: widget.weatherCtr.sunriseTimeCtr,
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
                  widget.weatherCtr.sunriseTimeCtr.text = formattedTime;
                  CollEventServices(ref: ref).updateWeatherData(
                      widget.eventID,
                      WeatherCompanion(
                        sunriseTime: db.Value(formattedTime),
                      ));
                }
              },
            ),
            TextField(
              controller: widget.weatherCtr.sunsetTimeCtr,
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
                  widget.weatherCtr.sunsetTimeCtr.text = formattedTime;
                  _updateWeatherData(WeatherCompanion(
                    sunsetTime: db.Value(formattedTime),
                  ));
                }
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: DropdownButtonFormField(
            value: widget.weatherCtr.moonPhaseCtr,
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
                widget.weatherCtr.moonPhaseCtr = value;
                CollEventServices(ref: ref).updateWeatherData(
                    widget.eventID,
                    WeatherCompanion(
                      moonPhase: db.Value(value),
                    ));
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: CommonTextField(
            controller: widget.weatherCtr.noteCtr,
            labelText: 'Notes',
            hintText: 'Enter notes',
            maxLines: 3,
            isLastField: true,
            onChanged: (String? value) {
              if (value != null) {
                CollEventServices(ref: ref).updateWeatherData(
                    widget.eventID,
                    WeatherCompanion(
                      notes: db.Value(value),
                    ));
              }
            },
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
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  void _updateWeatherData(WeatherCompanion weatherData) {
    CollEventServices(ref: ref).updateWeatherData(widget.eventID, weatherData);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return time.format(context);
  }
}

class WeatherInfoContent extends StatelessWidget {
  const WeatherInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          content: 'Weather data records the weather during the event.',
        ),
      ],
    );
  }
}
