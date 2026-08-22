import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class TemplateImageService {
  const TemplateImageService();

  Future<Directory> _logosDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'template_images'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<String> addLogoFromFile(String sourcePath) async {
    final ext = p.extension(sourcePath).toLowerCase();
    return addLogoFromFileWithExtension(sourcePath, ext.isEmpty ? '.png' : ext);
  }

  Future<String> addLogoFromFileWithExtension(
    String sourcePath,
    String extension,
  ) async {
    final dir = await _logosDir();
    final id = const Uuid().v4();
    final dest = p.join(dir.path, '$id$extension');
    await File(sourcePath).copy(dest);
    return dest;
  }

  Future<List<String>> listLogoPaths() async {
    final dir = await _logosDir();
    return dir.listSync().whereType<File>().map((f) => f.path).toList()..sort();
  }
}
