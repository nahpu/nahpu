import 'package:flutter/material.dart';
import 'package:nahpu/screens/events/event_list.dart';
import 'package:nahpu/screens/narrative/narrative_list.dart';
import 'package:nahpu/screens/projects/taxonomy/specimen_list.dart';
import 'package:nahpu/screens/sites/site_list.dart';

/// The record categories shown in the Collection Records segmented view, in
/// the order they appear on the segmented button (left to right).
enum CollectionView {
  sites,
  events,
  specimens,
  narrative;

  /// Short label shown on the segmented button.
  String get segmentLabel {
    switch (this) {
      case CollectionView.sites:
        return 'Sites';
      case CollectionView.events:
        return 'Events';
      case CollectionView.specimens:
        return 'Specimen';
      case CollectionView.narrative:
        return 'Narrative';
    }
  }

  /// Title shown between the segmented button and the list.
  String get title {
    switch (this) {
      case CollectionView.sites:
        return 'Site Records';
      case CollectionView.events:
        return 'Event Records';
      case CollectionView.specimens:
        return 'Specimen Records';
      case CollectionView.narrative:
        return 'Narrative Records';
    }
  }
}

/// Hosts the four collection list views (sites, events, specimens, narrative)
/// under a single Material 3 segmented button. The lists are kept alive in an
/// [IndexedStack] so each tab preserves its search state while switching.
class CollectionRecordsPage extends StatefulWidget {
  const CollectionRecordsPage({
    super.key,
    this.initialView = CollectionView.sites,
  });

  final CollectionView initialView;

  @override
  State<CollectionRecordsPage> createState() => _CollectionRecordsPageState();
}

class _CollectionRecordsPageState extends State<CollectionRecordsPage> {
  late CollectionView _selected = widget.initialView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Records'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SegmentedButton<CollectionView>(
                  selected: {_selected},
                  showSelectedIcon: false,
                  segments: CollectionView.values
                      .map((view) => ButtonSegment<CollectionView>(
                            value: view,
                            label: Text(view.segmentLabel),
                          ))
                      .toList(),
                  onSelectionChanged: (Set<CollectionView> selection) {
                    setState(() => _selected = selection.first);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _selected.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: IndexedStack(
                index: _selected.index,
                children: const [
                  SiteListBody(),
                  CollEventListBody(),
                  SpecimenListBody(),
                  NarrativeListBody(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
