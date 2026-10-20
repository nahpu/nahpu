import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/layout/navigation.dart';
import 'package:nahpu/services/common/navigation_services.dart';

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

  testWidgets('go to page sheet search button closes it and opens search', (
    tester,
  ) async {
    final navigation = PageNavigation.init()..clampToCount(pageCount);
    var searchCount = 0;
    await tester.pumpWidget(
      _NavigationHarness(
        navigation: navigation,
        pageCount: pageCount,
        onPageChanged: (_) {},
        onSearch: () => searchCount++,
      ),
    );

    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(NavSheet), findsOneWidget);
    expect(find.byType(GoToPageField), findsOneWidget);

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    expect(searchCount, 1);
    expect(find.byType(NavSheet), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
  });

  testWidgets('go to page sheet hides search without a search handler', (
    tester,
  ) async {
    final navigation = PageNavigation.init()..clampToCount(pageCount);
    await tester.pumpWidget(
      _NavigationHarness(
        navigation: navigation,
        pageCount: pageCount,
        onPageChanged: (_) {},
      ),
    );

    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(GoToPageField), findsOneWidget);
    expect(find.byTooltip('Search'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
  });

  testWidgets('page buttons stay above the system navigation bar', (
    tester,
  ) async {
    const systemInset = 48.0;
    final navigation = PageNavigation.init()..clampToCount(pageCount);
    tester.view.padding = const FakeViewPadding(bottom: systemInset);
    tester.view.viewPadding = const FakeViewPadding(bottom: systemInset);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        // A rail layout: no bottom navigation bar absorbs the inset, and a
        // Scaffold hides it from its bottom sheet.
        home: Builder(
          builder: (context) => Scaffold(
            body: const SizedBox.expand(),
            bottomSheet: PageNavButton(
              pageNav: navigation,
              bottomPadding: MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ),
      ),
    );

    final screenBottom = tester.getBottomLeft(find.byType(Scaffold)).dy;
    final buttonBottom = tester.getBottomLeft(find.byType(TextButton).first).dy;
    expect(buttonBottom, lessThanOrEqualTo(screenBottom - systemInset));

    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
  });
}

class _NavigationHarness extends StatefulWidget {
  const _NavigationHarness({
    required this.navigation,
    required this.pageCount,
    required this.onPageChanged,
    this.onSearch,
  });

  final PageNavigation navigation;
  final int pageCount;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onSearch;

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
          bottomNavigationBar: PageNavButton(
            pageNav: widget.navigation,
            onSearch: widget.onSearch,
          ),
        ),
      ),
    );
  }
}
