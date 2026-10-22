import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/projects/specimen_check/components/tissue_scan_card.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/specimen_check/tissue_check_session.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Scans tubes with the camera until the user is done. Each code goes to
/// [onCode]; the same code held in view is sent once.
class TissueCameraScanner extends StatefulWidget {
  const TissueCameraScanner({super.key, required this.onCode});

  final Future<TissueScanOutcome> Function(String code) onCode;

  @override
  State<TissueCameraScanner> createState() => _TissueCameraScannerState();
}

class _TissueCameraScannerState extends State<TissueCameraScanner>
    with WidgetsBindingObserver {
  static const _repeatDelay = Duration(seconds: 2);

  final _camera = MobileScannerController(autoStart: false);
  Future<void> _cameraWork = Future.value();
  ScannerMode _mode = ScannerMode.barcode;
  TissueScanOutcome? _outcome;
  String? _lastCode;
  DateTime _lastSeen = DateTime.fromMillisecondsSinceEpoch(0);
  String? _cameraError;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
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
    _isClosing = true;
    unawaited(_disposeCamera());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan tubes'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
                    errorBuilder: (context, error) => TissueCameraError(
                      message:
                          error.errorCode ==
                              MobileScannerErrorCode.permissionDenied
                          ? 'Camera access is denied. Allow camera access in '
                                'device settings, then retry.'
                          : 'Camera scanning is unavailable. Use the scan '
                                'field instead.',
                      onRetry: () => unawaited(_setCameraRunning(true)),
                    ),
                  ),
                  if (state.error == null && _cameraError == null)
                    ScannerCameraOverlay(
                      mode: _mode,
                      supportedModes: const {
                        ScannerMode.barcode,
                        ScannerMode.qr,
                      },
                      onModeChanged: (mode) => setState(() => _mode = mode),
                    ),
                  if (_cameraError != null)
                    TissueCameraError(
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
              child: TissueScanFeedback(outcome: _outcome),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isClosing || !mounted) return;
    final barcodes = filterScannerCapture(capture, _mode).barcodes;
    final code = barcodes.firstOrNull?.rawValue?.trim() ?? '';
    if (code.isEmpty) return;
    final now = DateTime.now();
    final isRepeat =
        code == _lastCode && now.difference(_lastSeen) < _repeatDelay;
    _lastSeen = now;
    if (isRepeat) return;
    _lastCode = code;
    final outcome = await widget.onCode(code);
    if (mounted) setState(() => _outcome = outcome);
  }

  Future<void> _setCameraRunning(bool running) {
    _cameraWork = _cameraWork.then((_) async {
      if (!mounted || (running && _isClosing)) return;
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
    if (mounted && !_isClosing) {
      setState(
        () => _cameraError =
            'Unable to use the camera. Retry or use the scan field.',
      );
    }
  }
}

class TissueCameraError extends StatelessWidget {
  const TissueCameraError({
    super.key,
    required this.message,
    required this.onRetry,
  });

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
