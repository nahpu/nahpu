import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/specimen_services.dart';

import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class ExportDocumentService {
  const ExportDocumentService({this.ref});

  final WidgetRef? ref;

  /// Merges the previous column order with the newly selected columns.
  List<String> mergeColumnOrder(
    List<String> previousOrder,
    Set<String> selected,
  ) {
    final out = <String>[];
    final sel = {...selected};
    for (final id in previousOrder) {
      if (sel.remove(id)) out.add(id);
    }
    final rest = sel.toList()
      ..sort((a, b) => specimenColumnDisplayTitle(a)
          .toLowerCase()
          .compareTo(specimenColumnDisplayTitle(b).toLowerCase()));
    out.addAll(rest);
    return out;
  }

  /// Exports documents to PDF using the provided parameters.
  Future<File> exportDocuments({
    required Set<String> selectedSpecimens,
    required Directory selectedDir,
    required String fileStem,
    required rust_config.DocumentLayoutPreset layout,
  }) async {
    if (ref == null) {
      throw Exception('WidgetRef is required for exporting');
    }
    final all = await SpecimenServices(ref: ref!).getSpecimenList();
    final picked = all
        .where((s) => selectedSpecimens.contains(s.uuid))
        .toList(growable: false);

    if (picked.isEmpty) {
      throw Exception('Select at least one specimen');
    }

    return await DocumentWriter(ref: ref!).writeDocuments(
      picked: picked,
      selectedDir: selectedDir,
      fileStem: fileStem,
      layout: layout,
    );
  }
}
