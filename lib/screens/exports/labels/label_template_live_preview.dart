import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nahpu/screens/exports/labels/label_gender_icon.dart';
import 'package:nahpu/screens/exports/labels/label_outline.dart';
import 'package:nahpu/services/export/label_writer.dart';
import 'package:nahpu/screens/exports/labels/label_template_fonts.dart';
import 'package:nahpu/screens/exports/labels/label_template_model.dart';

double _previewFontSizePx(double fontSizePt, double mmToPx) =>
    fontSizePt * mmToPx * 25.4 / 72.0;

TextAlign _parseTextAlign(String align) {
  switch (align) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    case 'left':
    default:
      return TextAlign.left;
  }
}

/// Read-only scaled preview of one or both label pages (for print preview dialog).
class LabelTemplateLivePreview extends StatelessWidget {
  const LabelTemplateLivePreview({
    super.key,
    required this.viewportSize,
    required this.showHeading,
    required this.template,
    required this.isDuplex,
    required this.mirrorFront,
    required this.mirrorBack,
    required this.labelWidthMm,
    required this.labelHeightMm,
    this.placeholderValues = const {},
  });

  final Size viewportSize;
  final bool showHeading;
  final LabelTemplate template;
  final bool isDuplex;
  final bool mirrorFront;
  final bool mirrorBack;
  final double labelWidthMm;
  final double labelHeightMm;

  /// When non-empty, `[field]` text is replaced (e.g. first specimen for editor preview).
  final Map<String, String> placeholderValues;

  @override
  Widget build(BuildContext context) {
    final pages = isDuplex
        ? <(bool, LabelPageTemplate, bool)>[
            (true, template.page1, mirrorFront),
            (false, template.page2, mirrorBack),
          ]
        : <(bool, LabelPageTemplate, bool)>[
            (true, template.page1, mirrorFront),
          ];

    const pad = 16.0;
    final maxW = (viewportSize.width - 2 * pad).clamp(80.0, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < pages.length; i++) ...[
            if (showHeading || (isDuplex && pages.length > 1))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  pages[i].$1 ? 'Front' : 'Back',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            Center(
              child: _PreviewPage(
                page: pages[i].$2,
                mirror: pages[i].$3,
                outline: template.outline,
                labelWidthMm: labelWidthMm,
                labelHeightMm: labelHeightMm,
                maxWidth: maxW,
                placeholderValues: placeholderValues,
              ),
            ),
            if (i < pages.length - 1) const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _PreviewPage extends StatelessWidget {
  const _PreviewPage({
    required this.page,
    required this.mirror,
    required this.outline,
    required this.labelWidthMm,
    required this.labelHeightMm,
    required this.maxWidth,
    required this.placeholderValues,
  });

  final LabelPageTemplate page;
  final bool mirror;
  final LabelTemplateOutline? outline;
  final double labelWidthMm;
  final double labelHeightMm;
  final double maxWidth;
  final Map<String, String> placeholderValues;

  @override
  Widget build(BuildContext context) {
    final scale = (maxWidth / labelWidthMm).clamp(0.25, 12.0);
    final w = labelWidthMm * scale;
    final h = labelHeightMm * scale;
    final outlinePaint = outline;

    return Transform.rotate(
      angle: mirror ? math.pi : 0,
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            DecoratedBox(
              decoration: labelAreaStackDecoration(),
              child: const SizedBox.expand(),
            ),
            if (outlinePaint != null)
              CustomPaint(
                painter: LabelOutlineOverlayPainter(
                  outline: outlinePaint,
                  scaleMmToPx: scale,
                ),
                child: const SizedBox.expand(),
              ),
            for (final im in page.customImages)
              Positioned(
                left: im.xMm * scale,
                top: im.yMm * scale,
                width: math.max(1.0, im.widthMm * scale),
                height: math.max(1.0, im.heightMm * scale),
                child: Transform.rotate(
                  angle: im.rotationDegrees * math.pi / 180,
                  child: isLabelImagePathUsable(im.imagePath)
                      ? Image.file(
                          File(im.imagePath),
                          fit: BoxFit.fill,
                          errorBuilder: (_, __, ___) =>
                              const ColoredBox(color: Color(0xFFEEEEEE)),
                        )
                      : const ColoredBox(color: Color(0xFFEEEEEE)),
                ),
              ),
            for (final ct in page.customTexts)
              if (labelGenderIconFieldKeyFromBracketText(ct.text)
                  case final gKey?)
                Positioned(
                  left: ct.xMm * scale,
                  top: ct.yMm * scale,
                  width: math.max(
                    1.0,
                    (ct.iconWidthMm ?? kLabelGenderIconDefaultWidthMm) * scale,
                  ),
                  height: math.max(
                    1.0,
                    (ct.iconHeightMm ?? kLabelGenderIconDefaultHeightMm) *
                        scale,
                  ),
                  child: Transform.rotate(
                    angle: ct.rotationDegrees * math.pi / 180,
                    child: IconTheme(
                      data: IconThemeData(
                        size: math.min(
                              (ct.iconWidthMm ??
                                      kLabelGenderIconDefaultWidthMm) *
                                  scale,
                              (ct.iconHeightMm ??
                                      kLabelGenderIconDefaultHeightMm) *
                                  scale,
                            ) *
                            0.88,
                        color: Colors.black,
                      ),
                      child: Icon(
                        labelGenderIconForFieldKey(placeholderValues, gKey),
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  left: ct.xMm * scale,
                  top: ct.yMm * scale,
                  child: Transform.rotate(
                    angle: ct.rotationDegrees * math.pi / 180,
                    child: SizedBox(
                      width:
                          ct.maxWidthMm != null ? ct.maxWidthMm! * scale : null,
                      child: Text(
                        ct.text.isEmpty
                            ? ' '
                            : formatTextWithCase(
                                placeholderValues.isEmpty
                                    ? ct.text
                                    : substituteLabelPlaceholders(
                                        ct.text,
                                        placeholderValues,
                                      ),
                                ct.caseFormat,
                              ),
                        style: customLabelCanvasTextStyle(
                          fontFamilyRaw: ct.fontFamily,
                          fontSize: _previewFontSizePx(ct.fontSizePt, scale),
                          fontWeight:
                              ct.bold ? FontWeight.bold : FontWeight.normal,
                          fontStyle:
                              ct.italic ? FontStyle.italic : FontStyle.normal,
                        ).copyWith(color: Colors.black),
                        softWrap: ct.maxWidthMm != null,
                        maxLines: ct.maxWidthMm != null ? null : 1,
                        overflow: ct.maxWidthMm != null
                            ? TextOverflow.clip
                            : TextOverflow.visible,
                        textAlign: _parseTextAlign(ct.textAlign),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
