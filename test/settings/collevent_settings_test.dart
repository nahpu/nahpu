import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/records/collevent_settings.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/user_config_settings_service.dart';

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
      'Temperature (°C)',
      'Day lowest temperature',
      'Day highest temperature',
      'Night lowest temperature',
      'Night highest temperature',
      'Humidity (%)',
      'Average humidity',
      'Dew point',
      'Environmental measurements',
      'Cloud cover',
      'Rainfall',
      'Ambient temperature',
      'Ambient humidity',
      'Aquatic Data',
      'Water temperature',
      'pH',
      'Dissolved oxygen',
      'Flow velocity',
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
    expect(
      find.widgetWithText(CheckboxListTile, 'Temperature (°C)'),
      findsNothing,
    );

    await tester.tap(
      find.widgetWithText(CheckboxListTile, 'Water temperature'),
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
}

class _RecordingUserConfigSettingsService extends UserConfigSettingsService {
  final replacements = <List<String>>[];

  @override
  Future<void> replaceOptions(String prefKey, List<String> newOptions) async {
    replacements.add(List<String>.from(newOptions));
  }
}
