import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/template_specimen_sex_icon.dart';
import 'package:nahpu/screens/templates/template_editor_math.dart';
import 'package:nahpu/screens/templates/template_outline.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/screens/templates/template_fonts.dart';
import 'package:nahpu/screens/templates/template_markdown.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/nested_list_service.dart';

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

/// Read-only scaled preview of one or both template pages (for print preview dialog).
class TemplateLivePreview extends StatelessWidget {
  const TemplateLivePreview({
    super.key,
    required this.viewportSize,
    required this.showHeading,
    required this.template,
    required this.isDuplex,
    required this.mirrorFront,
    required this.mirrorBack,
    required this.templateWidthMm,
    required this.templateHeightMm,
    this.placeholderValues = const {},
  });

  final Size viewportSize;
  final bool showHeading;
  final Template template;
  final bool isDuplex;
  final bool mirrorFront;
  final bool mirrorBack;
  final double templateWidthMm;
  final double templateHeightMm;

  /// When non-empty, `[field]` text is replaced (e.g. first specimen for editor preview).
  final Map<String, String> placeholderValues;

  @override
  Widget build(BuildContext context) {
    final pages = isDuplex
        ? <(bool, TemplatePage, bool)>[
            (true, template.page1, mirrorFront),
            (false, template.page2, mirrorBack),
          ]
        : <(bool, TemplatePage, bool)>[
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
                templateWidthMm: templateWidthMm,
                templateHeightMm: templateHeightMm,
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
    required this.templateWidthMm,
    required this.templateHeightMm,
    required this.maxWidth,
    required this.placeholderValues,
  });

  final TemplatePage page;
  final bool mirror;
  final TemplateOutline? outline;
  final double templateWidthMm;
  final double templateHeightMm;
  final double maxWidth;
  final Map<String, String> placeholderValues;

  @override
  Widget build(BuildContext context) {
    final scale = (maxWidth / templateWidthMm).clamp(0.25, 12.0);
    final w = templateWidthMm * scale;
    final h = templateHeightMm * scale;
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
              decoration: templateAreaStackDecoration(),
              child: const SizedBox.expand(),
            ),
            if (outlinePaint != null)
              CustomPaint(
                painter: TemplateOutlineOverlayPainter(
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
                  angle: degreesToRadians(im.rotationDegrees),
                  child: isTemplateImagePathUsable(im.imagePath)
                      ? Image.file(
                          File(im.imagePath),
                          fit: BoxFit.fill,
                          errorBuilder: (_, _, _) =>
                              const ColoredBox(color: Color(0xFFEEEEEE)),
                        )
                      : const ColoredBox(color: Color(0xFFEEEEEE)),
                ),
              ),
            for (final ct in page.customTexts)
              if (templateSpecimenSexIconFieldKeyFromBracketText(ct.text)
                  case final gKey?)
                Positioned(
                  left: ct.xMm * scale,
                  top: ct.yMm * scale,
                  width: math.max(
                    1.0,
                    (ct.iconWidthMm ?? kTemplateSpecimenSexIconDefaultWidthMm) *
                        scale,
                  ),
                  height: math.max(
                    1.0,
                    (ct.iconHeightMm ??
                            kTemplateSpecimenSexIconDefaultHeightMm) *
                        scale,
                  ),
                  child: Transform.rotate(
                    angle: degreesToRadians(ct.rotationDegrees),
                    child: IconTheme(
                      data: IconThemeData(
                        size: math.min(
                              (ct.iconWidthMm ??
                                      kTemplateSpecimenSexIconDefaultWidthMm) *
                                  scale,
                              (ct.iconHeightMm ??
                                      kTemplateSpecimenSexIconDefaultHeightMm) *
                                  scale,
                            ) *
                            0.88,
                        color: Colors.black,
                      ),
                      child: Icon(
                        templateSpecimenSexIconForFieldKey(
                            placeholderValues, gKey),
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  left: ct.xMm * scale,
                  top: ct.yMm * scale,
                  child: Transform.rotate(
                    angle: degreesToRadians(ct.rotationDegrees),
                    child: Builder(
                      builder: (context) {
                        final textFormatter = ct.isQrCode
                            ? formatTemplateText
                            : formatExportTemplateText;
                        final formattedText = ct.text.isEmpty
                            ? ' '
                            : textFormatter(
                                resolveDocumentTemplatePlaceholders(
                                  text: ct.text,
                                  data: placeholderValues,
                                  textType: ct.textType,
                                  formatOption: ct.formatOption,
                                  caseFormat: ct.caseFormat,
                                  nullFallbackOption: ct.nullFallbackOption,
                                  customNullFallbackText:
                                      ct.customNullFallbackText,
                                ),
                                ct.textType,
                                ct.formatOption,
                                ct.caseFormat,
                              );
                        final hasNewlines = formattedText.contains('\n');
                        return SizedBox(
                          width: ct.maxWidthMm != null
                              ? ct.maxWidthMm! * scale
                              : null,
                          height: (!ct.isDynamic && ct.heightMm != null)
                              ? ct.heightMm! * scale
                              : null,
                          child: Builder(builder: (context) {
                            final textStyle = customTemplateCanvasTextStyle(
                              fontFamilyRaw: ct.fontFamily,
                              fontSize:
                                  _previewFontSizePx(ct.fontSizePt, scale),
                              fontWeight:
                                  ct.bold ? FontWeight.bold : FontWeight.normal,
                              fontStyle: ct.italic
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              underline: ct.underline,
                              strikethrough: ct.strikethrough,
                            ).copyWith(color: Colors.black);
                            final textAlign = _parseTextAlign(ct.textAlign);
                            if (isTemplateRichTextType(ct.textType)) {
                              return TemplateMarkdownBody(
                                data: formattedText,
                                textStyle: textStyle,
                                textAlign: textAlign,
                                clipOverflow: !ct.isDynamic,
                              );
                            }
                            return Text(
                              formattedText,
                              style: textStyle,
                              softWrap: ct.maxWidthMm != null || hasNewlines,
                              maxLines: (ct.maxWidthMm != null || hasNewlines)
                                  ? null
                                  : 1,
                              overflow: (ct.maxWidthMm != null || hasNewlines)
                                  ? TextOverflow.clip
                                  : TextOverflow.visible,
                              textAlign: textAlign,
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
