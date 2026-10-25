import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

class NahpuTheme {
  static const _canopyTeal = Color(0xFF1B9E77);
  static const _mistySage = Color(0xFF4D625B);
  static const _mossShadow = Color(0xFF1E352F);
  static const _canopyMist = Color(0xFF7FD9BE);
  static const _canopyDeep = Color(0xFF0F7B5C);

  /// Dark theme secondary and tertiary: the misty sage and moss hues lifted to
  /// a light tone so they read at 4.5:1 on every dark surface. The light theme
  /// tones are too dark to read there.
  static const _mistySageLight = Color(0xFFB4CCC3);
  static const _mossLight = Color(0xFFA5D0BF);

  /// Light theme primary: the canopy hue just dark enough for 4.5:1 as text
  /// on every light surface, up to surfaceContainerHighest.
  static const _canopyForest = Color(0xFF0C7055);

  /// Fill for the single most important call to action, such as Create
  /// project on the home screen. Canopy teal is too light to carry white label
  /// text, so this deeper canopy shade keeps white text above a 4.5:1 contrast
  /// ratio in both themes.
  static const Color primaryAction = _canopyDeep;

  /// Text and icon color on [primaryAction].
  static const Color onPrimaryAction = Colors.white;

  // Primary is the canopy hue at the depth that meets WCAG AA (4.5:1) as
  // text on the surface and under its on-primary text: canopy teal itself
  // reads only about 3:1 against white.
  static final _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _canopyTeal,
    brightness: Brightness.light,
    primary: _canopyForest,
    onPrimary: Colors.white,
    secondary: _mistySage,
    tertiary: _mossShadow,
  );

  static final _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _canopyTeal,
    brightness: Brightness.dark,
    primary: _canopyMist,
    secondary: _mistySageLight,
    onSecondary: _mossShadow,
    tertiary: _mossLight,
    onTertiary: _mossShadow,
  );

  /// Colors for the record types of the statistics network, one per type in
  /// declaration order: site, event, specimen, taxon, collector, media.
  /// Distinct hues tuned for the surface of each theme.
  static List<Color> networkTypeColors(ColorScheme colorScheme) =>
      colorScheme.brightness == Brightness.dark
      ? _networkTypeColorsDark
      : _networkTypeColorsLight;

  // Dark2 hues, deepened where needed to keep 3:1 on surfaceContainerHighest.
  static const _networkTypeColorsLight = [
    Color(0xFF178A68),
    Color(0xFFD05B01),
    Color(0xFF7570B3),
    Color(0xFFE7298A),
    Color(0xFF538C17),
    Color(0xFFA6761D),
  ];

  static const _networkTypeColorsDark = [
    Color(0xFF66C2A5),
    Color(0xFFFC8D62),
    Color(0xFF8DA0CB),
    Color(0xFFE78AC3),
    Color(0xFFA6D854),
    Color(0xFFE5C494),
  ];

  /// Text color for edits that are waiting to be saved, such as the data
  /// table's "2 unsaved changes". Readable at 4.5:1 on every surface in both
  /// themes, up to surfaceContainerHighest.
  static Color pendingChange(ColorScheme colorScheme) =>
      colorScheme.brightness == Brightness.dark ? _canopyMist : _canopyForest;

  /// Text and icon color for warnings, such as a skipped or conflicting
  /// scan. [ColorScheme.tertiary] is too dark to read on dark surfaces, and
  /// an amber keeps warnings distinct from errors and success in both themes.
  static Color warningText(ColorScheme colorScheme) =>
      colorScheme.brightness == Brightness.dark ? _amberLight : _amberDeep;

  static const _amberDeep = Color(0xFF8A5300);
  static const _amberLight = Color(0xFFFFB95C);

  /// Light surface used around printable template canvases in every app theme.
  static Color get templateEditorWorkspaceSurface => _lightColorScheme.surface;

  /// Marker color for the focused point on NAHPU maps. Selected points use
  /// [ColorScheme.primary] and the rest use [ColorScheme.onSurfaceVariant], so
  /// this tone has to stay readable next to the canopy teal in both themes.
  static Color focusedMapMarker(ColorScheme colorScheme) =>
      colorScheme.brightness == Brightness.dark ? _canopyMist : _mossShadow;

  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: _lightColorScheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: appBarLightTheme,
      cardTheme: _cardTheme(_lightColorScheme),
      inputDecorationTheme: inputDecorationTheme,
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      colorScheme: _darkColorScheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: appBarDarkTheme,
      cardTheme: _cardTheme(_darkColorScheme),
      inputDecorationTheme: inputDecorationTheme,
    );
  }

  static CardThemeData _cardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: NahpuElevation.none,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(NahpuRadius.md)),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: NahpuStroke.thin,
        ),
      ),
    );
  }

  static AppBarTheme get appBarLightTheme {
    return const AppBarTheme(
      elevation: NahpuElevation.none,
      titleTextStyle: TextStyle(
        fontFamily: 'Merriweather',
        color: Colors.black,
        fontSize: 24,
      ),
    );
  }

  static AppBarTheme get appBarDarkTheme {
    return const AppBarTheme(
      elevation: NahpuElevation.none,
      titleTextStyle: TextStyle(
        fontFamily: 'Merriweather',
        color: Colors.white,
        fontSize: 24,
      ),
    );
  }

  static InputDecorationTheme get inputDecorationTheme {
    return const InputDecorationTheme(
      floatingLabelStyle: TextStyle(fontSize: 16),
      hintStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.11,
      ),
    );
  }
}
