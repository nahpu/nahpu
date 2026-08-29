import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/dialogs/record_sort_dialog.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/record_sort.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/record_sort.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Covers the shared "Sort records" dialog: each viewer offers its own field
/// list, Apply commits and persists, and Cancel leaves the sort untouched.
void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  Future<ProviderContainer> pumpDialog(
    WidgetTester tester,
    RecordViewer viewer,
  ) async {
    final container = ProviderContainer(
      overrides: [settingProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: RecordSortDialog(viewer: viewer)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('each viewer offers only its own sort fields', (tester) async {
    for (final viewer in RecordViewer.values) {
      await pumpDialog(tester, viewer);
      final fields = recordSortFields[viewer]!;

      expect(
        find.byType(RadioListTile<RecordSortField>),
        findsNWidgets(fields.length),
      );
      for (final field in fields) {
        expect(
          find.text(field.labelFor(viewer)),
          findsOneWidget,
          reason: '${viewer.name} should offer ${field.name}',
        );
      }
      // Insertion order is always the first option and the starting value.
      expect(fields.first, RecordSortField.insertion);
    }
  });

  testWidgets('applying commits the choice and persists it', (tester) async {
    final container = await pumpDialog(tester, RecordViewer.site);

    await tester.tap(
      find.text(RecordSortField.locality.labelFor(RecordViewer.site)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(RecordSortDirection.descending.label));
    await tester.pumpAndSettle();

    // Nothing is committed until Apply, so the list behind the dialog does
    // not refetch on every tap.
    expect(
      container.read(recordSortProvider(RecordViewer.site)),
      RecordSort.defaultSort,
    );

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    const expected = RecordSort(
      field: RecordSortField.locality,
      direction: RecordSortDirection.descending,
    );
    expect(container.read(recordSortProvider(RecordViewer.site)), expected);
    expect(
      preferences.getString(recordSortPrefKeyFor(RecordViewer.site)),
      expected.encode(),
    );
  });

  testWidgets('cancelling writes nothing', (tester) async {
    final container = await pumpDialog(tester, RecordViewer.narrative);

    await tester.tap(
      find.text(RecordSortField.writer.labelFor(RecordViewer.narrative)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      container.read(recordSortProvider(RecordViewer.narrative)),
      RecordSort.defaultSort,
    );
    expect(
      preferences.getString(recordSortPrefKeyFor(RecordViewer.narrative)),
      isNull,
    );
  });

  testWidgets('the dialog opens on the persisted sort', (tester) async {
    const stored = RecordSort(
      field: RecordSortField.cataloger,
      direction: RecordSortDirection.descending,
    );
    SharedPreferences.setMockInitialValues({
      recordSortPrefKeyFor(RecordViewer.specimen): stored.encode(),
    });
    preferences = await SharedPreferences.getInstance();

    final container = await pumpDialog(tester, RecordViewer.specimen);

    expect(container.read(recordSortProvider(RecordViewer.specimen)), stored);
    final group = tester.widget<RadioGroup<RecordSortField>>(
      find.byType(RadioGroup<RecordSortField>),
    );
    expect(group.groupValue, RecordSortField.cataloger);
    final segmented = tester.widget<SegmentedButton<RecordSortDirection>>(
      find.byType(SegmentedButton<RecordSortDirection>),
    );
    expect(segmented.selected, {RecordSortDirection.descending});
  });

  test('an unrecognized stored value falls back to the default', () {
    expect(RecordSort.decode(null), RecordSort.defaultSort);
    expect(RecordSort.decode(''), RecordSort.defaultSort);
    expect(RecordSort.decode('nonsense'), RecordSort.defaultSort);
    expect(RecordSort.decode('removedField:ascending'), RecordSort.defaultSort);
    expect(RecordSort.decode('locality:sideways'), RecordSort.defaultSort);
    expect(
      RecordSort.decode('locality:descending'),
      const RecordSort(
        field: RecordSortField.locality,
        direction: RecordSortDirection.descending,
      ),
    );
  });
}
