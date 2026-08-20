import 'dart:ui';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_details.dart';
import 'package:nahpu/screens/specimens/shared/taxonomy.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/record_exchange/taxon_exchange_service.dart';

void main() {
  testWidgets('wide taxon details place QR beside classification', (
    tester,
  ) async {
    final fixture = await _fixture();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      fixture.scope(
        SizedBox(
          width: 600,
          height: 700,
          child: TaxonDetailsView(taxonData: fixture.taxon),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final qr = find.byType(TaxonQrIcon);
    expect(qr, findsOneWidget);
    expect(
      find.byKey(const ValueKey('taxon-classification-qr-row')),
      findsOneWidget,
    );
    final qrViewer = tester.widget<QrCodeViewer>(
      find.descendant(of: qr, matching: find.byType(QrCodeViewer)),
    );
    expect(qrViewer.maxSize, 96);
    expect(qrViewer.data, TaxonExchangeService.encodeQr(fixture.taxon));
    expect(find.byKey(const ValueKey('taxon-records-active')), findsOneWidget);
    expect(find.byKey(const ValueKey('taxon-records-all')), findsOneWidget);

    await tester.tap(qr);
    await tester.pumpAndSettle();
    expect(find.byType(QrCodeDialog), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('narrow taxon details place QR above classification', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final fixture = await _fixture();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      fixture.scope(
        SizedBox(
          width: 390,
          height: 700,
          child: TaxonDetailsView(taxonData: fixture.taxon),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('taxon-classification-qr-row')),
      findsNothing,
    );
    final qrRect = tester.getRect(find.byType(TaxonQrIcon));
    final classificationRect = tester.getRect(
      find.byKey(const ValueKey('taxon-classification-section')),
    );
    expect(qrRect.bottom, lessThanOrEqualTo(classificationRect.top));
  });

  testWidgets('specimen View details opens the desktop taxon dialog', (
    tester,
  ) async {
    final fixture = await _fixture();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      fixture.scope(
        TaxonomicForm(useHorizontalLayout: true, specimenUuid: 'specimen-a-1'),
      ),
    );
    await tester.pumpAndSettle();

    final viewDetails = find.text('View details');
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    final location = tester.getCenter(viewDetails);
    await mouse.addPointer(location: location);
    await tester.pump();
    await mouse.down(location);
    await mouse.up();
    await tester.pumpAndSettle();
    await mouse.removePointer();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TaxonDetailsView), findsOneWidget);
  });
}

Future<_TaxonDetailsFixture> _fixture() async {
  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  await database
      .into(database.project)
      .insert(
        const ProjectCompanion(
          uuid: Value('project-a'),
          name: Value('Project A'),
        ),
      );
  final taxonId = await database
      .into(database.taxonomy)
      .insert(
        const TaxonomyCompanion(
          taxonRank: Value('species'),
          taxonClass: Value('Mammalia'),
          taxonOrder: Value('Chiroptera'),
          taxonFamily: Value('Vespertilionidae'),
          genus: Value('Myotis'),
          specificEpithet: Value('lucifugus'),
          countryStatus: Value('Protected'),
        ),
      );
  await database.batch((batch) {
    batch.insertAll(database.specimen, [
      SpecimenCompanion(
        uuid: const Value('specimen-a-1'),
        projectUuid: const Value('project-a'),
        speciesID: Value(taxonId),
      ),
    ]);
  });
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(database)],
  );
  container.read(projectUuidProvider.notifier).updateProjectUuid('project-a');
  return _TaxonDetailsFixture(
    database: database,
    container: container,
    taxon: await database.select(database.taxonomy).getSingle(),
  );
}

class _TaxonDetailsFixture {
  _TaxonDetailsFixture({
    required this.database,
    required this.container,
    required this.taxon,
  });

  final Database database;
  final ProviderContainer container;
  final TaxonomyData taxon;

  Widget scope(Widget child) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  void dispose() {
    container.dispose();
    database.close();
  }
}
