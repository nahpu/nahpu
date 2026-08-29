import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/personnel/new_personnel.dart';
import 'package:nahpu/screens/projects/personnel/personnel.dart';
import 'package:nahpu/screens/projects/personnel/personnel_details.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/layout/master_detail.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/styles/design_tokens.dart';

class ManagePersonnel extends StatelessWidget {
  const ManagePersonnel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage personnel')),
      body: const SafeArea(child: ManagePersonnelList()),
    );
  }
}

class ManagePersonnelList extends ConsumerStatefulWidget {
  const ManagePersonnelList({super.key});

  @override
  ConsumerState<ManagePersonnelList> createState() =>
      _ManagePersonnelListState();
}

class _ManagePersonnelListState extends ConsumerState<ManagePersonnelList> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focus = FocusNode();
  final Set<String> _selectedPersonnelUuids = {};
  Set<String> _listedPersonnelUuids = {};
  String? _focusedPersonnelUuid;
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
        .watch(allPersonnelProvider)
        .when(
          data: (personnel) {
            if (personnel.isEmpty) {
              return const Center(child: Text('No personnel found'));
            }
            final filteredPersonnel = _query.isEmpty
                ? personnel
                : PersonnelSearchService(
                    data: personnel,
                  ).search(_query.toLowerCase());
            final focusedPersonnel = _focusedPersonnel(filteredPersonnel);
            final isWide =
                MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact;
            return ResponsiveMasterDetail(
              wideLayoutKey: const ValueKey('manage-personnel-wide-layout'),
              listPane: _listPane(
                filteredPersonnel,
                focusedPersonnel: focusedPersonnel,
                isWide: isWide,
              ),
              detailsPane: focusedPersonnel == null
                  ? const EmptyDetailsPrompt(
                      message: 'Select personnel to view details',
                    )
                  : PersonnelDetails(
                      personnel: focusedPersonnel,
                      onEdit: () => _openEditor(focusedPersonnel),
                    ),
            );
          },
          loading: () => const Center(child: CommonProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
        );
  }

  Widget _listPane(
    List<PersonnelData> personnel, {
    required PersonnelData? focusedPersonnel,
    required bool isWide,
  }) {
    final allowedPersonnel = personnel
        .where((person) => !_listedPersonnelUuids.contains(person.uuid))
        .toList();
    final allVisibleSelected =
        allowedPersonnel.isNotEmpty &&
        allowedPersonnel.every(
          (person) => _selectedPersonnelUuids.contains(person.uuid),
        );
    return Column(
      key: const ValueKey('manage-personnel-list-pane'),
      children: [
        Padding(
          padding: const EdgeInsets.all(NahpuSpacing.md),
          child: CommonSearchBar(
            controller: _searchController,
            focusNode: _focus,
            hintText: 'Search personnel',
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
          onClearPressed: _selectedPersonnelUuids.isEmpty
              ? null
              : () => setState(_selectedPersonnelUuids.clear),
          onSelectAllPressed: allowedPersonnel.isEmpty || allVisibleSelected
              ? null
              : () {
                  setState(() {
                    _selectedPersonnelUuids
                      ..clear()
                      ..addAll(allowedPersonnel.map((person) => person.uuid));
                  });
                },
          onSelectPressed: _toggleSelectionMode,
        ),
        const Divider(height: NahpuStroke.thin),
        Expanded(
          child: personnel.isEmpty
              ? _NoPersonnelMatches(query: _query)
              : CommonScrollbar(
                  scrollController: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: personnel.length,
                    itemBuilder: (context, index) {
                      final person = personnel[index];
                      final isProtected = _listedPersonnelUuids.contains(
                        person.uuid,
                      );
                      return OutlinedListTile(
                        key: ValueKey('managed-personnel-${person.uuid}'),
                        isFocused: focusedPersonnel?.uuid == person.uuid,
                        onTap: () => _onPersonnelTap(
                          person,
                          isProtected: isProtected,
                          isWide: isWide,
                        ),
                        leading: _isSelecting
                            ? ListCheckBox(
                                isDisabled: isProtected,
                                value: _selectedPersonnelUuids.contains(
                                  person.uuid,
                                ),
                                onChanged: (selected) => _changeSelection(
                                  person.uuid,
                                  selected,
                                  isProtected,
                                ),
                              )
                            : null,
                        title: Text(person.name ?? 'Unnamed personnel'),
                        subtitle: PersonnelSubtitle(
                          role: person.role,
                          affiliation: person.affiliation,
                          orcid: person.orcid,
                          currentFieldNumber: person.currentFieldNumber,
                        ),
                        trailing: _isSelecting && isProtected
                            ? const Tooltip(
                                message:
                                    'Personnel is currently assigned to a project',
                                child: Icon(Icons.book_outlined),
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
              selectedItems: _selectedPersonnelUuids.toList(),
              itemName: 'personnel',
              onPressedFunction: _deletePersonnel,
            ),
          ),
        ],
      ],
    );
  }

  PersonnelData? _focusedPersonnel(List<PersonnelData> personnel) {
    if (_focusedPersonnelUuid == null) return null;
    for (final person in personnel) {
      if (person.uuid == _focusedPersonnelUuid) return person;
    }
    return null;
  }

  Future<void> _toggleSelectionMode() async {
    if (!_isSelecting) {
      final listed = await PersonnelServices(
        ref: ref,
      ).getAllPersonnelListedInProjects();
      if (!mounted) return;
      _listedPersonnelUuids = listed.toSet();
    }
    setState(() {
      _isSelecting = !_isSelecting;
      _selectedPersonnelUuids.clear();
    });
  }

  Future<void> _onPersonnelTap(
    PersonnelData person, {
    required bool isProtected,
    required bool isWide,
  }) async {
    if (_isSelecting) {
      _changeSelection(
        person.uuid,
        !_selectedPersonnelUuids.contains(person.uuid),
        isProtected,
      );
      return;
    }
    setState(() => _focusedPersonnelUuid = person.uuid);
    if (isWide) return;
    final editRequested = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.85,
          child: PersonnelDetails(
            personnel: person,
            onEdit: () => Navigator.pop(sheetContext, true),
          ),
        ),
      ),
    );
    if (editRequested == true && mounted) await _openEditor(person);
  }

  void _changeSelection(String uuid, bool? selected, bool isProtected) {
    if (isProtected) return;
    setState(() {
      if (selected == true) {
        _selectedPersonnelUuids.add(uuid);
      } else {
        _selectedPersonnelUuids.remove(uuid);
      }
    });
  }

  Future<void> _openEditor(PersonnelData personnel) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPersonnelForm(personnelData: personnel),
      ),
    );
  }

  Future<void> _deletePersonnel() async {
    final selectedCount = _selectedPersonnelUuids.length;
    final deletableUuids = _selectedPersonnelUuids
        .difference(_listedPersonnelUuids)
        .toList();
    try {
      await PersonnelServices(ref: ref).deletePersonnelFromList(deletableUuids);
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() {
        if (deletableUuids.contains(_focusedPersonnelUuid)) {
          _focusedPersonnelUuid = null;
        }
        _selectedPersonnelUuids.clear();
        _isSelecting = false;
      });
      _showSuccess(deletableUuids.length, selectedCount);
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
        ? '$deleted personnel deleted.'
        : '$deleted personnel deleted. $protected personnel could not be '
              'deleted because they are assigned to a project.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 10)),
    );
  }
}

class _NoPersonnelMatches extends StatelessWidget {
  const _NoPersonnelMatches({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Text(
          'No personnel match “$query”.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
