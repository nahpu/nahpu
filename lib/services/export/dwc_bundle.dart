import 'dart:convert';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/media_services.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/src/rust/api/dwc.dart';

enum DwcBundleFormat { darwinCoreArchive, darwinCoreDataPackage }

extension DwcBundleFormatLabel on DwcBundleFormat {
  String get label => switch (this) {
        DwcBundleFormat.darwinCoreArchive => 'Darwin Core Archive',
        DwcBundleFormat.darwinCoreDataPackage => 'Darwin Core Data Package',
      };

  String get outputExtension => switch (this) {
        DwcBundleFormat.darwinCoreArchive => 'zip',
        DwcBundleFormat.darwinCoreDataPackage => 'dwc-dp',
      };

  String get wireValue => switch (this) {
        DwcBundleFormat.darwinCoreArchive => 'darwin_core_archive',
        DwcBundleFormat.darwinCoreDataPackage => 'darwin_core_data_package',
      };
}

/// A complete, display-ready description of a bundle before it is written.
class DwcBundleManifest {
  const DwcBundleManifest({
    required this.files,
    required this.warnings,
  });

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
    required Set<String> selectedTaxonGroups,
  }) async {
    final request = await _buildRequest(format, selectedTaxonGroups);
    return DwcBundleManifest.fromJson(
      await planDwcBundle(requestJson: jsonEncode(request)),
    );
  }

  Future<DwcBundleManifest> write({
    required DwcBundleFormat format,
    required Set<String> selectedTaxonGroups,
    required String outputPath,
  }) async {
    final request = await _buildRequest(format, selectedTaxonGroups);
    final validation =
        await validateDwcBundle(requestJson: jsonEncode(request));
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
    Set<String> requestedGroups,
  ) async {
    final selectedGroups = _expandTaxonSelection(requestedGroups);
    final project =
        await ProjectServices(ref: ref).getProjectByUuid(currentProjectUuid);
    final specimens = await SpecimenServices(ref: ref).getAllSpecimens();
    final selected = specimens.where((specimen) {
      return selectedGroups
          .contains(normalizeBundleTaxonGroup(specimen.taxonGroup));
    }).toList(growable: false);

    final events = <String, Map<String, dynamic>>{};
    final occurrenceRows = <Map<String, dynamic>>[];
    final materialRows = <Map<String, dynamic>>[];
    final measurementRows = <Map<String, dynamic>>[];
    final mediaRows = <Map<String, dynamic>>[];
    final agents = <String, _ResolvedAgent>{};
    final occurrenceAgentRoles = <Map<String, dynamic>>[];
    final eventAgentRoles = <Map<String, dynamic>>[];
    final materialAgentRoles = <Map<String, dynamic>>[];
    final mediaAgentRoles = <Map<String, dynamic>>[];

    for (final specimen in selected) {
      final event =
          await CollEventServices(ref: ref).getCollEvent(specimen.collEventID);
      final site = event == null
          ? null
          : await SiteServices(ref: ref).getSite(event.siteID);
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
      var eventAgents = event == null
          ? <_ResolvedAgent>[]
          : await _resolveEventAgents(event.id, agents);
      if (eventAgents.isEmpty && cataloger != null) eventAgents = [cataloger];
      final recorders = _catalogerFirst(cataloger, eventAgents);

      occurrenceRows.add(_occurrenceRow(
        specimen: specimen,
        taxon: taxon,
        event: event,
        eventId: eventId,
        site: site,
        coordinate: coordinate,
        recorders: recorders,
      ));
      if (event != null) {
        events.putIfAbsent(
          eventId!,
          () => _eventRow(event, site, eventId, eventAgents),
        );
        _addAgentRoles(
          targetId: eventId,
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
      materialRows.addAll(await _materialRows(
        specimen.uuid,
        eventId,
        agents,
        materialAgentRoles,
      ));
      measurementRows.addAll(await _measurementRows(specimen));
      mediaRows.addAll(await _mediaRows(
        specimen.uuid,
        agents,
        mediaAgentRoles,
      ));
    }

    return <String, dynamic>{
      'format': format.wireValue,
      'name': project.name,
      'project': _removeEmpty(project.toJson()),
      'occurrences': occurrenceRows.map(_removeEmpty).toList(growable: false),
      'events': events.values.map(_removeEmpty).toList(growable: false),
      'materials': materialRows.map(_removeEmpty).toList(growable: false),
      'measurements': measurementRows.map(_removeEmpty).toList(growable: false),
      'media': mediaRows.map(_removeEmpty).toList(growable: false),
      'agents': agents.values
          .map((agent) => agent.toJson())
          .map(_removeEmpty)
          .toList(growable: false),
      'occurrence_agent_roles':
          occurrenceAgentRoles.map(_removeEmpty).toList(growable: false),
      'event_agent_roles':
          eventAgentRoles.map(_removeEmpty).toList(growable: false),
      'material_agent_roles':
          materialAgentRoles.map(_removeEmpty).toList(growable: false),
      'media_agent_roles':
          mediaAgentRoles.map(_removeEmpty).toList(growable: false),
    };
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
    required CoordinateData? coordinate,
    required List<_ResolvedAgent> recorders,
  }) {
    final released = specimen.condition?.toLowerCase() == 'released';
    final scientificName = [taxon?.genus, taxon?.specificEpithet]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join(' ');
    return <String, dynamic>{
      'occurrenceID': specimen.uuid,
      'basisOfRecord': released ? 'HumanObservation' : 'PreservedSpecimen',
      'occurrenceStatus': 'detected',
      'catalogNumber': specimen.projectFieldNumber ?? specimen.fieldNumber,
      'eventID': eventId,
      'eventDate': specimen.collectionDate ??
          specimen.captureDate ??
          _eventDate(event?.startDate, event?.endDate),
      'eventTime':
          specimen.collectionTime ?? specimen.captureTime ?? event?.startTime,
      'samplingProtocol': event?.primaryCollMethod,
      'samplingEffort': event?.collMethodNotes,
      'scientificName': scientificName,
      'scientificNameAuthorship': taxon?.authors,
      'kingdom': getKingdom(taxon?.taxonClass),
      'phylum': getPhylum(taxon?.taxonClass),
      'class': taxon?.taxonClass,
      'order': taxon?.taxonOrder,
      'family': taxon?.taxonFamily,
      'genus': taxon?.genus,
      'specificEpithet': taxon?.specificEpithet,
      'vernacularName': taxon?.commonName,
      'taxonRemarks': taxon?.notes,
      'country': site?.country,
      'stateProvince': site?.stateProvince,
      'county': site?.county,
      'municipality': site?.municipality,
      'locality': site?.locality,
      'habitat': site?.habitatDescription ?? site?.habitatType,
      'locationRemarks': site?.remark,
      'decimalLatitude': coordinate?.decimalLatitude,
      'decimalLongitude': coordinate?.decimalLongitude,
      'geodeticDatum': coordinate?.datum,
      'coordinateUncertaintyInMeters': coordinate?.uncertaintyInMeters,
      'minimumElevationInMeters': coordinate?.elevationInMeter,
      'maximumElevationInMeters': coordinate?.elevationInMeter,
      'georeferenceRemarks': coordinate?.notes,
      'disposition': specimen.condition,
      'recordedBy': _agentNames(recorders),
      'recordedByID': _agentIds(recorders),
    };
  }

  Map<String, dynamic> _eventRow(
    CollEventData event,
    SiteData? site,
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
      'stateProvince': site?.stateProvince,
      'county': site?.county,
      'municipality': site?.municipality,
      'locality': site?.locality,
      'habitat': site?.habitatDescription ?? site?.habitatType,
    };
  }

  Future<List<Map<String, dynamic>>> _materialRows(
    String specimenUuid,
    String? eventId,
    Map<String, _ResolvedAgent> agents,
    List<Map<String, dynamic>> roles,
  ) async {
    final parts =
        await SpecimenPartServices(ref: ref).getSpecimenParts(specimenUuid);
    final rows = <Map<String, dynamic>>[];
    for (final part in parts) {
      final materialEntityId = '$specimenUuid:part:${part.id}';
      final preparations = [
        part.treatment,
        part.additionalTreatment,
      ]
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .join(' | ');
      final otherCatalogNumbers =
          part.barcodeID == part.tissueID ? null : part.barcodeID;
      rows.add(<String, dynamic>{
        'occurrenceID': specimenUuid,
        'eventID': eventId,
        'materialEntityID': materialEntityId,
        'materialEntityType': part.type,
        'catalogNumber': part.tissueID ?? part.barcodeID,
        'otherCatalogNumbers': otherCatalogNumbers,
        'preparations': preparations,
        'materialEntityRemarks': part.remark,
      });
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

  Future<List<Map<String, dynamic>>> _measurementRows(
      SpecimenData specimen) async {
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
        'measurementUnit': entry.value.unit,
      });
    }
    return rows;
  }

  Future<Map<String, dynamic>> _measurementValues(SpecimenData specimen) async {
    try {
      switch (normalizeBundleTaxonGroup(specimen.taxonGroup)) {
        case 'Birds':
          return (await SpecimenServices(ref: ref)
                  .getAvianMeasurementData(specimen.uuid))
              .toJson();
        case 'Herpetofauna':
          return (await SpecimenServices(ref: ref)
                  .getHerpMeasurementData(specimen.uuid))
              .toJson();
        default:
          return (await SpecimenServices(ref: ref)
                  .getMammalMeasurementData(specimen.uuid))
              .toJson();
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
    final links =
        await SpecimenServices(ref: ref).getSpecimenMedia(specimenUuid);
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
        'accessURI':
            media.fileName == null ? null : 'media/$mediaId-${media.fileName}',
        'source_path': sourcePath,
      });
    }
    return rows;
  }

  Future<List<_ResolvedAgent>> _resolveEventAgents(
    int eventId,
    Map<String, _ResolvedAgent> agents,
  ) async {
    final personnel =
        await CollEventServices(ref: ref).getAllCollPersonnel(eventId);
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
    if ((name == null || name.isEmpty) && id != null && id.isNotEmpty) {
      name = (await PersonnelServices(ref: ref).getPersonnelName(id))?.trim();
    }
    if ((id == null || id.isEmpty) && (name == null || name.isEmpty)) {
      return null;
    }
    final agentId = id?.isNotEmpty == true
        ? id!
        : 'name:${name!.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), "-")}';
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
      final duplicate = output.any((entry) =>
          entry[targetKey] == targetId &&
          entry['agentID'] == agent.id &&
          entry['agentRole'] == agent.role);
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
    if (const {'jpg', 'jpeg', 'png', 'gif', 'webp', 'tif', 'tiff'}
        .contains(extension)) {
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
  'frequencyAtMaxEnergy':
      _MeasurementDefinition('frequency at maximum energy', 'kHz'),
};

/// Normalizes both current and legacy database labels to package choices.
String normalizeBundleTaxonGroup(String? value) {
  final normalized =
      (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
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
  return value?.trim().isNotEmpty == true ? value!.trim() : 'Other';
}

Map<String, dynamic> _removeEmpty(Map<String, dynamic> source) {
  return Map<String, dynamic>.fromEntries(source.entries.where((entry) {
    final value = entry.value;
    return value != null && (value is! String || value.trim().isNotEmpty);
  }));
}
