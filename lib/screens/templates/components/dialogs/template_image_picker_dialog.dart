import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/image_service.dart';
import 'package:path/path.dart' as path;
import 'package:nahpu/services/localization/l10n.dart';

class TemplateImagePickerDialog extends StatelessWidget {
  const TemplateImagePickerDialog({
    super.key,
    required this.onUpload,
    required this.onImageSelected,
  });

  final VoidCallback onUpload;
  final ValueChanged<String> onImageSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.templateAddImage),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(context.l10n.templateUploadFromDevice),
              subtitle: Text(context.l10n.templateUploadFromDeviceBody),
              onTap: onUpload,
            ),
            const Divider(height: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Text(
                context.l10n.templateSavedImages,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: const TemplateImageService().listLogoPaths(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final paths = snapshot.data ?? [];
                  if (paths.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.templateNoSavedImages,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: paths.length,
                    separatorBuilder: (_, _) => const Divider(height: 2),
                    itemBuilder: (_, index) {
                      final imagePath = paths[index];
                      return ListTile(
                        leading: _TemplateImageThumb(imagePath: imagePath),
                        title: Text(
                          path.basename(imagePath),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onImageSelected(imagePath),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonClose),
        ),
      ],
    );
  }
}

class _TemplateImageThumb extends StatelessWidget {
  const _TemplateImageThumb({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: isTemplateImagePathUsable(imagePath)
          ? Image.file(
              File(imagePath),
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.broken_image_outlined),
              ),
            )
          : const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.broken_image_outlined),
            ),
    );
  }
}
