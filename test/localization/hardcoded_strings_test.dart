import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Screens already moved to `context.l10n`. Add a file once it has no
/// user-facing literals left, so later edits cannot slip English back in.
final _localizedFiles = [
  p.join('lib', 'screens', 'home', 'home.dart'),
  p.join('lib', 'screens', 'home', 'components', 'body.dart'),
  p.join('lib', 'screens', 'home', 'components', 'cookbook.dart'),
  p.join('lib', 'screens', 'home', 'components', 'global_search.dart'),
  p.join('lib', 'screens', 'home', 'components', 'menu_drawer.dart'),
  p.join('lib', 'screens', 'home', 'components', 'project_actions.dart'),
  p.join('lib', 'screens', 'narrative', 'narrative_form.dart'),
  p.join('lib', 'screens', 'narrative', 'narrative_view.dart'),
  p.join('lib', 'screens', 'narrative', 'components', 'menu_bar.dart'),
  p.join('lib', 'screens', 'narrative', 'components', 'top_forms.dart'),
  p.join(
    'lib',
    'screens',
    'settings',
    'application',
    'application_settings.dart',
  ),
  p.join('lib', 'screens', 'settings', 'application', 'data_usage.dart'),
  p.join('lib', 'screens', 'settings', 'application', 'file_tree.dart'),
  p.join('lib', 'screens', 'settings', 'application', 'map_settings.dart'),
  p.join(
    'lib',
    'screens',
    'settings',
    'application',
    'project_tool_settings.dart',
  ),
  p.join('lib', 'screens', 'settings', 'application', 'selection_review.dart'),
  p.join('lib', 'screens', 'settings', 'common.dart'),
  p.join('lib', 'screens', 'settings', 'database', 'db_settings.dart'),
  p.join('lib', 'screens', 'settings', 'onboarding', 'setup_wizard.dart'),
  p.join('lib', 'screens', 'settings', 'presets', 'document_presets.dart'),
  p.join('lib', 'screens', 'settings', 'presets', 'export_preset_edit.dart'),
  p.join('lib', 'screens', 'settings', 'presets', 'export_preset_fields.dart'),
  p.join('lib', 'screens', 'settings', 'presets', 'export_presets.dart'),
  p.join('lib', 'screens', 'settings', 'presets', 'font_manager.dart'),
  p.join(
    'lib',
    'screens',
    'settings',
    'presets',
    'template_preset_deletion.dart',
  ),
  p.join(
    'lib',
    'screens',
    'settings',
    'presets',
    'template_preset_manager.dart',
  ),
  p.join('lib', 'screens', 'settings', 'records', 'catalog_format.dart'),
  p.join('lib', 'screens', 'settings', 'records', 'collevent_settings.dart'),
  p.join('lib', 'screens', 'settings', 'records', 'controlled_vocabulary.dart'),
  p.join('lib', 'screens', 'settings', 'records', 'custom_fields.dart'),
  p.join('lib', 'screens', 'settings', 'records', 'site_settings.dart'),
  p.join('lib', 'screens', 'settings', 'records', 'specimen_settings.dart'),
  p.join('lib', 'screens', 'settings', 'settings.dart'),
  p.join('lib', 'screens', 'settings', 'settings_destination.dart'),
  p.join('lib', 'screens', 'settings', 'transfer', 'app_settings_import.dart'),
  p.join(
    'lib',
    'screens',
    'settings',
    'transfer',
    'custom_field_transfer.dart',
  ),
  p.join(
    'lib',
    'screens',
    'settings',
    'transfer',
    'user_config_transfer_widgets.dart',
  ),
  p.join('lib', 'screens', 'shared', 'docs', 'documentation_widgets.dart'),
];

/// Text that stays the same in every language.
const _untranslatable = {
  'NAHPU',
  'pt',
  // Export header formats, shown as the literal header syntax.
  'table::fieldName',
  'fieldName',
  'Darwin Core (dwc:/dcterms:)',
};

final _literal = RegExp(
  r'''(?:Text\(\s*|(?:title|label|tooltip|hintText|labelText|helperText): )'''
  r'''['"]([^'"]+)['"]''',
);

/// Interpolated code, such as `${l10n.title}` or `$count`, is not UI text.
final _interpolation = RegExp(r'\$\{[^}]*\}|\$\w+');
final _word = RegExp('[A-Za-z]{2,}');

void main() {
  test('localized screens have no hard-coded UI text', () {
    for (final path in _localizedFiles) {
      final source = File(path).readAsStringSync();
      final literals = _literal
          .allMatches(source)
          .map((match) => match[1]!)
          .where(
            (text) => !_untranslatable.contains(
              text.replaceAll(_interpolation, '').trim(),
            ),
          )
          .where((text) => text.replaceAll(_interpolation, '').contains(_word))
          .toList();
      expect(literals, isEmpty, reason: path);
    }
  });
}
