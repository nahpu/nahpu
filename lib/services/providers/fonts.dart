import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/templates/font_registry.dart';
import 'package:nahpu/services/templates/user_font_service.dart';
import 'package:nahpu/services/types/user_fonts.dart';

final fontRegistryProvider =
    AsyncNotifierProvider<FontRegistryNotifier, FontRegistry>(
      FontRegistryNotifier.new,
    );

class FontRegistryNotifier extends AsyncNotifier<FontRegistry> {
  final _service = const UserFontService();

  @override
  Future<FontRegistry> build() async {
    final catalog = await _service.load();
    return FontRegistry(userFonts: catalog.fonts);
  }

  /// Installs [file] and registers the family for canvas rendering.
  Future<UserFont> importFile(File file) async {
    final result = await _service.importFile(file);
    await registerUserFonts(service: _service);
    state = AsyncValue.data(FontRegistry(userFonts: result.catalog.fonts));
    return result.font;
  }

  Future<void> delete(UserFont font) async {
    final catalog = await _service.deleteFont(font);
    state = AsyncValue.data(FontRegistry(userFonts: catalog.fonts));
  }
}
