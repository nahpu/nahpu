import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/narrative/narrative_form.dart';
import 'package:nahpu/screens/narrative/narrative_view.dart';
import 'package:nahpu/services/common/navigation_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    // The form's media components touch path_provider.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathChannel,
          (call) async => Directory.systemTemp.path,
        );
  });

  testWidgets('rebuilding the viewer keeps the controller and typed text', (
    tester,
  ) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);
    final pageNav = PageNavigation.init();
    addTearDown(pageNav.pageController.dispose);

    Future<void> pumpPages(String savedText) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: NarrativePages(
                // A fresh row each pump, as a refetch of the list would give.
                narrativeEntries: [NarrativeData(id: 1, narrative: savedText)],
                pageNav: pageNav,
                isNavButtonVisible: false,
                onPageChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    NarrativeFormCtrModel currentCtr() =>
        tester.widget<NarrativeForm>(find.byType(NarrativeForm)).narrativeCtr;

    await pumpPages('Saved');
    final ctr = currentCtr();
    expect(ctr.narrativeCtr.text, 'Saved');
    ctr.narrativeCtr.text = 'Typed but not saved';

    await pumpPages('Saved again');

    expect(currentCtr(), same(ctr));
    expect(currentCtr().narrativeCtr.text, 'Typed but not saved');

    // PageViewer's page-number overlay schedules a 5s timer.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));
  });
}
