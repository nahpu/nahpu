import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/events/components/menu_bar.dart';
import 'package:nahpu/screens/sites/components/menu_bar.dart';

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
    expect(find.text('Export JSON'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Import JSON'), findsOneWidget);
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
    expect(find.text('Export JSON'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Import JSON'), findsOneWidget);
  });
}
