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
  p.join('lib', 'screens', 'exports', 'components', 'file_settings.dart'),
  p.join('lib', 'screens', 'shared', 'actions', 'adaptive_menu.dart'),
  p.join('lib', 'screens', 'shared', 'actions', 'buttons.dart'),
  p.join('lib', 'screens', 'shared', 'actions', 'export_action_bar.dart'),
  p.join('lib', 'screens', 'shared', 'actions', 'export_progress_panel.dart'),
  p.join('lib', 'screens', 'shared', 'actions', 'export_share_button.dart'),
  p.join('lib', 'screens', 'shared', 'actions', 'preset_actions.dart'),
  p.join('lib', 'screens', 'shared', 'actions', 'record_exchange_actions.dart'),
  p.join('lib', 'screens', 'shared', 'common', 'common.dart'),
  p.join('lib', 'screens', 'shared', 'dialogs', 'adaptive_sheet_dialog.dart'),
  p.join('lib', 'screens', 'shared', 'dialogs', 'load_defaults_dialog.dart'),
  p.join('lib', 'screens', 'shared', 'dialogs', 'preset_export_dialog.dart'),
  p.join(
    'lib',
    'screens',
    'shared',
    'dialogs',
    'project_exchange_dialogs.dart',
  ),
  p.join('lib', 'screens', 'shared', 'dialogs', 'qr_code_dialog.dart'),
  p.join('lib', 'screens', 'shared', 'dialogs', 'record_exchange_dialogs.dart'),
  p.join('lib', 'screens', 'shared', 'dialogs', 'record_sort_dialog.dart'),
  p.join('lib', 'screens', 'shared', 'document', 'column_picker.dart'),
  p.join('lib', 'screens', 'shared', 'document', 'document_page_preview.dart'),
  p.join('lib', 'screens', 'shared', 'document', 'document_preview_pane.dart'),
  p.join('lib', 'screens', 'shared', 'document', 'document_settings_pane.dart'),
  p.join('lib', 'screens', 'shared', 'document', 'record_selection.dart'),
  p.join(
    'lib',
    'screens',
    'shared',
    'document',
    'specimen_part_filter_dialog.dart',
  ),
  p.join(
    'lib',
    'screens',
    'shared',
    'document',
    'specimen_part_selection.dart',
  ),
  p.join('lib', 'screens', 'shared', 'document', 'specimen_selection.dart'),
  p.join('lib', 'screens', 'shared', 'file', 'db_backup_summary_panel.dart'),
  p.join('lib', 'screens', 'shared', 'file', 'file_operation.dart'),
  p.join('lib', 'screens', 'shared', 'file', 'file_settings.dart'),
  p.join('lib', 'screens', 'shared', 'fonts', 'font_preview.dart'),
  p.join('lib', 'screens', 'shared', 'forms', 'bundled_preset_checklist.dart'),
  p.join(
    'lib',
    'screens',
    'shared',
    'forms',
    'custom_field_definition_editor.dart',
  ),
  p.join('lib', 'screens', 'shared', 'forms', 'description_field.dart'),
  p.join('lib', 'screens', 'shared', 'forms', 'features.dart'),
  p.join('lib', 'screens', 'shared', 'forms', 'custom_fields.dart'),
  p.join('lib', 'screens', 'shared', 'forms', 'fields.dart'),
  p.join('lib', 'screens', 'shared', 'forms', 'forms.dart'),
  p.join('lib', 'screens', 'shared', 'forms', 'numbered_id_fields.dart'),
  p.join('lib', 'screens', 'shared', 'forms', 'pickers.dart'),
  p.join('lib', 'screens', 'shared', 'forms', 'preset_identity_fields.dart'),
  p.join('lib', 'screens', 'shared', 'forms', 'preset_name_dialog.dart'),
  p.join('lib', 'screens', 'shared', 'forms', 'site_name_display.dart'),
  p.join('lib', 'screens', 'shared', 'inline_grouped_field_picker.dart'),
  p.join('lib', 'screens', 'shared', 'layout', 'navigation.dart'),
  p.join('lib', 'screens', 'shared', 'layout', 'wizard.dart'),
  p.join('lib', 'screens', 'shared', 'text_replacement_rules_editor.dart'),
];

/// Text that stays the same in every language.
const _untranslatable = {
  'NAHPU',
  'pt',
  // Example file name in the file-name hint.
  'my_file',
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
