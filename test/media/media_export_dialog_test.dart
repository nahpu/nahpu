import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/media/media_export_dialog.dart';
import 'package:nahpu/services/media/media_export_service.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/src/rust/api/images.dart' as rust_images;
import 'package:path/path.dart' as path;

void main() {
  testWidgets('uses a bottom sheet on compact layouts', (tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpLauncher(tester, _audioSource());
    await tester.tap(find.text('Open export'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Export media'), findsOneWidget);
  });

  testWidgets('uses a constrained dialog on wide layouts', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpLauncher(tester, _audioSource());
    await tester.tap(find.text('Open export'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Export media'), findsOneWidget);
  });

  testWidgets('non-image media offers Original export only', (tester) async {
    await _pumpDialog(tester, _audioSource());

    expect(find.text('Original (.mp3)'), findsOneWidget);
    expect(find.text('Resize image'), findsNothing);
    await tester.tap(find.text('Original (.mp3)'));
    await tester.pumpAndSettle();
    expect(find.text('JPEG (.jpg)'), findsNothing);
    expect(find.text('PNG (.png)'), findsNothing);
    expect(find.text('WebP (.webp)'), findsNothing);
  });

  testWidgets('source path uses an ellipsis and the last two parents', (
    tester,
  ) async {
    final sourcePath = path.join(
      'Users',
      'scientist',
      'NAHPU',
      'project',
      'media',
      'field-image.png',
    );
    await _pumpDialog(
      tester,
      MediaExportSource(
        file: File(sourcePath),
        kind: MediaKind.image,
        originalExtension: 'png',
      ),
    );

    expect(
      find.text(
        '…${path.separator}project${path.separator}media'
        '${path.separator}field-image.png',
      ),
      findsOneWidget,
    );
    expect(find.text(sourcePath), findsNothing);
  });

  testWidgets('image export links dimensions and exposes JPEG quality', (
    tester,
  ) async {
    MediaExportFormat? exportedFormat;
    int? exportedWidth;
    int? exportedHeight;
    int? exportedQuality;
    await _pumpDialog(
      tester,
      _imageSource(),
      onExport:
          ({
            required source,
            required format,
            required fileStem,
            destinationDirectory,
            width,
            height,
            required jpegQuality,
          }) async {
            exportedFormat = format;
            exportedWidth = width;
            exportedHeight = height;
            exportedQuality = jpegQuality;
            return MediaExportResult(
              file: File('/tmp/exported.jpg'),
              bytes: 100,
              width: width,
              height: height,
              resized: width != null,
            );
          },
    );

    await tester.tap(find.text('Original (.png)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('JPEG (.jpg)').last);
    await tester.pumpAndSettle();

    expect(find.text('Resize image'), findsOneWidget);
    expect(find.text('JPEG quality'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    await tester.tap(find.text('Resize image'));
    await tester.pumpAndSettle();

    final widthField = find.widgetWithText(TextField, 'Width (px)');
    final heightField = find.widgetWithText(TextField, 'Height (px)');
    await tester.enterText(widthField, '200');
    await tester.pump();
    expect(tester.widget<TextField>(heightField).controller!.text, '100');

    await tester.enterText(widthField, '1600');
    await tester.pump();
    expect(tester.widget<TextField>(widthField).controller!.text, '800');
    expect(tester.widget<TextField>(heightField).controller!.text, '400');

    await tester.enterText(widthField, '200');
    await tester.ensureVisible(find.text('Export'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(exportedFormat, MediaExportFormat.jpeg);
    expect(exportedWidth, 200);
    expect(exportedHeight, 100);
    expect(exportedQuality, 85);
    expect(find.text('Share'), findsOneWidget);
  });
}

Future<void> _pumpLauncher(
  WidgetTester tester,
  MediaExportSource source,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showMediaExportDialog(
              context: context,
              prepare: () async => source,
              onExport: _fakeExport,
            ),
            child: const Text('Open export'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpDialog(
  WidgetTester tester,
  MediaExportSource source, {
  MediaExportCallback onExport = _fakeExport,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MediaExportDialog(
          prepare: () async => source,
          onExport: onExport,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<MediaExportResult> _fakeExport({
  required MediaExportSource source,
  required MediaExportFormat format,
  required String fileStem,
  Directory? destinationDirectory,
  int? width,
  int? height,
  required int jpegQuality,
}) async {
  return MediaExportResult(
    file: File('/tmp/exported.${format.extension(source.originalExtension)}'),
    bytes: 10,
    width: width,
    height: height,
    resized: width != null,
  );
}

MediaExportSource _audioSource() => MediaExportSource(
  file: File('/tmp/field-audio.mp3'),
  kind: MediaKind.audio,
  originalExtension: 'mp3',
);

MediaExportSource _imageSource() => MediaExportSource(
  file: File('/tmp/field-image.png'),
  kind: MediaKind.image,
  originalExtension: 'png',
  imageInfo: const rust_images.ImageSourceInfo(
    format: rust_images.ImageExportFormat.png,
    width: 800,
    height: 400,
  ),
);
