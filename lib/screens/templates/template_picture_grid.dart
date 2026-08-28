import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/template_model.dart';

/// Renders record pictures in the same deterministic row-major grid used by
/// PDF output. Each image is contained within its cell without distortion.
class TemplatePictureGrid extends StatelessWidget {
  const TemplatePictureGrid({
    super.key,
    required this.imagePaths,
    this.showPlaceholder = false,
  });

  final List<String> imagePaths;
  final bool showPlaceholder;

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return showPlaceholder
          ? const Center(
              child: Icon(
                Icons.photo_library_outlined,
                key: Key('picture-placeholder'),
              ),
            )
          : const SizedBox.shrink();
    }
    final dimensions = templatePictureGridDimensions(imagePaths.length);
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / dimensions.columns;
        final cellHeight = constraints.maxHeight / dimensions.rows;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            for (var index = 0; index < imagePaths.length; index++)
              Positioned(
                key: ValueKey('picture-cell-$index'),
                left: (index % dimensions.columns) * cellWidth,
                top: (index ~/ dimensions.columns) * cellHeight,
                width: cellWidth,
                height: cellHeight,
                child: Image.file(
                  File(imagePaths[index]),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
          ],
        );
      },
    );
  }
}
