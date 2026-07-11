import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// [RenderStack] that hit-tests children when [clipBehavior] is [Clip.none],
/// even if [position] lies outside the stack’s layout size (overflow chips).
class RenderTemplateCanvasStack extends RenderStack {
  RenderTemplateCanvasStack({
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

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Stack children paint in list order. This helper walks from last child to
    // first, so pointer input always reaches the visually topmost layer first.
    return defaultHitTestChildren(result, position: position);
  }
}

/// Stack for template chips; use [Clip.none] so overflow stays interactive.
class TemplateCanvasStack extends MultiChildRenderObjectWidget {
  const TemplateCanvasStack({
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
  RenderTemplateCanvasStack createRenderObject(BuildContext context) {
    return RenderTemplateCanvasStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderTemplateCanvasStack renderObject,
  ) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..fit = fit
      ..clipBehavior = clipBehavior;
  }
}

/// A sized box that bypasses the boundary check during hit testing.
class CanvasSizedBox extends SingleChildRenderObjectWidget {
  const CanvasSizedBox({
    super.key,
    required this.width,
    required this.height,
    super.child,
  });

  final double width;
  final double height;

  @override
  RenderCanvasSizedBox createRenderObject(BuildContext context) {
    return RenderCanvasSizedBox(width: width, height: height);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderCanvasSizedBox renderObject,
  ) {
    renderObject
      ..width = width
      ..height = height;
  }
}

class RenderCanvasSizedBox extends RenderProxyBox {
  RenderCanvasSizedBox({
    required double width,
    required double height,
  })  : _width = width,
        _height = height;

  double _width;
  double get width => _width;
  set width(double value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  double _height;
  double get height => _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final targetSize = constraints.constrain(Size(width, height));
    if (child != null) {
      child!.layout(BoxConstraints.tight(targetSize), parentUsesSize: true);
      size = child!.size;
    } else {
      size = targetSize;
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      if (child!.hitTest(result, position: position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }
}
