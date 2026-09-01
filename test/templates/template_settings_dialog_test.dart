import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/components/dialogs/template_settings_dialog.dart';
import 'package:nahpu/screens/templates/template_model.dart';

void main() {
  const template = Template(
    name: 'Field tag',
    page1: TemplatePage(),
    page2: TemplatePage(),
    widthMm: 50,
    heightMm: 25,
    description: 'Old description',
  );

  Finder nameField() => find.widgetWithText(TextField, 'Field tag');
  Finder descriptionField() =>
      find.widgetWithText(TextField, 'Old description');

  Future<void> pumpForm(
    WidgetTester tester, {
    Set<String> takenNames = const {},
    bool isDuplex = true,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TemplateSettingsForm(
          template: template,
          isDuplex: isDuplex,
          takenNames: takenNames,
          onCancel: () {},
          onApply: (_) {},
        ),
      ),
    ),
  );

  testWidgets('settings applies description and sided mode together', (
    tester,
  ) async {
    TemplateSettingsResult? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TemplateSettingsForm(
            template: template,
            isDuplex: true,
            onCancel: () {},
            onApply: (value) => result = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('1 sided'));
    await tester.enterText(descriptionField(), ' Updated description ');
    await tester.tap(find.text('Apply'));

    expect(result?.isDuplex, isFalse);
    expect(result?.description, 'Updated description');
    expect(result?.name, 'Field tag');
  });

  testWidgets('the name is editable and returned trimmed', (tester) async {
    TemplateSettingsResult? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TemplateSettingsForm(
            template: template,
            isDuplex: false,
            onCancel: () {},
            onApply: (value) => result = value,
          ),
        ),
      ),
    );

    expect(nameField(), findsOneWidget);
    await tester.enterText(nameField(), '  Museum tag  ');
    await tester.pump();
    await tester.tap(find.text('Apply'));

    expect(result?.name, 'Museum tag');
    expect(result?.description, 'Old description');
  });

  testWidgets('an empty name is rejected', (tester) async {
    await pumpForm(tester);

    await tester.enterText(nameField(), '   ');
    await tester.pump();

    expect(find.text('Enter a name'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('a name taken by another template is rejected', (tester) async {
    await pumpForm(tester, takenNames: {'Museum tag'});

    await tester.enterText(nameField(), 'Museum tag');
    await tester.pump();

    expect(
      find.text('A template with this name already exists'),
      findsOneWidget,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('keeping the current name is always allowed', (tester) async {
    TemplateSettingsResult? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TemplateSettingsForm(
            template: template,
            isDuplex: false,
            takenNames: const {'Museum tag'},
            onCancel: () {},
            onApply: (value) => result = value,
          ),
        ),
      ),
    );

    await tester.enterText(nameField(), 'Field tag');
    await tester.pump();
    await tester.tap(find.text('Apply'));

    expect(result?.name, 'Field tag');
  });
}
