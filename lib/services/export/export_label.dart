import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/template_editor/label_template_model.dart';
import 'package:nahpu/services/export/label_writer.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/specimen_services.dart';

class ExportLabelService {
  const ExportLabelService({this.ref});

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

  /// Exports labels to PDF using the provided parameters.
  Future<void> exportLabels({
    required Set<String> selectedSpecimens,
    required Directory selectedDir,
    required String fileStem,
    required LabelTemplate? template,
    required String pageSizeKey,
    required String pageOrientation,
    required double customPageWidthMm,
    required double customPageHeightMm,
    required int rowsPerPage,
    required int colsPerPage,
    required double pagePadTopMm,
    required double pagePadLeftMm,
    required double pagePadRightMm,
    required double pagePadBottomMm,
    required double labelPadTopMm,
    required double labelPadLeftMm,
    required double labelPadRightMm,
    required double labelPadBottomMm,
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

    await LabelWriter(ref: ref!).writeLabels(
      picked: picked,
      selectedDir: selectedDir,
      fileStem: fileStem,
      template: template,
      pageSizeKey: pageSizeKey,
      pageOrientation: pageOrientation,
      customPageWidthMm: customPageWidthMm,
      customPageHeightMm: customPageHeightMm,
      layout: LabelPrintLayoutOptions(
        rowsPerPage: rowsPerPage,
        colsPerPage: colsPerPage,
        pagePadTopMm: pagePadTopMm,
        pagePadLeftMm: pagePadLeftMm,
        pagePadRightMm: pagePadRightMm,
        pagePadBottomMm: pagePadBottomMm,
        labelPadTopMm: labelPadTopMm,
        labelPadLeftMm: labelPadLeftMm,
        labelPadRightMm: labelPadRightMm,
        labelPadBottomMm: labelPadBottomMm,
      ),
    );
  }
}
