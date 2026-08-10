import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/record_exchange/record_exchange_service.dart';
import 'package:nahpu/services/types/controllers.dart';

class RecordQrDialog extends StatelessWidget {
  const RecordQrDialog({super.key, required this.title, required this.data});

  final String title;
  final String data;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(data: data, size: 280, backgroundColor: Colors.white),
            const SizedBox(height: 12),
            const Text(
              'Scan this code from another NAHPU device to import the record.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class RecordImportTargetChoice {
  const RecordImportTargetChoice({required this.targetId});

  final int? targetId;
}

Future<RecordImportTargetChoice?> showRecordImportTargetDialog({
  required BuildContext context,
  required RecordExchangePayload payload,
  required List<SiteData> sites,
  required List<CollEventData> events,
  int? initialTargetId,
}) {
  final isSite = payload.type == RecordExchangeType.site;
  final selectedRecords = isSite
      ? sites
            .map((site) => _ImportTargetOption(site.id, _recordLabel(site)))
            .toList()
      : events
            .map((event) => _ImportTargetOption(event.id, _recordLabel(event)))
            .toList();
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
          title: Text('Import ${isSite ? 'site' : 'event'}'),
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
                  Text(_summary(payload)),
                  const SizedBox(height: 16),
                  RadioGroup<int?>(
                    groupValue: selected,
                    onChanged: (value) => setState(() => selected = value),
                    child: Column(
                      children: [
                        RadioListTile<int?>(
                          value: null,
                          title: Text(
                            'Create new ${isSite ? 'site' : 'event'}',
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (selectedRecords.isNotEmpty) ...[
                          const Divider(),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Update an existing ${isSite ? 'site' : 'event'}',
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
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(RecordImportTargetChoice(targetId: selected)),
              child: const Text('Continue'),
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
  required List<SiteData> sites,
}) {
  var selected = -1;
  return showDialog<LinkedSiteChoice>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Choose event site'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This event includes a linked site. Choose an existing site '
                  'or create the embedded site as a new site.',
                ),
                const SizedBox(height: 12),
                RadioGroup<int>(
                  groupValue: selected,
                  onChanged: (value) => setState(() => selected = value ?? -1),
                  child: Column(
                    children: [
                      RadioListTile<int>(
                        value: -1,
                        title: const Text('Create embedded site'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (sites.isNotEmpty) ...[
                        const Divider(),
                        ...sites.map(
                          (site) => RadioListTile<int>(
                            value: site.id,
                            title: Text(_recordLabel(site)),
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              selected == -1
                  ? const LinkedSiteChoice(createEmbeddedSite: true)
                  : LinkedSiteChoice(siteId: selected),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    ),
  );
}

String _summary(RecordExchangePayload payload) {
  final parts = <String>[];
  if (payload.coordinateCount > 0) {
    parts.add(
      '${payload.coordinateCount} '
      '${payload.coordinateCount == 1 ? 'coordinate' : 'coordinates'}',
    );
  }
  if (payload.personnelCount > 0) {
    parts.add(
      '${payload.personnelCount} '
      '${payload.personnelCount == 1 ? 'person' : 'people'}',
    );
  }
  if (payload.effortCount > 0) {
    parts.add(
      '${payload.effortCount} '
      '${payload.effortCount == 1 ? 'effort' : 'efforts'}',
    );
  }
  if (payload.assignmentCount > 0) {
    parts.add(
      '${payload.assignmentCount} personnel '
      '${payload.assignmentCount == 1 ? 'assignment' : 'assignments'}',
    );
  }
  if (payload.type == RecordExchangeType.event &&
      payload.data['weather'] != null) {
    parts.add('weather');
  }
  if (payload.mediaCount > 0) {
    parts.add(
      '${payload.mediaCount} '
      '${payload.mediaCount == 1 ? 'media file' : 'media files'}',
    );
  }
  return parts.isEmpty
      ? 'No associated records'
      : 'Includes ${parts.join(', ')}.';
}

class _ImportTargetOption {
  const _ImportTargetOption(this.id, this.label);

  final int id;
  final String label;
}

String _recordLabel(Object record) {
  if (record is SiteData) {
    return record.siteID?.trim().isNotEmpty == true
        ? record.siteID!
        : 'Site ${record.id}';
  }
  if (record is CollEventData) {
    final suffix = record.idSuffix?.trim();
    return suffix?.isNotEmpty == true ? 'Event $suffix' : 'Event ${record.id}';
  }
  return 'Record';
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
  Directory? _selectedDir;
  File? _outputFile;
  bool _isRunning = false;

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
            'Export ${widget.payload.type.label}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(_exportDescription()),
          const SizedBox(height: 16),
          GenericFileSettingsCard<_RecordExportFormat>(
            exportCtr: _exportCtr,
            selectedDir: _selectedDir,
            format: _format,
            formats: formats,
            formatLabel: _formatLabel,
            formatFieldLabel: _hasMedia ? 'Archive format' : 'File format',
            onFormatChanged: (value) => setState(() {
              _format = value;
              _outputFile = null;
            }),
            onFileNameChanged: (_) => _resetExport(),
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

  String _exportDescription() {
    if (!_hasMedia) {
      return 'Export this ${widget.payload.type.label} record as JSON.';
    }
    return 'This ${widget.payload.type.label} includes '
        '${widget.payload.mediaCount} linked media '
        'file${widget.payload.mediaCount == 1 ? '' : 's'} that will be '
        'included in the archive.';
  }

  void _resetExport() {
    if (mounted) setState(() => _outputFile = null);
  }

  Future<void> _selectDirectory() async {
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
        fileStem: _exportCtr.fileNameCtr.text.trim(),
        destinationDirectory: _selectedDir,
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
            systemPlatform == PlatformType.desktop
                ? 'Exported to ${file.path}'
                : 'Export complete!',
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
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
        title: const Text('Import specimen'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payload.displayName),
                const SizedBox(height: 8),
                Text(
                  'Includes ${payload.partCount} part(s), '
                  '${payload.associatedDataCount} associated record(s), and '
                  '${payload.mediaCount} media file(s).',
                ),
                const SizedBox(height: 12),
                RadioGroup<String?>(
                  groupValue: selected,
                  onChanged: (value) => setState(() => selected = value),
                  child: Column(
                    children: [
                      const RadioListTile<String?>(
                        value: null,
                        title: Text('Create new specimen'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (specimens.isNotEmpty) ...[
                        const Divider(),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Update an existing specimen'),
                        ),
                        ...specimens.map(
                          (specimen) => RadioListTile<String?>(
                            value: specimen.uuid,
                            title: Text(_specimenLabel(specimen)),
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(SpecimenImportTargetChoice(targetUuid: selected)),
            child: const Text('Continue'),
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
  required List<SiteData> sites,
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
        title: const Text('Choose specimen event'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: RadioGroup<int>(
              groupValue: selected,
              onChanged: (value) => setState(() => selected = value!),
              child: Column(
                children: [
                  const RadioListTile<int>(
                    value: -1,
                    title: Text('Create embedded event'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ...events.map(
                    (event) => RadioListTile<int>(
                      value: event.id,
                      title: Text(_recordLabel(event)),
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(selected),
            child: const Text('Continue'),
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
        title: const Text('Choose specimen taxonomy'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: RadioGroup<int>(
              groupValue: selected,
              onChanged: (value) => setState(() => selected = value!),
              child: Column(
                children: [
                  const RadioListTile<int>(
                    value: -1,
                    title: Text('Create embedded taxonomy'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ...taxa.map(
                    (taxon) => RadioListTile<int>(
                      value: taxon.id,
                      title: Text(_taxonLabel(taxon)),
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(selected),
            child: const Text('Continue'),
          ),
        ],
      ),
    ),
  );
}

String _specimenLabel(SpecimenData specimen) {
  final field = specimen.fieldNumber;
  return field == null ? specimen.uuid : 'Specimen $field';
}

String _taxonLabel(TaxonomyData taxon) {
  final genus = taxon.genus?.trim() ?? '';
  final epithet = taxon.specificEpithet?.trim() ?? '';
  final name = '$genus $epithet'.trim();
  return name.isEmpty ? 'Taxon ${taxon.id}' : name;
}
