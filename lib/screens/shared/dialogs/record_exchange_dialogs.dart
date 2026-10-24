import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/export/export_destination.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/record_exchange/record_exchange_service.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/geography.dart';

class RecordImportTargetChoice {
  const RecordImportTargetChoice({required this.targetId});

  final int? targetId;
}

Future<RecordImportTargetChoice?> showRecordImportTargetDialog({
  required BuildContext context,
  required RecordExchangePayload payload,
  required List<SiteRecord> sites,
  required List<CollEventData> events,
  int? initialTargetId,
  String? matchedLocality,
}) {
  final l10n = context.l10n;
  final isSite = payload.type == RecordExchangeType.site;
  final selectedRecords = isSite
      ? sites
            .map(
              (site) => _ImportTargetOption(site.id, _recordLabel(site, l10n)),
            )
            .toList()
      : events
            .map(
              (event) =>
                  _ImportTargetOption(event.id, _recordLabel(event, l10n)),
            )
            .toList();
  final typeName = payload.type.name;
  var selected =
      initialTargetId != null &&
          selectedRecords.any((record) => record.id == initialTargetId)
      ? initialTargetId
      : null;

  return showDialog<RecordImportTargetChoice>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(l10n.sharedImportRecordType(typeName)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payload.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(_summary(payload, l10n)),
                  if (matchedLocality != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.sharedReusesSavedLocality(matchedLocality),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  RadioGroup<int?>(
                    groupValue: selected,
                    onChanged: (value) => setState(() => selected = value),
                    child: Column(
                      children: [
                        RadioListTile<int?>(
                          value: null,
                          title: Text(l10n.sharedCreateNewRecordType(typeName)),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (selectedRecords.isNotEmpty) ...[
                          const Divider(),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.sharedUpdateExistingRecordType(typeName),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          ...selectedRecords.map(
                            (record) => RadioListTile<int?>(
                              value: record.id,
                              title: Text(record.label),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(RecordImportTargetChoice(targetId: selected)),
              child: Text(context.l10n.sharedContinue),
            ),
          ],
        );
      },
    ),
  );
}

class LinkedSiteChoice {
  const LinkedSiteChoice({this.siteId, this.createEmbeddedSite = false});

  final int? siteId;
  final bool createEmbeddedSite;
}

Future<LinkedSiteChoice?> showLinkedSiteDialog({
  required BuildContext context,
  required List<SiteRecord> sites,
}) {
  var selected = -1;
  return showDialog<LinkedSiteChoice>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(context.l10n.sharedChooseEventSite),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.sharedChooseEventSiteDescription),
                const SizedBox(height: 12),
                RadioGroup<int>(
                  groupValue: selected,
                  onChanged: (value) => setState(() => selected = value ?? -1),
                  child: Column(
                    children: [
                      RadioListTile<int>(
                        value: -1,
                        title: Text(context.l10n.sharedCreateEmbeddedSite),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (sites.isNotEmpty) ...[
                        const Divider(),
                        ...sites.map(
                          (site) => RadioListTile<int>(
                            value: site.id,
                            title: Text(_recordLabel(site, context.l10n)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              selected == -1
                  ? const LinkedSiteChoice(createEmbeddedSite: true)
                  : LinkedSiteChoice(siteId: selected),
            ),
            child: Text(context.l10n.sharedContinue),
          ),
        ],
      ),
    ),
  );
}

/// What the payload brings along, as separate items joined by a middle dot
/// so no sentence is assembled from translated fragments.
String _summary(RecordExchangePayload payload, AppLocalizations l10n) {
  final parts = <String>[
    if (payload.coordinateCount > 0)
      l10n.sharedCoordinateCount(payload.coordinateCount),
    if (payload.personnelCount > 0)
      l10n.sharedPersonCount(payload.personnelCount),
    if (payload.effortCount > 0) l10n.sharedEffortCount(payload.effortCount),
    if (payload.assignmentCount > 0)
      l10n.sharedPersonnelAssignmentCount(payload.assignmentCount),
    if (payload.type == RecordExchangeType.event &&
        (payload.data['environment'] != null ||
            payload.data['weather'] != null))
      l10n.sharedEnvironmentalData,
    if (payload.mediaCount > 0) l10n.sharedMediaFileCount(payload.mediaCount),
  ];
  return parts.isEmpty ? l10n.sharedNoAssociatedRecords : parts.join(' · ');
}

class _ImportTargetOption {
  const _ImportTargetOption(this.id, this.label);

  final int id;
  final String label;
}

String _recordLabel(Object record, AppLocalizations l10n) {
  if (record is SiteData) {
    return record.siteID?.trim().isNotEmpty == true
        ? record.siteID!
        : l10n.sharedSiteLabel('${record.id}');
  }
  if (record is CollEventData) {
    final suffix = record.idSuffix?.trim();
    return l10n.sharedEventLabel(
      suffix?.isNotEmpty == true ? suffix! : '${record.id}',
    );
  }
  return l10n.sharedRecordLabel;
}

typedef RecordExportSaveCallback =
    Future<File> Function({
      required String fileStem,
      required Directory? destinationDirectory,
      required RecordArchiveFormat? archiveFormat,
    });

enum _RecordExportFormat { json, zip, tarGzip }

Future<void> showRecordExportDialog({
  required BuildContext context,
  required RecordExchangePayload payload,
  required RecordExportSaveCallback onExport,
}) async {
  final content = RecordExportDialog(payload: payload, onExport: onExport);
  if (MediaQuery.sizeOf(context).width > 600) {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: content,
        ),
      ),
    );
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: content,
      ),
    ),
  );
}

class RecordExportDialog extends StatefulWidget {
  const RecordExportDialog({
    super.key,
    required this.payload,
    required this.onExport,
  });

  final RecordExchangePayload payload;
  final RecordExportSaveCallback onExport;

  @override
  State<RecordExportDialog> createState() => _RecordExportDialogState();
}

class _RecordExportDialogState extends State<RecordExportDialog> {
  late final FileOpCtrModel _exportCtr;
  late _RecordExportFormat _format;
  final ExportDestinationService _destination = ExportDestinationService();
  Directory? _selectedDir;
  File? _outputFile;
  bool _isRunning = false;
  bool _appendDate = false;

  bool get _hasMedia => widget.payload.hasMedia;

  @override
  void initState() {
    super.initState();
    _exportCtr = FileOpCtrModel.empty();
    _exportCtr.fileNameCtr.text = widget.payload.displayName;
    _format = _hasMedia ? _RecordExportFormat.zip : _RecordExportFormat.json;
  }

  @override
  void dispose() {
    _exportCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = _hasMedia
        ? const [_RecordExportFormat.zip, _RecordExportFormat.tarGzip]
        : const [_RecordExportFormat.json];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.sharedExportRecordType(widget.payload.type.name),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(_exportDescription(l10n)),
          const SizedBox(height: 16),
          GenericFileSettingsCard<_RecordExportFormat>(
            exportCtr: _exportCtr,
            selectedDir: _selectedDir,
            format: _format,
            formats: formats,
            formatLabel: _formatLabel,
            // Null keeps the card's own "File format" label.
            formatFieldLabel: _hasMedia
                ? l10n.settingsSelectionArchiveFormat
                : null,
            extensionForFormat: (format) => switch (format) {
              _RecordExportFormat.json => 'json',
              _RecordExportFormat.zip => 'zip',
              _RecordExportFormat.tarGzip => 'tar.gz',
            },
            onFormatChanged: (value) => setState(() {
              _format = value;
              _outputFile = null;
            }),
            onFileNameChanged: (_) => _resetExport(),
            appendDate: _appendDate,
            onAppendDateChanged: (value) => setState(() {
              _appendDate = value;
              _outputFile = null;
            }),
            onSelectDir: _selectDirectory,
            onClearDir: () => setState(() {
              _selectedDir = null;
              _outputFile = null;
            }),
          ),
          const SizedBox(height: 20),
          ExportShareButton(
            hasExported: _outputFile != null,
            isRunning: _isRunning,
            onExport: _exportCtr.isValid ? _export : null,
            onShare: _share,
            output: _outputFile,
            onRevealFile: _openFolder,
            onSaveCopy: _saveCopy,
          ),
        ],
      ),
    );
  }

  String _formatLabel(_RecordExportFormat format) => switch (format) {
    _RecordExportFormat.json => 'JSON (.json)',
    _RecordExportFormat.zip => 'ZIP (.zip)',
    _RecordExportFormat.tarGzip => 'TAR.GZ (.tar.gz)',
  };

  String _exportDescription(AppLocalizations l10n) {
    if (!_hasMedia) {
      return l10n.sharedExportRecordJson(widget.payload.type.name);
    }
    return l10n.sharedExportRecordMedia(widget.payload.mediaCount);
  }

  void _resetExport() {
    if (mounted) setState(() => _outputFile = null);
  }

  Future<void> _selectDirectory() async {
    if (!_destination.canChooseDirectory) return;
    final directory = await FilePickerServices().selectDir();
    if (directory != null && mounted) {
      setState(() {
        _selectedDir = directory;
        _outputFile = null;
      });
    }
  }

  Future<void> _export() async {
    setState(() => _isRunning = true);
    try {
      final file = await widget.onExport(
        fileStem: _appendDate
            ? appendDateToFileStem(_exportCtr.fileNameCtr.text, DateTime.now())
            : _exportCtr.fileNameCtr.text.trim(),
        destinationDirectory: await _destination.resolve(_selectedDir),
        archiveFormat: switch (_format) {
          _RecordExportFormat.json => null,
          _RecordExportFormat.zip => RecordArchiveFormat.zip,
          _RecordExportFormat.tarGzip => RecordArchiveFormat.tarGzip,
        },
      );
      if (!mounted) return;
      setState(() => _outputFile = file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            // Only a folder the user chose is worth naming; the fallback is
            // a path they cannot act on.
            _selectedDir != null
                ? context.l10n.sharedExportedTo(file.path)
                : context.l10n.sharedExportComplete,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _share() async {
    final file = _outputFile;
    if (file == null) return;
    try {
      await FilePickerServices().shareFile(context, file);
    } catch (error) {
      _reportActionFailure(error);
    }
  }

  Future<void> _openFolder() async {
    final file = _outputFile;
    if (file == null) return;
    try {
      await FilePickerServices().openContainingDirectory(file);
    } catch (error) {
      _reportActionFailure(error);
    }
  }

  /// Hands the finished file to the system "Save to..." dialog.
  ///
  /// How Android reaches the Files app: its share sheet only lists apps that
  /// accept a file, never a folder to drop one into.
  Future<void> _saveCopy() async {
    final file = _outputFile;
    if (file == null) return;
    try {
      await FilePickerServices().saveCopyToDevice(file);
    } catch (error) {
      _reportActionFailure(error);
    }
  }

  void _reportActionFailure(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

class SpecimenImportTargetChoice {
  const SpecimenImportTargetChoice({this.targetUuid});

  final String? targetUuid;
}

Future<SpecimenImportTargetChoice?> showSpecimenImportTargetDialog({
  required BuildContext context,
  required RecordExchangePayload payload,
  required List<SpecimenData> specimens,
  String? initialTargetUuid,
}) {
  var selected = initialTargetUuid;
  if (selected != null &&
      specimens.every((specimen) => specimen.uuid != selected)) {
    selected = null;
  }
  return showDialog<SpecimenImportTargetChoice>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          context.l10n.sharedImportRecordType(RecordExchangeType.specimen.name),
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payload.displayName),
                const SizedBox(height: 8),
                Text(
                  context.l10n.sharedSpecimenImportSummary(
                    payload.partCount,
                    payload.associatedDataCount,
                    payload.mediaCount,
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<String?>(
                  groupValue: selected,
                  onChanged: (value) => setState(() => selected = value),
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        value: null,
                        title: Text(
                          context.l10n.sharedCreateNewRecordType(
                            RecordExchangeType.specimen.name,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (specimens.isNotEmpty) ...[
                        const Divider(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            context.l10n.sharedUpdateExistingRecordType(
                              RecordExchangeType.specimen.name,
                            ),
                          ),
                        ),
                        ...specimens.map(
                          (specimen) => RadioListTile<String?>(
                            value: specimen.uuid,
                            title: Text(_specimenLabel(specimen, context.l10n)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(SpecimenImportTargetChoice(targetUuid: selected)),
            child: Text(context.l10n.sharedContinue),
          ),
        ],
      ),
    ),
  );
}

Future<SpecimenImportReferences?> chooseSpecimenReferences({
  required BuildContext context,
  required RecordExchangePayload payload,
  required List<CollEventData> events,
  required List<SiteRecord> sites,
  required List<TaxonomyData> taxa,
}) async {
  int? eventId;
  var createEvent = false;
  int? siteId;
  var createSite = false;
  int? taxonomyId;
  var createTaxonomy = false;

  if (payload.data['event'] is Map) {
    final eventChoice = await _chooseSpecimenEvent(
      context: context,
      events: events,
    );
    if (eventChoice == null) return null;
    eventId = eventChoice;
    createEvent = eventId == -1;
    if (createEvent &&
        (Map<String, dynamic>.from(payload.data['event'] as Map)['site']
            is Map)) {
      if (!context.mounted) return null;
      final siteChoice = await showLinkedSiteDialog(
        context: context,
        sites: sites,
      );
      if (siteChoice == null) return null;
      siteId = siteChoice.siteId;
      createSite = siteChoice.createEmbeddedSite;
    }
  }

  if (payload.data['taxonomy'] is Map) {
    if (!context.mounted) return null;
    final taxonomyChoice = await _chooseSpecimenTaxonomy(
      context: context,
      taxa: taxa,
    );
    if (taxonomyChoice == null) return null;
    taxonomyId = taxonomyChoice;
    createTaxonomy = taxonomyId == -1;
  }

  return SpecimenImportReferences(
    eventId: eventId == -1 ? null : eventId,
    siteId: siteId,
    taxonomyId: taxonomyId == -1 ? null : taxonomyId,
    createEmbeddedEvent: createEvent,
    createEmbeddedSite: createSite,
    createEmbeddedTaxonomy: createTaxonomy,
  );
}

Future<int?> _chooseSpecimenEvent({
  required BuildContext context,
  required List<CollEventData> events,
}) {
  var selected = -1;
  return showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(context.l10n.sharedChooseSpecimenEvent),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: RadioGroup<int>(
              groupValue: selected,
              onChanged: (value) => setState(() => selected = value!),
              child: Column(
                children: [
                  RadioListTile<int>(
                    value: -1,
                    title: Text(context.l10n.sharedCreateEmbeddedEvent),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ...events.map(
                    (event) => RadioListTile<int>(
                      value: event.id,
                      title: Text(_recordLabel(event, context.l10n)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(selected),
            child: Text(context.l10n.sharedContinue),
          ),
        ],
      ),
    ),
  );
}

Future<int?> _chooseSpecimenTaxonomy({
  required BuildContext context,
  required List<TaxonomyData> taxa,
}) {
  var selected = -1;
  return showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(context.l10n.sharedChooseSpecimenTaxonomy),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: RadioGroup<int>(
              groupValue: selected,
              onChanged: (value) => setState(() => selected = value!),
              child: Column(
                children: [
                  RadioListTile<int>(
                    value: -1,
                    title: Text(context.l10n.sharedCreateEmbeddedTaxonomy),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ...taxa.map(
                    (taxon) => RadioListTile<int>(
                      value: taxon.id,
                      title: Text(_taxonLabel(taxon, context.l10n)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(selected),
            child: Text(context.l10n.sharedContinue),
          ),
        ],
      ),
    ),
  );
}

String _specimenLabel(SpecimenData specimen, AppLocalizations l10n) {
  final field = specimen.fieldNumber;
  return field == null ? specimen.uuid : l10n.sharedSpecimenLabel('$field');
}

String _taxonLabel(TaxonomyData taxon, AppLocalizations l10n) {
  final genus = taxon.genus?.trim() ?? '';
  final epithet = taxon.specificEpithet?.trim() ?? '';
  final name = '$genus $epithet'.trim();
  return name.isEmpty ? l10n.sharedTaxonLabel('${taxon.id}') : name;
}
