import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// Unplaced tubes in field ID order, for boxing tubes without a scanner.
/// Place puts the current tube in the next cell; Skip moves past it. Search
/// jumps to any tube, so tubes can be boxed in the order they come to hand.
class TissueWorkListPanel extends StatefulWidget {
  const TissueWorkListPanel({
    super.key,
    required this.records,
    required this.index,
    required this.labelFor,
    required this.searchTextFor,
    required this.nextLocation,
    required this.isBusy,
    required this.onPlace,
    required this.onSkip,
    required this.onSelect,
  });

  /// Shown at most this many upcoming tubes below the current one.
  static const int upcomingCount = 5;

  /// Shown at most this many search results.
  static const int resultCount = 8;

  /// Null while the list loads.
  final List<TissueItemRecord>? records;
  final int index;
  final String Function(TissueItemRecord record) labelFor;
  final String Function(TissueItemRecord record) searchTextFor;
  final String? nextLocation;
  final bool isBusy;
  final VoidCallback onPlace;
  final VoidCallback onSkip;
  final ValueChanged<int> onSelect;

  @override
  State<TissueWorkListPanel> createState() => _TissueWorkListPanelState();
}

class _TissueWorkListPanelState extends State<TissueWorkListPanel> {
  final _searchCtr = TextEditingController();

  @override
  void dispose() {
    _searchCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final records = widget.records;
    if (records == null) {
      return const Padding(
        padding: EdgeInsets.all(NahpuSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (records.isEmpty) {
      return Text(
        context.l10n.projectTissueWorkListEmpty,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final index = widget.index;
    final current = records[index];
    final isSearching = _searchCtr.text.trim().isNotEmpty;
    final matches = isSearching
        ? searchTissueItems(records, _searchCtr.text, widget.searchTextFor)
        : const <int>[];
    final upcoming = [
      for (
        var offset = 1;
        offset <= TissueWorkListPanel.upcomingCount;
        offset++
      )
        if (offset < records.length) (index + offset) % records.length,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('tissue-work-list-search'),
          controller: _searchCtr,
          decoration: InputDecoration(
            labelText: context.l10n.projectTissueWorkListSearch,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: isSearching
                ? IconButton(
                    tooltip: context.l10n.commonClear,
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (matches.length == 1) _select(matches.single);
          },
        ),
        if (isSearching) ...[
          const SizedBox(height: NahpuSpacing.sm),
          if (matches.isEmpty)
            Text(
              context.l10n.projectTissueNoMatches,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            for (final match in matches.take(TissueWorkListPanel.resultCount))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                selected: match == index,
                title: Text(widget.labelFor(records[match])),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _select(match),
              ),
          const Divider(height: NahpuSpacing.xl),
        ] else
          const SizedBox(height: NahpuSpacing.lg),
        Text(
          context.l10n.projectTissueRemaining(records.length),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NahpuSpacing.xs),
        Text(
          widget.labelFor(current),
          key: const ValueKey('tissue-work-list-current'),
          style: theme.textTheme.titleMedium,
        ),
        if (widget.nextLocation != null)
          Text(
            '→ ${widget.nextLocation}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        const SizedBox(height: NahpuSpacing.lg),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: widget.isBusy ? null : _place,
                icon: const Icon(Icons.move_to_inbox_outlined),
                label: Text(context.l10n.projectTissuePlace),
              ),
            ),
            const SizedBox(width: NahpuSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.isBusy || records.length < 2
                    ? null
                    : widget.onSkip,
                icon: const Icon(Icons.skip_next_outlined),
                label: Text(context.l10n.projectWizardSkip),
              ),
            ),
          ],
        ),
        if (upcoming.isNotEmpty && !isSearching) ...[
          const SizedBox(height: NahpuSpacing.lg),
          const Divider(height: NahpuStroke.thin),
          for (final upcomingIndex in upcoming)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(widget.labelFor(records[upcomingIndex])),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => widget.onSelect(upcomingIndex),
            ),
        ],
      ],
    );
  }

  void _select(int index) {
    widget.onSelect(index);
    _clearSearch();
  }

  void _place() {
    widget.onPlace();
    _clearSearch();
  }

  void _clearSearch() {
    setState(_searchCtr.clear);
  }
}
