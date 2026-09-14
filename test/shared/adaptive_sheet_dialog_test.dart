import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';

void main() {
  testWidgets('compact screens show a bottom sheet', (tester) async {
    _setViewSize(tester, const Size(400, 800));
    await _pumpLauncher(
      tester,
      (context) => showAdaptiveSheetDialog<void>(
        context: context,
        builder: (_, isSheet) => AdaptiveSheetDialogBody(
          title: 'Sheet title',
          showCloseButton: !isSheet,
          child: const Text('Body'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Sheet title'), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);
  });

  testWidgets('wide screens show a dialog with a close button', (tester) async {
    _setViewSize(tester, const Size(1000, 800));
    await _pumpLauncher(
      tester,
      (context) => showAdaptiveSheetDialog<void>(
        context: context,
        builder: (_, isSheet) => AdaptiveSheetDialogBody(
          title: 'Dialog title',
          showCloseButton: !isSheet,
          child: const Text('Body'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog title'), findsNothing);
  });

  testWidgets('a non-dismissible dialog ignores taps outside it', (
    tester,
  ) async {
    _setViewSize(tester, const Size(1000, 800));
    await _pumpLauncher(
      tester,
      (context) => showAdaptiveSheetDialog<void>(
        context: context,
        isDismissible: false,
        builder: (_, _) => const AdaptiveSheetDialogBody(
          title: 'Unsaved input',
          showCloseButton: false,
          child: Text('Body'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved input'), findsOneWidget);
  });

  testWidgets('long actions wrap instead of overflowing', (tester) async {
    _setViewSize(tester, const Size(320, 640));
    await _pumpLauncher(
      tester,
      (context) => showAdaptiveSheetDialog<void>(
        context: context,
        builder: (_, _) => AdaptiveSheetDialogBody(
          title: 'Actions',
          showCloseButton: false,
          actions: [
            OutlinedButton(
              onPressed: () {},
              child: const Text('A fairly long secondary action'),
            ),
            FilledButton(
              onPressed: () {},
              child: const Text('A fairly long primary action'),
            ),
          ],
          child: const Text('Body'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  for (final (label, expected) in [('Delete', true), ('Cancel', false)]) {
    testWidgets('confirmation returns $expected after $label', (tester) async {
      _setViewSize(tester, const Size(400, 800));
      bool? result;
      await _pumpLauncher(tester, (context) async {
        result = await showAdaptiveConfirmation(
          context: context,
          title: 'Delete item?',
          message: 'This cannot be undone.',
          confirmLabel: 'Delete',
          isDestructive: true,
        );
      });

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete item?'), findsOneWidget);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(result, expected);
    });
  }
}

void _setViewSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpLauncher(
  WidgetTester tester,
  Future<void> Function(BuildContext context) onOpen,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => onOpen(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}
