import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/record_qr_share_sheet.dart';
import 'package:nahpu/services/record_exchange/record_exchange_models.dart';

const _event = RecordExchangePayload(
  type: RecordExchangeType.event,
  data: {
    'event': {'idSuffix': '1'},
    'personnelAssignments': [
      {'personnelId': 'person-a', 'name': 'Person A'},
    ],
    'site': {
      'site': {'siteID': 'Camp A', 'leadStaffId': 'person-a'},
    },
    'personnel': [
      {'uuid': 'person-a', 'name': 'Person A', 'initial': 'PA'},
    ],
  },
);

void main() {
  Future<void> pumpSheet(
    WidgetTester tester, {
    RecordExchangePayload payload = _event,
    required bool Function(String data) fits,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<RecordQrShareChoice>(
              context: context,
              builder: (_) => Dialog(
                child: RecordQrShareSheet(
                  title: 'Event QR code',
                  payload: payload,
                  projectUuid: 'project-a',
                  fits: fits,
                ),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  bool switchValue(WidgetTester tester, String key) =>
      tester.widget<SwitchListTile>(find.byKey(ValueKey(key))).value;

  testWidgets('keeps full details when they fit', (tester) async {
    await pumpSheet(tester, fits: (_) => true);

    expect(switchValue(tester, 'record-qr-personnel'), isTrue);
    expect(switchValue(tester, 'record-qr-site'), isTrue);
    expect(find.text('Fits in a QR code.'), findsOneWidget);
    expect(find.textContaining('must already have'), findsNothing);
  });

  testWidgets('switches to references when full details do not fit', (
    tester,
  ) async {
    await pumpSheet(tester, fits: (data) => !data.contains('"personnel":'));

    expect(switchValue(tester, 'record-qr-personnel'), isFalse);
    expect(switchValue(tester, 'record-qr-site'), isTrue);
    expect(find.textContaining('must already have'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('record-qr-personnel')));
    await tester.pumpAndSettle();
    expect(find.text('Too large for a QR code.'), findsOneWidget);
    expect(find.byKey(const ValueKey('record-qr-export')), findsOneWidget);
  });

  testWidgets('show QR returns the chosen smaller payload', (tester) async {
    RecordQrShareChoice? choice;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              choice = await showDialog<RecordQrShareChoice>(
                context: context,
                builder: (_) => const Dialog(
                  child: RecordQrShareSheet(
                    title: 'Event QR code',
                    payload: _event,
                    projectUuid: 'project-a',
                  ),
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
    await tester.tap(find.byKey(const ValueKey('record-qr-site')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('record-qr-show')));
    await tester.pumpAndSettle();

    final payload = (choice! as ShowRecordQr).payload;
    expect(payload.siteRef, {'projectUuid': 'project-a', 'siteID': 'Camp A'});
    expect(payload.version, recordExchangeReferenceVersion);
  });

  testWidgets('offers a file export when nothing fits', (tester) async {
    await pumpSheet(tester, fits: (_) => false);

    expect(find.text('Too large for a QR code.'), findsOneWidget);
    expect(find.byKey(const ValueKey('record-qr-show')), findsNothing);
    expect(find.byKey(const ValueKey('record-qr-export')), findsOneWidget);
  });

  testWidgets('site switch is off-limits without a site code', (tester) async {
    const noCode = RecordExchangePayload(
      type: RecordExchangeType.event,
      data: {
        'event': {},
        'site': {'site': <String, dynamic>{}},
      },
    );
    await pumpSheet(tester, payload: noCode, fits: (_) => true);

    expect(find.byKey(const ValueKey('record-qr-personnel')), findsNothing);
    final site = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('record-qr-site')),
    );
    expect(site.onChanged, isNull);
    expect(find.textContaining('Add a site ID'), findsOneWidget);
  });

  test('only payloads with personnel or a site offer a choice', () {
    expect(RecordQrShareSheet.offersChoice(_event), isTrue);
    expect(
      RecordQrShareSheet.offersChoice(
        const RecordExchangePayload(
          type: RecordExchangeType.site,
          data: {'site': {}},
        ),
      ),
      isFalse,
    );
  });

  testWidgets('missing references list who and which site', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MissingRecordReferences(
            check: RecordReferenceCheck(
              missingPersonnel: [
                MissingPersonnelReference(
                  uuid: 'ghost',
                  name: 'Ghost',
                  initial: 'GH',
                ),
              ],
              siteCode: 'Camp A',
              siteStatus: SiteReferenceStatus.missing,
            ),
          ),
        ),
      ),
    );

    expect(find.text("Can't import yet"), findsOneWidget);
    expect(find.text('Ghost (GH)'), findsOneWidget);
    expect(find.text("Site Camp A isn't in this project."), findsOneWidget);
  });
}
