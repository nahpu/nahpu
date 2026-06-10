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

  /// Whether the attached viewport can currently reach [index]. False while
  /// the [PageView] still has the pre-refresh (smaller) item count laid out.
  bool _canReach(int index) {
    final position = pageController.position;
    if (!position.hasContentDimensions) return false;
    final pageSize =
        position.viewportDimension * pageController.viewportFraction;
    if (pageSize <= 0) return false;
    // Tolerance absorbs floating-point error in the extent math.
    return index * pageSize <= position.maxScrollExtent + 0.001;
  }

  /// Jumps the live [PageController] to [index] if it isn't already there.
  /// Safe to call from a post-frame callback after the list shrinks. Never
  /// jumps to a page the laid-out extent cannot reach — that clamps to the
  /// old last page and corrupts the bookkeeping via a spurious onPageChanged.
  void clampController(int index) {
    if (pageController.hasClients &&
        _canReach(index) &&
        (pageController.page?.round() ?? 0) != index) {
      pageController.jumpToPage(index);
    }
  }

  /// Replaces [pageController] with a fresh one opened at [index].
  ///
  /// `initialPage` is only applied when a [PageView] creates its scroll
  /// position, so the viewer's [PageView] must be keyed by the controller
  /// instance (`ObjectKey(pageNav.pageController)`): the swap then rebuilds
  /// it as a new element whose fresh position starts exactly on the target
  /// page, with no `onPageChanged` fired. Jumping the live controller
  /// instead is unreliable here — a landing is requested by a data listener
  /// while the refreshed (grown) list may not be laid out yet, and a jump
  /// against the stale extent clamps to the old last page and corrupts the
  /// page bookkeeping via a spurious `onPageChanged`. `keepPage: false`
  /// stops [PageStorage] from restoring the pre-landing page. The previous
  /// controller is disposed once the rebuild has detached it.
  void openControllerAt(int index) {
    final previous = pageController;
    pageController = PageController(initialPage: index, keepPage: false);
    _disposeWhenDetached(previous);
  }

  void _disposeWhenDetached(PageController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        // The rebuild that swaps in the new controller hasn't run yet; retry.
        _disposeWhenDetached(controller);
      } else {
        controller.dispose();
      }
    });
  }

  void dispose() {
    pageController.dispose();
  }
}
