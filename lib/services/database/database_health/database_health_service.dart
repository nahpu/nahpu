import 'dart:io';

import 'package:drift/drift.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/media_file_resolver.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart'
    show dataTableAttributeTableForGroup;
import 'package:nahpu/services/database/database_health/database_health_models.dart';
import 'package:nahpu/services/providers/record_providers.dart';
import 'package:path/path.dart' as p;

export 'database_health_models.dart';

/// Finds problems in the NAHPU database that users can fix in the app, and
/// applies the safe repairs.
///
/// The check covers the whole database file, every project included, because
/// a broken link in one project can stop another project's export.
class DatabaseHealthService extends AppServices {
  const DatabaseHealthService({required super.ref});

  /// Most integrity messages SQLite reports before the list stops helping.
  static const int maxIntegrityMessages = 20;

  /// Runs every check and reports what it found.
  Future<HealthReport> scan() async {
    final integrity = await _checkIntegrity();
    if (integrity.isNotEmpty) {
      // A damaged file makes the other checks unreliable.
      return HealthReport(issues: integrity, scannedAt: DateTime.now());
    }
    final issues = <HealthIssue>[
      ...await _checkForeignKeys(),
      ...await _checkCrossProjectLinks(),
      ...await _checkMedia(),
      ...await _checkPersonnelPhotos(),
      ...await _checkAttributeRecords(),
      ...await _checkFieldNumbers(),
    ];
    return HealthReport(issues: issues, scannedAt: DateTime.now());
  }

  /// Applies the fixes of [issues], taking a database copy first when
  /// [backup] is set.
  ///
  /// Each fix runs in its own transaction, so a fix SQLite refuses does not
  /// hold back the rest.
  Future<HealthFixResult> applyFixes(
    Iterable<HealthIssue> issues, {
    required bool backup,
  }) async {
    final fixable = issues.where((issue) => issue.fix != null).toList();
    if (fixable.isEmpty) {
      return const HealthFixResult(fixed: 0, failed: [], backup: null);
    }
    final backupFile = backup ? await writeSafetyBackup() : null;
    var fixed = 0;
    final failed = <HealthIssue>[];
    for (final issue in fixable) {
      try {
        await dbAccess.transaction(() => _applyFix(issue));
        fixed++;
      } catch (_) {
        failed.add(issue);
      }
    }
    invalidateProjectRecordProviders(ref, currentProjectUuid);
    return HealthFixResult(fixed: fixed, failed: failed, backup: backupFile);
  }

  /// Copies the database into the backup folder, where Replace database can
  /// restore it from.
  Future<File> writeSafetyBackup() async {
    final documentDir = await nahpuDocumentDir;
    final target = File(
      p.join(
        documentDir.path,
        nahpuBackupDir,
        'nahpu_before_check-$dateTimeStamp.sqlite3',
      ),
    );
    await dbAccess.exportInto(target);
    return target;
  }

  Future<List<HealthIssue>> _checkIntegrity() async {
    final rows = await _select('PRAGMA integrity_check');
    final messages = rows
        .map((row) => row.values.first?.toString() ?? '')
        .where((message) => message != 'ok')
        .take(maxIntegrityMessages);
    return [
      for (final message in messages)
        HealthIssue(
          kind: HealthIssueKind.databaseIntegrity,
          table: '',
          recordLabel: '',
          detail: message,
        ),
    ];
  }

  Future<List<HealthIssue>> _checkForeignKeys() async {
    final violations = await _select('PRAGMA foreign_key_check');
    final foreignKeys = <String, List<Map<String, dynamic>>>{};
    final columnInfo = <String, Map<String, Map<String, dynamic>>>{};
    final issues = <HealthIssue>[];
    for (final violation in violations) {
      final table = violation['table'] as String;
      final rowId = violation['rowid'] as int?;
      final parent = violation['parent'] as String;
      final fkId = violation['fkid'] as int;
      final keys = foreignKeys[table] ??= await _select(
        'PRAGMA foreign_key_list(${_quote(table)})',
      );
      final columns = keys
          .where((key) => key['id'] == fkId)
          .map((key) => key['from'] as String)
          .toList(growable: false);
      final info = columnInfo[table] ??= {
        for (final column in await _select(
          'PRAGMA table_info(${_quote(table)})',
        ))
          column['name'] as String: column,
      };
      final row = rowId == null ? null : await _rowByRowId(table, rowId);
      issues.add(
        HealthIssue(
          kind: HealthIssueKind.brokenLink,
          table: table,
          rowId: rowId,
          columns: columns,
          parentTable: parent,
          recordLabel: _recordLabel(table, row, rowId),
          fix: _linkFix(table, parent, columns, info, rowId),
          target: _targetFor(table, row, parent: parent),
        ),
      );
    }
    return issues;
  }

  /// Columns naming the record a row belongs to. A row whose owner is gone
  /// means nothing on its own, so the fix deletes it instead of clearing the
  /// link.
  static const Map<String, Set<String>> ownerColumns = {
    'siteAttribute': {'siteID'},
    'fossilSite': {'siteID'},
    'coordinate': {'siteID'},
    'environment': {'eventID'},
    'collPersonnel': {'eventID'},
    'collMethod': {'eventID'},
    'siteMedia': {'siteId', 'mediaId'},
    'eventMedia': {'eventID', 'mediaId'},
    'narrativeMedia': {'narrativeId', 'mediaId'},
    'specimenMedia': {'specimenUuid', 'mediaId'},
    'specimenAssociatedData': {'specimenUuid', 'associatedDataId'},
    'siteAssociatedData': {'siteId', 'associatedDataId'},
    'eventAssociatedData': {'eventID', 'associatedDataId'},
    'personnelList': {'projectUuid', 'personnelUuid'},
    'mammalAttribute': {'specimenUuid'},
    'birdAttribute': {'specimenUuid'},
    'herpAttribute': {'specimenUuid'},
    'invertebrateAttribute': {'specimenUuid'},
    'fishAttribute': {'specimenUuid'},
    'fossilAttribute': {'specimenUuid'},
    'symbiontDetection': {'specimenUuid'},
    'symbiont': {'specimenUuid'},
    'specimenPart': {'specimenUuid'},
    'specimenIndividual': {'specimenUuid'},
    'specimenPartIndividual': {'partID', 'individualID'},
    'symbiontIndividual': {'symbiontID', 'individualID'},
    'customFieldDefinition': {'projectUuid'},
    'customFieldValue': {
      'fieldDefinitionId',
      'eventId',
      'siteId',
      'specimenUuid',
      'specimenPartId',
      'symbiontId',
    },
  };

  /// Deletes a row whose owner is gone, and otherwise clears the link when
  /// the column allows it. A record that lost its project gets no automatic
  /// fix: clearing the project would hide it from every project.
  HealthFixAction? _linkFix(
    String table,
    String parent,
    List<String> columns,
    Map<String, Map<String, dynamic>> info,
    int? rowId,
  ) {
    if (rowId == null || columns.isEmpty) return null;
    final owners = ownerColumns[table] ?? const {};
    if (columns.every(owners.contains)) return HealthFixAction.removeRow;
    if (parent == 'project') return null;
    final nullable = columns.every((column) {
      final details = info[column];
      return details != null && details['notnull'] == 0 && details['pk'] == 0;
    });
    return nullable ? HealthFixAction.clearLink : HealthFixAction.removeRow;
  }

  Future<List<HealthIssue>> _checkCrossProjectLinks() async {
    final issues = <HealthIssue>[];
    final specimens = await _select(
      'SELECT s.rowid AS rid, s.* FROM specimen s '
      'JOIN collEvent e ON e.id = s.collEventID '
      'WHERE s.projectUuid IS NOT e.projectUuid',
    );
    for (final row in specimens) {
      issues.add(
        HealthIssue(
          kind: HealthIssueKind.crossProjectLink,
          table: 'specimen',
          rowId: row['rid'] as int,
          columns: const ['collEventID'],
          parentTable: 'collEvent',
          recordLabel: _recordLabel('specimen', row, row['rid'] as int),
          fix: HealthFixAction.clearLink,
          target: _targetFor('specimen', row),
        ),
      );
    }
    final events = await _select(
      'SELECT e.rowid AS rid, e.* FROM collEvent e '
      'JOIN site st ON st.id = e.siteID '
      'WHERE e.projectUuid IS NOT st.projectUuid',
    );
    for (final row in events) {
      issues.add(
        HealthIssue(
          kind: HealthIssueKind.crossProjectLink,
          table: 'collEvent',
          rowId: row['rid'] as int,
          columns: const ['siteID'],
          parentTable: 'site',
          recordLabel: _recordLabel('collEvent', row, row['rid'] as int),
          fix: HealthFixAction.clearLink,
          target: _targetFor('collEvent', row),
        ),
      );
    }
    return issues;
  }

  Future<List<HealthIssue>> _checkMedia() async {
    final documentRoot = await nahpuDocumentDir;
    final rows = await _select('SELECT * FROM media');
    final issues = <HealthIssue>[];
    for (final row in rows) {
      final file = projectMediaFile(
        documentRoot,
        row,
        fallbackProjectUuid: currentProjectUuid,
      );
      if (file != null && await file.exists()) continue;
      final mediaId = row['primaryId'] as int;
      issues.add(
        HealthIssue(
          kind: HealthIssueKind.missingMedia,
          table: 'media',
          recordKey: mediaId,
          recordLabel: row['fileName'] as String? ?? '#$mediaId',
          fix: HealthFixAction.removeMissingMedia,
          target: await _mediaOwner(mediaId),
        ),
      );
    }
    return issues;
  }

  /// The first record showing the media, so the user can see what it was.
  Future<HealthRecordTarget?> _mediaOwner(int mediaId) async {
    const owners = [
      ('specimenMedia', 'specimenUuid', DataTableRecordType.specimenRecords),
      ('siteMedia', 'siteId', DataTableRecordType.sites),
      ('eventMedia', 'eventID', DataTableRecordType.events),
      ('narrativeMedia', 'narrativeId', DataTableRecordType.narrative),
    ];
    for (final (table, column, type) in owners) {
      final rows = await _select(
        'SELECT ${_quote(column)} AS ownerKey FROM ${_quote(table)} '
        'WHERE mediaId = ?',
        [mediaId],
      );
      final keys = rows
          .map((row) => row['ownerKey'])
          .whereType<Object>()
          .toSet();
      if (keys.isNotEmpty) return HealthRecordTarget(type: type, keys: keys);
    }
    return null;
  }

  Future<List<HealthIssue>> _checkPersonnelPhotos() async {
    final documentRoot = await nahpuDocumentDir;
    final rows = await _select(
      'SELECT uuid, name, photoPath FROM personnel WHERE photoPath IS NOT NULL',
    );
    final issues = <HealthIssue>[];
    for (final row in rows) {
      final photoPath = row['photoPath'] as String?;
      final file = personnelPhotoFile(documentRoot, photoPath);
      if (file == null || await file.exists()) continue;
      issues.add(
        HealthIssue(
          kind: HealthIssueKind.missingPersonnelPhoto,
          table: 'personnel',
          recordKey: row['uuid'] as String,
          recordLabel: row['name'] as String? ?? photoPath!,
          detail: photoPath,
          fix: HealthFixAction.clearPersonnelPhoto,
        ),
      );
    }
    return issues;
  }

  /// Every specimen with a taxon group keeps its measurements in that
  /// group's attribute table. Records made outside the app can lack the row.
  Future<List<HealthIssue>> _checkAttributeRecords() async {
    final specimens = await _select(
      'SELECT rowid AS rid, * FROM specimen WHERE taxonGroup IS NOT NULL',
    );
    final present = <String, Set<String>>{};
    final issues = <HealthIssue>[];
    for (final row in specimens) {
      final table = dataTableAttributeTableForGroup(
        row['taxonGroup'] as String,
      );
      final uuids = present[table] ??= (await _select(
        'SELECT DISTINCT specimenUuid FROM ${_quote(table)}',
      )).map((r) => r['specimenUuid']).whereType<String>().toSet();
      final uuid = row['uuid'] as String;
      if (uuids.contains(uuid)) continue;
      issues.add(
        HealthIssue(
          kind: HealthIssueKind.missingAttributeRecord,
          table: 'specimen',
          rowId: row['rid'] as int,
          recordKey: uuid,
          recordLabel: _recordLabel('specimen', row, row['rid'] as int),
          detail: table,
          fix: HealthFixAction.createAttributeRow,
          target: _targetFor('specimen', row),
        ),
      );
    }
    return issues;
  }

  Future<List<HealthIssue>> _checkFieldNumbers() async {
    final issues = <HealthIssue>[];
    final conflicts = await _select(
      'SELECT rowid AS rid, * FROM specimen '
      'WHERE fieldNumber IS NOT NULL AND projectFieldNumber IS NOT NULL',
    );
    for (final row in conflicts) {
      issues.add(
        HealthIssue(
          kind: HealthIssueKind.fieldNumberConflict,
          table: 'specimen',
          rowId: row['rid'] as int,
          recordLabel: _recordLabel('specimen', row, row['rid'] as int),
          target: _targetFor('specimen', row),
        ),
      );
    }
    // A cataloger's field numbers run on across projects, so their duplicates
    // are found database-wide. Project field numbers belong to one project.
    final groups = await _select(
      'SELECT group_concat(s.uuid, char(31)) AS uuids, s.fieldNumber AS number, '
      'p.initial AS initial, NULL AS projectUuid, NULL AS projectName '
      'FROM specimen s LEFT JOIN personnel p ON p.uuid = s.catalogerID '
      'WHERE s.fieldNumber IS NOT NULL AND s.catalogerID IS NOT NULL '
      'GROUP BY s.catalogerID, s.fieldNumber HAVING COUNT(*) > 1 '
      'UNION ALL '
      'SELECT group_concat(s.uuid, char(31)), s.projectFieldNumber, NULL, '
      's.projectUuid, pr.name '
      'FROM specimen s LEFT JOIN project pr ON pr.uuid = s.projectUuid '
      'WHERE s.projectFieldNumber IS NOT NULL '
      'GROUP BY s.projectUuid, s.projectFieldNumber HAVING COUNT(*) > 1',
    );
    for (final group in groups) {
      final uuids = (group['uuids'] as String).split(String.fromCharCode(31));
      final number = group['number'];
      final prefix = group['initial'] ?? group['projectName'];
      issues.add(
        HealthIssue(
          kind: HealthIssueKind.duplicateFieldNumber,
          table: 'specimen',
          recordKey: group['projectUuid'] ?? 'personnel',
          recordLabel: prefix == null ? '$number' : '$prefix $number',
          detail: '${uuids.length}',
          target: HealthRecordTarget(
            type: DataTableRecordType.specimenRecords,
            keys: uuids.toSet(),
          ),
        ),
      );
    }
    return issues;
  }

  Future<void> _applyFix(HealthIssue issue) async {
    final table = _quote(issue.table);
    switch (issue.fix!) {
      case HealthFixAction.clearLink:
        final assignments = issue.columns
            .map((column) => '${_quote(column)} = NULL')
            .join(', ');
        await _execute('UPDATE $table SET $assignments WHERE rowid = ?', [
          issue.rowId,
        ]);
      case HealthFixAction.removeRow:
        await _execute('DELETE FROM $table WHERE rowid = ?', [issue.rowId]);
      case HealthFixAction.removeMissingMedia:
        final mediaId = issue.recordKey;
        for (final link in const [
          'siteMedia',
          'eventMedia',
          'narrativeMedia',
          'specimenMedia',
        ]) {
          await _execute('DELETE FROM $link WHERE mediaId = ?', [mediaId]);
        }
        await _execute('UPDATE taxonomy SET mediaId = NULL WHERE mediaId = ?', [
          mediaId,
        ]);
        await _execute('UPDATE site SET mediaID = NULL WHERE mediaID = ?', [
          mediaId,
        ]);
        await _execute(
          'UPDATE narrative SET mediaID = NULL WHERE mediaID = ?',
          [mediaId],
        );
        await _execute('DELETE FROM media WHERE primaryId = ?', [mediaId]);
      case HealthFixAction.createAttributeRow:
        await _execute(
          'INSERT INTO ${_quote(issue.detail!)} (specimenUuid) '
          'SELECT ? WHERE NOT EXISTS '
          '(SELECT 1 FROM ${_quote(issue.detail!)} WHERE specimenUuid = ?)',
          [issue.recordKey, issue.recordKey],
        );
      case HealthFixAction.clearPersonnelPhoto:
        await _execute('UPDATE personnel SET photoPath = NULL WHERE uuid = ?', [
          issue.recordKey,
        ]);
    }
  }

  /// What the user knows a record by. Falls back to the table's row number.
  String _recordLabel(String table, Map<String, dynamic>? row, int? rowId) {
    final fallback = rowId == null ? table : '$table #$rowId';
    if (row == null) return fallback;
    final label = switch (table) {
      'specimen' => _specimenLabel(row),
      'site' => row['siteID'],
      'collEvent' => [
        row['startDate'],
        row['idSuffix'],
      ].whereType<Object>().join(' '),
      'narrative' => row['date'],
      'taxonomy' => [
        row['genus'],
        row['specificEpithet'],
      ].whereType<Object>().join(' '),
      'personnel' => row['name'],
      'media' => row['fileName'],
      _ => null,
    };
    final text = label?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  String? _specimenLabel(Map<String, dynamic> row) {
    final number = row['fieldNumber'] ?? row['projectFieldNumber'];
    if (number != null) return '$number';
    final uuid = row['uuid'] as String?;
    return uuid == null || uuid.length < 8 ? uuid : uuid.substring(0, 8);
  }

  /// The record to open for a row of [table]. A row that only hangs off a
  /// specimen opens that specimen, unless the specimen is what is missing.
  HealthRecordTarget? _targetFor(
    String table,
    Map<String, dynamic>? row, {
    String? parent,
  }) {
    if (row == null) return null;
    final (type, key) = switch (table) {
      'specimen' => (DataTableRecordType.specimenRecords, row['uuid']),
      'specimenPart' => (DataTableRecordType.specimenParts, row['id']),
      'symbiont' => (DataTableRecordType.symbionts, row['id']),
      'site' => (DataTableRecordType.sites, row['id']),
      'collEvent' => (DataTableRecordType.events, row['id']),
      'narrative' => (DataTableRecordType.narrative, row['id']),
      _ when parent != 'specimen' && row['specimenUuid'] != null => (
        DataTableRecordType.specimenRecords,
        row['specimenUuid'],
      ),
      _ => (null, null),
    };
    if (type == null || key == null) return null;
    return HealthRecordTarget(type: type, keys: {key as Object});
  }

  Future<Map<String, dynamic>?> _rowByRowId(String table, int rowId) async {
    final rows = await _select(
      'SELECT * FROM ${_quote(table)} WHERE rowid = ?',
      [rowId],
    );
    return rows.isEmpty ? null : rows.single;
  }

  Future<List<Map<String, dynamic>>> _select(
    String sql, [
    List<Object?> values = const [],
  ]) async {
    final rows = await dbAccess
        .customSelect(
          sql,
          variables: values.map(_variable).toList(growable: false),
          readsFrom: const {},
        )
        .get();
    return rows.map((row) => row.data).toList(growable: false);
  }

  Future<void> _execute(String sql, List<Object?> values) =>
      dbAccess.customStatement(sql, values);

  Variable _variable(Object? value) => switch (value) {
    int value => Variable.withInt(value),
    String value => Variable.withString(value),
    _ => Variable<Object>(value),
  };

  static String _quote(String identifier) =>
      '"${identifier.replaceAll('"', '""')}"';
}
