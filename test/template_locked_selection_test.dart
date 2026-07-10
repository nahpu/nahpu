import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/components/canvas/draggable_chip.dart';
import 'package:nahpu/screens/templates/components/canvas/draggable_image_chip.dart';
import 'package:nahpu/screens/templates/components/canvas/draggable_line_chip.dart';
import 'package:nahpu/screens/templates/components/canvas/draggable_shape_chip.dart';

void main() {
  Offset? panDelta(Offset globalPosition, Offset globalDelta) => globalDelta;

  Future<void> pumpLockedElement(
    WidgetTester tester,
    Widget element,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: Stack(children: [element]),
          ),
        ),
      ),
    );
  }

  testWidgets('locked text selects with one pointer press', (tester) async {
    var selections = 0;
    await pumpLockedElement(
      tester,
      DraggableChip(
        label: 'Locked text',
        position: const Offset(20, 20),
        fontSize: 10,
        scale: 1,
        templateWidthMm: 200,
        templateHeightMm: 200,
        templatePanToMmDelta: panDelta,
        onMoved: (_) {},
        isCustom: true,
        isLocked: true,
        onTap: () => selections++,
      ),
    );

    await tester.tapAt(const Offset(25, 25));
    expect(selections, 1);
  });

  testWidgets('locked image selects with one pointer press', (tester) async {
    var selections = 0;
    await pumpLockedElement(
      tester,
      DraggableImageChip(
        imagePath: '',
        vectorChild: const ColoredBox(color: Colors.blue),
        position: const Offset(20, 20),
        widthMm: 20,
        heightMm: 20,
        scale: 1,
        templateWidthMm: 200,
        templateHeightMm: 200,
        templatePanToMmDelta: panDelta,
        onMoved: (_) {},
        onBoundsChanged: (_, __, ___, ____) {},
        onRotationChanged: (_) {},
        isLocked: true,
        onTap: () => selections++,
      ),
    );

    await tester.tapAt(const Offset(25, 25));
    expect(selections, 1);
  });

  testWidgets('locked line selects with one pointer press', (tester) async {
    var selections = 0;
    await pumpLockedElement(
      tester,
      DraggableLineChip(
        position: const Offset(20, 20),
        lengthMm: 40,
        scale: 1,
        templateWidthMm: 200,
        templateHeightMm: 200,
        templatePanToMmDelta: panDelta,
        onMoved: (_) {},
        onBoundsChanged: (_, __, ___, ____) {},
        onRotationChanged: (_) {},
        isLocked: true,
        onTap: () => selections++,
      ),
    );

    await tester.tapAt(const Offset(30, 20));
    expect(selections, 1);
  });

  testWidgets('locked shape selects with one pointer press', (tester) async {
    var selections = 0;
    await pumpLockedElement(
      tester,
      DraggableShapeChip(
        shapeType: 'rect',
        polygonSides: 4,
        position: const Offset(20, 20),
        widthMm: 20,
        heightMm: 20,
        scale: 1,
        templateWidthMm: 200,
        templateHeightMm: 200,
        templatePanToMmDelta: panDelta,
        onMoved: (_) {},
        onBoundsChanged: (_, __, ___, ____) {},
        onRotationChanged: (_) {},
        isLocked: true,
        onTap: () => selections++,
      ),
    );

    await tester.tapAt(const Offset(25, 25));
    expect(selections, 1);
  });
}
