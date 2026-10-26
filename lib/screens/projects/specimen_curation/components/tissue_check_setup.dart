import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

/// Which tubes a check finds, the field it writes, the box it fills, and
/// how cell labels and stored values are handled, in titled sections. It has
/// no card of its own, so the inspector or a tab can host it.
class TissueCheckSetupPanel extends StatefulWidget {
  const TissueCheckSetupPanel({
    super.key,
    required this.settings,
    required this.onChanged,
    this.partTypes = const [],
    this.treatments = const [],
    this.parasiteCategories = const [],
  });

  final TissueCheckSettings settings;
  final ValueChanged<TissueCheckSettings> onChanged;

  /// The part type and treatment vocabularies the filters offer.
  final List<String> partTypes;
  final List<String> treatments;
  final List<String> parasiteCategories;

  @override
  State<TissueCheckSetupPanel> createState() => _TissueCheckSetupPanelState();
}

class _TissueCheckSetupPanelState extends State<TissueCheckSetupPanel> {
  late final _valueCtr = TextEditingController(text: widget.settings.value);
  late final _boxLabelCtr = TextEditingController(
    text: widget.settings.boxLabel,
  );
  late final _boxNumberCtr = TextEditingController(
    text: '${widget.settings.boxNumber}',
  );

  @override
  void didUpdateWidget(covariant TissueCheckSetupPanel oldWidget) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TissueSetupSection(
          key: const ValueKey('tissue-setup-find'),
          divided: false,
          icon: Icons.search,
          title: context.l10n.projectTissueFindTubes,
          description: context.l10n.projectTissueFindTubesBody,
          children: [
            SwitchListTile(
              key: const ValueKey('tissue-include-parasites'),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.projectTissueIncludeParasites),
              value: settings.includeParasites,
              onChanged: (include) => widget.onChanged(
                settings.copyWith(includeParasites: include),
              ),
            ),
            const SizedBox(height: NahpuSpacing.md),
            TissueSetupPair(
              first: TissueFilterChecklist(
                key: const ValueKey('tissue-type-filter'),
                label: context.l10n.projectTissueType,
                selected: settings.partTypes,
                options: widget.partTypes,
                onChanged: (types) =>
                    widget.onChanged(settings.copyWith(partTypes: types)),
              ),
              second: TissueFilterChecklist(
                key: const ValueKey('tissue-preservation-filter'),
                label: context.l10n.projectTissuePreservation,
                selected: settings.preservations,
                options: widget.treatments,
                onChanged: (treatments) => widget.onChanged(
                  settings.copyWith(preservations: treatments),
                ),
              ),
            ),
            if (settings.includeParasites) ...[
              const SizedBox(height: NahpuSpacing.xl),
              TissueFilterChecklist(
                key: const ValueKey('tissue-parasite-category-filter'),
                label: context.l10n.projectTissueParasiteCategory,
                selected: settings.parasiteCategories,
                options: widget.parasiteCategories,
                onChanged: (categories) => widget.onChanged(
                  settings.copyWith(parasiteCategories: categories),
                ),
              ),
            ],
          ],
        ),
        TissueSetupSection(
          key: const ValueKey('tissue-setup-update'),
          icon: Icons.edit_note,
          title: context.l10n.projectTissueUpdateField,
          description: context.l10n.projectTissueUpdateFieldBody,
          children: [
            TissueSetupPair(
              first: DropdownButtonFormField<TissueCheckField>(
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
              second: TextField(
                key: const ValueKey('tissue-check-value'),
                controller: _valueCtr,
                decoration: InputDecoration(
                  labelText: context.l10n.projectTissueValue,
                  hintText: context.l10n.projectTissueMuseumCode,
                ),
                onChanged: (value) =>
                    widget.onChanged(widget.settings.copyWith(value: value)),
              ),
            ),
          ],
        ),
        TissueSetupSection(
          key: const ValueKey('tissue-setup-box'),
          icon: Icons.inventory_2_outlined,
          title: context.l10n.projectTissueTabBox,
          description: context.l10n.projectTissueBoxSectionBody,
          children: [
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
                  layout: layout.copyWith(size: selection.first),
                ),
              ),
            ),
            const SizedBox(height: NahpuSpacing.xl),
            DropdownButtonFormField<TissueFillOrder>(
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
                  settings.copyWith(layout: layout.copyWith(fillOrder: order)),
                );
              },
            ),
            const SizedBox(height: NahpuSpacing.xl),
            TissueSetupPair(
              first: TextField(
                controller: _boxLabelCtr,
                decoration: InputDecoration(
                  labelText: context.l10n.projectTissueBoxLabel,
                  hintText: context.l10n.projectTissueBoxHint,
                ),
                onChanged: (label) =>
                    widget.onChanged(widget.settings.copyWith(boxLabel: label)),
              ),
              second: TextField(
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
        TissueSetupSection(
          key: const ValueKey('tissue-setup-advanced'),
          icon: Icons.tune,
          title: context.l10n.projectTissueAdvanced,
          description: context.l10n.projectTissueAdvancedBody,
          children: [
            SwitchListTile(
              key: const ValueKey('tissue-custom-labels'),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.projectTissueCustomLabels),
              value: settings.customLabels,
              onChanged: (custom) =>
                  widget.onChanged(settings.copyWith(customLabels: custom)),
            ),
            if (settings.customLabels) ...[
              TissueLabelFormatFields(
                settings: settings,
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: NahpuSpacing.md),
            ],
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
      ],
    );
  }

  void _sync(TextEditingController controller, String text) {
    if (controller.text != text) controller.text = text;
  }
}

/// The custom cell label settings: numbering, separators, zero padding,
/// and a preview of the locations they write. Shown while custom labels are
/// on.
class TissueLabelFormatFields extends StatefulWidget {
  const TissueLabelFormatFields({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final TissueCheckSettings settings;
  final ValueChanged<TissueCheckSettings> onChanged;

  @override
  State<TissueLabelFormatFields> createState() =>
      _TissueLabelFormatFieldsState();
}

class _TissueLabelFormatFieldsState extends State<TissueLabelFormatFields> {
  late final _boxSeparatorCtr = TextEditingController(
    text: widget.settings.layout.labelFormat.boxSeparator,
  );
  late final _rowColumnCtr = TextEditingController(
    text: widget.settings.layout.labelFormat.rowColumnSeparator,
  );

  @override
  void dispose() {
    _boxSeparatorCtr.dispose();
    _rowColumnCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = widget.settings;
    final layout = settings.layout;
    final format = layout.labelFormat;
    final effective = settings.effectiveLayout;
    final cells = effective.orderedCells;
    String example(TissueCell cell) => formatTissueLocation(
      settings.boxLabel,
      settings.boxNumber,
      effective.cellLabel(cell),
      format: effective.labelFormat,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              _update(layout.copyWith(numbering: numbering));
            },
          ),
          second: TextField(
            key: const ValueKey('tissue-box-separator'),
            controller: _boxSeparatorCtr,
            decoration: InputDecoration(
              labelText: context.l10n.projectTissueBoxSeparator,
            ),
            onChanged: (text) => _update(
              layout.copyWith(labelFormat: format.copyWith(boxSeparator: text)),
            ),
          ),
        ),
        if (layout.numbering == TissueCellNumbering.rowColumn) ...[
          const SizedBox(height: NahpuSpacing.xl),
          TextField(
            key: const ValueKey('tissue-row-column-separator'),
            controller: _rowColumnCtr,
            decoration: InputDecoration(
              labelText: context.l10n.projectTissueRowColumnSeparator,
            ),
            onChanged: (text) => _update(
              layout.copyWith(
                labelFormat: format.copyWith(rowColumnSeparator: text),
              ),
            ),
          ),
        ],
        SwitchListTile(
          key: const ValueKey('tissue-zero-pad'),
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.projectTissueZeroPad),
          value: format.zeroPad,
          onChanged: (zeroPad) => _update(
            layout.copyWith(labelFormat: format.copyWith(zeroPad: zeroPad)),
          ),
        ),
        Text(
          context.l10n.projectTissueLabelExample(
            '${example(cells.first)} … ${example(cells.last)}',
          ),
          key: const ValueKey('tissue-label-example'),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  void _update(TissueBoxLayout layout) {
    widget.onChanged(widget.settings.copyWith(layout: layout));
  }
}

/// A titled group of setup fields, divided from the group above it.
class TissueSetupSection extends StatelessWidget {
  const TissueSetupSection({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.children,
    this.divided = true,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Widget> children;

  /// False drops the rule above, as on the first section.
  final bool divided;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divided
            ? Border(top: BorderSide(color: theme.colorScheme.outlineVariant))
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: divided ? NahpuSpacing.xl : 0,
          bottom: NahpuSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: NahpuControlSize.iconMedium,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: NahpuSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.lg),
            ...children,
          ],
        ),
      ),
    );
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

/// A vocabulary filter that matches any of the checked values. Nothing
/// checked matches anything and reads as Any.
class TissueFilterChecklist extends StatelessWidget {
  const TissueFilterChecklist({
    super.key,
    required this.label,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final Set<String> selected;
  final List<String> options;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final values = [
      ...options,
      for (final value in selected)
        if (!options.contains(value)) value,
    ];
    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        style: const MenuStyle(
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
          ),
        ),
        menuChildren: [
          // The menu spans the field, so values line up under it.
          SizedBox(
            width: constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckboxMenuButton(
                  value: selected.isEmpty,
                  closeOnActivate: false,
                  onChanged: (_) => onChanged(const {}),
                  child: Text(context.l10n.projectTissueAny),
                ),
                for (final value in values)
                  CheckboxMenuButton(
                    value: selected.contains(value),
                    closeOnActivate: false,
                    onChanged: (isChecked) => onChanged(
                      isChecked == true
                          ? {...selected, value}
                          : ({...selected}..remove(value)),
                    ),
                    child: Text(value),
                  ),
              ],
            ),
          ),
        ],
        builder: (context, controller, child) => InkWell(
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            child: Text(
              selected.isEmpty
                  ? context.l10n.projectTissueAny
                  : values.where(selected.contains).join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
