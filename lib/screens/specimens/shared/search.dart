import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/shared/navigation.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/navigation_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';

class SpecimenSearchView extends ConsumerStatefulWidget {
  const SpecimenSearchView({super.key, required this.specimenData});

  final List<SpecimenData> specimenData;

  @override
  SpecimenSearchViewState createState() => SpecimenSearchViewState();
}

class SpecimenSearchViewState extends ConsumerState<SpecimenSearchView> {
  bool _isVisible = false;
  final PageNavigation _pageNav = PageNavigation.init();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focus = FocusNode();
  int _selectedSearchValue = 0;
  List<SpecimenData> _filteredSpecimenData = [];

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _pageNav.dispose();
    _focus.dispose();
    _searchController.dispose();
    _filteredSpecimenData.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FalseWillPop(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Specimen Records"),
          automaticallyImplyLeading: false,
          actions: [
            ExpandedSearchBar(
              controller: _searchController,
              focusNode: _focus,
              hintText: 'Search specimens',
              trailing: [
                _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            ref.invalidate(specimenEntryProvider);
                          });
                        },
                        icon: const Icon(Icons.clear_rounded))
                    : IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => SearchOptionScreen(
                                  selectedSearchValue: _selectedSearchValue,
                                  onSelected: (index) {
                                    setState(() {
                                      _selectedSearchValue = index;
                                      _searchController.clear();
                                      Navigator.pop(context);
                                    });
                                  }));
                        },
                        icon: const Icon(Icons.tune_rounded))
              ],
              onChanged: (query) async {
                _filteredSpecimenData = await SpecimenSearchServices(
                  db: ref.read(databaseProvider),
                  specimenEntries: widget.specimenData,
                  searchOption:
                      SpecimenSearchOption.values[_selectedSearchValue],
                ).search(query.toLowerCase());
                setState(() {
                  if (_searchController.text.isEmpty) {
                    _filteredSpecimenData.clear();
                  }
                  // Reuse the single PageController (no recreate/leak); clamp
                  // the page into the new result range and jump to it.
                  final index =
                      _pageNav.clampToCount(_filteredSpecimenData.length);
                  _isVisible = query.isNotEmpty;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _pageNav.clampController(index);
                  });
                });
              },
            ),
            TextButton(
                onPressed: () {
                  _searchController.clear();
                  ref.invalidate(specimenEntryProvider);
                  // Return to the SpecimenViewer that is still mounted in the
                  // ProjectShell underneath this search screen.
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
          ],
        ),
        body: SafeArea(
          child: _filteredSpecimenData.isNotEmpty
              ? SpecimenPages(
                  specimenEntry: _filteredSpecimenData,
                  isNavButtonVisible: _isVisible,
                  pageNav: _pageNav,
                  onPageChanged: (index) {
                    setState(() {
                      _updatePageNav(index);
                    });
                  })
              : const EmptySpecimen(isButtonVisible: false),
        ),
        bottomSheet: Visibility(
          visible: _isVisible,
          child: PageNavButton(
            pageNav: _pageNav,
          ),
        ),
      ),
    );
  }

  void _updatePageNav(int value) {
    _pageNav.currentPage = value + 1;
    _pageNav.updatePageNavigation();
  }
}
