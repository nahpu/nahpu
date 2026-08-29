import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';

const _steps = [
  ExportPhaseStep(phase: ExportPhase.preparing, label: 'Prepare', weight: 1),
  ExportPhaseStep(phase: ExportPhase.copyingFiles, label: 'Copy', weight: 4),
  ExportPhaseStep(phase: ExportPhase.compressing, label: 'Compress', weight: 5),
];

/// A reporter whose clock the test advances by hand.
({ExportProgressReporter reporter, void Function(Duration) advance})
_fixedClockReporter({List<ExportPhaseStep> steps = _steps}) {
  var now = Duration.zero;
  final reporter = ExportProgressReporter(steps: steps, elapsed: () => now);
  return (reporter: reporter, advance: (step) => now += step);
}

void main() {
  group('formatByteSize', () {
    test('scales into the largest unit that fits', () {
      expect(formatByteSize(0), '0 B');
      expect(formatByteSize(512), '512 B');
      expect(formatByteSize(2048), '2 KB');
      expect(formatByteSize(5 * 1024 * 1024), '5.0 MB');
      expect(formatByteSize(1932735283), '1.8 GB');
    });

    test('drops the decimal once the number is wide enough to read', () {
      expect(formatByteSize(640 * 1024 * 1024), '640 MB');
    });
  });

  group('formatExportDuration', () {
    test('reads as coarse time rather than raw seconds', () {
      expect(formatExportDuration(const Duration(seconds: 45)), '45 s');
      expect(formatExportDuration(const Duration(minutes: 3)), '3 min');
      expect(
        formatExportDuration(const Duration(minutes: 3, seconds: 42)),
        '3 min 42 s',
      );
      expect(
        formatExportDuration(const Duration(hours: 1, minutes: 12)),
        '1 hr 12 min',
      );
    });
  });

  group('ExportPhaseDetail', () {
    test('prefers bytes over item counts', () {
      const detail = ExportPhaseDetail(
        completedUnits: 1,
        totalUnits: 100,
        bytesProcessed: 750,
        totalBytes: 1000,
      );
      expect(detail.fraction, 0.75);
    });

    test('falls back to item counts when no size is known', () {
      const detail = ExportPhaseDetail(completedUnits: 25, totalUnits: 100);
      expect(detail.fraction, 0.25);
    });

    test('reports nothing when neither total is known', () {
      expect(const ExportPhaseDetail(completedUnits: 3).fraction, isNull);
    });

    test('stays indeterminate while still exposing its totals', () {
      const detail = ExportPhaseDetail(totalUnits: 918, indeterminate: true);
      expect(detail.fraction, isNull);
      expect(detail.totalUnits, 918);
    });
  });

  group('ExportProgressReporter', () {
    test('weights the overall bar by the share each stage carries', () async {
      final fixture = _fixedClockReporter();
      final reporter = fixture.reporter;
      final snapshots = <ExportJobProgress>[];
      reporter.stream.listen(snapshots.add);

      reporter.beginPhase(ExportPhase.preparing, totalUnits: 1);
      fixture.advance(const Duration(seconds: 1));
      reporter.advanceItem();
      fixture.advance(const Duration(seconds: 1));
      reporter.beginPhase(ExportPhase.copyingFiles, totalBytes: 1000);
      fixture.advance(const Duration(seconds: 1));
      reporter.reportDetail(
        const ExportPhaseDetail(bytesProcessed: 500, totalBytes: 1000),
      );
      await Future<void>.delayed(Duration.zero);

      // Prepare is 1 of 10 and complete; copy is 4 of 10 and half done.
      expect(snapshots.last.overallFraction, closeTo(0.3, 1e-9));
      await reporter.dispose();
    });

    test('goes indeterminate for a stage that cannot report', () async {
      final fixture = _fixedClockReporter();
      final reporter = fixture.reporter;
      final snapshots = <ExportJobProgress>[];
      reporter.stream.listen(snapshots.add);

      reporter.beginPhase(ExportPhase.compressing, indeterminate: true);
      await Future<void>.delayed(Duration.zero);

      expect(snapshots.last.overallFraction, isNull);
      expect(snapshots.last.activeStep?.label, 'Compress');
      await reporter.dispose();
    });

    test('reaches a full bar and a finished stepper on completion', () async {
      final fixture = _fixedClockReporter();
      final reporter = fixture.reporter;
      final snapshots = <ExportJobProgress>[];
      reporter.stream.listen(snapshots.add);

      reporter.beginPhase(ExportPhase.preparing);
      reporter.complete();
      await Future<void>.delayed(Duration.zero);

      final last = snapshots.last;
      expect(last.overallFraction, 1);
      expect(last.outcome, ExportOutcome.succeeded);
      expect(last.isComplete(_steps.length - 1), isTrue);
      expect(last.activeStep, isNull);
      await reporter.dispose();
    });

    test('throttles updates so a large copy cannot flood the UI', () async {
      final fixture = _fixedClockReporter();
      final reporter = fixture.reporter;
      final snapshots = <ExportJobProgress>[];
      reporter.stream.listen(snapshots.add);

      reporter.beginPhase(ExportPhase.copyingFiles, totalUnits: 1000);
      for (var index = 0; index < 500; index++) {
        reporter.advanceItem();
      }
      await Future<void>.delayed(Duration.zero);

      // One forced snapshot for the stage start; the rest fall inside the
      // throttle window because the clock never moved.
      expect(snapshots, hasLength(1));
      await reporter.dispose();
    });

    test('emits a throttled update once the interval passes', () async {
      final fixture = _fixedClockReporter();
      final reporter = fixture.reporter;
      final snapshots = <ExportJobProgress>[];
      reporter.stream.listen(snapshots.add);

      reporter.beginPhase(ExportPhase.copyingFiles, totalUnits: 10);
      reporter.advanceItem();
      fixture.advance(exportProgressInterval * 2);
      reporter.advanceItem();
      await Future<void>.delayed(Duration.zero);

      expect(snapshots, hasLength(2));
      expect(snapshots.last.detail.completedUnits, 2);
      await reporter.dispose();
    });

    test('forces the final update of a stage past the throttle', () async {
      final fixture = _fixedClockReporter();
      final reporter = fixture.reporter;
      final snapshots = <ExportJobProgress>[];
      reporter.stream.listen(snapshots.add);

      reporter.beginPhase(ExportPhase.compressing, totalUnits: 2);
      reporter.reportDetail(
        const ExportPhaseDetail(completedUnits: 1, totalUnits: 2),
      );
      reporter.reportDetail(
        const ExportPhaseDetail(completedUnits: 2, totalUnits: 2),
        force: true,
      );
      await Future<void>.delayed(Duration.zero);

      expect(snapshots.last.detail.completedUnits, 2);
      await reporter.dispose();
    });

    test('withholds an estimate until the rate is worth trusting', () async {
      final fixture = _fixedClockReporter();
      final reporter = fixture.reporter;
      final snapshots = <ExportJobProgress>[];
      reporter.stream.listen(snapshots.add);

      reporter.beginPhase(ExportPhase.copyingFiles, totalBytes: 1000);
      fixture.advance(const Duration(seconds: 2));
      reporter.reportDetail(
        const ExportPhaseDetail(bytesProcessed: 500, totalBytes: 1000),
        force: true,
      );
      await Future<void>.delayed(Duration.zero);

      expect(snapshots.last.estimatedRemaining, isNull);
      await reporter.dispose();
    });

    test('estimates the time left once enough of the job has run', () async {
      final fixture = _fixedClockReporter(
        steps: const [
          ExportPhaseStep(phase: ExportPhase.copyingFiles, label: 'Copy'),
        ],
      );
      final reporter = fixture.reporter;
      final snapshots = <ExportJobProgress>[];
      reporter.stream.listen(snapshots.add);

      reporter.beginPhase(ExportPhase.copyingFiles, totalBytes: 1000);
      fixture.advance(const Duration(seconds: 10));
      reporter.reportDetail(
        const ExportPhaseDetail(bytesProcessed: 500, totalBytes: 1000),
        force: true,
      );
      await Future<void>.delayed(Duration.zero);

      // Half done after ten seconds projects ten seconds remaining.
      expect(snapshots.last.estimatedRemaining, const Duration(seconds: 10));
      await reporter.dispose();
    });

    test('pushes the estimate out when the job slows down', () async {
      final fixture = _fixedClockReporter(
        steps: const [
          ExportPhaseStep(phase: ExportPhase.copyingFiles, label: 'Copy'),
        ],
      );
      final reporter = fixture.reporter;
      final snapshots = <ExportJobProgress>[];
      reporter.stream.listen(snapshots.add);

      reporter.beginPhase(ExportPhase.copyingFiles, totalBytes: 1000);
      fixture.advance(const Duration(seconds: 10));
      reporter.reportDetail(
        const ExportPhaseDetail(bytesProcessed: 500, totalBytes: 1000),
        force: true,
      );
      await Future<void>.delayed(Duration.zero);
      expect(snapshots.last.estimatedRemaining, const Duration(seconds: 10));

      // The job nearly stalls. The estimate has to grow, but smoothing keeps it
      // well short of the 990 s the raw instantaneous rate would project.
      fixture.advance(const Duration(seconds: 10));
      reporter.reportDetail(
        const ExportPhaseDetail(bytesProcessed: 505, totalBytes: 1000),
        force: true,
      );
      await Future<void>.delayed(Duration.zero);

      final estimate = snapshots.last.estimatedRemaining!;
      expect(estimate.inSeconds, greaterThan(10));
      expect(estimate.inSeconds, lessThan(100));
      await reporter.dispose();
    });

    test('never reads as no time left while work is still running', () async {
      final fixture = _fixedClockReporter(
        steps: const [
          ExportPhaseStep(phase: ExportPhase.copyingFiles, label: 'Copy'),
        ],
      );
      final reporter = fixture.reporter;
      final snapshots = <ExportJobProgress>[];
      reporter.stream.listen(snapshots.add);

      reporter.beginPhase(ExportPhase.copyingFiles, totalBytes: 1000);
      fixture.advance(const Duration(seconds: 10));
      reporter.reportDetail(
        const ExportPhaseDetail(bytesProcessed: 999, totalBytes: 1000),
        force: true,
      );
      await Future<void>.delayed(Duration.zero);

      expect(snapshots.last.estimatedRemaining, const Duration(seconds: 1));
      await reporter.dispose();
    });
  });

  group('ExportCancellation', () {
    test('throws only after a cancel is requested', () {
      final cancellation = ExportCancellation();
      expect(cancellation.isCancelled, isFalse);
      expect(cancellation.throwIfCancelled, returnsNormally);

      cancellation.cancel();

      expect(cancellation.isCancelled, isTrue);
      expect(
        cancellation.throwIfCancelled,
        throwsA(isA<ExportCancelledException>()),
      );
    });
  });
}
