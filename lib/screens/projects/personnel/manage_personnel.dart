import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/projects/personnel/new_personnel.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/screens/projects/personnel/personnel.dart';

class ManagePersonnel extends ConsumerStatefulWidget {
  const ManagePersonnel({super.key});

  @override
  ManagePersonnelState createState() => ManagePersonnelState();
}

class ManagePersonnelState extends ConsumerState<ManagePersonnel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage personnel'),
      ),
      body: const ScrollableConstrainedLayout(child: ManagePersonnelList()),
    );
  }
}

class PersonnelEmpty extends StatelessWidget {
  const PersonnelEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No personnel found'));
  }
}

class ManagePersonnelList extends ConsumerStatefulWidget {
  const ManagePersonnelList({
    super.key,
  });

  @override
  ManagePersonnelListState createState() => ManagePersonnelListState();
}

class ManagePersonnelListState extends ConsumerState<ManagePersonnelList> {
  final TextEditingController _searchController = TextEditingController();
  List<PersonnelData> _filteredData = [];
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _focus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(allPersonnelProvider).when(
          data: (data) {
            if (data.isEmpty) {
              return const Center(child: Text('No personnel'));
            } else {
              return Column(
                children: [
                  CommonPadding(
                    child: CommonSearchBar(
                        controller: _searchController,
                        focusNode: _focus,
                        hintText: 'Search personnel',
                        trailing: [
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                  icon: const Icon(Icons.clear),
                                )
                              : const SizedBox.shrink(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filteredData = PersonnelSearchService(data: data)
                                .search(value.toLowerCase());
                          });
                        }),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                      height: MediaQuery.sizeOf(context).height - 240,
                      child: data.isEmpty
                          ? const PersonnelEmpty()
                          : PersonnelListView(
                              personnelList:
                                  _filteredData.isEmpty ? data : _filteredData,
                            ))
                ],
              );
            }
          },
          loading: () => const CommonProgressIndicator(),
          error: (error, stack) => Text(
            error.toString(),
          ),
        );
  }
}

class PersonnelListView extends ConsumerStatefulWidget {
  const PersonnelListView({
    super.key,
    required this.personnelList,
  });

  final List<PersonnelData> personnelList;

  @override
  PersonnelListViewState createState() => PersonnelListViewState();
}

class PersonnelListViewState extends ConsumerState<PersonnelListView> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _selectedPersonnel = [];
  List<String> _allPersonnel = [];
  List<String> _allowedPersonnel = [];
  List<String> _listedInProjectPersonnel = [];
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SelectItemsInterface(
          isSelecting: _isSelecting,
          onClearPressed: _selectedPersonnel.isEmpty
              ? null
              : () {
                  setState(() {
                    _selectedPersonnel.clear();
                  });
                },
          onSelectAllPressed: () {
            setState(() {
              _selectedPersonnel.clear();
              _selectedPersonnel.addAll(_allPersonnel);
            });
          },
          onSelectPressed: () async {
            _listedInProjectPersonnel = await _getListedPersonnelInProject();
            _allowedPersonnel = _getAllowedPersonnel();
            _allPersonnel = _getAllPersonnel();
            setState(() {
              _isSelecting = !_isSelecting;
              _selectedPersonnel.clear();
            });
          },
        ),
        Expanded(
            child: CommonScrollbar(
                scrollController: _scrollController,
                child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: widget.personnelList.length,
                    itemBuilder: (context, index) {
                      return SelectPersonnelTile(
                        data: widget.personnelList[index],
                        listedPersonnel: _listedInProjectPersonnel,
                        selectedPersonnel: _selectedPersonnel,
                        isSelecting: _isSelecting,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedPersonnel
                                  .add(widget.personnelList[index].uuid);
                            } else {
                              _selectedPersonnel
                                  .remove(widget.personnelList[index].uuid);
                            }
                          });
                        },
                      );
                    }))),
        const SizedBox(height: 8),
        _isSelecting
            ? DeleteItemsButton(
                selectedItems: _selectedPersonnel,
                itemName: 'personnel',
                onPressedFunction: () async {
                  await _deletePersonnel();
                  setState(() {
                    _selectedPersonnel.clear();
                  });
                })
            : const SizedBox.shrink(),
      ],
    );
  }

  Future<void> _deletePersonnel() async {
    try {
      List<String> personnelToDelete = _selectedPersonnel
          .toSet()
          .intersection(_allowedPersonnel.toSet())
          .toList();

      await PersonnelServices(ref: ref)
          .deletePersonnelFromList(personnelToDelete);
      setState(() {
        _isSelecting = false;
      });
      if (context.mounted) {
        _pop();
      }
      _showSuccess(personnelToDelete.length, _selectedPersonnel.length);
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  List<String> _getAllPersonnel() {
    final List<String> allPersonnel = [];
    for (final personnel in widget.personnelList) {
      allPersonnel.add(personnel.uuid);
    }

    return allPersonnel;
  }

  List<String> _getAllowedPersonnel() {
    final List<String> allowedPersonnel = [];
    for (final personnel in widget.personnelList) {
      if (!_listedInProjectPersonnel.contains(personnel.uuid)) {
        allowedPersonnel.add(personnel.uuid);
      }
    }
    return allowedPersonnel;
  }

  Future<List<String>> _getListedPersonnelInProject() async {
    return await PersonnelServices(ref: ref).getAllPersonnelListedInProjects();
  }

  void _pop() {
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(int deleted, int selected) {
    String message = '$deleted personnel deleted.';

    if (deleted < selected) {
      message = '''
        $message
        ${selected - deleted} personnel could not be deleted because they are assigned to a project.
      ''';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10),
      ),
    );
  }
}

class SelectPersonnelTile extends StatelessWidget {
  const SelectPersonnelTile({
    super.key,
    required this.data,
    required this.listedPersonnel,
    required this.selectedPersonnel,
    required this.onChanged,
    required this.isSelecting,
  });

  final PersonnelData data;
  final List<String> listedPersonnel;
  final List<String> selectedPersonnel;
  final bool isSelecting;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(data.name ?? ''),
        subtitle: PersonnelSubtitle(
          role: data.role,
          affiliation: data.affiliation,
          currentFieldNumber: data.currentFieldNumber,
        ),
        leading: isSelecting
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                ListCheckBox(
                  isDisabled: false,
                  value: selectedPersonnel.contains(data.uuid),
                  onChanged: onChanged,
                ),
                Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: listedPersonnel.contains(data.uuid),
                    child: Tooltip(
                        message: 'Personnel is currently assigned to a project',
                        child: Icon(Icons.book))),
              ])
            : const SizedBox.shrink(),
        trailing: !isSelecting
            ? IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditPersonnelForm(
                                personnelData: data,
                              )));
                },
              )
            : SizedBox.shrink());
  }
}
