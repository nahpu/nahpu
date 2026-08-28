import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/components/controls/front_back_page_pickers.dart';

void main() {
  testWidgets('one-sided template shows a stable status pill', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TemplateSideSwitcher(
              isDuplex: false,
              isPage1: true,
              mirrorFront: false,
              mirrorBack: false,
              onPageChanged: _ignorePageChange,
            ),
          ),
        ),
      ),
    );

    expect(find.text('1 sided'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('two-sided template selects the requested side', (tester) async {
    var selectedPage = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TemplateSideSwitcher(
              isDuplex: true,
              isPage1: true,
              mirrorFront: false,
              mirrorBack: true,
              onPageChanged: (page) => selectedPage = page,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Back'));

    expect(selectedPage, 1);
  });
}

void _ignorePageChange(int _) {}
