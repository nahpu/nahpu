import 'dart:math' as math;

import 'package:nahpu/screens/templates/template_model.dart';

/// Resolves render-only offsets for elements that follow dynamic template text.
///
/// Dynamic text keeps its saved origin while its rendered content may grow past
/// its configured baseline height. Elements with a greater saved Y coordinate
/// receive the accumulated excess height. This lets the editor show the same
/// vertical flow that document export applies without mutating template data.
class TemplateDynamicLayoutService {
  const TemplateDynamicLayoutService._();

  /// Returns the vertical render offset for an element at [targetYmm].
  ///
  /// [contentHeightMmByTextId] contains the actual rendered heights of dynamic
  /// text elements. Text not present in the map contributes no growth until it
  /// has been laid out. [excludeTextId] prevents an element from shifting itself.
  static double verticalShiftMm({
    required Iterable<CustomTextElement> texts,
    required double targetYmm,
    required Map<String, double> contentHeightMmByTextId,
    String? excludeTextId,
  }) {
    var shift = 0.0;
    for (final text in texts) {
      if (!_canFlow(text) ||
          text.id == excludeTextId ||
          targetYmm <= text.yMm) {
        continue;
      }
      final contentHeight = contentHeightMmByTextId[text.id];
      if (contentHeight == null || !contentHeight.isFinite) continue;
      final baselineHeight = text.heightMm ?? 0.0;
      shift += math.max(0.0, contentHeight - baselineHeight);
    }
    return shift;
  }

  /// Converts a render-time Y coordinate back to the persisted template Y.
  ///
  /// Dynamic flow is a monotonic step function, so a short fixed-point loop is
  /// sufficient to invert it for drag and resize callbacks.
  static double savedYmmForRenderedY({
    required Iterable<CustomTextElement> texts,
    required double renderedYmm,
    required Map<String, double> contentHeightMmByTextId,
    String? excludeTextId,
  }) {
    final sortedTexts = texts
        .where((text) => _canFlow(text) && text.id != excludeTextId)
        .toList()
      ..sort((a, b) => a.yMm.compareTo(b.yMm));

    var accumulatedShift = 0.0;
    for (final text in sortedTexts) {
      final contentHeight = contentHeightMmByTextId[text.id];
      if (contentHeight == null || !contentHeight.isFinite) continue;
      final baselineHeight = text.heightMm ?? 0.0;
      final growth = math.max(0.0, contentHeight - baselineHeight);

      final renderedBoundary = text.yMm + accumulatedShift;

      if (renderedYmm <= renderedBoundary) {
        return renderedYmm - accumulatedShift;
      }

      if (renderedYmm <= renderedBoundary + growth) {
        return text.yMm;
      }

      accumulatedShift += growth;
    }

    return renderedYmm - accumulatedShift;
  }

  /// Whether [text] participates in dynamic vertical flow.
  static bool isFlowingDynamicText(CustomTextElement text) => _canFlow(text);

  static bool _canFlow(CustomTextElement text) {
    return text.isVisible &&
        text.isDynamic &&
        !text.isQrCode &&
        templateGenderIconFieldKeyFromBracketText(text.text) == null;
  }
}
