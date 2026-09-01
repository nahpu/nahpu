import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;
import 'package:nahpu/services/templates/user_font_service.dart';
import 'package:nahpu/services/types/user_fonts.dart';

/// Font families bundled with the app, declared under `flutter.fonts` in
/// `pubspec.yaml` and shipped to the Typst compiler from `assets/fonts/`.
///
/// The strings are the internal typographic family names, so the same value
/// works as a Flutter `fontFamily`, a template dropdown key, and a Typst
/// `font:` argument.
const List<String> kBundledFontFamilies = [
  'Merriweather',
  'DejaVu Sans',
  'DejaVu Serif',
  'Libertinus Sans',
  'Libertinus Serif',
  'Plus Jakarta Sans',
];

/// The family used when a template asks for a font this installation does not
/// have. Matches the empty-family fallback in the Typst renderer.
const String kFallbackFontFamily = 'Merriweather';

/// One selectable font family, bundled or user-installed.
class FontFamilyEntry {
  const FontFamilyEntry({
    required this.family,
    required this.isBundled,
    this.userFont,
  });

  final String family;
  final bool isBundled;
  final UserFont? userFont;

  bool get hasBold => isBundled || (userFont?.hasBold ?? false);

  bool get hasItalic => isBundled || (userFont?.hasItalic ?? false);
}

/// The fonts available to templates: bundled families plus user-installed
/// families, with the runtime registration that makes the latter renderable.
class FontRegistry {
  const FontRegistry({this.userFonts = const []});

  final List<UserFont> userFonts;

  List<FontFamilyEntry> get entries => [
    for (final family in kBundledFontFamilies)
      FontFamilyEntry(family: family, isBundled: true),
    for (final font in userFonts)
      FontFamilyEntry(family: font.family, isBundled: false, userFont: font),
  ];

  List<String> get availableFamilies => [
    ...kBundledFontFamilies,
    ...userFonts.map((font) => font.family),
  ];

  bool isAvailable(String family) {
    final needle = family.trim();
    // An empty family means "use the default", which is always available.
    if (needle.isEmpty) return true;
    final lower = needle.toLowerCase();
    return availableFamilies.any((f) => f.toLowerCase() == lower);
  }

  /// Returns the families in [families] that this installation cannot render.
  Set<String> missingFrom(Iterable<String> families) => {
    for (final family in families)
      if (!isAvailable(family)) family.trim(),
  }..remove('');

  FontFamilyEntry? entryFor(String family) {
    final lower = family.trim().toLowerCase();
    for (final entry in entries) {
      if (entry.family.toLowerCase() == lower) return entry;
    }
    return null;
  }
}

/// Registers user-installed fonts with the Flutter engine so the template
/// canvas can render them under their own family name.
///
/// Failures are per-family: a corrupt file must not stop the app from
/// starting, and its family simply stays unavailable on the canvas.
Future<void> registerUserFonts({
  UserFontService service = const UserFontService(),
}) async {
  final UserFontCatalog catalog;
  try {
    catalog = await service.load();
  } on Object {
    return;
  }
  for (final font in catalog.fonts) {
    try {
      final loader = FontLoader(font.family);
      var added = false;
      for (final variant in font.variants) {
        final file = File(await service.filePath(font, variant));
        if (!await file.exists()) continue;
        final bytes = await file.readAsBytes();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
        added = true;
      }
      if (added) await loader.load();
    } on Object {
      continue;
    }
  }
}
