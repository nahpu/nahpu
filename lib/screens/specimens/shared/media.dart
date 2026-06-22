import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/media.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/specimen_services.dart';
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
    return ref.watch(specimenMediaProvider(widget.specimenUuid)).when(
          data: (data) {
            return MediaViewer(
              images: List.from(data),
              onAddFromGallery: () async {
                try {
                  List<String> images = await ImageServices(
                    ref: ref,
                    category: mediaCategory,
                  ).pickFromGallery();
                  if (images.isNotEmpty) {
                    for (String path in images) {
                      await SpecimenServices(ref: ref).createSpecimenMedia(
                        widget.specimenUuid,
                        path,
                      );
                    }
                    setState(() {});
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString(),
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              onAccessingCamera: () async {
                try {
                  String? image = await ImageServices(
                    ref: ref,
                    category: mediaCategory,
                  ).accessCamera();
                  if (image != null) {
                    await SpecimenServices(ref: ref).createSpecimenMedia(
                      widget.specimenUuid,
                      image,
                    );
                  }
                  setState(() {});
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
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text(
              error.toString(),
            ),
          ),
        );
  }
}
