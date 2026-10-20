import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/services/common/platform_services.dart';

class ExportShareButton extends StatelessWidget {
  ExportShareButton({
    super.key,
    required this.hasExported,
    required this.isRunning,
    required this.onExport,
    required this.onShare,
    this.output,
    this.onRevealFile,
    this.onSaveCopy,
    SavedFileAction? savedFileAction,
  }) : savedFileAction = savedFileAction ?? platformSavedFileAction;

  final bool hasExported;
  final bool isRunning;
  final VoidCallback? onExport;
  final VoidCallback onShare;

  /// The finished file, when the caller can offer more than Share.
  ///
  /// Without it the dialog keeps its original single-button behaviour, since
  /// both extra actions need a file to act on.
  final File? output;

  final VoidCallback? onRevealFile;
  final VoidCallback? onSaveCopy;
  final SavedFileAction savedFileAction;

  @override
  Widget build(BuildContext context) {
    if (!hasExported) {
      return ProgressButton(
        label: 'Export',
        icon: Icons.file_upload_outlined,
        isRunning: isRunning,
        onPressed: onExport,
      );
    }
    final file = output;
    if (file == null) return ShareButton(onPressed: onShare);
    return SavedFileActions(
      action: _wiredAction,
      file: file,
      onShare: onShare,
      onReveal: onRevealFile ?? () {},
      onSaveCopy: onSaveCopy ?? () {},
    );
  }

  /// The platform's action, less any the caller has not wired up.
  ///
  /// Rendering a button whose handler is missing would offer the user an
  /// action that silently does nothing.
  SavedFileAction get _wiredAction => switch (savedFileAction) {
    SavedFileAction.reveal when onRevealFile == null => SavedFileAction.none,
    SavedFileAction.saveCopy when onSaveCopy == null => SavedFileAction.none,
    final wired => wired,
  };
}
