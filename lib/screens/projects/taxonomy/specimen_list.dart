import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/forms/features.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/utility_services.dart';

/// Standalone Specimen list screen. The same list body is also embedded in the
/// Collection Records segmented view.
class SpecimenListPage extends StatelessWidget {
  const SpecimenListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Specimen Records')),
      body: const SpecimenListBody(),
    );
  }
}

class SpecimenListBody extends ConsumerStatefulWidget {
  const SpecimenListBody({super.key});

  @override
  SpecimenListBodyState createState() => SpecimenListBodyState();
}

class SpecimenListBodyState extends ConsumerState<SpecimenListBody> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedSearchValue = 0;
  List<SpecimenData> _filteredSpecimenData = [];
  bool _isSearching = false;
  bool _isSearchOptionVisible = false;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(specimenEntryProvider).when(
          data: (specimenData) => SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Column(
                    children: [
                      CommonSearchBar(
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
                              : const SizedBox.shrink(),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _isSearchOptionVisible =
                                      !_isSearchOptionVisible;
                                });
                              },
                              icon: const Icon(Icons.tune_rounded)),
                        ],
                        onChanged: (String query) async {
                          _filteredSpecimenData = await SpecimenSearchServices(
                            db: ref.read(databaseProvider),
                            specimenEntries: specimenData,
                            searchOption: SpecimenSearchOption
                                .values[_selectedSearchValue],
                          ).search(query.toLowerCase());
                          setState(() {
                            if (_searchController.text.isNotEmpty) {
                              _isSearching = true;
                            } else {
                              _isSearching = false;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 4),
                      Visibility(
                          visible: _isSearchOptionVisible,
                          child: SpecimenSearchChips(
                            selectedValue: _selectedSearchValue,
                            onSelected: (int index) {
                              setState(() {
                                _selectedSearchValue = index;
                              });
                            },
                          )),
                      const SizedBox(height: 8),
                      if (specimenData.isEmpty)
                        const Expanded(
                          child: Center(child: Text('No specimens found')),
                        )
                      else ...[
                        Text(
                          specimenCount(specimenData),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: SpecimenList(
                            data: _isSearching
                                ? _filteredSpecimenData
                                : specimenData,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        );
  }

  String specimenCount(List<SpecimenData> data) {
    if (_isSearching) {
      int length = _filteredSpecimenData.length;
      String specimenCount = data.length > 1
          ? '${data.length} specimens'
          : '${data.length} specimen';
      if (length == 0) {
        return 'No specimens found';
      } else if (length == 1) {
        return 'Found: 1 of $specimenCount';
      } else {
        return 'Found: $length of $specimenCount';
      }
    } else {
      return 'Specimen counts: ${data.length}';
    }
  }
}

class SpecimenList extends StatelessWidget {
  const SpecimenList({
    super.key,
    required this.data,
  });

  final List<SpecimenData> data;

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return CommonScrollbar(
      scrollController: scrollController,
      child: ListView.builder(
        controller: scrollController,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: _getLeadingIcon(data[index].taxonGroup),
            title: SpecimenListTitle(
                catalogerID: data[index].catalogerID,
                fieldNumber: data[index].fieldNumber),
            subtitle: SpecimenListSubtitle(
              data: data[index],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SpecimenFormView(
                          specimenUuid: data[index].uuid,
                        )),
              );
            },
          );
        },
      ),
    );
  }

  Icon _getLeadingIcon(String? taxonGroup) {
    CatalogFmt fmt = matchTaxonGroupToCatFmt(taxonGroup);
    return Icon(matchCatFmtToIcon(fmt, isFilledIcon: false));
  }
}

class SpecimenListTitle extends ConsumerWidget {
  const SpecimenListTitle({
    super.key,
    required this.catalogerID,
    required this.fieldNumber,
  });

  final String? catalogerID;
  final int? fieldNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      builder: (context, snapshot) {
        // Render a stable Text regardless of the async state so recycled rows
        // don't flash a progress indicator while scrolling. The field number is
        // known synchronously; the cataloger name fills in once resolved.
        final name = snapshot.data ?? '';
        return Text(
          '$name ${fieldNumber ?? ''}'.trim(),
          style: Theme.of(context).textTheme.titleMedium,
        );
      },
      future: _getPersonnelName(catalogerID, ref),
    );
  }

  Future<String> _getPersonnelName(String? catalogerID, WidgetRef ref) async {
    if (catalogerID != null) {
      PersonnelData data =
          await PersonnelServices(ref: ref).getPersonnelByUuid(catalogerID);
      return data.name ?? '';
    } else {
      return '';
    }
  }
}

class SpecimenListSubtitle extends ConsumerWidget {
  const SpecimenListSubtitle({
    super.key,
    required this.data,
  });

  final SpecimenData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      builder: (context, snapshot) {
        // Keep a blank, same-style placeholder while loading so fast scrolling
        // doesn't flash 'Loading...' as rows are recycled.
        return Text(
          snapshot.data ?? '',
          style: Theme.of(context).textTheme.titleSmall,
        );
      },
      future: _getTaxonData(data?.speciesID, ref),
    );
  }

  Future<String> _getTaxonData(int? taxonId, WidgetRef ref) async {
    if (taxonId != null) {
      TaxonomyData data =
          await TaxonomyServices(ref: ref).getTaxonById(taxonId);
      return _createTaxonInfo(data);
    } else {
      return '';
    }
  }

  String _createTaxonInfo(TaxonomyData data) {
    String order =
        data.taxonOrder != null ? '${data.taxonOrder}$listTileSeparator' : '';
    String family =
        data.taxonFamily != null ? '${data.taxonFamily}$listTileSeparator' : '';
    String species = '${data.genus ?? ''} ${data.specificEpithet ?? ''}';

    return '$order$family$species';
  }
}
