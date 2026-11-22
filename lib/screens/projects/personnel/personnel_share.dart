import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/shared/dialogs/project_exchange_dialogs.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/screens/shared/media/media_export_dialog.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/media/media_export_service.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/record_exchange/personnel_exchange_service.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as p;

enum _ShareAction { qr, json, photo }

/// Shares one person as a QR code or JSON file, and their photo on its own.
class PersonnelShareMenu extends ConsumerWidget {
  const PersonnelShareMenu({super.key, required this.personnel});

  final PersonnelData personnel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final photo = ref
        .watch(personnelPhotoFileProvider(personnel.photoPath))
        .value;
    return MenuAnchor(
      builder: (context, controller, _) => OutlinedButton.icon(
        key: const ValueKey('personnel-share-menu'),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(Icons.share_outlined),
        label: Text(l10n.personnelShare),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.qr_code_2),
          onPressed: () => _run(context, ref, _ShareAction.qr, photo),
          child: Text(l10n.personnelShareQr),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.data_object),
          onPressed: () => _run(context, ref, _ShareAction.json, photo),
          child: Text(l10n.personnelShareExportJson),
        ),
        if (photo != null)
          MenuItemButton(
            leadingIcon: const Icon(Icons.photo_outlined),
            onPressed: () => _run(context, ref, _ShareAction.photo, photo),
            child: Text(l10n.personnelSharePhoto),
          ),
      ],
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    _ShareAction action,
    File? photo,
  ) async {
    switch (action) {
      case _ShareAction.qr:
        await _showQr(context);
      case _ShareAction.json:
        await showPersonnelExportDialog(context: context, personnel: personnel);
      case _ShareAction.photo:
        if (photo != null) await _sharePhoto(context, ref, photo);
    }
  }

  Future<void> _showQr(BuildContext context) async {
    final data = PersonnelExchangeService.encodeQr(personnel);
    if (!canEncodeQrPayload(data)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.personnelShareQrTooLarge)),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => QrCodeDialog(
        title: context.l10n.personnelShareQrTitle,
        data: data,
        description: context.l10n.personnelShareQrDescription,
        fileStem: PersonnelExchangeService.safeFileStem(
          personnel.name ?? 'personnel',
        ),
      ),
    );
  }

  /// Opens the media export flow on a copy named after the person, so the
  /// receiver can tell whose photo it is.
  Future<void> _sharePhoto(
    BuildContext context,
    WidgetRef ref,
    File photo,
  ) async {
    final service = MediaExportService(ref: ref);
    final extension = p.extension(photo.path).replaceFirst('.', '');
    await showMediaExportDialog(
      context: context,
      prepare: () async => service.prepareImageBytes(
        bytes: await photo.readAsBytes(),
        fileStem: PersonnelExchangeService.safeFileStem(
          personnel.name ?? 'personnel',
        ),
        extension: extension.isEmpty ? 'jpg' : extension,
      ),
      onExport:
          ({
            required source,
            required format,
            required fileStem,
            destinationDirectory,
            width,
            height,
            required jpegQuality,
          }) => service.export(
            source: source,
            format: format,
            fileStem: fileStem,
            destinationDirectory: destinationDirectory,
            width: width,
            height: height,
            jpegQuality: jpegQuality,
          ),
    );
  }
}

/// App bar actions that bring a shared person to this device.
class PersonnelImportActions extends ConsumerWidget {
  const PersonnelImportActions({super.key, this.canScan});

  /// Overrides camera support detection, for tests.
  final bool? canScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canScan ?? supportsCameraScanning)
          IconButton(
            key: const ValueKey('personnel-import-scan'),
            tooltip: l10n.personnelImportScanQr,
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scan(context, ref),
          ),
        IconButton(
          key: const ValueKey('personnel-import-json'),
          tooltip: l10n.personnelImportJson,
          icon: const Icon(Icons.file_download_outlined),
          onPressed: () => _importJson(context, ref),
        ),
      ],
    );
  }

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final payload = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (scannerContext) => ScannerScreen(
          onDetect: (capture) {
            final rawValue = capture.barcodes.firstOrNull?.rawValue;
            if (rawValue != null) Navigator.of(scannerContext).pop(rawValue);
          },
        ),
      ),
    );
    if (payload == null || !context.mounted) return;
    final PersonnelData person;
    try {
      person = PersonnelExchangeService.decode(payload);
    } on FormatException {
      _showMessage(context, context.l10n.personnelImportInvalid);
      return;
    }
    await reviewPersonnelImport(context, ref, person);
  }

  Future<void> _importJson(BuildContext context, WidgetRef ref) async {
    final file = await FilePickerServices().selectJsonFile();
    if (file == null || !context.mounted) return;
    final PersonnelData person;
    try {
      person = await const PersonnelExchangeService().read(file);
    } on FormatException {
      if (context.mounted) {
        _showMessage(context, context.l10n.personnelImportInvalid);
      }
      return;
    }
    if (!context.mounted) return;
    await reviewPersonnelImport(context, ref, person);
  }
}

/// Shows what importing [incoming] would change, then adds, updates, or
/// keeps the person as the user chooses.
Future<void> reviewPersonnelImport(
  BuildContext context,
  WidgetRef ref,
  PersonnelData incoming,
) async {
  final importer = PersonnelImporter(ref.read(databaseProvider));
  final preview = await importer.preview(incoming);
  if (!context.mounted) return;
  final choice = await showAdaptiveSheetDialog<PersonnelImportChoice>(
    context: context,
    builder: (context, isSheet) =>
        PersonnelImportReview(preview: preview, showCloseButton: !isSheet),
  );
  if (choice == null || !context.mounted) return;
  try {
    await importer.apply(
      incoming,
      updateExisting: choice == PersonnelImportChoice.update,
      projectUuid: ref.read(projectUuidProvider),
    );
    PersonnelServices(ref: ref).invalidatePersonnel();
    if (!context.mounted) return;
    _showMessage(context, context.l10n.personnelImported(incoming.name ?? ''));
  } catch (error) {
    if (context.mounted) _showMessage(context, error.toString());
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

enum PersonnelImportChoice { add, update, keep }

/// The review step of a personnel import: who is coming in and, for someone
/// already on this device, which fields would change.
class PersonnelImportReview extends StatelessWidget {
  const PersonnelImportReview({
    super.key,
    required this.preview,
    this.showCloseButton = true,
  });

  final PersonnelImportPreview preview;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final incoming = preview.incoming;
    final close = Navigator.of(context).pop;
    return AdaptiveSheetDialogBody(
      title: l10n.personnelImportTitle,
      showCloseButton: showCloseButton,
      actions: preview.isNew
          ? [
              FilledButton.icon(
                onPressed: () => close(PersonnelImportChoice.add),
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: Text(l10n.personnelImportAdd),
              ),
            ]
          : [
              OutlinedButton(
                onPressed: () => close(PersonnelImportChoice.keep),
                child: Text(l10n.personnelImportKeep),
              ),
              if (preview.changes.isNotEmpty)
                FilledButton(
                  onPressed: () => close(PersonnelImportChoice.update),
                  child: Text(l10n.personnelImportUpdate),
                ),
            ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(incoming.name ?? ''),
            subtitle: Text(
              [
                incoming.initial,
                if (incoming.role != null)
                  personnelRoleLabel(l10n, incoming.role!),
              ].whereType<String>().join(' · '),
            ),
          ),
          Text(
            preview.isNew
                ? l10n.personnelImportNew
                : preview.changes.isEmpty
                ? '${l10n.personnelImportExisting} ${l10n.personnelImportNoChanges}'
                : l10n.personnelImportExisting,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          for (final change in preview.changes)
            _PersonnelChangeRow(change: change),
        ],
      ),
    );
  }
}

class _PersonnelChangeRow extends StatelessWidget {
  const _PersonnelChangeRow({required this.change});

  final PersonnelFieldChange change;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: NahpuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fieldLabel(l10n, change.field),
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: NahpuSpacing.xxs),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: _display(l10n, change.field, change.current),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const TextSpan(text: '  →  '),
                TextSpan(text: _display(l10n, change.field, change.incoming)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fieldLabel(AppLocalizations l10n, PersonnelField field) {
    return switch (field) {
      PersonnelField.name => l10n.personnelFieldName,
      PersonnelField.initial => l10n.projectPersonnelInitials,
      PersonnelField.email => l10n.projectPersonnelEmail,
      PersonnelField.phone => l10n.projectPersonnelPhone,
      PersonnelField.affiliation => l10n.projectPersonnelAffiliation,
      PersonnelField.orcid => l10n.projectPersonnelOrcid,
      PersonnelField.role => l10n.projectPersonnelSpecimenCareRole,
      PersonnelField.currentFieldNumber =>
        l10n.projectPersonnelCurrentFieldNumber,
      PersonnelField.notes => l10n.projectPersonnelNotes,
      PersonnelField.isRegisterField =>
        l10n.projectPersonnelRegisterFieldNumber,
    };
  }

  String _display(AppLocalizations l10n, PersonnelField field, Object? value) {
    if (value == null) return '—';
    if (value is bool) {
      return value ? l10n.projectEnabled : l10n.projectDisabled;
    }
    if (field == PersonnelField.role) {
      return personnelRoleLabel(l10n, value.toString());
    }
    return value.toString();
  }
}
