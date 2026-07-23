import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/statistics.dart';

class SearchableStatisticFilterPicker extends StatelessWidget {
  const SearchableStatisticFilterPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.title,
    required this.placeholder,
    required this.onChanged,
    required this.onRetry,
  });

  final AsyncValue<List<StatisticFilterOption>> options;
  final StatisticFilterOption? selected;
  final String title;
  final String placeholder;
  final ValueChanged<StatisticFilterOption?> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return options.when(
      data: (items) => Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: items.isEmpty
                  ? null
                  : () async {
                      final result =
                          await showModalBottomSheet<StatisticFilterOption>(
                            context: context,
                            isScrollControlled: true,
                            showDragHandle: true,
                            builder: (context) =>
                                SearchableStatisticFilterSheet(
                                  title: title,
                                  options: items,
                                ),
                          );
                      if (result != null) onChanged(result);
                    },
              icon: const Icon(Icons.search_rounded),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selected?.label ?? placeholder,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (selected != null)
            IconButton(
              tooltip: 'Clear selection',
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.clear_rounded),
            ),
        ],
      ),
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => Row(
        children: [
          Expanded(child: Text('Unable to load choices: $error')),
          IconButton(
            tooltip: 'Retry',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class SearchableStatisticFilterSheet extends StatefulWidget {
  const SearchableStatisticFilterSheet({
    super.key,
    required this.title,
    required this.options,
  });

  final String title;
  final List<StatisticFilterOption> options;

  @override
  State<SearchableStatisticFilterSheet> createState() =>
      _SearchableStatisticFilterSheetState();
}

class _SearchableStatisticFilterSheetState
    extends State<SearchableStatisticFilterSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    final filtered = widget.options
        .where((option) => option.label.toLowerCase().contains(query))
        .toList(growable: false);
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SearchBar(
                controller: _searchController,
                hintText: 'Search',
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
                ],
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No matching choices'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final option = filtered[index];
                          return ListTile(
                            title: Text(option.label),
                            onTap: () => Navigator.pop(context, option),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
