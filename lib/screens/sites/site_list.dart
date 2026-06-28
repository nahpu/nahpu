import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/shared/project_shell.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/utility_services.dart';

/// Index of [SiteViewer] in the project shell's navbar, used to jump back to
/// the always-mounted viewer when a list entry is tapped.
const int _siteViewerIndex = 1;

/// Standalone Site list screen. The same list body is also embedded in the
/// Collection Records segmented view.
class SiteListPage extends StatelessWidget {
  const SiteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Site Records')),
      body: const SiteListBody(),
    );
  }
}

class SiteListBody extends ConsumerStatefulWidget {
  const SiteListBody({super.key});

  @override
  SiteListBodyState createState() => SiteListBodyState();
}

class SiteListBodyState extends ConsumerState<SiteListBody> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focus = FocusNode();
  List<SiteData> _filteredSiteData = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _focus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(siteEntryProvider).when(
          data: (siteData) => SafeArea(
              child: ScrollableConstrainedLayout(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonSearchBar(
                      controller: _searchController,
                      focusNode: _focus,
                      hintText: 'Search sites',
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
                            _filteredSiteData =
                                SiteSearchServices(siteEntries: siteData)
                                    .search(query.toLowerCase());
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    siteData.isEmpty
                        ? const Text('No sites found')
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _siteCount(siteData),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              SiteList(
                                data:
                                    _isSearching ? _filteredSiteData : siteData,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        );
  }

  String _siteCount(List<SiteData> data) {
    if (_isSearching) {
      final length = _filteredSiteData.length;
      if (length == 0) {
        return 'No sites found';
      }
      return 'Found: $length of ${data.length}';
    }
    return 'Site counts: ${data.length}';
  }
}

class SiteList extends ConsumerWidget {
  const SiteList({
    super.key,
    required this.data,
  });

  final List<SiteData> data;

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
            final site = data[index];
            return ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(
                _siteTitle(site),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                _siteSubtitle(site),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Hand the tapped record to the always-mounted SiteViewer and
                // switch to its tab; the viewer lands on it via _reconcile.
                ref
                    .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
                    .updateState(site.id);
                ref.invalidate(siteEntryProvider);
                ProjectShell.returnToTab(context, ref, _siteViewerIndex);
              },
            );
          },
        ),
      ),
    );
  }

  String _siteTitle(SiteData site) {
    final siteID = site.siteID;
    if (siteID != null && siteID.isNotEmpty) {
      return siteID;
    }
    return 'Site ${site.id}';
  }

  String _siteSubtitle(SiteData site) {
    final parts = [
      site.locality,
      site.municipality,
      site.county,
      site.stateProvince,
      site.country,
    ].where((e) => e != null && e.isNotEmpty).cast<String>();
    return parts.join(listTileSeparator);
  }
}
