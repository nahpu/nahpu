import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/specimens/shared/specimen_parts.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/controllers.dart';

void main() {
  testWidgets('specimen part IDs and fields use expandable sections', (
    tester,
  ) async {
    final database = await _pumpPartForm(
      tester,
      controller: PartFormCtrModel.empty(),
    );
    addTearDown(database.close);

    expect(find.text('IDs'), findsOneWidget);
    expect(find.text('Specimen UUID: specimen'), findsOneWidget);
    expect(find.text('Additional Part ID'), findsNothing);
    expect(find.text('Preparation'), findsOneWidget);
    expect(find.text('Sampling'), findsOneWidget);
    expect(find.text('Curation'), findsNothing);
    expect(find.text('Additional treatment'), findsNothing);
    expect(find.text('Preparator'), findsNothing);

    final showMore = find.text('Show more');
    await tester.ensureVisible(showMore);
    await tester.tap(showMore);
    await tester.pumpAndSettle();

    expect(find.text('Curation'), findsOneWidget);
    _expectFieldInSection(tester, 'Additional treatment', 'Preparation');
    _expectFieldInSection(tester, 'Preparator', 'Sampling');
    _expectFieldInSection(tester, 'Museum permanent', 'Curation');

    final showLess = find.text('Show less');
    await tester.ensureVisible(showLess);
    await tester.tap(showLess);
    await tester.pumpAndSettle();

    expect(find.text('Curation'), findsNothing);
    expect(find.text('Additional treatment'), findsNothing);
  });

  testWidgets('populated specimen part details remain visible when collapsed', (
    tester,
  ) async {
    final controller = PartFormCtrModel.empty();
    controller.dateTakenCtr.date = '2026-07-01';
    controller.pmiCtr.text = '1:30';
    controller.museumPermanentCtr.text = 'USNM';
    final database = await _pumpPartForm(tester, controller: controller);
    addTearDown(database.close);

    expect(find.text('Show more'), findsOneWidget);
    _expectFieldInSection(tester, 'Date taken', 'Sampling');
    _expectFieldInSection(tester, 'PMI', 'Sampling');
    _expectFieldInSection(tester, 'Museum permanent', 'Curation');
    expect(find.text('Museum loan'), findsNothing);
    expect(find.text('Remarks'), findsNothing);
  });
}

Future<Database> _pumpPartForm(
  WidgetTester tester, {
  required PartFormCtrModel controller,
}) async {
  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        userDefinedFieldProvider.overrideWith2(
          (prefKey) => _EmptyUserDefinedField(prefKey),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: PartForm(
            specimenUuid: 'specimen',
            specimenPartId: null,
            partCtr: controller,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return database;
}

void _expectFieldInSection(
  WidgetTester tester,
  String fieldLabel,
  String sectionTitle,
) {
  final sections = tester.widgetList<FormSection>(
    find.ancestor(
      of: find.text(fieldLabel),
      matching: find.byType(FormSection),
    ),
  );
  expect(sections.map((section) => section.title), contains(sectionTitle));
}

class _EmptyUserDefinedField extends UserDefinedField {
  _EmptyUserDefinedField(super.prefKey);

  @override
  Future<List<String>> build() async => const [];
}
