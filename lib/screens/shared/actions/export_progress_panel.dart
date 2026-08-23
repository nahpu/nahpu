import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as p;

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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xxl),
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

  /// Counts for the running stage, shown beside its label.
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

class ExportResultPanel extends StatelessWidget {
  const ExportResultPanel({
    super.key,
    required this.outcome,
    required this.successTitle,
    this.output,
    this.outputBytes,
    this.duration,
    this.errorMessage,
    this.failedStepLabel,
    this.onRetry,
  });

  final ExportOutcome outcome;

  final String successTitle;

  final File? output;
  final int? outputBytes;
  final Duration? duration;
  final String? errorMessage;

  final String? failedStepLabel;

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xxl),
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
            // Share and the saved path belong to the location card above the
            // export button, so a finished job states its result once.
            if (outcome != ExportOutcome.succeeded && onRetry != null) ...[
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
      ),
    );
  }

  List<Widget> _body(ThemeData theme) {
    switch (outcome) {
      case ExportOutcome.succeeded:
        return [
          if (output != null)
            Text(
              p.basename(output!.path),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          if (_sizeAndDuration() != null)
            Padding(
              padding: const EdgeInsets.only(top: NahpuSpacing.xs),
              child: Text(
                _sizeAndDuration()!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ];
      case ExportOutcome.cancelled:
        return [
          Text(
            'No file was saved. Nothing on this device was changed.',
            style: theme.textTheme.bodyMedium,
          ),
        ];
      case ExportOutcome.failed:
      case ExportOutcome.running:
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
  }

  String? _sizeAndDuration() {
    final bytes = outputBytes;
    final elapsed = duration;
    if (bytes == null && elapsed == null) return null;
    if (bytes == null) return 'Finished in ${formatExportDuration(elapsed!)}';
    if (elapsed == null) return formatByteSize(bytes);
    return '${formatByteSize(bytes)} in ${formatExportDuration(elapsed)}';
  }

  String _title() => switch (outcome) {
    ExportOutcome.succeeded => successTitle,
    ExportOutcome.cancelled => 'Export cancelled',
    ExportOutcome.failed || ExportOutcome.running => 'Export failed',
  };

  IconData _icon() => switch (outcome) {
    ExportOutcome.succeeded => Icons.check_circle_rounded,
    ExportOutcome.cancelled => Icons.cancel_outlined,
    ExportOutcome.failed ||
    ExportOutcome.running => Icons.error_outline_rounded,
  };

  Color _iconColor(ThemeData theme) => switch (outcome) {
    ExportOutcome.succeeded => theme.colorScheme.primary,
    ExportOutcome.cancelled => theme.colorScheme.onSurfaceVariant,
    ExportOutcome.failed || ExportOutcome.running => theme.colorScheme.error,
  };
}
