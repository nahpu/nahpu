import 'dart:ui' show AppExitResponse;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/app_exit.dart';
import 'package:nahpu/services/providers/database.dart';

/// Handles the platform's request to quit: finishes registered exit work,
/// then closes the app database before the engine shuts down.
class AppExitHandler extends ConsumerStatefulWidget {
  const AppExitHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppExitHandler> createState() => _AppExitHandlerState();
}

class _AppExitHandlerState extends ConsumerState<AppExitHandler> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onExitRequested: _onExitRequested);
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<AppExitResponse> _onExitRequested() {
    // Never open the database just to close it.
    final database = ref.exists(databaseProvider)
        ? ref.read(databaseProvider)
        : null;
    return ref.read(appExitCoordinatorProvider).handleExitRequest(database);
  }
}
