import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/custom_fields/custom_field_service.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/export/common.dart';
import 'package:nahpu/services/export/dwc_values.dart';
import 'package:nahpu/services/projects/orcid.dart';
import 'package:nahpu/services/types/custom_field.dart';

enum MultiEntryExpansion { concatenate, specimenParts, parasites }

/// Builds template source maps using canonical database `table::field` keys.
class DynamicRecordExporter {
  DynamicRecordExporter({required this.ref, required this.expansion});
  final WidgetRef ref;
  final MultiEntryExpansion expansion;

  Future<List<Map<String, String>>> getRecord(SpecimenData data) async {
    final Map<String, String> baseRecord = {};

    // Pre-populate specimenPart keys to avoid unresolved placeholders
    final partColumns = [
      'id',
      'specimenUuid',
      'personnelId',
      'tissueID',
      'barcodeID',
      'type',
      'count',
      'treatment',
      'additionalTreatment',
      'storage',
      'storageLocation',
      'dateTaken',
      'timeTaken',
      'pmi',
      'museumPermanent',
      'museumLoan',
      'remark',
    ];
    for (var col in partColumns) {
      baseRecord['specimenPart::$col'] = '';
    }
    for (final col in const [
      'specimenUuid',
      'parasiteExamined',
      'parasiteDetected',
      'detectionRemark',
    ]) {
      baseRecord['parasiteDetection::$col'] = '';
    }
    for (final col in const [
      'specimenUuid',
      'speciesID',
      'identifierID',
      'parasiteID',
      'parasiteUuid',
      'count',
      'preparationMethod',
      'storage',
      'storageLocation',
      'treatment',
      'anatomicalLocation',
      'lifeStage',
      'category',
      'associationStatus',
      'detectionMethod',
      'dateCollected',
      'timeCollected',
      'datePreserved',
      'timePreserved',
      'museumPermanent',
      'museumLoan',
      'remark',
      'scientificName',
    ]) {
      baseRecord['parasite::$col'] = '';
    }

    await _getSpecimenData(data, baseRecord);
    await _addCustomFieldData(
      CustomFieldOwner.specimen(data.uuid),
      'customSpecimen',
      baseRecord,
    );
    await _getProjectData(data.projectUuid, baseRecord);
    await _getCollEventData(data.collEventID, baseRecord);
    await _getCoordinateData(data.coordinateID, baseRecord);
    await _getAttributeData(data.uuid, baseRecord);

    final List<Map<String, dynamic>> parts = await _getPartData(data.uuid);
    final parasites = await _getParasiteData(data.uuid);

    switch (expansion) {
      case MultiEntryExpansion.concatenate:
        _addCombinedData(baseRecord, 'specimenPart', parts);
        _addCombinedData(baseRecord, 'parasite', parasites);
        return [baseRecord];
      case MultiEntryExpansion.specimenParts:
        _addCombinedData(baseRecord, 'parasite', parasites);
        if (parts.isEmpty) return [baseRecord];
        return [
          for (final part in parts)
            Map<String, String>.from(baseRecord)
              ..addAll(_namespacedData('specimenPart', part)),
        ];
      case MultiEntryExpansion.parasites:
        _addCombinedData(baseRecord, 'specimenPart', parts);
        if (parasites.isEmpty) return [baseRecord];
        return [
          for (final parasite in parasites)
            Map<String, String>.from(baseRecord)
              ..addAll(_namespacedData('parasite', parasite)),
        ];
    }
  }

  Future<void> _getSpecimenData(
    SpecimenData data,
    Map<String, String> record,
  ) async {
    _addData(record, 'specimen', data.toJson());
    if (data.catalogerID != null) {
      final p = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(data.catalogerID!);
      record['specimen::catalogerID'] = p.name ?? '';
      _addData(record, 'personnel', p.toJson());
    }
    if (data.preparatorID != null) {
      final p = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(data.preparatorID!);
      record['specimen::preparatorID'] = p.name ?? '';
    }
    if (data.determinerID != null) {
      final p = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(data.determinerID!);
      record['specimen::determiner'] = p.name ?? '';
      record['specimen::determinerID'] = canonicalOrcidUrl(p.orcid) ?? p.uuid;
    }
    if (data.speciesID != null) {
      final tax = await TaxonomyServices(
        ref: ref,
      ).getTaxonById(data.speciesID!);
      record['specimen::speciesID'] = tax.id.toString();
      record['specimen::scientificName'] = getTaxonDisplayName(tax);
      _addData(record, 'taxonomy', tax.toJson());
    }
  }

  Future<void> _getProjectData(
    String? projectUuid,
    Map<String, String> record,
  ) async {
    if (projectUuid != null) {
      final proj = await ProjectServices(
        ref: ref,
      ).getProjectByUuid(projectUuid);
      _addData(record, 'project', proj.toJson());
    }
  }

  Future<void> _getCollEventData(
    int? collEventID,
    Map<String, String> record,
  ) async {
    // Pre-populate collEffort keys to avoid unresolved placeholders
    final effortColumns = [
      'id',
      'eventID',
      'method',
      'brand',
      'count',
      'size',
      'notes',
    ];
    for (var col in effortColumns) {
      record['collEffort::$col'] = '';
    }

    if (collEventID != null) {
      final event = await CollEventServices(ref: ref).getCollEvent(collEventID);
      if (event != null) {
        _addData(record, 'collEvent', event.toJson());
        _addData(record, 'event', event.toJson());

        final formattedEventID = await CollEventServices(
          ref: ref,
        ).getCollEventID(event);
        record['collEvent::collEventID'] = formattedEventID;
        record['collEvent::collEventId'] = formattedEventID;
        record['event::collEventID'] = formattedEventID;
        record['event::collEventId'] = formattedEventID;

        final methods = await _getEventEffort(event.id);
        final personnel = await _getEventPersonnel(event.id);
        record['collEvent::methods'] = methods;
        record['event::methods'] = methods;
        record['collEvent::personnel'] = personnel;
        record['event::personnel'] = personnel;
        record['collEvent::Activity'] = event.primaryCollMethod ?? '';
        record['event::Activity'] = event.primaryCollMethod ?? '';

        final efforts = await CollEventServices(
          ref: ref,
        ).getAllCollEffort(event.id);
        if (efforts.isNotEmpty) {
          final Set<String> effortKeys = {};
          final List<Map<String, dynamic>> effortJsons = efforts
              .map((e) => e.toJson())
              .toList();
          for (var effortJson in effortJsons) {
            effortKeys.addAll(effortJson.keys);
          }
          for (var key in effortKeys) {
            final combined = effortJsons
                .map((e) => e[key]?.toString() ?? '')
                .join(writerSeparator);
            record['collEffort::$key'] = combined;
          }
        }

        if (event.siteID != null) {
          final site = await SiteServices(ref: ref).getSite(event.siteID!);
          if (site != null) {
            _addData(record, 'site', site.site.toJson());
            // Geography is a shared record now, so it gets its own namespace.
            _addData(record, 'geography', site.draft.toJson());
            final siteAttribute = await SiteServices(
              ref: ref,
            ).getSiteAttribute(site.id);
            if (siteAttribute != null) {
              _addData(record, 'siteAttribute', siteAttribute.toJson());
            }
            final fossilSite = await FossilSiteServices(
              ref: ref,
            ).getFossilSite(site.id);
            if (fossilSite != null) {
              _addData(record, 'fossilSite', fossilSite.toJson());
            }
            await _addCustomFieldData(
              CustomFieldOwner.site(site.id),
              'customSite',
              record,
            );
          }
        }

        try {
          final environment = await CollEventServices(
            ref: ref,
          ).getAllEnvironmentData(collEventID);
          _addData(record, 'environment', environment.toJson());
        } catch (_) {
          // No environmental data found.
        }
        await _addCustomFieldData(
          CustomFieldOwner.environment(event.id),
          'customEnvironment',
          record,
        );
      }
    }
  }

  Future<String> _getEventEffort(int id) async {
    List<CollEffortData> effort = await CollEventServices(
      ref: ref,
    ).getAllCollEffort(id);
    return effort.map((e) => '"${e.method}";${e.count}').join(writerSeparator);
  }

  Future<String> _getEventPersonnel(int id) async {
    List<CollPersonnelData> personnel = await CollEventServices(
      ref: ref,
    ).getAllCollPersonnel(id);

    String person = await Future.wait(
      personnel.map((e) async {
        if (e.personnelId == null) return '';
        final p = await PersonnelServices(
          ref: ref,
        ).getPersonnelByUuid(e.personnelId!);
        return '${p.name};${e.role}';
      }),
    ).then((value) => value.where((v) => v.isNotEmpty).join(writerSeparator));

    return person;
  }

  Future<void> _getCoordinateData(
    int? coordinateID,
    Map<String, String> record,
  ) async {
    if (coordinateID != null) {
      final coord = await CoordinateServices(
        ref: ref,
      ).getCoordinateById(coordinateID);
      if (coord != null) {
        _addData(record, 'coordinate', coord.toJson());
      }
    }
    final uncertainty = double.tryParse(
      record['coordinate::uncertaintyInMeters'] ?? '',
    );
    final extent = double.tryParse(
      record['specimen::coordinateExtentMeters'] ?? '',
    );
    final combined = positiveCoordinateUncertainty(uncertainty, extent);
    record['coordinate::uncertaintyInMeters'] = combined?.toString() ?? '';
  }

  Future<void> _getAttributeData(
    String specimenUuid,
    Map<String, String> record,
  ) async {
    final db = ref.read(databaseProvider);
    final mammal = await (db.select(
      db.mammalAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).getSingleOrNull();
    if (mammal != null) {
      _addData(record, 'mammalAttribute', mammal.toJson());
    }

    final bird = await (db.select(
      db.birdAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).getSingleOrNull();
    if (bird != null) {
      _addData(record, 'birdAttribute', bird.toJson());
    }

    final herp = await (db.select(
      db.herpAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).getSingleOrNull();
    if (herp != null) {
      _addData(record, 'herpAttribute', herp.toJson());
    }
    final arthropod = await (db.select(
      db.arthropodAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).getSingleOrNull();
    if (arthropod != null) {
      _addData(record, 'arthropodAttribute', arthropod.toJson());
    }
    final fossil = await (db.select(
      db.fossilAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).getSingleOrNull();
    if (fossil != null) {
      _addData(record, 'fossilAttribute', fossil.toJson());
    }
    final detection = await (db.select(
      db.parasiteDetection,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).getSingleOrNull();
    if (detection != null) {
      final json = detection.toJson();
      for (final field in ['parasiteExamined', 'parasiteDetected']) {
        json[field] = switch (json[field]) {
          1 => 'Yes',
          0 => 'No',
          _ => '',
        };
      }
      _addData(record, 'parasiteDetection', json);
    }
  }

  Future<List<Map<String, dynamic>>> _getPartData(String specimenUuid) async {
    final db = ref.read(databaseProvider);
    final parts = await (db.select(
      db.specimenPart,
    )..where((t) => t.specimenUuid.equals(specimenUuid))).get();
    return Future.wait(
      parts.map((part) async {
        final json = part.toJson();
        if (part.id != null) {
          json.addAll(
            await _customFieldData(
              CustomFieldOwner.specimenPart(part.id!),
              'customSpecimenPart',
            ),
          );
        }
        return json;
      }),
    );
  }

  Future<List<Map<String, dynamic>>> _getParasiteData(
    String specimenUuid,
  ) async {
    final db = ref.read(databaseProvider);
    final records = await (db.select(
      db.parasite,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).get();
    return Future.wait(
      records.map((record) async {
        final json = record.toJson()..remove('id');
        if (record.id != null) {
          json.addAll(
            await _customFieldData(
              CustomFieldOwner.parasite(record.id!),
              'customParasite',
            ),
          );
        }
        json['associationStatus'] =
            parasiteAssociationStatuses[record.associationStatus] ?? '';
        if (record.speciesID != null) {
          final taxon = await TaxonomyServices(
            ref: ref,
          ).getTaxonById(record.speciesID!);
          json['scientificName'] = getTaxonDisplayName(taxon);
        }
        if (record.identifierID != null) {
          final identifier = await PersonnelServices(
            ref: ref,
          ).getPersonnelByUuid(record.identifierID!);
          json['identifierID'] = identifier.name;
        }
        return json;
      }),
    );
  }

  void _addCombinedData(
    Map<String, String> record,
    String table,
    List<Map<String, dynamic>> rows,
  ) {
    final keys = rows.expand((row) => row.keys).toSet();
    for (final key in keys) {
      record[_exportKey(table, key)] = rows
          .map((row) => row[key]?.toString() ?? '')
          .join(writerSeparator);
    }
  }

  Map<String, String> _namespacedData(String table, Map<String, dynamic> data) {
    return {
      for (final entry in data.entries)
        _exportKey(table, entry.key): entry.value?.toString() ?? '',
    };
  }

  String _exportKey(String table, String key) =>
      key.startsWith('custom') && key.contains('::') ? key : '$table::$key';

  Future<Map<String, String>> _customFieldData(
    CustomFieldOwner owner,
    String namespace,
  ) async {
    final entries = await CustomFieldService(
      ref.read(databaseProvider),
    ).getExportEntries(owner);
    return {
      for (final entry in entries)
        '$namespace::${entry.definition.uuid}': entry.value == null
            ? ''
            : entry.definition.displayValue(entry.value!.value),
    };
  }

  Future<void> _addCustomFieldData(
    CustomFieldOwner owner,
    String namespace,
    Map<String, String> record,
  ) async {
    record.addAll(await _customFieldData(owner, namespace));
  }

  void _addData(
    Map<String, String> record,
    String table,
    Map<String, dynamic> json,
  ) {
    for (var entry in json.entries) {
      record['$table::${entry.key}'] = entry.value?.toString() ?? '';
    }
  }
}
