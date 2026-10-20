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

/// Scroll tuning for the record forms.
abstract final class NahpuScroll {
  /// How far beyond the viewport a record form keeps its panels mounted.
  ///
  /// A record form is a handful of tall cards, each watching its own database
  /// provider. With the default 250 px window a fast flick unmounts and
  /// remounts them, so every panel re-queried and briefly showed a progress
  /// indicator in place of a full card -- a visible hitch mid-fling. This is
  /// wide enough to span a whole form on a phone, and deliberately finite so
  /// the first frame still only lays out what is near the viewport.
  static const double recordFormCacheExtent = 2400;
}

/// Gap between a scrolling page and the screen edge. It stays the same at
/// every screen size, so cards on the dashboard, the record forms, and the
/// statistics page line up with each other.
abstract final class NahpuPageMargin {
  static const double horizontal = NahpuSpacing.md;
  static const double top = NahpuSpacing.lg;
  static const double bottom = NahpuSpacing.xxxl;
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
  /// Confirmations and other short dialogs.
  static const double dialog = 480;
  static const double form = 600;
  static const double projectForm = 720;
  static const double projectWizard = 760;
  static const double home = 800;

  /// Home screen when the project list and its actions sit side by side.
  static const double homeSplit = 1200;
  static const double settings = 1200;

  /// Section list beside the settings page on wide screens.
  static const double settingsList = 380;
}
