import 'package:flutter/material.dart';

class SyncedMaxHeightField extends StatefulWidget {
  const SyncedMaxHeightField({
    super.key,
    required this.maxHeightMm,
    required this.onValidSize,
  });

  final double? maxHeightMm;
  final ValueChanged<double?> onValidSize;

  @override
  State<SyncedMaxHeightField> createState() => SyncedMaxHeightFieldState();
}

class SyncedMaxHeightFieldState extends State<SyncedMaxHeightField> {
  static const double _maxHeightMm = 1000.0;

  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.maxHeightMm == null || widget.maxHeightMm == 0.0
          ? '0'
          : widget.maxHeightMm!.toStringAsFixed(1),
    );
    _focus = FocusNode();
    _controller.addListener(_onEdit);
  }

  void _onEdit() {
    if (_controller.text.trim().isEmpty) return;
    final p = double.tryParse(_controller.text.trim());
    if (p != null && p >= 0 && p <= _maxHeightMm) {
      widget.onValidSize(p == 0.0 ? null : p);
    }
  }

  @override
  void didUpdateWidget(covariant SyncedMaxHeightField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxHeightMm != widget.maxHeightMm) {
      final next = widget.maxHeightMm == null || widget.maxHeightMm == 0.0
          ? '0'
          : widget.maxHeightMm!.toStringAsFixed(1);

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
