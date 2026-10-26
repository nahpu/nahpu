import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// WCAG 2.2 AA contrast for normal text.
const double wcagTextContrast = 4.5;

/// WCAG 2.2 AA contrast for large text and for icons (non-text contrast).
const double wcagLargeTextContrast = 3;

/// The WCAG contrast ratio between two opaque colors.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (light, dark) = la > lb ? (la, lb) : (lb, la);
  return (light + 0.05) / (dark + 0.05);
}

/// Checks every visible text and icon glyph on screen against the color
/// painted behind it, and describes those below WCAG AA. Large text (24 px,
/// or 18.66 px bold) and icons need 3:1; other text needs 4.5:1.
///
/// Faded text below half opacity is skipped: Material draws disabled
/// controls that way, and WCAG exempts inactive controls.
List<String> textContrastFailures(WidgetTester tester) {
  final failures = <String>[];
  final fallback = Theme.of(
    tester.element(find.byType(Scaffold).first),
  ).scaffoldBackgroundColor;
  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject;
    if (paragraph is! RenderParagraph || !paragraph.hasSize) continue;
    if (paragraph.size.isEmpty) continue;
    final background = _backgroundBehind(paragraph, fallback);
    _visitStyledText(paragraph.text, null, (text, style) {
      final color = style?.color;
      if (color == null || color.a < 0.5) return;
      final shown = Color.alphaBlend(color, background);
      final isIcon = style!.fontFamily == 'MaterialIcons';
      final size = style.fontSize ?? 14;
      final isBold = (style.fontWeight?.value ?? 400) >= 700;
      final isLarge = size >= 24 || (size >= 18.66 && isBold);
      final required = isIcon || isLarge
          ? wcagLargeTextContrast
          : wcagTextContrast;
      final ratio = contrastRatio(shown, background);
      if (ratio + 0.005 < required) {
        final label = isIcon
            ? 'icon U+${text.runes.first.toRadixString(16)}'
            : '"$text"';
        failures.add(
          '$label: ${ratio.toStringAsFixed(2)}:1 < $required:1 '
          '(text $shown on $background)',
        );
      }
    });
  }
  return failures;
}

void _visitStyledText(
  InlineSpan span,
  TextStyle? inherited,
  void Function(String text, TextStyle? style) visit,
) {
  final style = inherited?.merge(span.style) ?? span.style;
  if (span is TextSpan) {
    final text = span.text?.trim() ?? '';
    if (text.isNotEmpty) visit(text, style);
    for (final child in span.children ?? const <InlineSpan>[]) {
      _visitStyledText(child, style, visit);
    }
  }
}

/// The opaque color under [object]: the nearest painted Material or box
/// fill, with translucent fills blended over what lies beneath them.
Color _backgroundBehind(RenderObject object, Color fallback) {
  final fills = <Color>[];
  RenderObject? current = object.parent;
  while (current != null) {
    final fill = switch (current) {
      RenderPhysicalShape() => current.color,
      RenderPhysicalModel() => current.color,
      RenderDecoratedBox(:final decoration) when decoration is BoxDecoration =>
        decoration.color,
      _ => null,
    };
    if (fill != null && fill.a > 0) {
      fills.add(fill);
      if (fill.a >= 1) break;
    }
    current = current.parent;
  }
  var color = fills.isNotEmpty && fills.last.a >= 1
      ? fills.removeLast()
      : fallback;
  for (final fill in fills.reversed) {
    color = Color.alphaBlend(fill, color);
  }
  return color;
}
