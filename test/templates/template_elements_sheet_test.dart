import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/controls/template_elements_sheet.dart';
import 'package:nahpu/screens/templates/template_model.dart';

void main() {
  const page = TemplatePage(
    customTexts: [CustomTextElement(id: 'ct_0', text: 'Site', xMm: 0, yMm: 0)],
    customImages: [
      CustomImageElement(
        id: 'img_0',
        imagePath: 'lab.png',
        xMm: 0,
        yMm: 0,
        widthMm: 20,
        heightMm: 10,
        zIndex: 1,
        isLocked: true,
      ),
    ],
  );

  /// Opens the sheet for [page] and records what it returns in [results].
  Future<void> openSheet(
    WidgetTester tester,
    TemplatePage page,
    List<String?> results,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                results.add(
                  await showTemplateElementsSheet(
                    context: context,
                    page: page,
                    page1: true,
                    sideLabel: 'Front',
                    selectedElement: 'custom:1:ct_0',
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
  }

  testWidgets('lists the side and returns the tapped element', (tester) async {
    final results = <String?>[];
    await openSheet(tester, page, results);

    expect(find.text('Elements · Front'), findsOneWidget);
    expect(find.text('lab.png'), findsOneWidget);
    expect(find.text('Site'), findsOneWidget);
    expect(find.byTooltip('Locked'), findsOneWidget);

    await tester.tap(find.text('lab.png'));
    await tester.pumpAndSettle();

    expect(results, ['image:1:img_0']);
    expect(find.text('Elements · Front'), findsNothing);
  });

  testWidgets('an empty side says how to add elements', (tester) async {
    await openSheet(tester, const TemplatePage(), <String?>[]);

    expect(find.textContaining('No elements on this side yet'), findsOneWidget);
  });
}
