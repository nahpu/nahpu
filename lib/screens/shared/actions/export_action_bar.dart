import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as p;

class ExportLocationCard extends StatelessWidget {
  ExportLocationCard({
    super.key,
    required this.selectedDir,
    required this.output,
    required this.onSelectDir,
    required this.onClearDir,
    required this.onShare,
    required this.onOpenFolder,
    required this.onSaveCopy,
    required this.onDismiss,
    this.outputBytes,
    this.duration,
    this.enabled = true,
    ExportDestinationMode? destinationMode,
    SavedFileAction? savedFileAction,
  }) : destinationMode = destinationMode ?? platformExportDestination,
       savedFileAction = savedFileAction ?? platformSavedFileAction;

  final Directory? selectedDir;

  final File? output;

  final VoidCallback onSelectDir;
  final VoidCallback onClearDir;
  final VoidCallback onShare;
  final VoidCallback onOpenFolder;
  final VoidCallback onSaveCopy;

  final VoidCallback onDismiss;

  final int? outputBytes;
  final Duration? duration;
  final bool enabled;

  final ExportDestinationMode destinationMode;
  final SavedFileAction savedFileAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NahpuPanel(
      child: output == null
          ? _destination(context, theme)
          : _result(context, theme),
    );
  }

  Widget _destination(BuildContext context, ThemeData theme) {
    return ExportDestinationField(
      mode: destinationMode,
      selectedDir: selectedDir,
      onSelectDir: enabled ? onSelectDir : () {},
      onClearDir: enabled ? onClearDir : () {},
    );
  }

  Widget _result(BuildContext context, ThemeData theme) {
    final file = output!;
    final sizeAndDuration = _sizeAndDuration();
    final isTemporary = destinationMode == ExportDestinationMode.temporary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isTemporary
                  ? Icons.adaptive.share_outlined
                  : Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
              size: NahpuControlSize.iconMedium,
            ),
            const SizedBox(width: NahpuSpacing.md),
            Expanded(
              child: Text(
                // "Saved" means it is on disk where the user left it;
                // "Export complete" means it is done but will not survive the
                // next export. The word "Share" belongs to the button below.
                isTemporary ? 'Export complete' : 'Saved',
                style: theme.textTheme.titleSmall,
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded),
              iconSize: NahpuControlSize.iconMedium,
              tooltip: 'Hide save location',
            ),
          ],
        ),
        const SizedBox(height: NahpuSpacing.xs),
        Text(
          p.basename(file.path),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
        if (sizeAndDuration != null)
          Padding(
            padding: const EdgeInsets.only(top: NahpuSpacing.xs),
            child: Text(
              sizeAndDuration,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: NahpuSpacing.md),
          child: Text(
            _detail(file),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: NahpuSpacing.xl),
        SavedFileActions(
          action: savedFileAction,
          file: file,
          onShare: onShare,
          onReveal: onOpenFolder,
          onSaveCopy: onSaveCopy,
        ),
      ],
    );
  }

  /// What the file's location means to the user.
  ///
  /// Only a folder the user chose is worth printing. The fallback is an
  /// app-private directory whose path is meaningless on Android and unhelpful
  /// on desktop, so it is described rather than shown.
  String _detail(File file) {
    if (destinationMode == ExportDestinationMode.temporary) {
      return 'Share this file now to keep it. NAHPU removes it when you '
          'export again.';
    }
    if (selectedDir != null) return file.path;
    return 'Saved in NAHPU app storage. Choose a folder next time to save '
        'straight to it.';
  }

  String? _sizeAndDuration() {
    final bytes = outputBytes;
    final elapsed = duration;
    if (bytes == null && elapsed == null) return null;
    if (bytes == null) return 'Finished in ${formatExportDuration(elapsed!)}';
    if (elapsed == null) return formatByteSize(bytes);
    return '${formatByteSize(bytes)} in ${formatExportDuration(elapsed)}';
  }
}

class ExportActionBar extends StatelessWidget {
  const ExportActionBar({
    super.key,
    required this.label,
    required this.repeatLabel,
    required this.icon,
    required this.canExport,
    required this.isRunning,
    required this.onExport,
    required this.hasOutput,
  });

  final String label;

  final String repeatLabel;

  final IconData icon;
  final bool canExport;
  final bool isRunning;
  final VoidCallback onExport;
  final bool hasOutput;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: NahpuElevation.none,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: NahpuContentWidth.form),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                NahpuSpacing.md,
                NahpuSpacing.lg,
                NahpuSpacing.md,
                NahpuSpacing.lg,
              ),
              child: Center(
                child: PrimaryButton(
                  label: hasOutput ? repeatLabel : label,
                  icon: icon,
                  isRunning: isRunning,
                  onPressed: canExport ? onExport : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The actions offered once an export has been written.
///
/// Share is always there; what sits beside it is the one thing this platform
/// can do with a finished file, which differs by platform rather than by
/// screen. Both the export screens and the export dialogs render this, so the
/// two families cannot drift apart.
class SavedFileActions extends StatelessWidget {
  const SavedFileActions({
    super.key,
    required this.action,
    required this.file,
    required this.onShare,
    required this.onReveal,
    required this.onSaveCopy,
  });

  final SavedFileAction action;
  final File file;
  final VoidCallback onShare;
  final VoidCallback onReveal;
  final VoidCallback onSaveCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final services = FilePickerServices();
    final canSaveCopy =
        action == SavedFileAction.saveCopy && services.canSaveCopyOf(file);
    final tooLarge =
        action == SavedFileAction.saveCopy &&
        services.exceedsSaveCopyLimit(file);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: NahpuSpacing.lg,
          runSpacing: NahpuSpacing.md,
          children: [
            ShareButton(onPressed: onShare),
            switch (action) {
              SavedFileAction.reveal => OutlinedButton.icon(
                onPressed: onReveal,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open directory'),
              ),
              SavedFileAction.saveCopy when canSaveCopy => OutlinedButton.icon(
                onPressed: onSaveCopy,
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Save to device'),
              ),
              _ => const SizedBox.shrink(),
            },
          ],
        ),
        if (tooLarge)
          Padding(
            padding: const EdgeInsets.only(top: NahpuSpacing.md),
            child: Text(
              'Too large to save through the Files app, which is limited to '
              '${formatByteSize(FilePickerServices.maxSaveCopyBytes)}. Choose '
              'a folder before exporting to write files this size straight to '
              'your device.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
