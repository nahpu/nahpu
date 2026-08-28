import 'package:flutter/foundation.dart';
import 'package:nahpu/services/providers/page_jump.dart';

/// A field a record viewer can be ordered by.
///
/// One enum across all four viewers, gated per viewer by [recordSortFields], so
/// the sort dialog, the preference codec, and the SQL term builders share a
/// single vocabulary. A value that a viewer does not offer simply falls back to
/// [RecordSortField.insertion] in the query builders.
enum RecordSortField {
  /// Insertion order: `site.id`, `collEvent.id`, `narrative.id`, and
  /// `specimen.rowId` (the specimen primary key is a uuid, not an int).
  insertion,

  /// `site.siteID`.
  siteName,

  /// `site.stateProvince`.
  stateProvince,

  /// `site.locality` — the precise locality; there is no `preciseLocality`
  /// column in the schema.
  locality,

  /// The components of the displayed event id, in the order
  /// `formatCollEventId` composes them: site id, start date, then suffix.
  eventId,

  /// `collEvent.startDate`.
  startDate,

  /// `specimen.fieldNumber` or `specimen.projectFieldNumber`, whichever the
  /// active `FieldIdMode` selects.
  fieldId,

  /// `personnel.name` joined through `specimen.catalogerID`.
  cataloger,

  /// `taxonomy.genus`, then specific and subspecific epithet.
  species,

  /// `narrative.date`.
  narrativeDate,

  /// `site.siteID` joined through `narrative.siteID`.
  narrativeSite,

  /// `personnel.name` joined through `narrative.writerId`.
  writer;

  /// The menu label for this field in [viewer].
  ///
  /// [insertion] reads "ID" where the record carries a visible integer id, and
  /// "Record order" for specimens, whose primary key is a uuid.
  String labelFor(RecordViewer viewer) {
    switch (this) {
      case RecordSortField.insertion:
        return viewer == RecordViewer.specimen ? 'Record order' : 'ID';
      case RecordSortField.siteName:
        return 'Site ID';
      case RecordSortField.stateProvince:
        return 'State/province';
      case RecordSortField.locality:
        return 'Precise locality';
      case RecordSortField.eventId:
        return 'Event ID';
      case RecordSortField.startDate:
        return 'Start date';
      case RecordSortField.fieldId:
        return 'Field ID';
      case RecordSortField.cataloger:
        return 'Cataloger';
      case RecordSortField.species:
        return 'Species';
      case RecordSortField.narrativeDate:
        return 'Date';
      case RecordSortField.narrativeSite:
        return 'Site ID';
      case RecordSortField.writer:
        return 'Writer';
    }
  }
}

enum RecordSortDirection {
  ascending,
  descending;

  String get label =>
      this == RecordSortDirection.ascending ? 'Ascending' : 'Descending';
}

/// The field and direction a record viewer orders its pages by.
@immutable
class RecordSort {
  const RecordSort({
    this.field = RecordSortField.insertion,
    this.direction = RecordSortDirection.ascending,
  });

  final RecordSortField field;
  final RecordSortDirection direction;

  /// Insertion order, ascending: the order every viewer used before sorting
  /// existed, and the order the create/duplicate flows assume.
  static const RecordSort defaultSort = RecordSort();

  bool get isDefault => this == defaultSort;

  RecordSort copyWith({
    RecordSortField? field,
    RecordSortDirection? direction,
  }) {
    return RecordSort(
      field: field ?? this.field,
      direction: direction ?? this.direction,
    );
  }

  /// Encodes to `'<field>:<direction>'` for shared preferences.
  String encode() => '${field.name}:${direction.name}';

  /// Decodes [raw], falling back to [defaultSort] for anything unrecognized.
  ///
  /// A preference written by a build with different enum values must never
  /// wedge a viewer, so this never throws.
  static RecordSort decode(String? raw) {
    if (raw == null) return defaultSort;
    final parts = raw.split(':');
    if (parts.length != 2) return defaultSort;
    RecordSortField? field;
    for (final value in RecordSortField.values) {
      if (value.name == parts.first) field = value;
    }
    RecordSortDirection? direction;
    for (final value in RecordSortDirection.values) {
      if (value.name == parts.last) direction = value;
    }
    if (field == null || direction == null) return defaultSort;
    return RecordSort(field: field, direction: direction);
  }

  @override
  bool operator ==(Object other) =>
      other is RecordSort &&
      other.field == field &&
      other.direction == direction;

  @override
  int get hashCode => Object.hash(field, direction);

  @override
  String toString() => 'RecordSort(${encode()})';
}

/// The fields each viewer offers, in menu order.
///
/// [RecordSortField.insertion] is always first: it is the default, and the
/// order the create and duplicate flows append into.
const Map<RecordViewer, List<RecordSortField>> recordSortFields = {
  RecordViewer.site: [
    RecordSortField.insertion,
    RecordSortField.siteName,
    RecordSortField.stateProvince,
    RecordSortField.locality,
  ],
  RecordViewer.collEvent: [
    RecordSortField.insertion,
    RecordSortField.eventId,
    RecordSortField.startDate,
  ],
  RecordViewer.specimen: [
    RecordSortField.insertion,
    RecordSortField.fieldId,
    RecordSortField.cataloger,
    RecordSortField.species,
  ],
  RecordViewer.narrative: [
    RecordSortField.insertion,
    RecordSortField.narrativeDate,
    RecordSortField.narrativeSite,
    RecordSortField.writer,
  ],
};
