import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/styles/design_tokens.dart';

class ExportProgressPanel extends StatefulWidget {
  const ExportProgressPanel({
    super.key,
    required this.title,
    required this.progress,
    this.hint,
    this.onCancel,
    this.isCancelling = false,
  });

  final String title;
  final ExportJobProgress progress;

  final String? hint;

  final VoidCallback? onCancel;
  final bool isCancelling;

  @override
  State<ExportProgressPanel> createState() => _ExportProgressPanelState();
}

class _ExportProgressPanelState extends State<ExportProgressPanel> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.progress;
    final fraction = progress.overallFraction;
    final currentItem = progress.detail.currentItem;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: NahpuSpacing.xl),
          ExportPhaseStepper(progress: progress),
          const SizedBox(height: NahpuSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(NahpuRadius.xs),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: NahpuSpacing.md,
                  ),
                ),
              ),
              if (fraction != null) ...[
                const SizedBox(width: NahpuSpacing.lg),
                Text(
                  '${(fraction * 100).round()}%',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ],
          ),
          const SizedBox(height: NahpuSpacing.lg),
          Text(_statusLine(), style: theme.textTheme.bodyMedium),
          if (progress.estimatedRemaining != null)
            Padding(
              padding: const EdgeInsets.only(top: NahpuSpacing.xs),
              child: Text(
                'about ${formatExportDuration(progress.estimatedRemaining!)} left',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (currentItem != null && currentItem.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: NahpuSpacing.sm),
              child: Text(
                currentItem,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (widget.hint != null) ...[
            const SizedBox(height: NahpuSpacing.xl),
            Text(
              widget.hint!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (widget.onCancel != null) ...[
            const SizedBox(height: NahpuSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.isCancelling ? null : widget.onCancel,
                child: Text(widget.isCancelling ? 'Cancelling…' : 'Cancel'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLine() {
    final detail = widget.progress.detail;
    final parts = <String>[];
    if (detail.totalUnits > 0) {
      parts.add('${detail.completedUnits} of ${detail.totalUnits} files');
    } else if (detail.completedUnits > 0) {
      parts.add('${detail.completedUnits} files');
    }
    if (detail.totalBytes > 0) {
      parts.add(
        '${formatByteSize(detail.bytesProcessed)} '
        'of ${formatByteSize(detail.totalBytes)}',
      );
    } else if (detail.bytesProcessed > 0) {
      parts.add(formatByteSize(detail.bytesProcessed));
    }
    parts.add('${formatExportDuration(_stopwatch.elapsed)} elapsed');
    return parts.join(' · ');
  }
}

class ExportPhaseStepper extends StatelessWidget {
  const ExportPhaseStepper({super.key, required this.progress});

  final ExportJobProgress progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < progress.steps.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: NahpuSpacing.md),
            child: _ExportPhaseTile(
              label: progress.steps[index].label,
              isComplete: progress.isComplete(index),
              isActive: progress.isActive(index),
              trailing: progress.isActive(index) ? _trailing() : null,
            ),
          ),
      ],
    );
  }

  String? _trailing() {
    final detail = progress.detail;
    if (detail.totalUnits > 0) {
      return '${detail.completedUnits} of ${detail.totalUnits}';
    }
    if (detail.completedUnits > 0) return '${detail.completedUnits}';
    return null;
  }
}

class _ExportPhaseTile extends StatelessWidget {
  const _ExportPhaseTile({
    required this.label,
    required this.isComplete,
    required this.isActive,
    this.trailing,
  });

  final String label;
  final bool isComplete;
  final bool isActive;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingColor = theme.colorScheme.onSurfaceVariant.withAlpha(140);
    return Row(
      children: [
        SizedBox.square(
          dimension: NahpuControlSize.iconMedium,
          child: _leading(theme, pendingColor),
        ),
        const SizedBox(width: NahpuSpacing.lg),
        Expanded(
          child: Text(
            label,
            style: isActive
                ? theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    color: isComplete ? null : pendingColor,
                  ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _leading(ThemeData theme, Color pendingColor) {
    if (isComplete) {
      return Icon(
        Icons.check_circle_rounded,
        size: NahpuControlSize.iconMedium,
        color: theme.colorScheme.primary,
      );
    }
    if (isActive) {
      return const Padding(
        padding: EdgeInsets.all(NahpuSpacing.xxs),
        child: CircularProgressIndicator(strokeWidth: NahpuStroke.regular),
      );
    }
    return Icon(
      Icons.circle_outlined,
      size: NahpuControlSize.iconMedium,
      color: pendingColor,
    );
  }
}

class ExportFailurePanel extends StatelessWidget {
  const ExportFailurePanel({
    super.key,
    required this.outcome,
    this.errorMessage,
    this.failedStepLabel,
    this.onRetry,
  });

  final ExportOutcome outcome;

  final String? errorMessage;
  final String? failedStepLabel;

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _icon(),
                color: _iconColor(theme),
                size: NahpuControlSize.icon,
              ),
              const SizedBox(width: NahpuSpacing.lg),
              Expanded(
                child: Text(_title(), style: theme.textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: NahpuSpacing.xl),
          ..._body(theme),
          if (onRetry != null) ...[
            const SizedBox(height: NahpuSpacing.xl),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _body(ThemeData theme) {
    if (outcome == ExportOutcome.cancelled) {
      return [
        Text(
          'No file was saved. Nothing on this device was changed.',
          style: theme.textTheme.bodyMedium,
        ),
      ];
    }
    return [
      if (failedStepLabel != null)
        Padding(
          padding: const EdgeInsets.only(bottom: NahpuSpacing.md),
          child: Text(
            'Stopped while working on: $failedStepLabel',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ErrorText(error: errorMessage ?? 'The export did not finish.'),
    ];
  }

  String _title() =>
      outcome == ExportOutcome.cancelled ? 'Export cancelled' : 'Export failed';

  IconData _icon() => outcome == ExportOutcome.cancelled
      ? Icons.cancel_outlined
      : Icons.error_outline_rounded;

  Color _iconColor(ThemeData theme) => outcome == ExportOutcome.cancelled
      ? theme.colorScheme.onSurfaceVariant
      : theme.colorScheme.error;
}
