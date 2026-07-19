import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';

class ExportShareButton extends StatelessWidget {
  const ExportShareButton({
    super.key,
    required this.hasExported,
    required this.isRunning,
    required this.onExport,
    required this.onShare,
  });

  final bool hasExported;
  final bool isRunning;
  final VoidCallback? onExport;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    if (hasExported) {
      return ShareButton(onPressed: onShare);
    }
    return ProgressButton(
      label: 'Export',
      icon: Icons.file_upload_outlined,
      isRunning: isRunning,
      onPressed: onExport,
    );
  }
}
