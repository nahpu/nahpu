import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/events/components/menu_bar.dart';
import 'package:nahpu/screens/sites/components/menu_bar.dart';
import 'package:nahpu/screens/specimens/shared/menu_bar.dart';

void main() {
  testWidgets('site menu exposes record exchange actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(actions: [const SiteMenu(siteId: null)]),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton));
    await tester.pumpAndSettle();

    expect(find.text('Show QR'), findsOneWidget);
    expect(find.text('Export site'), findsOneWidget);
    expect(find.text('Copy from project ...'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Import site'), findsOneWidget);
  });

  testWidgets('event menu exposes record exchange actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(actions: [const CollEventMenu(collEventId: null)]),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton));
    await tester.pumpAndSettle();

    expect(find.text('Show QR'), findsOneWidget);
    expect(find.text('Export event'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Import event'), findsOneWidget);
  });

  testWidgets('specimen menu exposes JSON exchange without QR actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                const SpecimenMenu(specimenUuid: null, catalogFmt: null),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton));
    await tester.pumpAndSettle();

    expect(find.text('Export specimen'), findsOneWidget);
    expect(find.text('Import specimen'), findsOneWidget);
    expect(find.text('Show QR'), findsNothing);
    expect(find.text('Scan QR'), findsNothing);
  });
}
