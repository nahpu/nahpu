part of '../document_writer.dart';

class _DocumentPdfInputResolver {
  const _DocumentPdfInputResolver({
    required this.collector,
  });

  final _DocumentLayoutRecordCollector collector;

  Future<Map<String, Template>> _loadTemplates(
    rust_config.DocumentLayoutPreset layout,
  ) async {
    final service = const TemplateService();
    final templates = <String, Template>{};
    for (final block in layout.blocks) {
      if (templates.containsKey(block.templateName)) continue;
      templates[block.templateName] = await service.getTemplate(
            block.templateName,
          ) ??
          DefaultTemplate.defaultTemplate(block.templateName);
    }
    return templates;
  }

  Future<List<_DocumentPdfBlockInput>> fromRecords<T>({
    required List<T> records,
    required rust_config.DocumentLayoutPreset layout,
    required Future<Map<String, String>> Function(T) recordToFields,
  }) async {
    final templates = await _loadTemplates(layout);
    final data = <Map<String, String>>[];
    for (final record in records) {
      data.add(await recordToFields(record));
    }
    return [
      for (final block in layout.blocks)
        _DocumentPdfBlockInput(
          block: block,
          template: templates[block.templateName]!,
          data: data,
        ),
    ];
  }

  Future<List<_DocumentPdfBlockInput>> fromLayout({
    required rust_config.DocumentLayoutPreset layout,
    required bool isPreview,
    required List<String>? previewRecords,
  }) async {
    final templates = await _loadTemplates(layout);
    final inputs = <_DocumentPdfBlockInput>[];
    for (var index = 0; index < layout.blocks.length; index++) {
      final block = layout.blocks[index];
      final template = templates[block.templateName]!;
      final data = await collector.getRecordDataListForBlock(
        index,
        template.recordType,
        isPreview,
        previewRecords,
      );
      inputs.add(
        _DocumentPdfBlockInput(
          block: block,
          template: template,
          data: data,
        ),
      );
    }
    return inputs;
  }
}
