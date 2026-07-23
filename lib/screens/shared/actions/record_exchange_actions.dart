import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/screens/shared/dialogs/record_exchange_dialogs.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/record_exchange_service.dart';

class RecordExchangeActions {
  const RecordExchangeActions({required this.context, required this.ref});

  final BuildContext context;
  final WidgetRef ref;

  Future<void> showSiteQr(int siteId) async {
    await _showQr(
      payload: await RecordExchangeService(ref: ref).exportSite(siteId),
      title: 'Site QR code',
      onFallback: () => exportSiteJson(siteId),
    );
  }

  Future<void> showEventQr(int eventId) async {
    await _showQr(
      payload: await RecordExchangeService(ref: ref).exportEvent(eventId),
      title: 'Event QR code',
      onFallback: () => exportEventJson(eventId),
    );
  }

  Future<void> exportSiteJson(int siteId) async {
    await _export(
      payload: await RecordExchangeService(ref: ref).exportSite(siteId),
    );
  }

  Future<void> exportEventJson(int eventId) async {
    await _export(
      payload: await RecordExchangeService(ref: ref).exportEvent(eventId),
    );
  }

  Future<void> scanSiteQr({int? initialTargetId}) async {
    await _scan(
      expectedType: 'site',
      onPayload: (payload) =>
          importSite(payload, initialTargetId: initialTargetId),
    );
  }

  Future<void> scanEventQr({int? initialTargetId}) async {
    await _scan(
      expectedType: 'event',
      onPayload: (payload) =>
          importEvent(payload, initialTargetId: initialTargetId),
    );
  }

  Future<void> importSiteJson({int? initialTargetId}) async {
    final file = await RecordExchangeService(ref: ref).selectJsonFile();
    if (file == null) return;
    try {
      final content = await File(file.path).readAsString();
      final payload = RecordExchangePayload.parse(
        content,
        expectedType: 'site',
      );
      await importSite(payload, initialTargetId: initialTargetId);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> importEventJson({int? initialTargetId}) async {
    final file = await RecordExchangeService(ref: ref).selectJsonFile();
    if (file == null) return;
    try {
      final content = await File(file.path).readAsString();
      final payload = RecordExchangePayload.parse(
        content,
        expectedType: 'event',
      );
      await importEvent(payload, initialTargetId: initialTargetId);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> importSite(
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
      ref.invalidate(siteEntryProvider);
      ref.invalidate(allPersonnelProvider);
      ref.invalidate(projectPersonnelProvider);
      ref
          .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
          .updateState(result.recordId);
      _showSuccess('Site imported successfully.');
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> importEvent(
    RecordExchangePayload payload, {
    int? initialTargetId,
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
      );
      ref.invalidate(collEventEntryProvider);
      ref.invalidate(siteEntryProvider);
      ref.invalidate(allPersonnelProvider);
      ref.invalidate(projectPersonnelProvider);
      ref
          .read(pendingRecordJumpProvider(RecordViewer.collEvent).notifier)
          .updateState(result.recordId);
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
                child: const Text('Export JSON'),
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

  Future<void> _export({required RecordExchangePayload payload}) async {
    try {
      final file = await RecordExchangeService(
        ref: ref,
      ).saveJson(payload, fileStem: payload.displayName);
      _showSuccess('Exported JSON to ${file.path}.');
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
