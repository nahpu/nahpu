import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/db_settings.dart';
import 'package:nahpu/services/export/db_writer.dart';

void main() {
  testWidgets('database candidate dialog returns the selected root file', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              selected = await showDialog<String>(
                context: context,
                builder: (context) => const DatabaseCandidateDialog(
                  candidates: [
                    DbArchiveDatabaseCandidate(
                      archivePath: 'nahpu.sqlite3',
                      displayName: 'nahpu.sqlite3',
                    ),
                    DbArchiveDatabaseCandidate(
                      archivePath: 'legacy.db',
                      displayName: 'legacy.db',
                    ),
                  ],
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Choose database'), findsOneWidget);
    await tester.tap(find.text('legacy.db'));
    await tester.pumpAndSettle();

    expect(selected, 'legacy.db');
  });
}
