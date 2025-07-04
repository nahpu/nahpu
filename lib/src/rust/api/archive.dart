// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.9.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class ZipExtractor {
  final String archivePath;
  final String outputDir;

  const ZipExtractor({
    required this.archivePath,
    required this.outputDir,
  });

  Future<void> extract() =>
      RustLib.instance.api.crateApiArchiveZipExtractorExtract(
        that: this,
      );

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<ZipExtractor> newInstance(
          {required String archivePath, required String outputDir}) =>
      RustLib.instance.api.crateApiArchiveZipExtractorNew(
          archivePath: archivePath, outputDir: outputDir);

  @override
  int get hashCode => archivePath.hashCode ^ outputDir.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZipExtractor &&
          runtimeType == other.runtimeType &&
          archivePath == other.archivePath &&
          outputDir == other.outputDir;
}

class ZipWriter {
  final String parentDir;
  final String? altParentDir;
  final List<String> files;
  final String outputPath;

  const ZipWriter({
    required this.parentDir,
    this.altParentDir,
    required this.files,
    required this.outputPath,
  });

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<ZipWriter> newInstance(
          {required String parentDir,
          required List<String> files,
          required String outputPath}) =>
      RustLib.instance.api.crateApiArchiveZipWriterNew(
          parentDir: parentDir, files: files, outputPath: outputPath);

  Future<void> write() => RustLib.instance.api.crateApiArchiveZipWriterWrite(
        that: this,
      );

  @override
  int get hashCode =>
      parentDir.hashCode ^
      altParentDir.hashCode ^
      files.hashCode ^
      outputPath.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZipWriter &&
          runtimeType == other.runtimeType &&
          parentDir == other.parentDir &&
          altParentDir == other.altParentDir &&
          files == other.files &&
          outputPath == other.outputPath;
}
