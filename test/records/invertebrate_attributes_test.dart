import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/specimens/invertebrates/attributes.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  testWidgets(
    'invertebrate life stage, caste, and ecology precede morphometrics',
    (tester) async {
      final database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(
              uuid: Value('project-a'),
              name: Value('Project A'),
            ),
          );
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('invertebrate-a'),
              projectUuid: Value('project-a'),
              taxonGroup: Value('Invertebrates'),
            ),
          );
      await database
          .into(database.invertebrateAttribute)
          .insert(
            const InvertebrateAttributeCompanion(
              specimenUuid: Value('invertebrate-a'),
            ),
          );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            specimenSexVocabularyProvider.overrideWith(
              (ref) async => allowedSpecimenSexes,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 900,
                child: InvertebrateAttributeForms(
                  useHorizontalLayout: true,
                  specimenUuid: 'invertebrate-a',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ecological interactions'), findsOneWidget);
      expect(find.text('Environmental parameters'), findsNothing);
      expect(find.byType(SpecimenSexDropdown), findsOneWidget);
      expect(find.byType(LifeStageDropdown), findsOneWidget);
      expect(find.text('Caste'), findsOneWidget);
      final sectionLabel = tester.widget<Text>(
        find.text('Ecological interactions'),
      );
      expect(sectionLabel.textAlign, TextAlign.center);
      expect(
        sectionLabel.style,
        Theme.of(
          tester.element(find.text('Ecological interactions')),
        ).textTheme.titleMedium,
      );
      expect(
        tester.getTopLeft(find.byType(SpecimenSexDropdown)).dy,
        lessThan(tester.getTopLeft(find.text('Ecological interactions')).dy),
      );
      expect(find.text('Show specimen morphometrics'), findsOneWidget);
      expect(find.text('Head width (mm)'), findsNothing);
      expect(find.byType(SymbiontDetectionForm), findsNothing);

      await tester.ensureVisible(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.text('Specimen morphometrics'), findsOneWidget);
      expect(find.text('Head width (mm)'), findsOneWidget);
      expect(find.text('Body length (mm)'), findsOneWidget);
    },
  );

  testWidgets('saved invertebrate morphometrics reopen their section', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('invertebrate-a'),
            projectUuid: Value('project-a'),
            taxonGroup: Value('Invertebrates'),
          ),
        );
    await database
        .into(database.invertebrateAttribute)
        .insert(
          const InvertebrateAttributeCompanion(
            specimenUuid: Value('invertebrate-a'),
            bodyLength: Value(12.5),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          specimenSexVocabularyProvider.overrideWith(
            (ref) async => defaultSpecimenSexes,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: InvertebrateAttributeForms(
              useHorizontalLayout: false,
              specimenUuid: 'invertebrate-a',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Specimen morphometrics'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Body length (mm)'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });
}
