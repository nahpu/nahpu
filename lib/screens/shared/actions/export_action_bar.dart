import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as p;

/// The one place an export says where its file goes, and the only place it
/// offers to share it.
class ExportLocationCard extends StatelessWidget {
  ExportLocationCard({
    super.key,
    required this.selectedDir,
    required this.output,
    required this.onSelectDir,
    required this.onClearDir,
    required this.onShare,
    required this.onOpenFolder,
    required this.onDismiss,
    this.outputBytes,
    this.duration,
    this.enabled = true,
    bool? isDesktop,
  }) : isDesktop = isDesktop ?? systemPlatform == PlatformType.desktop;

  final Directory? selectedDir;

  final File? output;

  final VoidCallback onSelectDir;
  final VoidCallback onClearDir;
  final VoidCallback onShare;
  final VoidCallback onOpenFolder;

  final VoidCallback onDismiss;

  final int? outputBytes;
  final Duration? duration;
  final bool enabled;

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: NahpuElevation.none,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: output == null
            ? _destination(context, theme)
            : _result(context, theme),
      ),
    );
  }

  Widget _destination(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          FileSettingsDirectoryPicker(
            selectedDir: selectedDir,
            onSelectDir: enabled ? onSelectDir : () {},
            onClearDir: enabled ? onClearDir : () {},
          )
        else ...[
          Text('Save to', style: theme.textTheme.titleSmall),
          const SizedBox(height: NahpuSpacing.xs),
          Text('NAHPU app storage', style: theme.textTheme.bodyMedium),
          const SizedBox(height: NahpuSpacing.md),
          Text(
            'Exports stay in NAHPU on this device. Share the file to save a '
            'copy to your device storage or send it to another app.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _result(BuildContext context, ThemeData theme) {
    final file = output!;
    final sizeAndDuration = _sizeAndDuration();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isDesktop
                  ? Icons.check_circle_rounded
                  : Icons.adaptive.share_outlined,
              color: theme.colorScheme.primary,
              size: NahpuControlSize.iconMedium,
            ),
            const SizedBox(width: NahpuSpacing.md),
            Expanded(
              child: Text(
                // The word "Share" belongs to the button below; repeating it
                // here would read as two different offers.
                isDesktop ? 'Saved' : 'Export complete',
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
            isDesktop
                ? file.path
                : 'Export complete. Use Share to save this file to your device '
                      'storage or send it to another app.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: NahpuSpacing.xl),
        Wrap(
          spacing: NahpuSpacing.lg,
          runSpacing: NahpuSpacing.md,
          children: [
            ShareButton(onPressed: onShare),
            if (isDesktop)
              OutlinedButton.icon(
                onPressed: onOpenFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open directory'),
              ),
          ],
        ),
      ],
    );
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
