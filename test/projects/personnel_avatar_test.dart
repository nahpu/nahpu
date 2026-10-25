import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/personnel/avatars.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/providers/media.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:path/path.dart' as p;

void main() {
  test('every default avatar is a bundled asset', () {
    for (final name in [...availableBirdAvatar, ...availableMammalAvatar]) {
      expect(
        File(p.joinAll(['assets', 'avatars', name])).existsSync(),
        isTrue,
        reason: '$name is missing from assets/avatars',
      );
    }
  });

  test('a misspelled saved avatar resolves to the bundled asset', () {
    expect(
      resolveAvatarAsset('${avatarPath}hnadika_rousettus.png'),
      '${avatarPath}handika_rousettus.png',
    );
    expect(
      resolveAvatarAsset('${avatarPath}handika_dasypus.png'),
      '${avatarPath}handika_dasypus.png',
    );
  });

  group('custom avatar file', () {
    late Directory documentDir;

    setUp(() async {
      documentDir = await Directory.systemTemp.createTemp('nahpu_avatar_');
    });

    tearDown(() async {
      if (await documentDir.exists()) {
        await documentDir.delete(recursive: true);
      }
    });

    test('resolves under the personnel media folder', () async {
      final container = ProviderContainer(
        overrides: [
          nahpuDocumentDirProvider.overrideWith((ref) async => documentDir),
        ],
      );
      addTearDown(container.dispose);

      final file = await container.read(
        personnelAvatarFileProvider('face.jpg').future,
      );

      expect(
        file.path,
        p.join(documentDir.path, 'appMedia', 'personnel', 'face.jpg'),
      );
    });

    testWidgets('resolves the document directory once across rebuilds', (
      tester,
    ) async {
      var lookups = 0;
      final ctr = TextEditingController(text: 'face.jpg');
      addTearDown(ctr.dispose);
      late StateSetter rebuild;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nahpuDocumentDirProvider.overrideWith((ref) async {
              lookups++;
              return documentDir;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: nahpuLocalizationsDelegates,
            home: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return SizedBox.square(
                  dimension: avatarSize.toDouble(),
                  child: AvatarViewer(avatarCtr: ctr),
                );
              },
            ),
          ),
        ),
      );
      // Loading keeps the plain circle instead of the not-found text.
      expect(find.byType(CircleAvatar), findsOneWidget);
      await tester.pump();

      for (var i = 0; i < 3; i++) {
        rebuild(() {});
        await tester.pump();
      }

      expect(lookups, 1);
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      final image = avatar.foregroundImage! as ResizeImage;
      expect(image.width, isNotNull);
      expect(
        (image.imageProvider as FileImage).file.path,
        endsWith('face.jpg'),
      );
    });
  });
}
