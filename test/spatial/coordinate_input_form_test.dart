import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/coordinates.dart';
import 'package:nahpu/services/controlled_vocabulary_services.dart';
import 'package:nahpu/services/coordinate_input.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/src/rust/api/gis.dart';
import 'package:nahpu/src/rust/frb_generated.dart';

void main() {
  setUpAll(() async {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final dylibPath = Platform.isMacOS
          ? 'rust/target/debug/librust_lib_nahpu.dylib'
          : Platform.isWindows
          ? 'rust/target/debug/rust_lib_nahpu.dll'
          : 'rust/target/debug/librust_lib_nahpu.so';
      await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
    } else {
      await RustLib.init();
    }
  });

  testWidgets('DDM and DMS use numeric component fields without directions', (
    tester,
  ) async {
    final resources = await _pumpCoordinateForm(tester);
    addTearDown(resources.dispose);

    await _selectFormat(tester, 'Degrees decimal minutes (DDM)');

    expect(_fields('Degree'), findsNWidgets(2));
    expect(_fields('Minute'), findsNWidgets(2));
    expect(_fields('Second'), findsNothing);
    expect(find.text('Latitude'), findsOneWidget);
    expect(find.text('Longitude'), findsOneWidget);
    expect(find.text('Latitude degrees'), findsNothing);
    expect(find.text('Longitude decimal minutes'), findsNothing);
    expect(resources.controller.latitudeAngularCtr.direction, isNull);
    expect(resources.controller.longitudeAngularCtr.direction, isNull);

    final controlWidth = tester.getSize(_field('Degree')).width;
    expect(tester.getSize(_field('Minute')).width, controlWidth);
    final directions = find.byType(SegmentedButton<AngularCoordinateDirection>);
    expect(directions, findsNWidgets(2));
    expect(tester.getSize(directions.first).width, controlWidth);

    await _selectFormat(tester, 'Degrees minutes seconds (DMS)');

    expect(_fields('Second'), findsNWidgets(2));
    expect(_fields('Minute'), findsNWidgets(2));
  });

  testWidgets(
    'format switching can be cancelled before populated input clears',
    (tester) async {
      final resources = await _pumpCoordinateForm(tester);
      addTearDown(resources.dispose);
      await _selectFormat(tester, 'Degrees decimal minutes (DDM)');
      await tester.enterText(_field('Degree'), '41');

      await _selectFormat(tester, 'Degrees minutes seconds (DMS)');
      expect(find.text('Change coordinate format?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(_fields('Minute'), findsNWidgets(2));
      expect(resources.controller.latitudeAngularCtr.degreesCtr.text, '41');

      await _selectFormat(tester, 'Degrees minutes seconds (DMS)');
      await tester.tap(find.text('Clear and switch'));
      await tester.pumpAndSettle();

      expect(_fields('Second'), findsNWidgets(2));
      expect(resources.controller.latitudeAngularCtr.degreesCtr.text, isEmpty);
    },
  );

  testWidgets('missing DDM directions show inline errors', (tester) async {
    final resources = await _pumpCoordinateForm(tester, withFormKey: true);
    addTearDown(resources.dispose);
    await _selectFormat(tester, 'Degrees decimal minutes (DDM)');
    await tester.enterText(_field('Degree'), '41');
    await tester.enterText(_field('Minute'), '24.2');
    await tester.enterText(_field('Degree', index: 1), '123');
    await tester.enterText(_field('Minute', index: 1), '15.5');

    await tester.runAsync(resources.formKey!.currentState!.submit);
    await tester.pumpAndSettle();

    expect(find.text('Select N or S for latitude'), findsOneWidget);
    expect(find.text('Select E or W for longitude'), findsOneWidget);
    expect(
      await resources.database.select(resources.database.coordinate).get(),
      isEmpty,
    );
  });

  testWidgets('DDM component entry stores decimal and verbatim coordinates', (
    tester,
  ) async {
    final resources = await _pumpCoordinateForm(tester, withFormKey: true);
    addTearDown(resources.dispose);
    await _selectFormat(tester, 'Degrees decimal minutes (DDM)');
    await tester.enterText(_field('Degree'), '41');
    await tester.enterText(_field('Minute'), '24.2028');
    await tester.enterText(_field('Degree', index: 1), '123');
    await tester.enterText(_field('Minute', index: 1), '15.500');
    await _selectDirection(tester, 'N');
    await _selectDirection(tester, 'W');

    await tester.runAsync(resources.formKey!.currentState!.submit);
    await tester.pumpAndSettle();

    final coordinate = await resources.database
        .select(resources.database.coordinate)
        .getSingle();
    expect(coordinate.verbatimLatitude, "41° 24.2028' N");
    expect(coordinate.verbatimLongitude, "123° 15.500' W");
    expect(coordinate.verbatimCoordinateSystem, 'degrees decimal minutes');
    expect(coordinate.decimalLatitude, closeTo(41.40338, 0.0000001));
    expect(coordinate.decimalLongitude, closeTo(-123.258333, 0.000001));
  });

  testWidgets('DMS component entry stores southern and western coordinates', (
    tester,
  ) async {
    final resources = await _pumpCoordinateForm(tester, withFormKey: true);
    addTearDown(resources.dispose);
    await _selectFormat(tester, 'Degrees minutes seconds (DMS)');
    await tester.enterText(_field('Degree'), '12');
    await tester.enterText(_field('Minute'), '03');
    await tester.enterText(_field('Second'), '04.250');
    await tester.enterText(_field('Degree', index: 1), '45');
    await tester.enterText(_field('Minute', index: 1), '30');
    await tester.enterText(_field('Second', index: 1), '0');
    await _selectDirection(tester, 'S');
    await _selectDirection(tester, 'W');

    await tester.runAsync(resources.formKey!.currentState!.submit);
    await tester.pumpAndSettle();

    final coordinate = await resources.database
        .select(resources.database.coordinate)
        .getSingle();
    expect(coordinate.verbatimLatitude, '12° 03\' 04.250" S');
    expect(coordinate.verbatimLongitude, '45° 30\' 0" W');
    expect(coordinate.verbatimCoordinateSystem, 'degrees minutes seconds');
    expect(coordinate.decimalLatitude, closeTo(-12.0511805, 0.000001));
    expect(coordinate.decimalLongitude, closeTo(-45.5, 0.000001));
  });

  testWidgets('altered verbatim data warns and requires re-entry', (
    tester,
  ) async {
    final controller = CoordinateCtrModel.fromData(
      const CoordinateData(
        id: 1,
        siteID: 1,
        decimalLatitude: 41.4,
        decimalLongitude: -123.2,
        verbatimLatitude: 'externally changed latitude',
        verbatimLongitude: "123° 12' W",
        verbatimCoordinateSystem: 'degrees decimal minutes',
      ),
    );
    final resources = await _pumpCoordinateForm(
      tester,
      controller: controller,
      isEditing: true,
    );
    addTearDown(resources.dispose);

    expect(find.textContaining('changed outside NAHPU'), findsOneWidget);
    expect(find.textContaining('externally changed latitude'), findsOneWidget);
    expect(_fields('Degree'), findsNWidgets(2));
    expect(controller.latitudeAngularCtr.degreesCtr.text, isEmpty);
  });

  testWidgets('Import shows supported formats above the initial actions', (
    tester,
  ) async {
    final resources = await _pumpNewCoordinate(tester);
    addTearDown(resources.dispose);

    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Supported files: GeoJSON/JSON, KML, zipped Shapefile, and GPX.',
      ),
      findsOneWidget,
    );
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Select coordinate file'), findsOneWidget);
  });
}

Finder _fields(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
  description: 'TextField with label $label',
);

Finder _field(String label, {int index = 0}) => _fields(label).at(index);

Future<void> _selectFormat(WidgetTester tester, String label) async {
  await tester.tap(
    find.byType(DropdownButtonFormField<CoordinateInputFormat>).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _selectDirection(WidgetTester tester, String direction) async {
  final finder = find.text(direction);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<_CoordinateTestResources> _pumpCoordinateForm(
  WidgetTester tester, {
  CoordinateCtrModel? controller,
  bool isEditing = false,
  bool withFormKey = false,
}) async {
  tester.view.physicalSize = const Size(500, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final coordinateController = controller ?? CoordinateCtrModel.empty();
  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  await database.into(database.site).insert(const SiteCompanion());
  final formKey = withFormKey ? GlobalKey<CoordinateFormsState>() : null;
  await tester.pumpWidget(
    _harness(
      database: database,
      child: Scaffold(
        body: CoordinateForms(
          key: formKey,
          coordinateId: isEditing ? 1 : null,
          siteId: 1,
          coordCtr: coordinateController,
          isEditing: isEditing,
          disposeController: false,
          showActions: false,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _CoordinateTestResources(
    controller: coordinateController,
    database: database,
    formKey: formKey,
  );
}

Future<_CoordinateTestResources> _pumpNewCoordinate(WidgetTester tester) async {
  tester.view.physicalSize = const Size(500, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final controller = CoordinateCtrModel.empty();
  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  await database.into(database.site).insert(const SiteCompanion());
  await tester.pumpWidget(
    _harness(
      database: database,
      child: NewCoordinate(siteId: 1, coordCtr: controller),
    ),
  );
  await tester.pumpAndSettle();
  return _CoordinateTestResources(
    controller: controller,
    database: database,
    disposeController: false,
  );
}

Widget _harness({required Database database, required Widget child}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(database),
      userDefinedFieldProvider.overrideWith(
        (ref, prefKey) async => const ['WGS84'],
      ),
      effectiveUserDefinedFieldProvider(
        datumPrefKey,
      ).overrideWith((ref) async => const ['WGS84']),
    ],
    child: MaterialApp(home: child),
  );
}

class _CoordinateTestResources {
  const _CoordinateTestResources({
    required this.controller,
    required this.database,
    this.formKey,
    this.disposeController = true,
  });

  final CoordinateCtrModel controller;
  final Database database;
  final GlobalKey<CoordinateFormsState>? formKey;
  final bool disposeController;

  Future<void> dispose() async {
    if (disposeController) controller.dispose();
    await database.close();
  }
}
