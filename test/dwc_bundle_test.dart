import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/exports/bundle_project.dart';
import 'package:nahpu/services/export/dwc_bundle.dart';

void main() {
  test('normalizes current and legacy bundle taxon labels', () {
    expect(normalizeBundleTaxonGroup('Avians'), 'Birds');
    expect(normalizeBundleTaxonGroup('General Mammals'), 'Mammals');
    expect(normalizeBundleTaxonGroup('Non-Bat Mammals'), 'Mammals');
    expect(normalizeBundleTaxonGroup('Bats'), 'Bats');
    expect(normalizeBundleTaxonGroup('Herpetofauna'), 'Herpetofauna');
  });

  testWidgets('users can switch to selected taxa and change the selection',
      (tester) async {
    var mode = BundleTaxonSelectionMode.all;
    var selected = <String>{'Birds', 'Mammals', 'Bats'};

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => BundleTaxonSelectionCard(
            availableTaxonGroups: const {'Birds', 'Mammals', 'Bats'},
            selectedTaxonGroups: selected,
            selectionMode: mode,
            isLoading: false,
            onModeChanged: (value) => setState(() => mode = value),
            onChanged: (value) => setState(() => selected = value),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Selected taxa'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Birds'));
    await tester.pump();

    expect(mode, BundleTaxonSelectionMode.selected);
    expect(selected, isNot(contains('Birds')));
    expect(selected, containsAll(<String>{'Mammals', 'Bats'}));
    final batsTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Bats'),
    );
    expect(batsTile.value, isTrue);
    expect(batsTile.onChanged, isNull);
  });

  testWidgets('only files with fields show an expansion control',
      (tester) async {
    const manifest = DwcBundleManifest(
      files: [
        DwcBundleFile(
          path: 'datapackage.json',
          mediaType: 'application/json',
          records: 0,
          columns: [],
        ),
        DwcBundleFile(
          path: 'occurrence.csv',
          mediaType: 'text/csv',
          records: 1,
          columns: ['occurrenceID'],
        ),
      ],
      warnings: [],
    );

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: BundleContentsPane(
          manifest: manifest,
          isLoading: false,
          error: null,
        ),
      ),
    ));

    expect(find.byType(ExpansionTile), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'datapackage.json'), findsOneWidget);
  });

  testWidgets('all taxa selection keeps the taxa card at the panel width',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: BundleTaxonSelectionCard(
              availableTaxonGroups: {'Birds', 'Herpetofauna', 'Mammals'},
              selectedTaxonGroups: {'Birds', 'Herpetofauna', 'Mammals'},
              selectionMode: BundleTaxonSelectionMode.all,
              isLoading: false,
              onChanged: _ignoreTaxonGroups,
              onModeChanged: _ignoreSelectionMode,
            ),
          ),
        ),
      ),
    ));

    final card = find.byType(Card);
    expect(tester.getSize(card).width, 500);
    expect(
      tester
          .getCenter(find.byType(SegmentedButton<BundleTaxonSelectionMode>))
          .dx,
      closeTo(tester.getCenter(card).dx, 0.1),
    );
  });

  testWidgets('package contents uses media-type icons', (tester) async {
    const manifest = DwcBundleManifest(
      files: [
        DwcBundleFile(
          path: 'media/specimen.jpg',
          mediaType: 'image/jpeg',
          records: 0,
          columns: [],
        ),
        DwcBundleFile(
          path: 'media/call.wav',
          mediaType: 'audio/wav',
          records: 0,
          columns: [],
        ),
        DwcBundleFile(
          path: 'media/behavior.mp4',
          mediaType: 'video/mp4',
          records: 0,
          columns: [],
        ),
      ],
      warnings: [],
    );

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: BundleContentsPane(
          manifest: manifest,
          isLoading: false,
          error: null,
        ),
      ),
    ));

    final icons = tester
        .widgetList<Icon>(find.byType(Icon))
        .map((icon) => icon.icon)
        .toSet();
    expect(icons, contains(Icons.image_outlined));
    expect(icons, contains(Icons.audio_file_outlined));
    expect(icons, contains(Icons.video_file_outlined));
  });
}

void _ignoreTaxonGroups(Set<String> _) {}

void _ignoreSelectionMode(BundleTaxonSelectionMode _) {}
