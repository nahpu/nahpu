import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/specimens/shared/taxonomy.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';

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

  test('collection help describes the taxon field', () async {
    final document = await DocumentationRepository().loadInfo(
      InfoTopic.specimenGeneralRecord,
      DocsLanguage.english,
    );

    expect(document.title, 'Specimen general record');
    expect(document.markdown, contains('Choose the taxon'));
    expect(document.markdown, contains('`dwc:Occurrence`'));
  });
}
