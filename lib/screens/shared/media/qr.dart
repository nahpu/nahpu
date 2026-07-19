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
    try {
      return QrImage(
        QrCode(
          payload: QrPayload.fromString(data),
          errorCorrectLevel: QrErrorCorrectLevel.low,
        ),
      );
    } on InputTooLongException {
      return null;
    }
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
                  x * moduleSize, y * moduleSize, moduleSize, moduleSize),
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
