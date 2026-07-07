part of '../document_writer.dart';

class _ContinuousPrintItemGeneric<T> {
  _ContinuousPrintItemGeneric({
    required this.record,
    required this.template,
    required this.pageTemplate,
    required this.block,
    required this.mirror,
  });
  final T record;
  final Template template;
  final TemplatePage pageTemplate;
  final rust_config.DocumentLayoutBlock block;
  final bool mirror;
}

class _ContinuousPrintItem {
  _ContinuousPrintItem({
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
