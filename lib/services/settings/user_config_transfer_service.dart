import 'dart:io';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';
import 'package:nahpu/services/custom_fields/custom_field_service.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:path/path.dart' as path;

enum UserConfigFileFormat { json, jsonGzip }

enum UserConfigImportDestination { global, currentProject }

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

  Future<List<CustomFieldDefinitionData>> availableCustomFields(
    Database database, {
    String? projectUuid,
  }) {
    return CustomFieldService(
      database,
    ).getManageableDefinitions(projectUuid: projectUuid);
  }

  Future<rust_config.UserConfigTransferPreview> currentPreview({
    Database? database,
    String? projectUuid,
    Set<int>? selectedDefinitionIds,
  }) async {
    final templates = database == null
        ? const <rust_config.CustomFieldTemplate>[]
        : await _exportTemplates(
            database,
            projectUuid: projectUuid,
            selectedDefinitionIds: selectedDefinitionIds,
          );
    return rust_config.getConfigExportPreview(customFieldTemplates: templates);
  }

  Future<File> export({
    required File output,
    required UserConfigFileFormat format,
    required Set<rust_config.UserConfigSection> sections,
    Database? database,
    String? projectUuid,
    Set<int>? selectedDefinitionIds,
  }) async {
    _requireSections(sections);
    final templates =
        sections.contains(rust_config.UserConfigSection.customFields)
        ? await _exportTemplates(
            database,
            projectUuid: projectUuid,
            selectedDefinitionIds: selectedDefinitionIds,
          )
        : const <rust_config.CustomFieldTemplate>[];
    if (format == UserConfigFileFormat.json) {
      await rust_config.exportConfigToFile(
        filePath: output.path,
        sections: sections.toList(growable: false),
        customFieldTemplates: templates,
      );
      return output;
    }

    final staging = Directory.systemTemp.createTempSync('nahpu-config-export-');
    try {
      final jsonFile = File(path.join(staging.path, 'user-configs.json'));
      await rust_config.exportConfigToFile(
        filePath: jsonFile.path,
        sections: sections.toList(growable: false),
        customFieldTemplates: templates,
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
    Set<rust_config.UserConfigSection> sections, {
    Database? database,
    UserConfigImportDestination destination =
        UserConfigImportDestination.global,
    String? projectUuid,
  }) async {
    _requireSections(sections);
    final importsCustomFields = sections.contains(
      rust_config.UserConfigSection.customFields,
    );
    if (!importsCustomFields) {
      await rust_config.importConfigFromFile(
        filePath: source.jsonFile.path,
        sections: sections.toList(growable: false),
      );
      return;
    }
    if (database == null) {
      throw ArgumentError('A database is required to import custom fields.');
    }
    if (destination == UserConfigImportDestination.currentProject &&
        (projectUuid == null || projectUuid.isEmpty)) {
      throw ArgumentError('Open a project before importing project fields.');
    }
    final templates = await rust_config.getCustomFieldTemplates(
      filePath: source.jsonFile.path,
    );
    await _preflightTemplates(
      database,
      templates,
      destination: destination,
      projectUuid: projectUuid,
    );

    final redbSections = sections
        .where(
          (section) => section != rust_config.UserConfigSection.customFields,
        )
        .toSet();
    Directory? snapshotDirectory;
    File? snapshot;
    if (redbSections.isNotEmpty) {
      snapshotDirectory = Directory.systemTemp.createTempSync(
        'nahpu-config-rollback-',
      );
      snapshot = File(path.join(snapshotDirectory.path, 'snapshot.json'));
      await rust_config.exportConfigToFile(
        filePath: snapshot.path,
        sections: redbSections.toList(growable: false),
        customFieldTemplates: const [],
      );
    }
    var redbWasWritten = false;
    try {
      await database.transaction(() async {
        await _materializeTemplates(
          database,
          templates,
          destination: destination,
          projectUuid: projectUuid,
        );
        if (redbSections.isNotEmpty) {
          await rust_config.importConfigFromFile(
            filePath: source.jsonFile.path,
            sections: redbSections.toList(growable: false),
          );
          redbWasWritten = true;
        }
      });
    } catch (_) {
      if (redbWasWritten && snapshot != null) {
        await rust_config.importConfigFromFile(
          filePath: snapshot.path,
          sections: redbSections.toList(growable: false),
        );
      }
      rethrow;
    } finally {
      if (snapshotDirectory?.existsSync() ?? false) {
        await snapshotDirectory!.delete(recursive: true);
      }
    }
  }

  Future<List<rust_config.CustomFieldTemplate>> _exportTemplates(
    Database? database, {
    String? projectUuid,
    Set<int>? selectedDefinitionIds,
  }) async {
    if (database == null) return const [];
    final definitions = await availableCustomFields(
      database,
      projectUuid: projectUuid,
    );
    return definitions
        .where(
          (definition) =>
              selectedDefinitionIds == null ||
              selectedDefinitionIds.contains(definition.id),
        )
        .map(
          (definition) => rust_config.CustomFieldTemplate(
            templateUuid: definition.sourceTemplateUuid ?? definition.uuid,
            label: definition.name,
            fieldType: definition.type,
            placement: definition.uiSection,
            catalogFormat: definition.catalogFormat,
            optionsJson: definition.options,
            dwcTarget: definition.dwcTarget,
            dwcField: definition.dwcField,
            dwcMode: definition.dwcMode,
            allowDwcConflict: definition.allowDwcConflict == 1,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _preflightTemplates(
    Database database,
    List<rust_config.CustomFieldTemplate> templates, {
    required UserConfigImportDestination destination,
    required String? projectUuid,
  }) async {
    try {
      await database.transaction(() async {
        await _materializeTemplates(
          database,
          templates,
          destination: destination,
          projectUuid: projectUuid,
        );
        throw const _CustomFieldPreflightRollback();
      });
    } on _CustomFieldPreflightRollback {
      // Expected: Drift rolls the dry run back after every validation passes.
    }
  }

  Future<void> _materializeTemplates(
    Database database,
    List<rust_config.CustomFieldTemplate> templates, {
    required UserConfigImportDestination destination,
    required String? projectUuid,
  }) async {
    final service = CustomFieldService(database);
    final scope = destination == UserConfigImportDestination.global
        ? FieldScope.global
        : FieldScope.project;
    final targetProjectUuid = scope == FieldScope.project ? projectUuid : null;
    for (final template in templates) {
      final existing =
          await (database.select(database.customFieldDefinition)..where(
                (row) =>
                    (row.sourceTemplateUuid.equals(template.templateUuid) |
                        row.uuid.equals(template.templateUuid)) &
                    row.scope.equals(scope.name) &
                    (scope == FieldScope.global
                        ? row.projectUuid.isNull()
                        : row.projectUuid.equals(targetProjectUuid!)),
              ))
              .getSingleOrNull();
      final options = template.optionsJson == null
          ? const <CustomFieldOption>[]
          : (jsonDecode(template.optionsJson!) as List<dynamic>)
                .map(
                  (item) => CustomFieldOption.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList(growable: false);
      final mapping =
          template.dwcTarget == null ||
              template.dwcField == null ||
              template.dwcMode == null
          ? null
          : DwcFieldMapping(
              target: template.dwcTarget!,
              field: template.dwcField!,
              mode: DwcMappingMode.values.byName(template.dwcMode!),
              allowConflict: template.allowDwcConflict,
            );
      final draft = CustomFieldDraft(
        name: template.label,
        type: FieldType.values.byName(template.fieldType),
        placement: FieldUISection.values.byName(template.placement),
        scope: scope,
        projectUuid: targetProjectUuid,
        catalogFormat: template.catalogFormat == null
            ? null
            : CatalogFmt.values.byName(template.catalogFormat!),
        options: options,
        dwcMapping: mapping,
        sourceTemplateUuid: template.templateUuid,
      );
      if (existing == null) {
        await service.createDefinition(draft);
      } else {
        await service.updateDefinition(existing.id!, draft);
      }
    }
  }

  void _requireSections(Set<rust_config.UserConfigSection> sections) {
    if (sections.isEmpty) {
      throw ArgumentError('Select at least one user configuration section.');
    }
  }
}

class _CustomFieldPreflightRollback implements Exception {
  const _CustomFieldPreflightRollback();
}
