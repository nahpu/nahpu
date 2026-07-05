import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/template_service.dart';
import 'package:nahpu/services/providers/document_selection.dart';

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
    required Directory selectedDir,
    required String fileStem,
    required rust_config.DocumentLayoutPreset layout,
  }) async {
    if (ref == null) {
      throw Exception('WidgetRef is required for exporting');
    }

    String recordType = 'specimen';
    if (layout.blocks.isNotEmpty) {
      final tmpl = await const TemplateService()
          .getTemplate(layout.blocks.first.templateName);
      if (tmpl != null) {
        recordType = tmpl.recordType;
      }
    }

    final writer = DocumentWriter(ref: ref!);

    if (recordType == 'specimen') {
      final selectedSpecimens = ref!.read(documentSpecimenSelectionProvider);
      final all = await SpecimenServices(ref: ref!).getSpecimenList();
      final picked = all
          .where((s) => selectedSpecimens.contains(s.uuid))
          .toList(growable: false);
      if (picked.isEmpty) {
        throw Exception('Select at least one specimen');
      }
      return await writer.writeDocuments(
        picked: picked,
        selectedDir: selectedDir,
        fileStem: fileStem,
        layout: layout,
      );
    } else if (recordType == 'site') {
      final selectedSites = ref!.read(documentSiteSelectionProvider);
      final all = await SiteServices(ref: ref!).getAllSites();
      final picked = all
          .where((s) => selectedSites.contains(s.id))
          .toList(growable: false);
      if (picked.isEmpty) {
        throw Exception('Select at least one site');
      }
      return await writer.writeSites(
        picked: picked,
        selectedDir: selectedDir,
        fileStem: fileStem,
        layout: layout,
      );
    } else if (recordType == 'collEvent') {
      final selectedEvents = ref!.read(documentEventSelectionProvider);
      final all = await CollEventServices(ref: ref!).getAllCollEvents();
      final picked = all
          .where((s) => selectedEvents.contains(s.id))
          .toList(growable: false);
      if (picked.isEmpty) {
        throw Exception('Select at least one event');
      }
      return await writer.writeEvents(
        picked: picked,
        selectedDir: selectedDir,
        fileStem: fileStem,
        layout: layout,
      );
    } else if (recordType == 'narrative') {
      final selectedNarratives = ref!.read(documentNarrativeSelectionProvider);
      final all = await NarrativeServices(ref: ref!).getAllNarrative();
      final picked = all
          .where((s) => selectedNarratives.contains(s.id))
          .toList(growable: false);
      if (picked.isEmpty) {
        throw Exception('Select at least one narrative');
      }
      return await writer.writeNarratives(
        picked: picked,
        selectedDir: selectedDir,
        fileStem: fileStem,
        layout: layout,
      );
    } else {
      throw Exception('Unsupported record type: $recordType');
    }
  }
}
