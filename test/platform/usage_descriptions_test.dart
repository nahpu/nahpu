import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Guards the permission prompts shown to users and App Review.
///
/// App Review rejects vague purpose strings under Guideline 5.1.1, and the
/// Xcode template wording ("$(PRODUCT_NAME) would like to use your camera")
/// is exactly that. Each string must name NAHPU and say what the permission
/// is used for.
final infoPlistPaths = [
  p.join('ios', 'Runner', 'Info.plist'),
  p.join('macos', 'Runner', 'Info.plist'),
];

void main() {
  group('Info.plist usage descriptions are specific', () {
    for (final path in infoPlistPaths) {
      test(path, () {
        final descriptions = usageDescriptions(path);
        expect(descriptions, isNotEmpty, reason: '$path declares none');

        final vague = descriptions.entries
            .where(
              (entry) =>
                  !entry.value.startsWith('NAHPU ') ||
                  entry.value.contains(r'$(PRODUCT_NAME)') ||
                  entry.value.contains('would like'),
            )
            .map((entry) => '${entry.key}: ${entry.value}')
            .toList();

        expect(
          vague,
          isEmpty,
          reason:
              'Usage descriptions in $path must start with "NAHPU" and state '
              'the purpose of the permission:\n${vague.join('\n')}',
        );
      });
    }
  });
}

/// Every `NS*UsageDescription` key and its string value, read as source.
Map<String, String> usageDescriptions(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: '$path is missing');

  final pattern = RegExp(
    r'<key>(NS\w+UsageDescription)</key>\s*<string>([^<]*)</string>',
  );

  return {
    for (final match in pattern.allMatches(file.readAsStringSync()))
      match.group(1)!: match.group(2)!.trim(),
  };
}
