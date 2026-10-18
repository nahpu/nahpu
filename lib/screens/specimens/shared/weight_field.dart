import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';

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
    this.labelText = 'Weight',
    this.hintText = 'Enter specimen weight',
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String unit;
  final bool isBracketed;
  final String labelText;
  final String hintText;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: '$labelText ($unit)${isBracketed ? '*' : ''}',
        hintText: hintText,
        suffixIcon: AdaptiveMenuButton<String>(
          tooltip: 'Change weight unit',
          icon: const Icon(Icons.edit_outlined),
          initialValue: unit,
          onSelected: onUnitChanged,
          itemBuilder: () => [
            for (final value in specimenWeightUnits)
              AdaptiveMenuItem(
                value: value,
                label: value,
                checked: value == unit,
              ),
          ],
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
