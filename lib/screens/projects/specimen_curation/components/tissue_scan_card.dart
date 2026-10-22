import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Takes scanned codes. Keyboard-wedge scanners type into the field and end
/// with Enter; the camera button opens a continuous camera scanner.
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
            Text('Scan tube', style: theme.textTheme.titleSmall),
            const SizedBox(height: NahpuSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('tissue-scan-input'),
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Barcode or tissue ID',
                      hintText: 'Scan or type, then press Enter',
                      prefixIcon: Icon(Icons.qr_code_scanner),
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
                    tooltip: 'Scan with camera',
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
                  label: const Text('Undo'),
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
              outcome?.message ?? 'Ready. Scan the first tube.',
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
