import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/custom_fields/custom_field_service.dart';
import 'package:nahpu/services/media/media_services.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/projects/project_transfer_service.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/types/birds.dart' as birds;
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/types/mammals.dart' as mammals;
import 'package:nahpu/services/types/arthropods.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/projects/orcid.dart';
import 'package:nahpu/services/export/dwc_values.dart';
import 'package:nahpu/src/rust/api/dwc.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/src/rust/api/nahpu_dp.dart';

enum DwcBundleFormat {
  darwinCoreArchive,
  darwinCoreDataPackage,
  nahpuDataPackage,
}

enum BundleArchiveFormat { tarGzip, zip }

extension BundleArchiveFormatLabel on BundleArchiveFormat {
  String get label => switch (this) {
    BundleArchiveFormat.tarGzip => 'TAR.GZ',
    BundleArchiveFormat.zip => 'ZIP',
  };

  String get wireValue => switch (this) {
    BundleArchiveFormat.tarGzip => 'tar_gzip',
    BundleArchiveFormat.zip => 'zip',
  };
}

extension DwcBundleFormatLabel on DwcBundleFormat {
  String get label => switch (this) {
    DwcBundleFormat.darwinCoreArchive => 'Darwin Core Archive',
    DwcBundleFormat.darwinCoreDataPackage => 'Darwin Core Data Package',
    DwcBundleFormat.nahpuDataPackage => 'NAHPU Data Package',
  };

  bool get usesTaxonSelection => this != DwcBundleFormat.nahpuDataPackage;

  BundleArchiveFormat get defaultArchive => switch (this) {
    DwcBundleFormat.darwinCoreArchive => BundleArchiveFormat.zip,
    DwcBundleFormat.darwinCoreDataPackage ||
    DwcBundleFormat.nahpuDataPackage => BundleArchiveFormat.tarGzip,
  };

  Set<BundleArchiveFormat> get allowedArchives => switch (this) {
    DwcBundleFormat.darwinCoreArchive => {BundleArchiveFormat.zip},
    DwcBundleFormat.darwinCoreDataPackage ||
    DwcBundleFormat.nahpuDataPackage => BundleArchiveFormat.values.toSet(),
  };

  String get wireValue => switch (this) {
    DwcBundleFormat.darwinCoreArchive => 'darwin_core_archive',
    DwcBundleFormat.darwinCoreDataPackage => 'darwin_core_data_package',
    DwcBundleFormat.nahpuDataPackage => 'nahpu_data_package',
  };

  String outputExtension(BundleArchiveFormat archive) {
    if (this == DwcBundleFormat.darwinCoreArchive) return 'dwca.zip';
    final package = this == DwcBundleFormat.darwinCoreDataPackage
        ? 'dwc-dp'
        : 'nahpu-dp';
    return archive == BundleArchiveFormat.tarGzip
        ? '$package.tar.gz'
        : '$package.zip';
  }
}

/// A complete, display-ready description of a bundle before it is written.
class DwcBundleManifest {
  const DwcBundleManifest({required this.files, required this.warnings});

  final List<DwcBundleFile> files;
  final List<String> warnings;

  factory DwcBundleManifest.fromJson(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return DwcBundleManifest(
      files: (json['files'] as List<dynamic>? ?? const [])
          .map((entry) => DwcBundleFile.fromMap(entry as Map<String, dynamic>))
          .toList(growable: false),
      warnings: (json['warnings'] as List<dynamic>? ?? const [])
          .map((entry) => entry.toString())
          .toList(growable: false),
    );
  }
}

class DwcBundleFile {
  const DwcBundleFile({
    required this.path,
    required this.mediaType,
    required this.records,
    required this.columns,
  });

  final String path;
  final String mediaType;
  final int records;
  final List<String> columns;

  factory DwcBundleFile.fromMap(Map<String, dynamic> json) => DwcBundleFile(
    path: json['path'] as String,
    mediaType: json['media_type'] as String,
    records: json['records'] as int,
    columns: (json['columns'] as List<dynamic>? ?? const [])
        .map((entry) => entry.toString())
        .toList(growable: false),
  );
}

/// Builds Darwin Core specimen packages from the current NAHPU project.
///
/// The database is read here, while Darwin Core CSV, metadata, and archive
/// semantics remain in `nahpu_api/crates/nahpu_dwc`.
class DwcBundleWriter extends AppServices {
  const DwcBundleWriter({required super.ref});

  Future<List<String>> getRecordedTaxonGroups() async {
    final groups = await SpecimenServices(ref: ref).getRecordedGroupList();
    return groups.map(normalizeBundleTaxonGroup).toSet().toList()..sort();
  }

  Future<DwcBundleManifest> plan({
    required DwcBundleFormat format,
    required BundleArchiveFormat archiveFormat,
    required Set<String> selectedTaxonGroups,
  }) async {
    if (format == DwcBundleFormat.nahpuDataPackage) {
      return _withNahpuRequest(
        archiveFormat,
        (request) async => DwcBundleManifest.fromJson(
          await planNahpuPackage(requestJson: jsonEncode(request)),
        ),
      );
    }
    final request = await _buildRequest(
      format,
      archiveFormat,
      selectedTaxonGroups,
    );
    return DwcBundleManifest.fromJson(
      await planDwcBundle(requestJson: jsonEncode(request)),
    );
  }

  Future<DwcBundleManifest> write({
    required DwcBundleFormat format,
    required BundleArchiveFormat archiveFormat,
    required Set<String> selectedTaxonGroups,
    required String outputPath,
  }) async {
    if (format == DwcBundleFormat.nahpuDataPackage) {
      return _withNahpuRequest(archiveFormat, (request) async {
        final requestJson = jsonEncode(request);
        final validation = await validateNahpuPackage(requestJson: requestJson);
        final errors = jsonDecode(validation) as List<dynamic>;
        if (errors.isNotEmpty) {
          throw StateError(errors.join('\n'));
        }
        return DwcBundleManifest.fromJson(
          await writeNahpuPackage(
            requestJson: requestJson,
            outputPath: outputPath,
          ),
        );
      });
    }
    final request = await _buildRequest(
      format,
      archiveFormat,
      selectedTaxonGroups,
    );
    final validation = await validateDwcBundle(
      requestJson: jsonEncode(request),
    );
    final errors = jsonDecode(validation) as List<dynamic>;
    if (errors.isNotEmpty) {
      throw StateError(errors.join('\n'));
    }
    return DwcBundleManifest.fromJson(
      await writeDwcBundle(
        requestJson: jsonEncode(request),
        outputPath: outputPath,
      ),
    );
  }

  Future<Map<String, dynamic>> _buildRequest(
    DwcBundleFormat format,
    BundleArchiveFormat archiveFormat,
    Set<String> requestedGroups,
  ) async {
    final selectedGroups = _expandTaxonSelection(requestedGroups);
    final project = await ProjectServices(
      ref: ref,
    ).getProjectByUuid(currentProjectUuid);
    final specimens = await SpecimenServices(ref: ref).getAllSpecimens();
    final selected = specimens
        .where((specimen) {
          return selectedGroups.contains(
            normalizeBundleTaxonGroup(specimen.taxonGroup),
          );
        })
        .toList(growable: false);

    final events = <String, Map<String, dynamic>>{};
    final occurrenceRows = <Map<String, dynamic>>[];
    final materialRows = <Map<String, dynamic>>[];
    final measurementRows = <Map<String, dynamic>>[];
    final eventAssertionRows = <Map<String, dynamic>>[];
    final materialAssertionRows = <Map<String, dynamic>>[];
    final occurrenceAssertionRows = <Map<String, dynamic>>[];
    final interactionAssertionRows = <Map<String, dynamic>>[];
    final interactionRows = <Map<String, dynamic>>[];
    final mediaRows = <Map<String, dynamic>>[];
    final warnings = <String>[];
    final agents = <String, _ResolvedAgent>{};
    final occurrenceAgentRoles = <Map<String, dynamic>>[];
    final eventAgentRoles = <Map<String, dynamic>>[];
    final materialAgentRoles = <Map<String, dynamic>>[];
    final mediaAgentRoles = <Map<String, dynamic>>[];

    for (final specimen in selected) {
      final event = await CollEventServices(
        ref: ref,
      ).getCollEvent(specimen.collEventID);
      final site = event == null
          ? null
          : await SiteServices(ref: ref).getSite(event.siteID);
      final siteAttribute = site == null
          ? null
          : await SiteServices(ref: ref).getSiteAttribute(site.id);
      final coordinate = await _coordinateForSpecimen(
        specimen.coordinateID,
        event?.siteID,
      );
      final taxon = specimen.speciesID == null
          ? null
          : await TaxonomyServices(ref: ref).getTaxonById(specimen.speciesID!);
      final eventId = event == null ? null : await _eventId(event);
      final cataloger = await _resolveAgent(
        specimen.catalogerID,
        null,
        'cataloger',
        agents,
      );
      final determiner = await _resolveAgent(
        specimen.determinerID,
        null,
        'determiner',
        agents,
      );
      String? catalogNumber;
      if (specimen.projectFieldNumber != null) {
        catalogNumber = formatProjectFieldId(
          project,
          specimen.projectFieldNumber,
        );
      } else if (specimen.fieldNumber != null) {
        final catalogerData = specimen.catalogerID == null
            ? null
            : await PersonnelServices(
                ref: ref,
              ).getPersonnelByUuid(specimen.catalogerID!);
        catalogNumber =
            '${catalogerData?.initial ?? ''}${specimen.fieldNumber}';
      }
      var eventAgents = event == null
          ? <_ResolvedAgent>[]
          : await _resolveEventAgents(event.id, agents);
      if (eventAgents.isEmpty && cataloger != null) eventAgents = [cataloger];
      final recorders = _catalogerFirst(cataloger, eventAgents);
      final specimenAttributes = await _measurementValues(specimen);

      final occurrenceRow = _occurrenceRow(
        specimen: specimen,
        taxon: taxon,
        event: event,
        eventId: eventId,
        site: site,
        siteAttribute: siteAttribute,
        coordinate: coordinate,
        recorders: recorders,
        determiner: determiner,
        catalogNumber: catalogNumber,
        specimenAttributes: specimenAttributes,
      );
      _applyCustomFields(
        await CustomFieldService(
          dbAccess,
        ).getExportEntries(CustomFieldOwner.specimen(specimen.uuid)),
        occurrenceRow,
        assertionRows: occurrenceAssertionRows,
        assertionOwnerKey: 'occurrenceID',
        assertionOwnerId: specimen.uuid,
        warnings: warnings,
      );
      occurrenceRows.add(occurrenceRow);
      if (event != null) {
        if (!events.containsKey(eventId)) {
          final eventRow = _eventRow(
            event,
            site,
            siteAttribute,
            eventId!,
            eventAgents,
          );
          await _addEnvironmentAssertions(
            event,
            siteAttribute,
            eventId,
            eventAssertionRows,
          );
          _applyCustomFields(
            await CustomFieldService(
              dbAccess,
            ).getExportEntries(CustomFieldOwner.environment(event.id)),
            eventRow,
            assertionRows: eventAssertionRows,
            assertionOwnerKey: 'eventID',
            assertionOwnerId: eventId,
            warnings: warnings,
          );
          if (site != null) {
            _applyCustomFields(
              await CustomFieldService(
                dbAccess,
              ).getExportEntries(CustomFieldOwner.site(site.id)),
              eventRow,
              assertionRows: eventAssertionRows,
              assertionOwnerKey: 'eventID',
              assertionOwnerId: eventId,
              warnings: warnings,
            );
          }
          events[eventId] = eventRow;
        }
        _addAgentRoles(
          targetId: eventId!,
          targetKey: 'eventID',
          agents: eventAgents,
          output: eventAgentRoles,
        );
      }
      _addAgentRoles(
        targetId: specimen.uuid,
        targetKey: 'occurrenceID',
        agents: recorders,
        output: occurrenceAgentRoles,
      );
      if (determiner != null) {
        _addAgentRoles(
          targetId: specimen.uuid,
          targetKey: 'occurrenceID',
          agents: [determiner],
          output: occurrenceAgentRoles,
        );
      }
      materialRows.addAll(
        await _materialRows(
          specimen.uuid,
          eventId,
          agents,
          materialAgentRoles,
          materialAssertionRows,
          warnings,
        ),
      );
      measurementRows.addAll(await _measurementRows(specimen));
      final parasiteExport = await _parasiteRows(
        specimen,
        eventId,
        occurrenceAssertionRows,
        interactionAssertionRows,
        warnings,
      );
      occurrenceRows.addAll(parasiteExport.occurrences);
      interactionRows.addAll(parasiteExport.interactions);
      mediaRows.addAll(
        await _mediaRows(specimen.uuid, agents, mediaAgentRoles),
      );
    }

    return <String, dynamic>{
      'format': format.wireValue,
      'archive_format': archiveFormat.wireValue,
      'name': project.name,
      'project': _removeEmpty(project.toJson()),
      'occurrences': occurrenceRows.map(_removeEmpty).toList(growable: false),
      'events': events.values.map(_removeEmpty).toList(growable: false),
      'materials': materialRows.map(_removeEmpty).toList(growable: false),
      'measurements': measurementRows.map(_removeEmpty).toList(growable: false),
      'event_assertions': eventAssertionRows
          .map(_removeEmpty)
          .toList(growable: false),
      'material_assertions': materialAssertionRows
          .map(_removeEmpty)
          .toList(growable: false),
      'occurrence_assertions': occurrenceAssertionRows
          .map(_removeEmpty)
          .toList(growable: false),
      'organism_interactions': interactionRows
          .map(_removeEmpty)
          .toList(growable: false),
      'organism_interaction_assertions': interactionAssertionRows
          .map(_removeEmpty)
          .toList(growable: false),
      'warnings': warnings,
      'media': mediaRows.map(_removeEmpty).toList(growable: false),
      'agents': agents.values
          .map((agent) => agent.toJson())
          .map(_removeEmpty)
          .toList(growable: false),
      'occurrence_agent_roles': occurrenceAgentRoles
          .map(_removeEmpty)
          .toList(growable: false),
      'event_agent_roles': eventAgentRoles
          .map(_removeEmpty)
          .toList(growable: false),
      'material_agent_roles': materialAgentRoles
          .map(_removeEmpty)
          .toList(growable: false),
      'media_agent_roles': mediaAgentRoles
          .map(_removeEmpty)
          .toList(growable: false),
    };
  }

  Future<T> _withNahpuRequest<T>(
    BundleArchiveFormat archiveFormat,
    Future<T> Function(Map<String, dynamic> request) action,
  ) async {
    final database = dbAccess;
    final transferService = ProjectTransferService(ref: ref);
    final vocabularyFutures = _nahpuControlledVocabularyDefinitions
        .map(
          (definition) => ref.read(
            effectiveUserDefinedFieldProvider(definition.configKey).future,
          ),
        )
        .toList(growable: false);
    final root = await tempDirectory;
    final snapshotDir = await Directory(
      path.join(
        root.path,
        'nahpu-package-${DateTime.now().microsecondsSinceEpoch}',
      ),
    ).create(recursive: true);
    try {
      final configsFile = File(
        path.join(snapshotDir.path, 'user_configs.json'),
      );
      await rust_config.exportConfigToFile(
        filePath: configsFile.path,
        sections: rust_config.UserConfigSection.values,
        customFieldTemplates: const [],
      );
      final payload = await transferService.buildExport();
      final packageInfo = await PackageInfo.fromPlatform();
      final controlledVocabularies = await _readNahpuControlledVocabularies(
        vocabularyFutures,
      );
      final userConfigs =
          jsonDecode(await configsFile.readAsString()) as Map<String, dynamic>;
      final request = <String, dynamic>{
        'archive_format': archiveFormat.wireValue,
        'name': '${payload.projectName} NAHPU data',
        'app_name': 'NAHPU',
        'app_version': packageInfo.version,
        'app_build': packageInfo.buildNumber,
        'database_schema_version': payload.databaseVersion,
        'user_config_schema_version': userConfigs['schema_version'] as int,
        'project_json': payload.encoded,
        'user_configs': userConfigs,
        'tables': await _buildNahpuTables(database, payload),
        'enum_mappings': buildNahpuSqliteEnumMappings(),
        'controlled_vocabularies': controlledVocabularies,
        'files': await _collectNahpuPackageFiles(payload),
      };
      return await action(request);
    } finally {
      if (snapshotDir.existsSync()) {
        snapshotDir.deleteSync(recursive: true);
      }
    }
  }

  Future<List<Map<String, dynamic>>> _buildNahpuTables(
    Database database,
    ProjectTransferPayload payload,
  ) async {
    final tables = <Map<String, dynamic>>[];
    for (final table in database.allTables) {
      final tableName = table.actualTableName;
      final columns = await database
          .customSelect('PRAGMA table_info("$tableName")')
          .get();
      final foreignKeys = await database
          .customSelect('PRAGMA foreign_key_list("$tableName")')
          .get();
      tables.add({
        'name': tableName,
        'columns': columns
            .map(
              (column) => <String, dynamic>{
                'name': column.data['name'].toString(),
                'data_type': column.data['type'].toString(),
                'required': column.data['notnull'] == 1,
                'primary_key': column.data['pk'] != 0,
              },
            )
            .toList(growable: false),
        'foreign_keys': foreignKeys
            .map(
              (foreignKey) => <String, dynamic>{
                'fields': foreignKey.data['from'].toString(),
                'resource': foreignKey.data['table'].toString(),
                'reference_fields': foreignKey.data['to'].toString(),
              },
            )
            .toList(growable: false),
        'rows': tableName == 'project'
            ? [payload.project]
            : payload.rows(tableName),
      });
    }
    return tables;
  }

  Future<List<Map<String, dynamic>>> _readNahpuControlledVocabularies(
    List<Future<List<String>>> futures,
  ) async {
    final output = <Map<String, dynamic>>[];
    for (
      var index = 0;
      index < _nahpuControlledVocabularyDefinitions.length;
      index++
    ) {
      final definition = _nahpuControlledVocabularyDefinitions[index];
      final configured = await futures[index];
      output.add({
        'section': definition.section,
        'config_key': definition.configKey,
        'vocabulary_name': definition.name,
        'values': configured,
      });
    }
    return output;
  }

  Future<List<Map<String, String>>> _collectNahpuPackageFiles(
    ProjectTransferPayload payload,
  ) async {
    final root = await nahpuDocumentDir;
    final output = payload.mediaFiles
        .where((media) => media.sourcePath != null)
        .map(
          (media) => <String, String>{
            'source_path': media.sourcePath!,
            'package_path': media.archivePath,
          },
        )
        .toList();
    final fonts = Directory(
      path.join(root.path, userConfigDirName, userFontDirName),
    );
    if (fonts.existsSync()) {
      await for (final entity in fonts.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) continue;
        final relative = path.relative(entity.path, from: root.path);
        final normalized = relative.replaceAll('\\', '/');
        output.add({
          'source_path': entity.path,
          'package_path': 'files/$normalized',
        });
      }
    }
    output.sort(
      (left, right) => left['package_path']!.compareTo(right['package_path']!),
    );
    return output;
  }

  Future<CoordinateData?> _coordinateForSpecimen(
    int? coordinateId,
    int? siteId,
  ) async {
    final coordinates = CoordinateServices(ref: ref);
    if (coordinateId != null) {
      return coordinates.getCoordinateById(coordinateId);
    }
    if (siteId == null) return null;
    final siteCoordinates = await coordinates.getCoordinatesBySiteID(siteId);
    return siteCoordinates.length == 1 ? siteCoordinates.single : null;
  }

  Map<String, dynamic> _occurrenceRow({
    required SpecimenData specimen,
    required TaxonomyData? taxon,
    required CollEventData? event,
    required String? eventId,
    required SiteData? site,
    required SiteAttributeData? siteAttribute,
    required CoordinateData? coordinate,
    required List<_ResolvedAgent> recorders,
    required _ResolvedAgent? determiner,
    required String? catalogNumber,
    required Map<String, dynamic> specimenAttributes,
  }) {
    final released = specimen.condition?.toLowerCase() == 'released';
    final scientificName = [
      taxon?.genus,
      taxon?.specificEpithet,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
    return <String, dynamic>{
      'occurrenceID': specimen.uuid,
      'basisOfRecord': released ? 'HumanObservation' : 'PreservedSpecimen',
      'occurrenceStatus': 'detected',
      'catalogNumber': catalogNumber,
      'eventID': eventId,
      'eventDate':
          specimen.collectionDate ??
          specimen.captureDate ??
          _eventDate(event?.startDate, event?.endDate),
      'eventTime':
          specimen.collectionTime ?? specimen.captureTime ?? event?.startTime,
      'samplingProtocol': event?.primaryCollMethod,
      'samplingEffort': event?.collMethodNotes,
      'scientificName': scientificName,
      'scientificNameAuthorship': taxon?.authors,
      'kingdom': taxon?.kingdom ?? getKingdom(taxon?.taxonClass),
      'phylum': taxon?.phylum ?? getPhylum(taxon?.taxonClass),
      'class': taxon?.taxonClass,
      'order': taxon?.taxonOrder,
      'family': taxon?.taxonFamily,
      'genus': taxon?.genus,
      'specificEpithet': taxon?.specificEpithet,
      'infraspecificEpithet': taxon?.subspecificEpithet,
      'taxonRank': taxon?.taxonRank,
      'vernacularName': taxon?.commonName,
      'taxonRemarks': taxon?.notes,
      'country': site?.country,
      'islandGroup': site?.islandGroup,
      'stateProvince': site?.stateProvince,
      'county': site?.county,
      'municipality': site?.municipality,
      'locality': site?.locality,
      'habitat': _habitat(siteAttribute),
      'locationRemarks': site?.remark,
      'decimalLatitude': coordinate?.decimalLatitude,
      'decimalLongitude': coordinate?.decimalLongitude,
      'verbatimLatitude': coordinate?.verbatimLatitude,
      'verbatimLongitude': coordinate?.verbatimLongitude,
      'verbatimCoordinates': coordinate?.verbatimCoordinates,
      'verbatimCoordinateSystem': coordinate?.verbatimCoordinateSystem,
      'geodeticDatum': coordinate?.datum,
      'coordinateUncertaintyInMeters': positiveCoordinateUncertainty(
        coordinate?.uncertaintyInMeters?.toDouble(),
        specimen.coordinateExtentMeters,
      ),
      'minimumElevationInMeters': coordinate?.elevationInMeter,
      'maximumElevationInMeters': coordinate?.elevationInMeter,
      'georeferenceRemarks': coordinate?.notes,
      'recordedBy': _agentNames(recorders),
      'recordedByID': _agentIds(recorders),
      'identifiedBy': determiner?.name,
      'identifiedByID': determiner?.id,
      'identificationType': specimen.iDMethod,
      'sex': _specimenSexLabel(specimenAttributes['sex']),
      'lifeStage':
          specimenAttributes['lifeStage'] ??
          specimenAttributes['ontogeneticStage'],
      'caste': _casteLabel(specimenAttributes['caste']),
      'associatedTaxa': _hostAssociation(specimenAttributes['hostOrganism']),
      'occurrenceRemarks': specimenAttributes['remark'],
    };
  }

  String? _specimenSexLabel(dynamic value) {
    return value is int ? getSpecimenSexLabel(value) : null;
  }

  String? _hostAssociation(dynamic value) {
    if (value is! String || value.trim().isEmpty) return null;
    return 'host: ${value.trim()}';
  }

  String? _casteLabel(dynamic value) {
    if (value is! int || value < 0 || value >= arthropodCasteList.length) {
      return null;
    }
    return arthropodCasteList[value];
  }

  String? _habitat(SiteAttributeData? attribute) {
    if (attribute == null) return null;
    final values =
        [
              attribute.habitatType,
              attribute.habitatCondition,
              attribute.habitatDescription,
            ]
            .whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty);
    final habitat = values.join(' | ');
    return habitat.isEmpty ? null : habitat;
  }

  Map<String, dynamic> _eventRow(
    CollEventData event,
    SiteData? site,
    SiteAttributeData? siteAttribute,
    String eventId,
    List<_ResolvedAgent> agents,
  ) {
    final eventDate = _eventDate(event.startDate, event.endDate);
    return <String, dynamic>{
      'eventID': eventId,
      'eventCategory': 'sampling event',
      'eventConductedBy': _agentNames(agents),
      'eventConductedByID': _agentIds(agents),
      'eventDate': eventDate,
      'eventTime': event.startTime,
      'samplingProtocol': event.primaryCollMethod,
      'samplingEffort': event.collMethodNotes,
      'locationID': site == null ? null : _locationId(site),
      'country': site?.country,
      'islandGroup': site?.islandGroup,
      'stateProvince': site?.stateProvince,
      'county': site?.county,
      'municipality': site?.municipality,
      'locality': site?.locality,
      'habitat': _habitat(siteAttribute),
    };
  }

  Future<void> _addEnvironmentAssertions(
    CollEventData event,
    SiteAttributeData? siteAttribute,
    String eventId,
    List<Map<String, dynamic>> output,
  ) async {
    EnvironmentData? environment;
    try {
      environment = await EnvironmentDataQuery(
        dbAccess,
      ).getEnvironmentDataByEventId(event.id);
    } catch (_) {
      environment = null;
    }
    if (environment == null && siteAttribute?.canopyCover == null) return;
    final values = <String, (Object?, String?)>{
      'lowest day temperature': (environment?.lowestDayTempC, '°C'),
      'highest day temperature': (environment?.highestDayTempC, '°C'),
      'lowest night temperature': (environment?.lowestNightTempC, '°C'),
      'highest night temperature': (environment?.highestNightTempC, '°C'),
      'average humidity': (environment?.averageHumidity, '%'),
      'dew point': (environment?.dewPointTemp, '°C'),
      'sunrise': (environment?.sunriseTime, 'hh:mm:ss'),
      'sunset': (environment?.sunsetTime, 'hh:mm:ss'),
      'moon phase': (environment?.moonPhase, null),
      'cloud cover': (environment?.cloudCover, 'okta'),
      'rainfall': (environment?.rainfallInMm, 'mm'),
      'ambient temperature': (environment?.ambientTemperature, '°C'),
      'ambient humidity': (environment?.ambientHumidity, '%'),
      'water temperature': (environment?.waterTemperature, '°C'),
      'pH': (environment?.pH, null),
      'dissolved oxygen': (environment?.dissolvedOxygen, 'mg/L'),
      'flow velocity': (environment?.flowVelocity, 'm/s'),
      'canopy cover': (siteAttribute?.canopyCover, null),
      'environmental notes': (environment?.notes, null),
    };
    for (final entry in values.entries) {
      final value = entry.value.$1;
      if (value == null || value.toString().trim().isEmpty) continue;
      output.add({
        'eventID': eventId,
        'assertionID': '$eventId:environment:${entry.key.replaceAll(' ', '-')}',
        'assertionType': entry.key,
        'assertionValue': entry.value.$1,
        'assertionUnit': entry.value.$2,
      });
    }
  }

  Future<List<Map<String, dynamic>>> _materialRows(
    String specimenUuid,
    String? eventId,
    Map<String, _ResolvedAgent> agents,
    List<Map<String, dynamic>> roles,
    List<Map<String, dynamic>> assertionRows,
    List<String> warnings,
  ) async {
    final parts = await SpecimenPartServices(
      ref: ref,
    ).getSpecimenParts(specimenUuid);
    final rows = <Map<String, dynamic>>[];
    for (final part in parts) {
      final materialEntityId = '$specimenUuid:part:${part.id}';
      final preparations = [part.treatment, part.additionalTreatment]
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .join(' | ');
      final otherCatalogNumbers = part.barcodeID == part.tissueID
          ? null
          : part.barcodeID;
      final row = <String, dynamic>{
        'occurrenceID': specimenUuid,
        'eventID': eventId,
        'materialEntityID': materialEntityId,
        'materialEntityType': part.type,
        'catalogNumber': part.tissueID ?? part.barcodeID,
        'otherCatalogNumbers': otherCatalogNumbers,
        'preparations': preparations,
        'materialEntityRemarks': part.remark,
      };
      _applyCustomFields(
        await CustomFieldService(
          dbAccess,
        ).getExportEntries(CustomFieldOwner.specimenPart(part.id!)),
        row,
        assertionRows: assertionRows,
        assertionOwnerKey: 'materialEntityID',
        assertionOwnerId: materialEntityId,
        warnings: warnings,
      );
      rows.add(row);
      final agent = await _resolveAgent(
        part.personnelId,
        null,
        'preparator',
        agents,
      );
      if (agent != null) {
        _addAgentRoles(
          targetId: materialEntityId,
          targetKey: 'materialEntityID',
          agents: [agent],
          output: roles,
        );
      }
    }
    return rows;
  }

  Future<
    ({
      List<Map<String, dynamic>> occurrences,
      List<Map<String, dynamic>> interactions,
    })
  >
  _parasiteRows(
    SpecimenData host,
    String? eventId,
    List<Map<String, dynamic>> occurrenceAssertions,
    List<Map<String, dynamic>> interactionAssertions,
    List<String> warnings,
  ) async {
    final parasites = await (dbAccess.select(
      dbAccess.parasite,
    )..where((row) => row.specimenUuid.equals(host.uuid))).get();
    final occurrences = <Map<String, dynamic>>[];
    final interactions = <Map<String, dynamic>>[];
    for (final parasite in parasites) {
      final occurrenceId = parasite.parasiteUuid;
      final taxon = parasite.speciesID == null
          ? null
          : await TaxonomyServices(ref: ref).getTaxonById(parasite.speciesID!);
      final scientificName = [
        taxon?.genus,
        taxon?.specificEpithet,
      ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
      final occurrence = <String, dynamic>{
        'occurrenceID': occurrenceId,
        'eventID': eventId,
        'basisOfRecord': 'PreservedSpecimen',
        'occurrenceStatus': 'detected',
        'scientificName': scientificName,
        'class': taxon?.taxonClass,
        'order': taxon?.taxonOrder,
        'family': taxon?.taxonFamily,
        'genus': taxon?.genus,
        'specificEpithet': taxon?.specificEpithet,
        'lifeStage': parasite.lifeStage,
        'individualCount': parasite.count,
        'preparations': parasite.preparationMethod,
        'occurrenceRemarks': parasite.remark,
        'associatedOccurrences': 'host:${host.uuid}',
      };
      final interactionId = occurrenceId;
      final interaction = <String, dynamic>{
        'organismInteractionID': interactionId,
        'subjectOccurrenceID': occurrenceId,
        'relatedOccurrenceID': host.uuid,
        'eventID': eventId,
        'organismInteractionType': parasite.category,
        'relatedOrganismPart': parasite.anatomicalLocation,
        'organismInteractionDescription': parasite.associationStatus == null
            ? null
            : parasiteAssociationStatuses[parasite.associationStatus],
      };
      final entries = await CustomFieldService(
        dbAccess,
      ).getExportEntries(CustomFieldOwner.parasite(parasite.id!));
      _applyCustomFields(
        entries
            .where(
              (entry) =>
                  entry.definition.dwcMapping?.target != 'organismInteraction',
            )
            .toList(growable: false),
        occurrence,
        assertionRows: occurrenceAssertions,
        assertionOwnerKey: 'occurrenceID',
        assertionOwnerId: occurrenceId,
        warnings: warnings,
      );
      _applyCustomFields(
        entries
            .where(
              (entry) =>
                  entry.definition.dwcMapping?.target == 'organismInteraction',
            )
            .toList(growable: false),
        interaction,
        assertionRows: interactionAssertions,
        assertionOwnerKey: 'organismInteractionID',
        assertionOwnerId: interactionId,
        warnings: warnings,
        includeUnmapped: false,
      );
      occurrences.add(occurrence);
      interactions.add(interaction);
    }
    return (occurrences: occurrences, interactions: interactions);
  }

  void _applyCustomFields(
    List<CustomFieldEntry> entries,
    Map<String, dynamic> row, {
    required List<Map<String, dynamic>> assertionRows,
    required String assertionOwnerKey,
    required String assertionOwnerId,
    required List<String> warnings,
    bool includeUnmapped = true,
  }) {
    final dynamicProperties = <String, dynamic>{};
    for (final entry in entries) {
      final value = entry.value;
      if (value == null) continue;
      final definition = entry.definition;
      final display = definition.displayValue(value.value);
      final mapping = definition.dwcMapping;
      if (mapping == null) {
        if (includeUnmapped) {
          dynamicProperties[definition.name] = _typedCustomValue(
            definition,
            value.value,
          );
        }
        continue;
      }
      if (mapping.mode == DwcMappingMode.assertion) {
        assertionRows.add({
          assertionOwnerKey: assertionOwnerId,
          'assertionID': '$assertionOwnerId:custom:${definition.uuid}',
          'assertionType': definition.name,
          'assertionValue': display,
        });
        continue;
      }
      final targetField = mapping.field.split(':').last;
      final builtIn = row[targetField]?.toString().trim();
      if (builtIn != null && builtIn.isNotEmpty) {
        row[targetField] = '$builtIn | $display';
        warnings.add(
          '${definition.name} adds another value to ${mapping.field} for '
          '$assertionOwnerId.',
        );
      } else {
        row[targetField] = display;
      }
    }
    if (dynamicProperties.isNotEmpty) {
      row['dynamicProperties'] = jsonEncode(dynamicProperties);
    }
  }

  Object _typedCustomValue(
    CustomFieldDefinitionData definition,
    String value,
  ) => switch (definition.fieldType) {
    FieldType.boolean => value == 'true',
    FieldType.number => num.tryParse(value) ?? value,
    FieldType.text || FieldType.dropdown => definition.displayValue(value),
  };

  Future<List<Map<String, dynamic>>> _measurementRows(
    SpecimenData specimen,
  ) async {
    final raw = await _measurementValues(specimen);
    final rows = <Map<String, dynamic>>[];
    for (final entry in _measurementDefinitions.entries) {
      final value = raw[entry.key];
      if (value == null || value.toString().trim().isEmpty) continue;
      rows.add(<String, dynamic>{
        'occurrenceID': specimen.uuid,
        'measurementID': '${specimen.uuid}:${entry.key}',
        'measurementType': entry.value.type,
        'measurementValue': value,
        'measurementUnit': entry.key == 'weight'
            ? raw['weightUnit'] ?? entry.value.unit
            : entry.value.unit,
      });
    }
    return rows;
  }

  Future<Map<String, dynamic>> _measurementValues(SpecimenData specimen) async {
    try {
      switch (normalizeBundleTaxonGroup(specimen.taxonGroup)) {
        case 'Birds':
          return (await SpecimenServices(
            ref: ref,
          ).getBirdAttributeData(specimen.uuid)).toJson();
        case 'Herpetofauna':
          return (await SpecimenServices(
            ref: ref,
          ).getHerpAttributeData(specimen.uuid)).toJson();
        case 'Arthropods':
          return (await SpecimenServices(
            ref: ref,
          ).getArthropodAttributeData(specimen.uuid)).toJson();
        case 'Fossils':
          return (await (dbAccess.select(dbAccess.fossilAttribute)
                    ..where((row) => row.specimenUuid.equals(specimen.uuid)))
                  .getSingle())
              .toJson();
        default:
          return (await SpecimenServices(
            ref: ref,
          ).getMammalAttributeData(specimen.uuid)).toJson();
      }
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Future<List<Map<String, dynamic>>> _mediaRows(
    String specimenUuid,
    Map<String, _ResolvedAgent> agents,
    List<Map<String, dynamic>> roles,
  ) async {
    final links = await SpecimenServices(
      ref: ref,
    ).getSpecimenMedia(specimenUuid);
    final rows = <Map<String, dynamic>>[];
    for (final link in links) {
      final mediaId = link.mediaId;
      if (mediaId == null) continue;
      final media = await MediaServices(ref: ref).getMediaById(mediaId);
      final stableMediaId = '$currentProjectUuid:media:$mediaId';
      String? sourcePath;
      if (media.fileName != null && media.category != null) {
        final file = await MediaFinder(ref: ref).getPathForMedia(
          media.fileName!,
          matchMediaCategoryString(media.category!),
        );
        sourcePath = file.path;
      }
      final creator = await _resolveAgent(
        media.personnelId,
        null,
        'creator',
        agents,
      );
      if (creator != null) {
        _addAgentRoles(
          targetId: stableMediaId,
          targetKey: 'mediaID',
          agents: [creator],
          output: roles,
        );
      }
      rows.add(<String, dynamic>{
        'occurrenceID': specimenUuid,
        'mediaID': stableMediaId,
        'mediaType': _mediaType(media.fileName),
        'title': media.caption ?? media.fileName,
        'created': media.taken,
        'creator': creator?.name,
        'creatorID': creator?.id,
        'description': media.additionalExif,
        'accessURI': media.fileName == null
            ? null
            : 'media/$mediaId-${media.fileName}',
        'source_path': sourcePath,
      });
    }
    return rows;
  }

  Future<List<_ResolvedAgent>> _resolveEventAgents(
    int eventId,
    Map<String, _ResolvedAgent> agents,
  ) async {
    final personnel = await CollEventServices(
      ref: ref,
    ).getAllCollPersonnel(eventId);
    final resolved = <_ResolvedAgent>[];
    for (final entry in personnel) {
      final agent = await _resolveAgent(
        entry.personnelId,
        entry.name,
        entry.role ?? 'collector',
        agents,
      );
      if (agent != null) resolved.add(agent);
    }
    return resolved;
  }

  Future<_ResolvedAgent?> _resolveAgent(
    String? id,
    String? storedName,
    String role,
    Map<String, _ResolvedAgent> agents,
  ) async {
    var name = storedName?.trim();
    String? orcid;
    if (id != null && id.isNotEmpty) {
      final person = await PersonnelServices(ref: ref).getPersonnelByUuid(id);
      if (name == null || name.isEmpty) name = person.name?.trim();
      orcid = person.orcid;
    }
    if ((id == null || id.isEmpty) && (name == null || name.isEmpty)) {
      return null;
    }
    final agentId =
        canonicalOrcidUrl(orcid) ??
        (id?.isNotEmpty == true
            ? id!
            : 'name:${name!.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), "-")}');
    final resolved = _ResolvedAgent(
      id: agentId,
      name: name?.isNotEmpty == true ? name! : agentId,
      role: role.trim().isEmpty ? 'contributor' : role.trim(),
    );
    agents.putIfAbsent(agentId, () => resolved);
    return resolved;
  }

  List<_ResolvedAgent> _catalogerFirst(
    _ResolvedAgent? cataloger,
    Iterable<_ResolvedAgent> eventAgents,
  ) {
    final recorders = <_ResolvedAgent>[];
    if (cataloger != null) recorders.add(cataloger);
    for (final agent in eventAgents) {
      if (recorders.every((recorder) => recorder.id != agent.id)) {
        recorders.add(agent);
      }
    }
    return recorders;
  }

  void _addAgentRoles({
    required String targetId,
    required String targetKey,
    required List<_ResolvedAgent> agents,
    required List<Map<String, dynamic>> output,
  }) {
    for (var index = 0; index < agents.length; index++) {
      final agent = agents[index];
      final role = <String, dynamic>{
        targetKey: targetId,
        'agentID': agent.id,
        'agentRole': agent.role,
        'agentRoleOrder': index + 1,
      };
      final duplicate = output.any(
        (entry) =>
            entry[targetKey] == targetId &&
            entry['agentID'] == agent.id &&
            entry['agentRole'] == agent.role,
      );
      if (!duplicate) output.add(role);
    }
  }

  String? _agentNames(List<_ResolvedAgent> agents) {
    final values = <String>[];
    for (final agent in agents) {
      if (!values.contains(agent.name)) values.add(agent.name);
    }
    return values.isEmpty ? null : values.join(' | ');
  }

  String? _agentIds(List<_ResolvedAgent> agents) {
    final values = <String>[];
    for (final agent in agents) {
      if (!values.contains(agent.id)) values.add(agent.id);
    }
    return values.isEmpty ? null : values.join(' | ');
  }

  String _mediaType(String? fileName) {
    final extension = fileName?.split('.').last.toLowerCase() ?? '';
    if (const {
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'tif',
      'tiff',
    }.contains(extension)) {
      return 'StillImage';
    }
    if (const {'wav', 'mp3', 'm4a', 'flac', 'ogg'}.contains(extension)) {
      return 'Sound';
    }
    if (const {'mp4', 'mov', 'avi', 'mkv', 'webm'}.contains(extension)) {
      return 'MovingImage';
    }
    return 'Text';
  }

  Set<String> _expandTaxonSelection(Set<String> selectedGroups) {
    final normalized = selectedGroups.map(normalizeBundleTaxonGroup).toSet();
    if (normalized.contains('Mammals')) normalized.add('Bats');
    return normalized;
  }

  Future<String> _eventId(CollEventData event) async {
    final localId = await CollEventServices(ref: ref).getCollEventID(event);
    return '$currentProjectUuid:event:$localId';
  }

  String _locationId(SiteData site) =>
      '$currentProjectUuid:site:${site.siteID ?? site.id}';

  String? _eventDate(String? start, String? end) {
    if (start == null || start.trim().isEmpty) return end;
    if (end == null || end.trim().isEmpty || end == start) return start;
    return '$start/$end';
  }
}

List<Map<String, dynamic>> buildNahpuSqliteEnumMappings() {
  return [
    ..._specimenSexMappingRows(table: 'mammalAttribute', column: 'sex'),
    ..._specimenSexMappingRows(table: 'birdAttribute', column: 'sex'),
    ..._specimenSexMappingRows(table: 'herpAttribute', column: 'sex'),
    ..._specimenSexMappingRows(table: 'arthropodAttribute', column: 'sex'),
    ..._indexedMappingRows(
      table: 'arthropodAttribute',
      column: 'caste',
      enumType: 'ArthropodCaste',
      enumNames: arthropodCasteList,
      displayNames: arthropodCasteList,
    ),
    ..._enumMappingRows(
      table: 'mammalAttribute',
      column: 'testisPosition',
      enumType: 'mammals.TestisPosition',
      values: mammals.TestisPosition.values,
      displayNames: mammals.testisPositionList,
    ),
    ..._enumMappingRows(
      table: 'mammalAttribute',
      column: 'epididymisAppearance',
      enumType: 'mammals.EpididymisAppearance',
      values: mammals.EpididymisAppearance.values,
      displayNames: mammals.epididymisAppearanceList,
    ),
    ..._enumMappingRows(
      table: 'mammalAttribute',
      column: 'vaginaOpening',
      enumType: 'mammals.VaginaOpening',
      values: mammals.VaginaOpening.values,
      displayNames: mammals.vaginaOpeningList,
    ),
    ..._enumMappingRows(
      table: 'mammalAttribute',
      column: 'pubicSymphysis',
      enumType: 'mammals.PubicSymphysis',
      values: mammals.PubicSymphysis.values,
      displayNames: mammals.pubicSymphysisList,
    ),
    ..._enumMappingRows(
      table: 'mammalAttribute',
      column: 'reproductiveStage',
      enumType: 'mammals.ReproductiveStage',
      values: mammals.ReproductiveStage.values,
      displayNames: mammals.reproductiveStageList,
    ),
    ..._enumMappingRows(
      table: 'mammalAttribute',
      column: 'mammaeCondition',
      enumType: 'mammals.MammaeCondition',
      values: mammals.MammaeCondition.values,
      displayNames: mammals.mammaeConditionList,
    ),
    ..._enumMappingRows(
      table: 'mammalAttribute',
      column: 'echolocation',
      enumType: 'mammals.Echolocation',
      values: mammals.Echolocation.values,
      displayNames: mammals.echolocationList,
    ),
    ..._enumMappingRows(
      table: 'birdAttribute',
      column: 'ovaryAppearance',
      enumType: 'birds.OvaryAppearance',
      values: birds.OvaryAppearance.values,
      displayNames: birds.ovaryAppearanceList,
    ),
    ..._enumMappingRows(
      table: 'birdAttribute',
      column: 'fat',
      enumType: 'birds.FatCategory',
      values: birds.FatCategory.values,
      displayNames: birds.fatCategoryList,
    ),
    ..._enumMappingRows(
      table: 'birdAttribute',
      column: 'oviductAppearance',
      enumType: 'birds.OviductAppearance',
      values: birds.OviductAppearance.values,
      displayNames: birds.oviductAppearanceList,
    ),
    ..._enumMappingRows(
      table: 'birdAttribute',
      column: 'bodyMolt',
      enumType: 'birds.BodyMolt',
      values: birds.BodyMolt.values,
      displayNames: birds.bodyMoltList,
    ),
    ..._indexedMappingRows(
      table: 'specimen',
      column: 'iDConfidence',
      enumType: 'IdentificationConfidence',
      enumNames: const ['low', 'medium', 'high'],
      displayNames: idConfidenceList,
    ),
  ];
}

List<Map<String, dynamic>> _specimenSexMappingRows({
  required String table,
  required String column,
}) {
  return [
    for (final entry in specimenSexByCode.entries)
      <String, dynamic>{
        'table': table,
        'column': column,
        'enum_type': 'SpecimenSex',
        'sqlite_index': entry.key,
        'enum_name': entry.value.name,
        'display_name': specimenSexLabel[entry.value],
      },
  ];
}

List<Map<String, dynamic>> _enumMappingRows({
  required String table,
  required String column,
  required String enumType,
  required List<Enum> values,
  required List<String> displayNames,
}) {
  return _indexedMappingRows(
    table: table,
    column: column,
    enumType: enumType,
    enumNames: values.map((value) => value.name).toList(growable: false),
    displayNames: displayNames,
  );
}

List<Map<String, dynamic>> _indexedMappingRows({
  required String table,
  required String column,
  required String enumType,
  required List<String> enumNames,
  required List<String> displayNames,
}) {
  assert(enumNames.length == displayNames.length);
  return List.generate(
    enumNames.length,
    (index) => <String, dynamic>{
      'table': table,
      'column': column,
      'enum_type': enumType,
      'sqlite_index': index,
      'enum_name': enumNames[index],
      'display_name': displayNames[index],
    },
    growable: false,
  );
}

class _NahpuControlledVocabularyDefinition {
  const _NahpuControlledVocabularyDefinition({
    required this.section,
    required this.configKey,
    required this.name,
  });

  final String section;
  final String configKey;
  final String name;
}

const _nahpuControlledVocabularyDefinitions = [
  _NahpuControlledVocabularyDefinition(
    section: 'site',
    configKey: siteTypePrefKey,
    name: 'Site type',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'site',
    configKey: habitatTypePrefKey,
    name: 'Habitat type',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'events',
    configKey: collMethodPrefKey,
    name: 'Collecting method',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'events',
    configKey: collRolePrefKey,
    name: 'Collecting personnel role',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'specimens',
    configKey: specimenTypePrefKey,
    name: 'Specimen type',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'specimens',
    configKey: treatmentPrefKey,
    name: 'Specimen treatment',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'specimens',
    configKey: conditionPrefKey,
    name: 'Specimen condition',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'specimens',
    configKey: specimenSexPrefKey,
    name: 'Specimen sex',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'specimens',
    configKey: idMethodPrefKey,
    name: 'IdMethod',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'specimens',
    configKey: lifeStagePrefKey,
    name: 'Life stage',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'parasites',
    configKey: parasiteCategoryPrefKey,
    name: 'Parasite category',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'parasites',
    configKey: parasiteDetectionMethodPrefKey,
    name: 'Parasite detection method',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'parasites',
    configKey: parasitePreparationMethodPrefKey,
    name: 'Parasite preparation method',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'parasites',
    configKey: parasiteAnatomicalLocationPrefKey,
    name: 'Parasite anatomical location',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'parasites',
    configKey: parasiteStoragePrefKey,
    name: 'Parasite storage',
  ),
  _NahpuControlledVocabularyDefinition(
    section: 'parasites',
    configKey: parasiteTreatmentPrefKey,
    name: 'Parasite treatment',
  ),
];

class _MeasurementDefinition {
  const _MeasurementDefinition(this.type, [this.unit]);

  final String type;
  final String? unit;
}

class _ResolvedAgent {
  const _ResolvedAgent({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final String role;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'agentID': id,
    'agentType': 'person',
    'preferredAgentName': name,
  };
}

const _measurementDefinitions = <String, _MeasurementDefinition>{
  'weight': _MeasurementDefinition('weight', 'g'),
  'totalLength': _MeasurementDefinition('total length', 'mm'),
  'tailLength': _MeasurementDefinition('tail length', 'mm'),
  'hindFootLength': _MeasurementDefinition('hind foot length', 'mm'),
  'earLength': _MeasurementDefinition('ear length', 'mm'),
  'forearm': _MeasurementDefinition('forearm length', 'mm'),
  'tibia': _MeasurementDefinition('tibia length', 'mm'),
  'wingspan': _MeasurementDefinition('wingspan', 'mm'),
  'svl': _MeasurementDefinition('snout-vent length', 'cm'),
  'frequencyMax': _MeasurementDefinition('maximum frequency', 'kHz'),
  'frequencyMin': _MeasurementDefinition('minimum frequency', 'kHz'),
  'frequencyAtMaxEnergy': _MeasurementDefinition(
    'frequency at maximum energy',
    'kHz',
  ),
  'headWidth': _MeasurementDefinition('head width', 'mm'),
  'bodyLength': _MeasurementDefinition('body length', 'mm'),
  'wingspanUpper': _MeasurementDefinition('upper wingspan', 'mm'),
  'wingspanLower': _MeasurementDefinition('lower wingspan', 'mm'),
  'hostPart': _MeasurementDefinition('host part'),
};

/// Normalizes both current and legacy database labels to package choices.
String normalizeBundleTaxonGroup(String? value) {
  final normalized = (value ?? '').toLowerCase().replaceAll(
    RegExp(r'[^a-z]'),
    '',
  );
  if (normalized == 'bat' || normalized == 'bats') return 'Bats';
  if (normalized.contains('mammal')) return 'Mammals';
  if (normalized.contains('bird') ||
      normalized.contains('avian') ||
      normalized == 'aves') {
    return 'Birds';
  }
  if (normalized.contains('herp') ||
      normalized.contains('reptil') ||
      normalized.contains('amphib')) {
    return 'Herpetofauna';
  }
  if (normalized.contains('arthropod') ||
      normalized.contains('insect') ||
      normalized.contains('arachnid')) {
    return 'Arthropods';
  }
  if (normalized.contains('fossil') || normalized.contains('paleo')) {
    return 'Fossils';
  }
  return value?.trim().isNotEmpty == true ? value!.trim() : 'Other';
}

Map<String, dynamic> _removeEmpty(Map<String, dynamic> source) {
  return Map<String, dynamic>.fromEntries(
    source.entries.where((entry) {
      final value = entry.value;
      return value != null && (value is! String || value.trim().isNotEmpty);
    }),
  );
}
