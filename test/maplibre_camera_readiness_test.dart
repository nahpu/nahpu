import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/maps/maplibre_camera_readiness.dart';

void main() {
  test('becomes ready regardless of callback order', () {
    final mapFirst = MapLibreCameraReadiness()
      ..markMapCreated()
      ..markStyleLoaded();
    final styleFirst = MapLibreCameraReadiness()
      ..markStyleLoaded()
      ..markMapCreated();

    expect(mapFirst.isReady, isTrue);
    expect(styleFirst.isReady, isTrue);
    expect(mapFirst.claimInitialCamera(), isTrue);
    expect(styleFirst.claimInitialCamera(), isTrue);
    expect(mapFirst.claimInitialCamera(), isFalse);
    expect(styleFirst.claimInitialCamera(), isFalse);
  });

  test('keeps reset requests made before readiness', () {
    final readiness = MapLibreCameraReadiness()..markMapCreated();

    expect(readiness.requestReset(), isFalse);
    readiness.markStyleLoaded();
    expect(readiness.claimInitialCamera(), isTrue);
    expect(readiness.takePendingReset(), isTrue);
    expect(readiness.takePendingReset(), isFalse);
  });

  test('reset starts a fresh initial-camera cycle', () {
    final readiness = MapLibreCameraReadiness()
      ..markMapCreated()
      ..markStyleLoaded();

    expect(readiness.claimInitialCamera(), isTrue);
    readiness.reset();
    readiness
      ..markStyleLoaded()
      ..markMapCreated();

    expect(readiness.claimInitialCamera(), isTrue);
  });

  test('style replacement waits for both callbacks before initializing', () {
    final readiness = MapLibreCameraReadiness()
      ..markMapCreated()
      ..markStyleLoaded();
    expect(readiness.claimInitialCamera(), isTrue);

    readiness.reset();
    readiness.markStyleLoaded();

    expect(readiness.isReady, isFalse);
    expect(readiness.claimInitialCamera(), isFalse);

    readiness.markMapCreated();

    expect(readiness.isReady, isTrue);
    expect(readiness.claimInitialCamera(), isTrue);
  });
}
