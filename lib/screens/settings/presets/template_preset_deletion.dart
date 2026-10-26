import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/localization/l10n.dart';
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
      .where(
        (summary) =>
            summary.template.name != target.name &&
            summary.template.recordType == target.recordType,
      )
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
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.presetsTemplateDeleteTitle),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.presetsDeleteNamePrompt(widget.target.name)),
              const SizedBox(height: 12),
              if (!hasUsages)
                Text(l10n.presetsTemplateUnusedDelete)
              else ...[
                Text(
                  l10n.presetsTemplateInUse(usageCount, widget.usages.length),
                ),
                const SizedBox(height: 12),
                ...widget.usages.map((usage) {
                  final blocks = usage.blockIndices
                      .map((index) => index + 1)
                      .join(', ');
                  final line = l10n.presetsTemplateUsageBlocks(
                    usage.layoutName,
                    usage.blockIndices.length,
                    blocks,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $line'),
                  );
                }),
                const SizedBox(height: 16),
                if (widget.candidates.isEmpty)
                  Text(l10n.presetsTemplateNoReplacement)
                else
                  DropdownButtonFormField<String>(
                    initialValue: _replacementName,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.presetsTemplateReplacement,
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
                Text(l10n.presetsTemplateReplacementNote),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
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
          child: Text(l10n.commonDelete),
        ),
      ],
    );
  }
}
