import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/document_selection.dart';
import 'package:nahpu/services/collevent_services.dart';

class SiteSelectionScreen extends ConsumerStatefulWidget {
  const SiteSelectionScreen({
    super.key,
    this.isSingleSelection = false,
    this.selectedIds,
    this.onSelectionChanged,
  });

  final bool isSingleSelection;
  final Set<int>? selectedIds;
  final ValueChanged<Set<int>>? onSelectionChanged;

  @override
  ConsumerState<SiteSelectionScreen> createState() =>
      _SiteSelectionScreenState();
}

class _SiteSelectionScreenState extends ConsumerState<SiteSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Set<int> selectedIds =
        widget.selectedIds ?? ref.watch(documentSiteSelectionProvider);
    final sitesAsync = ref.watch(siteEntryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSingleSelection
            ? 'Select Site for Preview'
            : widget.selectedIds != null
                ? 'Select Sites for Preview'
                : 'Select sites'),
      ),
      body: SafeArea(
        child: sitesAsync.when(
          data: (sites) {
            final filtered = sites.where((s) {
              final query = _searchQuery.toLowerCase();
              final siteId = (s.siteID ?? '').toLowerCase();
              final locality = (s.locality ?? '').toLowerCase();
              final country = (s.country ?? '').toLowerCase();
              return siteId.contains(query) ||
                  locality.contains(query) ||
                  country.contains(query);
            }).toList();

            final allFilteredIds = filtered.map((e) => e.id).toSet();
            final isSelectAllEnabled =
                allFilteredIds.any((id) => !selectedIds.contains(id));

            return Column(
              children: [
                if (!widget.isSingleSelection)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: selectedIds.isNotEmpty
                              ? () {
                                  if (widget.onSelectionChanged != null) {
                                    widget.onSelectionChanged!(<int>{});
                                  } else {
                                    ref
                                        .read(documentSiteSelectionProvider
                                            .notifier)
                                        .updateSelection(<int>{});
                                  }
                                }
                              : null,
                          child: const Text('Clear all'),
                        ),
                        TextButton(
                          onPressed: isSelectAllEnabled
                              ? () {
                                  final newSelected =
                                      Set<int>.from(selectedIds);
                                  newSelected.addAll(allFilteredIds);
                                  if (widget.onSelectionChanged != null) {
                                    widget.onSelectionChanged!(newSelected);
                                  } else {
                                    ref
                                        .read(documentSiteSelectionProvider
                                            .notifier)
                                        .updateSelection(newSelected);
                                  }
                                }
                              : null,
                          child: const Text('Select all'),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search site ID, locality...',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No sites found'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final site = filtered[index];
                            final isSelected = selectedIds.contains(site.id);

                            if (widget.isSingleSelection) {
                              return ListTile(
                                title: Text(site.siteID ?? 'Unnamed Site'),
                                subtitle: Text(
                                  site.locality ?? 'No locality details',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  if (widget.onSelectionChanged != null) {
                                    widget.onSelectionChanged!({site.id});
                                  } else {
                                    Navigator.pop(context, site.id);
                                  }
                                },
                              );
                            }

                            return CheckboxListTile(
                              value: isSelected,
                              title: Text(site.siteID ?? 'Unnamed Site'),
                              subtitle: Text(
                                site.locality ?? 'No locality details',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onChanged: (val) {
                                final newSelected = Set<int>.from(selectedIds);
                                if (val == true) {
                                  newSelected.add(site.id);
                                } else {
                                  newSelected.remove(site.id);
                                }
                                if (widget.onSelectionChanged != null) {
                                  widget.onSelectionChanged!(newSelected);
                                } else {
                                  ref
                                      .read(documentSiteSelectionProvider
                                          .notifier)
                                      .updateSelection(newSelected);
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class EventSelectionScreen extends ConsumerStatefulWidget {
  const EventSelectionScreen({
    super.key,
    this.isSingleSelection = false,
    this.selectedIds,
    this.onSelectionChanged,
  });

  final bool isSingleSelection;
  final Set<int>? selectedIds;
  final ValueChanged<Set<int>>? onSelectionChanged;

  @override
  ConsumerState<EventSelectionScreen> createState() =>
      _EventSelectionScreenState();
}

class _EventSelectionScreenState extends ConsumerState<EventSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<int, String> _eventIds = {};
  bool _loadingIds = true;

  @override
  void initState() {
    super.initState();
    _loadEventIds();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEventIds() async {
    final service = CollEventServices(ref: ref);
    final events = await service.getAllCollEvents();
    for (final event in events) {
      final name = await service.getCollEventID(event);
      _eventIds[event.id] = name;
    }
    if (mounted) {
      setState(() {
        _loadingIds = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Set<int> selectedIds =
        widget.selectedIds ?? ref.watch(documentEventSelectionProvider);
    final eventsAsync = ref.watch(collEventEntryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSingleSelection
            ? 'Select Event for Preview'
            : widget.selectedIds != null
                ? 'Select Events for Preview'
                : 'Select events'),
      ),
      body: SafeArea(
        child: _loadingIds
            ? const Center(child: CircularProgressIndicator())
            : eventsAsync.when(
                data: (events) {
                  final filtered = events.where((e) {
                    final query = _searchQuery.toLowerCase();
                    final eventId = (_eventIds[e.id] ?? '').toLowerCase();
                    final method = (e.primaryCollMethod ?? '').toLowerCase();
                    final notes = (e.collMethodNotes ?? '').toLowerCase();
                    return eventId.contains(query) ||
                        method.contains(query) ||
                        notes.contains(query);
                  }).toList();

                  final allFilteredIds = filtered.map((e) => e.id).toSet();
                  final isSelectAllEnabled =
                      allFilteredIds.any((id) => !selectedIds.contains(id));

                  return Column(
                    children: [
                      if (!widget.isSingleSelection)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: selectedIds.isNotEmpty
                                    ? () {
                                        if (widget.onSelectionChanged != null) {
                                          widget.onSelectionChanged!(<int>{});
                                        } else {
                                          ref
                                              .read(
                                                  documentEventSelectionProvider
                                                      .notifier)
                                              .updateSelection(<int>{});
                                        }
                                      }
                                    : null,
                                child: const Text('Clear all'),
                              ),
                              TextButton(
                                onPressed: isSelectAllEnabled
                                    ? () {
                                        final newSelected =
                                            Set<int>.from(selectedIds);
                                        newSelected.addAll(allFilteredIds);
                                        if (widget.onSelectionChanged != null) {
                                          widget
                                              .onSelectionChanged!(newSelected);
                                        } else {
                                          ref
                                              .read(
                                                  documentEventSelectionProvider
                                                      .notifier)
                                              .updateSelection(newSelected);
                                        }
                                      }
                                    : null,
                                child: const Text('Select all'),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search event ID, method...',
                            border: const OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text('No events found'))
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final event = filtered[index];
                                  final isSelected =
                                      selectedIds.contains(event.id);
                                  final name = _eventIds[event.id] ??
                                      'Event ID: ${event.id}';

                                  if (widget.isSingleSelection) {
                                    return ListTile(
                                      title: Text(name),
                                      subtitle: Text(
                                        '${event.primaryCollMethod ?? 'No method'} | '
                                        '${event.startDate ?? 'No date'}',
                                      ),
                                      onTap: () {
                                        if (widget.onSelectionChanged != null) {
                                          widget
                                              .onSelectionChanged!({event.id});
                                        } else {
                                          Navigator.pop(context, event.id);
                                        }
                                      },
                                    );
                                  }

                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(name),
                                    subtitle: Text(
                                      '${event.primaryCollMethod ?? 'No method'} | '
                                      '${event.startDate ?? 'No date'}',
                                    ),
                                    onChanged: (val) {
                                      final newSelected =
                                          Set<int>.from(selectedIds);
                                      if (val == true) {
                                        newSelected.add(event.id);
                                      } else {
                                        newSelected.remove(event.id);
                                      }
                                      if (widget.onSelectionChanged != null) {
                                        widget.onSelectionChanged!(newSelected);
                                      } else {
                                        ref
                                            .read(documentEventSelectionProvider
                                                .notifier)
                                            .updateSelection(newSelected);
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
      ),
    );
  }
}

class NarrativeSelectionScreen extends ConsumerStatefulWidget {
  const NarrativeSelectionScreen({
    super.key,
    this.isSingleSelection = false,
    this.selectedIds,
    this.onSelectionChanged,
  });

  final bool isSingleSelection;
  final Set<int>? selectedIds;
  final ValueChanged<Set<int>>? onSelectionChanged;

  @override
  ConsumerState<NarrativeSelectionScreen> createState() =>
      _NarrativeSelectionScreenState();
}

class _NarrativeSelectionScreenState
    extends ConsumerState<NarrativeSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Set<int> selectedIds =
        widget.selectedIds ?? ref.watch(documentNarrativeSelectionProvider);
    final narrativesAsync = ref.watch(narrativeEntryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSingleSelection
            ? 'Select Narrative for Preview'
            : widget.selectedIds != null
                ? 'Select Narratives for Preview'
                : 'Select narratives'),
      ),
      body: SafeArea(
        child: narrativesAsync.when(
          data: (narratives) {
            final filtered = narratives.where((n) {
              final query = _searchQuery.toLowerCase();
              final date = (n.date ?? '').toLowerCase();
              final text = (n.narrative ?? '').toLowerCase();
              return date.contains(query) || text.contains(query);
            }).toList();

            final allFilteredIds = filtered.map((e) => e.id).toSet();
            final isSelectAllEnabled =
                allFilteredIds.any((id) => !selectedIds.contains(id));

            return Column(
              children: [
                if (!widget.isSingleSelection)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: selectedIds.isNotEmpty
                              ? () {
                                  if (widget.onSelectionChanged != null) {
                                    widget.onSelectionChanged!(<int>{});
                                  } else {
                                    ref
                                        .read(documentNarrativeSelectionProvider
                                            .notifier)
                                        .updateSelection(<int>{});
                                  }
                                }
                              : null,
                          child: const Text('Clear all'),
                        ),
                        TextButton(
                          onPressed: isSelectAllEnabled
                              ? () {
                                  final newSelected =
                                      Set<int>.from(selectedIds);
                                  newSelected.addAll(allFilteredIds);
                                  if (widget.onSelectionChanged != null) {
                                    widget.onSelectionChanged!(newSelected);
                                  } else {
                                    ref
                                        .read(documentNarrativeSelectionProvider
                                            .notifier)
                                        .updateSelection(newSelected);
                                  }
                                }
                              : null,
                          child: const Text('Select all'),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search date, content...',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No narratives found'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final narrative = filtered[index];
                            final isSelected =
                                selectedIds.contains(narrative.id);

                            if (widget.isSingleSelection) {
                              return ListTile(
                                title: Text(narrative.date ?? 'No date'),
                                subtitle: Text(
                                  narrative.narrative ?? 'No text',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  if (widget.onSelectionChanged != null) {
                                    widget.onSelectionChanged!({narrative.id});
                                  } else {
                                    Navigator.pop(context, narrative.id);
                                  }
                                },
                              );
                            }

                            return CheckboxListTile(
                              value: isSelected,
                              title: Text(narrative.date ?? 'No date'),
                              subtitle: Text(
                                narrative.narrative ?? 'No text',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onChanged: (val) {
                                final newSelected = Set<int>.from(selectedIds);
                                if (val == true) {
                                  newSelected.add(narrative.id);
                                } else {
                                  newSelected.remove(narrative.id);
                                }
                                if (widget.onSelectionChanged != null) {
                                  widget.onSelectionChanged!(newSelected);
                                } else {
                                  ref
                                      .read(documentNarrativeSelectionProvider
                                          .notifier)
                                      .updateSelection(newSelected);
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
