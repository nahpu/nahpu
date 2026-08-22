import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Identifies the top-level record viewers hosted by the project shell.
enum RecordViewer { site, collEvent, specimen, narrative }

/// A one-shot request for a record viewer to land on a newly created record.
///
/// The viewers stay mounted in the shell's `IndexedStack`, so a data refresh
/// preserves the current page. Creating or duplicating a record is the
/// exception: the new row is appended to the end of the list and the user
/// expects to land on it to fill it in. The create/duplicate handlers live in
/// the menu bars, which have no access to the viewer's page controller, so
/// they store the new record's id (int) or uuid (String) here; the matching
/// viewer consumes it in `_reconcile` once the record shows up in the
/// refreshed list. Keying on the record id (rather than a boolean flag) makes
/// the handoff immune to emission ordering: a refresh that does not contain
/// the record yet simply leaves the request pending.
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
