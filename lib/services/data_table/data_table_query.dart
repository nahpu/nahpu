import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';

/// The record keys on one page, with the totals the pager needs.
class DataTableKeyPage {
  const DataTableKeyPage({
    required this.keys,
    required this.totalRows,
    required this.page,
    required this.pageCount,
  });

  final List<Object> keys;
  final int totalRows;
  final int page;
  final int pageCount;
}

/// Stored values of a page's editable fields, by record key.
class DataTableRawValues {
  const DataTableRawValues({
    required this.values,
    required this.attributes,
    this.siteIds = const {},
    this.eventIds = const {},
    this.specimenUuids = const {},
    this.projectUuids = const {},
  });

  final Map<Object, Map<String, String>> values;

  /// For specimens: the attribute table that holds each specimen's row.
  final Map<Object, String> attributes;

  /// The site and event each record is linked to.
  final Map<Object, int> siteIds;
  final Map<Object, int> eventIds;

  /// The specimen each specimen or part record belongs to.
  final Map<Object, String> specimenUuids;

  /// The project each record belongs to.
  final Map<Object, String> projectUuids;
}

/// Filters, sorts, counts, and pages records in SQL, so only one page of
/// records is ever read.
///
/// Every table alias and column comes from the field catalog; anything the
/// user typed is passed as a bound variable.
class DataTablePageQuery {
  const DataTablePageQuery(this.db);

  final Database db;

  Future<DataTableKeyPage> run(
    DataTableRecordType type,
    DataTableQuery query, {
    required String? projectUuid,
    SpecimenRecordType taxa = SpecimenRecordType.allTaxa,
  }) async {
    final where = _where(type, query, projectUuid, taxa);
    final joins = _joinClause(type, {
      ...where.joins,
      ..._sortFields(query).expand((field) => field.joins),
    });
    final from = '${_from(type)} $joins';

    final countRow = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM $from WHERE ${where.sql}',
          variables: where.variables,
          readsFrom: const {},
        )
        .getSingle();
    final total = countRow.read<int>('c');
    final rowsPerPage = query.rowsPerPage < 1 ? 1 : query.rowsPerPage;
    final pageCount = total == 0 ? 1 : (total + rowsPerPage - 1) ~/ rowsPerPage;
    final page = query.page.clamp(0, pageCount - 1);

    final rows = await db
        .customSelect(
          'SELECT ${_key(type)} AS k FROM $from WHERE ${where.sql} '
          'ORDER BY ${_orderBy(type, query)} LIMIT ? OFFSET ?',
          variables: [
            ...where.variables,
            Variable.withInt(rowsPerPage),
            Variable.withInt(page * rowsPerPage),
          ],
          readsFrom: const {},
        )
        .get();
    return DataTableKeyPage(
      keys: [for (final row in rows) row.data['k']!],
      totalRows: total,
      page: page,
      pageCount: pageCount,
    );
  }

  /// Reads the stored values of [fields] for [keys].
  Future<DataTableRawValues> rawValues(
    DataTableRecordType type,
    List<Object> keys,
    List<DataTableField> fields,
  ) async {
    if (keys.isEmpty) {
      return const DataTableRawValues(values: {}, attributes: {});
    }
    final selected = fields.where((field) => field.isFilterable).toList();
    final isSpecimen = type == DataTableRecordType.specimenRecords;
    final hasSpecimen = isSpecimen || type == DataTableRecordType.specimenParts;
    final links = switch (type) {
      DataTableRecordType.specimenRecords => const ['st.id', 'ce.id'],
      DataTableRecordType.events => const ['st.id', 'ce.id'],
      DataTableRecordType.narrative => const ['st.id', 'NULL'],
      DataTableRecordType.sites => const ['st.id', 'NULL'],
      DataTableRecordType.specimenParts => const ['NULL', 'NULL'],
    };
    final joins = _joinClause(type, {
      ...selected.expand((field) => field.joins),
      if (isSpecimen) ...dataTableAttributeTables.map((table) => table.join),
      if (type != DataTableRecordType.specimenParts) DataTableJoin.site,
    });
    final columns = [
      '${_key(type)} AS k',
      '${links[0]} AS linked_site',
      '${links[1]} AS linked_event',
      '${hasSpecimen ? 's.uuid' : 'NULL'} AS specimen_uuid',
      '${_projectColumn(type)} AS project_uuid',
      for (var i = 0; i < selected.length; i++) '${selected[i].sqlExpr} AS f$i',
      if (isSpecimen)
        for (final table in dataTableAttributeTables)
          '${table.alias}.rowid AS ${table.alias}_row',
    ];
    final placeholders = List.filled(keys.length, '?').join(', ');
    final rows = await db
        .customSelect(
          'SELECT ${columns.join(', ')} FROM ${_from(type)} $joins '
          'WHERE ${_key(type)} IN ($placeholders)',
          variables: [for (final key in keys) _variable(key)],
          readsFrom: const {},
        )
        .get();
    final values = <Object, Map<String, String>>{};
    final attributes = <Object, String>{};
    final siteIds = <Object, int>{};
    final eventIds = <Object, int>{};
    final specimenUuids = <Object, String>{};
    final projectUuids = <Object, String>{};
    for (final row in rows) {
      final key = row.data['k']!;
      if (row.data['linked_site'] case final int id) siteIds[key] = id;
      if (row.data['linked_event'] case final int id) eventIds[key] = id;
      if (row.data['specimen_uuid'] case final String uuid) {
        specimenUuids[key] = uuid;
      }
      if (row.data['project_uuid'] case final String uuid) {
        projectUuids[key] = uuid;
      }
      values[key] = {
        for (var i = 0; i < selected.length; i++)
          selected[i].key: _text(row.data['f$i']),
      };
      if (isSpecimen) {
        for (final table in dataTableAttributeTables) {
          if (row.data['${table.alias}_row'] != null) {
            attributes[key] = table.table;
            break;
          }
        }
      }
    }
    return DataTableRawValues(
      values: values,
      attributes: attributes,
      siteIds: siteIds,
      eventIds: eventIds,
      specimenUuids: specimenUuids,
      projectUuids: projectUuids,
    );
  }

  /// Reads the file names of the media linked to [keys].
  ///
  /// Parts have no media of their own, so they read their specimen's media.
  Future<Map<Object, List<String>>> mediaFiles(
    DataTableRecordType type,
    List<Object> keys,
  ) async {
    if (keys.isEmpty) return const {};
    final (link, owner) = switch (type) {
      DataTableRecordType.specimenRecords => (
        'specimenMedia l ON l.specimenUuid = s.uuid',
        's.uuid',
      ),
      DataTableRecordType.specimenParts => (
        'specimenMedia l ON l.specimenUuid = s.uuid',
        'p.id',
      ),
      DataTableRecordType.sites => ('siteMedia l ON l.siteId = st.id', 'st.id'),
      DataTableRecordType.events => (
        'eventMedia l ON l.eventID = ce.id',
        'ce.id',
      ),
      DataTableRecordType.narrative => (
        'narrativeMedia l ON l.narrativeId = n.id',
        'n.id',
      ),
    };
    final rows = await db
        .customSelect(
          'SELECT $owner AS k, coalesce(m.fileName, m.uri) AS file '
          'FROM ${_from(type)} JOIN $link '
          'JOIN media m ON m.primaryId = l.mediaId '
          'WHERE ${_key(type)} IN (SELECT value FROM json_each(?))',
          variables: [_keysVariable(keys)],
          readsFrom: const {},
        )
        .get();
    final files = <Object, List<String>>{};
    for (final row in rows) {
      if (row.data['file'] case final String file) {
        files.putIfAbsent(row.data['k']!, () => []).add(file);
      }
    }
    return files;
  }

  _WhereClause _where(
    DataTableRecordType type,
    DataTableQuery query,
    String? projectUuid,
    SpecimenRecordType taxa,
  ) {
    final clause = _WhereClause();
    if (projectUuid != null) {
      clause.add('${_projectColumn(type)} = ?', [
        Variable.withString(projectUuid),
      ]);
    } else if (query.projectUuids.isNotEmpty) {
      final placeholders = List.filled(query.projectUuids.length, '?');
      clause.add('${_projectColumn(type)} IN (${placeholders.join(', ')})', [
        for (final uuid in query.projectUuids) Variable.withString(uuid),
      ]);
    }

    final groups = _taxonGroups(type, taxa);
    if (groups.isNotEmpty) {
      clause.add(
        's.taxonGroup IN (${List.filled(groups.length, '?').join(', ')})',
        [for (final group in groups) Variable.withString(group)],
      );
    }

    final search = query.search.trim();
    if (search.isNotEmpty) {
      final keys = query.searchField == null
          ? query.searchKeys
          : [query.searchField!];
      final fields = keys
          .map(dataTableField)
          .where((field) => field.isFilterable)
          .toList();
      if (fields.isEmpty) {
        // Nothing visible can be searched in SQL, so nothing can match.
        clause.add('0', const []);
      } else {
        final pattern = '%${_escapeLike(search)}%';
        clause.add(
          '(${fields.map((f) => "${_asText(f)} LIKE ? ESCAPE '\\'").join(' OR ')})',
          [for (final _ in fields) Variable.withString(pattern)],
          fields.expand((field) => field.joins),
        );
      }
    }

    for (final rule in query.rules) {
      final field = dataTableField(rule.fieldKey);
      if (!field.isFilterable) {
        throw ArgumentError.value(rule.fieldKey, 'rule', 'is not filterable');
      }
      final (sql, variables) = _ruleSql(field, rule);
      clause.add(sql, variables, field.joins);
    }

    for (final filter in query.quickFilters) {
      if (filter.recordType == type) clause.add(filter.sql, const []);
    }

    final scope = query.scope;
    if (scope != null) {
      clause.add('${_key(type)} IN (SELECT value FROM json_each(?))', [
        _keysVariable(scope.keys),
      ]);
    }
    return clause;
  }

  (String, List<Variable>) _ruleSql(
    DataTableField field,
    DataTableFilterRule rule,
  ) {
    final expr = field.sqlExpr!;
    final empty = "($expr IS NULL OR TRIM(CAST($expr AS TEXT)) = '')";
    if (!DataTableFilterOp.forType(field.valueType).contains(rule.op)) {
      throw ArgumentError.value(rule.op, 'op', 'does not apply to this field');
    }
    if (field.valueType == DataTableValueType.coded &&
        rule.op == DataTableFilterOp.equals) {
      final code = field.codeForInput(rule.value);
      if (code == null) {
        throw FormatException('Choose one of the listed values', rule.value);
      }
      return ('$expr = ?', [Variable.withInt(code)]);
    }
    final isNumber =
        field.valueType == DataTableValueType.integer ||
        field.valueType == DataTableValueType.real;
    final compared = isNumber ? 'CAST($expr AS REAL)' : expr;
    Variable value(String raw) => isNumber
        ? Variable.withReal(_parseNumber(raw))
        : Variable.withString(_checkedValue(field.valueType, raw));
    return switch (rule.op) {
      DataTableFilterOp.isEmpty => (empty, const []),
      DataTableFilterOp.isNotEmpty => ('NOT $empty', const []),
      DataTableFilterOp.contains => (
        "$expr LIKE ? ESCAPE '\\'",
        [Variable.withString('%${_escapeLike(rule.value.trim())}%')],
      ),
      DataTableFilterOp.startsWith => (
        "$expr LIKE ? ESCAPE '\\'",
        [Variable.withString('${_escapeLike(rule.value.trim())}%')],
      ),
      DataTableFilterOp.equals =>
        field.valueType == DataTableValueType.text
            ? (
                '$expr = ? COLLATE NOCASE',
                [Variable.withString(rule.value.trim())],
              )
            : ('NOT $empty AND $compared = ?', [value(rule.value)]),
      DataTableFilterOp.greaterThan => (
        'NOT $empty AND $compared > ?',
        [value(rule.value)],
      ),
      DataTableFilterOp.lessThan => (
        'NOT $empty AND $compared < ?',
        [value(rule.value)],
      ),
      DataTableFilterOp.between => (
        'NOT $empty AND $compared BETWEEN ? AND ?',
        [value(rule.value), value(rule.value2)],
      ),
    };
  }

  Iterable<DataTableField> _sortFields(DataTableQuery query) sync* {
    final sort = query.sort;
    if (sort == null) return;
    final field = dataTableField(sort.columnKey);
    if (field.isSortable) yield field;
  }

  String _orderBy(DataTableRecordType type, DataTableQuery query) {
    final terms = <String>[];
    final sort = query.sort;
    for (final field in _sortFields(query)) {
      final direction = sort!.ascending ? 'ASC' : 'DESC';
      final isText =
          field.valueType == DataTableValueType.text ||
          field.valueType == DataTableValueType.coded;
      for (final term in field.orderTerms) {
        // Blanks sort last in both directions.
        terms
          ..add("($term IS NULL OR TRIM(CAST($term AS TEXT)) = '') ASC")
          ..add('$term${isText ? ' COLLATE NOCASE' : ''} $direction');
      }
    }
    terms.add('${_tiebreak(type)} ASC');
    return terms.join(', ');
  }

  String _joinClause(DataTableRecordType type, Iterable<DataTableJoin> wanted) {
    final needed = <DataTableJoin>{};
    void add(DataTableJoin join) {
      if (needed.add(join)) join.requires.forEach(add);
    }

    wanted.forEach(add);
    return [
      for (final join in DataTableJoin.values)
        if (needed.contains(join)) _joinSql(type, join),
    ].whereType<String>().join(' ');
  }

  /// SQL for [join], or null when the base table already provides it.
  String? _joinSql(DataTableRecordType type, DataTableJoin join) {
    final hasSpecimen =
        type == DataTableRecordType.specimenRecords ||
        type == DataTableRecordType.specimenParts;
    switch (join) {
      case DataTableJoin.taxonomy:
        return hasSpecimen
            ? 'LEFT JOIN taxonomy tx ON tx.id = s.speciesID'
            : null;
      case DataTableJoin.cataloger:
        return hasSpecimen
            ? 'LEFT JOIN personnel cat ON cat.uuid = s.catalogerID'
            : null;
      case DataTableJoin.preparator:
        return hasSpecimen
            ? 'LEFT JOIN personnel prep ON prep.uuid = s.preparatorID'
            : null;
      case DataTableJoin.event:
        return hasSpecimen
            ? 'LEFT JOIN collEvent ce ON ce.id = s.collEventID'
            : null;
      case DataTableJoin.site:
        return switch (type) {
          DataTableRecordType.sites => null,
          DataTableRecordType.narrative =>
            'LEFT JOIN site st ON st.id = n.siteID',
          _ => 'LEFT JOIN site st ON st.id = ce.siteID',
        };
      case DataTableJoin.geography:
        return 'LEFT JOIN geography g ON g.id = st.geographyId';
      case DataTableJoin.siteAttribute:
        return 'LEFT JOIN siteAttribute sa ON sa.rowid = '
            '(SELECT MIN(rowid) FROM siteAttribute WHERE siteID = st.id)';
      case DataTableJoin.environment:
        return type == DataTableRecordType.narrative ||
                type == DataTableRecordType.sites
            ? null
            : 'LEFT JOIN environment env ON env.rowid = '
                  '(SELECT MIN(rowid) FROM environment WHERE eventID = ce.id)';
      case DataTableJoin.mammal:
      case DataTableJoin.bird:
      case DataTableJoin.herp:
      case DataTableJoin.invertebrate:
      case DataTableJoin.fossil:
      case DataTableJoin.fish:
        if (!hasSpecimen) return null;
        final table = dataTableAttributeTables.firstWhere(
          (t) => t.join == join,
        );
        return 'LEFT JOIN ${table.table} ${table.alias} ON ${table.alias}.rowid = '
            '(SELECT MIN(rowid) FROM ${table.table} '
            'WHERE specimenUuid = s.uuid)';
    }
  }

  List<String> _taxonGroups(DataTableRecordType type, SpecimenRecordType taxa) {
    if (type != DataTableRecordType.specimenRecords) return const [];
    // Same groups the specimen record export selects.
    return taxonGroupsForRecordType(taxa).toList();
  }
}

String _from(DataTableRecordType type) => switch (type) {
  DataTableRecordType.specimenRecords => 'specimen s',
  DataTableRecordType.specimenParts =>
    'specimenPart p JOIN specimen s ON s.uuid = p.specimenUuid',
  DataTableRecordType.sites => 'site st',
  DataTableRecordType.events => 'collEvent ce',
  DataTableRecordType.narrative => 'narrative n',
};

String _key(DataTableRecordType type) => switch (type) {
  DataTableRecordType.specimenRecords => 's.uuid',
  DataTableRecordType.specimenParts => 'p.id',
  DataTableRecordType.sites => 'st.id',
  DataTableRecordType.events => 'ce.id',
  DataTableRecordType.narrative => 'n.id',
};

/// Final ordering term, so equal sort values keep a stable page order.
/// Specimens use insertion order, matching the export.
String _tiebreak(DataTableRecordType type) =>
    type == DataTableRecordType.specimenRecords ? 's.rowid' : _key(type);

String _projectColumn(DataTableRecordType type) => switch (type) {
  DataTableRecordType.specimenRecords ||
  DataTableRecordType.specimenParts => 's.projectUuid',
  DataTableRecordType.sites => 'st.projectUuid',
  DataTableRecordType.events => 'ce.projectUuid',
  DataTableRecordType.narrative => 'n.projectUuid',
};

String _asText(DataTableField field) => switch (field.valueType) {
  DataTableValueType.text || DataTableValueType.coded => field.displayExpr!,
  _ => 'CAST(${field.sqlExpr} AS TEXT)',
};

Variable _variable(Object key) =>
    key is int ? Variable.withInt(key) : Variable.withString(key.toString());

/// Binds [keys] as one JSON array, read back with `json_each`, so a long key
/// list never runs into the bound-variable limit.
Variable _keysVariable(Iterable<Object> keys) => Variable.withString(
  jsonEncode([for (final key in keys) key is int ? key : key.toString()]),
);

String _text(Object? value) {
  if (value == null) return '';
  if (value is double && value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

/// Makes `%`, `_`, and `\` match literally in a LIKE pattern.
String _escapeLike(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

double _parseNumber(String raw) {
  final value = double.tryParse(raw.trim());
  if (value == null) throw FormatException('Enter a number', raw);
  return value;
}

String _checkedValue(DataTableValueType type, String raw) {
  final value = raw.trim();
  final valid = switch (type) {
    DataTableValueType.date => isDataTableDate(value),
    DataTableValueType.time => isDataTableTime(value),
    _ => true,
  };
  if (!valid) {
    throw FormatException(
      type == DataTableValueType.date
          ? 'Enter a date as YYYY-MM-DD'
          : 'Enter a time as HH:MM',
      raw,
    );
  }
  return value;
}

/// Dates are stored as `yyyy-MM-dd`.
bool isDataTableDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return false;
  final parsed = DateTime.tryParse(value);
  return parsed != null && parsed.toIso8601String().substring(0, 10) == value;
}

/// Times are stored as 24-hour `HH:mm`, optionally with seconds.
bool isDataTableTime(String value) {
  final match = RegExp(r'^(\d{2}):(\d{2})(?::(\d{2}))?$').firstMatch(value);
  if (match == null) return false;
  final hours = int.parse(match[1]!);
  final minutes = int.parse(match[2]!);
  final seconds = int.tryParse(match[3] ?? '0')!;
  return hours < 24 && minutes < 60 && seconds < 60;
}

class _WhereClause {
  final _parts = <String>[];
  final variables = <Variable>[];
  final joins = <DataTableJoin>{};

  String get sql =>
      _parts.isEmpty ? '1' : _parts.map((part) => '($part)').join(' AND ');

  void add(
    String sql,
    List<Variable> values, [
    Iterable<DataTableJoin> needed = const [],
  ]) {
    _parts.add(sql);
    variables.addAll(values);
    joins.addAll(needed);
  }
}
