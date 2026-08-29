import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/features.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/specimens/shared/search.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/navigation.dart';
import 'package:nahpu/screens/specimens/shared/menu_bar.dart';
import 'package:nahpu/screens/specimens/specimen_form.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/navigation_services.dart';
import 'package:nahpu/services/common/record_page_reconciler.dart';

class SpecimenViewer extends ConsumerStatefulWidget {
  const SpecimenViewer({super.key});

  @override
  SpecimenViewerState createState() => SpecimenViewerState();
}

class SpecimenViewerState extends ConsumerState<SpecimenViewer>
    with RecordPageReconciler<SpecimenData, SpecimenEntry, SpecimenViewer> {
  String? _specimenUuid;
  CatalogFmt? _catalogFmt;
  TaxonData taxonomy = TaxonData();
  late FocusNode _focus;

  @override
  RecordViewer get recordViewer => RecordViewer.specimen;

  @override
  AsyncNotifierProvider<SpecimenEntry, List<SpecimenData>> get entryProvider =>
      specimenEntryProvider;

  @override
  Object recordIdOf(SpecimenData entry) => entry.uuid;

  @override
  void selectRecord(SpecimenData? entry) {
    _specimenUuid = entry?.uuid;
    _catalogFmt = entry == null
        ? null
        : matchTaxonGroupToCatFmt(entry.taxonGroup);
  }

  @override
  void invalidateEntries() => ref.invalidate(specimenEntryProvider);

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
    listenEntries();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Specimen Records"),
        actions: [
          IconButton(
            onPressed: _specimenUuid == null
                ? null
                : () async {
                    final specimenData = await SpecimenServices(
                      ref: ref,
                    ).getAllSpecimens();
                    if (context.mounted) {
                      // Pushed on top of the shell; Cancel pops back here.
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SpecimenSearchView(specimenData: specimenData),
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.search),
          ),
          const NewSpecimens(),
          SpecimenMenu(specimenUuid: _specimenUuid, catalogFmt: _catalogFmt),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ref
            .watch(specimenEntryProvider)
            .when(
              data: (specimenEntry) {
                if (specimenEntry.isEmpty) {
                  return const EmptySpecimen(isButtonVisible: true);
                }
                return SpecimenPages(
                  pageNav: pageNav,
                  isNavButtonVisible: isNavVisible,
                  specimenEntry: specimenEntry,
                  onPageChanged: (index) =>
                      handlePageChanged(index, specimenEntry[index]),
                );
              },
              loading: () => const CommonProgressIndicator(),
              error: (error, stack) => Text(error.toString()),
            ),
      ),
      bottomSheet: Visibility(
        visible: isNavVisible,
        child: PageNavButton(pageNav: pageNav),
      ),
    );
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
      title: const Text('Search Options', textAlign: TextAlign.center),
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
            ),
          ],
        ),
      ),
    );
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
      // Keyed by controller identity (see site_view.dart).
      key: ObjectKey(pageNav.pageController),
      controller: pageNav.pageController,
      itemCount: specimenEntry.length,
      itemBuilder: (context, index) {
        return _SpecimenPage(
          specimen: specimenEntry[index],
          pageNav: pageNav,
          isNavButtonVisible: isNavButtonVisible,
        );
      },
      onPageChanged: onPageChanged,
    );
  }
}

class _SpecimenPage extends ConsumerWidget {
  const _SpecimenPage({
    required this.specimen,
    required this.pageNav,
    required this.isNavButtonVisible,
  });

  final SpecimenData specimen;
  final bool isNavButtonVisible;
  final PageNavigation pageNav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSpecimen = ref
        .watch(specimenEntryProvider)
        .maybeWhen(
          data: (entries) => entries.firstWhere(
            (entry) => entry.uuid == specimen.uuid,
            orElse: () => specimen,
          ),
          orElse: () => specimen,
        );

    CatalogFmt catalogFmt = matchTaxonGroupToCatFmt(currentSpecimen.taxonGroup);
    final specimenFormCtr = _updateController(currentSpecimen);

    return PageViewer(
      pageNav: pageNav,
      isNavButtonVisible: isNavButtonVisible,
      child: SpecimenForm(
        key: ValueKey('${currentSpecimen.uuid}-${currentSpecimen.speciesID}'),
        specimenUuid: currentSpecimen.uuid,
        specimenCtr: specimenFormCtr,
        catalogFmt: catalogFmt,
      ),
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
      appBar: AppBar(title: const Text('Specimen Record')),
      body: SafeArea(
        child: ref
            .watch(specimenEntryProvider)
            .when(
              data: (specimenEntry) {
                if (specimenEntry.isEmpty) {
                  return const EmptySpecimen(isButtonVisible: false);
                } else {
                  final specimen = specimenEntry.firstWhere(
                    (specimen) => specimen.uuid == widget.specimenUuid,
                  );
                  CatalogFmt catalogFmt = matchTaxonGroupToCatFmt(
                    specimen.taxonGroup,
                  );
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
            ),
      ),
    );
  }

  SpecimenFormCtrModel _updateController(SpecimenData specimenEntry) {
    return SpecimenFormCtrModel.fromData(specimenEntry);
  }
}

class EmptySpecimen extends ConsumerWidget {
  const EmptySpecimen({super.key, required this.isButtonVisible});

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
