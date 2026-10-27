import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/dialogs/record_sort_dialog.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/record_exchange_actions.dart';
import 'package:nahpu/services/localization/l10n.dart';

Future<void> createNewCollEvents(BuildContext context, WidgetRef ref) {
  CollEventServices services = CollEventServices(ref: ref);

  return services.createNewCollEvents().then((newId) {
    // Refresh the always-mounted viewer in place and land on the new event.
    ref
        .read(pendingRecordJumpProvider(RecordViewer.collEvent).notifier)
        .updateState(newId);
    ref.invalidate(collEventEntryProvider);
  });
}

class NewCollEventTextButton extends ConsumerStatefulWidget {
  const NewCollEventTextButton({super.key});

  @override
  NewCollEventTextButtonState createState() => NewCollEventTextButtonState();
}

class NewCollEventTextButtonState
    extends ConsumerState<NewCollEventTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        try {
          await createNewCollEvents(context, ref);
        } catch (e) {
          _showError(e.toString());
        }
      },
      child: Text(context.l10n.eventCreate),
    );
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errors.contains('SqliteException(787)')
              ? context.l10n.eventDeleteInUse
              : errors.toString(),
        ),
      ),
    );
  }
}

class NewCollEvents extends ConsumerWidget {
  const NewCollEvents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline_rounded),
      onPressed: () async {
        createNewCollEvents(context, ref);
      },
    );
  }
}

enum _EventMenuAction {
  create,
  duplicate,
  sort,
  showQr,
  export,
  scanQr,
  import,
  delete,
  deleteAll,
}

class CollEventMenu extends ConsumerStatefulWidget {
  const CollEventMenu({super.key, required this.collEventId});

  final int? collEventId;

  @override
  NarrativeMenuState createState() => NarrativeMenuState();
}

class NarrativeMenuState extends ConsumerState<CollEventMenu> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveMenuButton<_EventMenuAction>(
      tooltip: context.l10n.eventActions,
      itemBuilder: _items,
      onSelected: _onSelected,
    );
  }

  List<AdaptiveMenuItem<_EventMenuAction>> _items() {
    final hasEvent = widget.collEventId != null;
    return [
      AdaptiveMenuItem(
        value: _EventMenuAction.create,
        icon: Icons.create_outlined,
        label: context.l10n.eventCreate,
      ),
      AdaptiveMenuItem(
        value: _EventMenuAction.duplicate,
        icon: Icons.copy_outlined,
        label: context.l10n.eventDuplicate,
        enabled: hasEvent,
      ),
      AdaptiveMenuItem(
        value: _EventMenuAction.sort,
        icon: Icons.sort_rounded,
        label: context.l10n.commonSortRecords,
        hasDividerBefore: true,
      ),
      AdaptiveMenuItem(
        value: _EventMenuAction.showQr,
        icon: Icons.qr_code_outlined,
        label: context.l10n.homeProjectShowQr,
        enabled: hasEvent,
        hasDividerBefore: true,
      ),
      AdaptiveMenuItem(
        value: _EventMenuAction.export,
        icon: Icons.file_upload_outlined,
        label: context.l10n.eventExport,
        enabled: hasEvent,
      ),
      if (supportsCameraScanning)
        AdaptiveMenuItem(
          value: _EventMenuAction.scanQr,
          icon: Icons.qr_code_scanner_outlined,
          label: context.l10n.sharedPresetScanQr,
          hasDividerBefore: true,
        ),
      AdaptiveMenuItem(
        value: _EventMenuAction.import,
        icon: Icons.file_download_outlined,
        label: context.l10n.eventImport,
        hasDividerBefore: !supportsCameraScanning,
      ),
      AdaptiveMenuItem(
        value: _EventMenuAction.delete,
        icon: Icons.delete_outline,
        label: context.l10n.commonDeleteRecord,
        isDestructive: true,
        hasDividerBefore: true,
      ),
      AdaptiveMenuItem(
        value: _EventMenuAction.deleteAll,
        icon: Icons.delete_forever_outlined,
        label: context.l10n.commonDeleteAllRecords,
        isDestructive: true,
      ),
    ];
  }

  void _onSelected(_EventMenuAction action) {
    final exchange = RecordExchangeActions(context: context, ref: ref);
    switch (action) {
      case _EventMenuAction.create:
        createNewCollEvents(context, ref);
      case _EventMenuAction.duplicate:
        _duplicateEvent();
      case _EventMenuAction.sort:
        showRecordSortDialog(context: context, viewer: RecordViewer.collEvent);
      case _EventMenuAction.showQr:
        exchange.showEventQr(widget.collEventId!);
      case _EventMenuAction.export:
        exchange.exportEventRecord(widget.collEventId!);
      case _EventMenuAction.scanQr:
        exchange.scanEventQr(initialTargetId: widget.collEventId);
      case _EventMenuAction.import:
        exchange.importEventRecord(initialTargetId: widget.collEventId);
      case _EventMenuAction.delete:
        _deleteEvent();
      case _EventMenuAction.deleteAll:
        _deleteAllEvents();
    }
  }

  void _deleteEvent() {
    if (widget.collEventId != null) {
      showDeleteAlertOnMenu(
        context: context,
        title: context.l10n.eventDeleteTitle,
        deletePrompt: context.l10n.eventDeleteBody,
        onDelete: () async {
          try {
            await CollEventServices(
              ref: ref,
            ).deleteCollEvent(widget.collEventId!);
            // Close the delete dialog.
            if (mounted) {
              Navigator.of(context).pop();
            }
            ref.invalidate(collEventEntryProvider);
          } catch (e) {
            _showError(e.toString());
          }
        },
      );
    }
  }

  Future<void> _duplicateEvent() async {
    try {
      final newId = await EventDuplicateService(
        ref: ref,
      ).duplicate(widget.collEventId!);
      if (newId != null) {
        ref
            .read(pendingRecordJumpProvider(RecordViewer.collEvent).notifier)
            .updateState(newId);
      }
      ref.invalidate(collEventEntryProvider);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _deleteAllEvents() {
    final projectUuid = ref.read(projectUuidProvider);
    showDeleteAlertOnMenu(
      context: context,
      title: context.l10n.eventDeleteAllTitle,
      deletePrompt: context.l10n.eventDeleteAllBody,
      onDelete: () async {
        try {
          final service = CollEventServices(ref: ref);
          await service.deleteAllCollEvents(projectUuid);

          if (context.mounted) {
            _pop();
          }
        } catch (e) {
          _showError(e.toString());
        }
      },
    );
  }

  void _pop() {
    Navigator.pop(context);
  }

  void _showError(String errors) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errors.contains('SqliteException(787)')
              ? context.l10n.eventDeleteInUse
              : errors.toString(),
        ),
      ),
    );
  }
}
