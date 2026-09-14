import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Guards the macOS sandbox entitlements the map cannot work without.
///
/// macOS has no native MapLibre plugin. `maplibre_webview` renders MapLibre GL
/// JS inside a web view and drives it over a WebSocket served from a loopback
/// `HttpServer`, so the app has to bind a listening socket. Under the App
/// Sandbox that requires `com.apple.security.network.server`, and loopback is
/// not exempt.
///
/// Nothing reports the failure. The bind throws, the platform view and every
/// child widget collapse to `SizedBox.shrink()`, and the map is simply absent
/// -- no crash, no log, no error state. That shipped once already: the key was
/// in DebugProfile but never added to Release, so the map rendered in
/// development and vanished in TestFlight. These tests fail instead.
///
/// `Info.plist` pairs that entitlement with `NSAllowsLocalNetworking`, which
/// declares the loopback connection. App Review's automated check rejected a
/// build that had the server entitlement without the declaration.
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
final infoPlistPath = p.join('macos', 'Runner', 'Info.plist');

/// Entitlement -> what in the map path stops working without it.
const mapEntitlements = <String, String>{
  'com.apple.security.network.server':
      'maplibre_webview binds a loopback HttpServer to reach its web view',
  'com.apple.security.network.client':
      'the OpenFreeMap style request and the maplibre-gl.js tags the web view '
      'loads',
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
            'The macOS map runs in a web view (maplibre_webview), not a native '
            'plugin. Without these keys in $releaseEntitlementsPath the App '
            'Sandbox blocks it and release builds show an empty map area with '
            'no error:\n${missing.join('\n')}',
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

    test('Info.plist declares the local networking the map server needs', () {
      final file = File(infoPlistPath);
      expect(file.existsSync(), isTrue, reason: '$infoPlistPath is missing');

      final transportSecurity = RegExp(
        r'<key>NSAppTransportSecurity</key>\s*<dict>(.*?)</dict>',
        dotAll: true,
      ).firstMatch(file.readAsStringSync())?.group(1);
      final allowsLocalNetworking =
          transportSecurity != null &&
          RegExp(
            r'<key>NSAllowsLocalNetworking</key>\s*<true\s*/>',
          ).hasMatch(transportSecurity);

      expect(
        allowsLocalNetworking,
        isTrue,
        reason:
            '$infoPlistPath must set NSAppTransportSecurity > '
            'NSAllowsLocalNetworking to true. It declares the loopback '
            'WebSocket that com.apple.security.network.server exists for; App '
            'Review flagged the entitlement as unused without it.',
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
