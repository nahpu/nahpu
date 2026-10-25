import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/common/tropical_mountains.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';

/// A theme option drawn as the Tropical Mountains skyline under that theme's
/// sky, so the choice shows how the app will look before it is picked.
class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({
    super.key,
    required this.mode,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final ThemeMode mode;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NahpuRadius.lg),
          side: BorderSide(
            color: isSelected ? colors.primary : colors.outlineVariant,
            width: isSelected ? NahpuStroke.regular : NahpuStroke.thin,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Portrait, so the ridges sit low under a tall sky.
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ThemeSkyline(mode: mode),
                    if (isSelected)
                      const Positioned(
                        top: NahpuSpacing.md,
                        right: NahpuSpacing.md,
                        child: _SelectedMark(),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NahpuSpacing.sm,
                  vertical: NahpuSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: NahpuSpacing.xs,
                  children: [
                    Icon(icon, size: NahpuControlSize.iconSmall),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isSelected ? colors.primary : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The skyline for one mode; the system option splits day from night on a
/// diagonal, since it follows the device between the two.
class _ThemeSkyline extends StatelessWidget {
  const _ThemeSkyline({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    return switch (mode) {
      ThemeMode.light => const _Sky(brightness: Brightness.light),
      ThemeMode.dark => const _Sky(brightness: Brightness.dark),
      ThemeMode.system => const Stack(
        fit: StackFit.expand,
        children: [
          // The sun moves left, clear of the night half.
          _Sky(
            brightness: Brightness.light,
            orbAlignment: Alignment(-0.45, -0.55),
          ),
          ClipPath(
            clipper: _NightClipper(),
            child: _Sky(brightness: Brightness.dark),
          ),
        ],
      ),
    };
  }
}

/// Sky, sun or moon, and the skyline, all drawn in the theme of [brightness]
/// rather than the active one, so every option previews its own colours.
class _Sky extends StatelessWidget {
  const _Sky({
    required this.brightness,
    this.orbAlignment = const Alignment(0.45, -0.55),
  });

  final Brightness brightness;
  final Alignment orbAlignment;

  /// Stronger than the backdrop default, since the ridges are the subject.
  static const double _lightRidges = 0.95;
  static const double _darkRidges = 0.85;

  /// Where the stars sit in the night sky, clear of the moon and the ridges.
  static const List<Alignment> _stars = [
    Alignment(-0.7, -0.85),
    Alignment(-0.2, -0.6),
    Alignment(0.75, -0.2),
    Alignment(-0.85, -0.3),
    Alignment(0.1, -0.9),
    Alignment(-0.45, -0.05),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;
    final theme = isDark ? NahpuTheme.darkTheme() : NahpuTheme.lightTheme();
    final colors = theme.colorScheme;
    final orb = NahpuTheme.skyOrb(colors);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: NahpuTheme.skyGradient(colors),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isDark)
            for (final star in _stars)
              Align(
                alignment: star,
                child: _Dot(color: orb, size: NahpuSpacing.xxs),
              ),
          Align(
            alignment: orbAlignment,
            child: FractionallySizedBox(
              widthFactor: 0.22,
              child: AspectRatio(
                aspectRatio: 1,
                child: isDark
                    ? FittedBox(child: Icon(Icons.nightlight_round, color: orb))
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: orb,
                          boxShadow: [
                            BoxShadow(
                              color: orb.withValues(alpha: 0.5),
                              blurRadius: NahpuSpacing.xl,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 0.5,
              child: Theme(
                data: theme,
                child: TropicalMountainsBackdrop(
                  fadeTop: true,
                  opacity: isDark ? _darkRidges : _lightRidges,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _SelectedMark extends StatelessWidget {
  const _SelectedMark();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary),
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xxs),
        child: Icon(
          Icons.check,
          size: NahpuControlSize.iconSmall,
          color: colors.onPrimary,
        ),
      ),
    );
  }
}

/// The night half of the system preview, right of a diagonal through the
/// middle.
class _NightClipper extends CustomClipper<Path> {
  const _NightClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width * 0.6, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(size.width * 0.4, size.height)
    ..close();

  @override
  bool shouldReclip(_NightClipper oldClipper) => false;
}
