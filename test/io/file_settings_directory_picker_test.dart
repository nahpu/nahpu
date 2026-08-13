import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';

void main() {
  testWidgets('uses the outlined Browse action until a directory is selected',
      (tester) async {
    var browseCount = 0;
    var clearCount = 0;

    Future<void> pumpPicker(Directory? selectedDir) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileSettingsDirectoryPicker(
              selectedDir: selectedDir,
              onSelectDir: () => browseCount++,
              onClearDir: () => clearCount++,
            ),
          ),
        ),
      );
    }

    await pumpPicker(null);
    expect(find.text('Select directory'), findsOneWidget);
    expect(find.text('Browse'), findsOneWidget);
    await tester.tap(find.text('Browse'));
    expect(browseCount, 1);

    await pumpPicker(Directory('/tmp/exports'));
    expect(find.text('/tmp/exports'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear directory'));
    expect(clearCount, 1);
  });
}
