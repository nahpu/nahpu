import 'package:material_ui/material_ui.dart';

class SyncedFontSizeField extends StatefulWidget {
  const SyncedFontSizeField({
    super.key,
    required this.fontSizePt,
    required this.onValidSize,
  });

  final double fontSizePt;
  final ValueChanged<double> onValidSize;

  @override
  State<SyncedFontSizeField> createState() => SyncedFontSizeFieldState();
}

class SyncedFontSizeFieldState extends State<SyncedFontSizeField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.fontSizePt.toStringAsFixed(1),
    );
    _focus = FocusNode();
    _controller.addListener(_onEdit);
  }

  void _onEdit() {
    final p = double.tryParse(_controller.text.trim());
    if (p != null && p >= 4 && p <= 72) {
      widget.onValidSize(p);
    }
  }

  @override
  void didUpdateWidget(covariant SyncedFontSizeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fontSizePt != widget.fontSizePt) {
      final next = widget.fontSizePt.toStringAsFixed(1);
      if (_controller.text != next) {
        _controller.removeListener(_onEdit);
        _controller.text = next;
        _controller.addListener(_onEdit);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onEdit);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      style: const TextStyle(fontSize: 14),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
