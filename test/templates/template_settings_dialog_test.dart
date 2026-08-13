import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/components/dialogs/template_settings_dialog.dart';
import 'package:nahpu/screens/templates/template_model.dart';

void main() {
  testWidgets('settings applies description and sided mode together',
      (tester) async {
    TemplateSettingsResult? result;
    const template = Template(
      name: 'Field tag',
      page1: TemplatePage(),
      page2: TemplatePage(),
      widthMm: 50,
      heightMm: 25,
      description: 'Old description',
    );

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
    await tester.enterText(find.byType(TextField), ' Updated description ');
    await tester.tap(find.text('Apply'));

    expect(result?.isDuplex, isFalse);
    expect(result?.description, 'Updated description');
  });
}
