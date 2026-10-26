import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/localization/app_language.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:path/path.dart' as p;

/// One element on a template side, described for the Elements list.
class TemplateElementEntry {
  const TemplateElementEntry({
    required this.selection,
    required this.type,
    required this.label,
    required this.detail,
    required this.zIndex,
    this.isLocked = false,
    this.isVisible = true,
  });

  /// The editor selection key, such as `custom:1:ct_0`.
  final String selection;
  final TemplateElementType type;
  final String label;
  final String detail;
  final int zIndex;
  final bool isLocked;
  final bool isVisible;
}

/// Describes the elements on a template side so they can be picked from a
/// list rather than tapped on the canvas.
class TemplateElementListService {
  const TemplateElementListService({this.l10n});

  /// Labels in this language; English when null.
  final AppLocalizations? l10n;

  /// Every element on [page], front-most first. Elements on the same layer
  /// keep their text, image, line, shape order.
  List<TemplateElementEntry> entries(TemplatePage page, {required bool page1}) {
    final side = page1 ? '1' : '2';
    final l10n = this.l10n ?? localizationsFor(AppLanguage.english);
    final entries = <TemplateElementEntry>[
      for (final text in page.customTexts)
        TemplateElementEntry(
          selection: 'custom:$side:${text.id}',
          type: TemplateElementType.text,
          label: _textLabel(l10n, text.text),
          detail: text.isQrCode
              ? l10n.templateQrCode
              : l10n.recordsCustomFieldTypeText,
          zIndex: text.zIndex,
          isLocked: text.isLocked,
          isVisible: text.isVisible,
        ),
      for (final image in page.customImages)
        TemplateElementEntry(
          selection: 'image:$side:${image.id}',
          type: TemplateElementType.image,
          label: image.imagePath.trim().isEmpty
              ? l10n.templateElementImage
              : p.basename(image.imagePath),
          detail: l10n.templateElementImageDetail(
            _mm(image.widthMm),
            _mm(image.heightMm),
          ),
          zIndex: image.zIndex,
          isLocked: image.isLocked,
          isVisible: image.isVisible,
        ),
      for (final line in page.customLines)
        TemplateElementEntry(
          selection: 'line:$side:${line.id}',
          type: TemplateElementType.line,
          label: l10n.templateElementLine,
          detail: '${_mm(line.lengthMm)} mm',
          zIndex: line.zIndex,
          isLocked: line.isLocked,
          isVisible: line.isVisible,
        ),
      for (final shape in page.customShapes)
        TemplateElementEntry(
          selection: 'shape:$side:${shape.id}',
          type: TemplateElementType.shape,
          label: _shapeLabel(l10n, shape.shapeType),
          detail: '${_mm(shape.widthMm)} × ${_mm(shape.heightMm)} mm',
          zIndex: shape.zIndex,
          isLocked: shape.isLocked,
          isVisible: shape.isVisible,
        ),
    ];
    final ordered = entries.indexed.toList()
      ..sort((a, b) {
        final byLayer = b.$2.zIndex.compareTo(a.$2.zIndex);
        return byLayer != 0 ? byLayer : a.$1.compareTo(b.$1);
      });
    return [for (final (_, entry) in ordered) entry];
  }

  String _textLabel(AppLocalizations l10n, String text) {
    final firstLine = text.trim().split('\n').first.trim();
    return firstLine.isEmpty ? l10n.templateElementEmptyText : firstLine;
  }

  String _shapeLabel(AppLocalizations l10n, String shapeType) {
    return switch (shapeType) {
      'rect' => l10n.templateRectangle,
      'ellipse' => l10n.templateEllipse,
      'circle' => l10n.templateCircle,
      'triangle' => l10n.templateTriangle,
      'polygon' => l10n.templatePolygon,
      _ => l10n.templateShape,
    };
  }

  String _mm(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}
