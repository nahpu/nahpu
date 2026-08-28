import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/coordinates.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/controllers.dart';

void main() {
  testWidgets('new coordinates use the first configured datum', (tester) async {
    final controller = CoordinateCtrModel.empty();
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(controller.dispose);
    addTearDown(database.close);
    await database.into(database.site).insert(const SiteCompanion());

    await tester.pumpWidget(
      _harness(
        controller: controller,
        database: database,
        configured: const ['Custom datum', 'WGS84'],
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.datumCtr.text, 'Custom datum');
    expect(find.text('Custom datum'), findsOneWidget);
  });

  testWidgets('editing preserves a legacy datum outside the configuration', (
    tester,
  ) async {
    final controller = CoordinateCtrModel.empty();
    controller.datumCtr.text = 'Legacy datum';
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(controller.dispose);
    addTearDown(database.close);
    await database.into(database.site).insert(const SiteCompanion());

    await tester.pumpWidget(
      _harness(
        controller: controller,
        database: database,
        configured: const ['WGS84'],
        isEditing: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.datumCtr.text, 'Legacy datum');
    expect(find.text('Legacy datum'), findsOneWidget);
  });

  testWidgets('an empty datum vocabulary leaves a new coordinate unselected', (
    tester,
  ) async {
    final controller = CoordinateCtrModel.empty();
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(controller.dispose);
    addTearDown(database.close);
    await database.into(database.site).insert(const SiteCompanion());

    await tester.pumpWidget(
      _harness(
        controller: controller,
        database: database,
        configured: const [],
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.datumCtr.text, isEmpty);
    expect(find.text('Specify the datum'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _harness({
  required CoordinateCtrModel controller,
  required Database database,
  required List<String> configured,
  bool isEditing = false,
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(database),
      userDefinedFieldProvider.overrideWith((ref, prefKey) async => configured),
      effectiveUserDefinedFieldProvider(
        datumPrefKey,
      ).overrideWith((ref) async => configured),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: CoordinateForms(
          coordinateId: isEditing ? 1 : null,
          siteId: 1,
          coordCtr: controller,
          isEditing: isEditing,
          disposeController: false,
          showActions: false,
        ),
      ),
    ),
  );
}
