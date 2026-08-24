import 'dart:math' as math;

import 'package:nahpu/screens/templates/template_model.dart';

/// Resolves render-only offsets for elements that follow dynamic template text.
///
/// Dynamic text keeps its saved origin while its rendered content may grow.
/// Elements with a greater saved Y coordinate move below every earlier dynamic
/// text's rendered bottom plus a small clearance. This lets the editor show the
/// same vertical flow that document export applies without mutating template
/// data.
class TemplateDynamicLayoutService {
  const TemplateDynamicLayoutService._();

  /// Minimum vertical clearance between dynamic content and lower elements.
  static const double verticalGapMm = 2.0;

  /// Saved Y positions within this distance form the same visual row.
  static const double verticalRowToleranceMm = 1.0;

  /// Returns the vertical render offset for an element at [targetYmm].
  ///
  /// [contentHeightMmByTextId] contains the actual rendered heights of dynamic
  /// text elements. Text not present in the map contributes no flow until it
  /// has been laid out. [excludeTextId] prevents an element from shifting
  /// itself.
  static double verticalShiftMm({
    required Iterable<CustomTextElement> texts,
    required double targetYmm,
    required Map<String, double> contentHeightMmByTextId,
    String? excludeTextId,
  }) {
    final flow = _flowedDynamicTexts(
      texts: texts,
      contentHeightMmByTextId: contentHeightMmByTextId,
      excludeTextId: excludeTextId,
    );
    var renderedY = targetYmm;
    for (final item in flow) {
      if (targetYmm - item.text.yMm <= verticalRowToleranceMm) {
        continue;
      }
      renderedY = math.max(renderedY, item.clearanceBottomMm);
    }
    return renderedY - targetYmm;
  }

  /// Converts a render-time Y coordinate back to the persisted template Y.
  ///
  /// Dynamic flow is a monotonic step function. A binary search maps positions
  /// inside a flowed gap back to its leading saved coordinate for drag and
  /// resize callbacks.
  static double savedYmmForRenderedY({
    required Iterable<CustomTextElement> texts,
    required double renderedYmm,
    required Map<String, double> contentHeightMmByTextId,
    String? excludeTextId,
  }) {
    var low = 0.0;
    var high = math.max(0.0, renderedYmm);
    for (var i = 0; i < 48; i++) {
      final middle = (low + high) / 2;
      final flowedY =
          middle +
          verticalShiftMm(
            texts: texts,
            targetYmm: middle,
            excludeTextId: excludeTextId,
            contentHeightMmByTextId: contentHeightMmByTextId,
          );
      if (flowedY >= renderedYmm) {
        high = middle;
      } else {
        low = middle;
      }
    }
    return high;
  }

  /// Whether [text] participates in dynamic vertical flow.
  static bool isFlowingDynamicText(CustomTextElement text) => _canFlow(text);

  static List<_FlowedDynamicText> _flowedDynamicTexts({
    required Iterable<CustomTextElement> texts,
    required Map<String, double> contentHeightMmByTextId,
    String? excludeTextId,
  }) {
    final sortedTexts =
        texts
            .where((text) => _canFlow(text) && text.id != excludeTextId)
            .toList()
          ..sort((a, b) => a.yMm.compareTo(b.yMm));
    final flowed = <_FlowedDynamicText>[];

    for (final text in sortedTexts) {
      final contentHeight = contentHeightMmByTextId[text.id];
      if (contentHeight == null ||
          !contentHeight.isFinite ||
          contentHeight < 0) {
        continue;
      }

      var renderedTop = text.yMm;
      for (final previous in flowed) {
        if (text.yMm - previous.text.yMm > verticalRowToleranceMm) {
          renderedTop = math.max(renderedTop, previous.clearanceBottomMm);
        }
      }
      flowed.add(
        _FlowedDynamicText(
          text: text,
          clearanceBottomMm: renderedTop + contentHeight + verticalGapMm,
        ),
      );
    }
    return flowed;
  }

  static bool _canFlow(CustomTextElement text) {
    return text.isVisible &&
        text.isDynamic &&
        !text.isQrCode &&
        !isTemplatePictureTextType(text.textType) &&
        templateSpecimenSexIconFieldKeyFromBracketText(text.text) == null;
  }
}

class _FlowedDynamicText {
  const _FlowedDynamicText({
    required this.text,
    required this.clearanceBottomMm,
  });

  final CustomTextElement text;
  final double clearanceBottomMm;
}
