part of '../document_writer.dart';

class _DocumentTemplateSubstitutor {
  const _DocumentTemplateSubstitutor({required this.ref});

  final WidgetRef ref;

  Future<TemplatePage> substitutePage(
    TemplatePage page,
    Map<String, String> data,
  ) async {
    final texts = <CustomTextElement>[];
    final tempDir = await AppServices(ref: ref).tempDirectory;
    for (final ct in page.customTexts) {
      if (!ct.isVisible) {
        texts.add(ct);
        continue;
      }
      var subbedText = substituteDocumentPlaceholders(
        expandNestedListTextIfEnabled(
          text: ct.text,
          textType: ct.textType,
          fieldValues: data,
          formatOption: ct.formatOption,
          caseFormat: ct.caseFormat,
        ),
        data,
        nullFallbackOption: ct.nullFallbackOption,
        customNullFallbackText: ct.customNullFallbackText,
        textType: ct.textType,
        formatOption: ct.formatOption,
      );
      var textType = ct.textType;
      if (isTemplateRichTextType(ct.textType) ||
          ct.text.toLowerCase().contains('narrative::narrative')) {
        subbedText = await rust_export.markdownToTypst(mdContent: subbedText);
        textType = 'markdown';
      }
      if (ct.isQrCode) {
        final formattedText = formatTemplateText(
          subbedText,
          textType,
          ct.formatOption,
          ct.caseFormat,
        );
        final fgColorHex = _colorToHex(ct.colorArgb);
        final bgColorHex = _colorToHex(ct.qrBgColorArgb);
        final svgString = _generateQrSvg(
          formattedText,
          fgColorHex,
          bgColorHex,
          ct.qrShape,
        );
        final tempFile = File(path.join(
          tempDir.path,
          'qr_${DateTime.now().microsecondsSinceEpoch}_${ct.id}.svg',
        ));
        await tempFile.writeAsString(svgString);
        texts.add(ct.copyWith(
          text: formattedText,
          tempPath: tempFile.path,
          textType: textType,
        ));
      } else {
        final formattedText = formatExportTemplateText(
          subbedText,
          textType,
          ct.formatOption,
          ct.caseFormat,
        );
        texts.add(ct.copyWith(
          text: formattedText,
          textType: textType,
        ));
      }
    }
    return page.copyWith(customTexts: texts);
  }

  String _colorToHex(int colorArgb) {
    final hex = colorArgb.toRadixString(16).padLeft(8, '0');
    final aa = hex.substring(0, 2);
    final rgb = hex.substring(2);
    if (aa == '00') return 'none';
    if (aa == 'ff') return '#$rgb';
    return '#$rgb$aa';
  }

  String _generateQrSvg(
    String data,
    String fgColorHex,
    String bgColorHex,
    String shape,
  ) {
    final qrCode = QrCode(
      payload: QrPayload.fromString(data.isEmpty ? ' ' : data),
      errorCorrectLevel: QrErrorCorrectLevel.low,
    );
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;

    final sb = StringBuffer();
    sb.writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $moduleCount $moduleCount" shape-rendering="crispEdges">');
    sb.writeln(
        '  <rect width="$moduleCount" height="$moduleCount" fill="$bgColorHex"/>');

    if (shape == 'circle') {
      for (int y = 0; y < moduleCount; y++) {
        for (int x = 0; x < moduleCount; x++) {
          if (qrImage.isDark(y, x)) {
            sb.writeln(
                '  <circle cx="${x + 0.5}" cy="${y + 0.5}" r="0.5" fill="$fgColorHex"/>');
          }
        }
      }
    } else {
      sb.writeln('  <path fill="$fgColorHex" d="');
      for (int y = 0; y < moduleCount; y++) {
        for (int x = 0; x < moduleCount; x++) {
          if (qrImage.isDark(y, x)) {
            sb.write('M$x ${y}h1v1h-1z ');
          }
        }
      }
      sb.writeln('"/>');
    }
    sb.writeln('</svg>');
    return sb.toString();
  }
}
