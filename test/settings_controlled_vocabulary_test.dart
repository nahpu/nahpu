import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/settings/controlled_vocabulary.dart';
import 'package:nahpu/screens/settings/site_settings.dart';
import 'package:nahpu/services/controlled_vocabulary_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/utility_services.dart';

void main() {
  testWidgets('site settings include the default datum vocabulary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          for (final key in [
            siteTypeFmtPrefKey,
            habitatTypeFmtPrefKey,
            datumFmtPrefKey,
          ])
            textCaseFmtNotifierProvider(
              key,
            ).overrideWith(() => _FakeTextCaseFmtNotifier(key)),
          effectiveUserDefinedFieldProvider(
            siteTypePrefKey,
          ).overrideWith((ref) async => const <String>[]),
          effectiveUserDefinedFieldProvider(
            habitatTypePrefKey,
          ).overrideWith((ref) async => const <String>[]),
          effectiveUserDefinedFieldProvider(
            datumPrefKey,
          ).overrideWith((ref) async => const ['WGS84', 'NAD83', 'NAD27']),
        ],
        child: const MaterialApp(home: SiteSelection()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Datums'), findsOneWidget);
    expect(find.text('WGS84'), findsOneWidget);
    expect(find.text('NAD83'), findsOneWidget);
    expect(find.text('NAD27'), findsOneWidget);
    expect(find.text('Other'), findsNothing);
  });

  testWidgets(
    'controlled vocabulary sections include format action and matching',
    (tester) async {
      await tester.pumpWidget(
        _settingsHarness(
          const ControlledVocabularySetting(
            title: 'specimen types',
            typePrefKey: specimenTypePrefKey,
            fmtPrefKey: specimenTypeFmtPrefKey,
            typeName: 'specimen type',
          ),
          formatKeys: [specimenTypeFmtPrefKey],
          vocabularyKeys: [specimenTypePrefKey],
        ),
      );
      await tester.pump();

      expect(find.text('Specimen Types'), findsOneWidget);
      expect(find.text('Case format'), findsNothing);
      expect(find.text('Types'), findsNothing);
      expect(find.text('Match database'), findsOneWidget);
      expect(find.byTooltip('Set case format'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ControlledVocabularySetting),
          matching: find.byType(CommonSettingSection),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Set case format'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Case format'), findsOneWidget);
      expect(find.text('Title Case'), findsOneWidget);

      await tester.tap(find.text('Title Case'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('parasite settings use one parent without repeated labels', (
    tester,
  ) async {
    const formatKeys = [
      parasiteCategoryFmtPrefKey,
      parasiteDetectionMethodFmtPrefKey,
      parasitePreparationMethodFmtPrefKey,
      parasiteAnatomicalLocationFmtPrefKey,
      parasiteStorageFmtPrefKey,
      parasiteTreatmentFmtPrefKey,
    ];
    const vocabularyKeys = [
      parasiteCategoryPrefKey,
      parasiteDetectionMethodPrefKey,
      parasitePreparationMethodPrefKey,
      parasiteAnatomicalLocationPrefKey,
      parasiteStoragePrefKey,
      parasiteTreatmentPrefKey,
    ];

    await tester.pumpWidget(
      _settingsHarness(
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parasite'),
            ControlledVocabularySetting(
              title: 'Categories',
              typePrefKey: parasiteCategoryPrefKey,
              fmtPrefKey: parasiteCategoryFmtPrefKey,
              typeName: 'category',
            ),
            ControlledVocabularySetting(
              title: 'Detection methods',
              typePrefKey: parasiteDetectionMethodPrefKey,
              fmtPrefKey: parasiteDetectionMethodFmtPrefKey,
              typeName: 'detection method',
            ),
            ControlledVocabularySetting(
              title: 'Preparation methods',
              typePrefKey: parasitePreparationMethodPrefKey,
              fmtPrefKey: parasitePreparationMethodFmtPrefKey,
              typeName: 'preparation method',
            ),
            ControlledVocabularySetting(
              title: 'Anatomical locations',
              typePrefKey: parasiteAnatomicalLocationPrefKey,
              fmtPrefKey: parasiteAnatomicalLocationFmtPrefKey,
              typeName: 'anatomical location',
            ),
            ControlledVocabularySetting(
              title: 'Storage',
              typePrefKey: parasiteStoragePrefKey,
              fmtPrefKey: parasiteStorageFmtPrefKey,
              typeName: 'storage value',
            ),
            ControlledVocabularySetting(
              title: 'Treatments',
              typePrefKey: parasiteTreatmentPrefKey,
              fmtPrefKey: parasiteTreatmentFmtPrefKey,
              typeName: 'treatment',
            ),
          ],
        ),
        formatKeys: formatKeys,
        vocabularyKeys: vocabularyKeys,
      ),
    );
    await tester.pump();

    expect(find.text('Parasite'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Detection Methods'), findsOneWidget);
    expect(find.text('Case format'), findsNothing);
    expect(find.text('Parasite categories'), findsNothing);
    expect(find.text('Match database'), findsNWidgets(6));
    expect(find.byTooltip('Set case format'), findsNWidgets(6));

    await tester.tap(find.byTooltip('Set case format').first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Case format'), findsOneWidget);
  });

  testWidgets('case format action opens a bottom sheet on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _settingsHarness(
        const ControlledVocabularySetting(
          title: 'specimen types',
          typePrefKey: specimenTypePrefKey,
          fmtPrefKey: specimenTypeFmtPrefKey,
          typeName: 'specimen type',
        ),
        formatKeys: [specimenTypeFmtPrefKey],
        vocabularyKeys: [specimenTypePrefKey],
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Set case format'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Title Case'), findsOneWidget);
  });
}

Widget _settingsHarness(
  Widget child, {
  required List<String> formatKeys,
  required List<String> vocabularyKeys,
}) {
  return ProviderScope(
    overrides: [
      for (final key in formatKeys)
        textCaseFmtNotifierProvider(
          key,
        ).overrideWith(() => _FakeTextCaseFmtNotifier(key)),
      for (final key in vocabularyKeys)
        effectiveUserDefinedFieldProvider(
          key,
        ).overrideWith((ref) async => const <String>[]),
    ],
    child: MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

class _FakeTextCaseFmtNotifier extends TextCaseFmtNotifier {
  _FakeTextCaseFmtNotifier(super.prefKey);

  @override
  Future<TextCaseFmt> build() async => TextCaseFmt.anyCase;

  @override
  Future<void> set(String prefKey, TextCaseFmt fmt) async {
    state = AsyncData(fmt);
  }
}
