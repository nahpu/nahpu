import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/events/components/coll_method.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';

void main() {
  testWidgets('add collection method form uses method and detail sections', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          userDefinedFieldProvider.overrideWith(
            (ref, prefKey) async => const ['Sweep net'],
          ),
        ],
        child: const MaterialApp(home: NewCollMethod(collEventId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Collection Method'), findsOneWidget);
    expect(find.byType(FormSection), findsNWidgets(2));
    expect(
      tester
          .widgetList<FormSection>(find.byType(FormSection))
          .map((section) => section.title),
      containsAll(<String>['Collection method', 'Method details']),
    );

    final methodSection = tester.widget<FormSection>(
      find.ancestor(
        of: find.byType(CollMethodDropdown),
        matching: find.byType(FormSection),
      ),
    );
    expect(methodSection.title, 'Collection method');
    expect(find.text('Method'), findsOneWidget);

    final countSections = tester.widgetList<FormSection>(
      find.ancestor(of: find.text('Count'), matching: find.byType(FormSection)),
    );
    expect(
      countSections.map((section) => section.title),
      contains('Collection method'),
    );

    final countField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Count',
      ),
    );
    expect(
      countField.decoration?.hintText,
      'How many of this tool were used (if applicable)?',
    );

    final brandField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Brand and Model',
      ),
    );
    expect(
      brandField.decoration?.hintText,
      'Enter brand and model of the tool (if applicable)',
    );

    for (final label in ['Brand and Model', 'Size', 'Notes']) {
      final sections = tester.widgetList<FormSection>(
        find.ancestor(of: find.text(label), matching: find.byType(FormSection)),
      );
      expect(
        sections.map((section) => section.title),
        contains('Method details'),
      );
    }
  });
}
