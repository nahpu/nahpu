import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/navigation_services.dart';

void main() {
  group('PageNavigation.clampToCount', () {
    test('first load from a fresh state shows the first page', () {
      final nav = PageNavigation.init();
      final index = nav.clampToCount(3);
      expect(nav.pageCounts, 3);
      expect(nav.currentPage, 1);
      expect(index, 0); // 0-based index of the first page
      expect(nav.isFirstPage, isTrue);
      expect(nav.isLastPage, isFalse);
    });

    test('a page in the middle of the range is left untouched', () {
      final nav = PageNavigation.init();
      nav.currentPage = 2;
      final index = nav.clampToCount(3);
      expect(nav.currentPage, 2);
      expect(index, 1);
      expect(nav.isFirstPage, isFalse);
      expect(nav.isLastPage, isFalse);
    });

    test('shrinking the list clamps currentPage to the new last page', () {
      final nav = PageNavigation.init();
      nav.currentPage = 5;
      final index = nav.clampToCount(3);
      expect(nav.pageCounts, 3);
      expect(nav.currentPage, 3);
      expect(index, 2);
      expect(nav.isFirstPage, isFalse);
      expect(nav.isLastPage, isTrue);
    });

    test('an empty list resets to page 0 and shows index 0', () {
      final nav = PageNavigation.init();
      nav.currentPage = 4;
      final index = nav.clampToCount(0);
      expect(nav.pageCounts, 0);
      expect(nav.currentPage, 0);
      expect(index, 0);
      expect(nav.isFirstPage, isFalse);
      expect(nav.isLastPage, isFalse);
    });

    test('the last page sets isLastPage', () {
      final nav = PageNavigation.init();
      nav.currentPage = 3;
      nav.clampToCount(3);
      expect(nav.isFirstPage, isFalse);
      expect(nav.isLastPage, isTrue);
    });
  });
}
