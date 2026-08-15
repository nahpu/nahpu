import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/taxonomy/new_taxa.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_details.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/layout/master_detail.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/styles/design_tokens.dart';

class ManageTaxa extends StatelessWidget {
  const ManageTaxa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage taxa')),
      body: const SafeArea(child: ManageTaxaList()),
    );
  }
}

class ManageTaxaList extends ConsumerStatefulWidget {
  const ManageTaxaList({super.key});

  @override
  ConsumerState<ManageTaxaList> createState() => _ManageTaxaListState();
}

class _ManageTaxaListState extends ConsumerState<ManageTaxaList> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focus = FocusNode();
  final Set<int> _selectedTaxonIds = {};
  Set<int> _usedTaxonIds = {};
  int? _focusedTaxonId;
  String _query = '';
  bool _isSelecting = false;

  @override
  void dispose() {
    _focus.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(taxonRegistryProvider)
        .when(
          data: (taxa) {
            if (taxa.isEmpty) {
              return const Center(child: Text('No taxa found'));
            }
            final filteredTaxa = _query.isEmpty
                ? taxa
                : TaxonFilterServices().filterTaxonList(taxa, _query);
            final focusedTaxon = _focusedTaxon(filteredTaxa);
            final isWide =
                MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact;
            return ResponsiveMasterDetail(
              wideLayoutKey: const ValueKey('manage-taxa-wide-layout'),
              listPane: _listPane(
                filteredTaxa,
                focusedTaxon: focusedTaxon,
                isWide: isWide,
              ),
              detailsPane: focusedTaxon == null
                  ? const EmptyDetailsPrompt(
                      message: 'Select a taxon to view details',
                    )
                  : TaxonManagementDetails(
                      taxon: focusedTaxon,
                      onEdit: () => _openEditor(focusedTaxon),
                    ),
            );
          },
          loading: () => const Center(child: CommonProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
        );
  }

  Widget _listPane(
    List<TaxonomyData> taxa, {
    required TaxonomyData? focusedTaxon,
    required bool isWide,
  }) {
    final allowedTaxa = taxa
        .where((taxon) => !_usedTaxonIds.contains(taxon.id))
        .toList();
    final allVisibleSelected =
        allowedTaxa.isNotEmpty &&
        allowedTaxa.every((taxon) => _selectedTaxonIds.contains(taxon.id));
    return Column(
      key: const ValueKey('manage-taxa-list-pane'),
      children: [
        Padding(
          padding: const EdgeInsets.all(NahpuSpacing.md),
          child: CommonSearchBar(
            controller: _searchController,
            focusNode: _focus,
            hintText: 'Search taxa',
            trailing: [
              if (_query.isNotEmpty)
                IconButton(
                  tooltip: 'Clear search',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear_rounded),
                ),
            ],
            onChanged: (query) => setState(() => _query = query.trim()),
          ),
        ),
        SelectItemsInterface(
          isSelecting: _isSelecting,
          onClearPressed: _selectedTaxonIds.isEmpty
              ? null
              : () => setState(_selectedTaxonIds.clear),
          onSelectAllPressed: allowedTaxa.isEmpty || allVisibleSelected
              ? null
              : () {
                  setState(() {
                    _selectedTaxonIds
                      ..clear()
                      ..addAll(allowedTaxa.map((taxon) => taxon.id));
                  });
                },
          onSelectPressed: _toggleSelectionMode,
        ),
        const Divider(height: NahpuStroke.thin),
        Expanded(
          child: taxa.isEmpty
              ? _NoTaxaMatches(query: _query)
              : CommonScrollbar(
                  scrollController: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: taxa.length,
                    itemBuilder: (context, index) {
                      final taxon = taxa[index];
                      final isProtected = _usedTaxonIds.contains(taxon.id);
                      final classification = _taxonClassification(taxon);
                      return OutlinedListTile(
                        key: ValueKey('managed-taxon-${taxon.id}'),
                        isFocused: focusedTaxon?.id == taxon.id,
                        onTap: () => _onTaxonTap(
                          taxon,
                          isProtected: isProtected,
                          isWide: isWide,
                        ),
                        leading: _isSelecting
                            ? ListCheckBox(
                                isDisabled: isProtected,
                                value: _selectedTaxonIds.contains(taxon.id),
                                onChanged: (selected) => _changeSelection(
                                  taxon.id,
                                  selected,
                                  isProtected,
                                ),
                              )
                            : null,
                        title: Text(getTaxonDisplayName(taxon)),
                        subtitle: classification.isEmpty
                            ? null
                            : Text(classification),
                        trailing: _isSelecting && isProtected
                            ? const Tooltip(
                                message:
                                    'Taxon is currently used by a specimen',
                                child: Icon(Icons.inventory_2_outlined),
                              )
                            : null,
                      );
                    },
                  ),
                ),
        ),
        if (_isSelecting) ...[
          const Divider(height: NahpuStroke.thin),
          Padding(
            padding: const EdgeInsets.all(NahpuSpacing.xl),
            child: DeleteItemsButton(
              selectedItems: _selectedTaxonIds.toList(),
              itemName: _selectedTaxonIds.length == 1 ? 'taxon' : 'taxa',
              onPressedFunction: _deleteTaxa,
            ),
          ),
        ],
      ],
    );
  }

  TaxonomyData? _focusedTaxon(List<TaxonomyData> taxa) {
    if (_focusedTaxonId == null) return null;
    for (final taxon in taxa) {
      if (taxon.id == _focusedTaxonId) return taxon;
    }
    return null;
  }

  Future<void> _toggleSelectionMode() async {
    if (!_isSelecting) {
      final usedTaxa = await TaxonomyServices(ref: ref).getUsedTaxa();
      if (!mounted) return;
      _usedTaxonIds = usedTaxa.toSet();
    }
    setState(() {
      _isSelecting = !_isSelecting;
      _selectedTaxonIds.clear();
    });
  }

  Future<void> _onTaxonTap(
    TaxonomyData taxon, {
    required bool isProtected,
    required bool isWide,
  }) async {
    if (_isSelecting) {
      _changeSelection(
        taxon.id,
        !_selectedTaxonIds.contains(taxon.id),
        isProtected,
      );
      return;
    }
    setState(() => _focusedTaxonId = taxon.id);
    if (isWide) return;
    final editRequested = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.85,
          child: TaxonManagementDetails(
            taxon: taxon,
            onEdit: () => Navigator.pop(sheetContext, true),
          ),
        ),
      ),
    );
    if (editRequested == true && mounted) await _openEditor(taxon);
  }

  void _changeSelection(int id, bool? selected, bool isProtected) {
    if (isProtected) return;
    setState(() {
      if (selected == true) {
        _selectedTaxonIds.add(id);
      } else {
        _selectedTaxonIds.remove(id);
      }
    });
  }

  Future<void> _openEditor(TaxonomyData taxon) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaxon(
          taxonId: taxon.id,
          ctr: TaxonRegistryCtrModel.fromData(taxon),
        ),
      ),
    );
  }

  Future<void> _deleteTaxa() async {
    final selectedCount = _selectedTaxonIds.length;
    final deletableIds = _selectedTaxonIds.difference(_usedTaxonIds).toList();
    try {
      await TaxonomyServices(ref: ref).deleteTaxonFromList(deletableIds);
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() {
        if (deletableIds.contains(_focusedTaxonId)) {
          _focusedTaxonId = null;
        }
        _selectedTaxonIds.clear();
        _isSelecting = false;
      });
      _showSuccess(deletableIds.length, selectedCount);
    } catch (error) {
      if (mounted) _showError(error.toString());
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _query = '';
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(int deleted, int selected) {
    final protected = selected - deleted;
    final message = protected == 0
        ? '$deleted ${deleted == 1 ? 'taxon' : 'taxa'} deleted.'
        : '$deleted taxa deleted. $protected taxa could not be deleted because '
              'they are used by specimens.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 10)),
    );
  }
}

class _NoTaxaMatches extends StatelessWidget {
  const _NoTaxaMatches({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Text(
          'No taxa match “$query”.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

String _taxonClassification(TaxonomyData taxon) {
  return [
    taxon.taxonClass,
    taxon.taxonOrder,
    taxon.taxonFamily,
  ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' • ');
}
