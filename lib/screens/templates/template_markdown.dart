import 'package:flutter/material.dart' as flutter;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

WrapAlignment templateMarkdownAlign(TextAlign align) {
  return switch (align) {
    TextAlign.center => WrapAlignment.center,
    TextAlign.right => WrapAlignment.end,
    TextAlign.end => WrapAlignment.end,
    _ => WrapAlignment.start,
  };
}

MarkdownStyleSheet templateMarkdownStyleSheet({
  required BuildContext context,
  required TextStyle textStyle,
  required TextAlign textAlign,
}) {
  final align = templateMarkdownAlign(textAlign);
  const tableBorderColor = Color(0xFFBDBDBD);
  return MarkdownStyleSheet.fromTheme(flutter.Theme.of(context)).copyWith(
    p: textStyle,
    h1: textStyle.copyWith(
      fontSize: textStyle.fontSize == null ? null : textStyle.fontSize! * 1.6,
      fontWeight: FontWeight.bold,
    ),
    h2: textStyle.copyWith(
      fontSize: textStyle.fontSize == null ? null : textStyle.fontSize! * 1.4,
      fontWeight: FontWeight.bold,
    ),
    h3: textStyle.copyWith(
      fontSize: textStyle.fontSize == null ? null : textStyle.fontSize! * 1.2,
      fontWeight: FontWeight.bold,
    ),
    strong: textStyle.copyWith(fontWeight: FontWeight.bold),
    em: textStyle.copyWith(fontStyle: FontStyle.italic),
    del: textStyle.copyWith(decoration: TextDecoration.lineThrough),
    code: textStyle.copyWith(fontFamily: 'monospace'),
    blockSpacing: 0,
    pPadding: EdgeInsets.zero,
    h1Padding: EdgeInsets.zero,
    h2Padding: EdgeInsets.zero,
    h3Padding: EdgeInsets.zero,
    textAlign: align,
    h1Align: align,
    h2Align: align,
    h3Align: align,
    unorderedListAlign: align,
    orderedListAlign: align,
    tableHead: textStyle.copyWith(color: Colors.black),
    tableBody: textStyle.copyWith(color: Colors.black),
    tableBorder: TableBorder.all(color: tableBorderColor, width: 0.5),
    tableCellsDecoration: const BoxDecoration(),
    tableHeadCellsDecoration: const BoxDecoration(),
  );
}

class TemplateMarkdownBody extends StatelessWidget {
  const TemplateMarkdownBody({
    super.key,
    required this.data,
    required this.textStyle,
    required this.textAlign,
    this.clipOverflow = false,
  });

  final String data;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final bool clipOverflow;

  @override
  Widget build(BuildContext context) {
    final body = MarkdownBody(
      data: data,
      fitContent: false,
      softLineBreak: true,
      styleSheet: templateMarkdownStyleSheet(
        context: context,
        textStyle: textStyle,
        textAlign: textAlign,
      ),
    );
    if (!clipOverflow) return body;
    return ClipRect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: body,
      ),
    );
  }
}
