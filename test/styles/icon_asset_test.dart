import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/types/events.dart';
import 'package:nahpu/services/types/specimens.dart';

/// Icons live directly in [iconDir]. Subdirectories are deliberately excluded
/// from the asset bundle, since Flutter's directory entries are not recursive.
///
/// The icon font is a separate system and is covered by `nahpu_font_test.dart`.
const String iconDir = 'assets/icons';

List<File> topLevelIcons() =>
    Directory(iconDir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

void main() {
  group('Icon paths referenced from Dart resolve to real files', () {
    test('partIconPath entries exist', () {
      for (final entry in partIconPath.entries) {
        expect(
          File(entry.value).existsSync(),
          isTrue,
          reason: 'partIconPath["${entry.key}"] -> ${entry.value} is missing',
        );
      }
    });

    test('preparationIconPath entries exist', () {
      for (final fmt in preparationIconPath.entries) {
        for (final part in fmt.value.entries) {
          expect(
            File(part.value).existsSync(),
            isTrue,
            reason:
                'preparationIconPath[${fmt.key}]["${part.key}"] -> '
                '${part.value} is missing',
          );
        }
      }
    });

    test('CollMethodIcon entries exist', () {
      for (final icon in CollMethodIcon.values) {
        expect(
          File(icon.iconPath).existsSync(),
          isTrue,
          reason: '$icon -> ${icon.iconPath} is missing',
        );
      }
    });

    test('matchCatalogFmtToIconPath covers every CatalogFmt', () {
      for (final fmt in CatalogFmt.values) {
        final path = matchCatalogFmtToIconPath(fmt);
        expect(
          File(path).existsSync(),
          isTrue,
          reason: 'matchCatalogFmtToIconPath($fmt) -> $path is missing',
        );
      }
    });

    /// Catches the class of bug where a widget hardcodes an icon path that was
    /// never added to the repo -- `json.svg` shipped broken this way.
    test('every assets/icons path literal under lib/ exists', () {
      final pattern = RegExp(r'assets/icons/[\w.-]+\.svg');
      final missing = <String>[];

      for (final file
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))) {
        final source = file.readAsStringSync();
        for (final match in pattern.allMatches(source)) {
          final path = match.group(0)!;
          if (!File(path).existsSync()) {
            missing.add('${file.path}: $path');
          }
        }
      }

      expect(
        missing,
        isEmpty,
        reason: 'Referenced icon assets do not exist:\n${missing.join('\n')}',
      );
    });
  });

  group('Icon set stays consistent', () {
    test('no two icons are byte-identical', () {
      final seen = <String, String>{};
      final duplicates = <String>[];

      for (final file in topLevelIcons()) {
        final content = file.readAsStringSync();
        final existing = seen[content];
        if (existing != null) {
          duplicates.add('${file.path} == $existing');
        } else {
          seen[content] = file.path;
        }
      }

      expect(
        duplicates,
        isEmpty,
        reason:
            'Duplicate icons -- reference one file from both call sites '
            'instead:\n${duplicates.join('\n')}',
      );
    });

    test('every icon uses the 48 grid and currentColor', () {
      final offenders = <String>[];

      for (final file in topLevelIcons()) {
        final content = file.readAsStringSync();
        if (!content.contains('viewBox="0 0 48 48"')) {
          offenders.add('${file.path}: missing viewBox="0 0 48 48"');
        }
        if (!content.contains('stroke="currentColor"')) {
          offenders.add('${file.path}: missing stroke="currentColor"');
        }
      }

      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });
  });

  group('SpecimenPartIcon resolution', () {
    test('skull and skeleton resolve per catalog format', () {
      expect(
        const SpecimenPartIcon(
          catalogFmt: CatalogFmt.birds,
          part: 'skull',
        ).match(),
        'assets/icons/bird_skull.svg',
      );
      expect(
        const SpecimenPartIcon(
          catalogFmt: CatalogFmt.herpetofauna,
          part: 'skeleton',
        ).match(),
        'assets/icons/herp_skeleton.svg',
      );
    });

    test('plural and mixed-case part names normalise', () {
      expect(
        const SpecimenPartIcon(
          catalogFmt: CatalogFmt.mammals,
          part: 'Skulls',
        ).match(),
        'assets/icons/mammal_skull.svg',
      );
    });

    /// `_cleanPart` used to mix the trimmed string with the untrimmed length,
    /// which over-trimmed or threw RangeError on padded values.
    test('whitespace-padded part names do not throw', () {
      expect(
        const SpecimenPartIcon(
          catalogFmt: CatalogFmt.mammals,
          part: '  skulls',
        ).match(),
        'assets/icons/mammal_skull.svg',
      );
    });

    test('a format without dedicated art falls back to the whole animal', () {
      expect(
        const SpecimenPartIcon(
          catalogFmt: CatalogFmt.birds,
          part: 'skin',
        ).match(),
        matchCatalogFmtToIconPath(CatalogFmt.birds),
      );
    });

    test('unknown parts fall back to the clue icon', () {
      expect(
        const SpecimenPartIcon(
          catalogFmt: CatalogFmt.mammals,
          part: 'nonsense value',
        ).match(),
        partIconPath['unknown'],
      );
    });
  });

  group('CollMethodIcon resolution', () {
    /// The generic `trap` fallback would swallow these if the specific
    /// branches did not run first.
    test('specific traps win over the generic trap fallback', () {
      expect(CollMethodIcon.fromMethod('Snap trap'), CollMethodIcon.snapTrap);
      expect(
        CollMethodIcon.fromMethod('  snap TRAP '),
        CollMethodIcon.snapTrap,
      );
      expect(CollMethodIcon.fromMethod('Cage trap'), CollMethodIcon.cageTrap);
      expect(
        CollMethodIcon.fromMethod('Malaise trap'),
        CollMethodIcon.malaiseTrap,
      );
      expect(CollMethodIcon.fromMethod('Light trap'), CollMethodIcon.lightTrap);
    });

    test('method names match case-insensitively', () {
      expect(CollMethodIcon.fromMethod('Hands'), CollMethodIcon.hands);
      expect(CollMethodIcon.fromMethod('hand'), CollMethodIcon.hands);
      expect(CollMethodIcon.fromMethod('Mist Net'), CollMethodIcon.mistNet);
      expect(CollMethodIcon.fromMethod('netline'), CollMethodIcon.mistNet);
    });

    /// Insect nets are checked before the bare `net` keyword.
    test('sweep nets are distinct from mist nets', () {
      expect(CollMethodIcon.fromMethod('Sweep net'), CollMethodIcon.sweepNet);
      expect(CollMethodIcon.fromMethod('Insect net'), CollMethodIcon.sweepNet);
      expect(CollMethodIcon.fromMethod('Net'), CollMethodIcon.mistNet);
    });

    test('every firearm resolves to the shotgun icon', () {
      expect(
        CollMethodIcon.fromMethod('Pellet Gun').iconPath,
        'assets/icons/gun.svg',
      );
      expect(
        CollMethodIcon.fromMethod('shotgun').iconPath,
        'assets/icons/gun.svg',
      );
    });

    test('unknown methods and null fall back to the generic trap', () {
      expect(CollMethodIcon.fromMethod('Trapline'), CollMethodIcon.other);
      expect(CollMethodIcon.fromMethod('nonsense value'), CollMethodIcon.other);
      expect(CollMethodIcon.fromMethod(null), CollMethodIcon.other);
      expect(CollMethodIcon.other.iconPath, 'assets/icons/trap.svg');
    });

    test('every default method resolves to a real icon', () {
      for (final method in defaultCollMethods) {
        expect(
          File(CollMethodIcon.fromMethod(method).iconPath).existsSync(),
          isTrue,
          reason: '$method has no icon on disk',
        );
      }
    });
  });
}
