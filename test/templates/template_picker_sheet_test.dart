import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/controls/template_picker_sheet.dart';

void main() {
  testWidgets('keeps the list above the navigation bar and returns a name', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.reset);

    final results = <String?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                results.add(
                  await showTemplatePickerSheet(
                    context: context,
                    savedNames: const ['Skull tag', 'Tissue label'],
                    currentName: 'Skull tag',
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      tester.getBottomLeft(find.byType(ListView)).dy,
      lessThanOrEqualTo(800 - 48),
    );

    await tester.tap(find.text('Tissue label'));
    await tester.pumpAndSettle();

    expect(results, ['Tissue label']);
  });
}
