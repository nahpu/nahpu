import 'package:drift/drift.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:uuid/uuid.dart';

/// Portable custom-field definitions and values for record exchange payloads.
class RecordExchangeCustomFields extends AppServices {
  const RecordExchangeCustomFields({required super.ref});

  Future<Map<String, dynamic>> export({
    int? siteId,
    String? specimenUuid,
    List<int> specimenPartIds = const [],
    List<int> parasiteIds = const [],
  }) async {
    final ownerClauses = <String>[];
    final ownerValues = <Object?>[];
    if (siteId != null) {
      ownerClauses.add('siteId = ?');
      ownerValues.add(siteId);
    }
    if (specimenUuid != null) {
      ownerClauses.add('specimenUuid = ?');
      ownerValues.add(specimenUuid);
    }
    if (specimenPartIds.isNotEmpty) {
      ownerClauses.add(
        'specimenPartId IN (${List.filled(specimenPartIds.length, '?').join(',')})',
      );
      ownerValues.addAll(specimenPartIds);
    }
    if (parasiteIds.isNotEmpty) {
      ownerClauses.add(
        'parasiteId IN (${List.filled(parasiteIds.length, '?').join(',')})',
      );
      ownerValues.addAll(parasiteIds);
    }

    final placements = <String>{
      if (siteId != null) 'siteAttribute',
      if (specimenUuid != null) 'specimenAttribute',
      if (specimenPartIds.isNotEmpty) 'specimenPart',
      if (parasiteIds.isNotEmpty) 'parasite',
    };
    if (placements.isEmpty) {
      return const {'definitions': [], 'values': []};
    }
    String? catalogFormat;
    if (specimenUuid != null) {
      final specimen = await _query(
        'SELECT taxonGroup FROM specimen WHERE uuid = ? LIMIT 1',
        [specimenUuid],
      );
      catalogFormat = specimen.isEmpty
          ? null
          : _catalogFormat(specimen.single['taxonGroup'] as String?);
    }
    final placementValues = placements.toList(growable: false);
    final definitions = await _query(
      'SELECT * FROM customFieldDefinition WHERE uiSection IN '
      '(${List.filled(placementValues.length, '?').join(',')}) '
      'AND (scope = ? OR projectUuid = ?) '
      'AND (uiSection = ? OR catalogFormat IS NULL OR catalogFormat = ?) '
      'ORDER BY uiSection, scope, sortOrder',
      [
        ...placementValues,
        'global',
        currentProjectUuid,
        'siteAttribute',
        catalogFormat,
      ],
    );
    final definitionIds = definitions
        .map((row) => row['id'])
        .whereType<int>()
        .toSet();
    final values = ownerClauses.isEmpty
        ? <Map<String, dynamic>>[]
        : (await _query(
                'SELECT * FROM customFieldValue WHERE isLegacy = 0 AND '
                '(${ownerClauses.join(' OR ')})',
                ownerValues,
              ))
              .where((row) => definitionIds.contains(row['fieldDefinitionId']))
              .toList(growable: false);
    return {
      'definitions': definitions
          .map((row) => {...row, 'sourceDefinitionId': row['id']}..remove('id'))
          .toList(growable: false),
      'values': values
          .map(
            (row) => {...row, 'sourceDefinitionId': row['fieldDefinitionId']}
              ..remove('id')
              ..remove('fieldDefinitionId')
              ..remove('projectUuid'),
          )
          .toList(growable: false),
    };
  }

  Future<void> import(
    Object? raw, {
    int? siteId,
    String? specimenUuid,
    Map<int, int> specimenPartIds = const {},
    Map<int, int> parasiteIds = const {},
  }) async {
    if (raw is! Map) return;
    final data = Map<String, dynamic>.from(raw);
    final definitions = _mapList(data['definitions']);
    final values = _mapList(data['values']);
    final definitionMap = <int, int>{};
    for (final source in definitions) {
      final sourceId = source['sourceDefinitionId'] as int?;
      final sourceUuid = source['uuid'] as String?;
      if (sourceId == null || sourceUuid == null) continue;
      final uuidMatches = await _query(
        'SELECT * FROM customFieldDefinition WHERE uuid = ? LIMIT 1',
        [sourceUuid],
      );
      if (uuidMatches.isNotEmpty &&
          _sameConfiguration(uuidMatches.single, source)) {
        definitionMap[sourceId] = uuidMatches.single['id'] as int;
        continue;
      }
      if (source['scope'] == 'global') {
        final globals = await _query(
          'SELECT * FROM customFieldDefinition WHERE scope = ? '
          'AND lower(name) = lower(?) AND uiSection = ?',
          ['global', source['name'], source['uiSection']],
        );
        final identical = globals
            .where((row) => _sameConfiguration(row, source))
            .firstOrNull;
        if (identical != null) {
          definitionMap[sourceId] = identical['id'] as int;
          continue;
        }
      }
      final target = Map<String, dynamic>.from(source)
        ..remove('sourceDefinitionId')
        ..['uuid'] = uuidMatches.isEmpty ? sourceUuid : const Uuid().v4()
        ..['scope'] = 'project'
        ..['projectUuid'] = currentProjectUuid
        ..['name'] = await _uniqueName(
          source['name'] as String? ?? 'Imported field',
          source['uiSection'] as String? ?? 'specimenAttribute',
        );
      final templateUuid = target['sourceTemplateUuid'] as String?;
      if (templateUuid != null &&
          (await _query(
            'SELECT 1 FROM customFieldDefinition WHERE sourceTemplateUuid = ? '
            'AND scope = ? AND projectUuid = ? LIMIT 1',
            [templateUuid, 'project', currentProjectUuid],
          )).isNotEmpty) {
        target['sourceTemplateUuid'] = null;
      }
      definitionMap[sourceId] = await _insertDefinition(target);
    }

    for (final source in values) {
      final definitionId = definitionMap[source['sourceDefinitionId'] as int?];
      if (definitionId == null) continue;
      final targetSiteId = source['siteId'] == null ? null : siteId;
      final targetSpecimenUuid = source['specimenUuid'] == null
          ? null
          : specimenUuid;
      final targetPartId = specimenPartIds[source['specimenPartId'] as int?];
      final targetParasiteId = parasiteIds[source['parasiteId'] as int?];
      if (targetSiteId == null &&
          targetSpecimenUuid == null &&
          targetPartId == null &&
          targetParasiteId == null) {
        continue;
      }
      await dbAccess.customStatement(
        'DELETE FROM customFieldValue WHERE fieldDefinitionId = ? '
        'AND siteId IS ? AND specimenUuid IS ? '
        'AND specimenPartId IS ? AND parasiteId IS ?',
        [
          definitionId,
          targetSiteId,
          targetSpecimenUuid,
          targetPartId,
          targetParasiteId,
        ],
      );
      await dbAccess.customStatement(
        'INSERT INTO customFieldValue '
        '(fieldDefinitionId, projectUuid, value, unit, siteId, specimenUuid, '
        'specimenPartId, parasiteId, isLegacy) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)',
        [
          definitionId,
          currentProjectUuid,
          source['value'],
          source['unit'],
          targetSiteId,
          targetSpecimenUuid,
          targetPartId,
          targetParasiteId,
        ],
      );
    }
  }

  Future<int> _insertDefinition(Map<String, dynamic> row) async {
    final columns = row.keys.toList(growable: false);
    await dbAccess.customStatement(
      'INSERT INTO customFieldDefinition (${columns.join(',')}) VALUES '
      '(${List.filled(columns.length, '?').join(',')})',
      columns.map((column) => row[column]).toList(growable: false),
    );
    return (await _query('SELECT last_insert_rowid() AS id')).single['id']
        as int;
  }

  Future<String> _uniqueName(String source, String placement) async {
    final base = source.trim().isEmpty ? 'Imported field' : source.trim();
    var candidate = base;
    var suffix = 2;
    while ((await _query(
      'SELECT 1 FROM customFieldDefinition WHERE uiSection = ? '
      'AND lower(name) = lower(?) AND '
      '(scope = ? OR projectUuid = ?) LIMIT 1',
      [placement, candidate, 'global', currentProjectUuid],
    )).isNotEmpty) {
      candidate = '$base (imported $suffix)';
      suffix++;
    }
    return candidate;
  }

  bool _sameConfiguration(
    Map<String, dynamic> current,
    Map<String, dynamic> imported,
  ) {
    const keys = [
      'name',
      'type',
      'uiSection',
      'options',
      'catalogFormat',
      'sortOrder',
      'isArchived',
      'dwcTarget',
      'dwcField',
      'dwcMode',
      'allowDwcConflict',
    ];
    return keys.every((key) => current[key] == imported[key]);
  }

  Future<List<Map<String, dynamic>>> _query(
    String sql, [
    List<Object?> values = const [],
  ]) async {
    final rows = await dbAccess
        .customSelect(
          sql,
          variables: values.map(_variable).toList(growable: false),
        )
        .get();
    return rows
        .map((row) => Map<String, dynamic>.from(row.data))
        .toList(growable: false);
  }

  Variable _variable(Object? value) => switch (value) {
    int value => Variable.withInt(value),
    double value => Variable.withReal(value),
    String value => Variable.withString(value),
    bool value => Variable.withBool(value),
    _ => Variable<Object>(value),
  };

  List<Map<String, dynamic>> _mapList(Object? value) {
    if (value == null) return const [];
    if (value is! List) {
      throw const FormatException('Custom field records must be a list.');
    }
    return value
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  String _catalogFormat(String? taxonGroup) {
    return switch (taxonGroup?.toLowerCase()) {
      'aves' || 'birds' => 'birds',
      'reptilia' || 'amphibia' || 'herpetofauna' => 'herpetofauna',
      'arthropoda' || 'arthropods' => 'arthropods',
      _ => 'mammals',
    };
  }
}
