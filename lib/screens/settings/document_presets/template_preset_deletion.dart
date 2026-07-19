import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/template_preset_management_service.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class TemplatePresetDeletionRequest {
  const TemplatePresetDeletionRequest({
    required this.name,
    this.replacementName,
  });

  final String name;
  final String? replacementName;
}

Future<TemplatePresetDeletionRequest?> showTemplatePresetDeletionDialog({
  required BuildContext context,
  required Template target,
  required List<rust_config.TemplatePresetUsage> usages,
  required List<TemplatePresetSummary> candidates,
}) {
  final compatibleCandidates = candidates
      .where((summary) =>
          summary.template.name != target.name &&
          summary.template.recordType == target.recordType)
      .toList();

  return showDialog<TemplatePresetDeletionRequest>(
    context: context,
    builder: (context) => _TemplatePresetDeletionDialog(
      target: target,
      usages: usages,
      candidates: compatibleCandidates,
    ),
  );
}

class _TemplatePresetDeletionDialog extends StatefulWidget {
  const _TemplatePresetDeletionDialog({
    required this.target,
    required this.usages,
    required this.candidates,
  });

  final Template target;
  final List<rust_config.TemplatePresetUsage> usages;
  final List<TemplatePresetSummary> candidates;

  @override
  State<_TemplatePresetDeletionDialog> createState() =>
      _TemplatePresetDeletionDialogState();
}

class _TemplatePresetDeletionDialogState
    extends State<_TemplatePresetDeletionDialog> {
  String? _replacementName;

  @override
  Widget build(BuildContext context) {
    final hasUsages = widget.usages.isNotEmpty;
    final usageCount = widget.usages.fold<int>(
      0,
      (total, usage) => total + usage.blockIndices.length,
    );
    final canDelete = !hasUsages || _replacementName != null;

    return AlertDialog(
      title: const Text('Delete template'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delete "${widget.target.name}"?'),
              const SizedBox(height: 12),
              if (!hasUsages)
                const Text(
                    'This template is unused and will be permanently removed.')
              else ...[
                Text(
                  'This template is used by $usageCount block${usageCount == 1 ? '' : 's'} '
                  'in ${widget.usages.length} print layout${widget.usages.length == 1 ? '' : 's'}. '
                  'Choose a replacement before deleting it.',
                ),
                const SizedBox(height: 12),
                ...widget.usages.map(
                  (usage) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${usage.layoutName}: block${usage.blockIndices.length == 1 ? '' : 's'} '
                      '${usage.blockIndices.map((index) => index + 1).join(', ')}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.candidates.isEmpty)
                  const Text(
                    'Create another template with the same record type, or change the affected '
                    'layout blocks before deleting this one.',
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _replacementName,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Replacement template',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.candidates
                        .map(
                          (candidate) => DropdownMenuItem(
                            value: candidate.template.name,
                            child: Text(
                              '${candidate.template.name} '
                              '(${candidate.template.widthMm.toStringAsFixed(0)} × '
                              '${candidate.template.heightMm.toStringAsFixed(0)} mm)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _replacementName = value;
                      });
                    },
                  ),
                const SizedBox(height: 8),
                const Text(
                  'Page size, margins, grid, and padding will stay unchanged. Review the '
                  'affected print layouts after replacement.',
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: canDelete
              ? () => Navigator.pop(
                    context,
                    TemplatePresetDeletionRequest(
                      name: widget.target.name,
                      replacementName: _replacementName,
                    ),
                  )
              : null,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
