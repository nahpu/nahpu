import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/statistics/network_layout.dart';
import 'package:nahpu/services/types/network_statistics.dart';

void main() {
  NetworkCountPage page(NetworkNodeType type, int count, {int hidden = 0}) =>
      NetworkCountPage(
        type: type,
        items: [
          for (var i = 0; i < count; i++)
            NetworkCount(id: '$i', label: '${type.name} $i', count: count - i),
        ],
        totalRecords: count + hidden,
        totalCount: count * (count + 1) ~/ 2 + hidden,
      );

  group('radial', () {
    test('places the hub in the middle and records on a ring', () {
      final result = const RadialNetworkLayout().layout(
        roots: page(NetworkNodeType.taxon, 8, hidden: 3),
        expansions: const [],
      );
      final hub = result.nodes.firstWhere(
        (node) => node.kind == NetworkNodeKind.hub,
      );
      final ring = result.nodes.where((node) => node != hub).toList();

      expect(hub.center, result.size.center(Offset.zero));
      expect(ring, hasLength(9));
      expect(
        ring.where((node) => node.kind == NetworkNodeKind.overflow),
        hasLength(1),
      );
      final distances = ring
          .map((node) => (node.center - hub.center).distance)
          .toSet();
      expect(distances.map((d) => d.round()).toSet(), hasLength(1));
      expect(result.edges, hasLength(9));
    });

    test('is deterministic and keeps nodes apart', () {
      NetworkLayoutResult build() => const RadialNetworkLayout().layout(
        roots: page(NetworkNodeType.site, 12),
        expansions: [
          NetworkExpansion(
            parent: const NetworkNodeKey(NetworkNodeType.site, '0'),
            page: page(NetworkNodeType.taxon, 6, hidden: 2),
          ),
        ],
      );
      final first = build();
      final second = build();

      expect(
        first.nodes.map((node) => node.center),
        orderedEquals(second.nodes.map((node) => node.center)),
      );
      for (var i = 0; i < first.nodes.length; i++) {
        for (var j = i + 1; j < first.nodes.length; j++) {
          final a = first.nodes[i];
          final b = first.nodes[j];
          expect(
            (a.center - b.center).distance,
            greaterThanOrEqualTo((a.bounds.width + b.bounds.width) / 2),
            reason: '${a.key} and ${b.key} overlap',
          );
        }
      }
    });

    test('links to a neighbor already shown instead of adding it', () {
      final result = const RadialNetworkLayout().layout(
        roots: page(NetworkNodeType.site, 2),
        expansions: [
          NetworkExpansion(
            parent: const NetworkNodeKey(NetworkNodeType.site, '0'),
            page: page(NetworkNodeType.taxon, 1),
          ),
          NetworkExpansion(
            parent: const NetworkNodeKey(NetworkNodeType.site, '1'),
            page: page(NetworkNodeType.taxon, 1),
          ),
        ],
      );

      expect(
        result.nodes.where((node) => node.key.type == NetworkNodeType.taxon),
        hasLength(1),
      );
      expect(result.edges, hasLength(4));
    });

    test('hit testing finds the node under a point', () {
      final result = const RadialNetworkLayout().layout(
        roots: page(NetworkNodeType.taxon, 4),
        expansions: const [],
      );
      final node = result.nodes.last;

      expect(result.hitTest(node.center)?.key, node.key);
      expect(result.hitTest(Offset.zero), isNull);
    });
  });

  group('layered', () {
    test('stacks columns without overlap and links them with bands', () {
      final data = NetworkLayeredData(
        columns: [
          page(NetworkNodeType.site, 3, hidden: 2),
          page(NetworkNodeType.taxon, 2),
        ],
        flows: const [
          [
            NetworkFlow(fromId: '0', toId: '1', weight: 2),
            NetworkFlow(fromId: '2', toId: '0', weight: 1),
            NetworkFlow(fromId: null, toId: '0', weight: 2),
          ],
        ],
      );
      final result = const LayeredNetworkLayout().layout(data);

      expect(result.columns, hasLength(2));
      expect(result.nodes, hasLength(6));
      for (final type in [NetworkNodeType.site, NetworkNodeType.taxon]) {
        final column = result.nodes
            .where((node) => node.key.type == type)
            .toList();
        for (var i = 1; i < column.length; i++) {
          expect(
            column[i].bounds.top,
            greaterThan(column[i - 1].bounds.bottom),
          );
        }
        expect(
          column.last.kind == NetworkNodeKind.overflow,
          type == NetworkNodeType.site,
        );
      }
      expect(result.edges, hasLength(3));
      expect(result.edges.every((edge) => edge.curved), isTrue);
      expect(result.edges.every((edge) => edge.start.dx < edge.end.dx), isTrue);
    });

    test('orders a column by its links to the column before', () {
      final data = NetworkLayeredData(
        columns: [
          page(NetworkNodeType.site, 2),
          page(NetworkNodeType.taxon, 2),
        ],
        flows: const [
          [
            NetworkFlow(fromId: '0', toId: '1', weight: 2),
            NetworkFlow(fromId: '1', toId: '0', weight: 1),
          ],
        ],
      );
      final result = const LayeredNetworkLayout().layout(data);
      final taxa = result.nodes
          .where((node) => node.key.type == NetworkNodeType.taxon)
          .map((node) => node.key.id)
          .toList();

      expect(taxa, ['1', '0']);
    });
  });
}
