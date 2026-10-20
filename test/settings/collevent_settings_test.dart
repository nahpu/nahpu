import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/records/collevent_settings.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/user_config_settings_service.dart';
import 'package:nahpu/services/types/events.dart';

void main() {
  testWidgets('environmental fields are grouped by category', (tester) async {
    final settings = _RecordingUserConfigSettingsService();
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userConfigSettingsServiceProvider.overrideWithValue(settings),
          userDefinedFieldProvider(environmentalDataFieldsPrefKey).overrideWith(
            (ref) async => const [
              'ambientTemperature',
              'ambientHumidity',
              'cloudCover',
              'rainfallInMm',
              'notes',
            ],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnvironmentalDataFieldSettings(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    const orderedLabels = [
      'Temperature',
      'Day lowest temperature (°C)',
      'Day highest temperature (°C)',
      'Night lowest temperature (°C)',
      'Night highest temperature (°C)',
      'Humidity',
      'Average humidity (%)',
      'Dew point (°C)',
      'Environmental measurements',
      'Cloud cover (okta)',
      'Rainfall (mm)',
      'Ambient temperature (°C)',
      'Ambient humidity (%)',
      'Aquatic Data',
      'Water temperature (°C)',
      'pH',
      'Dissolved oxygen (mg/L)',
      'Dissolved oxygen saturation (%)',
      'Conductivity (µS/cm)',
      'Flow velocity (m/s)',
      'Astronomy',
      'Sunrise',
      'Sunset',
      'Moon phase',
      'Notes',
    ];

    final yPositions = <double>[];
    for (final label in orderedLabels) {
      expect(find.text(label), findsOneWidget);
      yPositions.add(tester.getTopLeft(find.text(label)).dy);
    }
    for (var index = 1; index < yPositions.length; index++) {
      expect(yPositions[index], greaterThan(yPositions[index - 1]));
    }
    expect(find.widgetWithText(CheckboxListTile, 'Temperature'), findsNothing);

    await tester.tap(
      find.widgetWithText(CheckboxListTile, 'Water temperature (°C)'),
    );
    await tester.pumpAndSettle();

    expect(settings.replacements, [
      [
        'cloudCover',
        'rainfallInMm',
        'ambientTemperature',
        'ambientHumidity',
        'waterTemperature',
        'notes',
      ],
    ]);
  });

  test('every numeric environmental field declares its unit', () {
    const unitless = {'pH'};
    for (final field in environmentalNumericFields) {
      if (unitless.contains(field)) continue;
      expect(
        environmentalDataFieldUnits[field],
        isNotNull,
        reason: '$field needs a unit',
      );
    }
    expect(
      environmentalDataFieldLabelWithUnit('conductivity'),
      'Conductivity (µS/cm)',
    );
    expect(environmentalDataFieldLabelWithUnit('pH'), 'pH');
  });
}

class _RecordingUserConfigSettingsService extends UserConfigSettingsService {
  final replacements = <List<String>>[];

  @override
  Future<void> replaceOptions(String prefKey, List<String> newOptions) async {
    replacements.add(List<String>.from(newOptions));
  }
}
