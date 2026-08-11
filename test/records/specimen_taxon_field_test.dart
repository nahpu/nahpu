import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/specimens/shared/general_records.dart';
import 'package:nahpu/screens/specimens/shared/taxonomy.dart';

void main() {
  testWidgets('specimen taxon fields use taxon terminology', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SpeciesAutoComplete(
                  specimenUuid: 'specimen',
                  speciesCtr: controller,
                  options: const [],
                ),
                const DisabledSpeciesField(),
              ],
            ),
          ),
        ),
      ),
    );

    final fields = tester.widgetList<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(fields, hasLength(2));
    expect(fields.first.decoration.labelText, 'Taxon');
    expect(fields.first.decoration.hintText, 'Type taxon name');
    expect(fields.last.decoration.labelText, 'Taxon');
    expect(fields.last.decoration.hintText, 'Enter taxon');
    expect(find.byTooltip('Type taxon name and select from list'), findsOne);
    expect(find.text('Species'), findsNothing);
  });

  testWidgets('collection help describes the taxon field', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CollRecordInfoContent())),
    );

    final taxonHelp = tester
        .widgetList<InfoContent>(find.byType(InfoContent))
        .singleWhere((content) => content.header == 'Taxon field');
    expect(taxonHelp.content, contains('Type the taxon name'));
    expect(taxonHelp.content, contains('The taxon field will be disabled'));
  });
}
