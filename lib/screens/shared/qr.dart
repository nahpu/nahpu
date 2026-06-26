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

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR code'),
        ),
        body: MobileScanner(
          controller: _controller,
          onDetect: (barcode) {
            widget.onDetect(barcode);
            _controller.stop();
          },
        ));
  }
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
  });

  final String data;
  final double? size;
  final Color? color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size != null ? Size(size!, size!) : const Size.square(200),
      painter: _QrPainter(
        data: data,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String data;
  final Color color;
  final Color backgroundColor;

  _QrPainter({
    required this.data,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.L,
    );
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;
    final moduleSize = size.width / moduleCount;

    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    paint.color = color;
    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH(
                x * moduleSize, y * moduleSize, moduleSize, moduleSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
