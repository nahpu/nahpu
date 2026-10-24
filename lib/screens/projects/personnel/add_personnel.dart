import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/projects/personnel/new_personnel.dart';
import 'package:nahpu/screens/projects/personnel/select_personnel.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

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
        title: Text(context.l10n.recordsSpecimenAddPersonnel),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ref
            .watch(allPersonnelProvider)
            .when(
              data: (data) => data.isNotEmpty
                  ? const AddWithOptions()
                  : const NewPersonnel(),
              loading: () => const Center(child: CommonProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
            ),
      ),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.xl,
            NahpuSpacing.md,
            NahpuSpacing.xl,
            NahpuSpacing.lg,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < NahpuBreakpoints.compact;
              return SegmentedButton(
                selected: _selection,
                segments: [
                  ButtonSegment(
                    value: PersonnelSelection.selectPersonnel,
                    label: Text(
                      isCompact
                          ? context.l10n.projectPersonnelSelectExisting
                          : context.l10n.projectPersonnelSelectFromDatabase,
                    ),
                  ),
                  ButtonSegment(
                    value: PersonnelSelection.newPersonnel,
                    label: Text(
                      isCompact
                          ? context.l10n.projectPersonnelAddNew
                          : context.l10n.projectPersonnelAddNewPersonnel,
                    ),
                  ),
                ],
                showSelectedIcon: false,
                onSelectionChanged: (Set<PersonnelSelection> selection) {
                  setState(() {
                    _selection = selection;
                    ref.invalidate(projectPersonnelProvider);
                  });
                },
              );
            },
          ),
        ),
        Expanded(
          child: _selection.first == PersonnelSelection.newPersonnel
              ? const NewPersonnel()
              : ref
                    .watch(projectPersonnelProvider)
                    .when(
                      data: (data) => SelectPersonnel(addedPersonnel: data),
                      loading: () =>
                          const Center(child: CommonProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text(error.toString())),
                    ),
        ),
      ],
    );
  }
}
