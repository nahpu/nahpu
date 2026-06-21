import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/validation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:uuid/uuid.dart';

String get uuid => const Uuid().v4();

String get defaultCatalog => 'general-mammals';

class ProjectDeletionFailure implements Exception {
  ProjectDeletionFailure({
    required this.phase,
    required this.diagnosticSummary,
    this.cause,
  });

  final String phase;
  final String diagnosticSummary;
  final Object? cause;

  String toUserMessage() {
    final header = 'Project deletion failed while deleting $phase.';
    if (diagnosticSummary.isEmpty) {
      return '$header Some related data still references this project and could not be safely deleted.';
    }
    return '$header Remaining related data: $diagnosticSummary.';
  }

  @override
  String toString() {
    return toUserMessage();
  }
}

class _ProjectDeletionPhaseFailure implements Exception {
  _ProjectDeletionPhaseFailure(this.phase, this.cause);

  final String phase;
  final Object cause;
}

class ProjectServices extends AppServices {
  const ProjectServices({required super.ref});

  void createProject(ProjectCompanion form) {
    ProjectQuery(dbAccess).createProject(form);
    invalidateProject();
    updateProjectUuid(form.uuid.value);
  }

  void updateProjectUuid(String projectUuid) {
    ref.read(projectUuidProvider.notifier).updateProjectUuid(projectUuid);
  }

  void updateProject(String projectUuid, ProjectCompanion form) {
    ProjectQuery(dbAccess).updateProjectEntry(projectUuid, form);
    ref.invalidate(projectFormValidatorProvider);
    ref.invalidate(projectInfoProvider);
  }

  Future<ProjectData> getProjectByUuid(String uuid) async {
    return await ProjectQuery(dbAccess).getProjectByUuid(uuid);
  }

  Future<List<String>> getAllProjectNames() async {
    return await ProjectQuery(dbAccess).getAllProjectNames();
  }

  Future<String> getProjectName(String uuid) async {
    ProjectData data = await getProjectByUuid(uuid);
    return data.name;
  }

  String getProjectUuid() {
    return ref.read(projectUuidProvider);
  }

  Future<void> deleteProject(String uuid) async {
    await ProjectQuery(dbAccess).deleteProject(uuid);
    ref.invalidate(projectListProvider);
  }

  Future<String?> deleteProjectAndData(String projectUuid) async {
    try {
      await dbAccess.transaction(() async {
        await _runDeletionPhase('specimen records',
            () => SpecimenServices(ref: ref).deleteAllSpecimens(projectUuid));
        await _runDeletionPhase('collecting events',
            () => CollEventServices(ref: ref).deleteAllCollEvents(projectUuid));
        await _runDeletionPhase('narrative entries',
            () => NarrativeServices(ref: ref).deleteAllNarrative(projectUuid));
        await _runDeletionPhase('site records',
            () => SiteServices(ref: ref).deleteAllSites(projectUuid));
        await _runDeletionPhase(
            'project personnel links',
            () => PersonnelQuery(dbAccess)
                .deleteAllProjectPersonnel(projectUuid: projectUuid));
        await _runDeletionPhase(
            'project media', () => _cleanupProjectMedia(projectUuid));
        await _runDeletionPhase('project record',
            () => ProjectQuery(dbAccess).deleteProject(projectUuid));
      });
    } catch (e) {
      final phase =
          e is _ProjectDeletionPhaseFailure ? e.phase : 'project data';
      String diagnostics = '';
      try {
        diagnostics = await _collectDeletionDiagnostics(projectUuid);
      } catch (_) {
        diagnostics = '';
      }
      throw ProjectDeletionFailure(
        phase: phase,
        diagnosticSummary: diagnostics,
        cause: e is _ProjectDeletionPhaseFailure ? e.cause : e,
      );
    }

    String? cleanupWarning;
    final projectDir =
        await FileServices(ref: ref).getProjectDirByUUID(projectUuid);
    try {
      if (projectDir.existsSync()) {
        await projectDir.delete(recursive: true);
      }
    } catch (e) {
      cleanupWarning = 'Project data deleted, but file cleanup failed: $e';
    }

    invalidateProject();
    return cleanupWarning;
  }

  Future<void> _runDeletionPhase(
      String phase, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      throw _ProjectDeletionPhaseFailure(phase, e);
    }
  }

  Future<String> _collectDeletionDiagnostics(String projectUuid) async {
    final parts = <String>[];

    final specimenCount =
        (await SpecimenQuery(dbAccess).getAllSpecimens(projectUuid)).length;
    if (specimenCount > 0) {
      parts.add(_formatCount(specimenCount, 'specimen record'));
    }

    final collEventCount =
        (await CollEventQuery(dbAccess).getAllCollEvents(projectUuid)).length;
    if (collEventCount > 0) {
      parts.add(_formatCount(collEventCount, 'collecting event'));
    }

    final narrativeCount =
        (await NarrativeQuery(dbAccess).getAllNarrative(projectUuid)).length;
    if (narrativeCount > 0) {
      parts.add(_formatCount(narrativeCount, 'narrative entry'));
    }

    final siteCount =
        (await SiteQuery(dbAccess).getAllSites(projectUuid)).length;
    if (siteCount > 0) {
      parts.add(_formatCount(siteCount, 'site record'));
    }

    final projectPersonnelCount =
        (await PersonnelQuery(dbAccess).getProjectPersonnelLinks(projectUuid))
            .length;
    if (projectPersonnelCount > 0) {
      parts.add(_formatCount(projectPersonnelCount, 'project personnel link'));
    }

    final mediaCount =
        (await MediaDbQuery(dbAccess).getMediaByProject(projectUuid)).length;
    if (mediaCount > 0) {
      parts.add(_formatCount(mediaCount, 'project media item'));
    }

    try {
      await ProjectQuery(dbAccess).getProjectByUuid(projectUuid);
      parts.add('project record');
    } catch (_) {
      // No-op, project record does not exist.
    }

    return parts.join(', ');
  }

  String _formatCount(int count, String singular) {
    final suffix = count == 1 ? singular : '${singular}s';
    return '$count $suffix';
  }

  Future<void> _cleanupProjectMedia(String projectUuid) async {
    final mediaQuery = MediaDbQuery(dbAccess);
    final projectMedia = await mediaQuery.getMediaByProject(projectUuid);
    for (final mediaRow in projectMedia) {
      final hasSharedReference =
          await mediaQuery.isMediaReferencedByTaxonomy(mediaRow.primaryId);
      if (hasSharedReference) {
        await mediaQuery.detachMediaFromProject(mediaRow.primaryId);
      } else {
        await mediaQuery.deleteMedia(mediaRow.primaryId);
      }
    }
  }

  void invalidateProject() {
    ref.invalidate(projectListProvider);
    ref.invalidate(projectInfoProvider);
    ref.invalidate(projectUuidProvider);
  }
}

extension StringValidator on String {
  bool get isValidCollNum {
    final catNumRegex = RegExp(r'^[0-9]+$');
    return catNumRegex.hasMatch(this);
  }

  bool get isValidProjectName {
    final projectNameRegex =
        RegExp(r'^[\d\p{L}\p{Mn}\s\-\\_]+$', unicode: true);
    return projectNameRegex.hasMatch(this);
  }

  bool get isValidName {
    // Match name with unicode characters
    final nameRegex = RegExp(r'^[\p{L}\p{Mn}\p{Pd}\s\.\-]+$', unicode: true);
    return nameRegex.hasMatch(this);
  }

  bool get isValidInitial {
    final initialRegex = RegExp(r'^[a-zA-Z0-9\-\_]+$');
    return initialRegex.hasMatch(this);
  }

  bool get isValidEmail {
    final emailRegex =
        RegExp(r'(^[a-zA-Z0-9_.]+[@]{1}[a-z0-9]+[\.][a-z](.)+$)');
    return emailRegex.hasMatch(this);
  }
}
