import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:path/path.dart' as path;

enum UserConfigFileFormat { json, jsonGzip }

extension UserConfigFileFormatLabel on UserConfigFileFormat {
  String get label => switch (this) {
    UserConfigFileFormat.json => 'JSON (.json)',
    UserConfigFileFormat.jsonGzip => 'JSON.GZ (.json.gz)',
  };

  String get extension => switch (this) {
    UserConfigFileFormat.json => 'json',
    UserConfigFileFormat.jsonGzip => 'json.gz',
  };
}

class UserConfigImportSource {
  const UserConfigImportSource({
    required this.input,
    required this.jsonFile,
    required this.preview,
    this.temporaryDirectory,
  });

  final XFile input;
  final File jsonFile;
  final rust_config.UserConfigTransferPreview preview;
  final Directory? temporaryDirectory;

  Future<void> dispose() async {
    final directory = temporaryDirectory;
    if (directory != null && directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  }
}

class UserConfigTransferService {
  const UserConfigTransferService();

  Future<rust_config.UserConfigTransferPreview> currentPreview() {
    return rust_config.getConfigExportPreview();
  }

  Future<File> export({
    required File output,
    required UserConfigFileFormat format,
    required Set<rust_config.UserConfigSection> sections,
  }) async {
    _requireSections(sections);
    if (format == UserConfigFileFormat.json) {
      await rust_config.exportConfigToFile(
        filePath: output.path,
        sections: sections.toList(growable: false),
      );
      return output;
    }

    final staging = Directory.systemTemp.createTempSync('nahpu-config-export-');
    try {
      final jsonFile = File(path.join(staging.path, 'user-configs.json'));
      await rust_config.exportConfigToFile(
        filePath: jsonFile.path,
        sections: sections.toList(growable: false),
      );
      final writer = await GzipWriter.newInstance(
        inputPath: jsonFile.path,
        outputPath: output.path,
      );
      await writer.write();
      return output;
    } finally {
      if (staging.existsSync()) await staging.delete(recursive: true);
    }
  }

  Future<UserConfigImportSource> inspect(XFile input) async {
    final lowerPath = input.path.toLowerCase();
    if (lowerPath.endsWith('.json')) {
      final jsonFile = File(input.path);
      final preview = await rust_config.inspectConfigFile(
        filePath: jsonFile.path,
      );
      return UserConfigImportSource(
        input: input,
        jsonFile: jsonFile,
        preview: preview,
      );
    }
    if (!lowerPath.endsWith('.json.gz')) {
      throw const FormatException(
        'Choose a NAHPU user-config JSON or JSON.GZ file.',
      );
    }

    final staging = Directory.systemTemp.createTempSync('nahpu-config-import-');
    try {
      final jsonFile = File(path.join(staging.path, 'user-configs.json'));
      final extractor = await GzipExtractor.newInstance(
        archivePath: input.path,
        outputPath: jsonFile.path,
      );
      await extractor.extract();
      final preview = await rust_config.inspectConfigFile(
        filePath: jsonFile.path,
      );
      return UserConfigImportSource(
        input: input,
        jsonFile: jsonFile,
        preview: preview,
        temporaryDirectory: staging,
      );
    } catch (_) {
      if (staging.existsSync()) await staging.delete(recursive: true);
      rethrow;
    }
  }

  Future<void> import(
    UserConfigImportSource source,
    Set<rust_config.UserConfigSection> sections,
  ) {
    _requireSections(sections);
    return rust_config.importConfigFromFile(
      filePath: source.jsonFile.path,
      sections: sections.toList(growable: false),
    );
  }

  void _requireSections(Set<rust_config.UserConfigSection> sections) {
    if (sections.isEmpty) {
      throw ArgumentError('Select at least one user configuration section.');
    }
  }
}
