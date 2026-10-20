import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/load_defaults_dialog.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/bundled_preset_service.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  late _FakeBundledPresetService service;
  BundledPresetLoadResult? result;

  setUp(() {
    service = _FakeBundledPresetService();
    result = null;
  });

  Future<void> open(
    WidgetTester tester,
    Set<BundledPresetKind> kinds, {
    Size size = const Size(1000, 900),
    double bottomInset = 0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding(bottom: bottomInset);
    tester.view.viewPadding = FakeViewPadding(bottom: bottomInset);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bundledPresetServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showLoadDefaultsDialog(
                    context: context,
                    kinds: kinds,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('offers generic presets of the kind and loads checked ones', (
    tester,
  ) async {
    await open(tester, const {BundledPresetKind.document});

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Tissue label'), findsNothing);
    expect(find.text('For Mammalogy'), findsOneWidget);
    final booklet = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Mammal field booklet'),
    );
    expect(booklet.value, isFalse);
    final saved = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Old labels'),
    );
    expect(saved.value, isTrue);
    expect(saved.onChanged, isNull);
    final tissue = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Tissue labels'),
    );
    expect(tissue.value, isTrue);

    await tester.tap(find.text('Skull tags'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Load selected'));
    await tester.tap(find.text('Load selected'));
    await tester.pumpAndSettle();

    expect(service.loaded.map((preset) => preset.name), ['Tissue labels']);
    expect(result?.message, 'Added 1 preset');
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('the sheet keeps Load selected above the navigation bar', (
    tester,
  ) async {
    await open(
      tester,
      const {BundledPresetKind.document},
      size: const Size(500, 900),
      bottomInset: 48,
    );

    expect(find.byType(BottomSheet), findsOneWidget);
    final load = find.ancestor(
      of: find.text('Load selected'),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    );
    await tester.ensureVisible(load);
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(load).dy, lessThanOrEqualTo(900 - 48));
  });

  testWidgets('says so when no default of the kind exists', (tester) async {
    await open(tester, const {BundledPresetKind.record});

    expect(find.text('No default presets of this type.'), findsOneWidget);
    expect(find.text('Load selected'), findsNothing);
  });
}

class _FakeBundledPresetService extends BundledPresetService {
  _FakeBundledPresetService();

  static const _presets = [
    (
      BundledPreset(
        kind: BundledPresetKind.document,
        name: 'Tissue labels',
        description: 'Vial labels.',
        assetPath: 'assets/configs/document-tissue-labels.json',
      ),
      false,
    ),
    (
      BundledPreset(
        kind: BundledPresetKind.document,
        name: 'Skull tags',
        description: 'Round tags.',
        assetPath: 'assets/configs/document-skull-tags.json',
      ),
      false,
    ),
    (
      BundledPreset(
        kind: BundledPresetKind.document,
        name: 'Old labels',
        description: 'Already saved.',
        assetPath: 'assets/configs/document-old-labels.json',
      ),
      true,
    ),
    (
      BundledPreset(
        kind: BundledPresetKind.template,
        name: 'Tissue label',
        description: 'A template.',
        assetPath: 'assets/configs/template-tissue-label.json',
      ),
      false,
    ),
    (
      BundledPreset(
        kind: BundledPresetKind.document,
        name: 'Mammal field booklet',
        description: 'A booklet.',
        assetPath:
            'assets/configs/mammalogy/document-mammal-field-booklet.json',
        catalogFmt: CatalogFmt.mammalogy,
      ),
      false,
    ),
  ];

  final loaded = <BundledPreset>[];

  @override
  Future<List<BundledPresetStatus>> statuses({
    CatalogFmt? catalogFmt,
    bool allFormats = false,
  }) async {
    return [
      for (final (preset, installed) in _presets)
        if (allFormats || preset.isGeneric || preset.catalogFmt == catalogFmt)
          BundledPresetStatus(preset: preset, isInstalled: installed),
    ];
  }

  @override
  Future<BundledPresetLoadResult> loadSelected(
    Iterable<BundledPreset> presets,
  ) async {
    loaded.addAll(presets);
    return BundledPresetLoadResult(added: presets.toList(), skippedCount: 0);
  }
}
