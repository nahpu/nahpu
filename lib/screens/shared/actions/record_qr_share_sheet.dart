import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/record_exchange/record_exchange_models.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// What the user picked in a [RecordQrShareSheet].
sealed class RecordQrShareChoice {
  const RecordQrShareChoice();
}

/// Show this payload as a QR code.
class ShowRecordQr extends RecordQrShareChoice {
  const ShowRecordQr(this.payload);

  final RecordExchangePayload payload;
}

/// Nothing fits in a QR code; export a file instead.
class ExportRecordFile extends RecordQrShareChoice {
  const ExportRecordFile();
}

/// Lets the user leave out personnel or site details so a site or event fits
/// in one QR code, naming those records by ID or site code instead.
class RecordQrShareSheet extends StatefulWidget {
  const RecordQrShareSheet({
    super.key,
    required this.title,
    required this.payload,
    required this.projectUuid,
    this.showCloseButton = true,
    this.fits = canEncodeQrPayload,
  });

  final String title;

  /// The payload with every related record in full.
  final RecordExchangePayload payload;

  /// The project a referenced site belongs to.
  final String projectUuid;
  final bool showCloseButton;

  /// Whether QR data fits in one code. Replaceable in tests.
  final bool Function(String data) fits;

  /// Whether the sheet has anything to choose for [payload].
  static bool offersChoice(RecordExchangePayload payload) =>
      payload.canReferencePersonnel || payload.hasLinkedSite;

  @override
  State<RecordQrShareSheet> createState() => _RecordQrShareSheetState();
}

class _RecordQrShareSheetState extends State<RecordQrShareSheet> {
  late bool _includePersonnel;
  late bool _includeSite;

  @override
  void initState() {
    super.initState();
    // Full details when they fit; otherwise the first smaller form that does.
    final options = [
      (true, true),
      if (widget.payload.canReferencePersonnel) (false, true),
      if (widget.payload.canReferenceSite) (true, false),
      if (widget.payload.canReferencePersonnel &&
          widget.payload.canReferenceSite)
        (false, false),
    ];
    final fitting = options.where((option) => _fitsWith(option.$1, option.$2));
    final chosen = fitting.isEmpty ? options.last : fitting.first;
    _includePersonnel = chosen.$1;
    _includeSite = chosen.$2;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final payload = _payload(_includePersonnel, _includeSite);
    final fits = widget.fits(payload.compactEncoded);
    return AdaptiveSheetDialogBody(
      title: widget.title,
      showCloseButton: widget.showCloseButton,
      actions: [
        if (fits)
          FilledButton.icon(
            key: const ValueKey('record-qr-show'),
            onPressed: () => Navigator.of(context).pop(ShowRecordQr(payload)),
            icon: const Icon(Icons.qr_code_2),
            label: Text(l10n.sharedRecordQrShow),
          )
        else
          FilledButton.icon(
            key: const ValueKey('record-qr-export'),
            onPressed: () =>
                Navigator.of(context).pop(const ExportRecordFile()),
            icon: const Icon(Icons.file_upload_outlined),
            label: Text(l10n.sharedExportRecordType(payload.type.name)),
          ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.payload.canReferencePersonnel)
            SwitchListTile(
              key: const ValueKey('record-qr-personnel'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.sharedRecordQrIncludePersonnel),
              subtitle: Text(l10n.sharedRecordQrIncludePersonnelHelp),
              value: _includePersonnel,
              onChanged: (value) => setState(() => _includePersonnel = value),
            ),
          if (widget.payload.hasLinkedSite)
            SwitchListTile(
              key: const ValueKey('record-qr-site'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.sharedRecordQrIncludeSite),
              subtitle: Text(
                widget.payload.canReferenceSite
                    ? l10n.sharedRecordQrIncludeSiteHelp
                    : l10n.sharedRecordQrSiteNeedsCode,
              ),
              value: _includeSite,
              onChanged: widget.payload.canReferenceSite
                  ? (value) => setState(() => _includeSite = value)
                  : null,
            ),
          const SizedBox(height: NahpuSpacing.md),
          Row(
            children: [
              Icon(
                fits ? Icons.check_circle_outline : Icons.error_outline,
                color: fits ? colors.primary : colors.error,
                size: NahpuControlSize.iconMedium,
              ),
              const SizedBox(width: NahpuSpacing.md),
              Expanded(
                child: Text(
                  fits
                      ? l10n.sharedRecordQrFits
                      : l10n.sharedRecordQrTooLargeShort,
                  key: const ValueKey('record-qr-fit'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: fits ? null : colors.error,
                  ),
                ),
              ),
            ],
          ),
          if (payload.usesReferences) ...[
            const SizedBox(height: NahpuSpacing.md),
            Text(
              l10n.sharedRecordQrNeedsRecords,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  RecordExchangePayload _payload(bool includePersonnel, bool includeSite) {
    return widget.payload.withReferences(
      includePersonnelDetails: includePersonnel,
      includeSiteDetails: includeSite,
      projectUuid: widget.projectUuid,
    );
  }

  bool _fitsWith(bool includePersonnel, bool includeSite) =>
      widget.fits(_payload(includePersonnel, includeSite).compactEncoded);
}

/// Explains why a shared record cannot be imported yet: it points to
/// personnel or a site that are not on this device.
class MissingRecordReferences extends StatelessWidget {
  const MissingRecordReferences({
    super.key,
    required this.check,
    this.showCloseButton = true,
  });

  final RecordReferenceCheck check;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final code = check.siteCode ?? '';
    return AdaptiveSheetDialogBody(
      key: const ValueKey('record-missing-references'),
      title: l10n.sharedRecordMissingTitle,
      description: l10n.sharedRecordMissingBody,
      showCloseButton: showCloseButton,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (check.missingPersonnel.isNotEmpty) ...[
            Text(
              l10n.sharedRecordMissingPersonnel,
              style: theme.textTheme.titleSmall,
            ),
            for (final person in check.missingPersonnel)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_off_outlined),
                title: Text(person.label),
              ),
          ],
          if (check.siteStatus == SiteReferenceStatus.missing)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.wrong_location_outlined),
              title: Text(l10n.sharedRecordMissingSite(code)),
            ),
          if (check.siteStatus == SiteReferenceStatus.otherProject)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.wrong_location_outlined),
              title: Text(l10n.sharedRecordSiteOtherProject(code)),
            ),
        ],
      ),
    );
  }
}
