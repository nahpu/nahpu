import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app-wide settings notifiers are written by one-off `ref.read`s from
/// transient screens — the create-project wizard reads a setting on one step
/// and writes it several awaits later, never watching it in between. These
/// tests pin the lifetime that makes such a write safe.
void main() {
  testWidgets('a screen that never watches can still write a setting', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: Scaffold(body: _OneOffWriter())),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('ok'), findsOneWidget);
    expect(prefs.getString(catalogFmtPrefKey), isNotNull);
  });

  test('settings notifiers survive a gap with no listeners', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        settingProvider.overrideWithValue(prefs),
        fieldIdModeNotifierProvider.overrideWith(_TestFieldIdMode.new),
        projectFieldIdAutoIncrementProvider.overrideWith(
          _TestAutoIncrement.new,
        ),
      ],
    );
    addTearDown(container.dispose);

    final catalogFmt = container.read(catalogFmtNotifierProvider.notifier);
    final fieldIdMode = container.read(fieldIdModeNotifierProvider.notifier);
    final autoIncrement = container.read(
      projectFieldIdAutoIncrementProvider.notifier,
    );
    // Long enough for an auto-disposing provider to be torn down.
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(
      identical(
        container.read(catalogFmtNotifierProvider.notifier),
        catalogFmt,
      ),
      isTrue,
    );
    expect(
      identical(
        container.read(fieldIdModeNotifierProvider.notifier),
        fieldIdMode,
      ),
      isTrue,
    );
    expect(
      identical(
        container.read(projectFieldIdAutoIncrementProvider.notifier),
        autoIncrement,
      ),
      isTrue,
    );
  });
}

/// Mirrors the create-project wizard: read the setting on one step, write it
/// after later awaits, without ever watching the provider.
class _OneOffWriter extends ConsumerStatefulWidget {
  const _OneOffWriter();

  @override
  ConsumerState<_OneOffWriter> createState() => _OneOffWriterState();
}

class _OneOffWriterState extends ConsumerState<_OneOffWriter> {
  String _result = 'idle';

  Future<void> _run() async {
    try {
      final current = await ref.read(catalogFmtNotifierProvider.future);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await ref
          .read(catalogFmtNotifierProvider.notifier)
          .set(
            current == CatalogFmt.mammals
                ? CatalogFmt.birds
                : CatalogFmt.mammals,
          );
      final setting = ref.read(catalogFmtNotifierProvider);
      if (setting.hasError) throw setting.error!;
      _result = 'ok';
    } catch (error) {
      _result = 'error: $error';
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: _run, child: Text(_result));
  }
}

class _TestFieldIdMode extends FieldIdModeNotifier {
  @override
  Future<FieldIdMode> build() async => FieldIdMode.personnel;
}

class _TestAutoIncrement extends ProjectFieldIdAutoIncrementNotifier {
  @override
  Future<bool> build() async => false;
}
