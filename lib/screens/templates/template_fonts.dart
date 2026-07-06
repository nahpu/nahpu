import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nahpu/screens/templates/template_model.dart';

bool templateCanvasFontUsesGoogle(String fontFamilyRaw) {
  final f = fontFamilyRaw.trim().toLowerCase();
  if (f.isEmpty) return false;
  return !['merriweather', 'serif', 'sans-serif', 'monospace'].contains(f);
}

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
  final textDecoration = decorations.isEmpty
      ? TextDecoration.none
      : TextDecoration.combine(decorations);
  final raw = fontFamilyRaw.trim();
  if (raw.isEmpty) {
    return TextStyle(
      fontFamily: 'Merriweather',
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: textDecoration,
    );
  }
  try {
    return GoogleFonts.getFont(
      raw,
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        decoration: textDecoration,
      ),
    );
  } catch (_) {
    return TextStyle(
      fontFamily: raw,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: textDecoration,
    );
  }
}

Future<void> preloadGoogleFontForTemplateCanvas(
  String fontFamilyRaw,
  FontWeight weight,
  FontStyle style,
) async {
  if (!templateCanvasFontUsesGoogle(fontFamilyRaw)) return;
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.getFont(
        fontFamilyRaw.trim(),
        textStyle: TextStyle(fontWeight: weight, fontStyle: style),
      ),
    ]);
  } catch (_) {}
}

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

/// Keys shown in the template editor font dropdown (empty = platform default).
const List<String> kTemplateFontDropdownKeys = [
  '',
  'Merriweather',
  'DejaVuSans',
  'DejaVuSerif',
  'LibertinusSans',
  'LibertinusSerif',
  'PlusJakartaSans',
];

String templateFontDropdownLabel(String key) {
  if (key.isEmpty) return 'Default';
  return key;
}

/// Maps stored [fontFamily] to a [kTemplateFontDropdownKeys] entry when possible.
String normalizeTemplateFontFamily(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '';
  for (final k in kTemplateFontDropdownKeys) {
    if (k.isNotEmpty && k.toLowerCase() == t.toLowerCase()) return k;
  }
  return t;
}
