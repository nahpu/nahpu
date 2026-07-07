import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/projects/personnel/new_personnel.dart';
import 'package:nahpu/screens/projects/personnel/select_personnel.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';

enum PersonnelSelection { selectPersonnel, newPersonnel }

class AddPersonnel extends ConsumerStatefulWidget {
  const AddPersonnel({super.key});

  @override
  AddPersonnelState createState() => AddPersonnelState();
}

class AddPersonnelState extends ConsumerState<AddPersonnel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add personnel'),
        automaticallyImplyLeading: false,
      ),
      body: ScrollableConstrainedLayout(
          child: ref.watch(allPersonnelProvider).when(
                data: (data) {
                  if (data.isNotEmpty) {
                    return const AddWithOptions();
                  } else {
                    return const NewPersonnel();
                  }
                },
                loading: () => const CommonProgressIndicator(),
                error: (error, stack) => Text(
                  error.toString(),
                ),
              )),
    );
  }
}

class AddWithOptions extends ConsumerStatefulWidget {
  const AddWithOptions({super.key});

  @override
  AddWithOptionsState createState() => AddWithOptionsState();
}

class AddWithOptionsState extends ConsumerState<AddWithOptions> {
  Set<PersonnelSelection> _selection = {PersonnelSelection.selectPersonnel};
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedButton(
          selected: _selection,
          segments: const [
            ButtonSegment(
              value: PersonnelSelection.selectPersonnel,
              label: Text('Select from database'),
            ),
            ButtonSegment(
              value: PersonnelSelection.newPersonnel,
              label: Text('Add new personnel'),
            ),
          ],
          showSelectedIcon: false,
          onSelectionChanged: (Set<PersonnelSelection> selection) {
            setState(() {
              _selection = selection;
              ref.invalidate(projectPersonnelProvider);
            });
          },
        ),
        const SizedBox(height: 32),
        _selection.first == PersonnelSelection.newPersonnel
            ? const NewPersonnel()
            : ref.watch(projectPersonnelProvider).when(
                  data: (data) {
                    return SelectPersonnel(addedPersonnel: data);
                  },
                  loading: () => const CommonProgressIndicator(),
                  error: (error, stack) => Text(error.toString()),
                ),
      ],
    );
  }
}
