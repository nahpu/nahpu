import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/export.dart' as rust_export;
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/specimen_services.dart';

class DocumentExportServices {
  final WidgetRef ref;
  DocumentExportServices({required this.ref});

  Future<Uint8List> generateBytes({
    required DocumentExportType type,
    required DocumentExportFmt format,
  }) async {
    Map<String, dynamic> exportData = {};

    switch (type) {
      case DocumentExportType.narrative:
        List<NarrativeData> data =
            await NarrativeServices(ref: ref).getAllNarrative();
        exportData['narrative'] = data.map((e) => e.toJson()).toList();
        break;
      case DocumentExportType.site:
        List<SiteData> data = await SiteServices(ref: ref).getAllSites();
        exportData['sites'] = data.map((e) => e.toJson()).toList();
        break;
      case DocumentExportType.event:
        List<CollEventData> data =
            await CollEventServices(ref: ref).getAllCollEvents();
        exportData['events'] = data.map((e) => e.toJson()).toList();
        break;
      case DocumentExportType.specimen:
        List<SpecimenData> data =
            await SpecimenServices(ref: ref).getSpecimenList();
        exportData['specimens'] = data.map((e) => e.toJson()).toList();
        break;
    }

    String jsonContent = jsonEncode(exportData);
    List<Uint8List> fontBytesList = [];

    if (format == DocumentExportFmt.pdf) {
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> fontAssets = manifest.listAssets()
          .where((String key) => key.startsWith('assets/fonts/') && key.endsWith('.ttf') && !key.contains('nahpu_font.ttf'))
          .toList();

      for (var asset in fontAssets) {
        final byteData = await rootBundle.load(asset);
        fontBytesList.add(byteData.buffer.asUint8List());
      }
    }

    String formatStr = format.name; // 'md', 'typ', 'pdf'
    
    final bytes = await rust_export.generateDocument(
        jsonContent: jsonContent,
        exportFormat: formatStr,
        fontBytes: fontBytesList,
    );
    
    return bytes;
  }

  Future<void> exportDocument({
    required File file,
    required DocumentExportType type,
    required DocumentExportFmt format,
  }) async {
    final bytes = await generateBytes(type: type, format: format);
    await file.writeAsBytes(bytes);
  }
}
