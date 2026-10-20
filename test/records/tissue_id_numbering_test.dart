import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/records/specimen_settings.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('tissue IDs keep zero padding and add a suffix', (tester) async {
    SharedPreferences.setMockInitialValues({
      tissueIDPrefixKey: 'M',
      tissueIDNumberTextKey: '0042',
      tissueIDSuffixKey: '-T',
    });
    final preferences = await SharedPreferences.getInstance();
    final services = await _services(tester, preferences);

    expect(await services.getNewNumber(), 'M0042-T');
    expect(await services.getNewNumber(), 'M0043-T');
    expect(services.getNumberString(), '0044');
  });

  testWidgets('a legacy integer counter migrates on first use', (tester) async {
    SharedPreferences.setMockInitialValues({
      tissueIDPrefixKey: 'M',
      tissueIDNumberKey: 42,
    });
    final preferences = await SharedPreferences.getInstance();
    final services = await _services(tester, preferences);

    expect(services.getNumberString(), '42');
    expect(await services.getNewNumber(), 'M42');
    expect(preferences.getString(tissueIDNumberTextKey), '43');
    expect(preferences.containsKey(tissueIDNumberKey), isFalse);
  });

  testWidgets('tissue ID settings show a suffix and the next ID', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      tissueIDPrefixKey: 'M',
      tissueIDNumberTextKey: '007',
    });
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingProvider.overrideWithValue(preferences)],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: TissueIDFields(isMobile: false)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Suffix'), findsOneWidget);
    expect(
      find.text('Next tissue ID: M007 · Leading zeros are kept'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('numbered-id-suffix')),
      '-T',
    );
    await tester.pump();
    expect(
      find.text('Next tissue ID: M007-T · Leading zeros are kept'),
      findsOneWidget,
    );
    expect(preferences.getString(tissueIDSuffixKey), '-T');
  });
}

Future<TissueIdServices> _services(
  WidgetTester tester,
  SharedPreferences preferences,
) async {
  late WidgetRef widgetRef;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [settingProvider.overrideWithValue(preferences)],
      child: Consumer(
        builder: (context, ref, _) {
          widgetRef = ref;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return TissueIdServices(ref: widgetRef);
}
