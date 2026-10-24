import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimen_curation/specimen_curation_mode.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';
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
    this.entryMode = TissueEntryMode.scan,
    this.onEntryModeChanged,
    this.workList,
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

  final TissueEntryMode entryMode;

  /// Null hides the Scan and Work list toggle.
  final ValueChanged<TissueEntryMode>? onEntryModeChanged;

  /// Shown in place of the scan field in work list mode.
  final Widget? workList;

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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Column(
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
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('tissue-scan-input'),
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: widget.autofocus,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: widget.identifyBy.localizedLabel(
                          context.l10n,
                        ),
                        hintText: switch (widget.identifyBy) {
                          TissueIdentifyBy.tissueId =>
                            context.l10n.projectTissueScanHint,
                          TissueIdentifyBy.fieldId => 'ABC123 liver etoh',
                        },
                        prefixIcon: const Icon(Icons.qr_code_scanner),
                      ),
                      onSubmitted: _submit,
                      // Keeps focus on Enter, so back-to-back scans are not
                      // lost while the field would refocus.
                      onEditingComplete: () {},
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
        ),
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
      _ => (Icons.warning_amber_outlined, theme.colorScheme.tertiary),
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
