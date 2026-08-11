import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/maps/full_screen_map_page.dart';

void main() {
  testWidgets('full-screen map pages expand shrink-wrapped map stacks', (
    tester,
  ) async {
    final mapKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: FullScreenMapPage(
          title: 'Map',
          child: Stack(
            key: mapKey,
            children: [
              const Positioned.fill(child: ColoredBox(color: Colors.blue)),
              const SizedBox.square(dimension: 48),
            ],
          ),
        ),
      ),
    );

    final mapSize = tester.getSize(find.byKey(mapKey));

    expect(mapSize.width, greaterThan(700));
    expect(mapSize.height, greaterThan(400));
  });
}
