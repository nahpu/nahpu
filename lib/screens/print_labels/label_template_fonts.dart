import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nahpu/screens/print_labels/label_template_model.dart';

bool labelCanvasFontUsesGoogle(String fontFamilyRaw) {
  final f = fontFamilyRaw.trim().toLowerCase();
  if (f.isEmpty) return false;
  return !['merriweather', 'serif', 'sans-serif', 'monospace'].contains(f);
}

TextStyle customLabelCanvasTextStyle({
  required String fontFamilyRaw,
  required double fontSize,
  FontWeight fontWeight = FontWeight.normal,
  FontStyle fontStyle = FontStyle.normal,
}) {
  final raw = fontFamilyRaw.trim();
  if (raw.isEmpty) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }
  try {
    return GoogleFonts.getFont(
      raw,
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
    );
  } catch (_) {
    return TextStyle(
      fontFamily: raw,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }
}

Future<void> preloadGoogleFontForLabelCanvas(
  String fontFamilyRaw,
  FontWeight weight,
  FontStyle style,
) async {
  if (!labelCanvasFontUsesGoogle(fontFamilyRaw)) return;
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.getFont(
        fontFamilyRaw.trim(),
        textStyle: TextStyle(fontWeight: weight, fontStyle: style),
      ),
    ]);
  } catch (_) {}
}

Set<String> collectCustomTextFontKeys(LabelTemplate? template) {
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
const List<String> kLabelFontDropdownKeys = [
  '',
  'Merriweather',
  'Roboto',
  'Open Sans',
  'Lato',
  'Montserrat',
  'Source Sans 3',
  'Noto Sans',
];

String labelFontDropdownLabel(String key) {
  if (key.isEmpty) return 'Default';
  return key;
}

/// Maps stored [fontFamily] to a [kLabelFontDropdownKeys] entry when possible.
String normalizeLabelFontFamily(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '';
  for (final k in kLabelFontDropdownKeys) {
    if (k.isNotEmpty && k.toLowerCase() == t.toLowerCase()) return k;
  }
  return t;
}
