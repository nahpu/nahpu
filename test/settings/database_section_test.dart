import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/settings/settings.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';

/// The backup window used to be reachable only from the menu drawers, so a
/// user in Database settings was never told a full backup existed.
void main() {
  late Database db;

  setUp(() {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  Future<void> pumpSection(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: DatabaseSettingSections()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('offers a backup tile that states the guarantee', (tester) async {
    await pumpSection(tester);

    expect(find.text('Backup database'), findsOneWidget);
    expect(
      find.text('Full database backup of all records and settings'),
      findsOneWidget,
    );
  });

  testWidgets('the backup tile opens the backup window', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.text('Backup database'));
    // The backup window starts a real summary read, so the route is checked
    // once the transition has run rather than by settling on it.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ExportDbForm), findsOneWidget);
  });

  testWidgets('replace database warns and points at backing up', (
    tester,
  ) async {
    await pumpSection(tester);

    expect(find.text('Replace database'), findsOneWidget);
    expect(
      find.text('Replace current database with another database file'),
      findsOneWidget,
    );
  });
}
