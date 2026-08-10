import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/media/media.dart';
import 'package:nahpu/services/platform_services.dart';

void main() {
  test('media add sources are limited by operating-system type', () {
    expect(mediaAddSourcesForPlatform(PlatformType.mobile), [
      MediaAddSource.takeMedia,
      MediaAddSource.recordAudio,
      MediaAddSource.gallery,
      MediaAddSource.file,
    ]);
    expect(mediaAddSourcesForPlatform(PlatformType.desktop), [
      MediaAddSource.recordAudio,
      MediaAddSource.file,
    ]);
    expect(mediaAddSourcesForPlatform(PlatformType.unknown), [
      MediaAddSource.recordAudio,
      MediaAddSource.file,
    ]);
  });

  testWidgets('mobile Add menu shows all sources in the requested order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var takeCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaButton(
            platformOverride: PlatformType.mobile,
            onTakeMedia: () async {
              takeCount++;
            },
            onRecordAudio: () async {},
            onAddFromGallery: () async {},
            onAddFromFiles: () async {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(_sourceLabels(tester), [
      'Take photos/videos',
      'Record audio',
      'Add from gallery',
      'Add from file',
    ]);

    await tester.tap(find.text('Take photos/videos'));
    await tester.pumpAndSettle();
    expect(takeCount, 1);
  });

  testWidgets('desktop Add menu contains recorder and file import only', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaButton(
            platformOverride: PlatformType.desktop,
            onTakeMedia: () async {},
            onRecordAudio: () async {},
            onAddFromGallery: () async {},
            onAddFromFiles: () async {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add media'), findsOneWidget);
    expect(_sourceLabels(tester), ['Record audio', 'Add from file']);
    expect(find.text('Take photos/videos'), findsNothing);
    expect(find.text('Add from gallery'), findsNothing);
  });

  testWidgets('Gallery and primary Add share the Media title row', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MediaViewer(
              images: const [],
              onAddFromGallery: () async {},
              onAddFromFiles: () async {},
              onTakeMedia: () async {},
              onRecordAudio: () async {},
              onOpenGallery: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);
    final galleryPosition = tester.getTopLeft(find.text('Gallery'));
    final addPosition = tester.getTopLeft(find.text('Add'));
    expect((galleryPosition.dy - addPosition.dy).abs(), lessThan(4));
    expect(galleryPosition.dx, lessThan(addPosition.dx));
  });
}

List<String> _sourceLabels(WidgetTester tester) {
  return tester
      .widgetList<ListTile>(find.byType(ListTile))
      .map((tile) => (tile.title as Text).data!)
      .toList(growable: false);
}
