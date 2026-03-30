import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nahpu/screens/projects/personnel/manage_personnel.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/projects/personnel/add_personnel.dart';
import 'package:nahpu/screens/projects/personnel/avatars.dart';
import 'package:nahpu/screens/projects/personnel/new_personnel.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/styles/catalog_pages.dart';

enum PersonnelMenuAction { edit, delete }

const int avatarSize = 48;

class PersonnelViewer extends ConsumerStatefulWidget {
  const PersonnelViewer({super.key});

  @override
  PersonnelViewerState createState() => PersonnelViewerState();
}

class PersonnelViewerState extends ConsumerState<PersonnelViewer> {
  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Personnel',
      infoContent: const PersonnelInfoContent(),
      mainAxisAlignment: MainAxisAlignment.start,
      child: SizedBox(
        height: topDashboardHeight - 96,
        child: const PersonnelList(),
      ),
    );
  }
}

class PersonnelList extends ConsumerStatefulWidget {
  const PersonnelList({super.key});

  @override
  PersonnelListState createState() => PersonnelListState();
}

class PersonnelListState extends ConsumerState<PersonnelList> {
  final ScrollController _scrollController = ScrollController();
  bool _isSelecting = false;
  final List<String> _selectedPersonnel = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personnel = ref.watch(projectPersonnelProvider);
    return personnel.when(
      data: (data) {
        return data.isEmpty
            ? const EmptyPersonnel()
            : Column(
                mainAxisSize: MainAxisSize.min,
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
                        _selectedPersonnel
                            .addAll(data.map((e) => e.uuid).toList());
                      });
                    },
                    onSelectPressed: () {
                      setState(() {
                        _isSelecting = !_isSelecting;
                        _selectedPersonnel.clear();
                      });
                    },
                  ),
                  Flexible(
                    child: CommonScrollbar(
                      scrollController: _scrollController,
                      child: ListView.builder(
                        itemCount: data.length,
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return PersonnelListTile(
                            personnelData: data[index],
                            isSelecting: _isSelecting,
                            selectedPersonnel: _selectedPersonnel,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedPersonnel.add(data[index].uuid);
                                } else {
                                  _selectedPersonnel.remove(data[index].uuid);
                                }
                              });
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditPersonnelForm(
                                              personnelData: data[index],
                                            )));
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  !_isSelecting
                      ? const AddPersonnelButton()
                      : DeleteItemsButton(
                          selectedItems: _selectedPersonnel,
                          itemName: "personnel",
                          onPressedFunction: () async {
                            await _deletePersonnel();
                            setState(() {
                              _selectedPersonnel.clear();
                            });
                          },
                          customIconButtonText:
                              'Remove ${_selectedPersonnel.length} personnel from project',
                          customDialogHeader: 'Remove personnel',
                          customDialogText:
                              'Are you sure you want to remove the selected personnel from the project?',
                          customDialogButtonText: 'Remove',
                        )
                ],
              );
      },
      loading: () => const CommonProgressIndicator(),
      error: (error, stack) => Text(error.toString()),
    );
  }

  Future<void> _deletePersonnel() async {
    int numberPersonnelDeleted = 0;
    for (String personnelUuid in _selectedPersonnel) {
      try {
        await PersonnelServices(ref: ref).deleteProjectPersonnel(personnelUuid);
        numberPersonnelDeleted++;
      } catch (e) {
        if (e.toString().contains('Personnel is being used') ||
            e.toString().contains('SqliteException(787)')) {
          continue;
        } else {
          // Something went wrong. Discontinue deleting.
          _showError(e.toString());
          break;
        }
      }
    }

    if (context.mounted) {
      _pop();
    }

    if (numberPersonnelDeleted < _selectedPersonnel.length) {
      _showError('${_selectedPersonnel.length - numberPersonnelDeleted} '
          'personnel could not be removed as they are being '
          'used by project records.');
    }
  }

  void _pop() {
    Navigator.pop(context);
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errors),
        duration: const Duration(seconds: 10),
      ),
    );
  }
}

class EmptyPersonnel extends StatelessWidget {
  const EmptyPersonnel({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No personnel found.',
          style: Theme.of(context).textTheme.labelLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const AddPersonnelButton(),
      ],
    ));
  }
}

class AddPersonnelButton extends StatelessWidget {
  const AddPersonnelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        SecondaryButton(
            text: 'Manage',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManagePersonnel(),
                ),
              );
            }),
        PrimaryButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPersonnel(),
              ),
            );
          },
          label: 'Add personnel',
          icon: Icons.add,
        ),
      ],
    );
  }
}

class PersonnelListTile extends StatefulWidget {
  const PersonnelListTile({
    super.key,
    required this.personnelData,
    required this.isSelecting,
    required this.selectedPersonnel,
    required this.onChanged,
    required this.trailing,
  });

  final PersonnelData personnelData;
  final bool isSelecting;
  final List<String> selectedPersonnel;
  final void Function(bool?) onChanged;
  final Widget trailing;

  @override
  State<PersonnelListTile> createState() => _PersonnelListTileState();
}

class _PersonnelListTileState extends State<PersonnelListTile> {
  final TextEditingController _personnelPhotoCtr = TextEditingController();

  @override
  void initState() {
    _personnelPhotoCtr.text = widget.personnelData.photoPath ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _personnelPhotoCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personnelData = widget.personnelData;
    return ListTile(
      leading: Row(mainAxisSize: MainAxisSize.min, children: [
        !widget.isSelecting
            ? SizedBox(
                height: avatarSize.toDouble(),
                width: avatarSize.toDouble(),
                child: AvatarViewer(
                  avatarCtr: _personnelPhotoCtr,
                ))
            : ListCheckBox(
                isDisabled: false,
                value: widget.selectedPersonnel.contains(personnelData.uuid),
                onChanged: widget.onChanged),
      ]),
      title: Text(
        _getTitle(personnelData.name, personnelData.initial),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: PersonnelSubtitle(
        role: personnelData.role,
        affiliation: personnelData.affiliation,
        currentFieldNumber: personnelData.currentFieldNumber,
      ),
      trailing: !widget.isSelecting ? widget.trailing : SizedBox.shrink(),
    );
  }

  String _getTitle(String? name, String? personInitial) {
    if (name != null && personInitial != null) {
      return personInitial.isEmpty ? name : '$name ($personInitial)';
    } else if (name != null) {
      return name;
    } else if (personInitial != null) {
      return personInitial;
    } else {
      return '';
    }
  }
}

class PersonnelSubtitle extends StatelessWidget {
  const PersonnelSubtitle({
    super.key,
    required this.role,
    required this.affiliation,
    required this.currentFieldNumber,
  });

  final String? role;
  final String? affiliation;
  final int? currentFieldNumber;

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(children: [
      (role != null && role != '')
          ? TextSpan(children: [
              const WidgetSpan(
                  child: Tooltip(
                      message: 'Role',
                      child: TileIcon(icon: Icons.account_circle_outlined)),
                  alignment: PlaceholderAlignment.middle),
              TextSpan(
                text: ' $role ',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ])
          : const TextSpan(),
      (affiliation != null && affiliation != '')
          ? TextSpan(
              children: [
                const WidgetSpan(
                    child: Tooltip(
                        message: 'Affiliation',
                        child: TileIcon(icon: Icons.business_rounded)),
                    alignment: PlaceholderAlignment.middle),
                TextSpan(
                  text: ' $affiliation ',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            )
          : const TextSpan(),
      currentFieldNumber == null || currentFieldNumber! == 0
          ? const TextSpan()
          : TextSpan(
              children: [
                WidgetSpan(
                    child: Tooltip(
                        message: 'Current Field Number',
                        child: TileIcon(icon: MdiIcons.counter)),
                    alignment: PlaceholderAlignment.middle),
                TextSpan(
                  text: ' $currentFieldNumber',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
    ]));
  }
}

class PersonnelInfoContent extends StatelessWidget {
  const PersonnelInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Overview',
          content: 'List of personnel for this project.'
              ' Use the add button to add personnel.'
              ' To edit or delete the personnel, use the menu button.'
              ' You need at least a cataloger to start adding specimens.',
        ),
        InfoContent(
          content: 'When you create a personnel,'
              ' their data will be saved in the database'
              ' for reuse in other projects. Deleting a personnel will'
              ' only remove them from this project. '
              'You can permanently delete a personnel in the settings.',
        ),
        InfoContent(
          content: 'Some institutions use project ID'
              ' instead of initial for the specimen field ID.'
              ' Replace the initial with the project ID.',
        ),
        InfoContent(
          header: 'Role definitions',
          content: 'Cataloger - responsible for cataloging the specimens.'
              ' They are the ones who responsible for recording the specimen data.'
              ' You cannot change the cataloger role once the personnel is created.'
              ' Their names will be listed in'
              ' any field that ask for personnel name input.'
              '\n\n'
              'Preparator only - help prepare the specimens, '
              ' but does not record the specimen data.'
              ' Their name will only be listed in the preparator and collector field.'
              '\n\n'
              'None - does not have any role in taking care of the specimens.',
        ),
      ],
    );
  }
}
