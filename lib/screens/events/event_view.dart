import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/navigation_services.dart';
import 'package:nahpu/services/common/record_page_reconciler.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/screens/events/event_form.dart';
import 'package:nahpu/screens/events/components/menu_bar.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/navigation.dart';

class CollEventViewer extends ConsumerStatefulWidget {
  const CollEventViewer({super.key});

  @override
  CollEventViewerState createState() => CollEventViewerState();
}

class CollEventViewerState extends ConsumerState<CollEventViewer>
    with RecordPageReconciler<CollEventData, CollEventEntry, CollEventViewer> {
  final TextEditingController _searchController = TextEditingController();
  int? _collEvenId;
  bool _isSearching = false;
  final FocusNode _focus = FocusNode();

  @override
  RecordViewer get recordViewer => RecordViewer.collEvent;

  @override
  AsyncNotifierProvider<CollEventEntry, List<CollEventData>>
  get entryProvider => collEventEntryProvider;

  @override
  Object recordIdOf(CollEventData entry) => entry.id;

  @override
  void selectRecord(CollEventData? entry) => _collEvenId = entry?.id;

  @override
  void invalidateEntries() => CollEventServices(ref: ref).invalidateCollEvent();

  @override
  bool get isSearching => _isSearching;

  @override
  void cancelSearch() {
    _isSearching = false;
    _searchController.clear();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = CollEventServices(ref: ref);
    listenEntries();
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
                            icon: const Icon(Icons.clear_rounded),
                          )
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
                  icon: const Icon(Icons.search),
                )
              : TextButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      services.invalidateCollEvent();
                    });
                  },
                  child: const Text("Cancel"),
                ),
          !_isSearching ? const NewCollEvents() : const SizedBox.shrink(),
          CollEventMenu(collEventId: _collEvenId),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ref
              .watch(collEventEntryProvider)
              .when(
                data: (collEventEntries) {
                  if (collEventEntries.isEmpty) {
                    return EmptyCollEvent(isButtonVisible: !_isSearching);
                  }
                  return CollEventPages(
                    collEventEntries: collEventEntries,
                    pageNav: pageNav,
                    isNavButtonVisible: isNavVisible,
                    onPageChanged: (index) =>
                        handlePageChanged(index, collEventEntries[index]),
                  );
                },
                loading: () => const CommonProgressIndicator(),
                error: (error, stack) => Text(error.toString()),
              ),
        ),
      ),
      bottomSheet: Visibility(
        visible: isNavVisible,
        child: PageNavButton(pageNav: pageNav),
      ),
    );
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
      // Keyed by controller identity (see site_view.dart).
      key: ObjectKey(pageNav.pageController),
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
