import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/specimens/shared/parasite_forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';

void main() {
  testWidgets('parasite form saves its displayed UUID with the record', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('project'), name: Value('Test')),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('specimen'),
            projectUuid: Value('project'),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          userDefinedFieldProvider.overrideWith2(
            (prefKey) => _EmptyUserDefinedField(prefKey),
          ),
        ],
        child: const MaterialApp(home: NewParasite(specimenUuid: 'specimen')),
      ),
    );
    await tester.pumpAndSettle();

    final uuidText = tester.widget<SelectableText>(find.byType(SelectableText));
    final displayedUuid = uuidText.data!.replaceFirst('UUID: ', '');
    expect(
      displayedUuid,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(await database.select(database.parasite).get(), isEmpty);
    expect(find.text('Set options in Specimen settings'), findsWidgets);

    final idMenu = find.byWidgetPredicate(
      (widget) => widget is PopupMenuButton,
    );
    await tester.tap(idMenu.first);
    await tester.pumpAndSettle();
    expect(find.text('Generate UUID'), findsNothing);
    expect(find.text('New number'), findsOneWidget);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Add'));
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final parasite = await database.select(database.parasite).getSingle();
    expect(parasite.parasiteUuid, displayedUuid);
  });
}

class _EmptyUserDefinedField extends UserDefinedField {
  _EmptyUserDefinedField(super.prefKey);

  @override
  Future<List<String>> build() async => const [];
}
