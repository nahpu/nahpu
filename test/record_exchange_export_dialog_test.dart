import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/dialogs/record_exchange_dialogs.dart';
import 'package:nahpu/services/record_exchange/record_exchange_service.dart';

void main() {
  testWidgets('record export changes from Export to Share', (tester) async {
    String? exportedFileStem;
    Directory? exportedDestinationDirectory;
    RecordArchiveFormat? exportedArchiveFormat;

    const payload = RecordExchangePayload(
      type: RecordExchangeType.site,
      data: {
        'site': {'siteID': 'Ridge 01'},
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordExportDialog(
            payload: payload,
            onExport:
                ({
                  required fileStem,
                  required destinationDirectory,
                  required archiveFormat,
                }) async {
                  exportedFileStem = fileStem;
                  exportedDestinationDirectory = destinationDirectory;
                  exportedArchiveFormat = archiveFormat;
                  return File('/tmp/nahpu-site.json');
                },
          ),
        ),
      ),
    );

    expect(find.text('Export'), findsOneWidget);
    expect(find.text('JSON (.json)'), findsOneWidget);
    expect(find.text('Ridge 01'), findsOneWidget);

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(find.text('Share'), findsOneWidget);
    expect(exportedFileStem, 'Ridge 01');
    expect(exportedDestinationDirectory, isNull);
    expect(exportedArchiveFormat, isNull);
  });

  testWidgets('specimen media export offers archive formats', (tester) async {
    const payload = RecordExchangePayload(
      type: RecordExchangeType.specimen,
      data: {
        'specimen': {'fieldNumber': 'SP-01'},
        'media': [
          {'mediaId': 1},
        ],
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordExportDialog(
            payload: payload,
            onExport:
                ({
                  required fileStem,
                  required destinationDirectory,
                  required archiveFormat,
                }) async => File('/tmp/nahpu-specimen.zip'),
          ),
        ),
      ),
    );

    expect(find.text('Archive format'), findsOneWidget);
    expect(find.text('ZIP (.zip)'), findsOneWidget);
    expect(find.text('TAR.GZ (.tar.gz)'), findsNothing);

    await tester.tap(find.text('ZIP (.zip)'));
    await tester.pumpAndSettle();
    expect(find.text('TAR.GZ (.tar.gz)'), findsOneWidget);
  });
}
