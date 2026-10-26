import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/styles/design_tokens.dart';

class AppendDateSwitch extends StatelessWidget {
  const AppendDateSwitch({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: enabled ? onChanged : null,
      title: Text(context.l10n.sharedAppendDate),
      subtitle: Text(context.l10n.sharedAppendDateDescription),
    );
  }
}

class FileSettingsDirectoryPicker extends StatelessWidget {
  const FileSettingsDirectoryPicker({
    super.key,
    required this.selectedDir,
    required this.onSelectDir,
    required this.onClearDir,
  });

  final Directory? selectedDir;
  final VoidCallback onSelectDir;
  final VoidCallback onClearDir;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.sharedSaveTo,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                selectedDir?.path ?? l10n.sharedSelectDirectory,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        selectedDir == null
            ? OutlinedButton.icon(
                onPressed: onSelectDir,
                icon: const Icon(Icons.folder_outlined),
                label: Text(l10n.databaseBrowse),
              )
            : IconButton(
                onPressed: onClearDir,
                icon: const Icon(Icons.clear_rounded),
                tooltip: l10n.sharedClearDirectory,
              ),
      ],
    );
  }
}

/// The "Save to" block of an export surface.
///
/// Shows a directory picker where NAHPU can write to a folder the user chose,
/// and explains where the file goes where it cannot. Both the export screens'
/// location card and the export dialogs render this, so the destination rule
/// and its wording live in one place.
class ExportDestinationField extends StatelessWidget {
  const ExportDestinationField({
    super.key,
    required this.mode,
    required this.selectedDir,
    required this.onSelectDir,
    required this.onClearDir,
  });

  final ExportDestinationMode mode;
  final Directory? selectedDir;
  final VoidCallback onSelectDir;
  final VoidCallback onClearDir;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: switch (mode) {
        ExportDestinationMode.chooseDirectory => [
          FileSettingsDirectoryPicker(
            selectedDir: selectedDir,
            onSelectDir: onSelectDir,
            onClearDir: onClearDir,
          ),
          if (selectedDir == null) ...[
            const SizedBox(height: NahpuSpacing.md),
            _Caption(l10n.sharedNoFolderChosen, theme: theme),
          ],
        ],
        ExportDestinationMode.temporary => [
          Text(l10n.sharedSaveTo, style: theme.textTheme.titleSmall),
          const SizedBox(height: NahpuSpacing.xs),
          Text(l10n.sharedShareAfterExport, style: theme.textTheme.bodyMedium),
          const SizedBox(height: NahpuSpacing.md),
          _Caption(l10n.sharedTemporaryExportNote, theme: theme),
        ],
      },
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text, {required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
