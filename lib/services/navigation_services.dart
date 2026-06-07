import 'package:flutter/material.dart';

class PageNavigation {
  PageNavigation({
    required this.currentPage,
    required this.pageCounts,
    required this.isLastPage,
    required this.isFirstPage,
    required this.pageController,
  });
  int currentPage;
  int pageCounts;
  bool isLastPage;
  bool isFirstPage;
  PageController pageController;

  factory PageNavigation.init() {
    return PageNavigation(
      currentPage: 0,
      pageCounts: 0,
      isLastPage: false,
      isFirstPage: false,
      pageController: PageController(),
    );
  }

  void updatePageNavigation() {
    if (currentPage == 1) {
      isFirstPage = true;
      isLastPage = false;
    } else if (currentPage == pageCounts) {
      isFirstPage = false;
      isLastPage = true;
    } else {
      isFirstPage = false;
      isLastPage = false;
    }
  }

  /// Reconciles the page bookkeeping after the underlying list changes
  /// (create/delete/search). Updates [pageCounts], clamps [currentPage] into
  /// the new range, recomputes the first/last flags, and returns the 0-based
  /// index that should be shown (0 when the list is empty).
  ///
  /// This replaces the old `updatePageController()`, which rebuilt the
  /// [PageController] on every data refresh (leaking controllers and resetting
  /// the view to the end). The controller created in [PageNavigation.init] now
  /// lives for the State's lifetime; callers move to the clamped page via
  /// [clampController] from a post-frame callback instead.
  int clampToCount(int count) {
    pageCounts = count;
    if (count == 0) {
      // Empty list: no page is first or last, and the nav bar is hidden.
      currentPage = 0;
      isFirstPage = false;
      isLastPage = false;
      return 0;
    }
    if (currentPage < 1) {
      currentPage = 1;
    } else if (currentPage > count) {
      currentPage = count;
    }
    updatePageNavigation();
    return currentPage - 1;
  }

  /// Jumps the live [PageController] to [index] if it isn't already there.
  /// Safe to call from a post-frame callback after the list shrinks.
  void clampController(int index) {
    if (pageController.hasClients &&
        (pageController.page?.round() ?? 0) != index) {
      pageController.jumpToPage(index);
    }
  }

  void dispose() {
    pageController.dispose();
  }
}
