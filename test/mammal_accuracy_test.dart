import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/specimens/mammalian/attributes.dart';
import 'package:nahpu/services/types/mammals.dart';

void main() {
  group('mammal accuracy storage', () {
    test('parses accurate values and preserves an existing remark', () {
      final details = parseMammalAccuracy(
        'Accurate',
        accuracySpecify: 'existing note',
        includeBatFields: false,
      );

      expect(details.status, MammalAccuracyStatus.accurate);
      expect(details.inaccurateFields, isEmpty);
      expect(details.remark, 'existing note');
      expect(serializeMammalAccuracy(details), 'accurate');
    });

    test('parses and canonically serializes keyed fields', () {
      final details = parseMammalAccuracy(
        'inaccurate:weight, tailLength,unknown,tailLength,forearm',
        accuracySpecify: 'damaged',
        includeBatFields: false,
      );

      expect(details.inaccurateFields, {'tailLength', 'forearm', 'weight'});
      expect(details.remark, 'damaged');
      expect(
        serializeMammalAccuracy(details),
        'inaccurate:tailLength,forearm,weight',
      );
    });

    test('requires at least one field when serializing inaccurate details', () {
      final details = MammalAccuracyDetails(
        status: MammalAccuracyStatus.inaccurate,
      );

      expect(() => serializeMammalAccuracy(details), throwsArgumentError);
    });

    test('translates tail cropped and pre-fills the legacy remark', () {
      final details = parseMammalAccuracy(
        'Tail cropped',
        includeBatFields: false,
      );

      expect(details.inaccurateFields, {'totalLength', 'tailLength', 'weight'});
      expect(details.remark, 'Tail cropped');
    });

    test('translates ear damaged and keeps accuracySpecify precedence', () {
      final details = parseMammalAccuracy(
        'Ear damaged',
        accuracySpecify: 'right ear torn',
        includeBatFields: false,
      );

      expect(details.inaccurateFields, {'earLength', 'weight'});
      expect(details.remark, 'right ear torn');
    });

    test('translates legacy all-measurement values using active fields', () {
      final coreDetails = parseMammalAccuracy(
        'Partially eaten',
        includeBatFields: false,
      );
      final batDetails = parseMammalAccuracy(
        'Other reason',
        includeBatFields: true,
      );
      final shortOtherDetails = parseMammalAccuracy(
        'Other',
        includeBatFields: false,
      );

      expect(coreDetails.inaccurateFields, coreMammalAccuracyFields.toSet());
      expect(
        coreDetails.inaccurateFields,
        containsAll(const ['totalLength', 'tailLength']),
      );
      expect(batDetails.inaccurateFields, {
        ...coreMammalAccuracyFields,
        ...batMammalAccuracyFields,
      });
      expect(
        batDetails.inaccurateFields,
        containsAll(const ['totalLength', 'tailLength']),
      );
      expect(
        shortOtherDetails.inaccurateFields,
        containsAll(const ['totalLength', 'tailLength']),
      );
    });

    test('supports older explicit measurement reasons', () {
      expect(
        parseMammalAccuracy(
          'Ear length inaccurate',
          includeBatFields: false,
        ).inaccurateFields,
        {'earLength'},
      );
      expect(
        parseMammalAccuracy(
          'Hind length inaccurate',
          includeBatFields: false,
        ).inaccurateFields,
        {'hindFootLength'},
      );
    });

    test('treats an unknown non-empty legacy value conservatively', () {
      final details = parseMammalAccuracy(
        'Damaged before measurement',
        includeBatFields: false,
      );

      expect(details.status, MammalAccuracyStatus.inaccurate);
      expect(details.inaccurateFields, coreMammalAccuracyFields.toSet());
      expect(details.remark, 'Damaged before measurement');
    });
  });

  group('mammal accuracy widgets', () {
    testWidgets('attribute panel shows the saved accuracy remark', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MammalAccuracyField(
              details: MammalAccuracyDetails(
                status: MammalAccuracyStatus.inaccurate,
                inaccurateFields: const ['tailLength'],
                remark: 'Tail cropped',
              ),
              onStatusChanged: (_) {},
              onEditPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('*Inaccurate: Tail length'), findsOneWidget);
      expect(find.text('Remark:\nTail cropped'), findsOneWidget);
    });

    testWidgets('numeric brackets mark inaccurate fields in the label', (
      tester,
    ) async {
      final controller = TextEditingController(text: '12.5');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonNumField(
              controller: controller,
              labelText: 'Length',
              hintText: 'Enter length',
              isLastField: true,
              isDouble: true,
              isBracketed: true,
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.labelText, 'Length*');
      expect(field.decoration?.prefixText, isNull);
      expect(field.decoration?.suffixText, isNull);
      expect(controller.text, '12.5');
    });

    testWidgets('dialog validates selection and omits inactive bat fields', (
      tester,
    ) async {
      MammalAccuracyDetails? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  result = await showDialog<MammalAccuracyDetails>(
                    context: context,
                    builder: (context) => MammalAccuracyDialog(
                      initialDetails: MammalAccuracyDetails(
                        status: MammalAccuracyStatus.inaccurate,
                      ),
                      includeBatFields: false,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Forearm length'), findsNothing);
      expect(find.text('Tibia length'), findsNothing);

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(
        find.text('Select at least one inaccurate measurement.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Total length'));
      await tester.enterText(
        find.widgetWithText(TextField, 'Accuracy remark'),
        'Tail cropped',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result?.inaccurateFields, {'totalLength'});
      expect(result?.remark, 'Tail cropped');
    });

    testWidgets('dialog includes bat measurements when active', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MammalAccuracyDialog(
            initialDetails: MammalAccuracyDetails(
              status: MammalAccuracyStatus.inaccurate,
            ),
            includeBatFields: true,
          ),
        ),
      );

      expect(find.text('Forearm length'), findsOneWidget);
      expect(find.text('Tibia length'), findsOneWidget);
    });

    testWidgets('dialog preserves a hidden bat selection', (tester) async {
      MammalAccuracyDetails? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  result = await showDialog<MammalAccuracyDetails>(
                    context: context,
                    builder: (context) => MammalAccuracyDialog(
                      initialDetails: MammalAccuracyDetails(
                        status: MammalAccuracyStatus.inaccurate,
                        inaccurateFields: const ['totalLength', 'forearm'],
                      ),
                      includeBatFields: false,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Forearm length'), findsNothing);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result?.inaccurateFields, {'totalLength', 'forearm'});
    });
  });
}
