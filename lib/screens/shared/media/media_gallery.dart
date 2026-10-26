import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/media/media.dart';
import 'package:nahpu/screens/shared/media/media_batch_export.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/media/media_gallery_services.dart';
import 'package:nahpu/services/media/media_services.dart';
import 'package:nahpu/services/providers/media.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

/// Project filter value that shows media from every project.
const _allProjects = '';

const _galleryCategories = [
  MediaCategory.all,
  MediaCategory.specimen,
  MediaCategory.site,
  MediaCategory.event,
  MediaCategory.narrative,
];

Future<void> showMediaGallery(
  BuildContext context, {
  required MediaCategory initialCategory,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) =>
          MediaGalleryScreen(initialCategory: initialCategory),
    ),
  );
}

/// Opens the gallery with media from every project.
Future<void> showGlobalMediaGallery(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => const MediaGalleryScreen(
        initialCategory: MediaCategory.all,
        allProjects: true,
      ),
    ),
  );
}

class MediaGalleryScreen extends ConsumerStatefulWidget {
  const MediaGalleryScreen({
    super.key,
    required this.initialCategory,
    this.allProjects = false,
  });

  final MediaCategory initialCategory;

  /// Shows media from every project instead of only the open project.
  final bool allProjects;

  @override
  ConsumerState<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends ConsumerState<MediaGalleryScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final Set<int> _selectedMedia = {};
  final _galleryServices = const MediaGalleryServices();
  late MediaCategory _category;
  MediaGallerySort _sort = MediaGallerySort.addedNewest;
  String _projectUuid = _allProjects;
  bool _isSearching = false;
  bool _isSelecting = false;

  /// Query the grid is filtered by; trails the text field by the debounce.
  String _query = '';
  Timer? _searchDebounce;
  _VisibleMediaCache? _visibleCache;

  @override
  void initState() {
    super.initState();
    _category = _galleryCategories.contains(widget.initialCategory)
        ? widget.initialCategory
        : MediaCategory.all;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(_personnelProvider);
    if (widget.allProjects) ref.watch(projectListProvider);
    ref.listen(_mediaProvider, (_, next) {
      next.whenData((media) {
        final availableIds = media.map((item) => item.primaryId).toSet();
        if (_selectedMedia.any((id) => !availableIds.contains(id)) && mounted) {
          setState(() => _selectedMedia.retainAll(availableIds));
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isSearching ? NahpuSpacing.md : null,
        title: _isSearching
            ? Align(
                alignment: AlignmentDirectional.centerStart,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: NahpuContentWidth.form,
                  ),
                  child: CommonSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: context.l10n.mediaSearchMetadata,
                    trailing: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          tooltip: context.l10n.documentSelectionClearSearch,
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear_rounded),
                        ),
                    ],
                    onChanged: _onSearchChanged,
                  ),
                ),
              )
            : Text(
                widget.allProjects
                    ? context.l10n.mediaGalleryAllProjectsTitle
                    : context.l10n.mediaGalleryTitle,
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              tooltip: context.l10n.mediaSearch,
              onPressed: _startSearch,
              icon: const Icon(Icons.search),
            )
          else
            TextButton(
              onPressed: _cancelSearch,
              child: Text(context.l10n.commonCancel),
            ),
          if (!_isSearching && widget.allProjects)
            _ProjectMenu(
              value: _projectUuid,
              projects: _projects(),
              onSelected: _setProject,
            ),
          if (!_isSearching) _SortMenu(value: _sort, onSelected: _setSort),
        ],
      ),
      body: SafeArea(
        child: ref
            .watch(_mediaProvider)
            .when(
              data: _buildGallery,
              loading: () => const CommonProgressIndicator(),
              error: (error, stack) => Center(child: Text(error.toString())),
            ),
      ),
    );
  }

  Widget _buildGallery(List<MediaData> allMedia) {
    final visibleMedia = _visibleMedia(allMedia);
    final visibleIds = visibleMedia.map((media) => media.primaryId).toSet();
    final selectedVisible = _selectedMedia.intersection(visibleIds);

    return Column(
      children: [
        _CategoryFilter(
          selected: _category,
          onSelected: _setCategory,
          projectName: _projectUuid == _allProjects
              ? null
              : _projectNames()[_projectUuid] ?? _projectUuid,
          onProjectCleared: () => _setProject(_allProjects),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.sm),
          child: SelectItemsInterface(
            isSelecting: _isSelecting,
            onClearPressed: selectedVisible.isEmpty
                ? null
                : () => setState(_selectedMedia.clear),
            onSelectAllPressed: visibleMedia.isEmpty
                ? null
                : () {
                    setState(() {
                      _selectedMedia
                        ..clear()
                        ..addAll(visibleIds);
                    });
                  },
            onSelectPressed: visibleMedia.isEmpty
                ? null
                : () {
                    setState(() {
                      _isSelecting = !_isSelecting;
                      _selectedMedia.clear();
                    });
                  },
          ),
        ),
        Expanded(
          child: visibleMedia.isEmpty
              ? _GalleryEmptyState(hasProjectMedia: allMedia.isNotEmpty)
              : MediaViewerBuilder(
                  images: visibleMedia,
                  isSelecting: _isSelecting,
                  selectedMedia: selectedVisible,
                  onSelectionChanged: _toggleSelection,
                ),
        ),
        if (_isSelecting)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NahpuSpacing.md,
              NahpuSpacing.sm,
              NahpuSpacing.md,
              NahpuSpacing.md,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: context.l10n.mediaDeleteSelected,
                  color: Theme.of(context).colorScheme.error,
                  onPressed: selectedVisible.isEmpty
                      ? null
                      : () => _confirmDeleteSelected(allMedia),
                  icon: const Icon(Icons.delete_outline),
                ),
                Expanded(
                  child: Text(
                    context.l10n.mediaSelectedCount(selectedVisible.length),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                PrimaryButton(
                  label: context.l10n.commonExport,
                  icon: Icons.file_upload_outlined,
                  onPressed: selectedVisible.isEmpty
                      ? null
                      : () => showBatchMediaExport(
                          context,
                          media: visibleMedia
                              .where(
                                (media) =>
                                    selectedVisible.contains(media.primaryId),
                              )
                              .toList(growable: false),
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  FutureProvider<List<MediaData>> get _mediaProvider =>
      widget.allProjects ? allRecordMediaProvider : projectMediaProvider;

  FutureProvider<List<PersonnelData>> get _personnelProvider =>
      widget.allProjects ? allPersonnelProvider : projectPersonnelProvider;

  List<MediaData> _visibleMedia(List<MediaData> allMedia) {
    final personnel = ref.read(_personnelProvider).value;
    final projects = _projects();
    final cache = _visibleCache;
    final index =
        cache != null &&
            identical(cache.media, allMedia) &&
            identical(cache.personnel, personnel) &&
            identical(cache.projects, projects)
        ? cache.index
        : MediaSearchIndex.build(
            allMedia,
            personnelNames: _personnelNames(),
            projectNames: _projectNames(),
          );
    final filter = (
      category: _category,
      query: _query,
      sort: _sort,
      projectUuid: _projectUuid,
    );
    if (cache != null &&
        identical(cache.index, index) &&
        cache.filter == filter) {
      return cache.result;
    }
    final result = _galleryServices.filterAndSort(
      media: allMedia,
      category: _category,
      query: _query,
      sort: _sort,
      projectUuid: _projectUuid == _allProjects ? null : _projectUuid,
      index: index,
    );
    _visibleCache = _VisibleMediaCache(
      media: allMedia,
      personnel: personnel,
      projects: projects,
      index: index,
      filter: filter,
      result: result,
    );
    return result;
  }

  List<ProjectSummary> _projects() {
    if (!widget.allProjects) return const [];
    return ref.read(projectListProvider).value ?? const [];
  }

  Map<String, String> _projectNames() {
    return {for (final project in _projects()) project.uuid: project.name};
  }

  Map<String, String> _personnelNames() {
    final personnel = ref.read(_personnelProvider).value ?? const [];
    return {
      for (final person in personnel)
        if (person.name?.trim().isNotEmpty ?? false) person.uuid: person.name!,
    };
  }

  void _startSearch() {
    setState(() => _isSearching = true);
    _searchFocusNode.requestFocus();
  }

  void _onSearchChanged(String text) {
    // Rebuild now so the clear button tracks the text; filter after typing
    // pauses.
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _query = text;
      _pruneSelectionToVisible();
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _query = '';
    _pruneSelectionToVisible();
  }

  void _cancelSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _query = '';
    setState(() => _isSearching = false);
    _pruneSelectionToVisible();
  }

  void _setCategory(MediaCategory category) {
    setState(() => _category = category);
    _pruneSelectionToVisible();
  }

  void _setProject(String projectUuid) {
    setState(() => _projectUuid = projectUuid);
    _pruneSelectionToVisible();
  }

  void _setSort(MediaGallerySort sort) => setState(() => _sort = sort);

  void _pruneSelectionToVisible() {
    final allMedia = ref.read(_mediaProvider).value ?? const <MediaData>[];
    final visibleIds = _visibleMedia(
      allMedia,
    ).map((media) => media.primaryId).toSet();
    setState(() => _selectedMedia.retainAll(visibleIds));
  }

  void _toggleSelection(int id, bool selected) {
    setState(() {
      if (selected) {
        _selectedMedia.add(id);
      } else {
        _selectedMedia.remove(id);
      }
    });
  }

  Future<void> _deleteSelected(List<MediaData> allMedia) async {
    final selected = allMedia
        .where((media) => _selectedMedia.contains(media.primaryId))
        .toList(growable: false);
    var recordsDeleted = false;
    try {
      await MediaServices(ref: ref).deleteMediaItems(selected);
      recordsDeleted = true;
    } on MediaFileDeletionException catch (error) {
      recordsDeleted = true;
      if (mounted) _showError(error);
    } catch (error) {
      if (mounted) _showError(error);
    }
    if (mounted && recordsDeleted) {
      setState(() {
        _selectedMedia.clear();
        _isSelecting = false;
      });
    }
  }

  Future<void> _confirmDeleteSelected(List<MediaData> allMedia) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.mediaDeleteSelectedTitle),
        content: Text(context.l10n.mediaDeleteSelectedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _deleteSelected(allMedia);
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

typedef _GalleryFilter = ({
  MediaCategory category,
  String query,
  MediaGallerySort sort,
  String projectUuid,
});

/// Last filter result plus the inputs it came from.
class _VisibleMediaCache {
  const _VisibleMediaCache({
    required this.media,
    required this.personnel,
    required this.projects,
    required this.index,
    required this.filter,
    required this.result,
  });

  final List<MediaData> media;
  final List<PersonnelData>? personnel;
  final List<ProjectSummary> projects;
  final MediaSearchIndex index;
  final _GalleryFilter filter;
  final List<MediaData> result;
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.selected,
    required this.onSelected,
    required this.projectName,
    required this.onProjectCleared,
  });

  final MediaCategory selected;
  final ValueChanged<MediaCategory> onSelected;

  /// Active project filter, shown as a removable chip when not null.
  final String? projectName;
  final VoidCallback onProjectCleared;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        NahpuSpacing.md,
        NahpuSpacing.md,
        NahpuSpacing.md,
        NahpuSpacing.xs,
      ),
      child: Row(
        children: [
          if (projectName != null)
            Padding(
              padding: const EdgeInsets.only(right: NahpuSpacing.sm),
              child: InputChip(
                avatar: const Icon(Icons.folder_outlined),
                label: Text(projectName!),
                selected: true,
                showCheckmark: false,
                onPressed: onProjectCleared,
                onDeleted: onProjectCleared,
                deleteButtonTooltipMessage: context.l10n.mediaAllProjects,
              ),
            ),
          for (final category in _galleryCategories)
            Padding(
              padding: const EdgeInsets.only(right: NahpuSpacing.sm),
              child: ChoiceChip(
                label: Text(_categoryLabel(context.l10n, category)),
                selected: selected == category,
                onSelected: (_) => onSelected(category),
              ),
            ),
        ],
      ),
    );
  }

  String _categoryLabel(AppLocalizations l10n, MediaCategory category) =>
      switch (category) {
        MediaCategory.all => l10n.formsSearchAll,
        MediaCategory.specimen => l10n.presetsRecordTypeSpecimen,
        MediaCategory.site => l10n.presetsRecordTypeSite,
        MediaCategory.event => l10n.mediaCategoryEvent,
        MediaCategory.narrative => l10n.narrativeTitle,
        MediaCategory.personnel => l10n.settingsNavPersonnel,
      };
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.value, required this.onSelected});

  final MediaGallerySort value;
  final ValueChanged<MediaGallerySort> onSelected;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMenuButton<MediaGallerySort>(
      tooltip: context.l10n.mediaSort,
      initialValue: value,
      icon: const Icon(Icons.sort),
      onSelected: onSelected,
      itemBuilder: () => [
        for (final sort in MediaGallerySort.values)
          AdaptiveMenuItem(
            value: sort,
            label: sort.localizedLabel(context.l10n),
            checked: sort == value,
          ),
      ],
    );
  }
}

class _ProjectMenu extends StatelessWidget {
  const _ProjectMenu({
    required this.value,
    required this.projects,
    required this.onSelected,
  });

  final String value;
  final List<ProjectSummary> projects;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMenuButton<String>(
      tooltip: context.l10n.mediaFilterProject,
      initialValue: value,
      icon: Icon(value == _allProjects ? Icons.folder_outlined : Icons.folder),
      onSelected: onSelected,
      itemBuilder: () => [
        AdaptiveMenuItem(
          value: _allProjects,
          label: context.l10n.mediaAllProjects,
          checked: value == _allProjects,
        ),
        for (final project in projects)
          AdaptiveMenuItem(
            value: project.uuid,
            label: project.name,
            checked: project.uuid == value,
            hasDividerBefore: project == projects.first,
          ),
      ],
    );
  }
}

class _GalleryEmptyState extends StatelessWidget {
  const _GalleryEmptyState({required this.hasProjectMedia});

  final bool hasProjectMedia;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CommonEmptyForm(
        iconPath: 'assets/icons/image-gallery.svg',
        text: hasProjectMedia
            ? context.l10n.mediaNoMatching
            : context.l10n.mediaNoneAdded,
      ),
    );
  }
}
