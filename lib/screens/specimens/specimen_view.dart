import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/features.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/specimens/shared/search.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/navigation.dart';
import 'package:nahpu/screens/specimens/shared/menu_bar.dart';
import 'package:nahpu/screens/specimens/specimen_form.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/navigation_services.dart';

class SpecimenViewer extends ConsumerStatefulWidget {
  const SpecimenViewer({super.key});

  @override
  SpecimenViewerState createState() => SpecimenViewerState();
}

class SpecimenViewerState extends ConsumerState<SpecimenViewer> {
  bool isVisible = false;
  final PageNavigation _pageNav = PageNavigation.init();
  String? _specimenUuid;
  bool _loadedOnce = false;
  CatalogFmt? _catalogFmt;
  TaxonData taxonomy = TaxonData();
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
    // Reconcile page/selection bookkeeping outside build (see site_view.dart).
    ref.listen(specimenEntryProvider, (_, next) {
      // Skip refresh emissions: an in-progress refresh still carries the
      // previous list (see site_view.dart).
      if (next.isLoading) return;
      next.whenData(_reconcile);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Specimen Records",
        ),
        actions: [
          IconButton(
            onPressed: _specimenUuid == null
                ? null
                : () async {
                    final specimenData =
                        await SpecimenServices(ref: ref).getAllSpecimens();
                    if (context.mounted) {
                      // Push the search screen on top of the shell; its Cancel
                      // button pops back to this still-mounted viewer.
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            SpecimenSearchView(specimenData: specimenData),
                      ));
                    }
                  },
            icon: const Icon(Icons.search),
          ),
          const NewSpecimens(),
          SpecimenMenu(
            specimenUuid: _specimenUuid,
            catalogFmt: _catalogFmt,
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ref.watch(specimenEntryProvider).when(
              data: (specimenEntry) {
                if (specimenEntry.isEmpty) {
                  return const EmptySpecimen(isButtonVisible: true);
                }
                return SpecimenPages(
                  pageNav: _pageNav,
                  isNavButtonVisible: isVisible,
                  specimenEntry: specimenEntry,
                  onPageChanged: (index) {
                    setState(() {
                      _specimenUuid = specimenEntry[index].uuid;
                      _catalogFmt = matchTaxonGroupToCatFmt(
                          specimenEntry[index].taxonGroup);
                      _updatePageNav(index);
                    });
                  },
                );
              },
              loading: () => const CommonProgressIndicator(),
              error: (error, stack) => Text(error.toString()),
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

  void _reconcile(List<SpecimenData> specimenEntry) {
    if (!mounted) return;
    final count = specimenEntry.length;
    final landIndex = _landingIndex(specimenEntry);
    if (landIndex != null) {
      _pageNav.currentPage = landIndex + 1;
    }
    final index = _pageNav.clampToCount(count);
    setState(() {
      isVisible = count >= 2;
      if (count == 0) {
        _specimenUuid = null;
        _catalogFmt = null;
      } else if (landIndex != null ||
          _specimenUuid == null ||
          !specimenEntry.any((specimen) => specimen.uuid == _specimenUuid)) {
        _specimenUuid = specimenEntry[index].uuid;
        _catalogFmt = matchTaxonGroupToCatFmt(specimenEntry[index].taxonGroup);
      }
    });
    if (landIndex != null) {
      // The PageView is keyed by the controller, so this rebuilds it with a
      // fresh scroll position that starts exactly on the target page — a
      // jump on the live controller would race the refreshed list's layout.
      _pageNav.openControllerAt(index);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pageNav.clampController(index);
      });
    }
  }

  /// One-shot landing target for this refresh: a just-created record once it
  /// appears in the list, or the last record on this State's first data load
  /// (the old push-a-fresh-viewer-per-tab flow always landed at the end).
  int? _landingIndex(List<SpecimenData> specimenEntry) {
    final firstLoad = !_loadedOnce;
    _loadedOnce = true;
    final pendingJump =
        ref.read(pendingRecordJumpProvider(RecordViewer.specimen));
    if (pendingJump != null) {
      final target =
          specimenEntry.indexWhere((specimen) => specimen.uuid == pendingJump);
      if (target != -1) {
        ref
            .read(pendingRecordJumpProvider(RecordViewer.specimen).notifier)
            .state = null;
        return target;
      }
    }
    if (firstLoad && specimenEntry.isNotEmpty) {
      return specimenEntry.length - 1;
    }
    return null;
  }

  void _updatePageNav(int value) {
    setState(() {
      _pageNav.currentPage = value + 1;
      _pageNav.updatePageNavigation();

      ref.invalidate(specimenEntryProvider);
    });
  }
}

class SearchOptionScreen extends StatelessWidget {
  const SearchOptionScreen({
    super.key,
    required this.selectedSearchValue,
    required this.onSelected,
  });

  final int selectedSearchValue;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text(
          'Search Options',
          textAlign: TextAlign.center,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpecimenSearchChips(
                selectedValue: selectedSearchValue,
                onSelected: onSelected,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              )
            ],
          ),
        ));
  }
}

class SpecimenPages extends StatelessWidget {
  const SpecimenPages({
    super.key,
    required this.onPageChanged,
    required this.specimenEntry,
    required this.isNavButtonVisible,
    required this.pageNav,
  });

  final void Function(int) onPageChanged;
  final List<SpecimenData> specimenEntry;
  final bool isNavButtonVisible;
  final PageNavigation pageNav;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      // Keyed by controller identity so openControllerAt lands on its page
      // via a fresh scroll position (see site_view.dart).
      key: ObjectKey(pageNav.pageController),
      controller: pageNav.pageController,
      itemCount: specimenEntry.length,
      itemBuilder: (context, index) {
        CatalogFmt catalogFmt =
            matchTaxonGroupToCatFmt(specimenEntry[index].taxonGroup);
        final specimenFormCtr = _updateController(specimenEntry[index]);
        return PageViewer(
          pageNav: pageNav,
          isNavButtonVisible: isNavButtonVisible,
          child: SpecimenForm(
            specimenUuid: specimenEntry[index].uuid,
            specimenCtr: specimenFormCtr,
            catalogFmt: catalogFmt,
          ),
        );
      },
      onPageChanged: onPageChanged,
    );
  }

  SpecimenFormCtrModel _updateController(SpecimenData specimenEntry) {
    return SpecimenFormCtrModel.fromData(specimenEntry);
  }
}

class SpecimenFormView extends ConsumerStatefulWidget {
  const SpecimenFormView({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  SpecimenFormViewState createState() => SpecimenFormViewState();
}

class SpecimenFormViewState extends ConsumerState<SpecimenFormView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specimen Record'),
      ),
      body: SafeArea(
          child: ref.watch(specimenEntryProvider).when(
                data: (specimenEntry) {
                  if (specimenEntry.isEmpty) {
                    return const EmptySpecimen(isButtonVisible: false);
                  } else {
                    final specimen = specimenEntry.firstWhere(
                        (specimen) => specimen.uuid == widget.specimenUuid);
                    CatalogFmt catalogFmt =
                        matchTaxonGroupToCatFmt(specimen.taxonGroup);
                    final specimenFormCtr = _updateController(specimen);
                    return SpecimenForm(
                      specimenUuid: specimen.uuid,
                      specimenCtr: specimenFormCtr,
                      catalogFmt: catalogFmt,
                    );
                  }
                },
                loading: () => const CommonProgressIndicator(),
                error: (error, stack) => Text(error.toString()),
              )),
    );
  }

  SpecimenFormCtrModel _updateController(SpecimenData specimenEntry) {
    return SpecimenFormCtrModel.fromData(specimenEntry);
  }
}

class EmptySpecimen extends ConsumerWidget {
  const EmptySpecimen({
    super.key,
    required this.isButtonVisible,
  });

  final bool isButtonVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: CommonEmptyForm(
        iconPath: SpecimenServices(ref: ref).getIconPath(),
        text: 'No specimen found',
        child: Visibility(
          visible: isButtonVisible,
          child: const NewSpecimensTextButton(),
        ),
      ),
    );
  }
}
