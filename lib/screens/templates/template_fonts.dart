import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/font_registry.dart';

/// Builds the canvas text style for a template text element.
///
/// Bundled families come from `pubspec.yaml`; user-installed families are
/// registered at startup with [registerUserFonts], so both resolve through a
/// plain `fontFamily`. An unavailable family falls back to the platform
/// default rather than failing to paint.
TextStyle customTemplateCanvasTextStyle({
  required String fontFamilyRaw,
  required double fontSize,
  FontWeight fontWeight = FontWeight.normal,
  FontStyle fontStyle = FontStyle.normal,
  bool underline = false,
  bool strikethrough = false,
}) {
  final decorations = <TextDecoration>[
    if (underline) TextDecoration.underline,
    if (strikethrough) TextDecoration.lineThrough,
  ];
  // Normalize so legacy stored keys such as `DejaVuSans` resolve to the
  // family name the app actually declares.
  final raw = normalizeTemplateFontFamily(fontFamilyRaw);
  return TextStyle(
    fontFamily: raw.isEmpty ? kFallbackFontFamily : raw,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    decoration: decorations.isEmpty
        ? TextDecoration.none
        : TextDecoration.combine(decorations),
  );
}

/// Collects every font family referenced by [template]'s text elements.
Set<String> collectTemplateTextFontKeys(Template? template) {
  final keys = <String>{};
  if (template == null) return keys;
  for (final p in [template.page1, template.page2]) {
    for (final t in p.customTexts) {
      if (t.fontFamily.trim().isNotEmpty) keys.add(t.fontFamily.trim());
    }
  }
  return keys;
}

/// Keys shown in the template editor font dropdown (empty = default).
List<String> templateFontDropdownKeys(FontRegistry registry) => [
  '',
  ...registry.availableFamilies,
];

String templateFontDropdownLabel(String key) {
  if (key.isEmpty) return 'Default';
  return key;
}

/// Maps a stored [raw] family onto an available family when one matches,
/// ignoring case and spacing so legacy keys such as `DejaVuSans` resolve to
/// the font's real name.
String normalizeTemplateFontFamily(String raw, {FontRegistry? registry}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final compact = trimmed.replaceAll(' ', '').toLowerCase();
  final families = registry?.availableFamilies ?? kBundledFontFamilies;
  for (final family in families) {
    if (family.replaceAll(' ', '').toLowerCase() == compact) return family;
  }
  return trimmed;
}
