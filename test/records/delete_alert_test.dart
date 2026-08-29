import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/projects/project_services.dart';

void main() {
  testWidgets('delete button requires exact confirmation text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: DeleteAlerts(
              title: 'Delete project?',
              deletePrompt: 'Delete prompt',
              requiredConfirmationText: 'abcde',
              onDelete: _noOpDelete,
            ),
          ),
        ),
      ),
    );

    TextButton deleteButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Delete'),
    );
    expect(deleteButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'abcd');
    await tester.pump();
    deleteButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Delete'),
    );
    expect(deleteButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'abcde');
    await tester.pump();
    deleteButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Delete'),
    );
    expect(deleteButton.onPressed, isNotNull);
  });

  testWidgets('delete button uses disabled visual state before confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: DeleteAlerts(
              title: 'Delete project?',
              deletePrompt: 'Delete prompt',
              requiredConfirmationText: 'abcde',
              onDelete: _noOpDelete,
            ),
          ),
        ),
      ),
    );

    TextButton deleteButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Delete'),
    );
    final disabledColor = deleteButton.style?.foregroundColor?.resolve({
      WidgetState.disabled,
    });
    expect(disabledColor, isNotNull);

    await tester.enterText(find.byType(TextField), 'abcde');
    await tester.pump();

    deleteButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Delete'),
    );
    final enabledColor = deleteButton.style?.foregroundColor?.resolve(
      <WidgetState>{},
    );
    expect(enabledColor, isNotNull);
    expect(enabledColor, isNot(equals(disabledColor)));
  });

  testWidgets('dialog controls are disabled while delete is running', (
    tester,
  ) async {
    final completer = Completer<void>();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: DeleteAlerts(
              title: 'Delete project?',
              deletePrompt: 'Delete prompt',
              requiredConfirmationText: 'abcde',
              onDelete: () => completer.future,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'abcde');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pump();

    final TextField textField = tester.widget<TextField>(
      find.byType(TextField),
    );
    expect(textField.enabled, isFalse);

    final TextButton cancelButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Cancel'),
    );
    expect(cancelButton.onPressed, isNull);

    completer.complete();
    await tester.pump();
  });

  testWidgets('shows formatted phase failure message in error dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () {
                      showDeleteAlertOnMenu(
                        context: context,
                        title: 'Delete project?',
                        deletePrompt: 'Delete prompt',
                        requiredConfirmationText: 'abcde',
                        onDelete: () async {
                          try {
                            throw ProjectDeletionFailure(
                              phase: 'collecting events',
                              diagnosticSummary:
                                  '3 specimen records, 1 collecting event',
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            final errorMessage = e is ProjectDeletionFailure
                                ? e.toUserMessage()
                                : e.toString();
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: Text(errorMessage),
                              ),
                            );
                          }
                        },
                      );
                    },
                    child: const Text('Open delete dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open delete dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'abcde');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Error'), findsOneWidget);
    expect(
      find.text(
        'Project deletion failed while deleting collecting events. Remaining related data: 3 specimen records, 1 collecting event.',
      ),
      findsOneWidget,
    );
  });
}

Future<void> _noOpDelete() async {}
