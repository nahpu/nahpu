import 'package:flutter_svg/svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/types/specimens.dart';

/// The catalog-format glyph, sized and colored like an [Icon] so it can sit
/// anywhere an icon does.
class CatalogFmtIcon extends StatelessWidget {
  const CatalogFmtIcon({
    super.key,
    required this.catalogFmt,
    this.isFilled = false,
    this.size,
    this.color,
  });

  final CatalogFmt catalogFmt;

  /// Uses the filled glyph, such as for a selected destination.
  final bool isFilled;

  /// Defaults to the ambient [IconTheme] size.
  final double? size;

  /// Defaults to the ambient [IconTheme] color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = size ?? iconTheme.size ?? 24;
    final iconColor = color ?? iconTheme.color;
    return SizedBox.square(
      dimension: iconSize,
      child: Transform.scale(
        scale: _opticalScale,
        child: SvgPicture.asset(
          matchCatFmtToGlyphPath(catalogFmt, isFilled: isFilled),
          width: iconSize,
          height: iconSize,
          colorFilter: iconColor != null
              ? ColorFilter.mode(iconColor, BlendMode.srcIn)
              : null,
          excludeFromSemantics: true,
        ),
      ),
    );
  }

  /// Enlarges the glyph into the 2dp icon padding so it matches the visual
  /// weight of Material icons. The wide, short glyphs need the most; 1.2 is
  /// the largest scale that keeps every glyph inside the 24dp box.
  double get _opticalScale => switch (catalogFmt) {
    CatalogFmt.mammalogy => 1.2,
    CatalogFmt.ichthyology => 1.2,
    CatalogFmt.herpetology => 1.15,
    CatalogFmt.ornithology => 1.15,
    CatalogFmt.invertebrateZoology => 1.1,
  };
}
