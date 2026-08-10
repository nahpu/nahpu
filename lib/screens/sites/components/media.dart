import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/media/media.dart';
import 'package:nahpu/screens/shared/media/media_gallery.dart';
import 'package:nahpu/screens/shared/media/audio_recorder.dart';
import 'package:nahpu/screens/shared/media/media_capture.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/types/import.dart';

class SiteMediaForm extends ConsumerStatefulWidget {
  const SiteMediaForm({super.key, required this.siteId});

  final int siteId;

  @override
  SiteMediaFormState createState() => SiteMediaFormState();
}

class SiteMediaFormState extends ConsumerState<SiteMediaForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaCategory mediaCategory = MediaCategory.site;
    return ref
        .watch(siteMediaProvider(widget.siteId))
        .when(
          data: (data) {
            return MediaViewer(
              images: List.from(data),
              onOpenGallery: () =>
                  showMediaGallery(context, initialCategory: mediaCategory),
              onAddFromGallery: () async {
                try {
                  List<String> images = await ImageServices(
                    ref: ref,
                    category: mediaCategory,
                  ).pickMediaFromGallery();
                  if (images.isNotEmpty) {
                    await SiteServices(
                      ref: ref,
                    ).createSiteMediaFromList(widget.siteId, images);
                    _doneSelecting();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              onAddFromFiles: () async {
                try {
                  List<String> mediaFiles = await ImageServices(
                    ref: ref,
                    category: mediaCategory,
                  ).pickMediaFromFiles();
                  if (mediaFiles.isNotEmpty) {
                    await SiteServices(
                      ref: ref,
                    ).createSiteMediaFromList(widget.siteId, mediaFiles);
                    _doneSelecting();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              onTakeMedia: () async {
                try {
                  final captured = await showMediaCapture(context);
                  if (captured == null) return;
                  final media = await ImageServices(
                    ref: ref,
                    category: mediaCategory,
                  ).importCapturedMedia(captured);
                  await SiteServices(
                    ref: ref,
                  ).createSiteMedia(widget.siteId, media);
                  _doneSelecting();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              onRecordAudio: () async {
                try {
                  final recording = await showAudioRecorder(context);
                  if (recording == null) return;
                  final media = await ImageServices(
                    ref: ref,
                    category: mediaCategory,
                  ).importCapturedMedia(recording);
                  await SiteServices(
                    ref: ref,
                  ).createSiteMedia(widget.siteId, media);
                  _doneSelecting();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
            );
          },
          loading: () => const CommonProgressIndicator(),
          error: (e, s) => Text(e.toString()),
        );
  }

  void _doneSelecting() {
    if (!mounted) return;
    ref.invalidate(siteMediaProvider(widget.siteId));
  }
}
