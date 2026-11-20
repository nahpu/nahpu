import 'dart:io';

import 'package:nahpu/services/data_table/data_table_models.dart';

/// A kind of problem the database check looks for.
enum HealthIssueKind {
  /// SQLite reports damage to the database file itself.
  databaseIntegrity,

  /// A record points to a record that no longer exists.
  brokenLink,

  /// A specimen or event points to an event or site in another project.
  crossProjectLink,

  /// A media record whose file is missing or cannot be located.
  missingMedia,

  /// A personnel photo whose file is missing.
  missingPersonnelPhoto,

  /// A specimen without the attribute row its taxon group keeps
  /// measurements in.
  missingAttributeRecord,

  /// A specimen with both a personnel and a project field number.
  fieldNumberConflict,

  /// Several specimens sharing one field number.
  duplicateFieldNumber;

  /// Whether the problem stops a project export or package.
  HealthSeverity get severity => switch (this) {
    missingMedia ||
    missingPersonnelPhoto ||
    missingAttributeRecord ||
    duplicateFieldNumber => HealthSeverity.warning,
    _ => HealthSeverity.error,
  };
}

/// How much a problem matters.
enum HealthSeverity {
  /// Blocks exports or means the data is damaged.
  error,

  /// Worth fixing, but exports still run.
  warning,
}

/// A repair the check can apply on its own.
enum HealthFixAction {
  /// Empty the link column so the record no longer points anywhere.
  clearLink,

  /// Delete the record, which is useless without what it points to.
  removeRow,

  /// Delete the media record and every link to it.
  removeMissingMedia,

  /// Forget the personnel photo.
  clearPersonnelPhoto,

  /// Add the empty attribute row the specimen should have.
  createAttributeRow,
}

/// Records the user can open in the data table to look at a problem.
class HealthRecordTarget {
  const HealthRecordTarget({required this.type, required this.keys});

  final DataTableRecordType type;

  /// Specimen UUIDs or row ids, as [DataTableKeyScope] expects.
  final Set<Object> keys;
}

/// One problem found by the database check.
class HealthIssue {
  const HealthIssue({
    required this.kind,
    required this.table,
    required this.recordLabel,
    this.rowId,
    this.recordKey,
    this.columns = const [],
    this.parentTable,
    this.detail,
    this.fix,
    this.target,
  });

  final HealthIssueKind kind;

  /// The table holding the record with the problem.
  final String table;

  /// What the user knows the record by, such as a field number or file name.
  final String recordLabel;

  /// The SQLite rowid of the record, when it has one.
  final int? rowId;

  /// The record's own key, such as a media id or personnel UUID.
  final Object? recordKey;

  /// The link columns involved, for broken and cross-project links.
  final List<String> columns;

  /// The table a broken link points to.
  final String? parentTable;

  /// Extra text, such as the SQLite integrity message.
  final String? detail;

  /// The repair to offer, or null when the user has to fix it by hand.
  final HealthFixAction? fix;

  /// Records to open for a closer look, or null when there are none.
  final HealthRecordTarget? target;

  HealthSeverity get severity => kind.severity;

  /// Stable within one report, for remembering which fixes are selected.
  String get id => [
    kind.name,
    table,
    rowId ?? '',
    recordKey ?? '',
    columns.join(','),
    detail ?? '',
  ].join('|');
}

/// The outcome of one database check.
class HealthReport {
  const HealthReport({required this.issues, required this.scannedAt});

  final List<HealthIssue> issues;
  final DateTime scannedAt;

  bool get isHealthy => issues.isEmpty;

  int get errorCount =>
      issues.where((issue) => issue.severity == HealthSeverity.error).length;

  int get warningCount =>
      issues.where((issue) => issue.severity == HealthSeverity.warning).length;

  List<HealthIssue> get fixable =>
      issues.where((issue) => issue.fix != null).toList(growable: false);

  /// Issues grouped by kind, in [HealthIssueKind] order.
  Map<HealthIssueKind, List<HealthIssue>> get byKind => {
    for (final kind in HealthIssueKind.values)
      if (issues.any((issue) => issue.kind == kind))
        kind: issues
            .where((issue) => issue.kind == kind)
            .toList(growable: false),
  };
}

/// What happened when fixes were applied.
class HealthFixResult {
  const HealthFixResult({
    required this.fixed,
    required this.failed,
    required this.backup,
  });

  final int fixed;

  /// Fixes SQLite refused, usually because other records still depend on
  /// the record. Nothing changed for these.
  final List<HealthIssue> failed;

  /// The database copy taken before the fixes, or null when skipped.
  final File? backup;
}
