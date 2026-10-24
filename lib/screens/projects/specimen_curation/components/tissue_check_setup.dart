import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

/// Which field a check writes, the value it writes, and the box layout.
class TissueCheckSetupCard extends StatefulWidget {
  const TissueCheckSetupCard({
    super.key,
    required this.settings,
    required this.onChanged,
    this.partTypes = const [],
    this.treatments = const [],
  });

  final TissueCheckSettings settings;
  final ValueChanged<TissueCheckSettings> onChanged;

  /// The part type and treatment vocabularies the filters offer.
  final List<String> partTypes;
  final List<String> treatments;

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
            Text(
              context.l10n.projectTissueFindTubes,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: NahpuSpacing.lg),
            SegmentedButton<TissueIdentifyBy>(
              segments: [
                for (final by in TissueIdentifyBy.values)
                  ButtonSegment(
                    value: by,
                    label: Text(by.localizedLabel(context.l10n)),
                  ),
              ],
              selected: {settings.identifyBy},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => widget.onChanged(
                settings.copyWith(identifyBy: selection.first),
              ),
            ),
            const SizedBox(height: NahpuSpacing.xl),
            TissueSetupPair(
              first: TissueFilterDropdown(
                key: const ValueKey('tissue-type-filter'),
                label: context.l10n.projectTissueType,
                value: settings.partType,
                options: widget.partTypes,
                onChanged: (type) =>
                    widget.onChanged(settings.copyWith(partType: () => type)),
              ),
              second: TissueFilterDropdown(
                key: const ValueKey('tissue-preservation-filter'),
                label: context.l10n.projectTissuePreservation,
                value: settings.preservation,
                options: widget.treatments,
                onChanged: (treatment) => widget.onChanged(
                  settings.copyWith(preservation: () => treatment),
                ),
              ),
            ),
            const SizedBox(height: NahpuSpacing.xxl),
            Text(
              context.l10n.projectTissueUpdateField,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: NahpuSpacing.lg),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<TissueCheckField>(
                    initialValue: settings.field,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.projectTissueField,
                    ),
                    items: [
                      for (final field in TissueCheckField.values)
                        DropdownMenuItem(
                          value: field,
                          child: Text(field.localizedLabel(context.l10n)),
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
                    decoration: InputDecoration(
                      labelText: context.l10n.projectTissueValue,
                      hintText: context.l10n.projectTissueMuseumCode,
                    ),
                    onChanged: (value) => widget.onChanged(
                      widget.settings.copyWith(value: value),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.xl),
            Text(
              context.l10n.projectTissueBoxSize,
              style: Theme.of(context).textTheme.labelMedium,
            ),
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
            TissueSetupPair(
              first: DropdownButtonFormField<TissueCellNumbering>(
                initialValue: layout.numbering,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: context.l10n.projectTissueNumbering,
                ),
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
              second: DropdownButtonFormField<TissueFillOrder>(
                initialValue: layout.fillOrder,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: context.l10n.projectTissueFillOrder,
                ),
                items: [
                  for (final order in TissueFillOrder.values)
                    DropdownMenuItem(
                      value: order,
                      child: Text(order.localizedLabel(context.l10n)),
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
            const SizedBox(height: NahpuSpacing.xl),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _boxLabelCtr,
                    decoration: InputDecoration(
                      labelText: context.l10n.projectTissueBoxLabel,
                      hintText: context.l10n.projectTissueBoxHint,
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
                    decoration: InputDecoration(
                      labelText: context.l10n.projectTissueBoxNumber,
                    ),
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
              title: Text(context.l10n.projectTissueOverwrite),
              subtitle: Text(context.l10n.projectTissueOverwriteBody),
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

/// Two setup fields side by side, stacked on small screens where each needs
/// the full width.
class TissueSetupPair extends StatelessWidget {
  const TissueSetupPair({super.key, required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          first,
          const SizedBox(height: NahpuSpacing.xl),
          second,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: NahpuSpacing.md),
        Expanded(child: second),
      ],
    );
  }
}

/// A vocabulary filter with an Any choice, shown as null.
class TissueFilterDropdown extends StatelessWidget {
  const TissueFilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final values = [
      ...options,
      if (value != null && !options.contains(value)) value!,
    ];
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(context.l10n.projectTissueAny),
        ),
        for (final option in values)
          DropdownMenuItem<String?>(value: option, child: Text(option)),
      ],
      onChanged: onChanged,
    );
  }
}
