import 'dart:math' as math;

import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/template_dynamic_layout_service.dart';

const double _kPdfPointsPerMm = 72.0 / 25.4;

/// Extra logical-pixel padding needed around the canvas hit-test surface.
class TemplateCanvasOverflowPadding {
  const TemplateCanvasOverflowPadding({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
}

/// Calculates hit-test padding so oversized or rotated elements remain editable.
///
/// The visible canvas is still drawn at its normal size. This only enlarges the
/// surrounding interaction surface so handles and overflowed element bodies can
/// receive pointer events after a user grows an element past the canvas edge.
TemplateCanvasOverflowPadding calculateTemplateCanvasOverflowPadding({
  required TemplatePage page,
  required double templateWidthMm,
  required double templateHeightMm,
  required double scalePxPerMm,
  double basePaddingPx = 72.0,
  Map<String, double> dynamicTextContentHeightMmById = const {},
}) {
  var left = basePaddingPx;
  var top = basePaddingPx;
  var right = basePaddingPx;
  var bottom = basePaddingPx;

  void includeBounds({
    required double xMm,
    required double yMm,
    required double widthMm,
    required double heightMm,
    required int rotationDegrees,
  }) {
    final bounds = _rotatedBounds(
      xMm: xMm,
      yMm: yMm,
      widthMm: widthMm,
      heightMm: heightMm,
      rotationDegrees: rotationDegrees,
    );
    left = math.max(left, math.max(0.0, -bounds.left * scalePxPerMm));
    top = math.max(top, math.max(0.0, -bounds.top * scalePxPerMm));
    right = math.max(
      right,
      math.max(0.0, (bounds.right - templateWidthMm) * scalePxPerMm),
    );
    bottom = math.max(
      bottom,
      math.max(0.0, (bounds.bottom - templateHeightMm) * scalePxPerMm),
    );
  }

  double renderedYmm(double yMm, {String? excludeTextId}) {
    return yMm +
        TemplateDynamicLayoutService.verticalShiftMm(
          texts: page.customTexts,
          targetYmm: yMm,
          excludeTextId: excludeTextId,
          contentHeightMmByTextId: dynamicTextContentHeightMmById,
        );
  }

  for (final image in page.customImages) {
    includeBounds(
      xMm: image.xMm,
      yMm: renderedYmm(image.yMm),
      widthMm: image.widthMm,
      heightMm: image.heightMm,
      rotationDegrees: image.rotationDegrees,
    );
  }
  for (final line in page.customLines) {
    includeBounds(
      xMm: line.xMm,
      yMm: renderedYmm(line.yMm),
      widthMm: line.lengthMm,
      heightMm: math.max(2.0, line.thicknessPt * 0.3527),
      rotationDegrees: line.rotationDegrees,
    );
  }
  for (final shape in page.customShapes) {
    includeBounds(
      xMm: shape.xMm,
      yMm: renderedYmm(shape.yMm),
      widthMm: shape.widthMm,
      heightMm: shape.heightMm,
      rotationDegrees: shape.rotationDegrees,
    );
  }
  for (final text in page.customTexts) {
    final measuredHeightMm =
        dynamicTextContentHeightMmById[text.id] ?? double.nan;
    final size = _textElementSize(
      text,
      measuredHeightMm: measuredHeightMm,
    );
    includeBounds(
      xMm: text.xMm,
      yMm: renderedYmm(text.yMm, excludeTextId: text.id),
      widthMm: size.widthMm,
      heightMm: size.heightMm,
      rotationDegrees: text.rotationDegrees,
    );
  }

  return TemplateCanvasOverflowPadding(
    left: left + basePaddingPx,
    top: top + basePaddingPx,
    right: right + basePaddingPx,
    bottom: bottom + basePaddingPx,
  );
}

({double widthMm, double heightMm}) _textElementSize(
  CustomTextElement text, {
  required double measuredHeightMm,
}) {
  if (text.isQrCode) {
    return (widthMm: text.qrSizeMm, heightMm: text.qrSizeMm);
  }
  if (text.iconWidthMm != null || text.iconHeightMm != null) {
    return (
      widthMm: text.iconWidthMm ?? kTemplateGenderIconDefaultWidthMm,
      heightMm: text.iconHeightMm ?? kTemplateGenderIconDefaultHeightMm,
    );
  }
  final lineHeightMm = math.max(2.0, text.fontSizePt / _kPdfPointsPerMm);
  final fallbackWidthMm =
      math.max(10.0, text.text.length * lineHeightMm * 0.45);
  return (
    widthMm: text.maxWidthMm ?? fallbackWidthMm,
    heightMm: TemplateDynamicLayoutService.isFlowingDynamicText(text) &&
            measuredHeightMm.isFinite
        ? measuredHeightMm
        : text.heightMm ?? lineHeightMm * 1.4,
  );
}

({double left, double top, double right, double bottom}) _rotatedBounds({
  required double xMm,
  required double yMm,
  required double widthMm,
  required double heightMm,
  required int rotationDegrees,
}) {
  final radians = rotationDegrees * math.pi / 180.0;
  final cosTheta = math.cos(radians).abs();
  final sinTheta = math.sin(radians).abs();
  final boundsWidth = widthMm * cosTheta + heightMm * sinTheta;
  final boundsHeight = widthMm * sinTheta + heightMm * cosTheta;
  final centerX = xMm + widthMm / 2.0;
  final centerY = yMm + heightMm / 2.0;
  return (
    left: centerX - boundsWidth / 2.0,
    top: centerY - boundsHeight / 2.0,
    right: centerX + boundsWidth / 2.0,
    bottom: centerY + boundsHeight / 2.0,
  );
}
