import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/forms/site_name_display.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/site_fixture.dart';

void main() {
  late Database database;

  late SharedPreferences preferences;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  tearDown(() => database.close());

  testWidgets('shows a read-only site name with label and content hierarchy', (
    tester,
  ) async {
    final siteId = await insertSiteWithGeography(
      database,
      country: ' Indonesia ',
      stateProvince: 'West Java',
      county: '',
      municipality: 'Bogor',
      locality: 'Cibodas',
    );

    await tester.pumpWidget(
      _harness(database, siteId: siteId, preferences: preferences),
    );
    await tester.pumpAndSettle();

    expect(find.text('Site name'), findsOneWidget);
    expect(find.text('Indonesia, West Java, Bogor, Cibodas'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    final context = tester.element(find.byType(SiteNameDisplay));
    final theme = Theme.of(context);
    final label = tester.widget<Text>(find.text('Site name'));
    final value = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(label.style?.fontSize, theme.textTheme.labelMedium?.fontSize);
    expect(label.style?.color, theme.colorScheme.onSurfaceVariant);
    expect(value.style, theme.textTheme.bodyLarge);
  });

  testWidgets('hides when a site is not selected or has no name content', (
    tester,
  ) async {
    final emptySiteId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('')));

    await tester.pumpWidget(
      _harness(database, siteId: null, preferences: preferences),
    );
    await tester.pumpAndSettle();
    expect(find.text('Site name'), findsNothing);

    await tester.pumpWidget(
      _harness(database, siteId: 999, preferences: preferences),
    );
    await tester.pumpAndSettle();
    expect(find.text('Site name'), findsNothing);

    await tester.pumpWidget(
      _harness(database, siteId: emptySiteId, preferences: preferences),
    );
    await tester.pumpAndSettle();
    expect(find.text('Site name'), findsNothing);
    expect(find.byType(SelectableText), findsNothing);
  });
}

Widget _harness(
  Database database, {
  required int? siteId,
  required SharedPreferences preferences,
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(database),
      // The site list reads its sort from shared preferences.
      settingProvider.overrideWithValue(preferences),
    ],
    child: MaterialApp(
      home: Scaffold(body: SiteNameDisplay(siteId: siteId)),
    ),
  );
}
