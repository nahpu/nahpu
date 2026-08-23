//! This file contains the progress reporting and cancellation used by long exports.
import 'dart:async';

import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/src/rust/api/archive.dart';

/// Shortest gap between progress emissions.
///
/// A twenty-thousand file copy would otherwise rebuild the panel twenty thousand
/// times, which costs more than the copy itself.
const Duration exportProgressInterval = Duration(milliseconds: 100);

const Duration _minElapsedForEstimate = Duration(seconds: 5);
const double _minFractionForEstimate = 0.1;
const double _estimateSmoothing = 0.25;

/// Estimates beyond a day say nothing useful, so they are withheld entirely.
const int _maxEstimateSeconds = 24 * 60 * 60;

/// Thrown when a job stops because the user cancelled it.
class ExportCancelledException implements Exception {
  const ExportCancelledException();

  @override
  String toString() => 'Export cancelled';
}

/// A cancellation flag shared between the screen and the service doing the work.
///
/// Compression runs inside Rust and cannot be interrupted once it starts, so a
/// cancel takes effect at the next checkpoint rather than immediately.
class ExportCancellation {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() => _isCancelled = true;

  /// Aborts the job when a cancel is pending. Call between files and stages.
  void throwIfCancelled() {
    if (_isCancelled) throw const ExportCancelledException();
  }
}

/// Collects progress from a running job and publishes throttled snapshots.
///
/// Services report into this; the screen listens to [stream]. Passing one is
/// optional everywhere so callers that do not show progress stay unchanged.
class ExportProgressReporter {
  ExportProgressReporter({
    required List<ExportPhaseStep> steps,
    Duration Function()? elapsed,
  }) : steps = List.unmodifiable(steps),
       _elapsedOverride = elapsed,
       _stopwatch = elapsed == null ? (Stopwatch()..start()) : null;

  final List<ExportPhaseStep> steps;
  final Duration Function()? _elapsedOverride;
  final Stopwatch? _stopwatch;
  final StreamController<ExportJobProgress> _controller =
      StreamController<ExportJobProgress>.broadcast();

  int _activeIndex = -1;
  ExportPhaseDetail _detail = const ExportPhaseDetail();
  ExportOutcome _outcome = ExportOutcome.running;
  Duration _lastEmit = Duration.zero;
  bool _hasEmitted = false;
  double? _smoothedRate;
  double _lastFraction = 0;
  Duration _lastRateSample = Duration.zero;

  Stream<ExportJobProgress> get stream => _controller.stream;

  Duration get elapsed => _elapsedOverride?.call() ?? _stopwatch!.elapsed;

  /// Starts [phase] and sets the totals it expects to process.
  ///
  /// Pass `0` for a total that cannot be known; the stage then reports an
  /// indeterminate bar rather than a misleading percentage.
  void beginPhase(
    ExportPhase phase, {
    int totalUnits = 0,
    int totalBytes = 0,
    bool indeterminate = false,
  }) {
    final index = steps.indexWhere((step) => step.phase == phase);
    assert(index >= 0, 'Phase $phase is not part of this job.');
    if (index < 0) return;
    _activeIndex = index;
    _detail = ExportPhaseDetail(totalUnits: totalUnits, totalBytes: totalBytes);
    _emit(force: true);
  }

  /// Records one finished item in the active stage.
  void advanceItem({String? currentItem, int bytes = 0}) {
    _detail = _detail.copyWith(
      completedUnits: _detail.completedUnits + 1,
      bytesProcessed: _detail.bytesProcessed + bytes,
      currentItem: currentItem,
    );
    _emit();
  }

  /// Names the item the active stage is working on now.
  void setCurrentItem(String? item) {
    _detail = ExportPhaseDetail(
      completedUnits: _detail.completedUnits,
      totalUnits: _detail.totalUnits,
      bytesProcessed: _detail.bytesProcessed,
      totalBytes: _detail.totalBytes,
      currentItem: item,
      indeterminate: _detail.indeterminate,
    );
    _emit();
  }

  /// Replaces the active stage's counters, for a source that reports its own totals.
  ///
  /// Set [force] on the last update of a stage so the throttle cannot swallow it
  /// and leave the bar stalled just short of the end.
  void reportDetail(ExportPhaseDetail detail, {bool force = false}) {
    _detail = detail;
    _emit(force: force);
  }

  /// Marks every stage finished and emits a final snapshot.
  void complete([ExportOutcome outcome = ExportOutcome.succeeded]) {
    _activeIndex = steps.length;
    _outcome = outcome;
    _emit(force: true);
  }

  Future<void> dispose() => _controller.close();

  void _emit({bool force = false}) {
    final now = elapsed;
    if (!force && _hasEmitted && now - _lastEmit < exportProgressInterval) {
      return;
    }
    _lastEmit = now;
    _hasEmitted = true;
    if (_controller.isClosed) return;
    final fraction = _overallFraction();
    _controller.add(
      ExportJobProgress(
        steps: steps,
        activeIndex: _activeIndex,
        detail: _detail,
        elapsed: now,
        overallFraction: fraction,
        estimatedRemaining: _estimateRemaining(fraction, now),
        outcome: _outcome,
      ),
    );
  }

  double? _overallFraction() {
    if (_activeIndex < 0) return 0;
    if (_activeIndex >= steps.length) return 1;
    final total = steps.fold<double>(0, (sum, step) => sum + step.weight);
    if (total <= 0) return null;
    var done = 0.0;
    for (var index = 0; index < _activeIndex; index++) {
      done += steps[index].weight;
    }
    final active = _detail.fraction;
    if (active == null) return null;
    return ((done + steps[_activeIndex].weight * active) / total).clamp(
      0.0,
      1.0,
    );
  }

  /// Projects the time left from a smoothed rate of progress.
  ///
  /// The smoothing tracks the rate rather than the projected finish time. A
  /// projected finish time that goes stale keeps counting down while the job
  /// stalls, which is the opposite of what the user needs to see; a falling
  /// rate pushes the estimate out instead.
  ///
  /// Nothing is returned until the job has run long enough for the rate to be
  /// worth trusting, because a wrong estimate in the first seconds is worse
  /// than no estimate at all.
  Duration? _estimateRemaining(double? fraction, Duration now) {
    if (fraction == null || fraction <= 0) return null;
    if (fraction >= 1) return Duration.zero;
    _updateRate(fraction, now);
    if (now < _minElapsedForEstimate || fraction < _minFractionForEstimate) {
      return null;
    }
    final rate = _smoothedRate;
    if (rate == null || rate <= 0) return null;
    final remaining = (1 - fraction) / rate;
    if (!remaining.isFinite || remaining > _maxEstimateSeconds) return null;
    // Never read as `0 s left` while there is still work running.
    return Duration(seconds: remaining.round().clamp(1, _maxEstimateSeconds));
  }

  void _updateRate(double fraction, Duration now) {
    final seconds = (now - _lastRateSample).inMicroseconds / 1000000;
    if (seconds <= 0) return;
    final instant = (fraction - _lastFraction) / seconds;
    _lastFraction = fraction;
    _lastRateSample = now;
    if (instant < 0) return;
    final previous = _smoothedRate;
    _smoothedRate = previous == null
        ? instant
        : _estimateSmoothing * instant + (1 - _estimateSmoothing) * previous;
  }
}

/// Forwards a Rust archive progress stream into [progress] until it completes.
///
/// The Rust call runs to completion once started, so a pending cancel is applied
/// when the stream ends rather than part way through an entry.
Future<void> followArchiveProgress(
  Stream<ArchiveProgress> source, {
  ExportProgressReporter? progress,
  ExportCancellation? cancel,
}) async {
  ExportPhaseDetail? last;
  await for (final event in source) {
    last = ExportPhaseDetail(
      completedUnits: event.entriesDone.toInt(),
      totalUnits: event.entriesTotal.toInt(),
      bytesProcessed: event.bytesDone.toInt(),
      totalBytes: event.bytesTotal.toInt(),
      currentItem: event.currentPath.isEmpty ? null : event.currentPath,
    );
    progress?.reportDetail(last);
  }
  if (last != null) progress?.reportDetail(last, force: true);
  cancel?.throwIfCancelled();
}
