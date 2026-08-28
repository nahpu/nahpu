import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/personnel/new_personnel.dart';
import 'package:nahpu/screens/projects/personnel/personnel_details.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/layout/master_detail.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/styles/design_tokens.dart';

class SelectPersonnel extends ConsumerStatefulWidget {
  const SelectPersonnel({super.key, required this.addedPersonnel});

  final List<PersonnelData> addedPersonnel;

  @override
  SelectPersonnelState createState() => SelectPersonnelState();
}

class SelectPersonnelState extends ConsumerState<SelectPersonnel> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focus = FocusNode();
  final Set<String> _selectedPersonnelUuids = {};
  String? _focusedPersonnelUuid;
  String _query = '';
  bool _isAdding = false;

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
              return const Center(child: Text('No personnel'));
            }
            final filteredPersonnel = _query.isEmpty
                ? personnel
                : PersonnelSearchService(
                    data: personnel,
                  ).search(_query.toLowerCase());
            final addedUuids = widget.addedPersonnel
                .map((person) => person.uuid)
                .toSet();
            final focusedPersonnel = _focusedPersonnel(filteredPersonnel);
            final isWide =
                MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact;

            return ResponsiveMasterDetail(
              wideLayoutKey: const ValueKey('personnel-wide-layout'),
              listPane: _selectionPane(
                filteredPersonnel: filteredPersonnel,
                allPersonnel: personnel,
                addedUuids: addedUuids,
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

  Widget _selectionPane({
    required List<PersonnelData> filteredPersonnel,
    required List<PersonnelData> allPersonnel,
    required Set<String> addedUuids,
    required PersonnelData? focusedPersonnel,
    required bool isWide,
  }) {
    final eligiblePersonnel = filteredPersonnel
        .where((person) => !addedUuids.contains(person.uuid))
        .toList();
    final allVisibleSelected =
        eligiblePersonnel.isNotEmpty &&
        eligiblePersonnel.every(
          (person) => _selectedPersonnelUuids.contains(person.uuid),
        );

    return Column(
      key: const ValueKey('personnel-selection-pane'),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.md),
          child: Row(
            children: [
              TextButton(
                onPressed: _selectedPersonnelUuids.isEmpty
                    ? null
                    : () => setState(_selectedPersonnelUuids.clear),
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: eligiblePersonnel.isEmpty || allVisibleSelected
                    ? null
                    : () {
                        setState(() {
                          _selectedPersonnelUuids
                            ..clear()
                            ..addAll(
                              eligiblePersonnel.map((person) => person.uuid),
                            );
                        });
                      },
                child: const Text('Select all'),
              ),
              Expanded(
                child: Text(
                  '${_selectedPersonnelUuids.length} selected',
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: NahpuStroke.thin),
        Expanded(
          key: const ValueKey('personnel-list-region'),
          child: filteredPersonnel.isEmpty
              ? _NoPersonnelMatches(query: _query)
              : CommonScrollbar(
                  scrollController: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredPersonnel.length,
                    itemBuilder: (context, index) {
                      final person = filteredPersonnel[index];
                      final isAdded = addedUuids.contains(person.uuid);
                      return OutlinedListTile(
                        key: ValueKey('personnel-${person.uuid}'),
                        isFocused: focusedPersonnel?.uuid == person.uuid,
                        onTap: () => _focusPersonnel(person, isWide: isWide),
                        leading: ListCheckBox(
                          isDisabled: isAdded,
                          value: _selectedPersonnelUuids.contains(person.uuid),
                          onChanged: (selected) =>
                              _changeSelection(person.uuid, selected, isAdded),
                        ),
                        title: Text(person.name ?? 'Unnamed personnel'),
                        subtitle: _hasValue(person.affiliation)
                            ? Text(person.affiliation!)
                            : _hasValue(person.role)
                            ? Text(person.role!)
                            : null,
                        trailing: isAdded
                            ? const Chip(label: Text('Added'))
                            : null,
                      );
                    },
                  ),
                ),
        ),
        const Divider(height: NahpuStroke.thin),
        Padding(
          padding: const EdgeInsets.all(NahpuSpacing.xl),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: NahpuSpacing.xl,
            runSpacing: NahpuSpacing.md,
            children: [
              SecondaryButton(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
              PrimaryButton(
                label: 'Add ${_selectedPersonnelUuids.length} personnel',
                icon: Icons.add,
                onPressed: _selectedPersonnelUuids.isEmpty || _isAdding
                    ? null
                    : () => _addSelectedPersonnel(allPersonnel),
              ),
            ],
          ),
        ),
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

  Future<void> _focusPersonnel(
    PersonnelData person, {
    required bool isWide,
  }) async {
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

  Future<void> _openEditor(PersonnelData personnel) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPersonnelForm(personnelData: personnel),
      ),
    );
  }

  void _changeSelection(String uuid, bool? selected, bool isAdded) {
    if (isAdded) return;
    setState(() {
      if (selected == true) {
        _selectedPersonnelUuids.add(uuid);
      } else {
        _selectedPersonnelUuids.remove(uuid);
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _query = '';
    });
  }

  Future<void> _addSelectedPersonnel(List<PersonnelData> personnel) async {
    setState(() => _isAdding = true);
    try {
      final selectedPersonnel = personnel
          .where((person) => _selectedPersonnelUuids.contains(person.uuid))
          .toList();
      await PersonnelServices(
        ref: ref,
      ).addMultiplePersonnelToProject(selectedPersonnel);
      if (mounted) ProjectShell.returnToTab(context, ref, 0);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
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
