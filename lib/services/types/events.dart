const List<String> defaultCollMethods = [
  'Hands',
  'Mist net',
  'Sweep net',
  'Snap trap',
  'Cage trap',
  'Pitfall',
  'Malaise trap',
  'Light trap',
  'Beating sheet',
  'Aspirator',
  'Local snare',
  'Pellet gun',
  'Other',
];

const List<String> defaultCollRoles = ['Leader', 'Helper'];

/// Icon vocabulary for collecting methods.
///
/// This exists only to pick an SVG for an effort row. Methods themselves stay
/// free text, so [CollMethodIcon.fromMethod] matches case-insensitively on
/// substrings rather than on exact values.
enum CollMethodIcon {
  mistNet,
  sweepNet,
  malaiseTrap,
  lightTrap,
  beatingSheet,
  aspirator,
  localSnare,
  pitfall,
  hands,
  snapTrap,
  cageTrap,
  gun,
  other;

  /// Resolves [method] to an icon, falling back to [CollMethodIcon.other] for
  /// unknown values and null.
  ///
  /// Specific traps and nets are matched before the generic `trap` and `net`
  /// keywords so that, for example, `Snap trap` does not resolve to
  /// [CollMethodIcon.other] and `Sweep net` does not resolve to
  /// [CollMethodIcon.mistNet].
  factory CollMethodIcon.fromMethod(String? method) {
    final name = method?.toLowerCase().trim() ?? '';
    if (name.contains('snap')) {
      return CollMethodIcon.snapTrap;
    } else if (name.contains('cage') ||
        name.contains('box trap') ||
        name.contains('live trap')) {
      return CollMethodIcon.cageTrap;
    } else if (name.contains('malaise') || name.contains('intercept')) {
      return CollMethodIcon.malaiseTrap;
    } else if (name.contains('light') ||
        name.contains('uv') ||
        name.contains('lamp')) {
      return CollMethodIcon.lightTrap;
    } else if (name.contains('beat')) {
      return CollMethodIcon.beatingSheet;
    } else if (name.contains('aspirator') || name.contains('pooter')) {
      return CollMethodIcon.aspirator;
    } else if (name.contains('sweep') ||
        name.contains('aerial') ||
        name.contains('insect net') ||
        name.contains('butterfly')) {
      return CollMethodIcon.sweepNet;
    } else if (name.contains('pitfall') ||
        name.contains('bucket') ||
        name.contains('pan trap') ||
        name.contains('bowl')) {
      return CollMethodIcon.pitfall;
    } else if (name.contains('net')) {
      return CollMethodIcon.mistNet;
    } else if (name.contains('snare') || name.contains('noose')) {
      return CollMethodIcon.localSnare;
    } else if (name.contains('gun') ||
        name.contains('rifle') ||
        name.contains('shotgun') ||
        name.contains('pellet') ||
        name.contains('air')) {
      return CollMethodIcon.gun;
    } else if (name.contains('hand')) {
      return CollMethodIcon.hands;
    }
    return CollMethodIcon.other;
  }

  String get iconPath => switch (this) {
    CollMethodIcon.mistNet => 'assets/icons/mist_net.svg',
    CollMethodIcon.sweepNet => 'assets/icons/sweep_net.svg',
    CollMethodIcon.malaiseTrap => 'assets/icons/malaise_trap.svg',
    CollMethodIcon.lightTrap => 'assets/icons/light_trap.svg',
    CollMethodIcon.beatingSheet => 'assets/icons/beating_sheet.svg',
    CollMethodIcon.aspirator => 'assets/icons/aspirator.svg',
    CollMethodIcon.localSnare => 'assets/icons/snare.svg',
    CollMethodIcon.pitfall => 'assets/icons/pitfall.svg',
    CollMethodIcon.hands => 'assets/icons/hand.svg',
    CollMethodIcon.snapTrap => 'assets/icons/snap_trap.svg',
    CollMethodIcon.cageTrap => 'assets/icons/cage_trap.svg',
    CollMethodIcon.gun => 'assets/icons/gun.svg',
    CollMethodIcon.other => 'assets/icons/trap.svg',
  };
}
