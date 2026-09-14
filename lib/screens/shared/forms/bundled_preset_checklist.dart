import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/settings/bundled_preset_service.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Bundled presets as checkboxes grouped by kind, in one panel.
///
/// A preset that is already saved shows checked, disabled, and marked Added.
class BundledPresetChecklist extends StatelessWidget {
  const BundledPresetChecklist({
    super.key,
    required this.statuses,
    required this.isChecked,
    required this.onChanged,
    this.title,
    this.message,
  });

  final List<BundledPresetStatus> statuses;
  final bool Function(BundledPresetStatus status) isChecked;
  final void Function(BundledPreset preset, bool value) onChanged;
  final String? title;
  final String? message;

  static const _groups = [
    ('Documents', BundledPresetKind.document),
    ('Tabular records', BundledPresetKind.record),
    ('Templates', BundledPresetKind.template),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = this.title;
    final message = this.message;
    final groups = [
      for (final group in _groups)
        if (statuses.any((status) => status.preset.kind == group.$2)) group,
    ];
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) Text(title, style: textTheme.titleMedium),
          if (message != null) ...[
            const SizedBox(height: NahpuSpacing.xs),
            Text(message, style: textTheme.bodyMedium),
          ],
          for (final (index, (label, kind)) in groups.indexed) ...[
            if (index > 0 || title != null || message != null)
              const SizedBox(height: NahpuSpacing.lg),
            Text(label, style: textTheme.titleSmall),
            for (final status in statuses)
              if (status.preset.kind == kind)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isChecked(status),
                  onChanged: status.isInstalled
                      ? null
                      : (value) => onChanged(status.preset, value ?? false),
                  title: Text(status.preset.name),
                  subtitle: Text(
                    status.isInstalled
                        ? 'Added · ${status.preset.description}'
                        : status.preset.description,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
