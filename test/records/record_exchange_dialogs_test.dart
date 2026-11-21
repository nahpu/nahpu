import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/record_exchange_dialogs.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/types/geography.dart';

void main() {
  testWidgets('event import lists existing sites by Site ID', (tester) async {
    await _pumpLauncher(
      tester,
      (context) => showLinkedSiteDialog(context: context, sites: _sites),
    );

    expect(find.text('TJHH-L1'), findsOneWidget);
    expect(find.text('TJHH-P1'), findsOneWidget);
    expect(find.text('Record'), findsNothing);
  });
}

const _sites = [
  SiteRecord(site: SiteData(id: 1, siteID: 'TJHH-L1')),
  SiteRecord(site: SiteData(id: 2, siteID: 'TJHH-P1')),
];

Future<void> _pumpLauncher(
  WidgetTester tester,
  Future<Object?> Function(BuildContext context) open,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: nahpuLocalizationsDelegates,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => open(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}
