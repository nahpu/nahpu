import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/database/db_settings.dart';
import 'package:nahpu/services/export/db_writer.dart';
import 'package:nahpu/services/types/export.dart';

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

  test('the pre-replace safety backup is a full archive, not a bare db', () {
    // The snapshot taken before a restore used to be a `.sqlite3` holding no
    // media at all, which made the safety net under the most destructive
    // operation in the app useless for photos.
    expect(
      DbArchiveFormat.values,
      contains(preReplaceBackupFormat),
      reason: 'the safety backup must be one of the archive formats',
    );
    expect(preReplaceBackupFormat.extension, anyOf('zip', 'tar.gz'));
  });

  test('a restore reports a stage for the safety backup', () {
    // Writing a full archive can take minutes, so it needs its own labelled
    // stage rather than hiding inside "Replace database".
    final labels = DbWriter.restorePhases.map((step) => step.label).toList();
    expect(labels, contains('Back up current data'));
    expect(
      labels.indexOf('Back up current data'),
      lessThan(labels.indexOf('Replace database')),
    );
  });
}
