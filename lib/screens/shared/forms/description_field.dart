import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/types/export.dart';

/// Returns an error when [text] is longer than [kDescriptionMaxLength].
///
/// Counts user-perceived characters after trimming, the way the field counter
/// does, so a description the counter shows as fitting is accepted.
String? descriptionLengthError(String text) {
  if (text.trim().characters.length <= kDescriptionMaxLength) return null;
  return 'Use $kDescriptionMaxLength characters or fewer.';
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
          labelText: 'Description (optional)',
          errorText: descriptionLengthError(value.text),
          isDense: isDense,
          border: border,
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
