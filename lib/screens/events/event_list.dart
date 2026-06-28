import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/shared/project_shell.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/utility_services.dart';

/// Index of [CollEventViewer] in the project shell's navbar, used to jump back
/// to the always-mounted viewer when a list entry is tapped.
const int _collEventViewerIndex = 2;

class CollEventListPage extends ConsumerStatefulWidget {
  const CollEventListPage({super.key});

  @override
  CollEventListPageState createState() => CollEventListPageState();
}

class CollEventListPageState extends ConsumerState<CollEventListPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focus = FocusNode();
  List<CollEventData> _filteredEventData = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _focus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(collEventEntryProvider).when(
          data: (eventData) => Scaffold(
            appBar: AppBar(
              title: const Text('Event Records'),
            ),
            body: SafeArea(
              child: ScrollableConstrainedLayout(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonSearchBar(
                      controller: _searchController,
                      focusNode: _focus,
                      hintText: 'Search events',
                      trailing: [
                        _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _isSearching = false;
                                  });
                                },
                                icon: const Icon(Icons.clear_rounded))
                            : const SizedBox.shrink(),
                      ],
                      onChanged: (String query) {
                        setState(() {
                          if (query.isEmpty) {
                            _isSearching = false;
                          } else {
                            _isSearching = true;
                            _filteredEventData =
                                CollEventSearchServices(collEvents: eventData)
                                    .search(query.toLowerCase());
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    eventData.isEmpty
                        ? const Text('No events found')
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _eventCount(eventData),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              CollEventList(
                                data: _isSearching
                                    ? _filteredEventData
                                    : eventData,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        );
  }

  String _eventCount(List<CollEventData> data) {
    if (_isSearching) {
      final length = _filteredEventData.length;
      if (length == 0) {
        return 'No events found';
      }
      return 'Found: $length of ${data.length}';
    }
    return 'Event counts: ${data.length}';
  }
}

class CollEventList extends ConsumerWidget {
  const CollEventList({
    super.key,
    required this.data,
  });

  final List<CollEventData> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScrollController scrollController = ScrollController();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: CommonScrollbar(
        scrollController: scrollController,
        child: ListView.builder(
          shrinkWrap: true,
          controller: scrollController,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final event = data[index];
            return ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: CollEventListTitle(event: event),
              subtitle: Text(
                _eventSubtitle(event),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Hand the tapped record to the always-mounted CollEventViewer
                // and switch to its tab; the viewer lands on it via _reconcile.
                ref
                    .read(pendingRecordJumpProvider(RecordViewer.collEvent)
                        .notifier)
                    .updateState(event.id);
                ref.invalidate(collEventEntryProvider);
                ProjectShell.returnToTab(context, ref, _collEventViewerIndex);
              },
            );
          },
        ),
      ),
    );
  }

  String _eventSubtitle(CollEventData event) {
    final dates = [event.startDate, event.endDate]
        .where((e) => e != null && e.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    final parts = <String>[
      if (dates.isNotEmpty) dates.join(' – '),
      if (event.primaryCollMethod != null &&
          event.primaryCollMethod!.isNotEmpty)
        event.primaryCollMethod!,
    ];
    return parts.join(listTileSeparator);
  }
}

class CollEventListTitle extends ConsumerWidget {
  const CollEventListTitle({super.key, required this.event});

  final CollEventData event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: CollEventServices(ref: ref).getCollEventID(event),
      builder: (context, snapshot) {
        final label = _displayLabel(snapshot.data);
        return Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        );
      },
    );
  }

  /// The canonical event ID can be empty when site/date are unset; fall back to
  /// the start date and finally the row id so every entry stays identifiable.
  String _displayLabel(String? collEventId) {
    final trimmed = collEventId?.replaceAll(RegExp(r'^-+|-+$'), '').trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    final startDate = event.startDate;
    if (startDate != null && startDate.isNotEmpty) {
      return startDate;
    }
    return 'Event ${event.id}';
  }
}
