import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Guards the macOS sandbox entitlements the map cannot work without.
///
/// The macOS map is drawn by `flutter_map`, which fetches OpenFreeMap styles
/// and vector tiles over the network. Under the App Sandbox that requires
/// `com.apple.security.network.client`. A missing key fails silently: the
/// online basemap never loads and only the bundled Natural Earth map shows.
/// A key present in DebugProfile but not in Release once shipped a map that
/// worked in development and broke in TestFlight. These tests fail instead.
final releaseEntitlementsPath = p.join(
  'macos',
  'Runner',
  'Release.entitlements',
);
final debugProfileEntitlementsPath = p.join(
  'macos',
  'Runner',
  'DebugProfile.entitlements',
);

/// Entitlement -> what in the map path stops working without it.
const mapEntitlements = <String, String>{
  'com.apple.security.network.client':
      'the OpenFreeMap style and vector tile requests',
};

void main() {
  group('macOS entitlements keep the map working in release builds', () {
    test('the release build declares every entitlement the map needs', () {
      final granted = grantedEntitlements(releaseEntitlementsPath);

      final missing = mapEntitlements.entries
          .where((entry) => !granted.contains(entry.key))
          .map((entry) => '${entry.key} -- ${entry.value}')
          .toList();

      expect(
        missing,
        isEmpty,
        reason:
            'Without these keys in $releaseEntitlementsPath the App Sandbox '
            'blocks the online basemap and release builds fall back to the '
            'offline map with no error:\n${missing.join('\n')}',
      );
    });

    test('release does not fall behind debug on network entitlements', () {
      final release = grantedEntitlements(releaseEntitlementsPath);
      final debugProfile = grantedEntitlements(debugProfileEntitlementsPath);

      final onlyInDebug =
          debugProfile
              .where((key) => key.startsWith('com.apple.security.network.'))
              .where((key) => !release.contains(key))
              .toList()
            ..sort();

      expect(
        onlyInDebug,
        isEmpty,
        reason:
            'Debug and Profile sign with $debugProfileEntitlementsPath while '
            'release and TestFlight sign with $releaseEntitlementsPath. A '
            'network entitlement present only in the first is the exact shape '
            'of a bug that works on the developer machine and is invisible in '
            'TestFlight:\n${onlyInDebug.join('\n')}',
      );
    });
  });
}

/// Every entitlement an `.entitlements` plist grants, read as source.
///
/// The file is a fixed, hand-edited plist rather than a build artifact, so a
/// regex over the `<key>`/`<true/>` pairs is enough and keeps the test free of
/// a plist parser dependency. Keys set to `<false/>` are not grants and are
/// left out.
Set<String> grantedEntitlements(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: '$path is missing');

  final pattern = RegExp(r'<key>([^<]+)</key>\s*<(true|false)\s*/>');

  return {
    for (final match in pattern.allMatches(file.readAsStringSync()))
      if (match.group(2) == 'true') match.group(1)!.trim(),
  };
}
