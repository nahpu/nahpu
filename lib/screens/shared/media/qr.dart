import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:qr/qr.dart';

enum ScannerMode { qr, barcode }

class ScannerScreen extends StatefulWidget {
  ScannerScreen({
    super.key,
    required this.onDetect,
    this.supportedModes = const {ScannerMode.qr},
    this.initialMode = ScannerMode.qr,
  }) : assert(supportedModes.isNotEmpty),
       assert(supportedModes.contains(initialMode));

  final void Function(BarcodeCapture) onDetect;
  final Set<ScannerMode> supportedModes;
  final ScannerMode initialMode;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  late ScannerMode _mode;
  bool _hasDetected = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _controller.start();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_mode.screenTitle)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          ScannerCameraOverlay(
            mode: _mode,
            supportedModes: widget.supportedModes,
            onModeChanged: (mode) => setState(() => _mode = mode),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;
    final filtered = filterScannerCapture(capture, _mode);
    if (filtered.barcodes.isEmpty) return;
    _hasDetected = true;
    _controller.stop();
    widget.onDetect(filtered);
  }
}

class ScannerCameraOverlay extends StatelessWidget {
  const ScannerCameraOverlay({
    super.key,
    required this.mode,
    required this.supportedModes,
    required this.onModeChanged,
  });

  final ScannerMode mode;
  final Set<ScannerMode> supportedModes;
  final ValueChanged<ScannerMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = math.max(0.0, constraints.maxWidth - 48);
        final hasModeSelector = supportedModes.length > 1;
        final verticalReserve = hasModeSelector ? 152.0 : 104.0;
        final availableFrameHeight = math.max(
          0.0,
          constraints.maxHeight - verticalReserve,
        );
        final frameWidth = mode == ScannerMode.qr
            ? math.min(300.0, math.min(availableWidth, availableFrameHeight))
            : math.min(360.0, availableWidth);
        final frameHeight = mode == ScannerMode.qr
            ? frameWidth
            : math.min(
                availableFrameHeight,
                math.min(160.0, math.max(100.0, frameWidth * 0.42)),
              );
        final left = (constraints.maxWidth - frameWidth) / 2;
        final desiredTop = (constraints.maxHeight - frameHeight) / 2 - 28;
        final minTop = hasModeSelector ? 80.0 : 16.0;
        final maxTop = math.max(
          minTop,
          constraints.maxHeight - frameHeight - 72,
        );
        final top = desiredTop.clamp(minTop, maxTop).toDouble();
        const scrim = Color(0x99000000);
        return Stack(
          children: [
            IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: top,
                    child: const ColoredBox(color: scrim),
                  ),
                  Positioned(
                    left: 0,
                    top: top,
                    width: left,
                    height: frameHeight,
                    child: const ColoredBox(color: scrim),
                  ),
                  Positioned(
                    right: 0,
                    top: top,
                    width: left,
                    height: frameHeight,
                    child: const ColoredBox(color: scrim),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: top + frameHeight,
                    bottom: 0,
                    child: const ColoredBox(color: scrim),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    width: frameWidth,
                    height: frameHeight,
                    child: CustomPaint(
                      key: ValueKey('scanner-frame-${mode.name}'),
                      painter: _ScannerFramePainter(),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    top: top + frameHeight + 24,
                    child: Text(
                      mode.instruction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasModeSelector)
              Positioned(
                left: 24,
                right: 24,
                top: 16,
                child: Center(
                  child: Material(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    child: SegmentedButton<ScannerMode>(
                      key: const ValueKey('scanner-mode-selector'),
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: ScannerMode.qr,
                          icon: Icon(Icons.qr_code_2_outlined),
                          label: Text('QR'),
                        ),
                        ButtonSegment(
                          value: ScannerMode.barcode,
                          icon: Icon(Icons.barcode_reader),
                          label: Text('Barcode'),
                        ),
                      ],
                      selected: {mode},
                      onSelectionChanged: (selection) {
                        onModeChanged(selection.single);
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

ScannerMode? scannerModeForBarcodeFormat(BarcodeFormat format) {
  return switch (format) {
    BarcodeFormat.qrCode || BarcodeFormat.microQrCode => ScannerMode.qr,
    BarcodeFormat.unknown || BarcodeFormat.all => null,
    _ => ScannerMode.barcode,
  };
}

BarcodeCapture filterScannerCapture(BarcodeCapture capture, ScannerMode mode) {
  return BarcodeCapture(
    barcodes: capture.barcodes
        .where((barcode) => scannerModeForBarcodeFormat(barcode.format) == mode)
        .toList(growable: false),
    image: capture.image,
    raw: capture.raw,
    size: capture.size,
  );
}

extension on ScannerMode {
  String get screenTitle => switch (this) {
    ScannerMode.qr => 'Scan QR code',
    ScannerMode.barcode => 'Scan barcode',
  };

  String get instruction => switch (this) {
    ScannerMode.qr => 'Align the QR code within the frame',
    ScannerMode.barcode => 'Align the barcode within the frame',
  };
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      border,
    );

    final corners = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    const length = 42.0;
    const inset = 4.0;
    final paths = [
      Path()
        ..moveTo(inset, length)
        ..lineTo(inset, inset)
        ..lineTo(length, inset),
      Path()
        ..moveTo(size.width - length, inset)
        ..lineTo(size.width - inset, inset)
        ..lineTo(size.width - inset, length),
      Path()
        ..moveTo(inset, size.height - length)
        ..lineTo(inset, size.height - inset)
        ..lineTo(length, size.height - inset),
      Path()
        ..moveTo(size.width - length, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset)
        ..lineTo(size.width - inset, size.height - length),
    ];
    for (final path in paths) {
      canvas.drawPath(path, corners);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QrIcon extends StatelessWidget {
  const QrIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/qr-code.svg',
      width: 80,
      height: 80,
      colorFilter: ColorFilter.mode(
        Theme.of(context).colorScheme.onSurface,
        BlendMode.srcIn,
      ),
    );
  }
}

class QrImageView extends StatelessWidget {
  const QrImageView({
    super.key,
    required this.data,
    this.size,
    this.color,
    this.backgroundColor = Colors.transparent,
    this.shape = 'square',
    this.padding = 8,
  });

  final String data;
  final double? size;
  final Color? color;
  final Color backgroundColor;
  final String shape;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final qrImage = _createQrImage(data);
    if (qrImage == null) {
      return SizedBox.square(
        dimension: size ?? 200,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(NahpuRadius.small),
          ),
          child: const Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Data is too large for QR code.\n Try using file export feature instead.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CustomPaint(
      size: size != null ? Size(size!, size!) : const Size.square(200),
      painter: _QrPainter(
        data: data,
        qrImage: qrImage,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        backgroundColor: backgroundColor,
        shape: shape,
        padding: padding,
      ),
    );
  }

  QrImage? _createQrImage(String data) {
    if (!canEncodeQrPayload(data)) {
      return null;
    }
    return QrImage(
      QrCode(
        payload: QrPayload.fromString(data),
        errorCorrectLevel: QrErrorCorrectLevel.low,
      ),
    );
  }
}

/// Displays a QR code using scan-safe colors and a responsive square surface.
///
/// This is the shared viewer for exchange dialogs and compact project
/// previews. The lower-level [QrImageView] remains configurable for document
/// templates and other callers that intentionally use custom colors/shapes.
class QrCodeViewer extends StatelessWidget {
  const QrCodeViewer({super.key, required this.data, this.maxSize = 400});

  final String data;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    assert(maxSize > 0);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSize, maxHeight: maxSize),
        child: AspectRatio(
          aspectRatio: 1,
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.black),
            child: QrImageView(
              data: data,
              color: Colors.black,
              backgroundColor: Colors.white,
              padding: NahpuSpacing.sm,
            ),
          ),
        ),
      ),
    );
  }
}

bool canEncodeQrPayload(String data) {
  try {
    QrCode(
      payload: QrPayload.fromString(data),
      errorCorrectLevel: QrErrorCorrectLevel.low,
    );
    return true;
  } on InputTooLongException {
    return false;
  }
}

class _QrPainter extends CustomPainter {
  final String data;
  final QrImage qrImage;
  final Color color;
  final Color backgroundColor;
  final String shape;
  final double padding;

  _QrPainter({
    required this.data,
    required this.qrImage,
    required this.color,
    required this.backgroundColor,
    required this.shape,
    required this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final moduleCount = qrImage.moduleCount;
    final squareSize = math.min(size.width, size.height);
    final inset = math.max(0, padding);
    final qrSize = math.max(0, squareSize - inset * 2);
    final moduleSize = qrSize / moduleCount;
    final originX = (size.width - squareSize) / 2 + inset;
    final originY = (size.height - squareSize) / 2 + inset;

    final backgroundRect = Rect.fromLTWH(
      (size.width - squareSize) / 2,
      (size.height - squareSize) / 2,
      squareSize,
      squareSize,
    );
    final backgroundRRect = RRect.fromRectAndRadius(
      backgroundRect,
      const Radius.circular(16),
    );

    final paint = Paint()..color = backgroundColor;
    canvas.drawRRect(backgroundRRect, paint);

    paint.color = color;
    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          if (shape == 'circle') {
            canvas.drawCircle(
              Offset(
                originX + (x + 0.5) * moduleSize,
                originY + (y + 0.5) * moduleSize,
              ),
              moduleSize / 2,
              paint,
            );
          } else {
            canvas.drawRect(
              Rect.fromLTWH(
                originX + x * moduleSize,
                originY + y * moduleSize,
                moduleSize,
                moduleSize,
              ),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.shape != shape ||
        oldDelegate.padding != padding;
  }
}
