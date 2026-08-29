import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Shared color picker and swatch for template element properties.
Future<Color?> showTemplateColorPicker(
  BuildContext context, {
  required Color color,
  required String title,
  bool showColorCode = false,
  bool enableShadesSelection = false,
  bool enableCopyPaste = true,
}) async {
  var selectedColor = color;
  final picked = await ColorPicker(
    color: selectedColor,
    onColorChanged: (next) => selectedColor = next,
    enableShadesSelection: enableShadesSelection,
    heading: Text(title, style: Theme.of(context).textTheme.titleSmall),
    subheading: Text(
      'Select color shade',
      style: Theme.of(context).textTheme.titleSmall,
    ),
    wheelSubheading: Text(
      'Selected color and its shades',
      style: Theme.of(context).textTheme.titleSmall,
    ),
    showColorName: true,
    showColorCode: showColorCode,
    copyPasteBehavior: enableCopyPaste
        ? const ColorPickerCopyPasteBehavior(
            copyButton: true,
            pasteButton: true,
            longPressMenu: true,
          )
        : const ColorPickerCopyPasteBehavior(),
    colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
    colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
    pickersEnabled: const <ColorPickerType, bool>{
      ColorPickerType.both: false,
      ColorPickerType.primary: true,
      ColorPickerType.accent: true,
      ColorPickerType.bw: true,
      ColorPickerType.custom: true,
      ColorPickerType.wheel: true,
    },
  ).showPickerDialog(context);
  return picked ? selectedColor : null;
}

class TemplateColorSwatch extends StatelessWidget {
  const TemplateColorSwatch({
    super.key,
    required this.color,
    required this.title,
    required this.onPicked,
    this.borderColor,
    this.child,
    this.showColorCode = false,
    this.enableShadesSelection = false,
    this.enableCopyPaste = true,
    this.transparentBackground = false,
  });

  final Color color;
  final String title;
  final ValueChanged<Color> onPicked;
  final Color? borderColor;
  final Widget? child;
  final bool showColorCode;
  final bool enableShadesSelection;
  final bool enableCopyPaste;
  final bool transparentBackground;

  @override
  Widget build(BuildContext context) {
    final outline = borderColor ?? Theme.of(context).colorScheme.outline;
    return InkWell(
      onTap: () => _pick(context),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: transparentBackground ? Colors.transparent : color,
          border: Border.all(color: outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showTemplateColorPicker(
      context,
      color: color,
      title: title,
      showColorCode: showColorCode,
      enableShadesSelection: enableShadesSelection,
      enableCopyPaste: enableCopyPaste,
    );
    if (picked != null) onPicked(picked);
  }
}
