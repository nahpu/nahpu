import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/screens/shared/media/media.dart';
import 'package:nahpu/screens/shared/media/media_gallery.dart';
import 'package:nahpu/screens/shared/media/audio_recorder.dart';
import 'package:nahpu/screens/shared/media/media_capture.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/narrative/narrative_services.dart';
import 'package:nahpu/services/types/import.dart';

class NarrativeMediaForm extends ConsumerStatefulWidget {
  const NarrativeMediaForm({super.key, required this.narrativeId});

  final int narrativeId;

  @override
  NarrativeMediaFormState createState() => NarrativeMediaFormState();
}

class NarrativeMediaFormState extends ConsumerState<NarrativeMediaForm> {
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
    return ref
        .watch(narrativeMediaProvider(widget.narrativeId))
        .when(
          data: (data) {
            return NarrativeMediaViewer(
              narrativeId: widget.narrativeId,
              data: List.from(data),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
        );
  }
}

class NarrativeMediaViewer extends ConsumerStatefulWidget {
  const NarrativeMediaViewer({
    super.key,
    required this.narrativeId,
    required this.data,
  });

  final int narrativeId;
  final List<MediaData> data;

  @override
  NarrativeMediaViewerState createState() => NarrativeMediaViewerState();
}

class NarrativeMediaViewerState extends ConsumerState<NarrativeMediaViewer> {
  @override
  Widget build(BuildContext context) {
    MediaCategory mediaCategory = MediaCategory.narrative;
    return MediaViewer(
      images: widget.data,
      onOpenGallery: () =>
          showMediaGallery(context, initialCategory: mediaCategory),
      onAddFromGallery: () async {
        try {
          List<String> images = await ImageServices(
            ref: ref,
            category: mediaCategory,
          ).pickMediaFromGallery();
          if (images.isNotEmpty) {
            await NarrativeServices(
              ref: ref,
            ).createNarrativeMediaFromList(widget.narrativeId, images);
            ref.invalidate(narrativeMediaProvider(widget.narrativeId));
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
            await NarrativeServices(
              ref: ref,
            ).createNarrativeMediaFromList(widget.narrativeId, mediaFiles);
            ref.invalidate(narrativeMediaProvider(widget.narrativeId));
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
          await NarrativeServices(
            ref: ref,
          ).createNarrativeMedia(widget.narrativeId, media);
          ref.invalidate(narrativeMediaProvider(widget.narrativeId));
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
          await NarrativeServices(
            ref: ref,
          ).createNarrativeMedia(widget.narrativeId, media);
          ref.invalidate(narrativeMediaProvider(widget.narrativeId));
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      },
    );
  }
}
