import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  final arbDir = Directory(p.join('lib', 'l10n'));
  final placeholder = RegExp(r'\{(\w+)\}');

  Map<String, String> messages(File file) {
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return {
      for (final entry in json.entries)
        if (!entry.key.startsWith('@')) entry.key: entry.value as String,
    };
  }

  Set<String> placeholders(String message) =>
      placeholder.allMatches(message).map((match) => match[1]!).toSet();

  test('every translation has the English keys and placeholders', () {
    final template = messages(File(p.join(arbDir.path, 'app_en.arb')));
    final translations = arbDir
        .listSync()
        .whereType<File>()
        .where((file) => p.extension(file.path) == '.arb')
        .where((file) => p.basename(file.path) != 'app_en.arb');

    expect(translations, isNotEmpty);
    for (final file in translations) {
      final name = p.basename(file.path);
      final translated = messages(file);
      expect(translated.keys.toSet(), template.keys.toSet(), reason: name);
      for (final key in template.keys) {
        expect(
          placeholders(translated[key]!),
          placeholders(template[key]!),
          reason: '$name $key',
        );
      }
    }
  });
}
