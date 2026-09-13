import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/styles/design_tokens.dart';

void main() {
  Future<void> pumpList(
    WidgetTester tester, {
    required Size size,
    required List<Widget> sections,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CommonSettingList(sections: sections)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('section title is centered in the section header', (
    tester,
  ) async {
    await pumpList(
      tester,
      size: const Size(800, 600),
      sections: [
        CommonSettingSection(
          title: 'Catalogs',
          children: [CommonSettingTile(title: 'Format', onTap: () {})],
        ),
      ],
    );

    final surface = find
        .descendant(
          of: find.byType(CommonSettingSection),
          matching: find.byType(Material),
        )
        .first;
    final surfaceRect = tester.getRect(surface);
    final titleRect = tester.getRect(find.text('Catalogs'));
    final dividerRect = tester.getRect(
      find.descendant(of: surface, matching: find.byType(Divider)),
    );

    expect(surfaceRect.intersect(titleRect), titleRect);
    // Centered both ways in the header above the title divider.
    expect(titleRect.center.dx, closeTo(surfaceRect.center.dx, 1));
    expect(
      titleRect.center.dy,
      closeTo((surfaceRect.top + dividerRect.top) / 2, 1),
    );
    expect(titleRect.bottom, lessThan(tester.getRect(find.text('Format')).top));
  });

  testWidgets('untitled section has no title divider', (tester) async {
    await pumpList(
      tester,
      size: const Size(800, 600),
      sections: [
        CommonSettingSection(
          children: [CommonSettingTile(title: 'Total usage', onTap: null)],
        ),
      ],
    );

    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('list scrolls from the gutter and caps section width', (
    tester,
  ) async {
    await pumpList(
      tester,
      size: const Size(1600, 600),
      sections: [
        for (var i = 0; i < 20; i++)
          CommonSettingSection(
            title: 'Section $i',
            children: [CommonSettingTile(title: 'Tile $i', onTap: () {})],
          ),
      ],
    );

    expect(tester.getSize(find.byType(ListView)).width, 1600);
    final sectionRect = tester.getRect(find.byType(CommonSettingSection).first);
    expect(sectionRect.width, NahpuContentWidth.settings - NahpuSpacing.xl * 2);
    expect(sectionRect.center.dx, closeTo(800, 0.01));

    // Sections past the viewport are built on demand.
    expect(find.text('Section 19'), findsNothing);
    await tester.dragFrom(const Offset(40, 500), const Offset(0, -4000));
    await tester.pumpAndSettle();
    expect(find.text('Section 19'), findsOneWidget);
  });
}
