import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/features.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/specimens/shared/search.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
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
    return FalseWillPop(
        child: Scaffold(
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
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
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
                  setState(() {
                    isVisible = false;
                    _specimenUuid = null;
                  });

                  return const EmptySpecimen(isButtonVisible: true);
                } else {
                  int specimenSize = specimenEntry.length;
                  setState(() {
                    if (specimenSize >= 2) {
                      isVisible = true;
                    } else {
                      isVisible = false;
                    }
                    _pageNav.pageCounts = specimenSize;
                    _pageNav.updatePageController();
                  });
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
                }
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
      bottomNavigationBar: const ProjectBottomNavbar(),
    ));
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
