import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/screens/shared/media.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/types/import.dart';

class NarrativeMediaForm extends ConsumerStatefulWidget {
  const NarrativeMediaForm({
    super.key,
    required this.narrativeId,
  });

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
    return ref.watch(narrativeMediaProvider(widget.narrativeId)).when(
          data: (data) {
            return NarrativeMediaViewer(
              narrativeId: widget.narrativeId,
              data: List.from(data),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              error.toString(),
            ),
          ),
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
      onAddFromGallery: () async {
        try {
          List<String> images =
              await ImageServices(ref: ref, category: mediaCategory)
                  .pickFromGallery();
          if (images.isNotEmpty) {
            await NarrativeServices(ref: ref).createNarrativeMediaFromList(
              widget.narrativeId,
              images,
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.toString(),
                ),
              ),
            );
          }
        }
      },
      onAccessingCamera: () async {
        try {
          String? image = await ImageServices(ref: ref, category: mediaCategory)
              .accessCamera();
          if (image != null) {
            await NarrativeServices(ref: ref).createNarrativeMedia(
              widget.narrativeId,
              image,
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.toString(),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
