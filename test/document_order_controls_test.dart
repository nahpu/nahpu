import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/document/document_settings_pane.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/document_selection.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

void main() {
  late Database database;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => database.close());

  testWidgets('preset editor shows block ordering without expansion', (
    tester,
  ) async {
    await _pumpSection(
      tester,
      database: database,
      showBlockOrderingImmediately: true,
    );

    expect(find.text('Order by'), findsOneWidget);
    expect(find.text('Direction'), findsOneWidget);
  });

  testWidgets('export block hides ordering until Show more is opened', (
    tester,
  ) async {
    await _pumpSection(
      tester,
      database: database,
      showBlockOrderingImmediately: false,
    );

    expect(find.text('Order by'), findsNothing);
    final blockCard = find.ancestor(
      of: find.text('Block #1'),
      matching: find.byType(Card),
    );
    final showMore = find.descendant(
      of: blockCard,
      matching: find.text('Show more'),
    );
    await tester.tap(showMore);
    await tester.pumpAndSettle();

    expect(find.text('Order by'), findsOneWidget);
  });
}

Future<void> _pumpSection(
  WidgetTester tester, {
  required Database database,
  required bool showBlockOrderingImmediately,
}) async {
  final layout = rust_config.DocumentLayoutPreset(
    name: 'Test',
    layoutType: 'WholePage',
    pageSizeKey: 'Letter',
    pageOrientation: 'portrait',
    pagePadTopMm: 8,
    pagePadLeftMm: 8,
    pagePadRightMm: 8,
    pagePadBottomMm: 8,
    blocks: const [
      rust_config.DocumentLayoutBlock(
        templateName: 'template',
        templateCount: 1,
        rows: 1,
        cols: 1,
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
        pageBreakAfter: false,
        sortDirection: rust_config.DocumentSortDirection.ascending,
      ),
    ],
    fillPage: false,
    multiBlockMode: 'Continuous',
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        templateRecordTypeProvider.overrideWith(
          (ref, templateName) async => RecordType.specimenRecord,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DocumentLayoutSection(
              layout: layout,
              setupNames: const [],
              selectedSetupName: 'Test',
              templateNames: const ['template'],
              onLayoutChanged: (_) {},
              onSetupSelected: (_) {},
              showProfileDropdown: false,
              showBlockOverrideToggle: false,
              showBlockOrderingImmediately: showBlockOrderingImmediately,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
