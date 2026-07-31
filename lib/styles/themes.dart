import 'package:flutter/material.dart';
import 'package:nahpu/styles/design_tokens.dart';

class NahpuTheme {
  static const _canopyTeal = Color(0xFF1B9E77);
  static const _mistySage = Color(0xFF4D625B);
  static const _mossShadow = Color(0xFF1E352F);

  static final _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _canopyTeal,
    brightness: Brightness.light,
    primary: _canopyTeal,
    secondary: _mistySage,
    tertiary: _mossShadow,
  );

  static final _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _canopyTeal,
    brightness: Brightness.dark,
    primary: _canopyTeal,
    secondary: _mistySage,
    tertiary: _mossShadow,
  );

  /// Light surface used around printable template canvases in every app theme.
  static Color get templateEditorWorkspaceSurface => _lightColorScheme.surface;

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
        borderRadius: BorderRadius.all(Radius.circular(NahpuRadius.medium)),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: NahpuStroke.regular,
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
