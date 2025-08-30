import 'package:drift/drift.dart' as db;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';

class EventPersonnel extends ConsumerStatefulWidget {
  const EventPersonnel({
    super.key,
    required this.eventID,
  });

  final int eventID;

  @override
  CollectingPersonnelFormState createState() => CollectingPersonnelFormState();
}

class CollectingPersonnelFormState extends ConsumerState<EventPersonnel> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 402,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const TitleForm(
            text: 'Event Personnel',
            infoContent: EventPersonnelInfoContent(),
          ),
          SizedBox(
              height: 368,
              child: ref.watch(collPersonnelProvider(widget.eventID)).when(
                    data: (data) {
                      return data.isEmpty
                          ? EmptyPersonnel(onPressed: _addPersonnel)
                          : Column(
                              children: [
                                Flexible(
                                  child: CommonScrollbar(
                                    scrollController: scrollController,
                                    child: ListView(
                                      shrinkWrap: true,
                                      controller: scrollController,
                                      children: data
                                          .map(
                                            (person) => EventPersonnelField(
                                              eventID: widget.eventID,
                                              controller:
                                                  _addPersonnelCtr(person),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AddPersonnelButton(
                                  onPressed: _addPersonnel,
                                ),
                              ],
                            );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => const Center(child: Text('Error')),
                  )),
        ],
      ),
    );
  }

  Future<void> _addPersonnel() async {
    await CollEventServices(ref: ref)
        .createCollPersonnel(CollPersonnelCompanion(
      eventID: db.Value(widget.eventID),
    ));
    if (context.mounted) {
      setState(() {});
    }
  }

  EventPersonnelCtrModel _addPersonnelCtr(CollPersonnelData form) {
    final EventPersonnelCtrModel newPersonnel =
        EventPersonnelCtrModel.fromData(form);
    return newPersonnel;
  }
}

class AddPersonnelButton extends StatelessWidget {
  const AddPersonnelButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Add personnel',
      icon: Icons.add,
      onPressed: onPressed,
    );
  }
}

class EmptyPersonnel extends StatelessWidget {
  const EmptyPersonnel({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('No personnel added'),
        const SizedBox(height: 8),
        AddPersonnelButton(onPressed: onPressed),
      ],
    );
  }
}

class EventPersonnelField extends ConsumerStatefulWidget {
  const EventPersonnelField({
    super.key,
    required this.eventID,
    required this.controller,
  });

  final int eventID;
  final EventPersonnelCtrModel controller;

  @override
  EventPersonnelFieldState createState() => EventPersonnelFieldState();
}

class EventPersonnelFieldState extends ConsumerState<EventPersonnelField> {
  @override
  Widget build(BuildContext context) {
    return CommonPadding(
        child: Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: widget.controller.nameIDCtr,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Personnel',
              hintText: 'Enter a name',
            ),
            items: ref.watch(projectPersonnelProvider).when(
                  data: (value) => value
                      .map((person) => DropdownMenuItem(
                            value: person.uuid,
                            child: CommonDropdownText(
                              text: person.name ?? '',
                            ),
                          ))
                      .toList(),
                  loading: () => const [],
                  error: (error, stack) => const [],
                ),
            onChanged: (value) {
              widget.controller.nameIDCtr = value ?? '';

              CollEventServices(ref: ref).updateCollPersonnel(
                widget.controller.id!,
                CollPersonnelCompanion(
                  eventID: db.Value(widget.eventID),
                  personnelId: db.Value(value),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PersonnelRole(
            eventID: widget.eventID,
            controller: widget.controller,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _deletePersonnel();
          },
        ),
      ],
    ));
  }

  void _deletePersonnel() {
    showDeleteAlertOnMenu(
      context: context,
      title: 'Delete collecting personnel?',
      deletePrompt: 'You will delete this personnel from the event',
      onDelete: () async {
        try {
          await CollEventServices(ref: ref)
              .deleteCollPersonnel(widget.controller.id!);
          if (context.mounted) {
            _pop();
          }
        } catch (e) {
          if (context.mounted) {
            _showError(e.toString());
          }
        }
      },
    );
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errors),
      ),
    );
  }

  void _pop() {
    Navigator.pop(context);
  }
}

class PersonnelRole extends ConsumerStatefulWidget {
  const PersonnelRole({
    super.key,
    required this.eventID,
    required this.controller,
  });

  final int eventID;
  final EventPersonnelCtrModel controller;

  @override
  PersonnelRoleState createState() => PersonnelRoleState();
}

class PersonnelRoleState extends ConsumerState<PersonnelRole> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(collPersonnelRoleProvider).when(
          data: (data) {
            return DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: widget.controller.roleCtr,
              decoration: const InputDecoration(
                labelText: 'Role',
                hintText: 'Enter a role',
              ),
              items: data
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: CommonDropdownText(text: role),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.controller.roleCtr = value;
                  CollEventServices(ref: ref).updateCollPersonnel(
                    widget.controller.id!,
                    CollPersonnelCompanion(
                      eventID: db.Value(widget.eventID),
                      role: db.Value(value),
                    ),
                  );
                }
              },
            );
          },
          loading: () => const CommonProgressIndicator(),
          error: (error, _) {
            return const Text('Error');
          },
        );
  }
}

class EventPersonnelInfoContent extends StatelessWidget {
  const EventPersonnelInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          content: 'Personnel involves in the event.'
              ' We recommend adding anyone involved in the event.'
              ' For instance, if someone drive you to the site, add them.',
        ),
      ],
    );
  }
}
