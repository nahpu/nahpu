import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/dialogs/record_sort_dialog.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/screens/shared/actions/record_exchange_actions.dart';
import 'package:nahpu/screens/sites/components/copy_from_project_dialog.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/localization/l10n.dart';

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
      child: Text(context.l10n.siteCreate),
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

enum _SiteMenuAction {
  create,
  duplicate,
  copyFromProject,
  sort,
  showQr,
  export,
  scanQr,
  import,
  delete,
  deleteAll,
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
    return AdaptiveMenuButton<_SiteMenuAction>(
      tooltip: context.l10n.siteActions,
      itemBuilder: _items,
      onSelected: _onSelected,
    );
  }

  List<AdaptiveMenuItem<_SiteMenuAction>> _items() {
    final hasSite = widget.siteId != null;
    return [
      AdaptiveMenuItem(
        value: _SiteMenuAction.create,
        icon: Icons.create_outlined,
        label: context.l10n.siteCreate,
      ),
      AdaptiveMenuItem(
        value: _SiteMenuAction.duplicate,
        icon: Icons.copy_outlined,
        label: context.l10n.siteDuplicate,
        enabled: hasSite,
      ),
      AdaptiveMenuItem(
        value: _SiteMenuAction.copyFromProject,
        icon: Icons.content_copy_outlined,
        label: context.l10n.siteCopyFromProjectMenu,
        enabled: hasSite,
      ),
      AdaptiveMenuItem(
        value: _SiteMenuAction.sort,
        icon: Icons.sort_rounded,
        label: context.l10n.commonSortRecords,
        hasDividerBefore: true,
      ),
      AdaptiveMenuItem(
        value: _SiteMenuAction.showQr,
        icon: Icons.qr_code_outlined,
        label: context.l10n.homeProjectShowQr,
        enabled: hasSite,
        hasDividerBefore: true,
      ),
      AdaptiveMenuItem(
        value: _SiteMenuAction.export,
        icon: Icons.file_upload_outlined,
        label: context.l10n.siteExport,
        enabled: hasSite,
      ),
      if (supportsCameraScanning)
        AdaptiveMenuItem(
          value: _SiteMenuAction.scanQr,
          icon: Icons.qr_code_scanner_outlined,
          label: context.l10n.sharedPresetScanQr,
          hasDividerBefore: true,
        ),
      AdaptiveMenuItem(
        value: _SiteMenuAction.import,
        icon: Icons.file_download_outlined,
        label: context.l10n.siteImport,
        hasDividerBefore: !supportsCameraScanning,
      ),
      AdaptiveMenuItem(
        value: _SiteMenuAction.delete,
        icon: Icons.delete_outline,
        label: context.l10n.commonDeleteRecord,
        enabled: hasSite,
        isDestructive: true,
        hasDividerBefore: true,
      ),
      AdaptiveMenuItem(
        value: _SiteMenuAction.deleteAll,
        icon: Icons.delete_forever_outlined,
        label: context.l10n.commonDeleteAllRecords,
        enabled: hasSite,
        isDestructive: true,
      ),
    ];
  }

  void _onSelected(_SiteMenuAction action) {
    final exchange = RecordExchangeActions(context: context, ref: ref);
    switch (action) {
      case _SiteMenuAction.create:
        createNewSite(context, ref);
      case _SiteMenuAction.duplicate:
        _duplicateSite();
      case _SiteMenuAction.copyFromProject:
        _copyFromProject();
      case _SiteMenuAction.sort:
        showRecordSortDialog(context: context, viewer: RecordViewer.site);
      case _SiteMenuAction.showQr:
        exchange.showSiteQr(widget.siteId!);
      case _SiteMenuAction.export:
        exchange.exportSiteRecord(widget.siteId!);
      case _SiteMenuAction.scanQr:
        exchange.scanSiteQr(initialTargetId: widget.siteId);
      case _SiteMenuAction.import:
        exchange.importSiteRecord(initialTargetId: widget.siteId);
      case _SiteMenuAction.delete:
        _deleteSite();
      case _SiteMenuAction.deleteAll:
        _deleteAllSites();
    }
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
          context.l10n.siteCopiedSummary(
            context.l10n.siteFieldCount(result.fieldCount),
            context.l10n.sharedCoordinateCount(result.coordinateCount),
            result.sourceSiteLabel,
            result.sourceProjectName,
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSite() async {
    showDeleteAlertOnMenu(
      context: context,
      title: context.l10n.siteDeleteTitle,
      deletePrompt: context.l10n.siteDeleteBody,
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
      title: context.l10n.siteDeleteAllTitle,
      deletePrompt: context.l10n.siteDeleteAllBody,
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
              ? context.l10n.siteDeleteInUse
              : errors.toString(),
        ),
      ),
    );
  }
}
