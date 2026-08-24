import 'dart:io';

import 'package:nahpu/services/common/io_services.dart';
import 'package:path/path.dart' as p;

class TemplateImageService {
  const TemplateImageService();

  Future<Directory> _logosDir() async {
    return getTemplateMediaDirectory();
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
    final sourceName = p.basenameWithoutExtension(sourcePath).trim();
    final stem = sourceName.isEmpty ? 'image' : sourceName;
    final normalizedExtension = extension.startsWith('.')
        ? extension.toLowerCase()
        : '.${extension.toLowerCase()}';
    var dest = p.join(dir.path, '$stem$normalizedExtension');
    var suffix = 1;
    while (await File(dest).exists()) {
      dest = p.join(dir.path, '${stem}_$suffix$normalizedExtension');
      suffix++;
    }
    await File(sourcePath).copy(dest);
    return dest;
  }

  Future<List<String>> listLogoPaths() async {
    final dir = await _logosDir();
    final paths = await dir
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .map((file) => file.path)
        .toList();
    paths.sort(
      (a, b) =>
          p.basename(a).toLowerCase().compareTo(p.basename(b).toLowerCase()),
    );
    return paths;
  }
}
