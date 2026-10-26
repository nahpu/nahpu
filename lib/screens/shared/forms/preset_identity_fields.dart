import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/description_field.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Name and description fields for a preset, with Duplicate above them and
/// Update below.
///
/// Tabular and document presets share this layout so both edit screens look
/// and behave the same. The caller owns validation and saving.
class PresetIdentityFields extends StatelessWidget {
  const PresetIdentityFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.hasChanges,
    required this.canUpdate,
    required this.onUpdate,
    required this.onDuplicate,
    this.isUpdating = false,
    this.nameErrorText,
    this.onNameChanged,
    this.onDescriptionChanged,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;

  /// Whether the name or description differs from the saved preset.
  final bool hasChanges;

  /// Whether a changed, valid name or description can be committed.
  final bool canUpdate;
  final bool isUpdating;
  final VoidCallback onUpdate;
  final VoidCallback? onDuplicate;
  final String? nameErrorText;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: onDuplicate,
            icon: const Icon(Icons.copy_outlined),
            label: Text(l10n.formsPresetDuplicate),
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.formsPresetName,
            errorText: nameErrorText,
            helperText: hasChanges && nameErrorText == null
                ? l10n.formsPresetUpdateHelper
                : null,
          ),
          onChanged: onNameChanged,
          onSubmitted: (_) {
            if (canUpdate) onUpdate();
          },
        ),
        const SizedBox(height: NahpuSpacing.lg),
        DescriptionField(
          controller: descriptionController,
          onChanged: onDescriptionChanged,
          onSubmitted: (_) {
            if (canUpdate) onUpdate();
          },
        ),
        const SizedBox(height: NahpuSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: PrimaryButton(
            label: l10n.formsPresetUpdate,
            icon: Icons.check,
            isRunning: isUpdating,
            onPressed: canUpdate ? onUpdate : null,
          ),
        ),
      ],
    );
  }
}
