/// Canonical visual values for NAHPU UI.
///
/// Keep values on the curated even-number scale. Ratios, animation durations,
/// responsive calculations, and user-configurable document geometry are not
/// design tokens.
abstract final class NahpuSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double display = 48;
  static const double displayLarge = 64;
}

abstract final class NahpuRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

abstract final class NahpuStroke {
  static const double none = 0;
  static const double thin = 1;
  static const double regular = 2;
}

abstract final class NahpuElevation {
  static const double none = 0;
  static const double low = 2;
  static const double medium = 4;
  static const double high = 8;
  static const double overlay = 12;
}

abstract final class NahpuControlSize {
  static const double indicator = 12;
  static const double iconSmall = 16;
  static const double iconMedium = 20;
  static const double icon = 24;
  static const double iconLarge = 32;
  static const double control = 40;
  static const double touchTarget = 48;
  static const double prominent = 64;
}

abstract final class NahpuBreakpoints {
  static const double compact = 600;
  static const double projectWizardRail = 840;
  static const double desktop = 900;

  /// Laptop-sized and wider: enough room for the project rail to show its
  /// labels without crowding the page beside it.
  static const double laptop = 1280;
}

/// Fixed geometry for dashboard panels so every panel lines up.
abstract final class NahpuDashboardPanel {
  static const double height = 360;
  static const double maxWidth = 460;
  static const double contentMaxWidth = 420;

  /// Height of a dashboard row: one panel plus the card title and padding.
  static const double rowHeight = 470;
}

abstract final class NahpuContentWidth {
  static const double form = 600;
  static const double projectForm = 720;
  static const double projectWizard = 760;
  static const double home = 800;
  static const double settings = 1200;
}
