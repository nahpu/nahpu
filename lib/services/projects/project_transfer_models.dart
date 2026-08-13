import 'dart:convert';

import 'package:nahpu/services/specimens/specimen_attribute_names.dart';

const int projectTransferVersion = 6;
const Set<int> supportedProjectTransferVersions = {1, 2, 3, 4, 5, 6};
const String projectTransferMarker = 'project';
const String projectTransferManifestName = 'nahpu-project.json';

enum ProjectTransferArchiveFormat { jsonGzip, zip, tarGzip }

enum ProjectTransferImportMode { merge, newProject }

extension ProjectTransferArchiveFormatLabel on ProjectTransferArchiveFormat {
  String get label => switch (this) {
    ProjectTransferArchiveFormat.jsonGzip => 'JSON.GZ (light)',
    ProjectTransferArchiveFormat.tarGzip => 'TAR.GZ',
    ProjectTransferArchiveFormat.zip => 'ZIP',
  };

  String get extension => switch (this) {
    ProjectTransferArchiveFormat.jsonGzip => 'json.gz',
    ProjectTransferArchiveFormat.tarGzip => 'tar.gz',
    ProjectTransferArchiveFormat.zip => 'zip',
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

  List<Map<String, dynamic>> rows(String key) =>
      records[canonicalizeSpecimenAttributeTableName(key)] ?? const [];

  Map<String, int> get summary => {
    'Personnel': rows('personnel').length,
    'Taxonomy': rows('taxonomy').length,
    'Sites': rows('site').length,
    'Events': rows('collEvent').length,
    'Specimens': rows('specimen').length,
    'Narratives': rows('narrative').length,
    'Custom fields': rows('customFieldDefinition').length,
    'Media': rows('media').length + rows('personnelPhoto').length,
  };

  String get encoded => const JsonEncoder.withIndent('  ').convert(toJson());

  String get encodedWithoutMedia =>
      const JsonEncoder.withIndent('  ').convert(toJson(includeMedia: false));

  Map<String, dynamic> toJson({bool includeMedia = true}) => {
    'nahpu_project': projectTransferMarker,
    'version': version,
    'exportedAt': exportedAt,
    'appVersion': appVersion,
    'databaseVersion': databaseVersion,
    'project': project,
    'records': includeMedia ? records : _recordsWithoutMedia,
    'media': includeMedia
        ? mediaFiles.map((entry) => entry.toJson()).toList()
        : const [],
    'warnings': includeMedia ? warnings : const [],
  };

  Map<String, List<Map<String, dynamic>>> get _recordsWithoutMedia {
    const mediaCollections = {
      'media',
      'personnelPhoto',
      'siteMedia',
      'narrativeMedia',
      'specimenMedia',
    };
    final sanitized = <String, List<Map<String, dynamic>>>{};
    for (final entry in records.entries) {
      if (mediaCollections.contains(entry.key)) continue;
      sanitized[entry.key] = entry.value
          .map((row) {
            final copy = Map<String, dynamic>.from(row);
            if (entry.key == 'taxonomy') copy['mediaId'] = null;
            if (entry.key == 'site' || entry.key == 'narrative') {
              copy['mediaID'] = null;
            }
            if (entry.key == 'personnel') copy['photoPath'] = null;
            return copy;
          })
          .toList(growable: false);
    }
    return sanitized;
  }

  factory ProjectTransferPayload.parse(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) {
        throw const FormatException('Project transfer JSON must be an object.');
      }
      final json = Map<String, dynamic>.from(decoded);
      if (json['nahpu_project'] != projectTransferMarker) {
        throw const FormatException(
          'This is not a NAHPU project transfer payload.',
        );
      }
      if (!supportedProjectTransferVersions.contains(json['version'])) {
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
      final parsedRecords = <String, List<Map<String, dynamic>>>{};
      for (final entry in recordsValue.entries) {
        if (entry.key is! String || entry.value is! List) {
          throw const FormatException('Invalid project record collection.');
        }
        parsedRecords[entry.key as String] = (entry.value as List)
            .map((row) {
              if (row is! Map) {
                throw const FormatException('Invalid project record.');
              }
              return Map<String, dynamic>.from(row);
            })
            .toList(growable: false);
      }
      final records = _canonicalizeRecords(parsedRecords);
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

  static Map<String, List<Map<String, dynamic>>> _canonicalizeRecords(
    Map<String, List<Map<String, dynamic>>> records,
  ) {
    final canonical = <String, List<Map<String, dynamic>>>{};
    for (final entry in records.entries) {
      final key = canonicalizeSpecimenAttributeTableName(entry.key);
      final existing = canonical[key];
      if (existing != null && existing.isNotEmpty && entry.value.isNotEmpty) {
        throw FormatException(
          'The project transfer contains conflicting $key collections.',
        );
      }
      if (existing == null || existing.isEmpty) {
        canonical[key] = switch (key) {
          'associatedData' =>
            entry.value.map(_normalizeAssociatedData).toList(growable: false),
          'birdAttribute' =>
            entry.value.map(_normalizeBirdAttribute).toList(growable: false),
          _ => entry.value,
        };
      }
    }
    return canonical;
  }

  static Map<String, dynamic> _normalizeAssociatedData(
    Map<String, dynamic> source,
  ) {
    final normalized = Map<String, dynamic>.from(source);
    normalized['uri'] ??= normalized['url'];
    normalized.remove('url');
    return normalized;
  }

  static Map<String, dynamic> _normalizeBirdAttribute(
    Map<String, dynamic> source,
  ) {
    final normalized = Map<String, dynamic>.from(source);
    normalized['toeColor'] ??= normalized['footColor'];
    normalized['toeHex'] ??= normalized['footHex'];
    normalized.remove('footColor');
    normalized.remove('footHex');
    return normalized;
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

class ProjectTransferProjectMatch {
  const ProjectTransferProjectMatch({required this.uuid, required this.name});

  final String uuid;
  final String name;
}

class ProjectTransferProjectExistsException implements Exception {
  const ProjectTransferProjectExistsException(this.project);

  final ProjectTransferProjectMatch project;

  @override
  String toString() =>
      'Project ${project.name} (${project.uuid}) already exists. '
      'Use Merge project instead.';
}

class ProjectTransferImportPlan {
  const ProjectTransferImportPlan({
    required this.payload,
    required this.mode,
    required this.destinationProjectUuid,
    required this.destinationProjectName,
    required this.conflicts,
    required this.matchedBySection,
    required this.newBySection,
    required this.warnings,
    this.nameConflict,
  });

  final ProjectTransferPayload payload;
  final ProjectTransferImportMode mode;
  final String destinationProjectUuid;
  final String destinationProjectName;
  final List<ProjectTransferConflict> conflicts;
  final Map<ProjectTransferSection, int> matchedBySection;
  final Map<ProjectTransferSection, int> newBySection;
  final List<String> warnings;
  final ProjectTransferProjectMatch? nameConflict;

  String get activeProjectUuid => destinationProjectUuid;
  String get activeProjectName => destinationProjectName;
  bool get isNewProject => mode == ProjectTransferImportMode.newProject;

  bool get hasUuidMismatch =>
      mode == ProjectTransferImportMode.merge &&
      payload.sourceProjectUuid != destinationProjectUuid;

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
