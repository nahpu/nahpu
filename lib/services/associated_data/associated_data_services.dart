import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:mime/mime.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/providers/associated_data.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:path/path.dart' as path;

const associatedDataMediaFileMessage =
    'This file type is supported by Media. '
    'Add it to the Media section instead.';

class AssociatedDataMediaFileException implements Exception {
  const AssociatedDataMediaFileException();

  @override
  String toString() => associatedDataMediaFileMessage;
}

class AssociatedDataFileValidator {
  const AssociatedDataFileValidator();

  Future<void> validate(File file) async {
    final handle = file.openSync();
    late final List<int> header;
    try {
      header = handle.readSync(defaultMagicNumbersMaxLength);
    } finally {
      handle.closeSync();
    }
    final mimeType = lookupMimeType(file.path, headerBytes: header);
    final mediaMimeTypes = mediaFmt.mimeTypes ?? const <String>[];
    if (isSupportedMediaPath(file.path) ||
        (mimeType != null && mediaMimeTypes.contains(mimeType))) {
      throw const AssociatedDataMediaFileException();
    }
  }
}

class AssociatedDataServices extends AppServices {
  const AssociatedDataServices({required super.ref});

  Future<List<AssociatedDataData>> getAssociatedData(
    AssociatedDataTarget target,
  ) {
    return AssociatedDataQuery(dbAccess).getAssociatedDataForTarget(target);
  }

  Future<List<AssociatedDataData>> getProjectAssociatedData() {
    return AssociatedDataQuery(
      dbAccess,
    ).getAssociatedDataForProject(currentProjectUuid);
  }

  Future<int> createAssociatedData({
    required AssociatedDataTarget target,
    required AssociatedDataCompanion form,
    File? selectedFile,
    AssociatedDataFileStorageMode storageMode =
        AssociatedDataFileStorageMode.copyToProject,
  }) async {
    final prepared = await _prepareFile(
      origin: target.origin,
      form: form,
      selectedFile: selectedFile,
      storageMode: storageMode,
    );
    try {
      final id = await AssociatedDataQuery(
        dbAccess,
      ).createDataAssociation(target, prepared.form);
      _invalidate(target);
      return id;
    } catch (_) {
      await _deleteCopiedFile(prepared.copiedFile);
      rethrow;
    }
  }

  Future<void> updateAssociatedData({
    required AssociatedDataTarget target,
    required int associatedDataId,
    required AssociatedDataCompanion form,
    File? selectedFile,
    AssociatedDataFileStorageMode storageMode =
        AssociatedDataFileStorageMode.copyToProject,
  }) async {
    final query = AssociatedDataQuery(dbAccess);
    final previous = await query.getAssociatedDataById(associatedDataId);
    if (previous == null) {
      throw StateError('Associated data no longer exists.');
    }
    final prepared = await _prepareFile(
      origin: _originFromStorageKey(previous.uri) ?? target.origin,
      form: form,
      selectedFile: selectedFile,
      storageMode: storageMode,
    );
    try {
      await query.updateAssociatedData(associatedDataId, prepared.form);
    } catch (_) {
      await _deleteCopiedFile(prepared.copiedFile);
      rethrow;
    }

    final nextType = prepared.form.type.present
        ? prepared.form.type.value
        : previous.type;
    final nextUri = prepared.form.uri.present
        ? prepared.form.uri.value
        : previous.uri;
    if (previous.type == 'File' &&
        (nextType != 'File' || previous.uri != nextUri)) {
      await cleanupManagedFileIfUnused(previous);
    }
    _invalidate(target);
  }

  Future<int> createProjectAssociatedData(AssociatedDataCompanion form) async {
    final id = await AssociatedDataQuery(dbAccess).createProjectAssociatedData(
      form.copyWith(projectUuid: db.Value(currentProjectUuid)),
    );
    ref.invalidate(associatedDataProvider);
    return id;
  }

  Future<void> linkToTarget(int id, AssociatedDataTarget target) async {
    await AssociatedDataQuery(dbAccess).linkToTarget(id, target);
    _invalidate(target);
  }

  Future<void> detachFromTarget(
    int associatedDataId,
    AssociatedDataTarget target,
  ) async {
    final query = AssociatedDataQuery(dbAccess);
    final data = await query.getAssociatedDataById(associatedDataId);
    final deleted = await query.detachFromTarget(associatedDataId, target);
    if (deleted && data != null) {
      await cleanupManagedFileIfUnused(data);
    }
    _invalidate(target);
  }

  Future<List<AssociatedDataData>> detachAllFromTarget(
    AssociatedDataTarget target, {
    bool cleanupFiles = true,
  }) async {
    final query = AssociatedDataQuery(dbAccess);
    final ids = await query.getAssociatedDataIdsForTarget(target);
    final orphaned = <AssociatedDataData>[];
    for (final id in ids) {
      final data = await query.getAssociatedDataById(id);
      final deleted = await query.detachFromTarget(id, target);
      if (deleted && data != null) {
        orphaned.add(data);
        if (cleanupFiles) await cleanupManagedFileIfUnused(data);
      }
    }
    _invalidate(target);
    return orphaned;
  }

  Future<void> deleteAssociatedData(int associatedDataId) async {
    final query = AssociatedDataQuery(dbAccess);
    final data = await query.getAssociatedDataById(associatedDataId);
    await query.deleteAssociatedData(associatedDataId);
    if (data != null) {
      await cleanupManagedFileIfUnused(data);
    }
    ref.invalidate(associatedDataProvider);
  }

  Future<bool> isFileUsed(File file) async {
    final query = AssociatedDataQuery(dbAccess);
    final fileUri = _fileUri(file);
    if (await query.isFileUsed(fileUri)) return true;
    final root = await nahpuDocumentDir;
    final absoluteRoot = path.absolute(root.path);
    final absoluteFile = path.absolute(file.path);
    if (!path.isWithin(absoluteRoot, absoluteFile)) {
      return false;
    }
    final segments = path.split(
      path.relative(absoluteFile, from: absoluteRoot),
    );
    if (segments.length < 3 || segments[1] != associatedDataDir) return false;
    final storageKey = path.joinAll(segments.skip(2)).replaceAll('\\', '/');
    return query.isFileUsed(storageKey, projectUuid: segments.first);
  }

  Future<File> resolveFile(AssociatedDataData data) async {
    if (data.type != 'File' || data.uri == null || data.uri!.trim().isEmpty) {
      throw const FormatException('Associated data has no file.');
    }
    final uri = Uri.tryParse(data.uri!);
    if (uri?.scheme == 'file') {
      return File.fromUri(uri!);
    }
    final projectUuid = data.projectUuid;
    if (projectUuid == null) {
      throw const FormatException('Associated data has no project.');
    }
    return FileServices(
      ref: ref,
    ).resolveAssociatedDataFile(projectUuid, data.uri!);
  }

  bool isExternalFile(AssociatedDataData data) {
    return data.type == 'File' &&
        Uri.tryParse(data.uri ?? '')?.scheme == 'file';
  }

  Future<({AssociatedDataCompanion form, File? copiedFile})> _prepareFile({
    required AssociatedDataOrigin origin,
    required AssociatedDataCompanion form,
    required File? selectedFile,
    required AssociatedDataFileStorageMode storageMode,
  }) async {
    if (selectedFile == null) return (form: form, copiedFile: null);

    await const AssociatedDataFileValidator().validate(selectedFile);
    if (storageMode == AssociatedDataFileStorageMode.linkOriginal) {
      return (
        form: form.copyWith(uri: db.Value(_fileUri(selectedFile))),
        copiedFile: null,
      );
    }

    final copied = await FileServices(
      ref: ref,
    ).copyAssociatedDataFile(selectedFile, origin);
    final key = await FileServices(ref: ref).associatedDataStorageKey(copied);
    return (form: form.copyWith(uri: db.Value(key)), copiedFile: copied);
  }

  Future<void> cleanupManagedFileIfUnused(AssociatedDataData data) async {
    final uri = data.uri;
    final projectUuid = data.projectUuid;
    if (data.type != 'File' ||
        uri == null ||
        uri.isEmpty ||
        projectUuid == null ||
        isExternalFile(data) ||
        await AssociatedDataQuery(
          dbAccess,
        ).isFileUsed(uri, projectUuid: projectUuid)) {
      return;
    }
    try {
      final file = await resolveFile(data);
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (_) {
      return;
    } on FormatException catch (_) {
      return;
    }
  }

  AssociatedDataOrigin? _originFromStorageKey(String? storageKey) {
    if (storageKey == null || Uri.tryParse(storageKey)?.scheme == 'file') {
      return null;
    }
    final firstSegment = storageKey.replaceAll('\\', '/').split('/').first;
    return switch (firstSegment) {
      associatedDataSitesDir => AssociatedDataOrigin.sites,
      associatedDataEventsDir => AssociatedDataOrigin.events,
      associatedDataSpecimensDir => AssociatedDataOrigin.specimens,
      _ => null,
    };
  }

  Future<void> _deleteCopiedFile(File? file) async {
    if (file != null && await file.exists()) await file.delete();
  }

  String _fileUri(File file) {
    return Uri.file(file.absolute.path, windows: Platform.isWindows).toString();
  }

  void _invalidate(AssociatedDataTarget target) {
    ref.invalidate(associatedDataProvider(target));
  }
}
