import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// The Tropical Mountains skyline, NAHPU v1's codename, drawn behind content.
///
/// The asset keeps the nahpu-docs colours so it matches the website on its
/// own. [_ThemeRidgeColorMapper] swaps them for the active theme, so the ridges
/// follow light and dark mode.
class TropicalMountainsBackdrop extends StatelessWidget {
  const TropicalMountainsBackdrop({super.key});

  static const String assetPath = 'assets/illustrations/tropical_mountains.svg';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompact =
        MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    // A compact width crops the range down to the summit, which then sits
    // behind the text, so it is faded further there, as on the website.
    final opacity = switch ((isDark, isCompact)) {
      (false, false) => 0.9,
      (true, false) => 0.7,
      (false, true) => 0.5,
      (true, true) => 0.4,
    };
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: SvgPicture.asset(
          assetPath,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          excludeFromSemantics: true,
          colorMapper: _ThemeRidgeColorMapper(
            theme.colorScheme,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

/// Maps the asset's website colours onto the theme.
///
/// On a dark surface the warm haze would only wash the background out and the
/// pale escarpment would read as a light left on, so both are dimmed to the
/// website's dark-mode strength.
class _ThemeRidgeColorMapper extends ColorMapper {
  const _ThemeRidgeColorMapper(this.colors, {required this.isDark});

  final ColorScheme colors;
  final bool isDark;

  /// Dark-mode haze strength relative to light (0.1 / 0.4 on the website).
  static const double _darkHaze = 0.25;

  /// Dark-mode escarpment strength relative to light (0.2 / 0.45).
  static const double _darkScar = 0.44;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    final alpha = color.a;
    return switch (color.toARGB32() & 0x00FFFFFF) {
      0x2B765F => colors.primary.withValues(alpha: alpha),
      0x58B192 => colors.primaryContainer.withValues(alpha: alpha),
      0xAEE1CC => colors.surfaceContainerHighest.withValues(
        alpha: isDark ? alpha * _darkHaze : alpha,
      ),
      0xD7F0E5 when attributeName == 'fill' => colors.surface.withValues(
        alpha: isDark ? alpha * _darkScar : alpha,
      ),
      0xD7F0E5 => colors.surface.withValues(alpha: alpha),
      0xFFF9C1 ||
      0xFFEF87 when isDark => color.withValues(alpha: alpha * _darkHaze),
      _ => color,
    };
  }
}
