import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/project_form.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/controllers.dart';

void main() {
  testWidgets(
    'edit form uses sections and exposes accession, not project IDs',
    (tester) async {
      final database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);
      await ProjectQuery(database).createProject(
        const ProjectCompanion(
          uuid: Value('project-uuid'),
          name: Value('Field Project'),
          accession: Value('ACC-1'),
          catalogNumberPrefix: Value('FP-'),
          currentCatalogNumber: Value(10),
          catalogNumberSuffix: Value('-M'),
        ),
      );
      final controller = ProjectFormCtrModel.fromData(
        await ProjectQuery(database).getProjectByUuid('project-uuid'),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp(
            home: Scaffold(
              body: ProjectForm(
                projectCtr: controller,
                projectUuid: 'project-uuid',
                isEditing: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FormSection), findsNWidgets(3));
      expect(find.text('Project details'), findsOneWidget);
      expect(find.text('Place and time'), findsOneWidget);
      expect(find.text('Project dates'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Accession'), findsOneWidget);
      final descriptionField = find.widgetWithText(
        TextFormField,
        'Project description',
      );
      await tester.enterText(
        descriptionField,
        List<String>.filled(161, 'x').join(),
      );
      expect(controller.descriptionCtr.text.length, 160);
      expect(
        find.textContaining('third-party collection management'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextField, 'Prefix'), findsNothing);
      expect(
        find.widgetWithText(TextField, 'Current catalog number'),
        findsNothing,
      );
      expect(find.widgetWithText(TextField, 'Suffix'), findsNothing);
    },
  );
}
