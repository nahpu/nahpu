import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/preset_export_dialog.dart';
import 'package:nahpu/services/settings/preset_transfer_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temp;
  late _FakeTransfer transfer;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('nahpu-preset-dialog-');
    transfer = _FakeTransfer(temp);
  });

  tearDown(() {
    if (temp.existsSync()) temp.deleteSync(recursive: true);
  });

  PresetExportRequest request({
    List<String> linked = const [],
    List<bool>? calls,
  }) {
    return PresetExportRequest(
      title: 'Export print layouts',
      summary: 'Booklet',
      defaultFileStem: 'preset_Booklet',
      linkedTemplateNames: linked,
      encode: ({required includeLinkedTemplates}) async {
        calls?.add(includeLinkedTemplates);
        return '{"templates":$includeLinkedTemplates}';
      },
    );
  }

  Future<void> open(
    WidgetTester tester,
    PresetExportRequest request, {
    Size size = const Size(1000, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPresetExportDialog(
                context: context,
                request: request,
                service: transfer,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('uses a bottom sheet on compact screens', (tester) async {
    await open(tester, request(), size: const Size(500, 900));

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.widgetWithIcon(IconButton, Icons.close), findsNothing);
  });

  testWidgets('fills in the file name and hides the template switch', (
    tester,
  ) async {
    await open(tester, request());

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Export print layouts'), findsOneWidget);
    expect(find.text('preset_Booklet'), findsOneWidget);
    expect(find.text('Include linked templates'), findsNothing);
  });

  testWidgets('includes linked templates until switched off, then shares', (
    tester,
  ) async {
    final calls = <bool>[];
    await open(tester, request(linked: ['Cover', 'Site'], calls: calls));

    final toggle = find.widgetWithText(
      SwitchListTile,
      'Include linked templates',
    );
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    expect(find.text('2 templates: Cover, Site'), findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    final export = find.text('Export');
    await tester.ensureVisible(export);
    await tester.tap(export);
    await tester.pumpAndSettle();

    expect(calls, [false]);
    expect(transfer.saved, [('{"templates":false}', 'preset_Booklet')]);
    expect(find.text('Share'), findsOneWidget);
  });
}

class _FakeTransfer extends PresetTransferService {
  _FakeTransfer(this.root);

  final Directory root;
  final saved = <(String, String)>[];

  @override
  Future<File> save({
    required String content,
    required String fileStem,
    Directory? directory,
  }) async {
    saved.add((content, fileStem));
    return File(p.join(root.path, '$fileStem.json'))
      ..writeAsStringSync(content);
  }
}
