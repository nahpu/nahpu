import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/inline_grouped_field_picker.dart';
import 'package:nahpu/screens/shared/text_replacement_rules_editor.dart';
import 'package:nahpu/services/specimens/conditional_brackets.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/screens/templates/components/properties/synced_font_size_field.dart';
import 'package:nahpu/screens/templates/components/properties/synced_max_width_field.dart';
import 'package:nahpu/screens/templates/components/properties/synced_max_height_field.dart';
import 'package:nahpu/services/templates/template_field_catalog.dart';
import 'package:nahpu/services/export/list_value_formatter.dart';
import 'package:nahpu/services/export/text_replacements.dart';
import 'package:nahpu/screens/templates/components/properties/text_format_options.dart';
import 'package:nahpu/screens/templates/components/properties/template_color_picker.dart';
import 'package:nahpu/screens/templates/template_fonts.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/screens/templates/components/dialogs/map_encoded_values_dialog.dart';
import 'package:nahpu/services/types/birds.dart';

class TextPropertiesPanel extends StatelessWidget {
  const TextPropertiesPanel({
    super.key,
    required this.selectedElement,
    required this.page1,
    required this.template,
    required this.onUpdateCustomText,
    required this.onDeleteCustomText,
    required this.actionControls,
    this.onDismiss,
  });

  final String selectedElement;
  final bool page1;
  final Template template;
  final VoidCallback? onDismiss;
  final Widget actionControls;

  final void Function(bool page1, CustomTextElement element) onUpdateCustomText;
  final void Function(bool page1, String id) onDeleteCustomText;

  static const double _textDimensionSliderMaxMm = 1000.0;

  CustomTextElement? _findCustomText(bool p1, String id) {
    final page = p1 ? template.page1 : template.page2;
    for (final ct in page.customTexts) {
      if (ct.id == id) return ct;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _buildCustomTextPanel(context, selectedElement, inToolbar: true);
  }

  Widget _buildPanelContainer(
    BuildContext context, {
    required Widget child,
    required bool inToolbar,
  }) {
    final scheme = Theme.of(context).colorScheme;

    final wrappedChild = Row(
      children: [
        Expanded(child: child),
        if (onDismiss != null) ...[
          SizedBox(
            height: 32,
            child: VerticalDivider(
              width: 2,
              thickness: 2,
              color: scheme.outlineVariant,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Dismiss toolbar',
            onPressed: onDismiss,
          ),
          const SizedBox(width: 4),
        ],
      ],
    );

    if (inToolbar) {
      return Material(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: wrappedChild,
      );
    }
    return Material(
      elevation: 2,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(top: false, child: wrappedChild),
    );
  }

  Widget _buildOptionSlider(
    BuildContext context, {
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final safeMin = min <= max ? min : max;
    final safeMax = max >= min ? max : min;
    final safeValue = value.clamp(safeMin, safeMax).toDouble();
    final safeDivisions = divisions > 0 ? divisions : null;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.12),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: TextStyle(color: scheme.onPrimary),
        valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
        showValueIndicator: ShowValueIndicator.onDrag,
      ),
      child: Slider(
        value: safeValue,
        min: safeMin,
        max: safeMax,
        divisions: safeDivisions,
        label: label,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCustomTextPanel(
    BuildContext context,
    String sel, {
    bool inToolbar = false,
  }) {
    final parts = sel.split(':');
    if (parts.length != 3) return const SizedBox.shrink();
    final page1 = parts[1] == '1';
    final id = parts[2];
    final ct = _findCustomText(page1, id);
    if (ct == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete text box',
      onPressed: () => onDeleteCustomText(page1, id),
    );

    if (isTemplateBracketSpecimenSexIconText(ct.text)) {
      final content = Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [actionControls, const Spacer(), deleteButton],
        ),
      );
      return _buildPanelContainer(
        context,
        inToolbar: inToolbar,
        child: content,
      );
    }

    final content = _CustomTextToolbar(
      key: ValueKey(ct.id),
      ct: ct,
      page1: page1,
      recordType: template.recordType,
      inToolbar: inToolbar,
      onUpdateCustomText: onUpdateCustomText,
      actionControls: actionControls,
      deleteButton: deleteButton,
      buildOptionSlider: _buildOptionSlider,
    );

    return _buildPanelContainer(context, inToolbar: inToolbar, child: content);
  }
}

class _CustomTextToolbar extends ConsumerStatefulWidget {
  const _CustomTextToolbar({
    super.key,
    required this.ct,
    required this.page1,
    required this.recordType,
    required this.inToolbar,
    required this.onUpdateCustomText,
    required this.actionControls,
    required this.deleteButton,
    required this.buildOptionSlider,
  });

  final CustomTextElement ct;
  final bool page1;
  final RecordType recordType;
  final bool inToolbar;
  final void Function(bool page1, CustomTextElement element) onUpdateCustomText;
  final Widget actionControls;
  final Widget deleteButton;
  final Widget Function(
    BuildContext, {
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  })
  buildOptionSlider;

  @override
  ConsumerState<_CustomTextToolbar> createState() => _CustomTextToolbarState();
}

class _CustomTextToolbarState extends ConsumerState<_CustomTextToolbar> {
  bool _showFormattingRow = false;
  bool _showStylingRow = false;
  late TextEditingController _separatorController;

  @override
  void initState() {
    super.initState();
    final initialOption = widget.ct.textType == 'list'
        ? normalizeTemplateListFormatOption(widget.ct.formatOption)
        : widget.ct.formatOption;
    final initialSep = initialOption.startsWith('custom:')
        ? initialOption.substring(7)
        : '';
    _separatorController = TextEditingController(text: initialSep);
  }

  @override
  void didUpdateWidget(covariant _CustomTextToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ct.id != oldWidget.ct.id ||
        widget.ct.formatOption != oldWidget.ct.formatOption) {
      final option = widget.ct.textType == 'list'
          ? normalizeTemplateListFormatOption(widget.ct.formatOption)
          : widget.ct.formatOption;
      final sep = option.startsWith('custom:') ? option.substring(7) : '';
      if (_separatorController.text != sep) {
        _separatorController.text = sep;
      }
    }
  }

  @override
  void dispose() {
    _separatorController.dispose();
    super.dispose();
  }

  bool _hasTextPlaceholder(String text) {
    return RegExp(r'\[([^\]]+)\]').allMatches(text).any((match) {
      final placeholder = match.group(1);
      return placeholder != null && !placeholder.trim().endsWith('-img');
    });
  }

  String _getSexPresentation(String formatOption) {
    final parts = formatOption.split(':');
    return parts.isNotEmpty ? parts[0] : 'text';
  }

  String _getSexMissing(String formatOption) {
    final parts = formatOption.split(':');
    return parts.length > 1 ? parts[1] : 'unknown';
  }

  Widget _buildPicturePrimaryRow(
    BuildContext context,
    CustomTextElement text,
    bool page1,
    void Function(bool page1, CustomTextElement element) onUpdate,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          widget.actionControls,
          const SizedBox(width: 12),
          Text('Width (mm)', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: SyncedMaxWidthField(
              key: ValueKey('pw_${text.id}'),
              maxWidthMm: text.pictureWidthMm,
              onValidSize: (value) {
                if (value != null && value > 0) {
                  onUpdate(page1, text.copyWith(pictureWidthMm: value));
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Text('Height (mm)', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: SyncedMaxHeightField(
              key: ValueKey('ph_${text.id}'),
              maxHeightMm: text.pictureHeightMm,
              onValidSize: (value) {
                if (value != null && value > 0) {
                  onUpdate(page1, text.copyWith(pictureHeightMm: value));
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.tune, size: 24),
            isSelected: _showFormattingRow,
            tooltip: 'Picture type options',
            onPressed: () {
              setState(() => _showFormattingRow = !_showFormattingRow);
            },
          ),
          const SizedBox(width: 12),
          Text('Rotation', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('0°')),
              ButtonSegment(value: 90, label: Text('90°')),
              ButtonSegment(value: -90, label: Text('-90°')),
              ButtonSegment(value: 180, label: Text('180°')),
            ],
            selected: {text.rotationDegrees},
            onSelectionChanged: (next) {
              if (next.isEmpty) return;
              onUpdate(page1, text.copyWith(rotationDegrees: next.first));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.ct;
    final page1 = widget.page1;
    final onUpdateCustomText = widget.onUpdateCustomText;
    final scheme = Theme.of(context).colorScheme;
    final isPicture = isTemplatePictureTextType(ct.textType);

    final fontKey = normalizeTemplateFontFamily(ct.fontFamily);
    final fontDropdownIds = List<String>.from(kTemplateFontDropdownKeys);
    if (fontKey.isNotEmpty && !fontDropdownIds.contains(fontKey)) {
      fontDropdownIds.add(fontKey);
    }

    final row1 = isPicture
        ? _buildPicturePrimaryRow(context, ct, page1, onUpdateCustomText)
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                widget.actionControls,
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('QR Code'),
                  selected: ct.isQrCode,
                  onSelected: (selected) {
                    onUpdateCustomText(page1, ct.copyWith(isQrCode: selected));
                  },
                ),
                const SizedBox(width: 8),
                if (ct.isQrCode) ...[
                  Text(
                    'QR Size (mm)',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: widget.buildOptionSlider(
                      context,
                      value: ct.qrSizeMm,
                      min: 5.0,
                      max: 100.0,
                      divisions: 95,
                      label: '${ct.qrSizeMm.toStringAsFixed(1)} mm',
                      onChanged: (v) {
                        onUpdateCustomText(page1, ct.copyWith(qrSizeMm: v));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.palette_outlined, size: 24),
                    isSelected: _showFormattingRow,
                    tooltip: 'Content formatting options',
                    onPressed: () {
                      setState(() {
                        _showFormattingRow = !_showFormattingRow;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Text('Shape', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'square', label: Text('Square')),
                      ButtonSegment(value: 'circle', label: Text('Circle')),
                    ],
                    selected: {ct.qrShape},
                    onSelectionChanged: (next) {
                      if (next.isEmpty) return;
                      onUpdateCustomText(
                        page1,
                        ct.copyWith(qrShape: next.first),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Rotation',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('0°')),
                      ButtonSegment(value: 90, label: Text('90°')),
                      ButtonSegment(value: -90, label: Text('-90°')),
                      ButtonSegment(value: 180, label: Text('180°')),
                    ],
                    selected: {ct.rotationDegrees},
                    onSelectionChanged: (next) {
                      if (next.isEmpty) return;
                      onUpdateCustomText(
                        page1,
                        ct.copyWith(rotationDegrees: next.first),
                      );
                    },
                  ),
                ] else ...[
                  FilterChip(
                    label: const Text('Dynamic'),
                    selected: ct.isDynamic,
                    onSelected: (selected) {
                      onUpdateCustomText(
                        page1,
                        ct.copyWith(isDynamic: selected),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Size (pt)',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: SyncedFontSizeField(
                      key: ValueKey('fs_${ct.id}'),
                      fontSizePt: ct.fontSizePt,
                      onValidSize: (p) =>
                          onUpdateCustomText(page1, ct.copyWith(fontSizePt: p)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    tooltip: 'Decrease font size',
                    onPressed: ct.fontSizePt > 4
                        ? () => onUpdateCustomText(
                            page1,
                            ct.copyWith(
                              fontSizePt: (ct.fontSizePt - 0.5).clamp(
                                4.0,
                                72.0,
                              ),
                            ),
                          )
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    tooltip: 'Increase font size',
                    onPressed: ct.fontSizePt < 72
                        ? () => onUpdateCustomText(
                            page1,
                            ct.copyWith(
                              fontSizePt: (ct.fontSizePt + 0.5).clamp(
                                4.0,
                                72.0,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.text_format, size: 24),
                    isSelected: _showFormattingRow,
                    tooltip: 'Text formatting options',
                    onPressed: () {
                      setState(() {
                        _showFormattingRow = !_showFormattingRow;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.palette_outlined, size: 24),
                    isSelected: _showStylingRow,
                    tooltip: 'Text styling options',
                    onPressed: () {
                      setState(() {
                        _showStylingRow = !_showStylingRow;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Max Width (mm)',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: SyncedMaxWidthField(
                      key: ValueKey('mw_${ct.id}'),
                      maxWidthMm: ct.maxWidthMm,
                      onValidSize: (p) =>
                          onUpdateCustomText(page1, ct.copyWith(maxWidthMm: p)),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: widget.buildOptionSlider(
                      context,
                      value: ct.maxWidthMm ?? 0.0,
                      min: 0.0,
                      max: TextPropertiesPanel._textDimensionSliderMaxMm,
                      divisions: 200,
                      label: ct.maxWidthMm == null || ct.maxWidthMm! == 0.0
                          ? 'Auto'
                          : '${ct.maxWidthMm!.toStringAsFixed(1)} mm',
                      onChanged: (v) {
                        onUpdateCustomText(
                          page1,
                          ct.copyWith(maxWidthMm: v == 0.0 ? null : v),
                        );
                      },
                    ),
                  ),
                  if (!ct.isDynamic) ...[
                    const SizedBox(width: 12),
                    Text(
                      'Max Height (mm)',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 64,
                      child: SyncedMaxHeightField(
                        key: ValueKey('mh_${ct.id}'),
                        maxHeightMm: ct.heightMm,
                        onValidSize: (p) =>
                            onUpdateCustomText(page1, ct.copyWith(heightMm: p)),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: widget.buildOptionSlider(
                        context,
                        value: ct.heightMm ?? 0.0,
                        min: 0.0,
                        max: TextPropertiesPanel._textDimensionSliderMaxMm,
                        divisions: 200,
                        label: ct.heightMm == null || ct.heightMm! == 0.0
                            ? 'Auto'
                            : '${ct.heightMm!.toStringAsFixed(1)} mm',
                        onChanged: (v) {
                          onUpdateCustomText(
                            page1,
                            ct.copyWith(heightMm: v == 0.0 ? null : v),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  Text(
                    'Rotation',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('0°')),
                      ButtonSegment(value: 90, label: Text('90°')),
                      ButtonSegment(value: -90, label: Text('-90°')),
                      ButtonSegment(value: 180, label: Text('180°')),
                    ],
                    selected: {ct.rotationDegrees},
                    onSelectionChanged: (next) {
                      if (next.isEmpty) return;
                      onUpdateCustomText(
                        page1,
                        ct.copyWith(rotationDegrees: next.first),
                      );
                    },
                  ),
                ],
              ],
            ),
          );

    final effectiveFormatOption = ct.textType == 'list'
        ? normalizeTemplateListFormatOption(ct.formatOption)
        : ct.formatOption;
    final isCustomSep = effectiveFormatOption.startsWith('custom:');
    final isCustomMap =
        ct.formatOption.startsWith('custom_map:') ||
        ct.formatOption == 'custom_map';
    final hasTextPlaceholder = _hasTextPlaceholder(ct.text);
    final nullFallbackControls = _NullFallbackControls(
      text: ct,
      page1: page1,
      hasTextPlaceholder: hasTextPlaceholder,
      onUpdate: onUpdateCustomText,
    );

    return Padding(
      padding: widget.inToolbar
          ? const EdgeInsets.all(8)
          : const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                row1,
                if (_showFormattingRow) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (!ct.isQrCode && !isPicture) ...[
                          Text(
                            'Font',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: fontKey,
                            isDense: true,
                            underline: const SizedBox.shrink(),
                            items: [
                              for (final k in fontDropdownIds)
                                DropdownMenuItem<String>(
                                  value: k,
                                  child: Text(templateFontDropdownLabel(k)),
                                ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              onUpdateCustomText(
                                page1,
                                ct.copyWith(fontFamily: v),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          _TextAlignPicker(
                            ct: ct,
                            page1: page1,
                            onUpdateCustomText: onUpdateCustomText,
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            isSelected: ct.bold,
                            icon: const Icon(Icons.format_bold, size: 20),
                            selectedIcon: Icon(
                              Icons.format_bold,
                              color: scheme.primary,
                              size: 20,
                            ),
                            onPressed: () => onUpdateCustomText(
                              page1,
                              ct.copyWith(bold: !ct.bold),
                            ),
                            tooltip: 'Bold',
                          ),
                          IconButton(
                            isSelected: ct.italic,
                            icon: const Icon(Icons.format_italic, size: 20),
                            selectedIcon: Icon(
                              Icons.format_italic,
                              color: scheme.primary,
                              size: 20,
                            ),
                            onPressed: () => onUpdateCustomText(
                              page1,
                              ct.copyWith(italic: !ct.italic),
                            ),
                            tooltip: 'Italic',
                          ),
                          IconButton(
                            isSelected: ct.underline,
                            icon: const Icon(Icons.format_underline, size: 20),
                            selectedIcon: Icon(
                              Icons.format_underline,
                              color: scheme.primary,
                              size: 20,
                            ),
                            onPressed: () => onUpdateCustomText(
                              page1,
                              ct.copyWith(underline: !ct.underline),
                            ),
                            tooltip: 'Underline',
                          ),
                          IconButton(
                            isSelected: ct.strikethrough,
                            icon: const Icon(
                              Icons.format_strikethrough,
                              size: 20,
                            ),
                            selectedIcon: Icon(
                              Icons.format_strikethrough,
                              color: scheme.primary,
                              size: 20,
                            ),
                            onPressed: () => onUpdateCustomText(
                              page1,
                              ct.copyWith(strikethrough: !ct.strikethrough),
                            ),
                            tooltip: 'Strikethrough',
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (ct.isQrCode) ...[
                          Text(
                            'Foreground',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          TemplateColorSwatch(
                            color: Color(ct.colorArgb),
                            title: 'Select QR foreground color',
                            enableCopyPaste: false,
                            onPicked: (color) => onUpdateCustomText(
                              page1,
                              ct.copyWith(colorArgb: color.toARGB32()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Background',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          TemplateColorSwatch(
                            color: Color(ct.qrBgColorArgb),
                            title: 'Select QR background color',
                            showColorCode: true,
                            enableCopyPaste: false,
                            onPicked: (color) => onUpdateCustomText(
                              page1,
                              ct.copyWith(qrBgColorArgb: color.toARGB32()),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Text(
                          'Type',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: ct.textType,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          items: textDropdownItems(kTextTypeOptions),
                          onChanged: (v) {
                            if (v == null) return;
                            String defaultOpt = 'normal';
                            if (v == 'coordinates') {
                              defaultOpt = 'decimal';
                            } else if (v == 'list') {
                              defaultOpt = 'pipe';
                            } else if (v == 'nestedList') {
                              defaultOpt = 'table';
                            } else if (v == 'date') {
                              defaultOpt = 'yyyy-mm-dd';
                            } else if (v == 'datetime') {
                              defaultOpt = 'yyyy-mm-dd-hm';
                            } else if (v == 'time') {
                              defaultOpt = 'time-24';
                            } else if (v == 'sex') {
                              defaultOpt = 'text:unknown';
                            } else if (v == 'number') {
                              defaultOpt = 'original';
                            } else if (v == 'encoded') {
                              defaultOpt = 'enum';
                            }
                            onUpdateCustomText(
                              page1,
                              ct.copyWith(
                                textType: v,
                                formatOption: defaultOpt,
                                isQrCode: v == kTemplatePictureTextType
                                    ? false
                                    : ct.isQrCode,
                                isDynamic: v == kTemplatePictureTextType
                                    ? false
                                    : ct.isDynamic,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        if (!isPicture) ...[
                          IconButton(
                            icon: const Icon(Icons.data_object_outlined),
                            tooltip: 'Conditional output',
                            onPressed: _hasTextPlaceholder(ct.text)
                                ? () async {
                                    final updated = await showDialog<String>(
                                      context: context,
                                      builder: (context) =>
                                          _ConditionalBracketTextDialog(
                                            text: ct.text,
                                            fieldGroups:
                                                availableTemplateFieldGroups(
                                                  ref.read(databaseProvider),
                                                  widget.recordType,
                                                ),
                                          ),
                                    );
                                    if (updated != null) {
                                      onUpdateCustomText(
                                        page1,
                                        ct.copyWith(text: updated),
                                      );
                                    }
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.find_replace),
                            selectedIcon: Icon(
                              Icons.find_replace,
                              color: scheme.primary,
                            ),
                            isSelected: ct.replacementRules.isNotEmpty,
                            tooltip: 'Find and replace',
                            onPressed: () async {
                              final updated =
                                  await showDialog<List<TextReplacementRule>>(
                                    context: context,
                                    builder: (context) =>
                                        TextReplacementRulesDialog(
                                          rules: ct.replacementRules,
                                        ),
                                  );
                              if (!context.mounted || updated == null) return;
                              onUpdateCustomText(
                                page1,
                                ct.copyWith(replacementRules: updated),
                              );
                            },
                          ),
                          if (ct.textType != 'sex') ...[
                            const SizedBox(width: 16),
                            Text(
                              'Format',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: isCustomSep
                                  ? 'custom'
                                  : (isCustomMap
                                        ? 'custom'
                                        : effectiveFormatOption),
                              isDense: true,
                              underline: const SizedBox.shrink(),
                              items: textFormatDropdownItems(ct.textType),
                              onChanged: (v) {
                                if (v == null) return;
                                String nextOpt = v;
                                if (v == 'custom') {
                                  if (ct.textType == 'encoded') {
                                    final placeholder = _detectPlaceholderKey(
                                      ct.text,
                                    );
                                    if (placeholder != null) {
                                      final defaultMap =
                                          _getDefaultEnumMapForPlaceholder(
                                            placeholder,
                                          );
                                      final pairs = defaultMap.entries
                                          .map((e) => '${e.key}=${e.value}')
                                          .join(',');
                                      nextOpt = 'custom_map:$pairs';
                                    } else {
                                      nextOpt = 'custom_map:';
                                    }
                                  } else {
                                    nextOpt = 'custom:';
                                  }
                                }
                                onUpdateCustomText(
                                  page1,
                                  ct.copyWith(formatOption: nextOpt),
                                );
                              },
                            ),
                            if (ct.textType == 'encoded' && isCustomMap) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_note, size: 24),
                                tooltip: 'Map encoded values',
                                onPressed: () async {
                                  final result = await showDialog<String>(
                                    context: context,
                                    builder: (context) =>
                                        MapEncodedValuesDialog(
                                          placeholderKey:
                                              _detectPlaceholderKey(ct.text) ??
                                              '',
                                          currentOption: ct.formatOption,
                                        ),
                                  );
                                  if (result != null) {
                                    onUpdateCustomText(
                                      page1,
                                      ct.copyWith(formatOption: result),
                                    );
                                  }
                                },
                              ),
                            ],
                            nullFallbackControls,
                            if (ct.textType == 'nestedList' &&
                                ct.formatOption == 'table') ...[
                              const SizedBox(width: 16),
                              Text(
                                'Header Case',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: ct.caseFormat == 'normal'
                                    ? 'title'
                                    : ct.caseFormat,
                                isDense: true,
                                underline: const SizedBox.shrink(),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'title',
                                    child: Text('Title Case'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'sentence',
                                    child: Text('Sentence Case'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'uppercase',
                                    child: Text('Uppercase'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'lowercase',
                                    child: Text('Lowercase'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  onUpdateCustomText(
                                    page1,
                                    ct.copyWith(caseFormat: v),
                                  );
                                },
                              ),
                            ],
                          ] else ...[
                            const SizedBox(width: 16),
                            Text(
                              'Format',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _getSexPresentation(ct.formatOption),
                              isDense: true,
                              underline: const SizedBox.shrink(),
                              items: textDropdownItems(kSexPresentationOptions),
                              onChanged: (v) {
                                if (v == null) return;
                                final missing = _getSexMissing(ct.formatOption);
                                onUpdateCustomText(
                                  page1,
                                  ct.copyWith(formatOption: '$v:$missing'),
                                );
                              },
                            ),
                            nullFallbackControls,
                            const SizedBox(width: 16),
                            Text(
                              'Missing',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _getSexMissing(ct.formatOption),
                              isDense: true,
                              underline: const SizedBox.shrink(),
                              items: textDropdownItems(kSexMissingOptions),
                              onChanged: (v) {
                                if (v == null) return;
                                final presentation = _getSexPresentation(
                                  ct.formatOption,
                                );
                                onUpdateCustomText(
                                  page1,
                                  ct.copyWith(formatOption: '$presentation:$v'),
                                );
                              },
                            ),
                          ],
                        ],
                        if (ct.textType == 'list' && isCustomSep) ...[
                          const SizedBox(width: 12),
                          Text(
                            'Separator',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              key: ValueKey('list-custom-separator-${ct.id}'),
                              controller: _separatorController,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (val) {
                                onUpdateCustomText(
                                  page1,
                                  ct.copyWith(formatOption: 'custom:$val'),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (_showStylingRow && !ct.isQrCode && !isPicture) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TextColorSwatch(
                          label: 'Text',
                          color: Color(ct.colorArgb),
                          pickerTitle: 'Select text color',
                          onPicked: (selectedColor) {
                            onUpdateCustomText(
                              page1,
                              ct.copyWith(colorArgb: selectedColor.toARGB32()),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _TextColorSwatch(
                          label: 'Background',
                          color: ct.backgroundColorArgb == null
                              ? Colors.transparent
                              : Color(ct.backgroundColorArgb!),
                          pickerTitle: 'Select text background color',
                          onPicked: (selectedColor) {
                            onUpdateCustomText(
                              page1,
                              ct.copyWith(
                                backgroundColorArgb: selectedColor.toARGB32(),
                              ),
                            );
                          },
                          onClear: () {
                            onUpdateCustomText(
                              page1,
                              ct.copyWith(clearBackgroundColor: true),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _TextColorSwatch(
                          label: 'Stroke',
                          color: ct.borderColorArgb == null
                              ? Colors.black
                              : Color(ct.borderColorArgb!),
                          pickerTitle: 'Select text stroke color',
                          onPicked: (selectedColor) {
                            onUpdateCustomText(
                              page1,
                              ct.copyWith(
                                borderColorArgb: selectedColor.toARGB32(),
                                borderWidthPt: ct.borderWidthPt <= 0
                                    ? 1.0
                                    : null,
                                borderStrokeStyle: ct.borderStrokeStyle,
                              ),
                            );
                          },
                          onClear: () {
                            onUpdateCustomText(
                              page1,
                              ct.copyWith(
                                clearBorderColor: true,
                                borderWidthPt: 0.0,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stroke',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 8),
                        _StrokeThicknessPicker(
                          value: ct.borderWidthPt,
                          onChanged: (v) {
                            onUpdateCustomText(
                              page1,
                              ct.copyWith(
                                borderWidthPt: v,
                                borderColorArgb:
                                    v > 0 && ct.borderColorArgb == null
                                    ? Colors.black.toARGB32()
                                    : null,
                                clearBorderColor: v == 0,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Style',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 8),
                        _StylePicker(
                          value: ct.borderStrokeStyle,
                          onChanged: (v) {
                            onUpdateCustomText(
                              page1,
                              ct.copyWith(
                                borderStrokeStyle: v,
                                borderWidthPt: ct.borderWidthPt <= 0
                                    ? 1.0
                                    : null,
                                borderColorArgb:
                                    ct.borderColorArgb ??
                                    Colors.black.toARGB32(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Radius',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        SizedBox(
                          width: 96,
                          child: widget.buildOptionSlider(
                            context,
                            value: ct.cornerRadiusPt.clamp(0.0, 24.0),
                            min: 0.0,
                            max: 24.0,
                            divisions: 24,
                            label: '${ct.cornerRadiusPt.toStringAsFixed(0)} pt',
                            onChanged: (v) {
                              onUpdateCustomText(
                                page1,
                                ct.copyWith(cornerRadiusPt: v),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Padding',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        SizedBox(
                          width: 96,
                          child: widget.buildOptionSlider(
                            context,
                            value: ct.paddingPt.clamp(0.0, 24.0),
                            min: 0.0,
                            max: 24.0,
                            divisions: 24,
                            label: '${ct.paddingPt.toStringAsFixed(0)} pt',
                            onChanged: (v) {
                              onUpdateCustomText(
                                page1,
                                ct.copyWith(paddingPt: v),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          widget.deleteButton,
        ],
      ),
    );
  }
}

class _TextAlignPicker extends StatelessWidget {
  const _TextAlignPicker({
    required this.ct,
    required this.page1,
    required this.onUpdateCustomText,
  });

  final CustomTextElement ct;
  final bool page1;
  final void Function(bool, CustomTextElement) onUpdateCustomText;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'left',
          icon: Icon(Icons.format_align_left, size: 20),
          tooltip: 'Align left',
        ),
        ButtonSegment(
          value: 'center',
          icon: Icon(Icons.format_align_center, size: 20),
          tooltip: 'Align center',
        ),
        ButtonSegment(
          value: 'right',
          icon: Icon(Icons.format_align_right, size: 20),
          tooltip: 'Align right',
        ),
      ],
      selected: {ct.textAlign},
      onSelectionChanged: (next) {
        if (next.isEmpty) return;
        onUpdateCustomText(page1, ct.copyWith(textAlign: next.first));
      },
      showSelectedIcon: false,
    );
  }
}

class _TextColorSwatch extends StatelessWidget {
  const _TextColorSwatch({
    required this.label,
    required this.color,
    required this.pickerTitle,
    required this.onPicked,
    this.onClear,
  });

  final String label;
  final Color color;
  final String pickerTitle;
  final ValueChanged<Color> onPicked;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(width: 8),
        TemplateColorSwatch(
          color: color,
          title: pickerTitle,
          showColorCode: true,
          enableCopyPaste: false,
          onPicked: onPicked,
        ),
        if (onClear != null)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Clear $label',
            onPressed: onClear,
          ),
      ],
    );
  }
}

class _NullFallbackContent extends StatefulWidget {
  const _NullFallbackContent({
    required this.text,
    required this.page1,
    required this.onUpdate,
  });

  final CustomTextElement text;
  final bool page1;
  final void Function(bool page1, CustomTextElement element) onUpdate;

  @override
  State<_NullFallbackContent> createState() => _NullFallbackContentState();
}

class _NullFallbackContentState extends State<_NullFallbackContent> {
  late String _nullFallbackOption;
  late TextEditingController _customTextController;

  @override
  void initState() {
    super.initState();
    _nullFallbackOption = widget.text.nullFallbackOption;
    _customTextController = TextEditingController(
      text: widget.text.customNullFallbackText,
    );
  }

  @override
  void dispose() {
    _customTextController.dispose();
    super.dispose();
  }

  void _onOptionChanged(String? val) {
    if (val == null) return;
    setState(() {
      _nullFallbackOption = val;
    });
    widget.onUpdate(
      widget.page1,
      widget.text.copyWith(nullFallbackOption: val),
    );
  }

  void _onTextChanged(String val) {
    widget.onUpdate(
      widget.page1,
      widget.text.copyWith(customNullFallbackText: val.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _nullFallbackOption,
          decoration: const InputDecoration(
            labelText: 'No Content Placeholder',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: kTemplateNullFallbackBlank,
              child: Text('Blank'),
            ),
            DropdownMenuItem(
              value: kTemplateNullFallbackField,
              child: Text('table::field'),
            ),
            DropdownMenuItem(
              value: kTemplateNullFallbackNa,
              child: Text('N/A'),
            ),
            DropdownMenuItem(
              value: kTemplateNullFallbackNone,
              child: Text('None'),
            ),
            DropdownMenuItem(
              value: kTemplateNullFallbackCustom,
              child: Text('Custom'),
            ),
          ],
          onChanged: _onOptionChanged,
        ),
        if (_nullFallbackOption == kTemplateNullFallbackCustom) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _customTextController,
            decoration: const InputDecoration(
              labelText: 'Custom Text',
              hintText: 'Enter custom fallback text',
              border: OutlineInputBorder(),
            ),
            onChanged: _onTextChanged,
          ),
        ],
      ],
    );
  }
}

class _NullFallbackDialog extends StatelessWidget {
  const _NullFallbackDialog({
    required this.text,
    required this.page1,
    required this.onUpdate,
  });

  final CustomTextElement text;
  final bool page1;
  final void Function(bool page1, CustomTextElement element) onUpdate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('No Content Placeholder'),
      content: SizedBox(
        width: 320.0,
        child: _NullFallbackContent(
          text: text,
          page1: page1,
          onUpdate: onUpdate,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _NullFallbackBottomSheet extends StatelessWidget {
  const _NullFallbackBottomSheet({
    required this.text,
    required this.page1,
    required this.onUpdate,
  });

  final CustomTextElement text;
  final bool page1;
  final void Function(bool page1, CustomTextElement element) onUpdate;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.0,
        8.0,
        16.0,
        media.viewInsets.bottom + 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'No Content Placeholder',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _NullFallbackContent(text: text, page1: page1, onUpdate: onUpdate),
        ],
      ),
    );
  }
}

class _NullFallbackControls extends StatelessWidget {
  const _NullFallbackControls({
    required this.text,
    required this.page1,
    required this.hasTextPlaceholder,
    required this.onUpdate,
  });

  final CustomTextElement text;
  final bool page1;
  final bool hasTextPlaceholder;
  final void Function(bool page1, CustomTextElement element) onUpdate;

  @override
  Widget build(BuildContext context) {
    if (!hasTextPlaceholder) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.pending_outlined, size: 24),
      tooltip: 'No Content Placeholder',
      onPressed: () {
        final isLargeScreen = MediaQuery.sizeOf(context).width > 600;
        if (isLargeScreen) {
          showDialog(
            context: context,
            builder: (context) => _NullFallbackDialog(
              text: text,
              page1: page1,
              onUpdate: onUpdate,
            ),
          );
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => _NullFallbackBottomSheet(
              text: text,
              page1: page1,
              onUpdate: onUpdate,
            ),
          );
        }
      },
    );
  }
}

class _StrokeThicknessPicker extends StatelessWidget {
  const _StrokeThicknessPicker({required this.value, required this.onChanged});

  static const values = [0.0, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0];

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<double>(
      value: values.contains(value) ? value : 0.0,
      isDense: true,
      underline: const SizedBox.shrink(),
      items: values
          .map(
            (thickness) => DropdownMenuItem(
              value: thickness,
              child: Text(thickness == 0.0 ? 'None' : '${thickness}pt'),
            ),
          )
          .toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}

class _StylePicker extends StatelessWidget {
  const _StylePicker({required this.value, required this.onChanged});

  static const values = ['solid', 'dashed', 'dotted', 'double'];

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return DropdownButton<String>(
      value: values.contains(value) ? value : 'solid',
      isDense: true,
      underline: const SizedBox.shrink(),
      items: [
        for (final val in values)
          DropdownMenuItem(
            value: val,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 20,
                  child: CustomPaint(
                    painter: _StylePreviewPainter(style: val, color: color),
                  ),
                ),
                const SizedBox(width: 12),
                Text(val[0].toUpperCase() + val.substring(1)),
              ],
            ),
          ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _StylePreviewPainter extends CustomPainter {
  const _StylePreviewPainter({required this.style, required this.color});

  final String style;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;

    if (style == 'solid') {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    } else if (style == 'dashed') {
      _drawDashedLine(canvas, size.width, y, paint, 6.0, 3.0);
    } else if (style == 'dotted') {
      _drawDashedLine(canvas, size.width, y, paint, 1.5, 3.0);
    } else if (style == 'double') {
      final paintDouble = Paint()
        ..color = color
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, y - 2), Offset(size.width, y - 2), paintDouble);
      canvas.drawLine(Offset(0, y + 2), Offset(size.width, y + 2), paintDouble);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    double width,
    double y,
    Paint paint,
    double dashLen,
    double gapLen,
  ) {
    double d = 0.0;
    while (d < width) {
      final end = (d + dashLen).clamp(0.0, width);
      canvas.drawLine(Offset(d, y), Offset(end, y), paint);
      d += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant _StylePreviewPainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.color != color;
  }
}

class _ConditionalBracketTextDialog extends StatefulWidget {
  const _ConditionalBracketTextDialog({
    required this.text,
    required this.fieldGroups,
  });

  final String text;
  final Map<String, List<String>> fieldGroups;

  @override
  State<_ConditionalBracketTextDialog> createState() =>
      _ConditionalBracketTextDialogState();
}

class _ConditionalBracketTextDialogState
    extends State<_ConditionalBracketTextDialog> {
  late final TextEditingController _targetController;
  late final TextEditingController _replacementController;
  late final List<_TemplateConditionDraft> _conditions;
  ConditionalBracketExpression? _existingExpression;
  ConditionalMatchMode _mode = ConditionalMatchMode.any;
  String _outputType = 'brackets';

  @override
  void initState() {
    super.initState();
    final expressions = conditionalBracketExpressionsInText(widget.text);
    final existing = expressions.isEmpty ? null : expressions.first;
    _existingExpression = existing;
    final fallbackTarget = RegExp(
      r'\[([^\[\]]+)\]',
    ).firstMatch(widget.text)?.group(1)?.trim().split('??').first.trim();
    _targetController = TextEditingController(
      text: existing?.targetField ?? fallbackTarget ?? '',
    );
    _replacementController = TextEditingController(
      text: existing?.replacementText ?? '',
    );
    _conditions =
        (existing?.conditions ??
                const [
                  ConditionalBracketCondition(
                    sourceField: '',
                    operator: ConditionalComparisonOperator.equals,
                    comparisonValue: '',
                  ),
                ])
            .map(_TemplateConditionDraft.fromCondition)
            .toList();
    if (existing != null) {
      _mode = existing.matchMode;
      if (existing.outputAction == ConditionalOutputAction.replacement) {
        final target = existing.targetField.trim().toLowerCase();
        _outputType =
            existing.conditions.every(
              (condition) =>
                  condition.sourceField.trim().toLowerCase() == target,
            )
            ? 'value'
            : 'field';
      }
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    _replacementController.dispose();
    for (final condition in _conditions) {
      condition.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = _targetController.text.trim();
    final valid =
        target.isNotEmpty &&
        _conditions.isNotEmpty &&
        _conditions.every(
          (condition) =>
              condition.valueController.text.trim().isNotEmpty &&
              (_outputType == 'value' ||
                  (condition.fieldController.text.trim().isNotEmpty &&
                      condition.fieldController.text.trim().toLowerCase() !=
                          target.toLowerCase())),
        ) &&
        (_outputType == 'brackets' || _replacementController.text.isNotEmpty);
    return AlertDialog(
      title: const Text('Conditional output'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _outputType,
                decoration: const InputDecoration(
                  labelText: 'Conditional type',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'brackets',
                    child: Text('Conditional brackets'),
                  ),
                  DropdownMenuItem(
                    value: 'field',
                    child: Text('Conditional field'),
                  ),
                  DropdownMenuItem(
                    value: 'value',
                    child: Text('Conditional value'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (_outputType == 'value' && value != 'value') {
                      for (final condition in _conditions) {
                        condition.fieldController.clear();
                      }
                    }
                    _outputType = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              InlineGroupedFieldPicker(
                value: target.isEmpty ? null : target,
                groups: _templateFieldGroupsWithValue(
                  widget.fieldGroups,
                  target,
                ),
                decoration: const InputDecoration(labelText: 'Target field'),
                onChanged: (value) {
                  _targetController.text = value;
                  _onTargetChanged(value);
                },
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < _conditions.length; index++)
                _TemplateConditionRow(
                  draft: _conditions[index],
                  targetField: _targetController.text,
                  fieldGroups: _templateFieldGroupsWithoutTarget(
                    widget.fieldGroups,
                    _targetController.text,
                  ),
                  showSourceField: _outputType != 'value',
                  onChanged: () => setState(() {}),
                  onRemove: _conditions.length == 1
                      ? null
                      : () => setState(() {
                          final removed = _conditions.removeAt(index);
                          removed.dispose();
                        }),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _conditions.add(_TemplateConditionDraft.empty());
                  }),
                  icon: const Icon(Icons.add),
                  label: const Text('Add condition'),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ConditionalMatchMode>(
                initialValue: _mode,
                decoration: const InputDecoration(labelText: 'Match logic'),
                items: const [
                  DropdownMenuItem(
                    value: ConditionalMatchMode.any,
                    child: Text('Any condition (OR)'),
                  ),
                  DropdownMenuItem(
                    value: ConditionalMatchMode.all,
                    child: Text('All conditions (AND)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _mode = value);
                },
              ),
              if (_outputType != 'brackets') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _replacementController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Replacement text',
                    helperText:
                        'Written when matched; otherwise the original target value is kept.',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: valid ? _save : null,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _save() {
    final target = _targetController.text.trim();
    final conditions = _conditions
        .map((condition) {
          final value = condition.toCondition();
          return _outputType == 'value'
              ? value.copyWith(sourceField: target)
              : value;
        })
        .toList(growable: false);
    final syntax = ConditionalBracketExpression(
      targetField: target,
      conditions: conditions,
      matchMode: _mode,
      start: 0,
      end: 0,
      outputAction: _outputType == 'brackets'
          ? ConditionalOutputAction.brackets
          : ConditionalOutputAction.replacement,
      replacementText: _replacementController.text,
    ).toTemplateSyntax();
    final existing = _existingExpression;
    if (existing != null) {
      Navigator.pop(
        context,
        widget.text.replaceRange(existing.start, existing.end, syntax),
      );
      return;
    }
    final placeholder = '[$target]';
    Navigator.pop(
      context,
      widget.text.contains(placeholder)
          ? widget.text.replaceFirst(placeholder, syntax)
          : '${widget.text}$syntax',
    );
  }

  void _onTargetChanged(String targetField) {
    for (final condition in _conditions) {
      condition.apply(
        conditionalBracketConditionForSource(
          condition.toCondition(),
          sourceField: condition.fieldController.text.trim(),
          targetField: targetField,
        ),
      );
    }
    setState(() {});
  }
}

class _TemplateConditionDraft {
  _TemplateConditionDraft({
    required String sourceField,
    required this.operator,
    required String comparisonValue,
  }) : fieldController = TextEditingController(text: sourceField),
       valueController = TextEditingController(text: comparisonValue);

  factory _TemplateConditionDraft.empty() => _TemplateConditionDraft(
    sourceField: '',
    operator: ConditionalComparisonOperator.equals,
    comparisonValue: '',
  );

  factory _TemplateConditionDraft.fromCondition(
    ConditionalBracketCondition condition,
  ) => _TemplateConditionDraft(
    sourceField: condition.sourceField,
    operator: condition.operator,
    comparisonValue: condition.comparisonValue,
  );

  final TextEditingController fieldController;
  final TextEditingController valueController;
  ConditionalComparisonOperator operator;

  bool get isValid =>
      fieldController.text.trim().isNotEmpty &&
      valueController.text.trim().isNotEmpty;

  ConditionalBracketCondition toCondition() => ConditionalBracketCondition(
    sourceField: fieldController.text.trim(),
    operator: operator,
    comparisonValue: valueController.text.trim(),
  );

  void apply(ConditionalBracketCondition condition) {
    fieldController.text = condition.sourceField;
    operator = condition.operator;
    valueController.text = condition.comparisonValue;
  }

  void dispose() {
    fieldController.dispose();
    valueController.dispose();
  }
}

class _TemplateConditionRow extends StatelessWidget {
  const _TemplateConditionRow({
    required this.draft,
    required this.targetField,
    required this.fieldGroups,
    required this.showSourceField,
    required this.onChanged,
    required this.onRemove,
  });

  final _TemplateConditionDraft draft;
  final String targetField;
  final Map<String, List<String>> fieldGroups;
  final bool showSourceField;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          if (showSourceField) ...[
            InlineGroupedFieldPicker(
              value: draft.fieldController.text.trim().isEmpty
                  ? null
                  : draft.fieldController.text.trim(),
              groups: _templateFieldGroupsWithValue(
                fieldGroups,
                draft.fieldController.text,
              ),
              decoration: const InputDecoration(labelText: 'Controlling field'),
              onChanged: (sourceField) {
                draft.apply(
                  conditionalBracketConditionForSource(
                    draft.toCondition(),
                    sourceField: sourceField,
                    targetField: targetField,
                  ),
                );
                onChanged();
              },
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              DropdownButton<ConditionalComparisonOperator>(
                value: draft.operator,
                items: const [
                  DropdownMenuItem(
                    value: ConditionalComparisonOperator.equals,
                    child: Text('Equals'),
                  ),
                  DropdownMenuItem(
                    value: ConditionalComparisonOperator.notEquals,
                    child: Text('Does not equal'),
                  ),
                  DropdownMenuItem(
                    value: ConditionalComparisonOperator.contains,
                    child: Text('Contains'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    draft.operator = value;
                    onChanged();
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: draft.valueController,
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(labelText: 'Value'),
                ),
              ),
              IconButton(
                tooltip: 'Remove condition',
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Map<String, List<String>> _templateFieldGroupsWithValue(
  Map<String, List<String>> groups,
  String? value,
) {
  final result = {
    for (final entry in groups.entries)
      entry.key: List<String>.from(entry.value),
  };
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty ||
      result.values.any((fields) => fields.contains(normalized))) {
    return result;
  }
  final table = _templateFieldTableName(normalized);
  result.putIfAbsent(table, () => <String>[]).add(normalized);
  return result;
}

Map<String, List<String>> _templateFieldGroupsWithoutTarget(
  Map<String, List<String>> groups,
  String targetField,
) {
  final normalized = targetField.trim().toLowerCase();
  if (normalized.isEmpty || !normalized.contains('::')) return groups;
  return {
    for (final entry in groups.entries)
      if (entry.value.any((field) => field.toLowerCase() != normalized))
        entry.key: entry.value
            .where((field) => field.toLowerCase() != normalized)
            .toList(growable: false),
  };
}

String _templateFieldTableName(String value) {
  final separator = value.indexOf('::');
  return separator == -1 ? 'Other fields' : value.substring(0, separator);
}

String? _detectPlaceholderKey(String text) {
  final match = RegExp(r'\[([^\]]+)\]').firstMatch(text);
  if (match != null) {
    return match.group(1)!.trim().split('??').first.trim();
  }
  return null;
}

Map<String, String> _getDefaultEnumMapForPlaceholder(String key) {
  final cleanKey = key.trim().toLowerCase();
  if (cleanKey.endsWith('::sex')) {
    return {'0': 'Male', '1': 'Female', '2': 'Unknown'};
  } else if (cleanKey == 'mammalattribute::age' ||
      cleanKey == 'mammalmeasurement::age') {
    return {'0': 'Adult', '1': 'Subadult', '2': 'Juvenile', '3': 'Unknown'};
  } else if (cleanKey == 'herpattribute::age' ||
      cleanKey == 'herpmeasurement::age') {
    return {
      '0': 'Adult',
      '1': 'Juvenile',
      '2': 'Neonate',
      '3': 'Metamorph',
      '4': 'Unknown',
    };
  } else if (cleanKey.endsWith('::testisposition')) {
    return {'0': 'Scrotal', '1': 'Abdominal'};
  } else if (cleanKey.endsWith('::epididymisappearance')) {
    return {'0': 'Tubular', '1': 'Partial', '2': 'Not Tubular'};
  } else if (cleanKey.endsWith('::vaginaopening')) {
    return {'0': 'Imperforate', '1': 'Perforate'};
  } else if (cleanKey.endsWith('::pubicsymphysis')) {
    return {'0': 'Close', '1': 'Small Open', '2': 'Open'};
  } else if (cleanKey.endsWith('::reproductivestage')) {
    return {'0': 'Nulliparous', '1': 'Primiparous', '2': 'Multiparous'};
  } else if (cleanKey.endsWith('::mammaecondition')) {
    return {'0': 'Small', '1': 'Large', '2': 'Lactating'};
  } else if (cleanKey.endsWith('::ovaryappearance')) {
    return birdLabelsByIndex(ovaryAppearanceList);
  } else if (cleanKey.endsWith('::oviductappearance')) {
    return birdLabelsByIndex(oviductAppearanceList);
  } else if (cleanKey.endsWith('::fat')) {
    return birdLabelsByIndex(fatCategoryList);
  } else if (cleanKey.endsWith('::bodymolt')) {
    return birdLabelsByIndex(bodyMoltList);
  } else if (cleanKey.endsWith('::echolocation')) {
    return {'0': 'FM', '1': 'CF', '2': 'QCF', '3': 'None'};
  } else if (cleanKey.endsWith('::broodpatch') ||
      cleanKey.endsWith('::hasbursa') ||
      cleanKey.endsWith('::wingismolt') ||
      cleanKey.endsWith('::tailismolt') ||
      cleanKey.endsWith('::showbatfields') ||
      cleanKey.endsWith('::showechofields')) {
    return {'0': 'No', '1': 'Yes'};
  }
  return {};
}
