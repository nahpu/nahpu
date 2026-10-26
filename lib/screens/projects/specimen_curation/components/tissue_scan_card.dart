import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimen_curation/specimen_curation_mode.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/specimen_curation/tissue_entry.dart';
import 'package:nahpu/services/localization/type_labels.dart';

/// Takes scanned codes, or shows the work list. Keyboard-wedge scanners
/// type into the field and end with Enter; the camera button opens a
/// continuous camera scanner.
class TissueScanCard extends StatefulWidget {
  const TissueScanCard({
    super.key,
    required this.outcome,
    required this.isBusy,
    required this.canUndo,
    required this.onScan,
    required this.onUndo,
    this.autofocus = false,
    this.onOpenCamera,
    this.identifyBy = TissueIdentifyBy.tissueId,
    this.onIdentifyByChanged,
    this.suggestions = const [],
    this.includeParasites = false,
    this.entryMode = TissueEntryMode.scan,
    this.onEntryModeChanged,
    this.workList,
    this.suggestionsAbove = false,
    this.framed = true,
  });

  final TissueScanOutcome? outcome;
  final bool isBusy;
  final bool canUndo;
  final Future<void> Function(String code) onScan;
  final VoidCallback onUndo;

  /// Focuses the field on open. Off on phones, where the soft keyboard
  /// would cover the box until the user taps the field.
  final bool autofocus;

  /// Null hides the camera button on platforms without camera scanning.
  final VoidCallback? onOpenCamera;

  /// Sets the field's label and hint.
  final TissueIdentifyBy identifyBy;

  /// Codes offered while typing, for the current identify mode.
  final List<String> suggestions;

  /// Null hides the Search by field ID toggle.
  final ValueChanged<TissueIdentifyBy>? onIdentifyByChanged;

  /// Names parasite IDs in the field's label.
  final bool includeParasites;

  final TissueEntryMode entryMode;

  /// Null hides the Scan and Work list toggle.
  final ValueChanged<TissueEntryMode>? onEntryModeChanged;

  /// Shown in place of the scan field in work list mode.
  final Widget? workList;

  /// Opens code suggestions above the field, as when the card is pinned to
  /// the bottom of a phone screen.
  final bool suggestionsAbove;

  /// False drops the card and its padding, as in the phone scan dock that
  /// already sets it apart.
  final bool framed;

  @override
  State<TissueScanCard> createState() => _TissueScanCardState();
}

class _TissueScanCardState extends State<TissueScanCard> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onEntryModeChanged == null)
          Text(
            context.l10n.projectTissueScanTube,
            style: theme.textTheme.titleSmall,
          )
        else
          SegmentedButton<TissueEntryMode>(
            segments: [
              for (final mode in TissueEntryMode.values)
                ButtonSegment(
                  value: mode,
                  label: Text(mode.localizedLabel(context.l10n)),
                ),
            ],
            selected: {widget.entryMode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                widget.onEntryModeChanged!(selection.first),
          ),
        const SizedBox(height: NahpuSpacing.lg),
        if (widget.entryMode == TissueEntryMode.workList &&
            widget.workList != null)
          widget.workList!
        else ...[
          if (widget.onIdentifyByChanged != null)
            SwitchListTile(
              key: const ValueKey('tissue-search-by-field-id'),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.projectTissueSearchByFieldId),
              value: widget.identifyBy == TissueIdentifyBy.fieldId,
              onChanged: (byFieldId) => widget.onIdentifyByChanged!(
                byFieldId
                    ? TissueIdentifyBy.fieldId
                    : TissueIdentifyBy.tissueId,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: RawAutocomplete<String>(
                  textEditingController: _controller,
                  focusNode: _focusNode,
                  optionsBuilder: (value) =>
                      suggestTissueCodes(widget.suggestions, value.text),
                  onSelected: _submit,
                  optionsViewOpenDirection: widget.suggestionsAbove
                      ? OptionsViewOpenDirection.up
                      : OptionsViewOpenDirection.down,
                  optionsViewBuilder: (context, onSelected, options) =>
                      TissueCodeSuggestions(
                        options: options.toList(),
                        onSelected: onSelected,
                        alignment: widget.suggestionsAbove
                            ? Alignment.bottomLeft
                            : Alignment.topLeft,
                      ),
                  fieldViewBuilder:
                      (
                        context,
                        controller,
                        focusNode,
                        onFieldSubmitted,
                      ) => TextField(
                        key: const ValueKey('tissue-scan-input'),
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: widget.autofocus,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: widget.identifyBy.localizedScanLabel(
                            context.l10n,
                            includeParasites: widget.includeParasites,
                          ),
                          hintText: switch (widget.identifyBy) {
                            TissueIdentifyBy.tissueId =>
                              context.l10n.projectTissueScanHint,
                            TissueIdentifyBy.fieldId => 'ABC123 liver etoh',
                          },
                          prefixIcon: const Icon(Icons.qr_code_scanner),
                        ),
                        // Enter scans the typed text as is, so a scanner's
                        // code is never swapped for a suggestion.
                        onSubmitted: _submit,
                        // Keeps focus on Enter, so back-to-back scans are not
                        // lost while the field would refocus.
                        onEditingComplete: () {},
                      ),
                ),
              ),
              if (widget.onOpenCamera != null) ...[
                const SizedBox(width: NahpuSpacing.md),
                IconButton.outlined(
                  tooltip: context.l10n.projectTissueScanWithCamera,
                  onPressed: widget.onOpenCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: NahpuSpacing.md),
        Row(
          children: [
            Expanded(child: TissueScanFeedback(outcome: widget.outcome)),
            if (widget.isBusy)
              const SizedBox.square(
                dimension: NahpuControlSize.iconSmall,
                child: CircularProgressIndicator(
                  strokeWidth: NahpuStroke.regular,
                ),
              ),
            TextButton.icon(
              onPressed: widget.canUndo ? widget.onUndo : null,
              icon: const Icon(Icons.undo),
              label: Text(context.l10n.projectTissueUndo),
            ),
          ],
        ),
      ],
    );
    if (!widget.framed) return content;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: content,
      ),
    );
  }

  Future<void> _submit(String text) async {
    _controller.clear();
    _focusNode.requestFocus();
    await widget.onScan(text);
    if (mounted) _focusNode.requestFocus();
  }
}

/// Codes matching the typed text, below the scan field. Picking one scans
/// it.
class TissueCodeSuggestions extends StatelessWidget {
  const TissueCodeSuggestions({
    super.key,
    required this.options,
    required this.onSelected,
    this.alignment = Alignment.topLeft,
  });

  /// Shown rows before the list scrolls.
  static const int visibleCount = 6;

  final List<String> options;
  final ValueChanged<String> onSelected;

  /// Bottom left when the list opens above the field.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final highlighted = AutocompleteHighlightedOption.of(context);
    return Align(
      alignment: alignment,
      child: Material(
        elevation: NahpuElevation.medium,
        borderRadius: BorderRadius.circular(NahpuRadius.sm),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: NahpuControlSize.touchTarget * visibleCount,
          ),
          child: ListView.builder(
            key: const ValueKey('tissue-scan-suggestions'),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) => ListTile(
              dense: true,
              selected: index == highlighted,
              leading: const Icon(Icons.qr_code_2),
              title: Text(options[index]),
              onTap: () => onSelected(options[index]),
            ),
          ),
        ),
      ),
    );
  }
}

/// The result of the last scan, announced to screen readers.
class TissueScanFeedback extends StatelessWidget {
  const TissueScanFeedback({super.key, required this.outcome});

  final TissueScanOutcome? outcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = outcome?.status;
    final (icon, color) = switch (status) {
      null => (Icons.info_outline, theme.colorScheme.onSurfaceVariant),
      TissueScanStatus.checked => (
        Icons.check_circle_outline,
        theme.colorScheme.primary,
      ),
      TissueScanStatus.undone => (
        Icons.undo,
        theme.colorScheme.onSurfaceVariant,
      ),
      _ when status.isError => (Icons.error_outline, theme.colorScheme.error),
      _ => (
        Icons.warning_amber_outlined,
        NahpuTheme.warningText(theme.colorScheme),
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Icon(icon, size: NahpuControlSize.iconSmall, color: color),
          const SizedBox(width: NahpuSpacing.sm),
          Expanded(
            child: Text(
              outcome?.message ?? context.l10n.projectTissueReady,
              key: const ValueKey('tissue-scan-feedback'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
