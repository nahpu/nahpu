part of '../document_writer.dart';

class _DocumentContinuousPrintItem {
  _DocumentContinuousPrintItem({
    required this.data,
    required this.template,
    required this.pageTemplate,
    required this.block,
    required this.mirror,
  });
  final Map<String, String> data;
  final Template template;
  final TemplatePage pageTemplate;
  final rust_config.DocumentLayoutBlock block;
  final bool mirror;
}
