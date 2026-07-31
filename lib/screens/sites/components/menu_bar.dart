import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/screens/shared/actions/record_exchange_actions.dart';
import 'package:nahpu/screens/sites/components/copy_from_project_dialog.dart';
import 'package:nahpu/services/site_services.dart';

Future<void> createNewSite(BuildContext context, WidgetRef ref) {
  return SiteServices(ref: ref).createNewSite().then((newId) {
    // Refresh the always-mounted viewer in place and land on the new site.
    ref
        .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
        .updateState(newId);
    ref.invalidate(siteEntryProvider);
  });
}

class NewSiteTextButton extends ConsumerStatefulWidget {
  const NewSiteTextButton({super.key});

  @override
  NewSiteTextButtonState createState() => NewSiteTextButtonState();
}

class NewSiteTextButtonState extends ConsumerState<NewSiteTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        try {
          await createNewSite(context, ref);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      },
      child: const Text('Create site'),
    );
  }
}

class NewSite extends ConsumerStatefulWidget {
  const NewSite({super.key});

  @override
  NewSiteState createState() => NewSiteState();
}

class NewSiteState extends ConsumerState<NewSite> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline_rounded),
      onPressed: () async {
        try {
          await createNewSite(context, ref);
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

class SiteMenu extends ConsumerStatefulWidget {
  const SiteMenu({super.key, required this.siteId});

  final int? siteId;

  @override
  SiteMenuState createState() => SiteMenuState();
}

class SiteMenuState extends ConsumerState<SiteMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          child: const CreateMenuButton(text: 'Create site'),
          onTap: () => createNewSite(context, ref),
        ),
        PopupMenuItem(
          onTap: widget.siteId == null
              ? null
              : () async => await _duplicateSite(),
          child: const DuplicateMenuButton(text: 'Duplicate site'),
        ),
        PopupMenuItem(
          enabled: widget.siteId != null,
          onTap: widget.siteId == null ? null : _copyFromProject,
          child: const ListTile(
            leading: Icon(Icons.content_copy_outlined),
            title: Text('Copy from project ...'),
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          enabled: widget.siteId != null,
          onTap: widget.siteId == null
              ? null
              : () => RecordExchangeActions(
                  context: context,
                  ref: ref,
                ).showSiteQr(widget.siteId!),
          child: const ListTile(
            leading: Icon(Icons.qr_code_outlined),
            title: Text('Show QR'),
          ),
        ),
        PopupMenuItem(
          enabled: widget.siteId != null,
          onTap: widget.siteId == null
              ? null
              : () => RecordExchangeActions(
                  context: context,
                  ref: ref,
                ).exportSiteRecord(widget.siteId!),
          child: const ListTile(
            leading: Icon(Icons.file_upload_outlined),
            title: Text('Export site'),
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          onTap: () => RecordExchangeActions(
            context: context,
            ref: ref,
          ).scanSiteQr(initialTargetId: widget.siteId),
          child: const ListTile(
            leading: Icon(Icons.qr_code_scanner_outlined),
            title: Text('Scan QR'),
          ),
        ),
        PopupMenuItem(
          onTap: () => RecordExchangeActions(
            context: context,
            ref: ref,
          ).importSiteRecord(initialTargetId: widget.siteId),
          child: const ListTile(
            leading: Icon(Icons.file_download_outlined),
            title: Text('Import site'),
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          enabled: widget.siteId != null,
          onTap: () => _deleteSite(),
          child: const DeleteMenuButton(deleteAll: false),
        ),
        PopupMenuItem(
          enabled: widget.siteId != null,
          onTap: () => _deleteAllSites(),
          child: const DeleteMenuButton(deleteAll: true),
        ),
      ],
    );
  }

  Future<void> _duplicateSite() async {
    try {
      final newId = await SiteServices(ref: ref).duplicateSite(widget.siteId!);
      if (newId != null) {
        ref
            .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
            .updateState(newId);
      }
      ref.invalidate(siteEntryProvider);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _copyFromProject() async {
    final result = await showCopyFromProjectDialog(
      context: context,
      targetSiteId: widget.siteId!,
    );
    if (!mounted || result == null) return;
    ref.invalidate(siteEntryProvider);
    ref.invalidate(coordinateBySiteProvider(widget.siteId!));
    ref.invalidate(coordinateByProjectProvider);
    ref.invalidate(projectPersonnelProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied ${result.fieldCount} ${result.fieldCount == 1 ? 'field' : 'fields'} '
          'and ${result.coordinateCount} '
          '${result.coordinateCount == 1 ? 'coordinate' : 'coordinates'} '
          'from ${result.sourceSiteLabel} in ${result.sourceProjectName}.',
        ),
      ),
    );
  }

  Future<void> _deleteSite() async {
    showDeleteAlertOnMenu(
      context: context,
      title: 'Delete site?',
      deletePrompt: 'You will delete all records in this site form',
      onDelete: () async {
        if (widget.siteId != null) {
          try {
            await SiteServices(ref: ref).deleteSite(widget.siteId!);

            // Close the delete dialog.
            if (mounted) {
              Navigator.pop(context);
            }
            ref.invalidate(siteEntryProvider);
          } catch (e) {
            _showError(e.toString());
          }
        }
      },
    );
  }

  void _deleteAllSites() {
    final projectUuid = ref.read(projectUuidProvider);
    showDeleteAlertOnMenu(
      context: context,
      title: 'Delete all sites?',
      deletePrompt: 'You will delete all site records',
      onDelete: () async {
        try {
          await SiteServices(ref: ref).deleteAllSites(projectUuid);
          if (context.mounted) {
            _popMenu();
          }
        } catch (e) {
          _showError(e.toString());
        }
      },
    );
  }

  void _popMenu() {
    Navigator.pop(context);
  }

  void _showError(String errors) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errors.contains('SqliteException(787)')
              ? 'Cannot delete sites. Being used by other records.'
              : errors.toString(),
        ),
      ),
    );
  }
}
