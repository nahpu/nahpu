import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/actions/export_progress_panel.dart';
import 'package:nahpu/services/export/export_progress.dart';

const _steps = [
  ExportPhaseStep(phase: ExportPhase.preparing, label: 'Prepare backup'),
  ExportPhaseStep(
    phase: ExportPhase.copyingFiles,
    label: 'Copy media and files',
  ),
  ExportPhaseStep(phase: ExportPhase.compressing, label: 'Compress archive'),
];

ExportJobProgress _progress({
  int activeIndex = 1,
  ExportPhaseDetail detail = const ExportPhaseDetail(),
  double? overallFraction = 0.43,
  Duration? estimatedRemaining,
  ExportOutcome outcome = ExportOutcome.running,
}) => ExportJobProgress(
  steps: _steps,
  activeIndex: activeIndex,
  detail: detail,
  elapsed: const Duration(seconds: 72),
  overallFraction: overallFraction,
  estimatedRemaining: estimatedRemaining,
  outcome: outcome,
);

Future<void> _pumpPanel(WidgetTester tester, Widget panel) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: panel)),
  ),
);

void main() {
  group('ExportProgressPanel', () {
    testWidgets('names every stage and marks where the job is', (tester) async {
      await _pumpPanel(
        tester,
        ExportProgressPanel(
          title: 'Backing up database',
          progress: _progress(),
        ),
      );

      expect(find.text('Backing up database'), findsOneWidget);
      for (final step in _steps) {
        expect(find.text(step.label), findsOneWidget);
      }
      // One finished stage, one running spinner, one still to come.
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows counts, size, and a percentage', (tester) async {
      await _pumpPanel(
        tester,
        ExportProgressPanel(
          title: 'Backing up database',
          progress: _progress(
            detail: const ExportPhaseDetail(
              completedUnits: 312,
              totalUnits: 918,
              bytesProcessed: 671088640,
              totalBytes: 1932735283,
            ),
          ),
        ),
      );

      expect(find.text('43%'), findsOneWidget);
      expect(
        find.textContaining('312 of 918 files · 640 MB of 1.8 GB'),
        findsOneWidget,
      );
      expect(find.textContaining('elapsed'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.43);
    });

    testWidgets('runs an indeterminate bar when a stage cannot report', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        ExportProgressPanel(
          title: 'Bundling records',
          progress: _progress(
            activeIndex: 2,
            overallFraction: null,
            detail: const ExportPhaseDetail(
              totalUnits: 918,
              indeterminate: true,
            ),
          ),
        ),
      );

      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, isNull);
      // No percentage is claimed, but the contents handed over are still named.
      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('0 of 918 files'), findsOneWidget);
    });

    testWidgets('shows the estimate only when one was calculated', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        ExportProgressPanel(
          title: 'Backing up database',
          progress: _progress(),
        ),
      );
      expect(find.textContaining('left'), findsNothing);

      await _pumpPanel(
        tester,
        ExportProgressPanel(
          title: 'Backing up database',
          progress: _progress(estimatedRemaining: const Duration(minutes: 2)),
        ),
      );
      expect(find.text('about 2 min left'), findsOneWidget);
    });

    testWidgets('keeps a long file name to a single line', (tester) async {
      await _pumpPanel(
        tester,
        ExportProgressPanel(
          title: 'Backing up database',
          progress: _progress(
            detail: const ExportPhaseDetail(
              currentItem:
                  'IMG_20240712_bat_roost_survey_transect_four_replicate.jpg',
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.text('IMG_20240712_bat_roost_survey_transect_four_replicate.jpg'),
      );
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('offers cancel and reports that it was asked for', (
      tester,
    ) async {
      var cancelled = false;
      await _pumpPanel(
        tester,
        ExportProgressPanel(
          title: 'Backing up database',
          progress: _progress(),
          onCancel: () => cancelled = true,
        ),
      );

      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);

      await _pumpPanel(
        tester,
        ExportProgressPanel(
          title: 'Backing up database',
          progress: _progress(),
          onCancel: () {},
          isCancelling: true,
        ),
      );
      expect(find.text('Cancelling…'), findsOneWidget);
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNull,
      );
    });

    testWidgets('hides cancel when the job must not be stopped', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        ExportProgressPanel(title: 'Restoring database', progress: _progress()),
      );

      expect(find.text('Cancel'), findsNothing);
    });
  });

  group('ExportFailurePanel', () {
    testWidgets('says plainly that a cancelled run saved nothing', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        ExportFailurePanel(outcome: ExportOutcome.cancelled, onRetry: () {}),
      );

      expect(find.text('Export cancelled'), findsOneWidget);
      expect(find.textContaining('No file was saved'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      // Success is the location card's job, so nothing here offers Share.
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('names the stage a failure stopped in', (tester) async {
      await _pumpPanel(
        tester,
        const ExportFailurePanel(
          outcome: ExportOutcome.failed,
          errorMessage: 'No space left on device',
          failedStepLabel: 'Compress archive',
        ),
      );

      expect(find.text('Export failed'), findsOneWidget);
      expect(
        find.text('Stopped while working on: Compress archive'),
        findsOneWidget,
      );
      expect(find.textContaining('No space left on device'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });
  });
}
