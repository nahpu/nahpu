import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/src/rust/api/images.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Writes a downscaled copy of [source] to [target].
typedef ThumbnailGenerator = Future<void> Function(File source, File target);

/// Caches small JPEG previews of record media outside project folders, so
/// galleries decode a few hundred kilobytes instead of full camera images.
class MediaThumbnailServices {
  MediaThumbnailServices({
    ThumbnailGenerator? generator,
    Future<Directory> Function()? cacheRoot,
    this.maxConcurrent = 4,
  }) : _generator = generator ?? _rustGenerator,
       _cacheRoot = cacheRoot ?? _defaultCacheRoot;

  /// Longest edge of a generated thumbnail, in pixels.
  static const int size = 768;

  final ThumbnailGenerator _generator;
  final Future<Directory> Function() _cacheRoot;
  final int maxConcurrent;
  final Map<String, Future<File?>> _inFlight = {};
  final Queue<Completer<void>> _waiting = Queue();
  int _running = 0;

  /// Returns the cached thumbnail for [source], generating it when missing.
  /// Returns null when the image cannot be converted.
  Future<File?> thumbnailFor(
    File source, {
    required String projectUuid,
    required String category,
  }) async {
    final FileStat stat;
    try {
      stat = await source.stat();
    } on FileSystemException {
      return null;
    }
    if (stat.type != FileSystemEntityType.file) return null;

    final target = File(
      p.join(
        (await _categoryDir(projectUuid, category)).path,
        cacheFileName(
          p.basename(source.path),
          modifiedMs: stat.modified.millisecondsSinceEpoch,
          bytes: stat.size,
        ),
      ),
    );
    if (await target.exists()) return target;
    return _inFlight.putIfAbsent(
      target.path,
      // A block body: returning the removed future would make whenComplete
      // wait on itself.
      () => _generate(source, target).whenComplete(() {
        _inFlight.remove(target.path);
      }),
    );
  }

  /// Removes cached thumbnails generated for [fileName].
  Future<void> deleteFor({
    required String projectUuid,
    required String category,
    required String fileName,
  }) async {
    final dir = await _categoryDir(projectUuid, category);
    if (!await dir.exists()) return;
    final pattern = RegExp(
      '^${RegExp.escape(p.basenameWithoutExtension(fileName))}'
      r'_\d+_\d+(\.part)?\.jpg$',
    );
    await for (final entity in dir.list()) {
      if (entity is File && pattern.hasMatch(p.basename(entity.path))) {
        await _tryDelete(entity);
      }
    }
  }

  /// Removes every cached thumbnail of a project.
  Future<void> deleteProject(String projectUuid) async {
    final dir = Directory(p.join((await _cacheRoot()).path, projectUuid));
    try {
      if (await dir.exists()) await dir.delete(recursive: true);
    } on FileSystemException catch (error) {
      if (kDebugMode) debugPrint('Thumbnail cleanup failed: $error');
    }
  }

  /// Cache file name for a source file; changes whenever the source does.
  @visibleForTesting
  static String cacheFileName(
    String sourceName, {
    required int modifiedMs,
    required int bytes,
  }) {
    return '${p.basenameWithoutExtension(sourceName)}_${modifiedMs}_$bytes.jpg';
  }

  Future<File?> _generate(File source, File target) async {
    await _acquire();
    // Keep the .jpg extension so the encoder sees a matching file type.
    final partial = File('${p.withoutExtension(target.path)}.part.jpg');
    try {
      await target.parent.create(recursive: true);
      await _generator(source, partial);
      return await partial.rename(target.path);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Thumbnail generation failed for ${source.path}: $error');
      }
      await _tryDelete(partial);
      return null;
    } finally {
      _release();
    }
  }

  Future<void> _acquire() async {
    if (_running < maxConcurrent) {
      _running++;
      return;
    }
    final slot = Completer<void>();
    _waiting.add(slot);
    await slot.future;
  }

  void _release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeFirst().complete();
    } else {
      _running--;
    }
  }

  Future<Directory> _categoryDir(String projectUuid, String category) async {
    return Directory(p.join((await _cacheRoot()).path, projectUuid, category));
  }

  Future<void> _tryDelete(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // A stale thumbnail only costs disk space; the key changes on reuse.
    }
  }

  static Future<Directory> _defaultCacheRoot() async {
    final cacheDir = await getApplicationCacheDirectory();
    return Directory(p.join(cacheDir.path, nahpuAppDir, 'thumbnails'));
  }

  static Future<void> _rustGenerator(File source, File target) async {
    await exportImage(
      inputPath: source.path,
      outputPath: target.path,
      outputFormat: ImageExportFormat.jpeg,
      resizeWidth: size,
      resizeHeight: size,
      jpegQuality: 80,
    );
  }
}
