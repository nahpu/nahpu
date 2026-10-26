import 'dart:ui' show AppExitResponse;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';

/// Runs before the app quits. Returns false to keep the app open, such as
/// when the user cancels leaving unsaved edits.
typedef AppExitGuard = Future<bool> Function();

/// Coordinates the work the app must finish before it quits.
///
/// The app database is closed last, after every guard agrees to quit.
/// Closing it explicitly matters: otherwise SQLite statements are left for
/// the Dart VM to clean up while the engine shuts down, in no fixed order,
/// which has crashed the app on quit (`sqlite3_finalize` on freed memory).
class AppExitCoordinator {
  final List<AppExitGuard> _guards = [];

  /// Adds [guard] and returns a callback that removes it.
  VoidCallback addGuard(AppExitGuard guard) {
    _guards.add(guard);
    return () => _guards.remove(guard);
  }

  /// Runs the guards in order, then closes [database] when all of them
  /// allow the exit. Pass null when the database was never opened.
  Future<AppExitResponse> handleExitRequest(Database? database) async {
    for (final guard in List.of(_guards)) {
      if (!await guard()) return AppExitResponse.cancel;
    }
    if (database != null) {
      try {
        await database.close();
      } catch (e) {
        // A failed close must not stop the app from quitting.
        debugPrint('Closing the database on exit failed: $e');
      }
    }
    return AppExitResponse.exit;
  }
}

final appExitCoordinatorProvider = Provider<AppExitCoordinator>(
  (ref) => AppExitCoordinator(),
);
