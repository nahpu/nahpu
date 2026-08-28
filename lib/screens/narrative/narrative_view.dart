import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/narrative/narrative_services.dart';
import 'package:nahpu/services/common/navigation_services.dart';
import 'package:nahpu/services/common/record_page_reconciler.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/screens/narrative/components/menu_bar.dart';
import 'package:nahpu/screens/narrative/narrative_form.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/navigation.dart';
import 'package:nahpu/services/database/database.dart';

class NarrativeViewer extends ConsumerStatefulWidget {
  const NarrativeViewer({super.key});

  @override
  NarrativeViewerState createState() => NarrativeViewerState();
}

class NarrativeViewerState extends ConsumerState<NarrativeViewer>
    with RecordPageReconciler<NarrativeData, NarrativeEntry, NarrativeViewer> {
  final TextEditingController _searchController = TextEditingController();
  int? _narrativeId;
  bool _isSearching = false;
  late FocusNode _focus;

  @override
  RecordViewer get recordViewer => RecordViewer.narrative;

  @override
  AsyncNotifierProvider<NarrativeEntry, List<NarrativeData>>
  get entryProvider => narrativeEntryProvider;

  @override
  Object recordIdOf(NarrativeData entry) => entry.id;

  @override
  void selectRecord(NarrativeData? entry) => _narrativeId = entry?.id;

  @override
  void invalidateEntries() => NarrativeServices(ref: ref).invalidateNarrative();

  @override
  bool get isSearching => _isSearching;

  @override
  void cancelSearch() {
    _isSearching = false;
    _searchController.clear();
  }

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrativeServices = NarrativeServices(ref: ref);
    listenEntries();
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
                            icon: const Icon(Icons.clear_rounded),
                          )
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
                  child: const Text('Cancel'),
                ),
          !_isSearching ? const NewNarrative() : const SizedBox.shrink(),
          NarrativeMenu(narrativeId: _narrativeId),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ref
              .watch(narrativeEntryProvider)
              .when(
                data: (narrativeEntries) {
                  if (narrativeEntries.isEmpty) {
                    return EmptyNarrative(isButtonVisible: !_isSearching);
                  }
                  return NarrativePages(
                    narrativeEntries: narrativeEntries,
                    isNavButtonVisible: isNavVisible,
                    pageNav: pageNav,
                    onPageChanged: (index) =>
                        handlePageChanged(index, narrativeEntries[index]),
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
      // Keyed by controller identity (see site_view.dart).
      key: ObjectKey(pageNav.pageController),
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
    List<NarrativeData> narrativeEntries,
    int index,
  ) {
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
      narrativeCtr: TextEditingController(
        text: narrativeEntries[index].narrative,
      ),
    );
  }
}

class EmptyNarrative extends StatelessWidget {
  const EmptyNarrative({super.key, required this.isButtonVisible});

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
