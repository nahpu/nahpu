import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/shared/project_shell.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/page_jump.dart';

/// Index of [NarrativeViewer] in the project shell's navbar, used to jump back
/// to the always-mounted viewer when a list entry is tapped.
const int _narrativeViewerIndex = 4;

/// Standalone Narrative list screen. The same list body is also embedded in
/// the Collection Records segmented view.
class NarrativeListPage extends StatelessWidget {
  const NarrativeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Narrative Records')),
      body: const NarrativeListBody(),
    );
  }
}

class NarrativeListBody extends ConsumerStatefulWidget {
  const NarrativeListBody({super.key});

  @override
  NarrativeListBodyState createState() => NarrativeListBodyState();
}

class NarrativeListBodyState extends ConsumerState<NarrativeListBody> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focus = FocusNode();
  List<NarrativeData> _filteredNarrativeData = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _focus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(narrativeEntryProvider).when(
          data: (narrativeData) => SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Column(
                    children: [
                      CommonSearchBar(
                        controller: _searchController,
                        focusNode: _focus,
                        hintText: 'Search narratives',
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
                              _filteredNarrativeData = NarrativeSearchServices(
                                      narrativeEntries: narrativeData)
                                  .search(query.toLowerCase());
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (narrativeData.isEmpty)
                        const Expanded(
                          child: Center(child: Text('No narratives found')),
                        )
                      else ...[
                        Text(
                          _narrativeCount(narrativeData),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: NarrativeList(
                            data: _isSearching
                                ? _filteredNarrativeData
                                : narrativeData,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        );
  }

  String _narrativeCount(List<NarrativeData> data) {
    if (_isSearching) {
      final length = _filteredNarrativeData.length;
      if (length == 0) {
        return 'No narratives found';
      }
      return 'Found: $length of ${data.length}';
    }
    return 'Narrative counts: ${data.length}';
  }
}

class NarrativeList extends ConsumerWidget {
  const NarrativeList({
    super.key,
    required this.data,
  });

  final List<NarrativeData> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScrollController scrollController = ScrollController();
    return CommonScrollbar(
      scrollController: scrollController,
      child: ListView.builder(
        controller: scrollController,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final narrative = data[index];
          final snippet = _narrativeSnippet(narrative);
          return ListTile(
            leading: const Icon(Icons.book_outlined),
            title: Text(
              _narrativeTitle(narrative),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: snippet.isEmpty
                ? null
                : Text(
                    snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Hand the tapped record to the always-mounted NarrativeViewer
              // and switch to its tab; the viewer lands on it via _reconcile.
              ref
                  .read(pendingRecordJumpProvider(RecordViewer.narrative)
                      .notifier)
                  .updateState(narrative.id);
              ref.invalidate(narrativeEntryProvider);
              ProjectShell.returnToTab(context, ref, _narrativeViewerIndex);
            },
          );
        },
      ),
    );
  }

  String _narrativeTitle(NarrativeData narrative) {
    final date = narrative.date;
    if (date != null && date.isNotEmpty) {
      return date;
    }
    return 'Narrative ${narrative.id}';
  }

  /// Collapse whitespace/newlines so the markdown body reads as a single-line
  /// preview in the list subtitle.
  String _narrativeSnippet(NarrativeData narrative) {
    final text = narrative.narrative;
    if (text == null) return '';
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
