import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/docs/documentation_widgets.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Optional screenshots support visual review without requiring golden files
  // or writing artifacts during normal test runs.
  const previewDirectory = String.fromEnvironment('NAHPU_DOCS_PREVIEW_DIR');
  final repository = DocumentationRepository();
  setUpAll(() async {
    // Use readable bundled fonts for content QA instead of the test Ahem font.
    for (final family in ['Roboto', 'monospace']) {
      final loader = FontLoader(family);
      loader.addFont(
        Future.value(
          ByteData.sublistView(
            File(p.join('assets', 'fonts', 'DejaVuSans.ttf')).readAsBytesSync(),
          ),
        ),
      );
      await loader.load();
    }
  });

  for (final language in DocsLanguage.values) {
    for (final size in [const Size(390, 844), const Size(1200, 900)]) {
      testWidgets('${language.code} content renders at ${size.width}', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        final paths = [
          for (final topic in [
            'project-overview',
            'event-weather',
            'taxon-registry',
          ])
            p.join('assets', 'docs', 'info', language.code, '$topic.md'),
          p.join('assets', 'docs', 'cookbook', language.code, 'day-one.mdoc'),
          p.join(
            'assets',
            'docs',
            'cookbook',
            language.code,
            'prepare',
            'configure-custom-fields.mdoc',
          ),
          p.join(
            'assets',
            'docs',
            'cookbook',
            language.code,
            'protect-and-collaborate',
            'import-project.mdoc',
          ),
        ];
        for (final path in paths) {
          final document = repository.parseDocument(
            assetPath: path,
            source: File(path).readAsStringSync(),
          );
          final boundaryKey = GlobalKey();
          final scrollController = ScrollController();
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: Scaffold(
                  body: RepaintBoundary(
                    key: boundaryKey,
                    child: Material(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(NahpuSpacing.md),
                        child: MarkdownDocumentView(document: document),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: path);
          expect(find.text(document.title), findsOneWidget);

          if (previewDirectory.isNotEmpty) {
            final boundary =
                boundaryKey.currentContext!.findRenderObject()
                    as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final image = await boundary.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              image.dispose();
              final output = Directory(previewDirectory);
              await output.create(recursive: true);
              await File(
                p.join(
                  output.path,
                  '${language.code}-${document.id}-${size.width.toInt()}.png',
                ),
              ).writeAsBytes(bytes!.buffer.asUint8List());
            });
          }

          scrollController.jumpTo(scrollController.position.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$path at end');
          expect(scrollController.position.extentAfter, 0);
          await tester.pumpWidget(const SizedBox.shrink());
          scrollController.dispose();
        }
      });
    }
  }
}
