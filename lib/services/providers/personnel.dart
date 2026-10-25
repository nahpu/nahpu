import 'dart:io';

import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/media.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final allPersonnelProvider = FutureProvider.autoDispose<List<PersonnelData>>((
  ref,
) async {
  List<PersonnelData> personnelData = await PersonnelQuery(
    ref.read(databaseProvider),
  ).getAllPersonnel();
  return personnelData;
});

final projectPersonnelProvider =
    FutureProvider.autoDispose<List<PersonnelData>>((ref) async {
      final projectUuid = ref.watch(projectUuidProvider);
      List<PersonnelData> personnelData = await PersonnelQuery(
        ref.read(databaseProvider),
      ).getPersonnelByProjectUuid(projectUuid);
      return personnelData;
    });

/// Personnel for a given project; falls back to the open project when the
/// UUID is empty.
final personnelByProjectProvider = FutureProvider.family
    .autoDispose<List<PersonnelData>, String>((ref, projectUuid) {
      final uuid = projectUuid.isEmpty
          ? ref.watch(projectUuidProvider)
          : projectUuid;
      return PersonnelQuery(
        ref.read(databaseProvider),
      ).getPersonnelByProjectUuid(uuid);
    });

final personnelNameProvider = FutureProvider.family
    .autoDispose<PersonnelData, String>((ref, uuid) {
      final person = PersonnelQuery(
        ref.read(databaseProvider),
      ).getPersonnelByUuid(uuid);
      return person;
    });

final personnelInitialProvider = FutureProvider.family
    .autoDispose<String?, String>((ref, uuid) async {
      final personInitial = PersonnelQuery(
        ref.read(databaseProvider),
      ).getInitial(uuid);
      return personInitial;
    });

/// A custom personnel photo file, resolved once per file name so avatar
/// rebuilds do not repeat the document-directory lookup. Matches
/// `MediaFinder.getPathForPersonnel`.
final personnelAvatarFileProvider = FutureProvider.autoDispose
    .family<File, String>((ref, fileName) async {
      final documentDir = await ref.watch(nahpuDocumentDirProvider.future);
      return File(
        p.normalize(
          p.join(documentDir.path, appMediaDirName, 'personnel', fileName),
        ),
      );
    });
