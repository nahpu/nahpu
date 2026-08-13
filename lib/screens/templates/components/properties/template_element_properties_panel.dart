import 'package:material_ui/material_ui.dart';
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
    required this.onDuplicateElement,
    required this.onCopyElement,
    required this.onPasteElement,
    required this.canPasteElement,
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
  final ValueChanged<String> onDuplicateElement;
  final ValueChanged<String> onCopyElement;
  final VoidCallback onPasteElement;
  final bool canPasteElement;

  @override
  Widget build(BuildContext context) {
    final selection = TemplateSelection.parse(selectedElement);
    if (selection == null) return const SizedBox.shrink();

    final actionControls = _buildActionControls(context, selectedElement);

    switch (selection.type) {
      case TemplateElementType.text:
        return TextPropertiesPanel(
          selectedElement: selectedElement,
          page1: page1,
          template: template,
          onUpdateCustomText: onUpdateCustomText,
          onDeleteCustomText: onDeleteCustomText,
          actionControls: actionControls,
          onDismiss: onDismiss,
        );
      case TemplateElementType.image:
        return ImagePropertiesPanel(
          page1: selection.page1,
          id: selection.id,
          zIndexControls: actionControls,
          onDelete: onDeleteCustomImage,
          inToolbar: true,
          onDismiss: onDismiss,
        );
      case TemplateElementType.line:
        final line = _findCustomLine(selection.page1, selection.id);
        if (line == null) return const SizedBox.shrink();
        return LinePropertiesPanel(
          page1: selection.page1,
          id: selection.id,
          line: line,
          zIndexControls: actionControls,
          onUpdate: onUpdateCustomLine,
          onDelete: onDeleteCustomLine,
          inToolbar: true,
          onDismiss: onDismiss,
        );
      case TemplateElementType.shape:
        final shape = _findCustomShape(selection.page1, selection.id);
        if (shape == null) return const SizedBox.shrink();
        return ShapePropertiesPanel(
          page1: selection.page1,
          id: selection.id,
          shape: shape,
          zIndexControls: actionControls,
          onUpdate: onUpdateCustomShape,
          onDelete: onDeleteCustomShape,
          inToolbar: true,
          onDismiss: onDismiss,
        );
    }
  }

  Widget _buildActionControls(BuildContext context, String selectedElement) {
    final selection = TemplateSelection.parse(selectedElement);
    if (selection == null) return const SizedBox.shrink();

    bool isLocked = false;
    bool isVisible = true;

    switch (selection.type) {
      case TemplateElementType.text:
        final el = _findCustomText(selection.page1, selection.id);
        if (el != null) {
          isLocked = el.isLocked;
          isVisible = el.isVisible;
        }
      case TemplateElementType.image:
        final el = _findCustomImage(selection.page1, selection.id);
        if (el != null) {
          isLocked = el.isLocked;
          isVisible = el.isVisible;
        }
      case TemplateElementType.line:
        final el = _findCustomLine(selection.page1, selection.id);
        if (el != null) {
          isLocked = el.isLocked;
          isVisible = el.isVisible;
        }
      case TemplateElementType.shape:
        final el = _findCustomShape(selection.page1, selection.id);
        if (el != null) {
          isLocked = el.isLocked;
          isVisible = el.isVisible;
        }
    }

    void setZIndex(int delta) {
      switch (selection.type) {
        case TemplateElementType.text:
          final element = _findCustomText(selection.page1, selection.id);
          if (element != null) {
            onUpdateCustomText(
              selection.page1,
              element.copyWith(zIndex: element.zIndex + delta),
            );
          }
        case TemplateElementType.image:
          final element = _findCustomImage(selection.page1, selection.id);
          if (element != null) {
            onUpdateCustomImage(
              selection.page1,
              element.copyWith(zIndex: element.zIndex + delta),
            );
          }
        case TemplateElementType.line:
          final element = _findCustomLine(selection.page1, selection.id);
          if (element != null) {
            onUpdateCustomLine(
              selection.page1,
              element.copyWith(zIndex: element.zIndex + delta),
            );
          }
        case TemplateElementType.shape:
          final element = _findCustomShape(selection.page1, selection.id);
          if (element != null) {
            onUpdateCustomShape(
              selection.page1,
              element.copyWith(zIndex: element.zIndex + delta),
            );
          }
      }
    }

    void toggleLock() {
      switch (selection.type) {
        case TemplateElementType.text:
          final el = _findCustomText(selection.page1, selection.id);
          if (el != null) {
            onUpdateCustomText(
              selection.page1,
              el.copyWith(isLocked: !el.isLocked),
            );
          }
        case TemplateElementType.image:
          final el = _findCustomImage(selection.page1, selection.id);
          if (el != null) {
            onUpdateCustomImage(
              selection.page1,
              el.copyWith(isLocked: !el.isLocked),
            );
          }
        case TemplateElementType.line:
          final el = _findCustomLine(selection.page1, selection.id);
          if (el != null) {
            onUpdateCustomLine(
              selection.page1,
              el.copyWith(isLocked: !el.isLocked),
            );
          }
        case TemplateElementType.shape:
          final el = _findCustomShape(selection.page1, selection.id);
          if (el != null) {
            onUpdateCustomShape(
              selection.page1,
              el.copyWith(isLocked: !el.isLocked),
            );
          }
      }
    }

    void toggleVisibility() {
      switch (selection.type) {
        case TemplateElementType.text:
          final el = _findCustomText(selection.page1, selection.id);
          if (el != null) {
            onUpdateCustomText(
              selection.page1,
              el.copyWith(isVisible: !el.isVisible),
            );
          }
        case TemplateElementType.image:
          final el = _findCustomImage(selection.page1, selection.id);
          if (el != null) {
            onUpdateCustomImage(
              selection.page1,
              el.copyWith(isVisible: !el.isVisible),
            );
          }
        case TemplateElementType.line:
          final el = _findCustomLine(selection.page1, selection.id);
          if (el != null) {
            onUpdateCustomLine(
              selection.page1,
              el.copyWith(isVisible: !el.isVisible),
            );
          }
        case TemplateElementType.shape:
          final el = _findCustomShape(selection.page1, selection.id);
          if (el != null) {
            onUpdateCustomShape(
              selection.page1,
              el.copyWith(isVisible: !el.isVisible),
            );
          }
      }
    }

    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_down, size: 20),
          tooltip: 'Send to back',
          onPressed: () => setZIndex(-5),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          tooltip: 'Send backward',
          onPressed: () => setZIndex(-1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, size: 20),
          tooltip: 'Bring forward',
          onPressed: () => setZIndex(1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_up, size: 20),
          tooltip: 'Bring to front',
          onPressed: () => setZIndex(5),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            isLocked ? Icons.lock : Icons.lock_open_outlined,
            size: 20,
          ),
          tooltip: isLocked ? 'Unlock position' : 'Lock position',
          onPressed: toggleLock,
          color: isLocked ? scheme.primary : null,
        ),
        IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_outlined : Icons.visibility_off,
            size: 20,
          ),
          tooltip: isVisible ? 'Hide element' : 'Show element',
          onPressed: toggleVisibility,
          color: !isVisible ? scheme.error : null,
        ),
        IconButton(
          icon: const Icon(Icons.control_point_duplicate_outlined, size: 20),
          tooltip: 'Duplicate element',
          onPressed: () => onDuplicateElement(selectedElement),
        ),
        IconButton(
          icon: const Icon(Icons.content_copy_outlined, size: 20),
          tooltip: 'Copy element',
          onPressed: () => onCopyElement(selectedElement),
        ),
        IconButton(
          icon: const Icon(Icons.content_paste_outlined, size: 20),
          tooltip: 'Paste element',
          onPressed: canPasteElement ? onPasteElement : null,
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
