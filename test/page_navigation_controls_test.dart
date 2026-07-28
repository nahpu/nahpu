import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/layout/navigation.dart';
import 'package:nahpu/services/navigation_services.dart';

void main() {
  const pageCount = 150;

  testWidgets('boundary buttons jump without reporting intermediate pages', (
    tester,
  ) async {
    final navigation = PageNavigation.init()..clampToCount(pageCount);
    final reportedPages = <int>[];
    await tester.pumpWidget(
      _NavigationHarness(
        navigation: navigation,
        pageCount: pageCount,
        onPageChanged: reportedPages.add,
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_double_arrow_right));
    await tester.pump();

    expect(navigation.pageController.page, pageCount - 1);
    expect(reportedPages, [pageCount - 1]);

    reportedPages.clear();
    await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left));
    await tester.pump();

    expect(navigation.pageController.page, 0);
    expect(reportedPages, [0]);

    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
  });

  testWidgets('go to page jumps directly to a distant destination', (
    tester,
  ) async {
    final navigation = PageNavigation.init()..clampToCount(pageCount);
    final reportedPages = <int>[];
    await tester.pumpWidget(
      _NavigationHarness(
        navigation: navigation,
        pageCount: pageCount,
        onPageChanged: reportedPages.add,
      ),
    );

    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '125');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(navigation.pageController.page, 124);
    expect(reportedPages, [124]);

    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
  });
}

class _NavigationHarness extends StatefulWidget {
  const _NavigationHarness({
    required this.navigation,
    required this.pageCount,
    required this.onPageChanged,
  });

  final PageNavigation navigation;
  final int pageCount;
  final ValueChanged<int> onPageChanged;

  @override
  State<_NavigationHarness> createState() => _NavigationHarnessState();
}

class _NavigationHarnessState extends State<_NavigationHarness> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: PageView.builder(
            controller: widget.navigation.pageController,
            itemCount: widget.pageCount,
            itemBuilder: (context, index) => Text('page $index'),
            onPageChanged: (index) {
              widget.onPageChanged(index);
              setState(() {
                widget.navigation.currentPage = index + 1;
                widget.navigation.updatePageNavigation();
              });
            },
          ),
          bottomNavigationBar: PageNavButton(pageNav: widget.navigation),
        ),
      ),
    );
  }
}
