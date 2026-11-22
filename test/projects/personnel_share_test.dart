import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/personnel/personnel_details.dart';
import 'package:nahpu/screens/projects/personnel/personnel_share.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/media.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/record_exchange/personnel_exchange_service.dart';
import 'package:path/path.dart' as p;

const _ada = PersonnelData(
  uuid: 'ada-uuid',
  name: 'Ada Lovelace',
  initial: 'AL',
  role: 'Cataloger',
  currentFieldNumber: 42,
  isRegisterField: true,
);

void main() {
  late Database database;
  late Directory documentDir;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    documentDir = await Directory.systemTemp.createTemp('nahpu-personnel-');
  });

  tearDown(() async {
    await database.close();
    if (await documentDir.exists()) await documentDir.delete(recursive: true);
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          nahpuDocumentDirProvider.overrideWith((ref) async => documentDir),
          ...overrides,
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('photo file provider finds only photos that exist', () async {
    final container = ProviderContainer(
      overrides: [
        nahpuDocumentDirProvider.overrideWith((ref) async => documentDir),
      ],
    );
    addTearDown(container.dispose);
    final photoDir = Directory(
      p.join(documentDir.path, appMediaDirName, 'personnel'),
    );
    await photoDir.create(recursive: true);
    await File(p.join(photoDir.path, 'ada.jpg')).writeAsBytes([1, 2, 3]);

    Future<File?> resolve(String? path) {
      final provider = personnelPhotoFileProvider(path);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      return container.read(provider.future);
    }

    expect((await resolve('ada.jpg'))?.path, endsWith('ada.jpg'));
    expect(await resolve('missing.jpg'), isNull);
    expect(await resolve('assets/avatars/handika_crocidura.png'), isNull);
    expect(await resolve(null), isNull);
  });

  Future<void> openShareMenu(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('personnel-share-menu')));
    await tester.pumpAndSettle();
  }

  testWidgets('share menu offers QR and JSON, but no photo without one', (
    tester,
  ) async {
    await pump(tester, PersonnelDetails(personnel: _ada, onEdit: () {}));
    await openShareMenu(tester);

    expect(find.text('Show QR'), findsOneWidget);
    expect(find.text('Export JSON'), findsOneWidget);
    expect(find.text('Share photo'), findsNothing);

    await tester.tap(find.text('Show QR'));
    await tester.pumpAndSettle();
    final dialog = tester.widget<QrCodeDialog>(find.byType(QrCodeDialog));
    expect(PersonnelExchangeService.decode(dialog.data).uuid, 'ada-uuid');
  });

  testWidgets('share menu offers the photo when its file exists', (
    tester,
  ) async {
    await pump(
      tester,
      PersonnelShareMenu(
        personnel: _ada.copyWith(photoPath: const Value('ada.jpg')),
      ),
      overrides: [
        personnelPhotoFileProvider.overrideWith(
          (ref, photoPath) async => File(p.join(documentDir.path, 'ada.jpg')),
        ),
      ],
    );
    await openShareMenu(tester);

    expect(find.text('Share photo'), findsOneWidget);
  });

  testWidgets('bundled avatars are not offered as a photo', (tester) async {
    await pump(
      tester,
      PersonnelShareMenu(
        personnel: _ada.copyWith(
          photoPath: const Value('assets/avatars/handika_crocidura.png'),
        ),
      ),
    );
    await openShareMenu(tester);

    expect(find.text('Share photo'), findsNothing);
  });

  testWidgets('scan QR shows only where the camera can scan', (tester) async {
    await pump(tester, const PersonnelImportActions(canScan: false));
    expect(find.byKey(const ValueKey('personnel-import-scan')), findsNothing);
    expect(find.byKey(const ValueKey('personnel-import-json')), findsOneWidget);

    await pump(tester, const PersonnelImportActions(canScan: true));
    expect(find.byKey(const ValueKey('personnel-import-scan')), findsOneWidget);
  });

  testWidgets('review offers add for someone new', (tester) async {
    await pump(
      tester,
      const PersonnelImportReview(
        preview: PersonnelImportPreview(incoming: _ada),
      ),
    );

    expect(find.text('New to this device.'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Update'), findsNothing);
  });

  testWidgets('review lists changes and offers update or keep', (tester) async {
    final incoming = _ada.copyWith(currentFieldNumber: const Value(50));
    await pump(
      tester,
      PersonnelImportReview(
        preview: PersonnelImportPreview(
          incoming: incoming,
          existing: _ada,
          changes: const [
            PersonnelFieldChange(
              field: PersonnelField.currentFieldNumber,
              current: 42,
              incoming: 50,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Already on this device.'), findsOneWidget);
    expect(find.text('Current field number'), findsOneWidget);
    expect(find.textContaining('50'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('Keep existing'), findsOneWidget);
  });
}
