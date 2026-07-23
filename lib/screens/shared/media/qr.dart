import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr/qr.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.onDetect});

  final void Function(BarcodeCapture) onDetect;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _hasDetected = false;

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: const Text('Scan QR code')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (barcode) {
              if (_hasDetected) return;
              _hasDetected = true;
              _controller.stop();
              widget.onDetect(barcode);
            },
          ),
          const IgnorePointer(child: _ScannerOverlay()),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameSize = constraints.maxWidth.clamp(220.0, 300.0);
        final left = (constraints.maxWidth - frameSize) / 2;
        final top = (constraints.maxHeight - frameSize) / 2 - 28;
        const scrim = Color(0x99000000);
        return Stack(
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
              height: frameSize,
              child: const ColoredBox(color: scrim),
            ),
            Positioned(
              right: 0,
              top: top,
              width: left,
              height: frameSize,
              child: const ColoredBox(color: scrim),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: top + frameSize,
              bottom: 0,
              child: const ColoredBox(color: scrim),
            ),
            Positioned(
              left: left,
              top: top,
              width: frameSize,
              height: frameSize,
              child: CustomPaint(painter: _ScannerFramePainter()),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: top + frameSize + 24,
              child: const Text(
                'Align the QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
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
  });

  final String data;
  final double? size;
  final Color? color;
  final Color backgroundColor;
  final String shape;

  @override
  Widget build(BuildContext context) {
    final qrImage = _createQrImage(data);
    if (qrImage == null) {
      return SizedBox.square(
        dimension: size ?? 200,
        child: ColoredBox(
          color: backgroundColor,
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

  _QrPainter({
    required this.data,
    required this.qrImage,
    required this.color,
    required this.backgroundColor,
    required this.shape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final moduleCount = qrImage.moduleCount;
    final moduleSize = size.width / moduleCount;

    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    paint.color = color;
    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          if (shape == 'circle') {
            canvas.drawCircle(
              Offset((x + 0.5) * moduleSize, (y + 0.5) * moduleSize),
              moduleSize / 2,
              paint,
            );
          } else {
            canvas.drawRect(
              Rect.fromLTWH(
                x * moduleSize,
                y * moduleSize,
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
        oldDelegate.shape != shape;
  }
}
