import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// [RenderStack] that hit-tests children when [clipBehavior] is [Clip.none],
/// even if [position] lies outside the stack’s layout size (overflow chips).
class RenderLabelCanvasStack extends RenderStack {
  RenderLabelCanvasStack({
    super.children,
    super.alignment,
    super.textDirection,
    super.fit,
    super.clipBehavior,
  });

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (clipBehavior == Clip.none) {
      if (!hasSize) return false;
      if (hitTestChildren(result, position: position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
      return hitTestSelf(position);
    }
    return super.hitTest(result, position: position);
  }
}

/// Stack for label chips; use [Clip.none] so overflow stays interactive.
class LabelCanvasStack extends MultiChildRenderObjectWidget {
  const LabelCanvasStack({
    super.key,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.none,
    super.children = const <Widget>[],
  });

  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit fit;
  final Clip clipBehavior;

  @override
  RenderLabelCanvasStack createRenderObject(BuildContext context) {
    return RenderLabelCanvasStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderLabelCanvasStack renderObject,
  ) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..fit = fit
      ..clipBehavior = clipBehavior;
  }
}
