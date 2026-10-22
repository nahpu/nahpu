import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimen_check/tissue_box.dart';
import 'package:nahpu/services/specimen_check/tissue_check_settings.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Which field a check writes, the value it writes, and the box layout.
class TissueCheckSetupCard extends StatefulWidget {
  const TissueCheckSetupCard({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final TissueCheckSettings settings;
  final ValueChanged<TissueCheckSettings> onChanged;

  @override
  State<TissueCheckSetupCard> createState() => _TissueCheckSetupCardState();
}

class _TissueCheckSetupCardState extends State<TissueCheckSetupCard> {
  late final _valueCtr = TextEditingController(text: widget.settings.value);
  late final _boxLabelCtr = TextEditingController(
    text: widget.settings.boxLabel,
  );
  late final _boxNumberCtr = TextEditingController(
    text: '${widget.settings.boxNumber}',
  );

  @override
  void didUpdateWidget(covariant TissueCheckSetupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_valueCtr, widget.settings.value);
    _sync(_boxLabelCtr, widget.settings.boxLabel);
    if (int.tryParse(_boxNumberCtr.text) != widget.settings.boxNumber) {
      _sync(_boxNumberCtr, '${widget.settings.boxNumber}');
    }
  }

  @override
  void dispose() {
    _valueCtr.dispose();
    _boxLabelCtr.dispose();
    _boxNumberCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final layout = settings.layout;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Update field', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: NahpuSpacing.lg),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<TissueCheckField>(
                    initialValue: settings.field,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Field'),
                    items: [
                      for (final field in TissueCheckField.values)
                        DropdownMenuItem(
                          value: field,
                          child: Text(field.label),
                        ),
                    ],
                    onChanged: (field) {
                      if (field != null) {
                        widget.onChanged(settings.copyWith(field: field));
                      }
                    },
                  ),
                ),
                const SizedBox(width: NahpuSpacing.md),
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: const ValueKey('tissue-check-value'),
                    controller: _valueCtr,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      hintText: 'Museum code',
                    ),
                    onChanged: (value) => widget.onChanged(
                      widget.settings.copyWith(value: value),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.xl),
            Text('Box size', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: NahpuSpacing.sm),
            SegmentedButton<TissueBoxSize>(
              segments: [
                for (final size in TissueBoxSize.values)
                  ButtonSegment(value: size, label: Text(size.label)),
              ],
              selected: {layout.size},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => widget.onChanged(
                settings.copyWith(
                  layout: TissueBoxLayout(
                    size: selection.first,
                    numbering: layout.numbering,
                    fillOrder: layout.fillOrder,
                  ),
                ),
              ),
            ),
            const SizedBox(height: NahpuSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TissueCellNumbering>(
                    initialValue: layout.numbering,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Numbering'),
                    items: [
                      for (final numbering in TissueCellNumbering.values)
                        DropdownMenuItem(
                          value: numbering,
                          child: Text(numbering.label),
                        ),
                    ],
                    onChanged: (numbering) {
                      if (numbering == null) return;
                      widget.onChanged(
                        settings.copyWith(
                          layout: TissueBoxLayout(
                            size: layout.size,
                            numbering: numbering,
                            fillOrder: layout.fillOrder,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: NahpuSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<TissueFillOrder>(
                    initialValue: layout.fillOrder,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Fill order'),
                    items: [
                      for (final order in TissueFillOrder.values)
                        DropdownMenuItem(
                          value: order,
                          child: Text(order.label),
                        ),
                    ],
                    onChanged: (order) {
                      if (order == null) return;
                      widget.onChanged(
                        settings.copyWith(
                          layout: TissueBoxLayout(
                            size: layout.size,
                            numbering: layout.numbering,
                            fillOrder: order,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.xl),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _boxLabelCtr,
                    decoration: const InputDecoration(
                      labelText: 'Box label',
                      hintText: 'Box',
                    ),
                    onChanged: (label) => widget.onChanged(
                      widget.settings.copyWith(boxLabel: label),
                    ),
                  ),
                ),
                const SizedBox(width: NahpuSpacing.md),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _boxNumberCtr,
                    decoration: const InputDecoration(labelText: 'Box number'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (text) {
                      final number = int.tryParse(text);
                      if (number != null && number > 0) {
                        widget.onChanged(
                          widget.settings.copyWith(boxNumber: number),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Overwrite existing values'),
              subtitle: const Text(
                'Replace a stored location or a different field value',
              ),
              value: settings.overwrite,
              onChanged: (overwrite) =>
                  widget.onChanged(settings.copyWith(overwrite: overwrite)),
            ),
          ],
        ),
      ),
    );
  }

  void _sync(TextEditingController controller, String text) {
    if (controller.text != text) controller.text = text;
  }
}
