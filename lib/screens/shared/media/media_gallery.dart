import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/media/media.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/media/media_gallery_services.dart';
import 'package:nahpu/services/media/media_services.dart';
import 'package:nahpu/services/providers/media.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/styles/design_tokens.dart';

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

class MediaGalleryScreen extends ConsumerStatefulWidget {
  const MediaGalleryScreen({super.key, required this.initialCategory});

  final MediaCategory initialCategory;

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
  bool _isSearching = false;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _category = _galleryCategories.contains(widget.initialCategory)
        ? widget.initialCategory
        : MediaCategory.all;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(projectPersonnelProvider);
    ref.listen(projectMediaProvider, (_, next) {
      next.whenData((media) {
        final availableIds = media.map((item) => item.primaryId).toSet();
        if (_selectedMedia.any((id) => !availableIds.contains(id)) && mounted) {
          setState(() => _selectedMedia.retainAll(availableIds));
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? CommonSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: 'Search media metadata',
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear_rounded),
                    ),
                ],
                onChanged: (_) => _pruneSelectionToVisible(),
              )
            : const Text('Media gallery'),
        actions: [
          if (!_isSearching)
            IconButton(
              tooltip: 'Search media',
              onPressed: _startSearch,
              icon: const Icon(Icons.search),
            )
          else
            TextButton(onPressed: _cancelSearch, child: const Text('Cancel')),
          if (!_isSearching) _SortMenu(value: _sort, onSelected: _setSort),
        ],
      ),
      body: SafeArea(
        child: ref
            .watch(projectMediaProvider)
            .when(
              data: _buildGallery,
              loading: () => const CommonProgressIndicator(),
              error: (error, stack) => Center(child: Text(error.toString())),
            ),
      ),
    );
  }

  Widget _buildGallery(List<MediaData> allMedia) {
    final personnelNames = _personnelNames();
    final visibleMedia = _galleryServices.filterAndSort(
      media: allMedia,
      category: _category,
      query: _searchController.text,
      sort: _sort,
      personnelNames: personnelNames,
    );
    final visibleIds = visibleMedia.map((media) => media.primaryId).toSet();
    final selectedVisible = _selectedMedia.intersection(visibleIds);

    return Column(
      children: [
        _CategoryFilter(selected: _category, onSelected: _setCategory),
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
          DeleteItemsButton(
            selectedItems: selectedVisible.toList(),
            itemName: selectedVisible.length == 1
                ? 'media file'
                : 'media files',
            customDialogHeader: 'Delete selected media?',
            customDialogText:
                'Delete the selected media from all NAHPU records and from '
                'disk? This cannot be undone.',
            onPressedFunction: () => _deleteSelected(allMedia),
          ),
      ],
    );
  }

  Map<String, String> _personnelNames() {
    final personnel = ref.read(projectPersonnelProvider).value ?? const [];
    return {
      for (final person in personnel)
        if (person.name?.trim().isNotEmpty ?? false) person.uuid: person.name!,
    };
  }

  void _startSearch() {
    setState(() => _isSearching = true);
    _searchFocusNode.requestFocus();
  }

  void _clearSearch() {
    _searchController.clear();
    _pruneSelectionToVisible();
  }

  void _cancelSearch() {
    _searchController.clear();
    setState(() => _isSearching = false);
    _pruneSelectionToVisible();
  }

  void _setCategory(MediaCategory category) {
    setState(() => _category = category);
    _pruneSelectionToVisible();
  }

  void _setSort(MediaGallerySort sort) => setState(() => _sort = sort);

  void _pruneSelectionToVisible() {
    final allMedia =
        ref.read(projectMediaProvider).value ?? const <MediaData>[];
    final visibleIds = _galleryServices
        .filterAndSort(
          media: allMedia,
          category: _category,
          query: _searchController.text,
          sort: _sort,
          personnelNames: _personnelNames(),
        )
        .map((media) => media.primaryId)
        .toSet();
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
    Navigator.of(context).pop();
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

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onSelected});

  final MediaCategory selected;
  final ValueChanged<MediaCategory> onSelected;

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
          for (final category in _galleryCategories)
            Padding(
              padding: const EdgeInsets.only(right: NahpuSpacing.sm),
              child: ChoiceChip(
                label: Text(_categoryLabel(category)),
                selected: selected == category,
                onSelected: (_) => onSelected(category),
              ),
            ),
        ],
      ),
    );
  }

  String _categoryLabel(MediaCategory category) => switch (category) {
    MediaCategory.all => 'All',
    MediaCategory.specimen => 'Specimen',
    MediaCategory.site => 'Site',
    MediaCategory.event => 'Event',
    MediaCategory.narrative => 'Narrative',
    MediaCategory.personnel => 'Personnel',
  };
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.value, required this.onSelected});

  final MediaGallerySort value;
  final ValueChanged<MediaGallerySort> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MediaGallerySort>(
      tooltip: 'Sort media',
      initialValue: value,
      icon: const Icon(Icons.sort),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final sort in MediaGallerySort.values)
          CheckedPopupMenuItem(
            value: sort,
            checked: sort == value,
            child: Text(sort.label),
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
        text: hasProjectMedia ? 'No matching media' : 'No media added',
      ),
    );
  }
}
