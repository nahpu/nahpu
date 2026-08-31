import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/import/taxon_qr_session.dart';
import 'package:nahpu/services/import/taxon_reader.dart';
import 'package:nahpu/styles/design_tokens.dart';

bool get supportsTaxonQrScanning =>
    kIsWeb ||
    switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };

class TaxonQrImportModeDialog extends StatelessWidget {
  const TaxonQrImportModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Import from QR'),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, TaxonQrImportMode.single),
          child: const Text('Single taxon'),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, TaxonQrImportMode.multiple),
          child: const Text('Multiple taxa'),
        ),
      ],
    );
  }
}

class TaxonQrImportScreen extends ConsumerStatefulWidget {
  const TaxonQrImportScreen({super.key, required this.mode});

  final TaxonQrImportMode mode;

  @override
  ConsumerState<TaxonQrImportScreen> createState() =>
      _TaxonQrImportScreenState();
}

class _TaxonQrImportScreenState extends ConsumerState<TaxonQrImportScreen>
    with WidgetsBindingObserver {
  final _camera = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.qrCode, BarcodeFormat.microQrCode],
  );
  late final TaxonQrSession _session;
  Future<void> _cameraWork = Future.value();
  TaxonQrScanResult? _lastResult;
  String? _cameraError;
  int _activeDetections = 0;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _session = TaxonQrSession(
      mode: widget.mode,
      reviewData: TaxonEntryReader(ref: ref).reviewQrData,
    );
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_setCameraRunning(true));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_camera.value.hasCameraPermission) return;
    unawaited(_setCameraRunning(state == AppLifecycleState.resumed));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session.close();
    _finishing = true;
    unawaited(_disposeCamera());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == TaxonQrImportMode.single
              ? 'Scan taxon QR'
              : 'Scan multiple taxa',
        ),
        actions: [
          if (widget.mode == TaxonQrImportMode.multiple)
            TextButton(
              onPressed:
                  _session.review.candidates.isEmpty ||
                      _activeDetections > 0 ||
                      _finishing
                  ? null
                  : _finish,
              child: const Text('Done'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _camera,
              builder: (context, state, child) => Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _camera,
                    onDetect: _onDetect,
                    onDetectError: (_, _) => _showCameraError(),
                    errorBuilder: (context, error) => _TaxonCameraError(
                      message:
                          error.errorCode ==
                              MobileScannerErrorCode.permissionDenied
                          ? 'Camera access is denied. Allow camera access in device settings, then retry.'
                          : 'Camera scanning is unavailable. Retry or use file import.',
                      onRetry: () => unawaited(_setCameraRunning(true)),
                    ),
                  ),
                  if (state.error == null && _cameraError == null)
                    ScannerCameraOverlay(
                      mode: ScannerMode.qr,
                      supportedModes: const {ScannerMode.qr},
                      onModeChanged: (_) {},
                    ),
                  if (_cameraError != null)
                    _TaxonCameraError(
                      message: _cameraError!,
                      onRetry: () => unawaited(_setCameraRunning(true)),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(NahpuSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.mode == TaxonQrImportMode.multiple)
                    Text(
                      '${_session.readyCount} taxa ready',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  const SizedBox(height: NahpuSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _lastResult?.message ?? 'Scan a NAHPU taxon QR code.',
                      key: const ValueKey('taxon-qr-feedback'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _lastResult?.isError == true
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_finishing || !mounted) return;
    final barcodes = filterScannerCapture(capture, ScannerMode.qr).barcodes;
    if (barcodes.isEmpty) return;
    setState(() => _activeDetections++);
    try {
      for (final barcode in barcodes) {
        final result = await _session.scan(barcode.rawValue);
        if (!mounted || _finishing) return;
        if (result == null) continue;
        setState(() => _lastResult = result);
        if (result.accepted && widget.mode == TaxonQrImportMode.single) {
          await _finish();
          return;
        }
      }
    } finally {
      if (mounted) setState(() => _activeDetections--);
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    _session.close();
    await _setCameraRunning(false);
    if (mounted) Navigator.pop<TaxonImportReview>(context, _session.review);
  }

  Future<void> _setCameraRunning(bool running) {
    _cameraWork = _cameraWork.then((_) async {
      if (!mounted || (running && _finishing)) return;
      try {
        if (running) {
          setState(() => _cameraError = null);
          await _camera.start();
        } else {
          await _camera.stop();
        }
      } catch (_) {
        _showCameraError();
      }
    });
    return _cameraWork;
  }

  Future<void> _disposeCamera() async {
    await _cameraWork;
    try {
      await _camera.stop();
    } catch (_) {
      // The native camera may already be gone during route or app teardown.
    } finally {
      try {
        await _camera.dispose();
      } catch (_) {
        // There is no active screen on which to recover during disposal.
      }
    }
  }

  void _showCameraError() {
    if (mounted && !_finishing) {
      setState(
        () => _cameraError =
            'Unable to use the camera. Retry or use file import.',
      );
    }
  }
}

class _TaxonCameraError extends StatelessWidget {
  const _TaxonCameraError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NahpuSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: NahpuSpacing.lg),
              TextButton(onPressed: onRetry, child: const Text('Retry camera')),
            ],
          ),
        ),
      ),
    );
  }
}
