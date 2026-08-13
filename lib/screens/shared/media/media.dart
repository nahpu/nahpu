import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/media/media_details.dart';
import 'package:nahpu/screens/shared/media/media_viewer_dialog.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/media/media_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as path;

const int imageSize = 300;

typedef MediaActionCallback = Future<void> Function();

class MediaViewer extends ConsumerStatefulWidget {
  const MediaViewer({
    super.key,
    required this.images,
    required this.onAddFromGallery,
    required this.onAddFromFiles,
    required this.onTakeMedia,
    required this.onRecordAudio,
    required this.onOpenGallery,
    this.contentHeight,
  });

  final List<MediaData> images;
  final MediaActionCallback onAddFromGallery;
  final MediaActionCallback onAddFromFiles;
  final MediaActionCallback onTakeMedia;
  final MediaActionCallback onRecordAudio;
  final VoidCallback onOpenGallery;
  final double? contentHeight;

  @override
  ConsumerState<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends ConsumerState<MediaViewer> {
  bool _isSelecting = false;
  final Set<int> _selectedMedia = {};

  @override
  void didUpdateWidget(covariant MediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final availableIds = widget.images.map((media) => media.primaryId).toSet();
    _selectedMedia.removeWhere((id) => !availableIds.contains(id));
    if (widget.images.isEmpty) {
      _isSelecting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const TitleForm(
                text: 'Media',
                isCentered: false,
                infoContent: MediaInfoContent(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: widget.onOpenGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                  const SizedBox(width: 8),
                  MediaButton(
                    onAddFromGallery: widget.onAddFromGallery,
                    onAddFromFiles: widget.onAddFromFiles,
                    onTakeMedia: widget.onTakeMedia,
                    onRecordAudio: widget.onRecordAudio,
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: SelectItemsInterface(
            isSelecting: _isSelecting,
            onClearPressed: _selectedMedia.isEmpty
                ? null
                : () => setState(_selectedMedia.clear),
            onSelectAllPressed: widget.images.isEmpty
                ? null
                : () {
                    setState(() {
                      _selectedMedia
                        ..clear()
                        ..addAll(widget.images.map((media) => media.primaryId));
                    });
                  },
            onSelectPressed: widget.images.isEmpty
                ? null
                : () {
                    setState(() {
                      _isSelecting = !_isSelecting;
                      _selectedMedia.clear();
                    });
                  },
          ),
        ),
        SizedBox(
          height:
              widget.contentHeight ?? MediaQuery.of(context).size.height * 0.5,
          child: widget.images.isEmpty
              ? const Center(child: EmptyMedia())
              : Column(
                  children: [
                    Expanded(
                      child: MediaViewerBuilder(
                        images: widget.images,
                        isSelecting: _isSelecting,
                        selectedMedia: _selectedMedia,
                        onSelectionChanged: _toggleSelection,
                      ),
                    ),
                    if (_isSelecting)
                      DeleteItemsButton(
                        selectedItems: _selectedMedia.toList(),
                        itemName: _selectedMedia.length == 1
                            ? 'media file'
                            : 'media files',
                        onPressedFunction: _deleteSelectedMedia,
                      ),
                  ],
                ),
        ),
      ],
    );
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

  Future<void> _deleteSelectedMedia() async {
    Navigator.of(context).pop();
    var recordsDeleted = false;
    try {
      await MediaServices(ref: ref).deleteMediaItems(
        widget.images.where(
          (media) => _selectedMedia.contains(media.primaryId),
        ),
      );
      recordsDeleted = true;
    } on MediaFileDeletionException catch (error) {
      recordsDeleted = true;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
    if (mounted && recordsDeleted) {
      setState(() {
        _selectedMedia.clear();
        _isSelecting = false;
      });
    }
  }
}

class EmptyMedia extends StatelessWidget {
  const EmptyMedia({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonEmptyForm(
      iconPath: 'assets/icons/image-gallery.svg',
      text: 'No media added',
    );
  }
}

enum MediaAddSource { takeMedia, recordAudio, gallery, file }

List<MediaAddSource> mediaAddSourcesForPlatform(PlatformType platform) {
  return [
    if (platform == PlatformType.mobile) MediaAddSource.takeMedia,
    MediaAddSource.recordAudio,
    if (platform == PlatformType.mobile) MediaAddSource.gallery,
    MediaAddSource.file,
  ];
}

class MediaButton extends StatelessWidget {
  const MediaButton({
    super.key,
    required this.onAddFromGallery,
    required this.onAddFromFiles,
    required this.onTakeMedia,
    required this.onRecordAudio,
    this.platformOverride,
  });

  final MediaActionCallback onAddFromGallery;
  final MediaActionCallback onAddFromFiles;
  final MediaActionCallback onTakeMedia;
  final MediaActionCallback onRecordAudio;
  final PlatformType? platformOverride;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: () => _showImportSourcePicker(context),
      label: 'Add',
      icon: Icons.add,
    );
  }

  Future<void> _showImportSourcePicker(BuildContext context) async {
    final sources = mediaAddSourcesForPlatform(
      platformOverride ?? systemPlatform,
    );
    final source = MediaQuery.sizeOf(context).width < 600
        ? await showModalBottomSheet<MediaAddSource>(
            context: context,
            showDragHandle: true,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final source in sources)
                    _MediaAddSourceTile(source: source),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          )
        : await showDialog<MediaAddSource>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add media'),
              contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final source in sources)
                      _MediaAddSourceTile(source: source),
                  ],
                ),
              ),
            ),
          );
    if (source == null) return;
    await switch (source) {
      MediaAddSource.takeMedia => onTakeMedia(),
      MediaAddSource.recordAudio => onRecordAudio(),
      MediaAddSource.gallery => onAddFromGallery(),
      MediaAddSource.file => onAddFromFiles(),
    };
  }
}

class _MediaAddSourceTile extends StatelessWidget {
  const _MediaAddSourceTile({required this.source});

  final MediaAddSource source;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).pop(source),
      leading: Icon(_icon),
      title: Text(_label),
    );
  }

  IconData get _icon => switch (source) {
    MediaAddSource.takeMedia => Icons.photo_camera_outlined,
    MediaAddSource.recordAudio => Icons.mic_none,
    MediaAddSource.gallery => Icons.photo_library_outlined,
    MediaAddSource.file => Icons.folder_open_outlined,
  };

  String get _label => switch (source) {
    MediaAddSource.takeMedia => 'Take photos/videos',
    MediaAddSource.recordAudio => 'Record audio',
    MediaAddSource.gallery => 'Add from gallery',
    MediaAddSource.file => 'Add from file',
  };
}

class MediaViewerBuilder extends StatelessWidget {
  const MediaViewerBuilder({
    super.key,
    required this.images,
    this.isSelecting = false,
    this.selectedMedia = const {},
    this.onSelectionChanged,
  });

  final List<MediaData> images;
  final bool isSelecting;
  final Set<int> selectedMedia;
  final void Function(int id, bool selected)? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return CommonScrollbar(
      scrollController: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          controller: scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getCrossAxisCount(
              MediaQuery.of(context).size.width,
              imageSize,
            ),
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return MediaCard(
              media: images[index],
              isSelecting: isSelecting,
              isSelected: selectedMedia.contains(images[index].primaryId),
              onSelectionChanged: onSelectionChanged,
              onTap: isSelecting
                  ? null
                  : () => showMediaViewerDialog(
                      context,
                      mediaList: images,
                      initialIndex: index,
                    ),
            );
          },
        ),
      ),
    );
  }
}

class MediaCard extends ConsumerStatefulWidget {
  const MediaCard({
    super.key,
    required this.media,
    this.onTap,
    this.isSelecting = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  final MediaData media;
  final VoidCallback? onTap;
  final bool isSelecting;
  final bool isSelected;
  final void Function(int id, bool selected)? onSelectionChanged;

  @override
  MediaCardState createState() => MediaCardState();
}

class MediaCardState extends ConsumerState<MediaCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        GestureDetector(
          onTap: widget.isSelecting
              ? () => widget.onSelectionChanged?.call(
                  widget.media.primaryId,
                  !widget.isSelected,
                )
              : widget.onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: widget.media.fileName != null
                ? FutureBuilder<_MediaAssetPreview>(
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _MediaTypeFallback(
                          kind: _getMediaKind(),
                          label: 'Media unavailable',
                        );
                      }
                      if (snapshot.hasData) {
                        final mediaAsset = snapshot.data!;
                        if (!mediaAsset.exists) {
                          return _MediaTypeFallback(
                            kind: mediaAsset.kind,
                            label: 'File missing',
                          );
                        }
                        if (mediaAsset.file != null) {
                          return Image.file(
                            width: imageSize.toDouble(),
                            height: imageSize.toDouble(),
                            cacheWidth: imageSize + 100,
                            mediaAsset.file!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _MediaTypeFallback(
                                kind: mediaAsset.kind,
                                label: 'Image unavailable',
                              );
                            },
                          );
                        }
                        return _MediaTypeFallback(kind: mediaAsset.kind);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                    future: _getMediaPath(),
                    initialData: null,
                  )
                : const Center(child: Text('No media')),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(NahpuRadius.medium),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withAlpha((0.9 * 255).toInt()),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  dense: true,
                  minVerticalPadding: 12,
                  leading: widget.isSelecting
                      ? ListCheckBox(
                          isDisabled: false,
                          value: widget.isSelected,
                          isDense: true,
                          onChanged: (value) {
                            widget.onSelectionChanged?.call(
                              widget.media.primaryId,
                              value ?? false,
                            );
                          },
                        )
                      : Icon(_mediaKindIcon(_getMediaKind())),
                  title: Text(
                    widget.media.fileName ?? 'No media',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  trailing: widget.isSelecting
                      ? null
                      : MediaPopUpMenu(media: widget.media),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<_MediaAssetPreview> _getMediaPath() async {
    MediaCategory category = matchMediaCategoryString(
      widget.media.category ?? '',
    );
    final fileName = widget.media.fileName!;
    final kind = _getMediaKind();
    final mediaPath = await ImageServices(
      ref: ref,
      category: category,
    ).getMediaPath(fileName);
    final exists = await mediaPath.exists();

    return _MediaAssetPreview(
      file: kind == MediaKind.image ? mediaPath : null,
      kind: kind,
      exists: exists,
    );
  }

  MediaKind _getMediaKind() {
    return matchMediaKindFromPath(widget.media.fileName ?? '');
  }
}

IconData _mediaKindIcon(MediaKind kind) {
  return switch (kind) {
    MediaKind.image => Icons.image_outlined,
    MediaKind.audio => Icons.audio_file_outlined,
    MediaKind.video => Icons.video_file_outlined,
    MediaKind.other => Icons.insert_drive_file_outlined,
  };
}

class _MediaAssetPreview {
  const _MediaAssetPreview({
    required this.file,
    required this.kind,
    required this.exists,
  });

  final File? file;
  final MediaKind kind;
  final bool exists;
}

class _MediaTypeFallback extends StatelessWidget {
  const _MediaTypeFallback({required this.kind, this.label});

  final MediaKind kind;
  final String? label;

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.insert_drive_file_outlined;
    switch (kind) {
      case MediaKind.audio:
      case MediaKind.video:
        icon = Icons.play_circle_outline;
        break;
      case MediaKind.image:
        icon = Icons.image_outlined;
        break;
      case MediaKind.other:
        icon = Icons.insert_drive_file_outlined;
        break;
    }
    return Container(
      width: imageSize.toDouble(),
      height: imageSize.toDouble(),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label ?? matchMediaKindLabel(kind)),
          ],
        ),
      ),
    );
  }
}

enum _MediaMenuAction { edit, info, share, delete }

class MediaPopUpMenu extends ConsumerStatefulWidget {
  const MediaPopUpMenu({super.key, required this.media});

  final MediaData media;

  @override
  MediaPopUpMenuState createState() => MediaPopUpMenuState();
}

class MediaPopUpMenuState extends ConsumerState<MediaPopUpMenu> {
  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      Icons.more_vert,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    );
    if (MediaQuery.sizeOf(context).width < 600) {
      return IconButton(
        tooltip: 'Media actions',
        onPressed: _showActionSheet,
        icon: icon,
      );
    }
    return PopupMenuButton<_MediaMenuAction>(
      tooltip: 'Media actions',
      icon: icon,
      onSelected: _onSelected,
      itemBuilder: (context) => [
        for (final action in _MediaMenuAction.values) ...[
          if (action == _MediaMenuAction.delete) const PopupMenuDivider(),
          PopupMenuItem(
            value: action,
            child: _MediaMenuTile(action: action),
          ),
        ],
      ],
    );
  }

  Future<void> _showActionSheet() async {
    final action = await showModalBottomSheet<_MediaMenuAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in _MediaMenuAction.values) ...[
              if (action == _MediaMenuAction.delete) const Divider(),
              _MediaMenuTile(
                action: action,
                onTap: () => Navigator.of(context).pop(action),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action != null && mounted) {
      await _onSelected(action);
    }
  }

  Future<void> _onSelected(_MediaMenuAction action) async {
    switch (action) {
      case _MediaMenuAction.edit:
        await _showEditor();
        return;
      case _MediaMenuAction.info:
        await _showInfo();
        return;
      case _MediaMenuAction.share:
        await _shareFile();
        return;
      case _MediaMenuAction.delete:
        await _confirmDelete();
        return;
    }
  }

  Future<void> _showEditor() async {
    if (MediaQuery.sizeOf(context).width < 600) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 16,
            ),
            child: MediaEditForm(
              media: widget.media,
              onClose: () => Navigator.of(sheetContext).pop(),
            ),
          ),
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit media'),
        content: SizedBox(
          width: 560,
          child: MediaEditForm(
            media: widget.media,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      ),
    );
  }

  Future<void> _showInfo() async {
    if (MediaQuery.sizeOf(context).width < 600) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.85,
            child: Column(
              children: [
                Text(
                  'Media info',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                Expanded(child: MediaDetailsView(media: widget.media)),
              ],
            ),
          ),
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Media info'),
        content: SizedBox(
          width: 480,
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: MediaDetailsView(media: widget.media),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareFile() async {
    final category = matchMediaCategoryString(widget.media.category ?? '');
    final mediaPath = await ImageServices(
      ref: ref,
      category: category,
    ).getMediaPath(widget.media.fileName ?? '');
    if (mounted) {
      await FilePickerServices().shareFile(context, mediaPath);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete media file?'),
        content: Text(
          'Delete ${widget.media.fileName ?? 'this media file'} from all '
          'NAHPU records and from disk? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
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
    if (confirmed != true) return;
    try {
      await MediaServices(
        ref: ref,
      ).deleteMedia(widget.media.primaryId, widget.media.category ?? '');
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: error.toString().contains('File exists')
            ? const Text('File already exists')
            : Text(error.toString()),
      ),
    );
  }
}

class _MediaMenuTile extends StatelessWidget {
  const _MediaMenuTile({required this.action, this.onTap});

  final _MediaMenuAction action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDelete = action == _MediaMenuAction.delete;
    return ListTile(
      onTap: onTap,
      leading: Icon(_icon, color: isDelete ? _errorColor(context) : null),
      title: Text(
        _label,
        style: TextStyle(color: isDelete ? _errorColor(context) : null),
      ),
    );
  }

  Color _errorColor(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  IconData get _icon => switch (action) {
    _MediaMenuAction.edit => Icons.edit_outlined,
    _MediaMenuAction.info => Icons.info_outline,
    _MediaMenuAction.share => Icons.adaptive.share,
    _MediaMenuAction.delete => Icons.delete_outline,
  };

  String get _label => switch (action) {
    _MediaMenuAction.edit => 'Edit',
    _MediaMenuAction.info => 'Show info',
    _MediaMenuAction.share => 'Share',
    _MediaMenuAction.delete => 'Delete',
  };
}

class MediaEditForm extends ConsumerStatefulWidget {
  const MediaEditForm({super.key, required this.media, required this.onClose});

  final MediaData media;
  final VoidCallback onClose;

  @override
  ConsumerState<MediaEditForm> createState() => _MediaEditFormState();
}

class _MediaEditFormState extends ConsumerState<MediaEditForm> {
  late final TextEditingController _fileNameController;
  late final TextEditingController _captionController;
  late final TextEditingController _tagController;
  String? _photographerId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(
      text: path.basenameWithoutExtension(widget.media.fileName ?? ''),
    );
    _captionController = TextEditingController(
      text: widget.media.caption ?? '',
    );
    _tagController = TextEditingController(text: widget.media.tag ?? '');
    _photographerId = widget.media.personnelId;
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _captionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final people = ref.watch(projectPersonnelProvider).value ?? const [];
    final hasSelectedPerson = people.any(
      (person) => person.uuid == _photographerId,
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (MediaQuery.sizeOf(context).width < 600) ...[
            Text('Edit media', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _fileNameController,
            decoration: InputDecoration(
              labelText: 'File name',
              hintText: 'Enter a file name',
              suffixText: path.extension(widget.media.fileName ?? ''),
            ),
          ),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              labelText: 'Caption',
              hintText: 'Enter a caption',
            ),
            maxLines: 3,
          ),
          TextField(
            controller: _tagController,
            decoration: const InputDecoration(
              labelText: 'Tag',
              hintText: 'Enter a tag',
            ),
          ),
          DropdownButtonFormField<String>(
            key: ValueKey(_photographerId),
            initialValue: _photographerId,
            decoration: InputDecoration(
              labelText: 'Photographer',
              hintText: 'Select personnel',
              suffixIcon: _photographerId == null
                  ? null
                  : IconButton(
                      tooltip: 'Clear photographer',
                      onPressed: () => setState(() => _photographerId = null),
                      icon: const Icon(Icons.clear_rounded),
                    ),
            ),
            items: [
              if (_photographerId != null && !hasSelectedPerson)
                DropdownMenuItem(
                  value: _photographerId,
                  child: CommonDropdownText(text: _photographerId!),
                ),
              ...people.map(
                (person) => DropdownMenuItem(
                  value: person.uuid,
                  child: CommonDropdownText(text: person.name ?? person.uuid),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _photographerId = value),
          ),
          TextFormField(
            initialValue: widget.media.category ?? '',
            enabled: false,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SecondaryButton(onPressed: widget.onClose, text: 'Cancel'),
              const SizedBox(width: 8),
              PrimaryButton(
                onPressed: _isSaving ? null : _save,
                label: _isSaving ? 'Saving' : 'Save',
                icon: Icons.check,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await MediaServices(ref: ref).updateMediaDetails(
        media: widget.media,
        fileName: _fileNameController.text,
        caption: _captionController.text,
        tag: _tagController.text,
        personnelId: _photographerId,
      );
      if (mounted) widget.onClose();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: error.toString().contains('File exists')
              ? const Text('File already exists')
              : Text(error.toString()),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class MediaInfoContent extends StatelessWidget {
  const MediaInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          content:
              'Media files of the project. Use Add to take photos or videos,'
              ' record audio, or import supported media. Camera and gallery'
              ' actions are available on Android and iOS.',
        ),
      ],
    );
  }
}
