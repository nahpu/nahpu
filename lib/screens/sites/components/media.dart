import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/media.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/site_services.dart';
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
    return ref.watch(siteMediaProvider(widget.siteId)).when(
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
                    await SiteServices(ref: ref).createSiteMediaFromList(
                      widget.siteId,
                      images,
                    );
                    _doneSelecting();
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
                  String? image = await ImageServices(
                    ref: ref,
                    category: mediaCategory,
                  ).accessCamera();
                  if (image != null) {
                    await SiteServices(ref: ref).createSiteMedia(
                      widget.siteId,
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
          loading: () => const CommonProgressIndicator(),
          error: (e, s) => Text(
            e.toString(),
          ),
        );
  }

  void _doneSelecting() {
    setState(() {});
  }
}
