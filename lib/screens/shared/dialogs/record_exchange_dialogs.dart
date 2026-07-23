import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/record_exchange_service.dart';

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
