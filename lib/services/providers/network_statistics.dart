import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/network_statistics_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/statistics/network_layout.dart';
import 'package:nahpu/services/types/network_statistics.dart';

/// Records shown per page at the top level and per layered column.
const networkRootPageSize = 12;

/// Neighbors shown per record type when a record is expanded.
const networkNeighborPageSize = 6;

/// Default layered columns, following specimens from where they were
/// collected to what they are and what was kept from them.
const networkDefaultColumns = [
  NetworkNodeType.site,
  NetworkNodeType.event,
  NetworkNodeType.taxon,
  NetworkNodeType.part,
  NetworkNodeType.parasite,
];

/// Record types shown by default when a radial record is expanded.
const networkDefaultLinkedTypes = [
  NetworkNodeType.site,
  NetworkNodeType.event,
  NetworkNodeType.specimen,
  NetworkNodeType.taxon,
  NetworkNodeType.media,
  NetworkNodeType.part,
  NetworkNodeType.parasite,
];

/// One record type fetched for an expanded record.
@immutable
class NetworkExpansionRequest {
  const NetworkExpansionRequest({
    required this.parent,
    required this.type,
    required this.limit,
  });

  final NetworkNodeKey parent;
  final NetworkNodeType type;
  final int limit;

  NetworkExpansionRequest withLimit(int limit) =>
      NetworkExpansionRequest(parent: parent, type: type, limit: limit);
}

/// What the network shows: layout, record types, expanded records, page
/// sizes, and the selected node.
@immutable
class NetworkViewState {
  const NetworkViewState({
    this.layout = NetworkLayout.radial,
    this.rootType = NetworkNodeType.taxon,
    this.rootLimit = networkRootPageSize,
    this.expansions = const [],
    this.linkedTypes = networkDefaultLinkedTypes,
    this.columns = networkDefaultColumns,
    this.columnLimits = const {},
    this.selected,
  });

  final NetworkLayout layout;

  /// Record type at the center of the radial network.
  final NetworkNodeType rootType;
  final int rootLimit;

  /// Expanded records in the radial network, in the order they were opened.
  final List<NetworkExpansionRequest> expansions;

  /// Record types the radial network links to, out of those the start type
  /// supports.
  final List<NetworkNodeType> linkedTypes;

  /// Record types of the layered network, left to right.
  final List<NetworkNodeType> columns;
  final Map<NetworkNodeType, int> columnLimits;
  final NetworkNodeKey? selected;

  bool isExpanded(NetworkNodeKey key) =>
      expansions.any((expansion) => expansion.parent == key);

  /// Record types of the radial network: the start type, then the chosen
  /// linked types.
  List<NetworkNodeType> get radialTypes => [
    rootType,
    for (final type in rootType.linkableTypes)
      if (linkedTypes.contains(type)) type,
  ];

  /// Record types opened when a record of [type] is expanded.
  List<NetworkNodeType> expandedTypes(NetworkNodeType type) => [
    for (final other in radialTypes)
      if (other != type) other,
  ];

  int columnLimit(NetworkNodeType type) =>
      columnLimits[type] ?? networkRootPageSize;

  NetworkViewState copyWith({
    NetworkLayout? layout,
    NetworkNodeType? rootType,
    int? rootLimit,
    List<NetworkExpansionRequest>? expansions,
    List<NetworkNodeType>? linkedTypes,
    List<NetworkNodeType>? columns,
    Map<NetworkNodeType, int>? columnLimits,
    ValueGetter<NetworkNodeKey?>? selected,
  }) => NetworkViewState(
    layout: layout ?? this.layout,
    rootType: rootType ?? this.rootType,
    rootLimit: rootLimit ?? this.rootLimit,
    expansions: expansions ?? this.expansions,
    linkedTypes: linkedTypes ?? this.linkedTypes,
    columns: columns ?? this.columns,
    columnLimits: columnLimits ?? this.columnLimits,
    selected: selected == null ? this.selected : selected(),
  );
}

/// Network view state for one project, or for every project when the UUID
/// is null. Shared by the Explore card and its full-screen view.
class NetworkViewController extends Notifier<NetworkViewState> {
  NetworkViewController(this.projectUuid);

  final String? projectUuid;

  @override
  NetworkViewState build() => const NetworkViewState();

  void setLayout(NetworkLayout layout) {
    state = state.copyWith(layout: layout, selected: () => null);
  }

  /// Recenters the radial network on [type], closing every expansion.
  void setRootType(NetworkNodeType type) {
    state = state.copyWith(
      rootType: type,
      rootLimit: networkRootPageSize,
      expansions: const [],
      selected: () => null,
    );
  }

  /// Sets the record types the radial network links to. Expanded records
  /// keep their open pages and gain or lose the changed types.
  void setLinkedTypes(List<NetworkNodeType> linkedTypes) {
    if (linkedTypes.isEmpty) return;
    final next = state.copyWith(linkedTypes: List.unmodifiable(linkedTypes));
    final parents = {
      for (final expansion in state.expansions) expansion.parent,
    };
    final selected = state.selected;
    state = next.copyWith(
      expansions: [
        for (final parent in parents)
          for (final type in next.expandedTypes(parent.type))
            state.expansions.firstWhere(
              (expansion) => expansion.parent == parent && expansion.type == type,
              orElse: () => NetworkExpansionRequest(
                parent: parent,
                type: type,
                limit: networkNeighborPageSize,
              ),
            ),
      ],
      selected: () =>
          selected != null && next.radialTypes.contains(selected.type)
          ? selected
          : null,
    );
  }

  void setColumns(List<NetworkNodeType> columns) {
    if (columns.isEmpty) return;
    final selected = state.selected;
    state = state.copyWith(
      columns: List.unmodifiable(columns),
      selected: () =>
          selected != null && columns.contains(selected.type) ? selected : null,
    );
  }

  void select(NetworkNodeKey? key) {
    state = state.copyWith(selected: () => key);
  }

  /// Opens [key]'s neighbors of every other record type, or closes them.
  void toggleExpanded(NetworkNodeKey key) {
    if (key.isOverflow) return;
    if (state.isExpanded(key)) {
      state = state.copyWith(
        expansions: [
          for (final expansion in state.expansions)
            if (expansion.parent != key) expansion,
        ],
      );
      return;
    }
    state = state.copyWith(
      expansions: [
        ...state.expansions,
        for (final type in state.expandedTypes(key.type))
          NetworkExpansionRequest(
              parent: key,
              type: type,
              limit: networkNeighborPageSize,
            ),
      ],
      selected: () => key,
    );
  }

  /// Shows the next page behind an overflow node of [type] under [parent],
  /// the radial hub or a layered column when [parent] is null.
  void showMore(NetworkNodeType type, {NetworkNodeKey? parent}) {
    if (state.layout == NetworkLayout.layered) {
      state = state.copyWith(
        columnLimits: {
          ...state.columnLimits,
          type: state.columnLimit(type) + networkRootPageSize,
        },
      );
      return;
    }
    if (parent == null || parent.id.isEmpty) {
      state = state.copyWith(rootLimit: state.rootLimit + networkRootPageSize);
      return;
    }
    state = state.copyWith(
      expansions: [
        for (final expansion in state.expansions)
          if (expansion.parent == parent && expansion.type == type)
            expansion.withLimit(expansion.limit + networkNeighborPageSize)
          else
            expansion,
      ],
    );
  }

  void reset() {
    state = NetworkViewState(
      layout: state.layout,
      rootType: state.rootType,
      columns: state.columns,
    );
  }
}

final networkViewProvider = NotifierProvider.autoDispose
    .family<NetworkViewController, NetworkViewState, String?>(
      NetworkViewController.new,
    );

final networkPageProvider = StreamProvider.autoDispose
    .family<NetworkCountPage, NetworkPageRequest>((ref, request) {
      return NetworkStatisticsQuery(
        ref.watch(databaseProvider),
      ).watchPage(request);
    });

final networkLayeredProvider = StreamProvider.autoDispose
    .family<NetworkLayeredData, NetworkLayeredRequest>((ref, request) {
      return NetworkStatisticsQuery(
        ref.watch(databaseProvider),
      ).watchLayered(request);
    });

final networkFocusFlowsProvider = StreamProvider.autoDispose
    .family<List<List<NetworkFlow>>, NetworkLayeredRequest>((ref, request) {
      return NetworkStatisticsQuery(
        ref.watch(databaseProvider),
      ).watchFocusFlows(request);
    });

/// The laid-out network for one project, or every project when null.
///
/// Radial expansions load on their own, so the network grows as each page
/// arrives instead of waiting for all of them. The layered focus loads
/// apart from the columns, so selecting a record never blanks the network.
final networkLayoutProvider = Provider.autoDispose
    .family<AsyncValue<NetworkLayoutResult>, String?>((ref, projectUuid) {
      final view = ref.watch(networkViewProvider(projectUuid));
      return switch (view.layout) {
        NetworkLayout.radial => _radial(ref, projectUuid, view),
        NetworkLayout.layered => _layered(ref, projectUuid, view),
      };
    });

AsyncValue<NetworkLayoutResult> _radial(
  Ref ref,
  String? projectUuid,
  NetworkViewState view,
) {
  final roots = ref.watch(
    networkPageProvider(
      NetworkPageRequest(
        projectUuid: projectUuid,
        type: view.rootType,
        limit: view.rootLimit,
      ),
    ),
  );
  final expansions = <NetworkExpansion>[
    for (final expansion in view.expansions)
      if (ref
              .watch(
                networkPageProvider(
                  NetworkPageRequest(
                    projectUuid: projectUuid,
                    type: expansion.type,
                    limit: expansion.limit,
                    source: expansion.parent,
                  ),
                ),
              )
              .value
          case final page?)
        NetworkExpansion(parent: expansion.parent, page: page),
  ];
  return roots.whenData(
    (page) =>
        const RadialNetworkLayout().layout(roots: page, expansions: expansions),
  );
}

AsyncValue<NetworkLayoutResult> _layered(
  Ref ref,
  String? projectUuid,
  NetworkViewState view,
) {
  final request = NetworkLayeredRequest(
    projectUuid: projectUuid,
    columns: view.columns,
    limits: [for (final type in view.columns) view.columnLimit(type)],
    focus: view.selected?.isOverflow ?? true ? null : view.selected,
  );
  final focus = request.focus == null
      ? null
      : ref.watch(networkFocusFlowsProvider(request)).value;
  return ref
      .watch(
        networkLayeredProvider(
          NetworkLayeredRequest(
            projectUuid: request.projectUuid,
            columns: request.columns,
            limits: request.limits,
          ),
        ),
      )
      .whenData(
        (data) => const LayeredNetworkLayout().layout(
          NetworkLayeredData(
            columns: data.columns,
            flows: data.flows,
            focusFlows: focus,
          ),
        ),
      );
}
