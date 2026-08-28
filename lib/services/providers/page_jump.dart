import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/projects.dart';

/// Identifies the top-level record viewers hosted by the project shell.
enum RecordViewer { site, collEvent, specimen, narrative }

/// A one-shot request for a record viewer to land on a newly created record.
///
/// The viewers stay mounted in the shell's `IndexedStack`, so a data refresh
/// preserves the current page. Creating or duplicating a record is the
/// exception: the user expects to land on the new row to fill it in. The
/// create/duplicate handlers live in the menu bars, which have no access to
/// the viewer's page controller, so they store the new record's id (int) or
/// uuid (String) here; the matching viewer consumes it in `reconcile` once the
/// record shows up in the refreshed list. Keying on the record id (rather than
/// a boolean flag or a position) makes the handoff immune both to emission
/// ordering — a refresh that does not contain the record yet simply leaves the
/// request pending — and to the active sort: the new row lands wherever
/// `RecordSort` puts it, not necessarily at the end of the list.
final pendingRecordJumpProvider =
    NotifierProvider.family<PendingRecordJumpNotifier, Object?, RecordViewer>(
      PendingRecordJumpNotifier.new,
    );

class PendingRecordJumpNotifier extends Notifier<Object?> {
  PendingRecordJumpNotifier(this.viewer);
  final RecordViewer viewer;

  @override
  Object? build() => null;

  void updateState(Object? newValue) {
    state = newValue;
  }
}

/// The record each viewer last showed.
///
/// Unlike [pendingRecordJumpProvider] this is a memory, not a one-shot: it is
/// never cleared on read. Rotating the device, or resizing across the rail
/// breakpoint, recreates the viewer's `State` and with it a fresh
/// `PageNavigation` at page zero, so the position has to live outside the
/// `State` to survive. Holds the record id (int) or uuid (String), matching
/// [pendingRecordJumpProvider]'s convention.
final lastViewedRecordProvider =
    NotifierProvider.family<LastViewedRecordNotifier, Object?, RecordViewer>(
      LastViewedRecordNotifier.new,
    );

class LastViewedRecordNotifier extends Notifier<Object?> {
  LastViewedRecordNotifier(this.viewer);
  final RecordViewer viewer;

  @override
  Object? build() {
    // Watching the project clears the memory when the user switches projects,
    // so a newly opened project falls back to its own landing rule.
    ref.watch(projectUuidProvider);
    return null;
  }

  void updateState(Object? newValue) {
    state = newValue;
  }
}
