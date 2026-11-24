import 'dart:convert';

/// Version written for payloads that carry every related record in full.
///
/// Kept at 8 so older NAHPU versions can still read full payloads.
const int recordExchangeVersion = 8;

/// Version written when a payload refers to personnel or a site by
/// `personnelRefs` or `siteRef` instead of carrying them. Older versions
/// would silently drop those keys, so they must reject the payload.
const int recordExchangeReferenceVersion = 9;

const Set<int> supportedRecordExchangeVersions = {1, 2, 3, 4, 5, 6, 7, 8, 9};

enum RecordExchangeType { site, event, specimen }

enum RecordArchiveFormat { zip, tarGzip }

extension RecordExchangeTypeLabel on RecordExchangeType {
  String get wireName => switch (this) {
    RecordExchangeType.site => 'site',
    RecordExchangeType.event => 'event',
    RecordExchangeType.specimen => 'specimen',
  };

  String get label => switch (this) {
    RecordExchangeType.site => 'site',
    RecordExchangeType.event => 'event',
    RecordExchangeType.specimen => 'specimen',
  };
}

extension RecordArchiveFormatLabel on RecordArchiveFormat {
  String get label => switch (this) {
    RecordArchiveFormat.zip => 'ZIP',
    RecordArchiveFormat.tarGzip => 'TAR.GZ',
  };

  String get extension => switch (this) {
    RecordArchiveFormat.zip => 'zip',
    RecordArchiveFormat.tarGzip => 'tar.gz',
  };
}

class RecordExchangePayload {
  const RecordExchangePayload({
    required this.type,
    required this.data,
    this.version = recordExchangeVersion,
    this.mediaFiles = const [],
  });

  final RecordExchangeType type;
  final int version;
  final Map<String, dynamic> data;
  final List<RecordExchangeMediaFile> mediaFiles;

  String get typeName => type.wireName;

  String get encoded => const JsonEncoder.withIndent('  ').convert(toJson());

  String get compactEncoded => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
    'nahpu_record': typeName,
    'version': version,
    'data': data,
  };

  String get displayName {
    final record = data[typeName];
    if (record is Map && type == RecordExchangeType.site) {
      final siteId = record['siteID'];
      if (siteId is String && siteId.trim().isNotEmpty) return siteId;
    }
    if (record is Map && type == RecordExchangeType.event) {
      final suffix = record['idSuffix'];
      if (suffix is String && suffix.trim().isNotEmpty) {
        return 'Event $suffix';
      }
    }
    if (record is Map && type == RecordExchangeType.specimen) {
      final fieldNumber = record['fieldNumber'];
      if (fieldNumber != null) return 'Specimen $fieldNumber';
    }
    return '${type.label} record';
  }

  int get coordinateCount => mapList(data['coordinates']).length;

  int get collMethodCount => mapList(data['effort']).length;

  int get assignmentCount => mapList(data['personnelAssignments']).length;

  int get personnelCount =>
      mapList(data['personnel']).length + personnelRefs.length;

  /// Personnel the payload names without carrying their details. The receiving
  /// device must already have each of them.
  List<Map<String, dynamic>> get personnelRefs =>
      mapList(data['personnelRefs']);

  /// The site an event names by project and site code instead of carrying it.
  Map<String, dynamic>? get siteRef {
    final value = data['siteRef'];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  bool get usesReferences => personnelRefs.isNotEmpty || siteRef != null;

  /// Whether the personnel details can be swapped for references.
  bool get canReferencePersonnel => mapList(data['personnel']).isNotEmpty;

  /// Whether the embedded site can be swapped for a reference: it needs a
  /// site code for the receiving device to match.
  bool get canReferenceSite => _embeddedSiteCode != null;

  String? get _embeddedSiteCode {
    final linked = data['site'];
    if (type != RecordExchangeType.event || linked is! Map) return null;
    final site = linked['site'];
    if (site is! Map) return null;
    final code = site['siteID'];
    return code is String && code.trim().isNotEmpty ? code.trim() : null;
  }

  /// A smaller copy that names personnel and the linked site instead of
  /// carrying them, so it fits in a QR code once those records are shared.
  ///
  /// [projectUuid] is the project the linked site belongs to. Returns this
  /// payload unchanged when nothing is left out.
  RecordExchangePayload withReferences({
    required bool includePersonnelDetails,
    required bool includeSiteDetails,
    required String projectUuid,
  }) {
    final referencePersonnel =
        !includePersonnelDetails && canReferencePersonnel;
    final referenceSite = !includeSiteDetails && canReferenceSite;
    if (!referencePersonnel && !referenceSite) return this;
    final reduced = Map<String, dynamic>.from(data);
    if (referenceSite) {
      reduced.remove('site');
      reduced['siteRef'] = {
        'projectUuid': projectUuid,
        'siteID': _embeddedSiteCode,
      };
    }
    if (referencePersonnel) {
      reduced['personnelRefs'] = [
        ...personnelRefs,
        for (final person in mapList(data['personnel']))
          {
            'uuid': person['uuid'],
            'name': person['name'],
            'initial': person['initial'],
          },
      ];
      reduced.remove('personnel');
    }
    return RecordExchangePayload(
      type: type,
      version: recordExchangeReferenceVersion,
      data: reduced,
      mediaFiles: mediaFiles,
    );
  }

  int get partCount => mapList(data['parts']).length;

  int get associatedDataCount => mapList(data['associatedData']).length;

  int get mediaCount => mapList(data['media']).length;

  bool get hasLinkedSite =>
      type == RecordExchangeType.event && data['site'] is Map;

  bool get hasMedia => mediaCount > 0;

  static RecordExchangePayload parse(String content, {String? expectedType}) {
    final decoded = jsonDecode(content);
    if (decoded is! Map) {
      throw const FormatException('NAHPU record JSON must be an object.');
    }
    final envelope = Map<String, dynamic>.from(decoded);
    final name = envelope['nahpu_record'];
    final version = envelope['version'];
    final rawData = envelope['data'];
    if (name is! String || version is! num || rawData is! Map) {
      throw const FormatException('Invalid NAHPU record JSON envelope.');
    }
    if (!supportedRecordExchangeVersions.contains(version.toInt())) {
      throw const FormatException('Unsupported NAHPU record JSON version.');
    }
    final type = RecordExchangeType.values.where(
      (value) => value.wireName == name,
    );
    if (type.isEmpty) {
      throw const FormatException('Unsupported NAHPU record type.');
    }
    if (expectedType != null && name != expectedType) {
      throw FormatException('This JSON contains a $name, not a $expectedType.');
    }
    return RecordExchangePayload(
      type: type.first,
      version: version.toInt(),
      data: _renameLegacySymbionts(rawData) as Map<String, dynamic>,
    )..validate();
  }

  /// Keys written before v26 named symbionts for parasites, keyed by their
  /// legacy name. Each is unique to symbionts, so any depth is safe.
  static const Map<String, String> _legacySymbiontKeys = {
    'parasites': 'symbionts',
    'parasiteDetection': 'symbiontDetection',
    'parasiteIndividuals': 'symbiontIndividuals',
    'parasiteTaxonomy': 'symbiontTaxonomy',
    'sourceParasiteId': 'sourceSymbiontId',
    'parasiteID': 'symbiontID',
    'parasiteUuid': 'symbiontUuid',
    'parasiteExamined': 'symbiontExamined',
    'parasiteDetected': 'symbiontDetected',
    'parasiteId': 'symbiontId',
  };

  static Object? _renameLegacySymbionts(Object? value) {
    if (value is List) return value.map(_renameLegacySymbionts).toList();
    if (value is! Map) return value;
    return <String, dynamic>{
      for (final MapEntry(:key, :value) in value.entries)
        _legacySymbiontKeys[key] ??
            key as String: key == 'uiSection' && value == 'parasite'
            ? 'symbiont'
            : _renameLegacySymbionts(value),
    };
  }

  void validate() {
    if (data[typeName] is! Map) {
      throw FormatException('NAHPU $typeName data is missing.');
    }
    mapList(data['personnel']);
    for (final ref in personnelRefs) {
      final uuid = ref['uuid'];
      if (uuid is! String || uuid.isEmpty) {
        throw const FormatException('A personnel reference has no ID.');
      }
    }
    mapList(data['coordinates']);
    if (type == RecordExchangeType.site) {
      final attribute = data['siteAttribute'];
      if (attribute != null && attribute is! Map) {
        throw const FormatException('Site attribute data is invalid.');
      }
      mapList(data['associatedData']);
      _validateCustomFields(data['customFields']);
      return;
    }

    if (type == RecordExchangeType.event) {
      mapList(data['effort']);
      mapList(data['personnelAssignments']);
      mapList(data['associatedData']);
      final environment = data['environment'] ?? data['weather'];
      if (environment != null && environment is! Map) {
        throw const FormatException('Event environmental data is invalid.');
      }
      _validateCustomFields(data['customFields']);
      final siteRef = data['siteRef'];
      if (siteRef != null) {
        final code = siteRef is Map ? siteRef['siteID'] : null;
        if (code is! String || code.trim().isEmpty) {
          throw const FormatException('Event site reference is invalid.');
        }
      }
      final site = data['site'];
      if (site != null && site is! Map) {
        throw const FormatException('Event linked site data is invalid.');
      }
      if (site is Map) {
        final linked = Map<String, dynamic>.from(site);
        if (linked['site'] is! Map) {
          throw const FormatException('Event linked site data is missing.');
        }
        final attribute = linked['siteAttribute'];
        if (attribute != null && attribute is! Map) {
          throw const FormatException(
            'Event linked site attributes are invalid.',
          );
        }
        mapList(linked['coordinates']);
        _validateCustomFields(linked['customFields']);
      }
      final media = data['media'];
      if (media != null) mapList(media);
      return;
    }

    mapList(data['parts']);
    mapList(data['symbionts']);
    mapList(data['associatedData']);
    final measurements = data['measurements'];
    if (measurements != null && measurements is! Map) {
      throw const FormatException('Specimen measurements data is invalid.');
    }
    final taxonomy = data['taxonomy'];
    if (taxonomy != null && taxonomy is! Map) {
      throw const FormatException('Specimen taxonomy data is invalid.');
    }
    final event = data['event'];
    if (event != null && event is! Map) {
      throw const FormatException('Specimen event data is invalid.');
    }
    final media = data['media'];
    if (media != null) mapList(media);
    _validateCustomFields(data['customFields']);
  }

  static void _validateCustomFields(Object? value) {
    if (value == null) return;
    if (value is! Map) {
      throw const FormatException('Custom field data is invalid.');
    }
    mapList(value['definitions']);
    mapList(value['values']);
  }

  static List<Map<String, dynamic>> mapList(dynamic value) {
    if (value == null) return const [];
    if (value is! List) {
      throw const FormatException('NAHPU associated data must be a list.');
    }
    return value.map((entry) {
      if (entry is! Map) {
        throw const FormatException('NAHPU associated data is invalid.');
      }
      return Map<String, dynamic>.from(entry);
    }).toList();
  }
}

class RecordExchangeMediaFile {
  const RecordExchangeMediaFile({
    required this.sourcePath,
    required this.archivePath,
  });

  final String sourcePath;
  final String archivePath;
}

class RecordExchangeResult {
  const RecordExchangeResult({
    int? recordId,
    this.recordUuid,
    this.createdSiteId,
    this.createdEventId,
    this.createdTaxonId,
  }) : recordId = recordId ?? -1;

  final int recordId;
  final String? recordUuid;
  final int? createdSiteId;
  final int? createdEventId;
  final int? createdTaxonId;
}

class SpecimenImportReferences {
  const SpecimenImportReferences({
    this.eventId,
    this.siteId,
    this.taxonomyId,
    this.createEmbeddedEvent = false,
    this.createEmbeddedSite = false,
    this.createEmbeddedTaxonomy = false,
  });

  final int? eventId;
  final int? siteId;
  final int? taxonomyId;
  final bool createEmbeddedEvent;
  final bool createEmbeddedSite;
  final bool createEmbeddedTaxonomy;
}

/// A person a payload points to who is neither in it nor on this device.
class MissingPersonnelReference {
  const MissingPersonnelReference({
    required this.uuid,
    this.name,
    this.initial,
  });

  final String uuid;
  final String? name;
  final String? initial;

  /// The name with initials when known, or the ID.
  String get label {
    final name = this.name;
    if (name == null || name.isEmpty) return initial ?? uuid;
    return initial == null || initial!.isEmpty ? name : '$name ($initial)';
  }
}

enum SiteReferenceStatus {
  /// The reference names a project other than the open one.
  otherProject,

  /// No site in the open project has the referenced site code.
  missing,

  /// Exactly one site matches.
  match,

  /// Several sites share the code; the user picks one.
  ambiguous,
}

/// What a payload points to that must already be on this device.
class RecordReferenceCheck {
  const RecordReferenceCheck({
    this.missingPersonnel = const [],
    this.siteCode,
    this.siteStatus,
    this.siteMatchIds = const [],
  });

  final List<MissingPersonnelReference> missingPersonnel;

  /// The site code of an event's `siteRef`, if it has one.
  final String? siteCode;
  final SiteReferenceStatus? siteStatus;
  final List<int> siteMatchIds;

  bool get siteBlocks =>
      siteStatus == SiteReferenceStatus.otherProject ||
      siteStatus == SiteReferenceStatus.missing;

  /// Whether importing would leave a record pointing to a missing one.
  bool get blocksImport => missingPersonnel.isNotEmpty || siteBlocks;

  int? get matchedSiteId =>
      siteStatus == SiteReferenceStatus.match ? siteMatchIds.single : null;
}
