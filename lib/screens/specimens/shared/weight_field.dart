import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const List<String> specimenWeightUnits = ['g', 'kg', 'lbs'];

class WeightField extends StatelessWidget {
  const WeightField({
    super.key,
    required this.controller,
    required this.unit,
    required this.onChanged,
    required this.onUnitChanged,
    this.focusNode,
    this.isBracketed = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String unit;
  final bool isBracketed;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: 'Weight ($unit)${isBracketed ? '*' : ''}',
        hintText: 'Enter specimen weight',
        suffixIcon: PopupMenuButton<String>(
          tooltip: 'Change weight unit',
          icon: const Icon(Icons.edit_outlined),
          initialValue: unit,
          onSelected: onUnitChanged,
          itemBuilder: (context) => specimenWeightUnits
              .map((value) => PopupMenuItem(value: value, child: Text(value)))
              .toList(),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
    );
  }
}
