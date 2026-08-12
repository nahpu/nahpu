import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/components/properties/text_element_editor.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  testWidgets('desktop text editor clears only the current draft', (
    tester,
  ) async {
    await _setTestSurface(tester, const Size(1200, 900));
    String? savedText;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TextElementEditorDialog(
              initialText: 'Existing template text',
              recordType: RecordType.specimenRecord,
              onSave: (value) => savedText = value,
            ),
          ),
        ),
      ),
    );

    await _expectDraftClear(tester, savedText: () => savedText);
  });

  testWidgets('mobile text editor clears only the current draft', (
    tester,
  ) async {
    await _setTestSurface(tester, const Size(400, 800));
    String? savedText;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TextElementEditorBottomSheet(
              initialText: 'Existing template text',
              recordType: RecordType.specimenRecord,
              onSave: (value) => savedText = value,
            ),
          ),
        ),
      ),
    );

    await _expectDraftClear(tester, savedText: () => savedText);
  });
}

Future<void> _expectDraftClear(
  WidgetTester tester, {
  required String? Function() savedText,
}) async {
  final textField = find.byType(TextField);
  final clearButton = find.widgetWithText(TextButton, 'Clear');
  expect(textField, findsOneWidget);
  expect(clearButton, findsOneWidget);
  expect(
    tester.getTopLeft(clearButton).dy,
    greaterThanOrEqualTo(tester.getBottomLeft(textField).dy),
  );

  await tester.tap(clearButton);
  await tester.pump();

  expect(tester.widget<TextField>(textField).controller?.text, isEmpty);
  expect(savedText(), isNull);
  expect(find.text('Edit Custom Text'), findsOneWidget);

  await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
  await tester.pump();

  expect(savedText(), '');
}

Future<void> _setTestSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
