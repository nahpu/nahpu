import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class NahpuTheme {
  static final _defaultLightColorScheme =
      FlexThemeData.light(scheme: FlexScheme.jungle).colorScheme;

  static final _defaultDarkColorScheme =
      FlexThemeData.dark(scheme: FlexScheme.jungle).colorScheme;

  static ThemeData lightTheme(ColorScheme? lightColorScheme) {
    return ThemeData(
      colorScheme: lightColorScheme ?? _defaultLightColorScheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: appBarLightTheme,
      inputDecorationTheme: inputDecorationTheme,
    );
  }

  static ThemeData darkTheme(ColorScheme? darkColorScheme) {
    return ThemeData(
      colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: appBarDarkTheme,
      inputDecorationTheme: inputDecorationTheme,
    );
  }

  static CardTheme get cardTheme {
    return const CardTheme(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }

  static AppBarTheme get appBarLightTheme {
    return const AppBarTheme(
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Merriweather',
        color: Colors.black,
        fontSize: 24,
      ),
    );
  }

  static AppBarTheme get appBarDarkTheme {
    return const AppBarTheme(
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Merriweather',
        color: Colors.white,
        fontSize: 24,
      ),
    );
  }

  static InputDecorationTheme get inputDecorationTheme {
    return const InputDecorationTheme(
      floatingLabelStyle: TextStyle(
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        fontSize: 16,
        color: Color(0xfffafafa),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.11
      ),
    );
  }
}
