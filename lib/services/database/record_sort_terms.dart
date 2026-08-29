import 'package:drift/drift.dart';
import 'package:nahpu/services/types/record_sort.dart';

/// Drift ordering helpers shared by the four record-viewer list queries.
///
/// Every list query must produce a *total* order: the viewers refetch on each
/// page change, so a tie that SQLite is free to break either way would let the
/// pages reshuffle mid-swipe. Each `getAll*` therefore appends its primary key
/// as the final ordering term.

OrderingMode orderingModeFor(RecordSortDirection direction) =>
    direction == RecordSortDirection.ascending
    ? OrderingMode.asc
    : OrderingMode.desc;

/// Ordering terms for a text column: blanks last in *both* directions, then
/// the column itself in [direction].
///
/// Blank means NULL or the empty string — this schema writes `''` for fields
/// the user cleared, and SQLite's `NULLS LAST` (3.30+) would not cover those.
/// Bucketing on `col IS NULL OR col = ''` sorts false (0) ahead of true (1) in
/// every SQLite version. Blanks stay last when the user reverses the
/// direction because a blank is absence of data, not a value: someone sorting
/// localities descending still wants the filled-in records first.
List<OrderingTerm> textSortTerms(
  Expression<String> column,
  RecordSortDirection direction,
) {
  return [
    OrderingTerm.asc(column.isNull() | column.equals('')),
    OrderingTerm(expression: column, mode: orderingModeFor(direction)),
  ];
}

/// Ordering terms for a non-text column: NULLs last in both directions, then
/// the column itself in [direction]. See [textSortTerms].
List<OrderingTerm> valueSortTerms(
  Expression<Object> column,
  RecordSortDirection direction,
) {
  return [
    OrderingTerm.asc(column.isNull()),
    OrderingTerm(expression: column, mode: orderingModeFor(direction)),
  ];
}
