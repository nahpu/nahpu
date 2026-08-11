import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';

/// Encodes, decodes, and writes project information exchanged between NAHPU
/// installations.
class ProjectExchangeService {
  const ProjectExchangeService();

  static String encode(ProjectData projectData) {
    return const JsonEncoder.withIndent('  ').convert(projectData.toJson());
  }

  static ProjectData decode(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map) {
        throw const FormatException('Project JSON must be an object.');
      }
      return ProjectData.fromJson(Map<String, dynamic>.from(decoded));
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('Invalid project JSON: $error');
    }
  }

  static String encodeQr(ProjectData projectData) {
    return jsonEncode(projectData.toJson());
  }

  Future<File> save(
    ProjectData projectData, {
    required String fileStem,
    Directory? destinationDirectory,
  }) async {
    final output = await AppIOServices(
      dir: destinationDirectory,
      fileStem: _safeFileStem(fileStem),
      ext: 'json',
    ).getSavePath();
    await output.writeAsString(encode(projectData));
    return output;
  }

  Future<ProjectData> read(XFile file) async {
    return decode(await File(file.path).readAsString());
  }

  static String _safeFileStem(String value) {
    final withoutExtension = value.trim().replaceFirst(
      RegExp(r'\.json$', caseSensitive: false),
      '',
    );
    final cleaned = withoutExtension
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'project-info' : cleaned;
  }
}
