import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// How strongly the Tropical Mountains skyline carries the brand colours.
enum TropicalMountainsTone {
  /// Canopy teal ridges, for surfaces where the skyline is the decoration.
  brand,

  /// Sage and surface ridges, for screens where a teal action has to stay the
  /// only saturated colour.
  muted,
}

/// The Tropical Mountains skyline, NAHPU v1's codename, drawn behind content.
///
/// The asset keeps the nahpu-docs colours so it matches the website on its
/// own. [_ThemeRidgeColorMapper] swaps them for the active theme, so the ridges
/// follow light and dark mode.
class TropicalMountainsBackdrop extends StatelessWidget {
  const TropicalMountainsBackdrop({
    super.key,
    this.tone = TropicalMountainsTone.brand,
    this.fadeTop = false,
  });

  static const String assetPath = 'assets/illustrations/tropical_mountains.svg';

  final TropicalMountainsTone tone;

  /// Dissolves the upper part of the skyline into the page, so the ridges rise
  /// out of the background instead of starting at a hard edge.
  final bool fadeTop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompact =
        MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    // A compact width crops the range down to the summit, which then sits
    // behind more of the content, so it is faded further there, as on the
    // website. The muted tone stays quieter still.
    final opacity = switch ((tone, isDark, isCompact)) {
      (TropicalMountainsTone.brand, false, false) => 0.9,
      (TropicalMountainsTone.brand, true, false) => 0.7,
      (TropicalMountainsTone.brand, false, true) => 0.5,
      (TropicalMountainsTone.brand, true, true) => 0.4,
      (TropicalMountainsTone.muted, false, false) => 0.55,
      (TropicalMountainsTone.muted, true, false) => 0.4,
      (TropicalMountainsTone.muted, false, true) => 0.45,
      (TropicalMountainsTone.muted, true, true) => 0.35,
    };
    final picture = SvgPicture.asset(
      assetPath,
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      excludeFromSemantics: true,
      colorMapper: _ThemeRidgeColorMapper(
        theme.colorScheme,
        tone: tone,
        isDark: isDark,
      ),
    );
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: fadeTop
            ? ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.12, 0.6],
                ).createShader(bounds),
                // Where `cover` crops the skyline, its cut edge would sit on
                // the mask's own edge row, which is only partly masked and
                // leaves a faint line under the content. Starting the picture
                // inside the fully clear part of the fade leaves that row
                // empty.
                child: Padding(
                  padding: const EdgeInsets.only(top: NahpuSpacing.xs),
                  child: picture,
                ),
              )
            : picture,
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
  const _ThemeRidgeColorMapper(
    this.colors, {
    required this.tone,
    required this.isDark,
  });

  final ColorScheme colors;
  final TropicalMountainsTone tone;
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
    final isMuted = tone == TropicalMountainsTone.muted;
    final hazeAlpha = isDark ? alpha * _darkHaze : alpha;
    return switch (color.toARGB32() & 0x00FFFFFF) {
      0x2B765F => (isMuted ? colors.secondary : colors.primary).withValues(
        alpha: alpha,
      ),
      0x58B192 =>
        (isMuted ? colors.secondaryContainer : colors.primaryContainer)
            .withValues(alpha: alpha),
      0xAEE1CC => colors.surfaceContainerHighest.withValues(alpha: hazeAlpha),
      0xD7F0E5 when attributeName == 'fill' => colors.surface.withValues(
        alpha: isDark ? alpha * _darkScar : alpha,
      ),
      0xD7F0E5 => colors.surface.withValues(alpha: alpha),
      // Gold would compete with the logo and with a teal action on a screen
      // that asks for the muted tone.
      0xFFF9C1 || 0xFFEF87 when isMuted =>
        colors.surfaceContainerHighest.withValues(alpha: hazeAlpha),
      0xFFF9C1 || 0xFFEF87 when isDark => color.withValues(alpha: hazeAlpha),
      _ => color,
    };
  }
}
