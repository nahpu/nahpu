import 'package:nahpu/src/rust/api/config.dart' as rust_config;

/// Persists names of bundled templates intentionally removed by the user.
///
/// The list lives in the config database so it is included in user-config
/// backups and prevents startup seeding from restoring deleted templates.
class BundledTemplatePresetService {
  const BundledTemplatePresetService();

  static const String _suppressedTemplateNamesKey =
      'document_suppressed_bundled_template_presets';

  Future<Set<String>> getSuppressedNames() async {
    final names = await rust_config.getUserConfigList(
      key: _suppressedTemplateNamesKey,
    );
    return names?.toSet() ?? <String>{};
  }

  Future<bool> suppress(String name) async {
    final names = await getSuppressedNames();
    if (!names.add(name)) return false;
    await _save(names);
    return true;
  }

  Future<void> restore(String name) async {
    final names = await getSuppressedNames();
    if (!names.remove(name)) return;
    await _save(names);
  }

  Future<void> restoreAll() async {
    await _save(<String>{});
  }

  Future<void> _save(Set<String> names) async {
    final ordered = names.toList()..sort();
    await rust_config.setUserConfigList(
      key: _suppressedTemplateNamesKey,
      value: ordered,
    );
  }
}
