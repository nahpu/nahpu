import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/specimens/avian/attributes.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/birds.dart';
import 'package:nahpu/services/types/controllers.dart';

void main() {
  test('bird encoded labels keep stable database meanings', () {
    expect(fatCategoryList.first, 'None');
    expect(ovaryAppearanceList[1], 'Ova minute');
    expect(ovaryAppearanceList[2], 'At least one ovum ≥ 1 mm dia.');
    expect(birdLabelForCode(fatCategoryList, 99), 'Stored code 99');
  });

  test('bird controller maps canonical toe and beak color columns', () {
    const data = BirdAttributeData(
      specimenUuid: 'bird',
      toeColor: 'Black',
      toeHex: '#000000',
      maxillaColor: 'Orange',
      mandibleColor: 'Yellow',
    );
    final controller = BirdAttributeCtrModel.fromData(data);
    addTearDown(controller.dispose);

    expect(controller.toeCtr.text, 'Black');
    expect(controller.maxillaCtr.text, 'Orange');
    expect(controller.mandibleCtr.text, 'Yellow');
  });

  testWidgets('saved wing and tail molt details remain visible', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final controller = BirdAttributeCtrModel.empty()
      ..wingIsMoltCtr = 1
      ..wingMoltCtr.text = 'Primary 5 growing'
      ..tailIsMoltCtr = 1
      ..tailMoltCtr.text = 'Rectrix molt';
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(
            body: MoltingForm(
              specimenUuid: 'bird',
              ctr: controller,
              useHorizontalLayout: false,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CommonTextField && widget.labelText == 'Wing molt',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CommonTextField && widget.labelText == 'Tail molt',
      ),
      findsOneWidget,
    );
    expect(find.text('Primary 5 growing'), findsOneWidget);
    expect(find.text('Rectrix molt'), findsOneWidget);
  });
}
