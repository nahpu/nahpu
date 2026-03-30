import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/screens/projects/taxonomy/new_taxa.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/utility_services.dart';

import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/taxonomy_services.dart';

class TaxonRegistryPage extends ConsumerStatefulWidget {
  const TaxonRegistryPage({super.key});

  @override
  TaxonRegistryPageState createState() => TaxonRegistryPageState();
}

class TaxonRegistryPageState extends ConsumerState<TaxonRegistryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taxon registry'),
      ),
      body: ref.watch(taxonRegistryProvider).when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(
                  child: Text(
                    'No taxon found',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return TaxonList(taxonList: data);
            },
            loading: () => const CommonProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
    );
  }
}

class TaxonList extends StatefulWidget {
  const TaxonList({
    super.key,
    required this.taxonList,
  });

  final List<TaxonomyData> taxonList;

  @override
  State<TaxonList> createState() => _TaxonListState();
}

class _TaxonListState extends State<TaxonList> {
  List<TaxonomyData> _filteredTaxonList = [];
  final TextEditingController _searchController = TextEditingController();
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
    return SafeArea(
      child: ScrollableConstrainedLayout(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonSearchBar(
              controller: _searchController,
              focusNode: _focus,
              hintText: 'Search taxa',
              trailing: [
                _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _filteredTaxonList.clear();
                          });
                        },
                        icon: const Icon(Icons.clear_rounded))
                    : const SizedBox.shrink()
              ],
              onChanged: (String value) {
                String searchValue = value.toLowerCase();
                setState(() {
                  _filteredTaxonList = TaxonFilterServices()
                      .filterTaxonList(widget.taxonList, searchValue);
                });
              },
            ),
            const SizedBox(height: 8),
            _filteredTaxonList.isEmpty
                ? const SizedBox.shrink()
                : Text('Results: ${_filteredTaxonList.length}'),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: TaxonListView(
                  taxonList: _filteredTaxonList.isNotEmpty
                      ? _filteredTaxonList
                      : widget.taxonList,
                ))
          ],
        ),
      ),
    );
  }
}

class TaxonListView extends ConsumerStatefulWidget {
  const TaxonListView({
    super.key,
    required this.taxonList,
  });

  final List<TaxonomyData> taxonList;

  @override
  TaxonListViewState createState() => TaxonListViewState();
}

class TaxonListViewState extends ConsumerState<TaxonListView> {
  final ScrollController _scrollController = ScrollController();
  final List<int> _selectedTaxon = [];
  List<int> _allowedTaxa = [];
  List<int> _usedTaxon = [];
  bool _isSelecting = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectItemsInterface(
          isSelecting: _isSelecting,
          onClearPressed: _selectedTaxon.isEmpty
              ? null
              : () {
                  setState(() {
                    _selectedTaxon.clear();
                  });
                },
          onSelectAllPressed:
              _selectedTaxon.length == widget.taxonList.length ||
                      _selectedTaxon.length == _allowedTaxa.length
                  ? null
                  : () {
                      setState(() {
                        _selectedTaxon.clear();
                        _selectedTaxon.addAll(_allowedTaxa);
                      });
                    },
          onSelectPressed: () async {
            _usedTaxon = await _getUsedTaxa();
            _allowedTaxa = _getAllowedTaxa();
            setState(() {
              _isSelecting = !_isSelecting;
              _selectedTaxon.clear();
            });
          },
        ),
        Expanded(
          child: CommonScrollbar(
            scrollController: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: widget.taxonList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      '${widget.taxonList[index].genus} ${widget.taxonList[index].specificEpithet}'),
                  subtitle: Text(
                    '${widget.taxonList[index].taxonClass}'
                    '$listTileSeparator'
                    '${widget.taxonList[index].taxonOrder}'
                    '$listTileSeparator'
                    '${widget.taxonList[index].taxonFamily}',
                  ),
                  leading: _isSelecting
                      ? ListCheckBox(
                          isDisabled:
                              _usedTaxon.contains(widget.taxonList[index].id),
                          value: _selectedTaxon
                              .contains(widget.taxonList[index].id),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedTaxon.add(widget.taxonList[index].id);
                              } else {
                                _selectedTaxon
                                    .remove(widget.taxonList[index].id);
                              }
                            });
                          },
                        )
                      : null,
                  trailing: !_isSelecting
                      ? IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditTaxon(
                                  taxonId: widget.taxonList[index].id,
                                  ctr: TaxonRegistryCtrModel.fromData(
                                      widget.taxonList[index]),
                                ),
                              ),
                            );
                          },
                        )
                      : SizedBox.shrink(),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        _isSelecting
            ? DeleteItemsButton(
                selectedItems: _selectedTaxon,
                itemName: _selectedTaxon.length == 1 ? 'taxon' : 'taxa',
                onPressedFunction: () async {
                  await _deleteTaxon();
                  setState(() {
                    _selectedTaxon.clear();
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Future<List<int>> _getUsedTaxa() async {
    return await TaxonomyServices(ref: ref).getUsedTaxa();
  }

  List<int> _getAllowedTaxa() {
    List<int> allowedTaxa = [];
    for (var taxon in widget.taxonList) {
      if (!_usedTaxon.contains(taxon.id)) {
        allowedTaxa.add(taxon.id);
      }
    }
    return allowedTaxa;
  }

  Future<void> _deleteTaxon() async {
    await TaxonomyServices(ref: ref).deleteTaxonFromList(_selectedTaxon);
  }
}
