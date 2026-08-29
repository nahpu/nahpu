//! This file contains the progress model shared by long-running exports and backups.
import 'package:flutter/foundation.dart';

/// A stage of a long-running export, backup, or restore.
///
/// A flow uses only the stages that apply to it; the panel renders whichever
/// [ExportPhaseStep] list the flow declares.
enum ExportPhase {
  preparing,
  collecting,
  copyingFiles,
  compressing,
  extracting,
  verifying,
  finalizing,
}

/// One stage of a job, with the share of the total work it represents.
@immutable
class ExportPhaseStep {
  const ExportPhaseStep({
    required this.phase,
    required this.label,
    this.weight = 1,
  });

  final ExportPhase phase;

  /// Wording shown in the stepper, phrased for the flow that declared it.
  final String label;

  /// Relative share of the whole job. Weights are normalized, not percentages.
  ///
  /// Copying and compressing move the same bytes, so they carry equal weight by
  /// default and the bar does not lurch when a two-file stage finishes.
  final double weight;
}

/// How far along the active stage is, when it can say.
@immutable
class ExportPhaseDetail {
  const ExportPhaseDetail({
    this.completedUnits = 0,
    this.totalUnits = 0,
    this.bytesProcessed = 0,
    this.totalBytes = 0,
    this.currentItem,
    this.indeterminate = false,
  });

  /// Items finished in this stage, usually files.
  final int completedUnits;

  /// Items this stage expects to process, or `0` when the count is unknown.
  final int totalUnits;

  final int bytesProcessed;

  /// Bytes this stage expects to process, or `0` when the size is unknown.
  final int totalBytes;

  /// Name of the file being processed, shown so a long stage looks alive.
  final String? currentItem;

  /// Whether this stage cannot say how far along it is.
  ///
  /// A stage that hands its work to one opaque call still knows what it handed
  /// over, so the totals stay set for display while [fraction] stays `null`.
  final bool indeterminate;

  ExportPhaseDetail copyWith({
    int? completedUnits,
    int? totalUnits,
    int? bytesProcessed,
    int? totalBytes,
    String? currentItem,
    bool? indeterminate,
  }) => ExportPhaseDetail(
    completedUnits: completedUnits ?? this.completedUnits,
    totalUnits: totalUnits ?? this.totalUnits,
    bytesProcessed: bytesProcessed ?? this.bytesProcessed,
    totalBytes: totalBytes ?? this.totalBytes,
    currentItem: currentItem ?? this.currentItem,
    indeterminate: indeterminate ?? this.indeterminate,
  );

  /// Share of this stage that is complete, or `null` when it cannot be known.
  ///
  /// Bytes are preferred over item counts because files vary hugely in size.
  double? get fraction {
    if (indeterminate) return null;
    if (totalBytes > 0) return (bytesProcessed / totalBytes).clamp(0.0, 1.0);
    if (totalUnits > 0) return (completedUnits / totalUnits).clamp(0.0, 1.0);
    return null;
  }
}

/// How a job finished.
enum ExportOutcome { running, succeeded, cancelled, failed }

/// An immutable snapshot of a job, rendered directly by the progress panel.
@immutable
class ExportJobProgress {
  const ExportJobProgress({
    required this.steps,
    required this.activeIndex,
    required this.detail,
    required this.elapsed,
    required this.overallFraction,
    required this.estimatedRemaining,
    this.outcome = ExportOutcome.running,
  });

  /// A snapshot for a job that has been described but has not started.
  factory ExportJobProgress.pending(List<ExportPhaseStep> steps) =>
      ExportJobProgress(
        steps: steps,
        activeIndex: -1,
        detail: const ExportPhaseDetail(),
        elapsed: Duration.zero,
        overallFraction: 0,
        estimatedRemaining: null,
      );

  final List<ExportPhaseStep> steps;

  /// Index into [steps] of the running stage, or `steps.length` once finished.
  final int activeIndex;

  final ExportPhaseDetail detail;
  final Duration elapsed;

  /// Share of the whole job complete, or `null` while a stage cannot report.
  final double? overallFraction;

  /// Smoothed estimate, withheld until it is stable enough to be worth showing.
  final Duration? estimatedRemaining;

  final ExportOutcome outcome;

  ExportPhaseStep? get activeStep =>
      activeIndex >= 0 && activeIndex < steps.length
      ? steps[activeIndex]
      : null;

  bool isComplete(int index) => index < activeIndex;
  bool isActive(int index) => index == activeIndex;
}

/// Formats [bytes] for display, as `1.8 GB` or `640 MB`.
///
/// Sizes below a megabyte round to whole units, since a decimal on `12 KB`
/// reads as noise next to a gigabyte-scale total.
String formatByteSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit += 1;
  }
  final decimals = value >= 100 || unit == 0 ? 0 : 1;
  return '${value.toStringAsFixed(decimals)} ${units[unit]}';
}

/// Formats [duration] as coarse, readable time, such as `3 min 42 s`.
String formatExportDuration(Duration duration) {
  final seconds = duration.inSeconds;
  if (seconds < 60) return '$seconds s';
  if (seconds < 3600) {
    final remainder = seconds % 60;
    return remainder == 0
        ? '${seconds ~/ 60} min'
        : '${seconds ~/ 60} min $remainder s';
  }
  final minutes = (seconds % 3600) ~/ 60;
  return minutes == 0
      ? '${seconds ~/ 3600} hr'
      : '${seconds ~/ 3600} hr $minutes min';
}
