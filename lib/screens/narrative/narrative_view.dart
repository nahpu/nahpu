import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/localization/l10n.dart';
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
    final l10n = context.l10n;
    final narrativeServices = NarrativeServices(ref: ref);
    listenEntries();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.narrativeTitle),
        actions: [
          _isSearching
              ? ExpandedSearchBar(
                  controller: _searchController,
                  focusNode: _focus,
                  hintText: l10n.narrativeSearchHint,
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
                  onPressed: _narrativeId == null ? null : _startSearch,
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
                  child: Text(l10n.commonCancel),
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
        child: PageNavButton(
          pageNav: pageNav,
          onSearch: _narrativeId == null ? null : _startSearch,
          bottomPadding: MediaQuery.paddingOf(context).bottom,
        ),
      ),
    );
  }

  /// Opens the search bar, or focuses it when it is already open.
  void _startSearch() {
    if (!_isSearching) {
      setState(() {
        _isSearching = true;
        NarrativeServices(ref: ref).invalidateNarrative();
      });
    }
    _focus.requestFocus();
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
        final narrativeCtr = narrativeFormController(narrativeEntries[index]);
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
}

/// Form controllers filled from [narrative].
NarrativeFormCtrModel narrativeFormController(NarrativeData narrative) {
  // Prefer the separate `time` column if present; otherwise try
  // to parse a time from the existing date string for backwards
  // compatibility with old data.
  String? timeStd = narrative.time;
  if ((timeStd == null || timeStd.isEmpty) && narrative.date != null) {
    final parsed = DateTime.tryParse(narrative.date!);
    if (parsed != null) {
      final hh = parsed.hour.toString().padLeft(2, '0');
      final mm = parsed.minute.toString().padLeft(2, '0');
      final ss = parsed.second.toString().padLeft(2, '0');
      timeStd = '$hh:$mm:$ss';
    }
  }

  return NarrativeFormCtrModel(
    dateCtr: DateEditingController(date: narrative.date),
    timeCtr: TimeEditingController(time: timeStd),
    siteCtr: narrative.siteID,
    writerCtr: narrative.writerId,
    narrativeCtr: TextEditingController(text: narrative.narrative),
  );
}

/// One narrative's form on its own page, opened from outside the narrative
/// viewer.
class NarrativeFormView extends ConsumerStatefulWidget {
  const NarrativeFormView({super.key, required this.narrativeId});

  final int narrativeId;

  @override
  NarrativeFormViewState createState() => NarrativeFormViewState();
}

class NarrativeFormViewState extends ConsumerState<NarrativeFormView> {
  /// Disposed by [NarrativeForm].
  NarrativeFormCtrModel? _narrativeCtr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.narrativeRecordTitle)),
      body: SafeArea(
        child: ref
            .watch(narrativeEntryProvider)
            .when(
              data: (entries) {
                final narrative = entries
                    .where((n) => n.id == widget.narrativeId)
                    .firstOrNull;
                if (narrative == null) {
                  return const EmptyNarrative(isButtonVisible: false);
                }
                // Built once, so typing isn't reset when the list reloads.
                final narrativeCtr = _narrativeCtr ??= narrativeFormController(
                  narrative,
                );
                return NarrativeForm(
                  key: ValueKey(narrative.id),
                  narrativeId: narrative.id,
                  narrativeCtr: narrativeCtr,
                );
              },
              loading: () => const CommonProgressIndicator(),
              error: (error, _) => Text(error.toString()),
            ),
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
      text: context.l10n.narrativeEmpty,
      child: Visibility(
        visible: isButtonVisible,
        child: const NewNarrativeTextButton(),
      ),
    );
  }
}
