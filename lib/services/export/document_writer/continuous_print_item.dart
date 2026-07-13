part of '../document_writer.dart';

class _DocumentContinuousPrintItem {
  _DocumentContinuousPrintItem({
    required this.data,
    required this.template,
    required this.pageTemplate,
    required this.block,
    required this.profile,
    required this.mirror,
  });
  final Map<String, String> data;
  final Template template;
  final TemplatePage pageTemplate;
  final rust_config.DocumentLayoutBlock block;
  final _DocumentTemplateRenderProfile profile;
  final bool mirror;
}
