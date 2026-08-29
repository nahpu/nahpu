import 'package:material_ui/material_ui.dart';

class SyncedMaxWidthField extends StatefulWidget {
  const SyncedMaxWidthField({
    super.key,
    required this.maxWidthMm,
    required this.onValidSize,
  });

  final double? maxWidthMm;
  final ValueChanged<double?> onValidSize;

  @override
  State<SyncedMaxWidthField> createState() => SyncedMaxWidthFieldState();
}

class SyncedMaxWidthFieldState extends State<SyncedMaxWidthField> {
  static const double _maxWidthMm = 1000.0;

  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.maxWidthMm == null || widget.maxWidthMm == 0.0
          ? '0'
          : widget.maxWidthMm!.toStringAsFixed(1),
    );
    _focus = FocusNode();
    _controller.addListener(_onEdit);
  }

  void _onEdit() {
    if (_controller.text.trim().isEmpty) return;
    final p = double.tryParse(_controller.text.trim());
    if (p != null && p >= 0 && p <= _maxWidthMm) {
      widget.onValidSize(p == 0.0 ? null : p);
    }
  }

  @override
  void didUpdateWidget(covariant SyncedMaxWidthField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxWidthMm != widget.maxWidthMm) {
      final next = widget.maxWidthMm == null || widget.maxWidthMm == 0.0
          ? '0'
          : widget.maxWidthMm!.toStringAsFixed(1);

      // Don't override if the user is typing (e.g. typing "10." shouldn't jump to "10")
      final currentNum = double.tryParse(_controller.text.trim());
      final nextNum = double.tryParse(next);
      if (currentNum != nextNum) {
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
