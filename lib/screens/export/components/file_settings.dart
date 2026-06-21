import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';

class FileSettingsCard extends StatelessWidget {
  const FileSettingsCard({
    super.key,
    required this.exportCtr,
    required this.selectedDir,
    required this.onExportFmtChanged,
    required this.onFileNameChanged,
    required this.onSelectDir,
    required this.onClearDir,
  });

  final FileOpCtrModel exportCtr;
  final Directory? selectedDir;
  final void Function(ExportFmt?) onExportFmtChanged;
  final void Function(String?) onFileNameChanged;
  final VoidCallback onSelectDir;
  final VoidCallback onClearDir;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExportFmt>(
              initialValue: exportCtr.exportFmtCtr,
              decoration: const InputDecoration(
                labelText: 'File format',
              ),
              items: exportFormats
                  .map((e) => DropdownMenuItem(
                        value: ExportFmt.values[exportFormats.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: onExportFmtChanged,
            ),
            FileNameField(
              controller: exportCtr,
              onChanged: onFileNameChanged,
            ),
            Visibility(
              visible: !Platform.isIOS,
              child: SelectDirField(
                dirPath: selectedDir,
                onPressed: onSelectDir,
                onCanceled: onClearDir,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
