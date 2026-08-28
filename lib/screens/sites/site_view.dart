import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/common/navigation_services.dart';
import 'package:nahpu/services/common/record_page_reconciler.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/navigation.dart';
import 'package:nahpu/screens/sites/components/menu_bar.dart';
import 'package:nahpu/screens/sites/site_form.dart';
import 'package:nahpu/services/types/geography.dart';

enum MenuSelection { newSite, pdfExport, deleteRecords, deleteAllRecords }

class SiteViewer extends ConsumerStatefulWidget {
  const SiteViewer({super.key});

  @override
  SiteViewerState createState() => SiteViewerState();
}

class SiteViewerState extends ConsumerState<SiteViewer>
    with RecordPageReconciler<SiteRecord, SiteEntry, SiteViewer> {
  final TextEditingController _searchController = TextEditingController();
  int? _siteId;
  bool _isSearching = false;
  late FocusNode _focus;

  @override
  RecordViewer get recordViewer => RecordViewer.site;

  @override
  AsyncNotifierProvider<SiteEntry, List<SiteRecord>> get entryProvider =>
      siteEntryProvider;

  @override
  Object recordIdOf(SiteRecord entry) => entry.id;

  @override
  void selectRecord(SiteRecord? entry) => _siteId = entry?.id;

  @override
  void invalidateEntries() => ref.invalidate(siteEntryProvider);

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
    final siteEntries = ref.watch(siteEntryProvider);
    listenEntries();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sites"),
        automaticallyImplyLeading: false,
        actions: [
          _isSearching
              ? ExpandedSearchBar(
                  controller: _searchController,
                  focusNode: _focus,
                  hintText: 'Search sites',
                  trailing: [
                    _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                ref.invalidate(siteEntryProvider);
                              });
                            },
                            icon: const Icon(Icons.clear_rounded),
                          )
                        : const SizedBox.shrink(),
                  ],
                  onChanged: (value) {
                    ref.read(siteEntryProvider.notifier).search(value);
                  },
                )
              : const SizedBox.shrink(),
          !_isSearching
              ? IconButton(
                  onPressed: _siteId == null
                      ? null
                      : () {
                          setState(() {
                            _isSearching = true;
                            ref.invalidate(siteEntryProvider);
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
                      ref.invalidate(siteEntryProvider);
                    });
                  },
                  child: const Text('Cancel'),
                ),
          !_isSearching ? const NewSite() : const SizedBox.shrink(),
          SiteMenu(siteId: _siteId),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: siteEntries.when(
            data: (siteEntries) {
              if (siteEntries.isEmpty) {
                return EmptySite(isButtonVisible: !_isSearching);
              }
              return SitePages(
                siteEntries: siteEntries,
                pageNav: pageNav,
                isNavButtonVisible: isNavVisible,
                onPageChanged: (index) =>
                    handlePageChanged(index, siteEntries[index]),
              );
            },
            loading: () {
              return const CommonProgressIndicator();
            },
            error: (error, stackTrace) {
              return Text(error.toString());
            },
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

class SitePages extends ConsumerWidget {
  const SitePages({
    super.key,
    required this.siteEntries,
    required this.pageNav,
    required this.isNavButtonVisible,
    required this.onPageChanged,
  });

  final List<SiteRecord> siteEntries;
  final PageNavigation pageNav;
  final bool isNavButtonVisible;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageView.builder(
      // Keyed by controller identity so openControllerAt's swap takes effect.
      key: ObjectKey(pageNav.pageController),
      controller: pageNav.pageController,
      itemCount: siteEntries.length,
      itemBuilder: (context, index) {
        final site = siteEntries[index];
        return ref
            .watch(siteAttributeProvider(site.id))
            .when(
              data: (attribute) {
                final siteForm = SiteFormCtrModel.fromData(site, attribute);
                return PageViewer(
                  pageNav: pageNav,
                  isNavButtonVisible: isNavButtonVisible,
                  child: SiteForm(id: site.id, siteFormCtr: siteForm),
                );
              },
              loading: () => const CommonProgressIndicator(),
              error: (error, _) => Text(error.toString()),
            );
      },
      onPageChanged: onPageChanged,
    );
  }
}

class EmptySite extends StatelessWidget {
  const EmptySite({super.key, required this.isButtonVisible});

  final bool isButtonVisible;

  @override
  Widget build(BuildContext context) {
    return CommonEmptyForm(
      iconPath: 'assets/icons/forest.svg',
      text: 'No site found',
      child: Visibility(
        visible: isButtonVisible,
        child: const NewSiteTextButton(),
      ),
    );
  }
}
