import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/services/common/platform_services.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required ExportDestinationMode mode,
    Directory? selectedDir,
    VoidCallback? onSelectDir,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportDestinationField(
            mode: mode,
            selectedDir: selectedDir,
            onSelectDir: onSelectDir ?? () {},
            onClearDir: () {},
          ),
        ),
      ),
    );
  }

  group('choose directory', () {
    testWidgets('offers Browse and explains the fallback', (tester) async {
      await pumpField(tester, mode: ExportDestinationMode.chooseDirectory);

      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Select directory'), findsOneWidget);
      expect(find.textContaining('No folder chosen'), findsOneWidget);
    });

    testWidgets('drops the fallback hint once a folder is picked', (
      tester,
    ) async {
      await pumpField(
        tester,
        mode: ExportDestinationMode.chooseDirectory,
        selectedDir: Directory('/exports/records'),
      );

      expect(find.text('/exports/records'), findsOneWidget);
      expect(find.textContaining('No folder chosen'), findsNothing);
      expect(find.text('Browse'), findsNothing);
    });

    testWidgets('Browse reaches the caller', (tester) async {
      var browsed = 0;
      await pumpField(
        tester,
        mode: ExportDestinationMode.chooseDirectory,
        onSelectDir: () => browsed++,
      );

      await tester.tap(find.text('Browse'));

      expect(browsed, 1);
    });
  });

  group('temporary', () {
    testWidgets('offers no picker and says the file is temporary', (
      tester,
    ) async {
      await pumpField(tester, mode: ExportDestinationMode.temporary);

      expect(find.text('Browse'), findsNothing);
      expect(find.text('Select directory'), findsNothing);
      expect(find.text('Share after export'), findsOneWidget);
      expect(
        find.textContaining('only until your next export'),
        findsOneWidget,
      );
    });

    testWidgets('ignores a directory it was handed anyway', (tester) async {
      await pumpField(
        tester,
        mode: ExportDestinationMode.temporary,
        selectedDir: Directory('/exports/records'),
      );

      expect(find.text('/exports/records'), findsNothing);
      expect(find.text('Share after export'), findsOneWidget);
    });
  });
}
