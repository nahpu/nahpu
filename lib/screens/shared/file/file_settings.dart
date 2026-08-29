import 'dart:io';

import 'package:material_ui/material_ui.dart';

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
      title: const Text('Append current date'),
      subtitle: const Text('Adds -yyyy-mm-dd to the filename'),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Save to', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                selectedDir?.path ?? 'Select directory',
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
                label: const Text('Browse'),
              )
            : IconButton(
                onPressed: onClearDir,
                icon: const Icon(Icons.clear_rounded),
                tooltip: 'Clear directory',
              ),
      ],
    );
  }
}
