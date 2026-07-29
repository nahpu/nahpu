import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';

import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/image_service.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class TemplateEditorService {
  final TemplateImageService _logoService = const TemplateImageService();

  Future<String?> exportTemplate(Template template) async {
    final raw = template.name.trim();
    final safe = raw.isEmpty
        ? 'template'
        : raw.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final suggested = 'template_$safe.json';
    final location = await getSaveLocation(suggestedName: suggested);
    if (location == null) return null;
    final savePath = location.path;
    final out = savePath.toLowerCase().endsWith('.json')
        ? savePath
        : '$savePath.json';
    await const TemplateService().saveTemplate(template);
    await rust_config.exportTemplatePresetToFile(
      name: template.name,
      filePath: out,
    );
    return out;
  }

  Future<String?> copyPickedImageToLogos() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return null;
    final filePath = result.files.single.path;
    if (filePath == null) return null;
    final ext = result.files.single.extension;
    final added = ext != null && ext.isNotEmpty
        ? await _logoService.addLogoFromFile(filePath)
        : await _logoService.addLogoFromFileWithExtension(filePath, '.png');
    return added;
  }
}
