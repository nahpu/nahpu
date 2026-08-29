import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/components/dialogs/template_name_dialogs.dart';

void main() {
  testWidgets('save dialog validates and returns a trimmed name', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<String>(
                context: context,
                builder: (_) =>
                    const SaveTemplateDialog(initialName: 'Current template'),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '  New template  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 'New template');
  });

  testWidgets('import dialog rejects taken names and accepts a unique name', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<String>(
                context: context,
                builder: (_) => const ImportTemplateNameDialog(
                  conflictingName: 'Field tag',
                  takenNames: {'Existing template'},
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Existing template');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(
      find.text('A template with this name already exists'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '  Imported copy  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 'Imported copy');
  });
}
