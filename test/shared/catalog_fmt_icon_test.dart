import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/common/catalog_fmt_icon.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  testWidgets('CatalogFmtIcon follows the ambient icon theme', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IconTheme(
          data: IconThemeData(size: 32, color: Colors.teal),
          child: CatalogFmtIcon(catalogFmt: CatalogFmt.ichthyology),
        ),
      ),
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 32);
    expect(svg.height, 32);
    expect(
      svg.colorFilter,
      const ColorFilter.mode(Colors.teal, BlendMode.srcIn),
    );
  });

  testWidgets('explicit size and color override the icon theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CatalogFmtIcon(
          catalogFmt: CatalogFmt.mammalogy,
          size: 18,
          color: Colors.red,
        ),
      ),
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 18);
    expect(
      svg.colorFilter,
      const ColorFilter.mode(Colors.red, BlendMode.srcIn),
    );
  });

  testWidgets('isFilled switches to the filled glyph', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            CatalogFmtIcon(catalogFmt: CatalogFmt.ornithology),
            CatalogFmtIcon(catalogFmt: CatalogFmt.ornithology, isFilled: true),
          ],
        ),
      ),
    );

    final names = tester
        .widgetList<SvgPicture>(find.byType(SvgPicture))
        .map((svg) => (svg.bytesLoader as SvgAssetLoader).assetName)
        .toList();
    expect(names, [
      matchCatFmtToGlyphPath(CatalogFmt.ornithology),
      matchCatFmtToGlyphPath(CatalogFmt.ornithology, isFilled: true),
    ]);
    expect(names.first, endsWith('ornithology_outlined.svg'));
  });
}
