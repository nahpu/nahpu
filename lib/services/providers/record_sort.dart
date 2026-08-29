import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/record_sort.dart';

/// The shared-preferences key holding [viewer]'s sort.
String recordSortPrefKeyFor(RecordViewer viewer) =>
    '$recordSortPrefKey.${viewer.name}';

/// The active sort for each record viewer, persisted per viewer.
///
/// A synchronous [Notifier], not an [AsyncNotifier]: [settingProvider] is a
/// synchronous `Provider<SharedPreferences>`, and the record entry providers
/// watch this from their fetch methods — an [AsyncValue] there would add a
/// loading flash to the record list on every read. Kept alive because the sort
/// dialog writes it with a one-off `ref.read` and then goes away.
final recordSortProvider =
    NotifierProvider.family<RecordSortNotifier, RecordSort, RecordViewer>(
      RecordSortNotifier.new,
    );

class RecordSortNotifier extends Notifier<RecordSort> {
  RecordSortNotifier(this.viewer);
  final RecordViewer viewer;

  @override
  RecordSort build() {
    final prefs = ref.watch(settingProvider);
    return RecordSort.decode(prefs.getString(recordSortPrefKeyFor(viewer)));
  }

  Future<void> set(RecordSort sort) async {
    state = sort;
    await ref
        .read(settingProvider)
        .setString(recordSortPrefKeyFor(viewer), sort.encode());
  }
}
