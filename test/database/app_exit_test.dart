import 'dart:ui' show AppExitResponse;

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/app_exit_handler.dart';
import 'package:nahpu/services/database/app_exit.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';

Database _memoryDb() =>
    Database.forTesting(DatabaseConnection(NativeDatabase.memory()));

/// Whether [db] still answers queries; a closed drift database throws.
Future<bool> _isOpen(Database db) async {
  try {
    await db.customSelect('SELECT 1').get();
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  group('AppExitCoordinator', () {
    test('closes the database and allows the exit', () async {
      final db = _memoryDb();
      expect(await _isOpen(db), isTrue);

      final response = await AppExitCoordinator().handleExitRequest(db);

      expect(response, AppExitResponse.exit);
      expect(await _isOpen(db), isFalse);
    });

    test('a guard that declines keeps the app and database open', () async {
      final db = _memoryDb();
      addTearDown(db.close);
      final calls = <String>[];
      final coordinator = AppExitCoordinator()
        ..addGuard(() async {
          calls.add('first');
          return false;
        })
        ..addGuard(() async {
          calls.add('second');
          return true;
        });

      final response = await coordinator.handleExitRequest(db);

      expect(response, AppExitResponse.cancel);
      expect(calls, ['first'], reason: 'stops at the first refusal');
      expect(await _isOpen(db), isTrue);
    });

    test('guards run before the close, and removed guards do not', () async {
      final db = _memoryDb();
      final seen = <bool>[];
      final coordinator = AppExitCoordinator();
      coordinator.addGuard(() async {
        seen.add(await _isOpen(db));
        return true;
      });
      final remove = coordinator.addGuard(() async => false);
      remove();

      final response = await coordinator.handleExitRequest(db);

      expect(response, AppExitResponse.exit);
      expect(seen, [true], reason: 'guards can still use the database');
      expect(await _isOpen(db), isFalse);
    });

    test('exits without a database', () async {
      expect(
        await AppExitCoordinator().handleExitRequest(null),
        AppExitResponse.exit,
      );
    });
  });

  group('AppExitHandler', () {
    testWidgets('a quit request closes the open database', (tester) async {
      final db = _memoryDb();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: AppExitHandler(
            child: Consumer(
              builder: (context, ref, _) {
                // Opens the database, as the app does once it starts.
                ref.watch(databaseProvider);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      // Drift connects on the first query; the running app always has.
      expect(await tester.runAsync(() => _isOpen(db)), isTrue);

      final response = await tester.runAsync(
        () => tester.binding.handleRequestAppExit(),
      );

      expect(response, AppExitResponse.exit);
      expect(await tester.runAsync(() => _isOpen(db)), isFalse);
    });

    testWidgets('a quit request does not open an unused database', (
      tester,
    ) async {
      var opened = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWith((ref) {
              opened++;
              return _memoryDb();
            }),
          ],
          child: const AppExitHandler(child: SizedBox()),
        ),
      );

      final response = await tester.runAsync(
        () => tester.binding.handleRequestAppExit(),
      );

      expect(response, AppExitResponse.exit);
      expect(opened, 0);
    });

    testWidgets('a declining guard cancels the quit', (tester) async {
      final db = _memoryDb();
      addTearDown(() => tester.runAsync(db.close));
      final coordinator = AppExitCoordinator()..addGuard(() async => false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            appExitCoordinatorProvider.overrideWithValue(coordinator),
          ],
          child: AppExitHandler(
            child: Consumer(
              builder: (context, ref, _) {
                ref.watch(databaseProvider);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      final response = await tester.runAsync(
        () => tester.binding.handleRequestAppExit(),
      );

      expect(response, AppExitResponse.cancel);
      expect(await tester.runAsync(() => _isOpen(db)), isTrue);
    });
  });
}
