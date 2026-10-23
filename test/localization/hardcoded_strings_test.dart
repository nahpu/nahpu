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
  p.join(
    'lib',
    'screens',
    'settings',
    'application',
    'application_settings.dart',
  ),
  p.join('lib', 'screens', 'shared', 'docs', 'documentation_widgets.dart'),
];

/// Text that stays the same in every language.
const _untranslatable = {'NAHPU'};

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
          .where((text) => !_untranslatable.contains(text))
          .where((text) => text.replaceAll(_interpolation, '').contains(_word))
          .toList();
      expect(literals, isEmpty, reason: path);
    }
  });
}
