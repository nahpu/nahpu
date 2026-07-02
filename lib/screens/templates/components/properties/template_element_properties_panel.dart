import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/components/properties/image_properties_panel.dart';
import 'package:nahpu/screens/templates/components/properties/line_properties_panel.dart';
import 'package:nahpu/screens/templates/components/properties/shape_properties_panel.dart';
import 'package:nahpu/screens/templates/components/properties/text_properties_panel.dart';
import 'package:nahpu/screens/templates/template_model.dart';

class TemplateElementPropertiesPanel extends StatelessWidget {
  const TemplateElementPropertiesPanel({
    super.key,
    required this.selectedElement,
    required this.page1,
    required this.template,
    required this.onUpdateCustomText,
    required this.onDeleteCustomText,
    required this.onUpdateCustomImage,
    required this.onDeleteCustomImage,
    required this.onUpdateCustomLine,
    required this.onDeleteCustomLine,
    required this.onUpdateCustomShape,
    required this.onDeleteCustomShape,
    this.onDismiss,
  });

  final String selectedElement;
  final bool page1;
  final Template template;
  final VoidCallback? onDismiss;
  final void Function(bool page1, CustomTextElement element) onUpdateCustomText;
  final void Function(bool page1, String id) onDeleteCustomText;
  final void Function(bool page1, CustomImageElement element)
      onUpdateCustomImage;
  final void Function(bool page1, String id) onDeleteCustomImage;
  final void Function(bool page1, CustomLineElement element) onUpdateCustomLine;
  final void Function(bool page1, String id) onDeleteCustomLine;
  final void Function(bool page1, CustomShapeElement element)
      onUpdateCustomShape;
  final void Function(bool page1, String id) onDeleteCustomShape;

  @override
  Widget build(BuildContext context) {
    final selection = _TemplateSelection.parse(selectedElement);
    if (selection == null) return const SizedBox.shrink();

    switch (selection.type) {
      case _TemplateElementType.text:
        return TextPropertiesPanel(
          selectedElement: selectedElement,
          page1: page1,
          template: template,
          onUpdateCustomText: onUpdateCustomText,
          onDeleteCustomText: onDeleteCustomText,
          onUpdateCustomImage: onUpdateCustomImage,
          onDeleteCustomImage: onDeleteCustomImage,
          onUpdateCustomLine: onUpdateCustomLine,
          onDeleteCustomLine: onDeleteCustomLine,
          onUpdateCustomShape: onUpdateCustomShape,
          onDeleteCustomShape: onDeleteCustomShape,
          onDismiss: onDismiss,
        );
      case _TemplateElementType.image:
        return ImagePropertiesPanel(
          page1: selection.page1,
          id: selection.id,
          zIndexControls: _buildZIndexControls(context, selectedElement),
          onDelete: onDeleteCustomImage,
          inToolbar: true,
          onDismiss: onDismiss,
        );
      case _TemplateElementType.line:
        final line = _findCustomLine(selection.page1, selection.id);
        if (line == null) return const SizedBox.shrink();
        return LinePropertiesPanel(
          page1: selection.page1,
          id: selection.id,
          line: line,
          zIndexControls: _buildZIndexControls(context, selectedElement),
          onUpdate: onUpdateCustomLine,
          onDelete: onDeleteCustomLine,
          inToolbar: true,
          onDismiss: onDismiss,
        );
      case _TemplateElementType.shape:
        final shape = _findCustomShape(selection.page1, selection.id);
        if (shape == null) return const SizedBox.shrink();
        return ShapePropertiesPanel(
          page1: selection.page1,
          id: selection.id,
          shape: shape,
          zIndexControls: _buildZIndexControls(context, selectedElement),
          onUpdate: onUpdateCustomShape,
          onDelete: onDeleteCustomShape,
          inToolbar: true,
          onDismiss: onDismiss,
        );
    }
  }

  Widget _buildZIndexControls(BuildContext context, String selectedElement) {
    void setZIndex(String selectedElement, int delta) {
      final selection = _TemplateSelection.parse(selectedElement);
      if (selection == null) return;

      switch (selection.type) {
        case _TemplateElementType.text:
          final element = _findCustomText(selection.page1, selection.id);
          if (element != null) {
            onUpdateCustomText(
              selection.page1,
              element.copyWith(zIndex: element.zIndex + delta),
            );
          }
        case _TemplateElementType.image:
          final element = _findCustomImage(selection.page1, selection.id);
          if (element != null) {
            onUpdateCustomImage(
              selection.page1,
              element.copyWith(zIndex: element.zIndex + delta),
            );
          }
        case _TemplateElementType.line:
          final element = _findCustomLine(selection.page1, selection.id);
          if (element != null) {
            onUpdateCustomLine(
              selection.page1,
              element.copyWith(zIndex: element.zIndex + delta),
            );
          }
        case _TemplateElementType.shape:
          final element = _findCustomShape(selection.page1, selection.id);
          if (element != null) {
            onUpdateCustomShape(
              selection.page1,
              element.copyWith(zIndex: element.zIndex + delta),
            );
          }
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_down, size: 20),
          tooltip: 'Send to back',
          onPressed: () => setZIndex(selectedElement, -1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          tooltip: 'Send backward',
          onPressed: () => setZIndex(selectedElement, -1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, size: 20),
          tooltip: 'Bring forward',
          onPressed: () => setZIndex(selectedElement, 1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_up, size: 20),
          tooltip: 'Bring to front',
          onPressed: () => setZIndex(selectedElement, 1),
        ),
      ],
    );
  }

  CustomTextElement? _findCustomText(bool page1, String id) {
    final page = page1 ? template.page1 : template.page2;
    for (final element in page.customTexts) {
      if (element.id == id) return element;
    }
    return null;
  }

  CustomImageElement? _findCustomImage(bool page1, String id) {
    final page = page1 ? template.page1 : template.page2;
    for (final element in page.customImages) {
      if (element.id == id) return element;
    }
    return null;
  }

  CustomLineElement? _findCustomLine(bool page1, String id) {
    final page = page1 ? template.page1 : template.page2;
    for (final element in page.customLines) {
      if (element.id == id) return element;
    }
    return null;
  }

  CustomShapeElement? _findCustomShape(bool page1, String id) {
    final page = page1 ? template.page1 : template.page2;
    for (final element in page.customShapes) {
      if (element.id == id) return element;
    }
    return null;
  }
}

enum _TemplateElementType { text, image, line, shape }

class _TemplateSelection {
  const _TemplateSelection({
    required this.type,
    required this.page1,
    required this.id,
  });

  final _TemplateElementType type;
  final bool page1;
  final String id;

  static _TemplateSelection? parse(String selectedElement) {
    final parts = selectedElement.split(':');
    if (parts.length != 3) return null;

    final type = switch (parts[0]) {
      'custom' => _TemplateElementType.text,
      'image' => _TemplateElementType.image,
      'line' => _TemplateElementType.line,
      'shape' => _TemplateElementType.shape,
      _ => null,
    };
    if (type == null) return null;

    return _TemplateSelection(
      type: type,
      page1: parts[1] == '1',
      id: parts[2],
    );
  }
}
