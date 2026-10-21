import 'package:drift/drift.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/data_table/data_table_query.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/sites/geography_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/geography.dart';
import 'package:nahpu/services/types/specimens.dart';

/// One cell of the table: a field of one record.
class DataTableCellId {
  const DataTableCellId(this.recordKey, this.fieldKey);

  final Object recordKey;
  final String fieldKey;

  @override
  bool operator ==(Object other) =>
      other is DataTableCellId &&
      other.recordKey == recordKey &&
      other.fieldKey == fieldKey;

  @override
  int get hashCode => Object.hash(recordKey, fieldKey);
}

/// A change to one cell that has not been saved yet.
class DataTableEdit {
  const DataTableEdit({
    required this.cell,
    required this.field,
    required this.value,
    this.row = const {},
    this.attributeTable,
    this.revision = 0,
  });

  final DataTableCellId cell;
  final DataTableField field;

  /// The new stored value, as text. Empty clears the field.
  final String value;

  /// The record's stored editable values, used to rebuild a locality.
  final Map<String, String> row;
  final String? attributeTable;

  /// Bumped on every change to the cell, so a save that finishes after a
  /// newer edit doesn't mark the newer edit saved.
  final int revision;

  DataTableEdit copyWith({String? value, int? revision}) => DataTableEdit(
    cell: cell,
    field: field,
    value: value ?? this.value,
    row: row,
    attributeTable: attributeTable,
    revision: revision ?? this.revision,
  );
}

class DataTableSaveResult {
  const DataTableSaveResult({required this.saved, required this.errors});

  final Set<DataTableCellId> saved;
  final Map<DataTableCellId, String> errors;
}

/// Converts [raw] to the value stored for [field]. Empty input clears it.
///
/// Throws [FormatException] with a message for the user when the text
/// doesn't fit the field.
Object? dataTableStoredValue(DataTableField field, String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;
  switch (field.valueType) {
    case DataTableValueType.text:
      return value;
    case DataTableValueType.integer:
      final number = int.tryParse(value);
      if (number == null) throw FormatException('Enter a whole number', raw);
      return number;
    case DataTableValueType.real:
      final number = double.tryParse(value);
      if (number == null) throw FormatException('Enter a number', raw);
      return number;
    case DataTableValueType.date:
      if (!isDataTableDate(value)) {
        throw FormatException('Enter a date as YYYY-MM-DD', raw);
      }
      return value;
    case DataTableValueType.time:
      if (!isDataTableTime(value)) {
        throw FormatException('Enter a time as HH:MM', raw);
      }
      return value;
  }
}

/// Writes data table edits.
///
/// Edits are grouped per record and table, and each group is written in its
/// own transaction, so one bad record doesn't hold back the rest. Tables and
/// columns come from the field catalog; values are bound variables.
class DataTableSaveService {
  const DataTableSaveService(this.db);

  final Database db;

  Future<DataTableSaveResult> save(
    DataTableRecordType type,
    Iterable<DataTableEdit> edits,
  ) async {
    final groups = <(Object, DataTableWriteTarget), List<DataTableEdit>>{};
    final errors = <DataTableCellId, String>{};
    for (final edit in edits) {
      final target = edit.field.writeTarget;
      if (target == null || !type.writeTargets.contains(target)) {
        errors[edit.cell] = 'This field can\'t be edited here.';
        continue;
      }
      groups.putIfAbsent((edit.cell.recordKey, target), () => []).add(edit);
    }

    final saved = <DataTableCellId>{};
    for (final entry in groups.entries) {
      final (key, target) = entry.key;
      final group = entry.value;
      try {
        final values = {
          for (final edit in group)
            edit.field.column!: dataTableStoredValue(edit.field, edit.value),
        };
        await db.transaction(() => _write(target, key, values, group));
        saved.addAll(group.map((edit) => edit.cell));
      } on FormatException catch (e) {
        for (final edit in group) {
          errors[edit.cell] = e.message;
        }
      } catch (e) {
        for (final edit in group) {
          errors[edit.cell] = 'Couldn\'t save: $e';
        }
      }
    }
    return DataTableSaveResult(saved: saved, errors: errors);
  }

  Future<void> _write(
    DataTableWriteTarget target,
    Object key,
    Map<String, Object?> values,
    List<DataTableEdit> group,
  ) async {
    switch (target) {
      case DataTableWriteTarget.specimen:
        await _update('specimen', values, 'uuid = ?', key);
      case DataTableWriteTarget.part:
        await _update('specimenPart', values, 'id = ?', key);
      case DataTableWriteTarget.site:
        await _update('site', values, 'id = ?', key);
      case DataTableWriteTarget.event:
        await _update('collEvent', values, 'id = ?', key);
      case DataTableWriteTarget.narrative:
        await _update('narrative', values, 'id = ?', key);
      case DataTableWriteTarget.siteAttribute:
        await _upsertOneToOne('siteAttribute', 'siteID', key, values);
      case DataTableWriteTarget.environment:
        await _upsertOneToOne('environment', 'eventID', key, values);
      case DataTableWriteTarget.attribute:
        final table = await _attributeTable(key as String, group);
        await _upsertOneToOne(table, 'specimenUuid', key, values);
      case DataTableWriteTarget.geography:
        await _resolveGeography(key as int, group);
    }
  }

  Future<void> _update(
    String table,
    Map<String, Object?> values,
    String where,
    Object key,
  ) async {
    final changed = await db.customUpdate(
      'UPDATE $table SET ${values.keys.map((c) => '$c = ?').join(', ')} '
      'WHERE $where',
      variables: [
        for (final value in values.values) Variable<Object>(value),
        Variable<Object>(key),
      ],
      updateKind: UpdateKind.update,
    );
    if (changed == 0) throw StateError('The record no longer exists.');
  }

  /// Updates the first row linked to [key], or adds one when the record has
  /// none yet: attribute, habitat, and environment rows are created lazily.
  Future<void> _upsertOneToOne(
    String table,
    String linkColumn,
    Object key,
    Map<String, Object?> values,
  ) async {
    final changed = await db.customUpdate(
      'UPDATE $table SET ${values.keys.map((c) => '$c = ?').join(', ')} '
      'WHERE rowid = (SELECT MIN(rowid) FROM $table WHERE $linkColumn = ?)',
      variables: [
        for (final value in values.values) Variable<Object>(value),
        Variable<Object>(key),
      ],
      updateKind: UpdateKind.update,
    );
    if (changed > 0) return;
    final columns = [linkColumn, ...values.keys];
    await db.customInsert(
      'INSERT INTO $table (${columns.join(', ')}) '
      'VALUES (${List.filled(columns.length, '?').join(', ')})',
      variables: [
        Variable<Object>(key),
        for (final value in values.values) Variable<Object>(value),
      ],
    );
  }

  /// The attribute table to write for a specimen: the one that already has
  /// its row, else the one its taxon group uses.
  Future<String> _attributeTable(
    String specimenUuid,
    List<DataTableEdit> group,
  ) async {
    var table = group.first.attributeTable;
    if (table == null) {
      final row = await db
          .customSelect(
            'SELECT taxonGroup FROM specimen WHERE uuid = ?',
            variables: [Variable.withString(specimenUuid)],
            readsFrom: const {},
          )
          .getSingleOrNull();
      table = _attributeTableForGroup(row?.data['taxonGroup'] as String?);
    }
    for (final edit in group) {
      final fits = edit.field.attributeTables.any((t) => t.table == table);
      if (!fits) {
        throw FormatException(
          '${edit.field.column} isn\'t recorded for this taxon group',
        );
      }
    }
    return table!;
  }

  String? _attributeTableForGroup(String? taxonGroup) {
    final group = taxonGroup ?? '';
    if (group.toLowerCase().contains('fossil')) return 'fossilAttribute';
    return switch (matchTaxonGroupToRecordType(group)) {
      SpecimenRecordType.birds => 'birdAttribute',
      SpecimenRecordType.herpetofauna => 'herpAttribute',
      SpecimenRecordType.invertebrates => 'invertebrateAttribute',
      SpecimenRecordType.fishes => null,
      _ => 'mammalAttribute',
    };
  }

  /// Localities are shared between sites, so an edit resolves the full
  /// locality to a matching or new row instead of changing the shared one.
  Future<void> _resolveGeography(int siteId, List<DataTableEdit> group) async {
    final current = {
      for (final field in _geographyColumns)
        field: group.first.row['geography::${_geographyKeys[field]}'] ?? '',
    };
    for (final edit in group) {
      current[edit.field.column!] = edit.value.trim();
    }
    String? value(String column) =>
        current[column]!.isEmpty ? null : current[column];
    await GeographyServices.resolveForSiteIn(
      db,
      siteId,
      GeographyDraft(
        country: value('country'),
        islandGroup: value('islandGroup'),
        stateProvince: value('stateProvince'),
        county: value('county'),
        municipality: value('municipality'),
        locality: value('locality'),
      ),
    );
  }
}

const _geographyColumns = [
  'country',
  'islandGroup',
  'stateProvince',
  'county',
  'municipality',
  'locality',
];

/// Export key names of the geography columns.
const _geographyKeys = {
  'country': 'country',
  'islandGroup': 'islandGroup',
  'stateProvince': 'stateProvince',
  'county': 'county',
  'municipality': 'municipality',
  'locality': 'specificLocality',
};
