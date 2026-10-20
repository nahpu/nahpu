import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/specimens/shared/specimen_parts.dart';

void main() {
  Widget narrowTile(PartTitle title) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 160,
            child: ListTile(title: title, trailing: const Icon(Icons.edit)),
          ),
        ),
      ),
    );
  }

  testWidgets('long part title ellipsizes instead of overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(
      narrowTile(
        const PartTitle(
          partType: 'Skeleton',
          partCount: '1',
          barcodeID: '',
          preparator: 'Ari Contoh',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Skeleton'), findsOneWidget);
  });

  for (final count in [null, '']) {
    testWidgets('missing part count "$count" shows No count', (tester) async {
      await tester.pumpWidget(
        narrowTile(
          PartTitle(
            partType: 'Skin',
            partCount: count,
            barcodeID: '',
            preparator: null,
          ),
        ),
      );

      expect(find.textContaining('No count'), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);
    });
  }

  testWidgets('long part title with barcode does not overflow', (tester) async {
    await tester.pumpWidget(
      narrowTile(
        const PartTitle(
          partType: 'Skeleton',
          partCount: '1',
          barcodeID: 'ENHM-000123456',
          preparator: 'Ari Contoh',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
