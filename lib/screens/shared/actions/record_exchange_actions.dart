import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/screens/shared/dialogs/record_exchange_dialogs.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/associated_data.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:nahpu/services/record_exchange/record_exchange_service.dart';

class RecordExchangeActions {
  const RecordExchangeActions({required this.context, required this.ref});

  final BuildContext context;
  final WidgetRef ref;

  Future<void> showSiteQr(int siteId) async {
    await _showQr(
      payload: await RecordExchangeService(ref: ref).exportSite(siteId),
      title: 'Site QR code',
      onFallback: () => exportSiteRecord(siteId),
    );
  }

  Future<void> showEventQr(int eventId) async {
    await _showQr(
      payload: await RecordExchangeService(ref: ref).exportEvent(eventId),
      title: 'Event QR code',
      onFallback: () => exportEventRecord(eventId),
    );
  }

  Future<void> exportSiteRecord(int siteId) async {
    try {
      final service = RecordExchangeService(ref: ref);
      final payload = await service.exportSite(siteId);
      if (!context.mounted) return;
      await showRecordExportDialog(
        context: context,
        payload: payload,
        onExport:
            ({
              required fileStem,
              required destinationDirectory,
              required archiveFormat,
            }) => service.saveJson(
              payload,
              fileStem: fileStem,
              destinationDirectory: destinationDirectory,
            ),
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> exportEventRecord(int eventId) async {
    try {
      final service = RecordExchangeService(ref: ref);
      final mediaCount = await service.getEventMediaCount(eventId);
      final payload = await service.exportEvent(
        eventId,
        includeMedia: mediaCount > 0,
      );
      if (!context.mounted) return;
      await showRecordExportDialog(
        context: context,
        payload: payload,
        onExport:
            ({
              required fileStem,
              required destinationDirectory,
              required archiveFormat,
            }) {
              if (archiveFormat == null) {
                return service.saveJson(
                  payload,
                  fileStem: fileStem,
                  destinationDirectory: destinationDirectory,
                );
              }
              return service.saveRecordArchive(
                payload,
                fileStem: fileStem,
                archiveFormat: archiveFormat,
                destinationDirectory: destinationDirectory,
              );
            },
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> exportSpecimenRecord(String specimenUuid) async {
    try {
      final service = RecordExchangeService(ref: ref);
      final mediaCount = await service.getSpecimenMediaCount(specimenUuid);
      final payload = await service.exportSpecimen(
        specimenUuid,
        includeMedia: mediaCount > 0,
      );
      if (!context.mounted) return;
      await showRecordExportDialog(
        context: context,
        payload: payload,
        onExport:
            ({
              required fileStem,
              required destinationDirectory,
              required archiveFormat,
            }) {
              if (archiveFormat == null) {
                return service.saveJson(
                  payload,
                  fileStem: fileStem,
                  destinationDirectory: destinationDirectory,
                );
              }
              return service.saveSpecimen(
                payload,
                fileStem: fileStem,
                archiveFormat: archiveFormat,
                destinationDirectory: destinationDirectory,
              );
            },
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> scanSiteQr({int? initialTargetId}) async {
    await _scan(
      expectedType: 'site',
      onPayload: (payload) =>
          _importSitePayload(payload, initialTargetId: initialTargetId),
    );
  }

  Future<void> scanEventQr({int? initialTargetId}) async {
    await _scan(
      expectedType: 'event',
      onPayload: (payload) =>
          _importEventPayload(payload, initialTargetId: initialTargetId),
    );
  }

  Future<void> importSiteRecord({int? initialTargetId}) async {
    final file = await RecordExchangeService(ref: ref).selectJsonFile();
    if (file == null) return;
    try {
      final content = await File(file.path).readAsString();
      final payload = RecordExchangePayload.parse(
        content,
        expectedType: 'site',
      );
      await _importSitePayload(payload, initialTargetId: initialTargetId);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> importEventRecord({int? initialTargetId}) async {
    final service = RecordExchangeService(ref: ref);
    final file = await service.selectRecordFile();
    if (file == null) return;
    RecordExchangeArchiveFile? imported;
    try {
      imported = await service.readRecordFile(
        file,
        expectedType: RecordExchangeType.event,
      );
      await _importEventPayload(
        imported.payload,
        initialTargetId: initialTargetId,
        extractedMediaDirectory: imported.extractedMediaDirectory,
      );
    } catch (error) {
      _showError(error);
    } finally {
      final directory = imported?.extractedMediaDirectory;
      if (directory != null && directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    }
  }

  Future<void> importSpecimenRecord({String? initialTargetUuid}) async {
    final file = await RecordExchangeService(ref: ref).selectRecordFile();
    if (file == null) return;
    RecordExchangeArchiveFile? imported;
    try {
      imported = await RecordExchangeService(
        ref: ref,
      ).readRecordFile(file, expectedType: RecordExchangeType.specimen);
      final service = RecordExchangeService(ref: ref);
      final specimens = await service.getCurrentProjectSpecimens();
      if (!context.mounted) return;
      final target = await showSpecimenImportTargetDialog(
        context: context,
        specimens: specimens,
        initialTargetUuid: initialTargetUuid,
        payload: imported.payload,
      );
      if (target == null) return;

      final events = await service.getCurrentProjectEvents();
      final sites = await service.getCurrentProjectSites();
      final taxa = await service.getTaxonomyList();
      if (!context.mounted) return;
      final references = await chooseSpecimenReferences(
        context: context,
        payload: imported.payload,
        events: events,
        sites: sites,
        taxa: taxa,
      );
      if (references == null) return;

      final result = await service.importPayload(
        imported.payload,
        targetSpecimenUuid: target.targetUuid,
        references: references,
        extractedMediaDirectory: imported.extractedMediaDirectory,
      );
      ref
          .read(pendingRecordJumpProvider(RecordViewer.specimen).notifier)
          .updateState(result.recordUuid);
      if (result.createdEventId case final createdEventId?) {
        ref
            .read(pendingRecordJumpProvider(RecordViewer.collEvent).notifier)
            .updateState(createdEventId);
      }
      if (result.createdSiteId case final createdSiteId?) {
        ref
            .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
            .updateState(createdSiteId);
      }
      ref.invalidate(specimenEntryProvider);
      if (result.createdEventId != null) {
        ref.invalidate(collEventEntryProvider);
      }
      if (result.createdSiteId != null) {
        ref.invalidate(siteEntryProvider);
      }
      ref.invalidate(partBySpecimenProvider(result.recordUuid!));
      ref.invalidate(
        associatedDataProvider(
          AssociatedDataTarget.specimen(result.recordUuid!),
        ),
      );
      _showSuccess('Specimen imported successfully.');
    } catch (error) {
      _showError(error);
    } finally {
      final directory = imported?.extractedMediaDirectory;
      if (directory != null && directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    }
  }

  Future<void> _importSitePayload(
    RecordExchangePayload payload, {
    int? initialTargetId,
  }) async {
    try {
      final service = RecordExchangeService(ref: ref);
      final sites = await service.getCurrentProjectSites();
      if (!context.mounted) return;
      final choice = await showRecordImportTargetDialog(
        context: context,
        payload: payload,
        sites: sites,
        events: const [],
        initialTargetId: initialTargetId,
      );
      if (choice == null) return;
      final result = await service.importPayload(
        payload,
        targetId: choice.targetId,
      );
      ref
          .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
          .updateState(result.recordId);
      ref.invalidate(siteEntryProvider);
      ref.invalidate(
        associatedDataProvider(AssociatedDataTarget.site(result.recordId)),
      );
      ref.invalidate(allPersonnelProvider);
      ref.invalidate(projectPersonnelProvider);
      _showSuccess('Site imported successfully.');
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _importEventPayload(
    RecordExchangePayload payload, {
    int? initialTargetId,
    Directory? extractedMediaDirectory,
  }) async {
    try {
      final service = RecordExchangeService(ref: ref);
      final events = await service.getCurrentProjectEvents();
      if (!context.mounted) return;
      final target = await showRecordImportTargetDialog(
        context: context,
        payload: payload,
        sites: const [],
        events: events,
        initialTargetId: initialTargetId,
      );
      if (target == null) return;

      LinkedSiteChoice? linkedSite;
      if (payload.data['site'] != null) {
        final sites = await service.getCurrentProjectSites();
        if (!context.mounted) return;
        linkedSite = await showLinkedSiteDialog(context: context, sites: sites);
        if (linkedSite == null) return;
      }
      final result = await service.importPayload(
        payload,
        targetId: target.targetId,
        linkedSiteId: linkedSite?.siteId,
        createEmbeddedSite: linkedSite?.createEmbeddedSite ?? false,
        extractedMediaDirectory: extractedMediaDirectory,
      );
      ref
          .read(pendingRecordJumpProvider(RecordViewer.collEvent).notifier)
          .updateState(result.recordId);
      if (result.createdSiteId case final createdSiteId?) {
        ref
            .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
            .updateState(createdSiteId);
      }
      ref.invalidate(collEventEntryProvider);
      ref.invalidate(eventMediaProvider(result.recordId));
      ref.invalidate(
        associatedDataProvider(AssociatedDataTarget.event(result.recordId)),
      );
      ref.invalidate(siteEntryProvider);
      ref.invalidate(allPersonnelProvider);
      ref.invalidate(projectPersonnelProvider);
      _showSuccess('Event imported successfully.');
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _scan({
    required String expectedType,
    required Future<void> Function(RecordExchangePayload payload) onPayload,
  }) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (scannerContext) => ScannerScreen(
          onDetect: (capture) {
            final rawValue = capture.barcodes.isEmpty
                ? null
                : capture.barcodes.first.rawValue;
            Navigator.of(scannerContext).pop();
            if (rawValue == null) {
              _showError(const FormatException('The QR code has no data.'));
              return;
            }
            try {
              final payload = RecordExchangePayload.parse(
                rawValue,
                expectedType: expectedType,
              );
              unawaited(onPayload(payload));
            } catch (error) {
              _showError(error);
            }
          },
        ),
      ),
    );
  }

  Future<void> _showQr({
    required RecordExchangePayload payload,
    required String title,
    required Future<void> Function() onFallback,
  }) async {
    try {
      final qrData = payload.compactEncoded;
      if (!canEncodeQrPayload(qrData)) {
        final export = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('QR code is too large'),
            content: const Text(
              'This record contains too much data for a QR code. '
              'Export it as JSON to transfer the complete record instead.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Export ${payload.type.label}'),
              ),
            ],
          ),
        );
        if (export == true) await onFallback();
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => RecordQrDialog(title: title, data: qrData),
      );
    } catch (error) {
      _showError(error);
    }
  }

  void _showSuccess(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(Object error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
  }

  String _errorMessage(Object error) {
    if (error is FormatException) return error.message;
    return 'Record import/export failed: $error';
  }
}
