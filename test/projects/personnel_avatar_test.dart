import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
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
}
