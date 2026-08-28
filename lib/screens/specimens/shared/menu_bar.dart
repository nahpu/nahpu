import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/dialogs/record_sort_dialog.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/screens/shared/actions/record_exchange_actions.dart';

Future<void> createNewSpecimens(BuildContext context, WidgetRef ref) async {
  final newUuid = await SpecimenServices(ref: ref).createSpecimen();
  // Refresh the always-mounted viewer in place and land on the new specimen.
  ref
      .read(pendingRecordJumpProvider(RecordViewer.specimen).notifier)
      .updateState(newUuid);
  ref.invalidate(specimenEntryProvider);
}

class NewSpecimensTextButton extends ConsumerStatefulWidget {
  const NewSpecimensTextButton({super.key});

  @override
  NewSpecimensTextButtonState createState() => NewSpecimensTextButtonState();
}

class NewSpecimensTextButtonState
    extends ConsumerState<NewSpecimensTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        try {
          await createNewSpecimens(context, ref);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      },
      child: const Text('Create specimen'),
    );
  }
}

class NewSpecimens extends ConsumerStatefulWidget {
  const NewSpecimens({super.key});

  @override
  NewSpecimensState createState() => NewSpecimensState();
}

class NewSpecimensState extends ConsumerState<NewSpecimens> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline_rounded),
      onPressed: () async {
        try {
          await createNewSpecimens(context, ref);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      },
    );
  }
}

class SpecimenMenu extends ConsumerStatefulWidget {
  const SpecimenMenu({
    super.key,
    required this.specimenUuid,
    required this.catalogFmt,
  });

  final String? specimenUuid;
  final CatalogFmt? catalogFmt;

  @override
  SpecimenMenuState createState() => SpecimenMenuState();
}

class SpecimenMenuState extends ConsumerState<SpecimenMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          child: CreateMenuButton(text: _getNewSpecimenLabel()),
          onTap: () => createNewSpecimens(context, ref),
        ),
        PopupMenuItem(
          onTap: widget.specimenUuid == null
              ? null
              : () async {
                  await _duplicatePart();
                },
          child: const DuplicateMenuButton(text: 'Duplicate part'),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          onTap: () => showRecordSortDialog(
            context: context,
            viewer: RecordViewer.specimen,
          ),
          child: const SortMenuButton(),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          enabled: widget.specimenUuid != null,
          onTap: widget.specimenUuid == null
              ? null
              : () => RecordExchangeActions(
                  context: context,
                  ref: ref,
                ).exportSpecimenRecord(widget.specimenUuid!),
          child: const ListTile(
            leading: Icon(Icons.file_upload_outlined),
            title: Text('Export specimen'),
          ),
        ),
        PopupMenuItem(
          onTap: () => RecordExchangeActions(
            context: context,
            ref: ref,
          ).importSpecimenRecord(initialTargetUuid: widget.specimenUuid),
          child: const ListTile(
            leading: Icon(Icons.file_download_outlined),
            title: Text('Import specimen'),
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          child: const DeleteMenuButton(deleteAll: false),
          onTap: () => _deleteSpecimen(),
        ),
        PopupMenuItem(
          child: const DeleteMenuButton(deleteAll: true),
          onTap: () => _deleteAllSpecimens(),
        ),
      ],
    );
  }

  String _getNewSpecimenLabel() {
    return 'Create specimen';
  }

  Future<void> _duplicatePart() async {
    try {
      final newUuid = await SpecimenServices(
        ref: ref,
      ).createSpecimenDuplicatePart(widget.specimenUuid!);
      if (newUuid != null) {
        ref
            .read(pendingRecordJumpProvider(RecordViewer.specimen).notifier)
            .updateState(newUuid);
      }
      ref.invalidate(specimenEntryProvider);
    } catch (e) {
      if (context.mounted) {
        _showError('Error duplicating part: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _deleteSpecimen() {
    showDeleteAlertOnMenu(
      context: context,
      title: 'Delete specimen?',
      deletePrompt:
          'You will delete this specimen record, all measurements, and specimen parts.\n'
          'You will need to manually update the field number.',
      onDelete: () async {
        if (widget.specimenUuid != null && widget.catalogFmt != null) {
          try {
            await SpecimenServices(
              ref: ref,
            ).deleteSpecimen(widget.specimenUuid!, widget.catalogFmt!);
            if (context.mounted) {
              _pop();
            }
            ref.invalidate(specimenEntryProvider);
          } catch (e) {
            if (context.mounted) {
              _showError('Error deleting specimen: $e');
            }
          }
        }
      },
    );
  }

  void _pop() {
    Navigator.pop(context);
  }

  void _deleteAllSpecimens() {
    final projectUuid = ref.read(projectUuidProvider);
    showDeleteAlertOnMenu(
      context: context,
      title: 'Delete all specimens?',
      deletePrompt:
          'It will remove all specimens records'
          ', measurements, and specimen parts',
      onDelete: () async {
        try {
          await SpecimenServices(ref: ref).deleteAllSpecimens(projectUuid);
          if (context.mounted) {
            _pop();
          }
        } catch (e) {
          if (context.mounted) {
            _pop();
            _showError('Error deleting all specimens: $e');
          }
        }
      },
    );
  }
}
