import 'dart:convert';

const int projectTransferVersion = 1;
const String projectTransferMarker = 'project';
const String projectTransferManifestName = 'nahpu-project.json';

enum ProjectTransferArchiveFormat { zip, tarGzip }

extension ProjectTransferArchiveFormatLabel on ProjectTransferArchiveFormat {
  String get label => switch (this) {
    ProjectTransferArchiveFormat.zip => 'ZIP',
    ProjectTransferArchiveFormat.tarGzip => 'TAR.GZ',
  };

  String get extension => switch (this) {
    ProjectTransferArchiveFormat.zip => 'zip',
    ProjectTransferArchiveFormat.tarGzip => 'tar.gz',
  };
}

enum ProjectTransferSection {
  projectInfo,
  personnel,
  taxonomy,
  sites,
  events,
  specimens,
  narratives,
}

extension ProjectTransferSectionLabel on ProjectTransferSection {
  String get label => switch (this) {
    ProjectTransferSection.projectInfo => 'Project info',
    ProjectTransferSection.personnel => 'Personnel',
    ProjectTransferSection.taxonomy => 'Taxonomy',
    ProjectTransferSection.sites => 'Sites',
    ProjectTransferSection.events => 'Events',
    ProjectTransferSection.specimens => 'Specimens',
    ProjectTransferSection.narratives => 'Narratives',
  };
}

enum ProjectTransferConflictAction {
  keepCurrent,
  useImported,
  importAsNew,
  skip,
}

extension ProjectTransferConflictActionLabel on ProjectTransferConflictAction {
  String get label => switch (this) {
    ProjectTransferConflictAction.keepCurrent => 'Keep current',
    ProjectTransferConflictAction.useImported => 'Use imported',
    ProjectTransferConflictAction.importAsNew => 'Import as new',
    ProjectTransferConflictAction.skip => 'Skip',
  };
}

class ProjectTransferMediaFile {
  const ProjectTransferMediaFile({
    required this.sourceId,
    required this.kind,
    required this.archivePath,
    required this.originalFileName,
    this.sourcePath,
  });

  final String sourceId;
  final String kind;
  final String archivePath;
  final String originalFileName;
  final String? sourcePath;

  Map<String, dynamic> toJson() => {
    'sourceId': sourceId,
    'kind': kind,
    'archivePath': archivePath,
    'originalFileName': originalFileName,
  };

  factory ProjectTransferMediaFile.fromJson(Map<String, dynamic> json) {
    final sourceId = json['sourceId'];
    final kind = json['kind'];
    final archivePath = json['archivePath'];
    final originalFileName = json['originalFileName'];
    if (sourceId is! String ||
        kind is! String ||
        archivePath is! String ||
        originalFileName is! String) {
      throw const FormatException('Invalid project media manifest entry.');
    }
    return ProjectTransferMediaFile(
      sourceId: sourceId,
      kind: kind,
      archivePath: archivePath,
      originalFileName: originalFileName,
    );
  }
}

class ProjectTransferPayload {
  const ProjectTransferPayload({
    required this.exportedAt,
    required this.appVersion,
    required this.databaseVersion,
    required this.project,
    required this.records,
    this.mediaFiles = const [],
    this.warnings = const [],
    this.version = projectTransferVersion,
  });

  final int version;
  final String exportedAt;
  final String appVersion;
  final int databaseVersion;
  final Map<String, dynamic> project;
  final Map<String, List<Map<String, dynamic>>> records;
  final List<ProjectTransferMediaFile> mediaFiles;
  final List<String> warnings;

  String get sourceProjectUuid => project['uuid'] as String;
  String get projectName => project['name'] as String? ?? 'Unnamed project';
  bool get hasMedia => mediaFiles.isNotEmpty;

  List<Map<String, dynamic>> rows(String key) => records[key] ?? const [];

  Map<String, int> get summary => {
    'Personnel': rows('personnel').length,
    'Taxonomy': rows('taxonomy').length,
    'Sites': rows('site').length,
    'Events': rows('collEvent').length,
    'Specimens': rows('specimen').length,
    'Narratives': rows('narrative').length,
    'Media': rows('media').length + rows('personnelPhoto').length,
  };

  String get encoded => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, dynamic> toJson() => {
    'nahpu_project': projectTransferMarker,
    'version': version,
    'exportedAt': exportedAt,
    'appVersion': appVersion,
    'databaseVersion': databaseVersion,
    'project': project,
    'records': records,
    'media': mediaFiles.map((entry) => entry.toJson()).toList(),
    'warnings': warnings,
  };

  factory ProjectTransferPayload.parse(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) {
        throw const FormatException('Project transfer JSON must be an object.');
      }
      final json = Map<String, dynamic>.from(decoded);
      if (json['nahpu_project'] != projectTransferMarker) {
        throw const FormatException(
          'This is not a NAHPU project transfer archive. '
          'Bundle records files cannot be imported here.',
        );
      }
      if (json['version'] != projectTransferVersion) {
        throw FormatException(
          'Unsupported project transfer version: ${json['version']}.',
        );
      }
      final projectValue = json['project'];
      final recordsValue = json['records'];
      if (projectValue is! Map || recordsValue is! Map) {
        throw const FormatException(
          'The project transfer is missing project records.',
        );
      }
      final project = Map<String, dynamic>.from(projectValue);
      if (project['uuid'] is! String ||
          (project['uuid'] as String).isEmpty ||
          project['name'] is! String) {
        throw const FormatException(
          'The project transfer has invalid project information.',
        );
      }
      final records = <String, List<Map<String, dynamic>>>{};
      for (final entry in recordsValue.entries) {
        if (entry.key is! String || entry.value is! List) {
          throw const FormatException('Invalid project record collection.');
        }
        records[entry.key as String] = (entry.value as List)
            .map((row) {
              if (row is! Map) {
                throw const FormatException('Invalid project record.');
              }
              return Map<String, dynamic>.from(row);
            })
            .toList(growable: false);
      }
      final media = _mapList(
        json['media'],
      ).map(ProjectTransferMediaFile.fromJson).toList(growable: false);
      for (final entry in media) {
        validateArchivePath(entry.archivePath);
      }
      return ProjectTransferPayload(
        version: json['version'] as int,
        exportedAt: json['exportedAt'] as String? ?? '',
        appVersion: json['appVersion'] as String? ?? '',
        databaseVersion: json['databaseVersion'] as int? ?? 0,
        project: project,
        records: records,
        mediaFiles: media,
        warnings: (json['warnings'] as List? ?? const [])
            .whereType<String>()
            .toList(growable: false),
      );
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('Invalid project transfer: $error');
    }
  }

  static List<Map<String, dynamic>> _mapList(Object? value) {
    if (value == null) return const [];
    if (value is! List) {
      throw const FormatException('Invalid project media collection.');
    }
    return value
        .map((entry) {
          if (entry is! Map) {
            throw const FormatException('Invalid project media entry.');
          }
          return Map<String, dynamic>.from(entry);
        })
        .toList(growable: false);
  }

  static void validateArchivePath(String value) {
    final normalized = value.replaceAll('\\', '/');
    if (normalized.isEmpty ||
        normalized.startsWith('/') ||
        normalized.contains('../') ||
        normalized == '..' ||
        RegExp(r'^[a-zA-Z]:').hasMatch(normalized)) {
      throw const FormatException(
        'The project transfer contains an unsafe media path.',
      );
    }
  }
}

class ProjectTransferConflict {
  const ProjectTransferConflict({
    required this.id,
    required this.section,
    required this.label,
    required this.currentSummary,
    required this.importedSummary,
    this.allowedActions = ProjectTransferConflictAction.values,
    this.warning,
  });

  final String id;
  final ProjectTransferSection section;
  final String label;
  final String currentSummary;
  final String importedSummary;
  final List<ProjectTransferConflictAction> allowedActions;
  final String? warning;
}

class ProjectTransferImportPlan {
  const ProjectTransferImportPlan({
    required this.payload,
    required this.activeProjectUuid,
    required this.activeProjectName,
    required this.conflicts,
    required this.matchedBySection,
    required this.newBySection,
    required this.warnings,
  });

  final ProjectTransferPayload payload;
  final String activeProjectUuid;
  final String activeProjectName;
  final List<ProjectTransferConflict> conflicts;
  final Map<ProjectTransferSection, int> matchedBySection;
  final Map<ProjectTransferSection, int> newBySection;
  final List<String> warnings;

  bool get hasUuidMismatch => payload.sourceProjectUuid != activeProjectUuid;

  List<ProjectTransferConflict> conflictsFor(ProjectTransferSection section) =>
      conflicts.where((conflict) => conflict.section == section).toList();
}

class ProjectTransferImportResult {
  const ProjectTransferImportResult({
    required this.imported,
    required this.updated,
    required this.skipped,
    required this.mediaCopied,
    required this.warnings,
  });

  final int imported;
  final int updated;
  final int skipped;
  final int mediaCopied;
  final List<String> warnings;
}
