import 'dart:convert';

const int recordExchangeVersion = 3;
const Set<int> supportedRecordExchangeVersions = {1, 2, 3};

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

  int get effortCount => mapList(data['effort']).length;

  int get assignmentCount => mapList(data['personnelAssignments']).length;

  int get personnelCount => mapList(data['personnel']).length;

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
      data: Map<String, dynamic>.from(rawData),
    )..validate();
  }

  void validate() {
    if (data[typeName] is! Map) {
      throw FormatException('NAHPU $typeName data is missing.');
    }
    mapList(data['personnel']);
    mapList(data['coordinates']);
    if (type == RecordExchangeType.site) {
      mapList(data['associatedData']);
      _validateCustomFields(data['customFields']);
      return;
    }

    if (type == RecordExchangeType.event) {
      mapList(data['effort']);
      mapList(data['personnelAssignments']);
      mapList(data['associatedData']);
      final weather = data['weather'];
      if (weather != null && weather is! Map) {
        throw const FormatException('Event weather data is invalid.');
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
        mapList(linked['coordinates']);
        _validateCustomFields(linked['customFields']);
      }
      final media = data['media'];
      if (media != null) mapList(media);
      return;
    }

    mapList(data['parts']);
    mapList(data['parasites']);
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
