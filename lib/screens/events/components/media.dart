import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/media/media.dart';
import 'package:nahpu/screens/shared/media/media_gallery.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/types/import.dart';

class EventMediaForm extends ConsumerWidget {
  const EventMediaForm({super.key, required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(eventMediaProvider(eventId))
        .when(
          data: (media) => MediaViewer(
            images: media,
            onOpenGallery: () =>
                showMediaGallery(context, initialCategory: MediaCategory.event),
            onAddFromGallery: () => _addFromGallery(context, ref),
            onAddFromFiles: () => _addFromFiles(context, ref),
            onAccessingCamera: () => _addFromCamera(context, ref),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stack) => Center(child: Text(error.toString())),
        );
  }

  Future<void> _addFromGallery(BuildContext context, WidgetRef ref) async {
    await _guard(context, () async {
      final files = await ImageServices(
        ref: ref,
        category: MediaCategory.event,
      ).pickFromGallery();
      if (files.isNotEmpty) {
        await CollEventServices(
          ref: ref,
        ).createEventMediaFromList(eventId, files);
      }
    });
  }

  Future<void> _addFromFiles(BuildContext context, WidgetRef ref) async {
    await _guard(context, () async {
      final files = await ImageServices(
        ref: ref,
        category: MediaCategory.event,
      ).pickMediaFromFiles();
      if (files.isNotEmpty) {
        await CollEventServices(
          ref: ref,
        ).createEventMediaFromList(eventId, files);
      }
    });
  }

  Future<void> _addFromCamera(BuildContext context, WidgetRef ref) async {
    await _guard(context, () async {
      final file = await ImageServices(
        ref: ref,
        category: MediaCategory.event,
      ).accessCamera();
      if (file != null) {
        await CollEventServices(ref: ref).createEventMedia(eventId, file);
      }
    });
  }

  Future<void> _guard(
    BuildContext context,
    Future<void> Function() callback,
  ) async {
    try {
      await callback();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}
