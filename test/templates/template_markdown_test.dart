import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_markdown.dart';
import 'package:nahpu/styles/themes.dart';

void main() {
  testWidgets('renders Markdown tables with printable colors in dark mode',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NahpuTheme.darkTheme(),
        home: const Scaffold(
          body: TemplateMarkdownBody(
            data: '| Header | Value |\n| --- | --- |\n| Body | Data |',
            textStyle: TextStyle(fontSize: 12),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );

    final table = tester.widget<Table>(find.byType(Table));
    final border = table.border!;
    final style = templateMarkdownStyleSheet(
      context: tester.element(find.byType(TemplateMarkdownBody)),
      textStyle: const TextStyle(fontSize: 12),
      textAlign: TextAlign.left,
    );

    expect(border.top.color, const Color(0xFFBDBDBD));
    expect(border.top.width, 0.5);
    expect(style.tableHead!.color, Colors.black);
    expect(style.tableHead!.fontWeight, isNull);
    expect(style.tableBody!.color, Colors.black);
    expect(
      (style.tableHeadCellsDecoration! as BoxDecoration).color,
      isNull,
    );
    expect(
      (style.tableCellsDecoration! as BoxDecoration).color,
      isNull,
    );
  });
}
