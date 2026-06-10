import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/navigation_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/screens/narrative/components/menu_bar.dart';
import 'package:nahpu/screens/narrative/narrative_form.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/navigation.dart';
import 'package:nahpu/services/database/database.dart';

class NarrativeViewer extends ConsumerStatefulWidget {
  const NarrativeViewer({super.key});

  @override
  NarrativeViewerState createState() => NarrativeViewerState();
}

class NarrativeViewerState extends ConsumerState<NarrativeViewer> {
  bool isVisible = false;
  final PageNavigation _pageNav = PageNavigation.init();
  final TextEditingController _searchController = TextEditingController();
  int? _narrativeId;
  bool _loadedOnce = false;
  bool _isSearching = false;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _pageNav.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrativeServices = NarrativeServices(ref: ref);
    // Reconcile page/selection bookkeeping outside build (see site_view.dart).
    ref.listen(narrativeEntryProvider, (_, next) {
      next.whenData(_reconcile);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("Narrative"),
        actions: [
          _isSearching
              ? ExpandedSearchBar(
                  controller: _searchController,
                  focusNode: _focus,
                  hintText: 'Search narrative',
                  trailing: [
                    _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                narrativeServices.invalidateNarrative();
                              });
                            },
                            icon: const Icon(Icons.clear_rounded))
                        : const SizedBox.shrink(),
                  ],
                  onChanged: (value) {
                    ref.read(narrativeEntryProvider.notifier).search(value);
                  },
                )
              : const SizedBox.shrink(),
          !_isSearching
              ? IconButton(
                  onPressed: _narrativeId == null
                      ? null
                      : () {
                          setState(() {
                            _isSearching = true;
                            narrativeServices.invalidateNarrative();
                          });
                          _focus.requestFocus();
                        },
                  icon: const Icon(Icons.search),
                )
              : TextButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      narrativeServices.invalidateNarrative();
                    });
                  },
                  child: const Text('Cancel')),
          !_isSearching ? const NewNarrative() : const SizedBox.shrink(),
          NarrativeMenu(
            narrativeId: _narrativeId,
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ref.watch(narrativeEntryProvider).when(
                data: (narrativeEntries) {
                  if (narrativeEntries.isEmpty) {
                    return EmptyNarrative(isButtonVisible: !_isSearching);
                  }
                  return NarrativePages(
                    narrativeEntries: narrativeEntries,
                    isNavButtonVisible: isVisible,
                    pageNav: _pageNav,
                    onPageChanged: (index) {
                      setState(() {
                        _narrativeId = narrativeEntries[index].id;
                        _updatePageNav(index);
                      });
                    },
                  );
                },
                loading: () => const CommonProgressIndicator(),
                error: (error, stack) => Text(error.toString()),
              ),
        ),
      ),
      bottomSheet: Visibility(
        visible: isVisible,
        child: PageNavButton(
          pageNav: _pageNav,
        ),
      ),
    );
  }

  void _reconcile(List<NarrativeData> narrativeEntries) {
    if (!mounted) return;
    final count = narrativeEntries.length;
    final landIndex = _landingIndex(narrativeEntries);
    if (landIndex != null) {
      _pageNav.currentPage = landIndex + 1;
    }
    final index = _pageNav.clampToCount(count);
    setState(() {
      isVisible = count >= 2;
      if (count == 0) {
        _narrativeId = null;
      } else if (landIndex != null ||
          _narrativeId == null ||
          !narrativeEntries.any((narrative) => narrative.id == _narrativeId)) {
        _narrativeId = narrativeEntries[index].id;
      }
    });
    if (landIndex != null && !_pageNav.pageController.hasClients) {
      // First attach: a fresh controller opens the PageView directly on the
      // target page (initialPage only applies to a newly created position).
      _pageNav.openControllerAt(index);
    } else {
      // Attached PageView: a controller swap would re-attach the existing
      // scroll position unchanged, so jump after the rebuilt frame instead.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pageNav.clampController(index);
      });
    }
  }

  /// One-shot landing target for this refresh: a just-created record once it
  /// appears in the list, or the last record on this State's first data load
  /// (the old push-a-fresh-viewer-per-tab flow always landed at the end).
  int? _landingIndex(List<NarrativeData> narrativeEntries) {
    final firstLoad = !_loadedOnce;
    _loadedOnce = true;
    final pendingJump =
        ref.read(pendingRecordJumpProvider(RecordViewer.narrative));
    if (pendingJump != null) {
      final target =
          narrativeEntries.indexWhere((narrative) => narrative.id == pendingJump);
      if (target != -1) {
        ref
            .read(pendingRecordJumpProvider(RecordViewer.narrative).notifier)
            .state = null;
        return target;
      }
    }
    if (firstLoad && narrativeEntries.isNotEmpty) {
      return narrativeEntries.length - 1;
    }
    return null;
  }

  void _updatePageNav(int value) {
    _pageNav.currentPage = value + 1;
    _pageNav.updatePageNavigation();
    if (!_isSearching) {
      NarrativeServices(ref: ref).invalidateNarrative();
    }
  }
}

class NarrativePages extends StatelessWidget {
  const NarrativePages({
    super.key,
    required this.narrativeEntries,
    required this.pageNav,
    required this.isNavButtonVisible,
    required this.onPageChanged,
  });

  final List<NarrativeData> narrativeEntries;
  final PageNavigation pageNav;
  final bool isNavButtonVisible;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageNav.pageController,
      itemCount: narrativeEntries.length,
      itemBuilder: (context, index) {
        final narrativeCtr = _updateController(narrativeEntries, index);
        return PageViewer(
          pageNav: pageNav,
          isNavButtonVisible: isNavButtonVisible,
          child: NarrativeForm(
            narrativeId: narrativeEntries[index].id,
            narrativeCtr: narrativeCtr,
          ),
        );
      },
      onPageChanged: onPageChanged,
    );
  }

  NarrativeFormCtrModel _updateController(
      List<NarrativeData> narrativeEntries, int index) {
    // Prefer the separate `time` column if present; otherwise try
    // to parse a time from the existing date string for backwards
    // compatibility with old data.
    String? timeStd = narrativeEntries[index].time;
    if ((timeStd == null || timeStd.isEmpty) &&
        narrativeEntries[index].date != null) {
      final storedDate = narrativeEntries[index].date!;
      final parsed = DateTime.tryParse(storedDate);
      if (parsed != null) {
        final hh = parsed.hour.toString().padLeft(2, '0');
        final mm = parsed.minute.toString().padLeft(2, '0');
        final ss = parsed.second.toString().padLeft(2, '0');
        timeStd = '$hh:$mm:$ss';
      }
    }

    return NarrativeFormCtrModel(
      dateCtr: DateEditingController(date: narrativeEntries[index].date),
      timeCtr: TimeEditingController(time: timeStd),
      siteCtr: narrativeEntries[index].siteID,
      writerCtr: narrativeEntries[index].writerId,
      narrativeCtr:
          TextEditingController(text: narrativeEntries[index].narrative),
    );
  }
}

class EmptyNarrative extends StatelessWidget {
  const EmptyNarrative({
    super.key,
    required this.isButtonVisible,
  });

  final bool isButtonVisible;

  @override
  Widget build(BuildContext context) {
    return CommonEmptyForm(
      iconPath: 'assets/icons/agendas.svg',
      text: 'No narrative found',
      child: Visibility(
        visible: isButtonVisible,
        child: const NewNarrativeTextButton(),
      ),
    );
  }
}
