import 'dart:io';

import 'package:flutter/material.dart';

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
              Text(
                'Save to',
                style: Theme.of(context).textTheme.titleSmall,
              ),
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
