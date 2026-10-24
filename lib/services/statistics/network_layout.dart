import 'dart:math' as math;
import 'dart:ui';

import 'package:nahpu/services/types/network_statistics.dart';

/// What a laid-out node stands for.
enum NetworkNodeKind {
  /// Every record of one type, the center of the radial network.
  hub,

  /// One record.
  record,

  /// The records of one type left out of a page.
  overflow,
}

/// A node placed in network space.
class NetworkLayoutNode {
  const NetworkLayoutNode({
    required this.key,
    required this.kind,
    required this.label,
    required this.count,
    required this.bounds,
    this.hiddenRecords = 0,
    this.parent,
  });

  final NetworkNodeKey key;
  final NetworkNodeKind kind;

  /// Record label; empty for hub and overflow nodes, which the screen names.
  final String label;

  /// Specimens linked to the node. For a radial child this is the specimens
  /// it shares with [parent].
  final int count;

  /// Records an overflow node stands for.
  final int hiddenRecords;

  /// Node this one was expanded from, for paging an overflow node.
  final NetworkNodeKey? parent;

  /// Circle bounds in the radial layout, bar bounds in the layered layout.
  final Rect bounds;

  Offset get center => bounds.center;
}

/// A link between two nodes, drawn from [start] to [end].
class NetworkLayoutEdge {
  const NetworkLayoutEdge({
    required this.from,
    required this.to,
    required this.weight,
    required this.start,
    required this.end,
    required this.width,
    required this.curved,
    this.focusWeight = 0,
  });

  final NetworkNodeKey from;
  final NetworkNodeKey to;

  /// Specimens shared by the two nodes.
  final int weight;

  /// Part of [weight] carried by the focused record's specimens.
  final int focusWeight;
  final Offset start;
  final Offset end;
  final double width;

  /// Whether the edge is a horizontal band rather than a straight line.
  final bool curved;
}

/// A column header in the layered layout.
class NetworkLayoutColumn {
  const NetworkLayoutColumn({
    required this.type,
    required this.left,
    required this.width,
    required this.totalRecords,
  });

  final NetworkNodeType type;
  final double left;
  final double width;
  final int totalRecords;
}

/// Nodes and edges in network space, with a grid index for hit testing.
class NetworkLayoutResult {
  NetworkLayoutResult({
    required this.size,
    required this.nodes,
    required this.edges,
    this.columns = const [],
  }) : _grid = _buildGrid(nodes);

  static const _cell = 96.0;

  final Size size;
  final List<NetworkLayoutNode> nodes;
  final List<NetworkLayoutEdge> edges;
  final List<NetworkLayoutColumn> columns;
  final Map<int, List<int>> _grid;

  bool get isEmpty => nodes.isEmpty;

  /// Top-most node under [point], allowing [slop] around small nodes.
  NetworkLayoutNode? hitTest(Offset point, {double slop = 4}) {
    final candidates = _grid[_cellKey(point.dx, point.dy)];
    if (candidates == null) return null;
    for (final index in candidates.reversed) {
      final node = nodes[index];
      if (node.bounds.inflate(slop).contains(point)) return node;
    }
    return null;
  }

  NetworkLayoutNode? nodeFor(NetworkNodeKey key) {
    for (final node in nodes) {
      if (node.key == key) return node;
    }
    return null;
  }

  static int _cellKey(double x, double y) =>
      (y ~/ _cell) * 100000 + (x ~/ _cell);

  static Map<int, List<int>> _buildGrid(List<NetworkLayoutNode> nodes) {
    final grid = <int, List<int>>{};
    for (var i = 0; i < nodes.length; i++) {
      // Inflated by the largest hit slop so edge taps still find the node.
      final bounds = nodes[i].bounds.inflate(8);
      for (var y = bounds.top ~/ _cell; y <= bounds.bottom ~/ _cell; y++) {
        for (var x = bounds.left ~/ _cell; x <= bounds.right ~/ _cell; x++) {
          (grid[y * 100000 + x] ??= []).add(i);
        }
      }
    }
    return grid;
  }
}

/// One expanded record and the page of neighbors fetched for it.
class NetworkExpansion {
  const NetworkExpansion({required this.parent, required this.page});

  final NetworkNodeKey parent;
  final NetworkCountPage page;
}

/// Places the radial network: a hub for the root type, its records on the
/// first ring, and each expanded record's neighbors on the ring outside it.
///
/// A neighbor already in the network is linked to rather than placed again.
/// Angles are shared by leaf count so busy branches get more room; nothing
/// is simulated, so the layout is stable and costs O(nodes + edges).
class RadialNetworkLayout {
  const RadialNetworkLayout();

  static const ringGap = 150.0;

  /// Smallest gap between neighboring centers on a ring: two of the largest
  /// nodes side by side with room between them.
  static const minArc = maxRadius * 2 + 8;
  static const minRadius = 10.0;
  static const maxRadius = 34.0;
  static const hubRadius = 44.0;
  static const labelMargin = 140.0;

  /// Widest slice a record below the hub may give its neighbors.
  static const maxSweep = math.pi * 2 / 3;

  NetworkLayoutResult layout({
    required NetworkCountPage roots,
    required List<NetworkExpansion> expansions,
  }) {
    final hubKey = NetworkNodeKey(roots.type, '');
    final hub = _TreeNode(
      key: hubKey,
      kind: NetworkNodeKind.hub,
      label: '',
      count: roots.totalCount,
      depth: 0,
    );
    final tree = <NetworkNodeKey, _TreeNode>{hubKey: hub};
    final crossEdges = <(NetworkNodeKey, NetworkNodeKey, int)>[];
    _addPage(tree, hub, roots, crossEdges);
    for (final expansion in expansions) {
      final parent = tree[expansion.parent];
      if (parent == null) continue;
      _addPage(tree, parent, expansion.page, crossEdges);
    }

    _countLeaves(hub);
    _sweep(hub, 0, 2 * math.pi);
    final ringRadii = _ringRadii(tree.values);
    final extent =
        (ringRadii.isEmpty ? 0.0 : ringRadii.last) + maxRadius + labelMargin;
    final center = Offset(extent, extent);
    for (final node in tree.values) {
      node.position = node.depth == 0
          ? center
          : center +
                Offset(math.cos(node.angle), math.sin(node.angle)) *
                    ringRadii[node.depth - 1];
    }

    final maxCount = tree.values
        .where((node) => node.kind != NetworkNodeKind.hub)
        .fold<int>(1, (max, node) => math.max(max, node.count));
    final nodes = <NetworkLayoutNode>[];
    for (final node in tree.values) {
      final radius = node.kind == NetworkNodeKind.hub
          ? hubRadius
          : minRadius +
                (maxRadius - minRadius) * math.sqrt(node.count / maxCount);
      nodes.add(
        NetworkLayoutNode(
          key: node.key,
          kind: node.kind,
          label: node.label,
          count: node.count,
          hiddenRecords: node.hiddenRecords,
          parent: node.parent?.key,
          bounds: Rect.fromCircle(center: node.position, radius: radius),
        ),
      );
    }

    final maxWeight = math.max(
      1,
      [
        for (final node in tree.values)
          if (node.parent != null) node.count,
        for (final edge in crossEdges) edge.$3,
      ].fold<int>(1, math.max),
    );
    double width(int weight) => 1 + 5 * math.sqrt(weight / maxWeight);
    final edges = <NetworkLayoutEdge>[
      for (final node in tree.values)
        if (node.parent case final parent?)
          NetworkLayoutEdge(
            from: parent.key,
            to: node.key,
            weight: node.count,
            start: parent.position,
            end: node.position,
            width: width(node.count),
            curved: false,
          ),
      for (final (from, to, weight) in crossEdges)
        NetworkLayoutEdge(
          from: from,
          to: to,
          weight: weight,
          start: tree[from]!.position,
          end: tree[to]!.position,
          width: width(weight),
          curved: false,
        ),
    ];
    return NetworkLayoutResult(
      size: Size.square(extent * 2),
      nodes: nodes,
      edges: edges,
    );
  }

  static void _addPage(
    Map<NetworkNodeKey, _TreeNode> tree,
    _TreeNode parent,
    NetworkCountPage page,
    List<(NetworkNodeKey, NetworkNodeKey, int)> crossEdges,
  ) {
    for (final item in page.items) {
      final key = NetworkNodeKey(page.type, item.id);
      final existing = tree[key];
      if (existing != null) {
        if (existing != parent && existing.parent != parent) {
          crossEdges.add((parent.key, key, item.count));
        }
        continue;
      }
      final child = _TreeNode(
        key: key,
        kind: NetworkNodeKind.record,
        label: item.label,
        count: item.count,
        depth: parent.depth + 1,
        parent: parent,
      );
      tree[key] = child;
      parent.children.add(child);
    }
    if (page.hiddenRecords > 0) {
      final key = NetworkNodeKey.overflow(page.type, parent.key.toString());
      final overflow = _TreeNode(
        key: key,
        kind: NetworkNodeKind.overflow,
        label: '',
        count: page.hiddenCount,
        hiddenRecords: page.hiddenRecords,
        depth: parent.depth + 1,
        parent: parent,
      );
      tree[key] = overflow;
      parent.children.add(overflow);
    }
  }

  static int _countLeaves(_TreeNode node) {
    if (node.children.isEmpty) return node.leaves = 1;
    var leaves = 0;
    for (final child in node.children) {
      leaves += _countLeaves(child);
    }
    return node.leaves = leaves;
  }

  /// Gives each node a slice of its parent's angle, shared by leaf count,
  /// and points the node at the middle of its slice.
  ///
  /// Below the hub a slice is capped at [maxSweep] around its middle, so an
  /// expanded record's neighbors fan out beside it instead of wrapping round
  /// the hub.
  static void _sweep(_TreeNode node, double start, double sweep) {
    final capped = node.depth == 0 ? sweep : math.min(sweep, maxSweep);
    node
      ..angle = start + sweep / 2
      ..sweep = capped;
    var childStart = start + (sweep - capped) / 2;
    for (final child in node.children) {
      final childSweep = capped * child.leaves / node.leaves;
      _sweep(child, childStart, childSweep);
      childStart += childSweep;
    }
  }

  /// Ring radius for each depth from 1: a [ringGap] past the ring inside it,
  /// and far enough out that the narrowest slice on the ring still spans
  /// [minArc], so neighbors on a ring never overlap.
  static List<double> _ringRadii(Iterable<_TreeNode> nodes) {
    final narrowest = <int, double>{};
    var maxDepth = 0;
    for (final node in nodes) {
      if (node.depth == 0) continue;
      narrowest.update(
        node.depth,
        (sweep) => math.min(sweep, node.sweep),
        ifAbsent: () => node.sweep,
      );
      maxDepth = math.max(maxDepth, node.depth);
    }
    final radii = <double>[];
    var previous = 0.0;
    for (var depth = 1; depth <= maxDepth; depth++) {
      // Neighbors are a chord apart, not an arc.
      final half = math.min(narrowest[depth]!, math.pi) / 2;
      final crowded = minArc / (2 * math.sin(half));
      final radius = math.max(previous + ringGap, crowded);
      radii.add(radius);
      previous = radius;
    }
    return radii;
  }
}

class _TreeNode {
  _TreeNode({
    required this.key,
    required this.kind,
    required this.label,
    required this.count,
    required this.depth,
    this.hiddenRecords = 0,
    this.parent,
  });

  final NetworkNodeKey key;
  final NetworkNodeKind kind;
  final String label;
  final int count;
  final int depth;
  final int hiddenRecords;
  final _TreeNode? parent;
  final List<_TreeNode> children = [];
  int leaves = 1;
  double angle = 0;
  double sweep = 0;
  Offset position = Offset.zero;
}

/// Places the layered network: one column of bars per record type, sized by
/// count, with bands between neighboring columns sized by shared specimens.
///
/// Each column after the first is ordered by the weighted mean height of its
/// links to the column before, which keeps most bands from crossing.
class LayeredNetworkLayout {
  const LayeredNetworkLayout();

  static const columnWidth = 150.0;
  static const columnGap = 200.0;
  static const headerHeight = 48.0;
  static const minBarHeight = 28.0;
  static const barGap = 10.0;
  static const minHeight = 520.0;
  static const margin = 24.0;

  NetworkLayoutResult layout(NetworkLayeredData data) {
    if (data.columns.isEmpty) {
      return NetworkLayoutResult(
        size: Size.zero,
        nodes: const [],
        edges: const [],
      );
    }
    final maxBars = data.columns.fold<int>(
      0,
      (max, page) => math.max(max, _entries(page).length),
    );
    final height = math.max(minHeight, maxBars * (minBarHeight + barGap) * 1.6);
    final nodes = <NetworkLayoutNode>[];
    final columns = <NetworkLayoutColumn>[];
    final byKey = <NetworkNodeKey, NetworkLayoutNode>{};
    List<NetworkLayoutNode> previous = const [];
    for (var i = 0; i < data.columns.length; i++) {
      final page = data.columns[i];
      final left = margin + i * (columnWidth + columnGap);
      columns.add(
        NetworkLayoutColumn(
          type: page.type,
          left: left,
          width: columnWidth,
          totalRecords: page.totalRecords,
        ),
      );
      final entries = _ordered(
        _entries(page),
        i == 0 ? null : data.flows[i - 1],
        {for (final node in previous) node.key: node.center.dy},
        data.columns[i - (i == 0 ? 0 : 1)].type,
      );
      final placed = _stack(entries, left, height);
      nodes.addAll(placed);
      for (final node in placed) {
        byKey[node.key] = node;
      }
      previous = placed;
    }

    final edges = <NetworkLayoutEdge>[];
    for (var i = 0; i < data.flows.length; i++) {
      edges.addAll(
        _bands(
          data.columns[i],
          data.columns[i + 1],
          data.flows[i],
          data.focusFlows?[i],
          byKey,
        ),
      );
    }
    final width =
        margin * 2 +
        data.columns.length * columnWidth +
        (data.columns.length - 1) * columnGap;
    return NetworkLayoutResult(
      size: Size(width, headerHeight + height + margin),
      nodes: nodes,
      edges: edges,
      columns: columns,
    );
  }

  static List<_Entry> _entries(NetworkCountPage page) => [
    for (final item in page.items)
      _Entry(
        key: NetworkNodeKey(page.type, item.id),
        kind: NetworkNodeKind.record,
        label: item.label,
        count: item.count,
      ),
    if (page.hiddenRecords > 0)
      _Entry(
        key: NetworkNodeKey.overflow(page.type, ''),
        kind: NetworkNodeKind.overflow,
        label: '',
        count: page.hiddenCount,
        hiddenRecords: page.hiddenRecords,
      ),
  ];

  /// Orders [entries] by the weighted mean height of their links into the
  /// previous column, keeping unlinked records after linked ones and the
  /// overflow node last.
  static List<_Entry> _ordered(
    List<_Entry> entries,
    List<NetworkFlow>? flows,
    Map<NetworkNodeKey, double> previousY,
    NetworkNodeType previousType,
  ) {
    if (flows == null) return entries;
    final sums = <NetworkNodeKey, (double, int)>{};
    final type = entries.isEmpty ? null : entries.first.key.type;
    if (type == null) return entries;
    for (final flow in flows) {
      final from = _flowKey(previousType, flow.fromId);
      final to = _flowKey(type, flow.toId);
      final y = previousY[from];
      if (y == null) continue;
      final (sum, weight) = sums[to] ?? (0.0, 0);
      sums[to] = (sum + y * flow.weight, weight + flow.weight);
    }
    double rank(_Entry entry) {
      if (entry.kind == NetworkNodeKind.overflow) return double.infinity;
      final (sum, weight) = sums[entry.key] ?? (0.0, 0);
      return weight == 0 ? double.maxFinite : sum / weight;
    }

    final ordered = [...entries];
    ordered.sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : b.count.compareTo(a.count);
    });
    return ordered;
  }

  static List<NetworkLayoutNode> _stack(
    List<_Entry> entries,
    double left,
    double height,
  ) {
    if (entries.isEmpty) return const [];
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.count);
    final free = math.max(
      0.0,
      height - entries.length * (minBarHeight + barGap),
    );
    final scale = total == 0 ? 0.0 : free / total;
    var top = headerHeight;
    return [
      for (final entry in entries)
        () {
          final barHeight = minBarHeight + entry.count * scale;
          final node = NetworkLayoutNode(
            key: entry.key,
            kind: entry.kind,
            label: entry.label,
            count: entry.count,
            hiddenRecords: entry.hiddenRecords,
            bounds: Rect.fromLTWH(left, top, columnWidth, barHeight),
          );
          top += barHeight + barGap;
          return node;
        }(),
    ];
  }

  static List<NetworkLayoutEdge> _bands(
    NetworkCountPage fromPage,
    NetworkCountPage toPage,
    List<NetworkFlow> flows,
    List<NetworkFlow>? focusFlows,
    Map<NetworkNodeKey, NetworkLayoutNode> byKey,
  ) {
    final focus = <(NetworkNodeKey, NetworkNodeKey), int>{
      for (final flow in focusFlows ?? const <NetworkFlow>[])
        (
          _flowKey(fromPage.type, flow.fromId),
          _flowKey(toPage.type, flow.toId),
        ): flow.weight,
    };
    final links = <_Link>[];
    final outSum = <NetworkNodeKey, int>{};
    final inSum = <NetworkNodeKey, int>{};
    for (final flow in flows) {
      final from = byKey[_flowKey(fromPage.type, flow.fromId)];
      final to = byKey[_flowKey(toPage.type, flow.toId)];
      if (from == null || to == null) continue;
      links.add(_Link(from, to, flow.weight, focus[(from.key, to.key)] ?? 0));
      outSum.update(
        from.key,
        (sum) => sum + flow.weight,
        ifAbsent: () => flow.weight,
      );
      inSum.update(
        to.key,
        (sum) => sum + flow.weight,
        ifAbsent: () => flow.weight,
      );
    }
    for (final link in links) {
      final fromShare =
          link.from.bounds.height /
          math.max(outSum[link.from.key]!, link.from.count);
      final toShare =
          link.to.bounds.height / math.max(inSum[link.to.key]!, link.to.count);
      link.width = math.max(1, link.weight * math.min(fromShare, toShare));
    }

    final startOffset = <NetworkNodeKey, double>{};
    final endOffset = <NetworkNodeKey, double>{};
    final startY = <_Link, double>{};
    final endY = <_Link, double>{};
    for (final link in [
      ...links,
    ]..sort((a, b) => a.to.center.dy.compareTo(b.to.center.dy))) {
      final offset = startOffset[link.from.key] ?? 0;
      startY[link] = link.from.bounds.top + offset + link.width / 2;
      startOffset[link.from.key] = offset + link.width;
    }
    for (final link in [
      ...links,
    ]..sort((a, b) => a.from.center.dy.compareTo(b.from.center.dy))) {
      final offset = endOffset[link.to.key] ?? 0;
      endY[link] = link.to.bounds.top + offset + link.width / 2;
      endOffset[link.to.key] = offset + link.width;
    }
    return [
      for (final link in links)
        NetworkLayoutEdge(
          from: link.from.key,
          to: link.to.key,
          weight: link.weight,
          focusWeight: link.focusWeight,
          start: Offset(link.from.bounds.right, startY[link]!),
          end: Offset(link.to.bounds.left, endY[link]!),
          width: link.width,
          curved: true,
        ),
    ];
  }

  static NetworkNodeKey _flowKey(NetworkNodeType type, String? id) =>
      id == null ? NetworkNodeKey.overflow(type, '') : NetworkNodeKey(type, id);
}

class _Entry {
  const _Entry({
    required this.key,
    required this.kind,
    required this.label,
    required this.count,
    this.hiddenRecords = 0,
  });

  final NetworkNodeKey key;
  final NetworkNodeKind kind;
  final String label;
  final int count;
  final int hiddenRecords;
}

class _Link {
  _Link(this.from, this.to, this.weight, this.focusWeight);

  final NetworkLayoutNode from;
  final NetworkLayoutNode to;
  final int weight;
  final int focusWeight;
  double width = 1;
}
