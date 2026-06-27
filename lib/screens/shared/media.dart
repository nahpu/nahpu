import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/media_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:drift/drift.dart' as db;
import 'package:path/path.dart' as path;

const int imageSize = 300;

class MediaViewer extends StatefulWidget {
  const MediaViewer({
    super.key,
    required this.images,
    required this.onAddFromGallery,
    required this.onAddFromFiles,
    required this.onAccessingCamera,
  });

  final List<MediaData> images;
  final VoidCallback onAddFromGallery;
  final VoidCallback onAddFromFiles;
  final VoidCallback onAccessingCamera;

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const TitleForm(
                text: 'Media',
                isCentered: false,
                infoContent: MediaInfoContent(),
              ),
              MediaButton(
                onAddFromGallery: widget.onAddFromGallery,
                onAddFromFiles: widget.onAddFromFiles,
                onAccessingCamera: widget.onAccessingCamera,
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: widget.images.isEmpty
                ? const EmptyMedia()
                : MediaViewerBuilder(images: widget.images),
          ),
        ),
      ],
    );
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

/// Display options to add media.
/// On mobile, secondary action opens gallery/files and primary action opens camera.
/// On desktop, primary action opens the file picker.
class MediaButton extends StatelessWidget {
  const MediaButton({
    super.key,
    required this.onAddFromGallery,
    required this.onAddFromFiles,
    required this.onAccessingCamera,
  });

  final VoidCallback onAddFromGallery;
  final VoidCallback onAddFromFiles;
  final VoidCallback onAccessingCamera;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: 8,
      children: [
        systemPlatform == PlatformType.mobile
            ? IconButton(
                onPressed: () {
                  _showImportSourceSheet(context);
                },
                icon: const Icon(Icons.add),
              )
            : const SizedBox.shrink(),
        PrimaryIconButton(
          onPressed: systemPlatform == PlatformType.mobile
              ? onAccessingCamera
              : onAddFromFiles,
          icon: systemPlatform == PlatformType.mobile
              ? Icons.camera_alt_outlined
              : Icons.attach_file_outlined,
        ),
      ],
    );
  }

  void _showImportSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onAddFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: const Text('Files'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onAddFromFiles();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class MediaViewerBuilder extends StatelessWidget {
  const MediaViewerBuilder({
    super.key,
    required this.images,
  });

  final List<MediaData> images;

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
              ctr: MediaFormCtr.fromData(images[index]),
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
    required this.ctr,
  });

  final MediaFormCtr ctr;

  @override
  MediaCardState createState() => MediaCardState();
}

class MediaCardState extends ConsumerState<MediaCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: widget.ctr.fileNameCtr != null
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
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                  future: _getMediaPath(),
                  initialData: null)
              : const Center(
                  child: Text('No media'),
                ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 0, 8, 0),
                color: Theme.of(context)
                    .scaffoldBackgroundColor
                    .withAlpha((0.9 * 255).toInt()),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  dense: true,
                  minVerticalPadding: 12,
                  title: Text(
                    widget.ctr.fileNameCtr ?? 'No media',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  subtitle: Text(
                    widget.ctr.captionCtr.text,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: MediaPopUpMenu(ctr: widget.ctr),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<_MediaAssetPreview> _getMediaPath() async {
    MediaCategory category =
        matchMediaCategoryString(widget.ctr.categoryCtr.text);
    final fileName = widget.ctr.fileNameCtr!;
    final kind = _getMediaKind();
    final mediaPath = await ImageServices(ref: ref, category: category)
        .getMediaPath(fileName);
    final exists = await mediaPath.exists();

    return _MediaAssetPreview(
      file: kind == MediaKind.image ? mediaPath : null,
      kind: kind,
      exists: exists,
    );
  }

  MediaKind _getMediaKind() {
    return matchMediaKindFromPath(widget.ctr.fileNameCtr ?? '');
  }
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
  const _MediaTypeFallback({
    required this.kind,
    this.label,
  });

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
      case MediaKind.pdf:
        icon = Icons.picture_as_pdf_outlined;
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

class MediaPopUpMenu extends ConsumerStatefulWidget {
  const MediaPopUpMenu({
    super.key,
    required this.ctr,
  });

  final MediaFormCtr ctr;

  @override
  MediaPopUpMenuState createState() => MediaPopUpMenuState();
}

class MediaPopUpMenuState extends ConsumerState<MediaPopUpMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MediaPopUpMenu>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      itemBuilder: (context) {
        return <PopupMenuEntry<MediaPopUpMenu>>[
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit details'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Edit Details'),
                      content: PhotoDetailForm(ctr: widget.ctr),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: Icon(
                Icons.edit_outlined,
              ),
              title: const Text(
                'Rename',
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController fileNameCtr = TextEditingController(
                        text: path.basenameWithoutExtension(
                            widget.ctr.fileNameCtr ?? ''));
                    return AlertDialog(
                      title: const Text('Rename'),
                      content: TextField(
                        controller: fileNameCtr,
                        decoration: InputDecoration(
                            labelText: 'File name',
                            hintText: 'Enter file name without extension',
                            suffix: fileNameCtr.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      fileNameCtr.clear();
                                    },
                                    icon: const Icon(Icons.clear_rounded),
                                  )
                                : null),
                      ),
                      actions: [
                        SecondaryButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                          text: 'Cancel',
                        ),
                        PrimaryButton(
                          onPressed: () async {
                            await _renameMedia(fileNameCtr);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          label: 'Rename',
                          icon: Icons.check,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          PopupMenuItem(
              child: ListTile(
            leading: Icon(Icons.adaptive.share),
            title: const Text('Share'),
            onTap: () async {
              MediaCategory category =
                  matchMediaCategoryString(widget.ctr.categoryCtr.text);
              File path = await ImageServices(ref: ref, category: category)
                  .getMediaPath(widget.ctr.fileNameCtr!);
              _shareFile(path);
            },
          )),
          const PopupMenuDivider(),
          PopupMenuItem(
            onTap: () async {
              await MediaServices(ref: ref).deleteMedia(
                widget.ctr.primaryId!,
                widget.ctr.categoryCtr.text,
              );
            },
            child: ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ),
        ];
      },
    );
  }

  void _shareFile(File path) {
    FilePickerServices().shareFile(context, path);
  }

  Future<void> _renameMedia(TextEditingController fileNameCtr) async {
    try {
      await MediaServices(ref: ref).renameMedia(
        widget.ctr.primaryId!,
        widget.ctr.fileNameCtr!,
        fileNameCtr.text,
        matchMediaCategoryString(widget.ctr.categoryCtr.text),
      );
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: e.toString().contains('File exists')
            ? const Text('File already exists')
            : Text(e.toString()),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class PhotoDetailForm extends ConsumerWidget {
  const PhotoDetailForm({
    super.key,
    required this.ctr,
  });

  final MediaFormCtr ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: ctr.captionCtr,
          decoration: InputDecoration(
            labelText: 'Caption',
            hintText: 'Enter caption',
            suffix: IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: Theme.of(context).disabledColor,
              ),
              onPressed: () {
                ctr.captionCtr.clear();
              },
            ),
          ),
          keyboardType: TextInputType.text,
          maxLines: 3,
          onChanged: (value) {
            if (value.isNotEmpty) {
              MediaServices(ref: ref).updateMedia(
                  ctr.primaryId!,
                  ctr.categoryCtr.text,
                  MediaCompanion(
                    caption: db.Value(value),
                  ));
            }
          },
        ),
        DropdownButtonFormField<String>(
          initialValue: ctr.photographerCtr,
          decoration: const InputDecoration(
            labelText: 'Photographer',
            hintText: 'Select Personnel',
          ),
          items: ref.watch(projectPersonnelProvider).when(
                data: (value) => value
                    .map((person) => DropdownMenuItem(
                          value: person.uuid,
                          child: CommonDropdownText(
                            text: person.name ?? '',
                          ),
                        ))
                    .toList(),
                loading: () => const [],
                error: (error, stack) => const [],
              ),
          onChanged: (String? value) {
            if (value != null) {
              MediaServices(ref: ref).updateMedia(
                  ctr.primaryId!,
                  ctr.categoryCtr.text,
                  MediaCompanion(
                    personnelId: db.Value(value),
                  ));
            }
          },
        ),
        const SizedBox(height: 24),
        ExifViewer(ctr: ctr),
      ],
    ));
  }
}

class ExifViewer extends StatelessWidget {
  const ExifViewer({super.key, required this.ctr});

  final MediaFormCtr ctr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getExtension(),
            // style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const SizedBox(height: 8),
        Text(ctr.cameraModelCtr.text, textAlign: TextAlign.center),
        Text(ctr.lenseModelCtr.text, textAlign: TextAlign.center),
        Text(ctr.additionalExifCtr.text, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        if (_parseDateTime().isNotEmpty)
          Text(
            _parseDateTime(),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  String _parseDateTime() {
    final value = parseMediaDateTime(ctr.dateTakenCtr.text);
    if (value.date.isEmpty && value.time.isEmpty) {
      return '';
    }
    return '${value.date}\n${value.time}';
  }

  String _getExtension() {
    String ext = path.extension(ctr.fileNameCtr!.toUpperCase());
    return ext.replaceFirst('.', '');
  }
}

class MediaInfoContent extends StatelessWidget {
  const MediaInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          content: 'Media files of the project.'
              ' On mobile, gallery and camera import images only.'
              ' Use Files to import audio, video, and PDF.',
        ),
      ],
    );
  }
}
