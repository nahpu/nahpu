import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/record_exchange_actions.dart';

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
      child: const Text('Create event'),
    );
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errors.contains('SqliteException(787)')
              ? 'Failed to delete the events.'
                    ' The events are currently in use by other records.'
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

class CollEventMenu extends ConsumerStatefulWidget {
  const CollEventMenu({super.key, required this.collEventId});

  final int? collEventId;

  @override
  NarrativeMenuState createState() => NarrativeMenuState();
}

class NarrativeMenuState extends ConsumerState<CollEventMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          child: const CreateMenuButton(text: 'Create event'),
          onTap: () => createNewCollEvents(context, ref),
        ),
        PopupMenuItem(
          onTap: widget.collEventId == null
              ? null
              : () async => await _duplicateEvent(),
          child: const DuplicateMenuButton(text: 'Duplicate event'),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          enabled: widget.collEventId != null,
          onTap: widget.collEventId == null
              ? null
              : () => RecordExchangeActions(
                  context: context,
                  ref: ref,
                ).showEventQr(widget.collEventId!),
          child: const ListTile(
            leading: Icon(Icons.qr_code_outlined),
            title: Text('Show QR'),
          ),
        ),
        PopupMenuItem(
          enabled: widget.collEventId != null,
          onTap: widget.collEventId == null
              ? null
              : () => RecordExchangeActions(
                  context: context,
                  ref: ref,
                ).exportEventRecord(widget.collEventId!),
          child: const ListTile(
            leading: Icon(Icons.file_upload_outlined),
            title: Text('Export event'),
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          onTap: () => RecordExchangeActions(
            context: context,
            ref: ref,
          ).scanEventQr(initialTargetId: widget.collEventId),
          child: const ListTile(
            leading: Icon(Icons.qr_code_scanner_outlined),
            title: Text('Scan QR'),
          ),
        ),
        PopupMenuItem(
          onTap: () => RecordExchangeActions(
            context: context,
            ref: ref,
          ).importEventRecord(initialTargetId: widget.collEventId),
          child: const ListTile(
            leading: Icon(Icons.file_download_outlined),
            title: Text('Import event'),
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          child: const DeleteMenuButton(deleteAll: false),
          onTap: () => _deleteEvent(),
        ),
        PopupMenuItem(
          child: const DeleteMenuButton(deleteAll: true),
          onTap: () => _deleteAllEvents(),
        ),
      ],
    );
  }

  void _deleteEvent() {
    if (widget.collEventId != null) {
      showDeleteAlertOnMenu(
        context: context,
        title: 'Delete collecting event?',
        deletePrompt:
            'You will also delete collecting effort'
            ', collecting personnel, weather data, and media in this event.',
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
      title: 'Delete all collecting events?',
      deletePrompt:
          'Deleting all collecting events will also delete all associated'
          ' collecting effort, collecting personnel, '
          'weather data, and media from the database.',
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
              ? 'Failed to delete the events.'
                    ' The events are currently in use by other records.'
              : errors.toString(),
        ),
      ),
    );
  }
}
