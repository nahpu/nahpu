import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/specimens/shared/weight_field.dart';

void main() {
  testWidgets('weight unit selection relabels without converting the value', (
    tester,
  ) async {
    final controller = TextEditingController(text: '12.5');
    addTearDown(controller.dispose);
    String? selectedUnit;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightField(
            controller: controller,
            unit: 'g',
            onChanged: (_) {},
            onUnitChanged: (unit) => selectedUnit = unit,
          ),
        ),
      ),
    );

    expect(find.text('g'), findsOneWidget);
    await tester.tap(find.byTooltip('Change weight unit'));
    await tester.pumpAndSettle();
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('lbs'), findsOneWidget);

    await tester.tap(find.text('kg'));
    await tester.pumpAndSettle();
    expect(selectedUnit, 'kg');
    expect(controller.text, '12.5');
  });
}
