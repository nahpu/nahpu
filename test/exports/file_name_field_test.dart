import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';

void main() {
  test('formats the filename suffix with the selected date', () {
    final date = DateTime(2026, 8, 19);

    expect(fileNameFieldSuffix('pdf', appendDate: false, date: date), '.pdf');
    expect(
      fileNameFieldSuffix('pdf', appendDate: true, date: date),
      '-2026-08-19.pdf',
    );
  });

  testWidgets('filename field previews extension and appended date', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'documents');
    addTearDown(controller.dispose);
    var appendDate = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                FileNameField(
                  controller: controller,
                  extension: 'pdf',
                  appendDate: appendDate,
                  onChanged: (_) {},
                ),
                AppendDateSwitch(
                  value: appendDate,
                  enabled: true,
                  onChanged: (value) => setState(() => appendDate = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    TextField field() => tester.widget<TextField>(find.byType(TextField));

    expect(field().decoration?.border, isA<OutlineInputBorder>());
    expect(field().decoration?.suffixText, '.pdf');

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(
      field().decoration?.suffixText,
      fileNameFieldSuffix('pdf', appendDate: true),
    );
    expect(controller.text, 'documents');
  });

  testWidgets('disabled filename controls cannot be changed', (tester) async {
    final controller = TextEditingController(text: 'documents');
    addTearDown(controller.dispose);
    var changed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FileNameField(
                controller: controller,
                extension: 'json',
                appendDate: false,
                enabled: false,
                onChanged: (_) => changed = true,
              ),
              AppendDateSwitch(
                value: false,
                enabled: false,
                onChanged: (_) => changed = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
      isNull,
    );
    expect(changed, isFalse);
  });
}
