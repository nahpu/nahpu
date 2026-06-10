import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/navigation_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/screens/events/event_form.dart';
import 'package:nahpu/screens/events/components/menu_bar.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/navigation.dart';

class CollEventViewer extends ConsumerStatefulWidget {
  const CollEventViewer({super.key});

  @override
  CollEventViewerState createState() => CollEventViewerState();
}

class CollEventViewerState extends ConsumerState<CollEventViewer> {
  bool _isVisible = false;
  final PageNavigation _pageNav = PageNavigation.init();
  final TextEditingController _searchController = TextEditingController();
  int? _collEvenId;
  bool _isSearching = false;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageNav.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = CollEventServices(ref: ref);
    // Reconcile page/selection bookkeeping outside build (see site_view.dart).
    ref.listen(collEventEntryProvider, (_, next) {
      next.whenData(_reconcile);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        actions: [
          _isSearching
              ? ExpandedSearchBar(
                  controller: _searchController,
                  focusNode: _focus,
                  hintText: 'Search events',
                  trailing: [
                    _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                services.invalidateCollEvent();
                              });
                            },
                            icon: const Icon(Icons.clear_rounded))
                        : const SizedBox.shrink(),
                  ],
                  onChanged: (value) {
                    ref.read(collEventEntryProvider.notifier).search(value);
                  },
                )
              : const SizedBox.shrink(),
          !_isSearching
              ? IconButton(
                  onPressed: _collEvenId == null
                      ? null
                      : () {
                          setState(() {
                            _isSearching = true;
                            services.invalidateCollEvent();
                          });
                          _focus.requestFocus();
                        },
                  icon: const Icon(Icons.search))
              : TextButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      services.invalidateCollEvent();
                    });
                  },
                  child: const Text("Cancel")),
          !_isSearching ? const NewCollEvents() : const SizedBox.shrink(),
          CollEventMenu(
            collEventId: _collEvenId,
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ref.watch(collEventEntryProvider).when(
                data: (collEventEntries) {
                  if (collEventEntries.isEmpty) {
                    return EmptyCollEvent(isButtonVisible: !_isSearching);
                  }
                  return CollEventPages(
                    collEventEntries: collEventEntries,
                    pageNav: _pageNav,
                    isNavButtonVisible: _isVisible,
                    onPageChanged: (index) {
                      setState(() {
                        _collEvenId = collEventEntries[index].id;
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
        visible: _isVisible,
        child: PageNavButton(
          pageNav: _pageNav,
        ),
      ),
    );
  }

  void _reconcile(List<CollEventData> collEventEntries) {
    if (!mounted) return;
    final count = collEventEntries.length;
    final index = _pageNav.clampToCount(count);
    setState(() {
      _isVisible = count >= 2;
      if (count == 0) {
        _collEvenId = null;
      } else if (_collEvenId == null ||
          !collEventEntries.any((event) => event.id == _collEvenId)) {
        _collEvenId = collEventEntries[index].id;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pageNav.clampController(index);
    });
  }

  void _updatePageNav(int value) {
    setState(() {
      _pageNav.currentPage = value + 1;
      _pageNav.updatePageNavigation();
      if (!_isSearching) {
        CollEventServices(ref: ref).invalidateCollEvent();
      }
    });
  }
}

class CollEventPages extends StatelessWidget {
  const CollEventPages({
    super.key,
    required this.collEventEntries,
    required this.pageNav,
    required this.onPageChanged,
    required this.isNavButtonVisible,
  });

  final List<CollEventData> collEventEntries;
  final PageNavigation pageNav;
  final bool isNavButtonVisible;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageNav.pageController,
      itemCount: collEventEntries.length,
      itemBuilder: (context, index) {
        final collEventForm = _updateController(collEventEntries[index]);

        return PageViewer(
          pageNav: pageNav,
          isNavButtonVisible: isNavButtonVisible,
          child: CollEventForm(
            id: collEventEntries[index].id,
            collEventCtr: collEventForm,
          ),
        );
      },
      onPageChanged: onPageChanged,
    );
  }

  CollEventFormCtrModel _updateController(CollEventData collEventData) {
    return CollEventFormCtrModel.fromData(collEventData);
  }
}

class EmptyCollEvent extends StatelessWidget {
  const EmptyCollEvent({super.key, required this.isButtonVisible});

  final bool isButtonVisible;

  @override
  Widget build(BuildContext context) {
    return CommonEmptyForm(
      iconPath: 'assets/icons/planner.svg',
      text: "No collecting event found",
      child: Visibility(
        visible: isButtonVisible,
        child: const NewCollEventTextButton(),
      ),
    );
  }
}
