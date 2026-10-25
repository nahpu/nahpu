import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/media/media_batch_export.dart';
import 'package:nahpu/screens/shared/media/media_details.dart';
import 'package:nahpu/screens/shared/media/media_export_dialog.dart';
import 'package:nahpu/screens/shared/media/media_viewer_dialog.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/media/media_services.dart';
import 'package:nahpu/services/media/media_export_service.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as path;
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

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
                infoTopic: InfoTopic.media,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: widget.onOpenGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(context.l10n.mediaGallery),
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
            selectionAction: _selectedMedia.isEmpty
                ? null
                : TextButton(
                    onPressed: _showSelectedMediaActions,
                    child: Text(context.l10n.mediaActions),
                  ),
          ),
        ),
        SizedBox(
          height:
              widget.contentHeight ?? MediaQuery.of(context).size.height * 0.5,
          child: widget.images.isEmpty
              ? const Center(child: EmptyMedia())
              : MediaViewerBuilder(
                  images: widget.images,
                  isSelecting: _isSelecting,
                  selectedMedia: _selectedMedia,
                  onSelectionChanged: _toggleSelection,
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

  Future<void> _showSelectedMediaActions() async {
    final selected = widget.images
        .where((media) => _selectedMedia.contains(media.primaryId))
        .toList(growable: false);
    if (selected.isEmpty) return;
    final action = await _showMediaSelectionActionPicker(
      context,
      selected.length,
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _MediaSelectionAction.export:
        await showBatchMediaExport(context, media: selected);
        return;
      case _MediaSelectionAction.delete:
        await _confirmDeleteSelectedMedia();
        return;
    }
  }

  Future<void> _confirmDeleteSelectedMedia() async {
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
              context.l10n.commonDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _deleteSelectedMedia();
  }

  Future<void> _deleteSelectedMedia() async {
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

enum _MediaSelectionAction { export, delete }

Future<_MediaSelectionAction?> _showMediaSelectionActionPicker(
  BuildContext context,
  int selectedCount,
) {
  final content = _MediaSelectionActionPicker(selectedCount: selectedCount);
  if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
    return showModalBottomSheet<_MediaSelectionAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(child: content),
    );
  }
  return showDialog<_MediaSelectionAction>(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(
        NahpuSpacing.md,
        NahpuSpacing.lg,
        NahpuSpacing.md,
        NahpuSpacing.md,
      ),
      content: SizedBox(width: 400, child: content),
    ),
  );
}

class _MediaSelectionActionPicker extends StatelessWidget {
  const _MediaSelectionActionPicker({required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.lg,
            NahpuSpacing.sm,
            NahpuSpacing.lg,
            NahpuSpacing.md,
          ),
          child: Text(
            context.l10n.mediaSelectedCount(selectedCount),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.file_upload_outlined),
          title: Text(context.l10n.commonExport),
          onTap: () => Navigator.of(context).pop(_MediaSelectionAction.export),
        ),
        const Divider(),
        ListTile(
          leading: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            context.l10n.commonDelete,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          onTap: () => Navigator.of(context).pop(_MediaSelectionAction.delete),
        ),
      ],
    );
  }
}

class EmptyMedia extends StatelessWidget {
  const EmptyMedia({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonEmptyForm(
      iconPath: 'assets/icons/image-gallery.svg',
      text: context.l10n.mediaNoneAdded,
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
      label: context.l10n.sharedAdd,
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
              title: Text(context.l10n.mediaAdd),
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
      title: Text(_label(context.l10n)),
    );
  }

  IconData get _icon => switch (source) {
    MediaAddSource.takeMedia => Icons.photo_camera_outlined,
    MediaAddSource.recordAudio => Icons.mic_none,
    MediaAddSource.gallery => Icons.photo_library_outlined,
    MediaAddSource.file => Icons.folder_open_outlined,
  };

  String _label(AppLocalizations l10n) => switch (source) {
    MediaAddSource.takeMedia => l10n.mediaTakePhotosVideos,
    MediaAddSource.recordAudio => l10n.mediaRecordAudio,
    MediaAddSource.gallery => l10n.mediaAddFromGallery,
    MediaAddSource.file => l10n.mediaAddFromFile,
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
                          label: context.l10n.mediaUnavailable,
                        );
                      }
                      if (snapshot.hasData) {
                        final mediaAsset = snapshot.data!;
                        if (!mediaAsset.exists) {
                          return _MediaTypeFallback(
                            kind: mediaAsset.kind,
                            label: context.l10n.mediaFileMissing,
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
                                label: context.l10n.mediaImageUnavailable,
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
                : Center(child: Text(context.l10n.mediaNone)),
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
                Radius.circular(NahpuRadius.md),
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
                    widget.media.fileName ?? context.l10n.mediaNone,
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
    ).getProjectMediaPath(fileName, widget.media.projectUuid ?? '');
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
            Text(label ?? kind.localizedLabel(context.l10n)),
          ],
        ),
      ),
    );
  }
}

enum _MediaMenuAction { edit, info, export, share, delete }

class MediaPopUpMenu extends ConsumerStatefulWidget {
  const MediaPopUpMenu({super.key, required this.media});

  final MediaData media;

  @override
  MediaPopUpMenuState createState() => MediaPopUpMenuState();
}

class MediaPopUpMenuState extends ConsumerState<MediaPopUpMenu> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveMenuButton<_MediaMenuAction>(
      tooltip: context.l10n.mediaMenuActions,
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      itemBuilder: _items,
      onSelected: _onSelected,
    );
  }

  List<AdaptiveMenuItem<_MediaMenuAction>> _items() => [
    AdaptiveMenuItem(
      value: _MediaMenuAction.edit,
      icon: Icons.edit_outlined,
      label: context.l10n.commonEdit,
    ),
    AdaptiveMenuItem(
      value: _MediaMenuAction.info,
      icon: Icons.info_outline,
      label: context.l10n.mediaShowInfo,
    ),
    AdaptiveMenuItem(
      value: _MediaMenuAction.export,
      icon: Icons.file_upload_outlined,
      label: context.l10n.commonExport,
      hasDividerBefore: true,
    ),
    AdaptiveMenuItem(
      value: _MediaMenuAction.share,
      icon: Icons.adaptive.share,
      label: context.l10n.sharedShare,
    ),
    AdaptiveMenuItem(
      value: _MediaMenuAction.delete,
      icon: Icons.delete_outline,
      label: context.l10n.commonDelete,
      isDestructive: true,
      hasDividerBefore: true,
    ),
  ];

  Future<void> _onSelected(_MediaMenuAction action) async {
    switch (action) {
      case _MediaMenuAction.edit:
        await _showEditor();
        return;
      case _MediaMenuAction.info:
        await _showInfo();
        return;
      case _MediaMenuAction.export:
        await _showExport();
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
        title: Text(context.l10n.mediaEdit),
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
                  context.l10n.mediaInfo,
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
        title: Text(context.l10n.mediaInfo),
        content: SizedBox(
          width: 480,
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: MediaDetailsView(media: widget.media),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.commonClose),
          ),
        ],
      ),
    );
  }

  Future<void> _shareFile() async {
    final category = matchMediaCategoryString(widget.media.category ?? '');
    final mediaPath = await ImageServices(ref: ref, category: category)
        .getProjectMediaPath(
          widget.media.fileName ?? '',
          widget.media.projectUuid ?? '',
        );
    if (mounted) {
      await FilePickerServices().shareFile(context, mediaPath);
    }
  }

  Future<void> _showExport() async {
    final service = MediaExportService(ref: ref);
    await showMediaExportDialog(
      context: context,
      prepare: () => service.prepare(widget.media),
      onExport:
          ({
            required source,
            required format,
            required fileStem,
            destinationDirectory,
            width,
            height,
            required jpegQuality,
          }) => service.export(
            source: source,
            format: format,
            fileStem: fileStem,
            destinationDirectory: destinationDirectory,
            width: width,
            height: height,
            jpegQuality: jpegQuality,
          ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.mediaDeleteFileTitle),
        content: Text(
          widget.media.fileName == null
              ? context.l10n.mediaDeleteThisFileBody
              : context.l10n.mediaDeleteFileBody(widget.media.fileName!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              context.l10n.commonDelete,
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
            ? Text(context.l10n.mediaFileAlreadyExists)
            : Text(error.toString()),
      ),
    );
  }
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
    final people =
        ref
            .watch(personnelByProjectProvider(widget.media.projectUuid ?? ''))
            .value ??
        const [];
    final hasSelectedPerson = people.any(
      (person) => person.uuid == _photographerId,
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (MediaQuery.sizeOf(context).width < 600) ...[
            Text(
              context.l10n.mediaEdit,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _fileNameController,
            decoration: InputDecoration(
              labelText: context.l10n.mediaFileName,
              hintText: context.l10n.mediaFileNameHint,
              suffixText: path.extension(widget.media.fileName ?? ''),
            ),
          ),
          TextField(
            controller: _captionController,
            decoration: InputDecoration(
              labelText: context.l10n.mediaCaption,
              hintText: context.l10n.mediaCaptionHint,
            ),
            maxLines: 3,
          ),
          TextField(
            controller: _tagController,
            decoration: InputDecoration(
              labelText: context.l10n.mediaTag,
              hintText: context.l10n.mediaTagHint,
            ),
          ),
          DropdownButtonFormField<String>(
            key: ValueKey(_photographerId),
            initialValue: _photographerId,
            decoration: InputDecoration(
              labelText: context.l10n.mediaPhotographer,
              hintText: context.l10n.mediaSelectPersonnel,
              suffixIcon: _photographerId == null
                  ? null
                  : IconButton(
                      tooltip: context.l10n.mediaClearPhotographer,
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
            decoration: InputDecoration(
              labelText: context.l10n.parasiteCategory,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SecondaryButton(
                onPressed: widget.onClose,
                text: context.l10n.commonCancel,
              ),
              const SizedBox(width: 8),
              PrimaryButton(
                onPressed: _isSaving ? null : _save,
                label: _isSaving
                    ? context.l10n.specimenSaving
                    : context.l10n.commonSave,
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
              ? Text(context.l10n.mediaFileAlreadyExists)
              : Text(error.toString()),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
