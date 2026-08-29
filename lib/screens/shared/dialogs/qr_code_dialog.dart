import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/media/qr.dart';

class QrCodeDialog extends StatelessWidget {
  const QrCodeDialog({
    super.key,
    required this.title,
    required this.data,
    required this.description,
  });

  final String title;
  final String data;
  final String description;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrCodeViewer(data: data),
            const SizedBox(height: 12),
            Text(description, textAlign: TextAlign.center),
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
