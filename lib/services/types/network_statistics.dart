import 'package:flutter/foundation.dart';

/// Record types shown as nodes in the statistics network.
///
/// Every link is counted through specimens: two records are linked when at
/// least one specimen belongs to both, and the link weight is the number of
/// such specimens.
enum NetworkNodeType {
  site,
  event,
  specimen,
  taxon,
  collector,
  media,
  part,
  parasite;

  /// Record types a record of this type can link to: every other type, since
  /// every type shares specimens with every other.
  List<NetworkNodeType> get linkableTypes => [
    for (final type in NetworkNodeType.values)
      if (type != this) type,
  ];
}

/// How the statistics network is drawn.
enum NetworkLayout {
  /// One record type in the middle, records around it, and each expanded
  /// record's neighbors on the next ring out.
  radial,

  /// One column per record type with bands between neighboring columns.
  layered,
}

/// Identifies one node in the network.
///
/// An overflow node stands for every record of [type] left out of a page;
/// its [id] is the key of the record whose neighbors were paged, or empty
/// for the top level.
@immutable
class NetworkNodeKey {
  const NetworkNodeKey(this.type, this.id) : isOverflow = false;

  const NetworkNodeKey.overflow(this.type, this.id) : isOverflow = true;

  final NetworkNodeType type;
  final String id;
  final bool isOverflow;

  @override
  bool operator ==(Object other) =>
      other is NetworkNodeKey &&
      other.type == type &&
      other.id == id &&
      other.isOverflow == isOverflow;

  @override
  int get hashCode => Object.hash(type, id, isOverflow);

  @override
  String toString() => '${type.name}:${isOverflow ? '+' : ''}$id';
}

/// One record and the number of specimens linked to it.
@immutable
class NetworkCount {
  const NetworkCount({
    required this.id,
    required this.label,
    required this.count,
  });

  final String id;
  final String label;
  final int count;
}

/// The top records of one type, plus what the page left out.
@immutable
class NetworkCountPage {
  const NetworkCountPage({
    required this.type,
    required this.items,
    required this.totalRecords,
    required this.totalCount,
  });

  const NetworkCountPage.empty(this.type)
    : items = const [],
      totalRecords = 0,
      totalCount = 0;

  final NetworkNodeType type;
  final List<NetworkCount> items;

  /// Number of records of [type], shown or not.
  final int totalRecords;

  /// Sum of the counts of every record of [type], shown or not.
  final int totalCount;

  /// Records left out of [items].
  int get hiddenRecords => totalRecords - items.length;

  /// Sum of the counts of the records left out of [items].
  int get hiddenCount =>
      totalCount - items.fold<int>(0, (sum, item) => sum + item.count);
}

/// Specimens shared by one record in a column and one in the next.
///
/// A null id stands for the column's overflow node.
@immutable
class NetworkFlow {
  const NetworkFlow({
    required this.fromId,
    required this.toId,
    required this.weight,
  });

  final String? fromId;
  final String? toId;
  final int weight;
}

/// Counts for the layered network: one page per column and the flows
/// between each pair of neighboring columns.
@immutable
class NetworkLayeredData {
  const NetworkLayeredData({
    required this.columns,
    required this.flows,
    this.focusFlows,
  });

  final List<NetworkCountPage> columns;

  /// `flows[i]` links `columns[i]` to `columns[i + 1]`.
  final List<List<NetworkFlow>> flows;

  /// The part of [flows] carried by the specimens of the focused record, or
  /// null without a focus.
  final List<List<NetworkFlow>>? focusFlows;
}

/// Records of [type] ranked by linked specimens, limited to the specimens of
/// [source] when set, else the top level of the network.
@immutable
class NetworkPageRequest {
  const NetworkPageRequest({
    required this.projectUuid,
    required this.type,
    required this.limit,
    this.source,
  });

  /// Project the counts cover, or null for every project in the database.
  final String? projectUuid;
  final NetworkNodeType type;
  final int limit;
  final NetworkNodeKey? source;

  @override
  bool operator ==(Object other) =>
      other is NetworkPageRequest &&
      other.projectUuid == projectUuid &&
      other.type == type &&
      other.limit == limit &&
      other.source == source;

  @override
  int get hashCode => Object.hash(projectUuid, type, limit, source);
}

/// Columns, page sizes, and focus for the layered network.
@immutable
class NetworkLayeredRequest {
  const NetworkLayeredRequest({
    required this.projectUuid,
    required this.columns,
    required this.limits,
    this.focus,
  });

  final String? projectUuid;
  final List<NetworkNodeType> columns;

  /// Page size of each column, in the order of [columns].
  final List<int> limits;
  final NetworkNodeKey? focus;

  @override
  bool operator ==(Object other) =>
      other is NetworkLayeredRequest &&
      other.projectUuid == projectUuid &&
      listEquals(other.columns, columns) &&
      listEquals(other.limits, limits) &&
      other.focus == focus;

  @override
  int get hashCode => Object.hash(
    projectUuid,
    Object.hashAll(columns),
    Object.hashAll(limits),
    focus,
  );
}
