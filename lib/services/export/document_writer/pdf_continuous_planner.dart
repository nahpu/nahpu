part of '../document_writer.dart';

class _DocumentPdfContinuousPlanner {
  const _DocumentPdfContinuousPlanner();

  List<_DocumentContinuousPrintItem> plan({
    required List<_DocumentPdfBlockInput> blocks,
    required String multiBlockMode,
  }) {
    final items = <_DocumentContinuousPrintItem>[];
    if (multiBlockMode == 'Alternate') {
      _appendAlternate(items: items, blocks: blocks);
    } else {
      _appendGrouped(items: items, blocks: blocks);
    }
    return items;
  }

  void _appendAlternate({
    required List<_DocumentContinuousPrintItem> items,
    required List<_DocumentPdfBlockInput> blocks,
  }) {
    final maxLength = blocks.fold<int>(
      0,
      (max, block) => math.max(max, block.data.length),
    );
    for (var index = 0; index < maxLength; index++) {
      for (final block in blocks) {
        if (index >= block.data.length) continue;
        _appendRecordCopies(
          items: items,
          block: block,
          data: block.data[index],
        );
      }
    }
  }

  void _appendGrouped({
    required List<_DocumentContinuousPrintItem> items,
    required List<_DocumentPdfBlockInput> blocks,
  }) {
    for (final block in blocks) {
      for (final data in block.data) {
        _appendRecordCopies(items: items, block: block, data: data);
      }
    }
  }

  void _appendRecordCopies({
    required List<_DocumentContinuousPrintItem> items,
    required _DocumentPdfBlockInput block,
    required Map<String, String> data,
  }) {
    final profile = block.profile;
    for (var copy = 0; copy < block.block.templateCount; copy++) {
      items.add(
        _DocumentContinuousPrintItem(
          data: data,
          template: block.template,
          pageTemplate: block.template.page1,
          block: block.block,
          profile: profile,
          mirror: profile.mirrorFront,
        ),
      );
      if (profile.duplex) {
        items.add(
          _DocumentContinuousPrintItem(
            data: data,
            template: block.template,
            pageTemplate: block.template.page2,
            block: block.block,
            profile: profile,
            mirror: profile.mirrorBack,
          ),
        );
      }
    }
  }
}
