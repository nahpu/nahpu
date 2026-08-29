import 'package:material_ui/material_ui.dart';

class SyncedDimField extends StatefulWidget {
  const SyncedDimField({
    super.key,
    required this.value,
    required this.onValidValue,
    this.min = 2.0,
    this.max = 300.0,
  });

  final double value;
  final ValueChanged<double> onValidValue;
  final double min;
  final double max;

  @override
  State<SyncedDimField> createState() => SyncedDimFieldState();
}

class SyncedDimFieldState extends State<SyncedDimField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(1));
    _focus = FocusNode();
    _controller.addListener(_onEdit);
  }

  void _onEdit() {
    final p = double.tryParse(_controller.text.trim());
    if (p != null && p >= widget.min && p <= widget.max) {
      widget.onValidValue(p);
    }
  }

  @override
  void didUpdateWidget(covariant SyncedDimField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final next = widget.value.toStringAsFixed(1);
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
