import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/common/navigation_services.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/record_sort.dart';

/// Page and selection bookkeeping shared by the four top-level record viewers.
///
/// Owns [pageNav] and [isNavVisible], seeds them from the entry provider's
/// cached list the moment the `State` is created, keeps them reconciled with
/// every later emission, and remembers the record on screen so a `State`
/// recreated by a rotation or a breakpoint resize lands back on it.
///
/// The seed is what fixes "Page 0 of 0". [listenEntries] only fires on a
/// provider *emission*, and the entry providers are `autoDispose` but stay
/// cached across a `State` swap, so a recreated viewer would otherwise never
/// reconcile: the records would render from `ref.watch` while the page counter
/// and the nav bar stayed at their initial zero.
mixin RecordPageReconciler<
  T,
  N extends AsyncNotifier<List<T>>,
  W extends ConsumerStatefulWidget
>
    on ConsumerState<W> {
  /// Page bookkeeping and the live [PageController]. Recreated with the
  /// `State`; [landingIndex] is what puts it back where the user was.
  final PageNavigation pageNav = PageNavigation.init();

  /// Whether the record list is long enough to warrant the page nav bar.
  bool isNavVisible = false;

  bool _loadedOnce = false;
  bool _isSeeding = false;
  Object? _selectedId;

  // --- Host contract -------------------------------------------------------

  /// Which viewer this is, for the per-viewer providers.
  RecordViewer get recordViewer;

  /// The viewer's record list provider.
  AsyncNotifierProvider<N, List<T>> get entryProvider;

  /// The record's stable identity: an `int` id, or a `String` uuid.
  Object recordIdOf(T entry);

  /// Assigns the host's own selection fields (the ones its menu bar reads).
  /// Called from inside this mixin's `setState`, so it must not call
  /// `setState` itself.
  void selectRecord(T? entry);

  /// Re-fetches the record list — `ref.invalidate`, or the matching service
  /// call for viewers that route invalidation through a service.
  void invalidateEntries();

  /// Whether the host's search bar is open. Viewers without search keep the
  /// default.
  bool get isSearching => false;

  /// Closes the host's search bar. Viewers without search keep the default.
  void cancelSearch() {}

  // --- Provided ------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _seedFromCache();
  }

  @override
  void dispose() {
    pageNav.dispose();
    super.dispose();
  }

  /// Registers the reconcile listener. Call once at the top of `build`.
  void listenEntries() {
    ref.listen(entryProvider, (_, next) {
      // An in-progress refresh still carries the previous list; reconciling
      // against it would consume landing requests with stale data.
      if (next.isLoading) return;
      next.whenData(reconcile);
    });
  }

  /// Reconciles page and selection bookkeeping against [entries].
  void reconcile(List<T> entries) {
    if (!mounted) return;
    _applyReconcile(entries);
  }

  /// Wire this to `PageView.onPageChanged`.
  void handlePageChanged(int index, T entry) {
    setState(() {
      _selectedId = recordIdOf(entry);
      selectRecord(entry);
      _rememberSelection();
      pageNav.currentPage = index + 1;
      pageNav.updatePageNavigation();
      if (!isSearching) invalidateEntries();
    });
  }

  /// The index to land on for this refresh, or null to stay put.
  ///
  /// In precedence order: a just-created record; on this `State`'s first
  /// reconcile, the record it was showing before it was recreated; and
  /// otherwise the record the user is reading, if the list moved it.
  @protected
  int? landingIndex(List<T> entries) {
    final firstLoad = !_loadedOnce;
    _loadedOnce = true;

    // Skipped while seeding: consuming the request would need a provider
    // write during `initState`, and a pending request means an emission is
    // already on its way for [listenEntries] to handle properly.
    if (!_isSeeding) {
      final pendingJump = ref.read(pendingRecordJumpProvider(recordViewer));
      if (pendingJump != null) {
        final target = entries.indexWhere(
          (entry) => recordIdOf(entry) == pendingJump,
        );
        if (target != -1) {
          ref
              .read(pendingRecordJumpProvider(recordViewer).notifier)
              .updateState(null);
          return target;
        }
      }
    }

    if (entries.isEmpty) return null;

    if (firstLoad) {
      // Only on the first reconcile: consulting the memory on every emission
      // would fight the refetch that each page change triggers, swapping the
      // controller out from under the user mid-swipe.
      final remembered = ref.read(lastViewedRecordProvider(recordViewer));
      if (remembered != null) {
        final target = entries.indexWhere(
          (entry) => recordIdOf(entry) == remembered,
        );
        if (target != -1) return target;
      }

      // Nothing to restore. In insertion order the newest record is the last
      // page and the user expects to land there; under any other sort its
      // position is arbitrary, so the first page is the least surprising.
      return isDefaultSortOrder ? entries.length - 1 : 0;
    }

    // The refresh may have reordered the list rather than only grown or shrunk
    // it — changing the sort does exactly that. Follow the record the user is
    // reading to its new page instead of holding the page number and silently
    // swapping the record underneath. A page change updates the selection and
    // the page number together before it refetches, so an ordinary swipe finds
    // the record already where it belongs and lands nothing.
    final selectedId = _selectedId;
    if (selectedId != null) {
      final target = entries.indexWhere(
        (entry) => recordIdOf(entry) == selectedId,
      );
      if (target != -1 && target != pageNav.currentPage - 1) return target;
    }
    return null;
  }

  /// Whether the viewer is showing records in plain insertion order.
  @protected
  bool get isDefaultSortOrder =>
      ref.read(recordSortProvider(recordViewer)).isDefault;

  // --- Internals -----------------------------------------------------------

  /// Reconciles against the entry provider's already-cached list.
  ///
  /// Runs during `initState`, so it assigns fields directly instead of calling
  /// `setState` — every field it touches is read by the first `build`, which
  /// has not happened yet. That leaves no frame showing "Page 0 of 0".
  void _seedFromCache() {
    final entries = ref.read(entryProvider);
    // Still loading, or errored: [listenEntries] picks it up from here.
    if (entries.isLoading) return;
    final value = entries.value;
    if (value == null) return;
    _isSeeding = true;
    try {
      _applyReconcile(value);
    } finally {
      _isSeeding = false;
    }
  }

  void _applyReconcile(List<T> entries) {
    final count = entries.length;
    final landIndex = landingIndex(entries);
    if (landIndex != null) {
      pageNav.currentPage = landIndex + 1;
    }
    final index = pageNav.clampToCount(count);

    void mutate() {
      if (landIndex != null && isSearching) cancelSearch();
      isNavVisible = count >= 2;
      if (count == 0) {
        _selectedId = null;
        selectRecord(null);
        _rememberSelection();
      } else if (landIndex != null ||
          _selectedId == null ||
          !entries.any((entry) => recordIdOf(entry) == _selectedId)) {
        // Landed on a one-shot target, no selection yet, or the selected
        // record was deleted; point the menu at the visible page.
        _selectedId = recordIdOf(entries[index]);
        selectRecord(entries[index]);
        _rememberSelection();
      }
    }

    _isSeeding ? mutate() : setState(mutate);

    if (landIndex != null) {
      // Keyed controller swap; a jump on the live controller would race the
      // refreshed list's layout (see openControllerAt).
      pageNav.openControllerAt(index);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) pageNav.clampController(index);
      });
    }
  }

  void _rememberSelection() {
    // Skipped while seeding: writing a provider during `initState` is not
    // allowed, and the seed only ever restores what the memory already holds.
    if (_isSeeding) return;
    ref
        .read(lastViewedRecordProvider(recordViewer).notifier)
        .updateState(_selectedId);
  }
}
