import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/dialogs/record_sort_dialog.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/screens/shared/actions/record_exchange_actions.dart';
import 'package:nahpu/services/localization/l10n.dart';

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
      child: Text(context.l10n.specimenCreate),
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

enum _SpecimenMenuAction {
  create,
  duplicatePart,
  sort,
  export,
  import,
  delete,
  deleteAll,
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
    return AdaptiveMenuButton<_SpecimenMenuAction>(
      tooltip: context.l10n.specimenActions,
      itemBuilder: _items,
      onSelected: _onSelected,
    );
  }

  List<AdaptiveMenuItem<_SpecimenMenuAction>> _items() {
    final hasSpecimen = widget.specimenUuid != null;
    return [
      AdaptiveMenuItem(
        value: _SpecimenMenuAction.create,
        icon: Icons.create_outlined,
        label: _getNewSpecimenLabel(),
      ),
      AdaptiveMenuItem(
        value: _SpecimenMenuAction.duplicatePart,
        icon: Icons.copy_outlined,
        label: context.l10n.specimenDuplicatePart,
        enabled: hasSpecimen,
      ),
      AdaptiveMenuItem(
        value: _SpecimenMenuAction.sort,
        icon: Icons.sort_rounded,
        label: context.l10n.commonSortRecords,
        hasDividerBefore: true,
      ),
      AdaptiveMenuItem(
        value: _SpecimenMenuAction.export,
        icon: Icons.file_upload_outlined,
        label: context.l10n.specimenExport,
        enabled: hasSpecimen,
        hasDividerBefore: true,
      ),
      AdaptiveMenuItem(
        value: _SpecimenMenuAction.import,
        icon: Icons.file_download_outlined,
        label: context.l10n.specimenImport,
      ),
      AdaptiveMenuItem(
        value: _SpecimenMenuAction.delete,
        icon: Icons.delete_outline,
        label: context.l10n.commonDeleteRecord,
        isDestructive: true,
        hasDividerBefore: true,
      ),
      AdaptiveMenuItem(
        value: _SpecimenMenuAction.deleteAll,
        icon: Icons.delete_forever_outlined,
        label: context.l10n.commonDeleteAllRecords,
        isDestructive: true,
      ),
    ];
  }

  void _onSelected(_SpecimenMenuAction action) {
    final exchange = RecordExchangeActions(context: context, ref: ref);
    switch (action) {
      case _SpecimenMenuAction.create:
        createNewSpecimens(context, ref);
      case _SpecimenMenuAction.duplicatePart:
        _duplicatePart();
      case _SpecimenMenuAction.sort:
        showRecordSortDialog(context: context, viewer: RecordViewer.specimen);
      case _SpecimenMenuAction.export:
        exchange.exportSpecimenRecord(widget.specimenUuid!);
      case _SpecimenMenuAction.import:
        exchange.importSpecimenRecord(initialTargetUuid: widget.specimenUuid);
      case _SpecimenMenuAction.delete:
        _deleteSpecimen();
      case _SpecimenMenuAction.deleteAll:
        _deleteAllSpecimens();
    }
  }

  String _getNewSpecimenLabel() {
    return context.l10n.specimenCreate;
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
      if (mounted) {
        _showError(context.l10n.specimenDuplicatePartError('$e'));
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
      title: context.l10n.specimenDeleteTitle,
      deletePrompt: context.l10n.specimenDeleteBody,
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
            if (mounted) {
              _showError(context.l10n.specimenDeleteError('$e'));
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
      title: context.l10n.specimenDeleteAllTitle,
      deletePrompt: context.l10n.specimenDeleteAllBody,
      onDelete: () async {
        try {
          await SpecimenServices(ref: ref).deleteAllSpecimens(projectUuid);
          if (context.mounted) {
            _pop();
          }
        } catch (e) {
          if (mounted) {
            _pop();
            _showError(context.l10n.specimenDeleteAllError('$e'));
          }
        }
      },
    );
  }
}
