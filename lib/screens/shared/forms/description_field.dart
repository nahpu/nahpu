import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/types/export.dart';

/// Whether [text] is longer than [kDescriptionMaxLength].
///
/// Counts user-perceived characters after trimming, the way the field counter
/// does, so a description the counter shows as fitting is accepted.
bool isDescriptionTooLong(String text) {
  return text.trim().characters.length > kDescriptionMaxLength;
}

/// Returns a localized error when [text] is longer than
/// [kDescriptionMaxLength], or null when it fits.
String? descriptionLengthError(AppLocalizations l10n, String text) {
  if (!isDescriptionTooLong(text)) return null;
  return l10n.formsDescriptionTooLong(kDescriptionMaxLength);
}

/// Optional short description input for presets and templates.
///
/// Text over the limit is kept rather than cut, so an older, longer
/// description loads intact; the counter and error mark it until it is
/// shortened.
class DescriptionField extends StatelessWidget {
  const DescriptionField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.isDense = false,
    this.border,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool isDense;
  final InputBorder? border;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        maxLength: kDescriptionMaxLength,
        maxLengthEnforcement: MaxLengthEnforcement.none,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: context.l10n.formsDescriptionOptional,
          errorText: descriptionLengthError(context.l10n, value.text),
          isDense: isDense,
          border: border,
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
