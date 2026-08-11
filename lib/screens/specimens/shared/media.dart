import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/media/media.dart';
import 'package:nahpu/screens/shared/media/media_gallery.dart';
import 'package:nahpu/screens/shared/media/audio_recorder.dart';
import 'package:nahpu/screens/shared/media/media_capture.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/import.dart';

class SpecimenMediaForm extends ConsumerStatefulWidget {
  const SpecimenMediaForm({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  SpecimenMediaFormState createState() => SpecimenMediaFormState();
}

class SpecimenMediaFormState extends ConsumerState<SpecimenMediaForm> {
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
    MediaCategory mediaCategory = MediaCategory.specimen;
    return ref
        .watch(specimenMediaProvider(widget.specimenUuid))
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
                    await SpecimenServices(
                      ref: ref,
                    ).createSpecimenMediaFromList(widget.specimenUuid, images);
                    _doneSelecting();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        duration: const Duration(seconds: 5),
                      ),
                    );
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
                    await SpecimenServices(
                      ref: ref,
                    ).createSpecimenMediaFromList(
                      widget.specimenUuid,
                      mediaFiles,
                    );
                    _doneSelecting();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        duration: const Duration(seconds: 5),
                      ),
                    );
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
                  await SpecimenServices(
                    ref: ref,
                  ).createSpecimenMediaFromList(widget.specimenUuid, [media]);
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
                  await SpecimenServices(
                    ref: ref,
                  ).createSpecimenMediaFromList(widget.specimenUuid, [media]);
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
        );
  }

  void _doneSelecting() {
    if (!mounted) return;
    ref.invalidate(specimenMediaProvider(widget.specimenUuid));
  }
}
