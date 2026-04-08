import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/print_labels/label_template_model.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/label_settings_services.dart';
import 'package:nahpu/services/label_template_service.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

double labelPdfMmToPt(double mm) => mm * 72.0 / 25.4;

class LabelPrintLayoutOptions {
  const LabelPrintLayoutOptions({
    required this.rowsPerPage,
    required this.colsPerPage,
    required this.pagePadTopMm,
    required this.pagePadLeftMm,
    required this.pagePadRightMm,
    required this.pagePadBottomMm,
    required this.labelPadTopMm,
    required this.labelPadLeftMm,
    required this.labelPadRightMm,
    required this.labelPadBottomMm,
  });

  final int rowsPerPage;
  final int colsPerPage;
  final double pagePadTopMm;
  final double pagePadLeftMm;
  final double pagePadRightMm;
  final double pagePadBottomMm;
  final double labelPadTopMm;
  final double labelPadLeftMm;
  final double labelPadRightMm;
  final double labelPadBottomMm;
}

void _paintPdfLabelOutline(
  PdfGraphics canvas,
  PdfPoint size,
  LabelTemplateOutline o,
) {
  final sx = size.x;
  final sy = size.y;
  final w = o.widthPt.clamp(0.1, 12.0);
  final color = PdfColor.fromInt(o.colorArgb);
  final half = w / 2;

  void strokeRect(PdfRect rect, List<num>? dash) {
    canvas.saveContext();
    if (dash != null && dash.isNotEmpty) {
      canvas.setLineDashPattern(dash, 0);
    } else {
      canvas.setLineDashPattern();
    }
    canvas
      ..setStrokeColor(color)
      ..setLineWidth(w)
      ..setLineJoin(PdfLineJoin.miter)
      ..setMiterLimit(4)
      ..drawBox(rect)
      ..strokePath();
    canvas.restoreContext();
  }

  final outer = PdfRect(half, half, sx - w, sy - w);

  switch (o.style) {
    case LabelTemplateOutlineStyle.solid:
      strokeRect(outer, null);
      break;
    case LabelTemplateOutlineStyle.dashed:
      strokeRect(outer, [3 * w, 2 * w]);
      break;
    case LabelTemplateOutlineStyle.dotted:
      strokeRect(outer, [w * 0.35, w * 2]);
      break;
    case LabelTemplateOutlineStyle.doubleLine:
      strokeRect(outer, null);
      final gap = math.max(1.0, w * 1.25);
      final inset = w + gap;
      final iw = sx - 2 * inset - w;
      final ih = sy - 2 * inset - w;
      if (iw > 0 && ih > 0) {
        final inner = PdfRect(inset + half, inset + half, iw, ih);
        strokeRect(inner, null);
      }
      break;
  }
}

/// Uniform scale (≤ 1) so at least one label fits the printable area, then
/// [cols]×[rows] tiles at [cellW]×[cellH] for the maximum count at that scale.
({int cols, int rows, double cellW, double cellH}) _labelSheetGrid({
  required double usableW,
  required double usableH,
  required double labelWPt,
  required double labelHPt,
}) {
  if (!usableW.isFinite ||
      !usableH.isFinite ||
      usableW <= 0 ||
      usableH <= 0 ||
      labelWPt <= 0 ||
      labelHPt <= 0) {
    return (
      cols: 1,
      rows: 1,
      cellW: labelWPt,
      cellH: labelHPt,
    );
  }
  final fitScale = math.min(
    1.0,
    math.min(usableW / labelWPt, usableH / labelHPt),
  );
  final s = fitScale <= 0 ? 1e-6 : fitScale;
  final cellW = labelWPt * s;
  final cellH = labelHPt * s;
  final cols = math.max(1, (usableW / cellW).floor());
  final rows = math.max(1, (usableH / cellH).floor());
  return (cols: cols, rows: rows, cellW: cellW, cellH: cellH);
}

class LabelPdfService {
  LabelPdfService({required this.ref});

  final WidgetRef ref;

  Database get _db => ref.read(databaseProvider);

  Future<Uint8List> generateLabelsPdf(
    List<SpecimenData> specimens, {
    LabelTemplate? template,
    required PdfPageFormat sheetFormat,
    LabelPrintLayoutOptions? layout,
  }) async {
    final settings = LabelSettingsServices();
    final wMm = await settings.getLabelWidthMm();
    final hMm = await settings.getLabelHeightMm();
    final duplex = await settings.getDuplex();
    final mirrorFront = await settings.getMirrorFront();
    final mirrorBack = await settings.getMirrorBack();
    final tmpl =
        template ?? await const LabelTemplateService().getCurrentTemplate();

    final wPt = labelPdfMmToPt(wMm);
    final hPt = labelPdfMmToPt(hMm);

    final doc = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    final pagePadTopPt = labelPdfMmToPt(layout?.pagePadTopMm ?? 0);
    final pagePadLeftPt = labelPdfMmToPt(layout?.pagePadLeftMm ?? 0);
    final pagePadRightPt = labelPdfMmToPt(layout?.pagePadRightMm ?? 0);
    final pagePadBottomPt = labelPdfMmToPt(layout?.pagePadBottomMm ?? 0);
    final labelPadTopPt = labelPdfMmToPt(layout?.labelPadTopMm ?? 0);
    final labelPadLeftPt = labelPdfMmToPt(layout?.labelPadLeftMm ?? 0);
    final labelPadRightPt = labelPdfMmToPt(layout?.labelPadRightMm ?? 0);
    final labelPadBottomPt = labelPdfMmToPt(layout?.labelPadBottomMm ?? 0);
    final usableW = math.max(1.0, sheetFormat.width - pagePadLeftPt - pagePadRightPt);
    final usableH = math.max(1.0, sheetFormat.height - pagePadTopPt - pagePadBottomPt);
    final forcedRows = layout?.rowsPerPage ?? 0;
    final forcedCols = layout?.colsPerPage ?? 0;
    final grid = forcedRows > 0 && forcedCols > 0
        ? (
            cols: forcedCols,
            rows: forcedRows,
            cellW: usableW / forcedCols,
            cellH: usableH / forcedRows,
          )
        : _labelSheetGrid(
            usableW: usableW,
            usableH: usableH,
            labelWPt: wPt,
            labelHPt: hPt,
          );
    final perSheet = grid.cols * grid.rows;
    if (specimens.isEmpty) {
      doc.addPage(
        pw.Page(
          pageFormat: sheetFormat,
          build: (_) => pw.Center(child: pw.Text('No labels')),
        ),
      );
      return doc.save();
    }

    for (var start = 0; start < specimens.length; start += perSheet) {
      final end = math.min(start + perSheet, specimens.length);
      final batch = specimens.sublist(start, end);

      final fronts = <LabelPageTemplate>[];
      final frontData = <Map<String, String>>[];
      final backs = <LabelPageTemplate>[];
      final backData = <Map<String, String>>[];
      for (final specimen in batch) {
        final data = await fieldValuesForSpecimen(_db, specimen);
        fronts.add(await _substitutePage(tmpl.page1, data));
        frontData.add(data);
        if (duplex) {
          backs.add(await _substitutePage(tmpl.page2, data));
          backData.add(data);
        }
      }

      doc.addPage(
        pw.Page(
          pageFormat: sheetFormat,
          build: (ctx) => _tiledLabelSheet(
            ctx,
            sheetFormat,
            grid,
            pagePadTopPt,
            pagePadLeftPt,
            labelPadTopPt,
            labelPadLeftPt,
            labelPadRightPt,
            labelPadBottomPt,
            fronts,
            frontData,
            mirrorFront,
            wPt,
            hPt,
            font,
            fontBold,
            tmpl.outline,
          ),
        ),
      );

      if (duplex) {
        doc.addPage(
          pw.Page(
            pageFormat: sheetFormat,
            build: (ctx) => _tiledLabelSheet(
              ctx,
              sheetFormat,
              grid,
              pagePadTopPt,
              pagePadLeftPt,
              labelPadTopPt,
              labelPadLeftPt,
              labelPadRightPt,
              labelPadBottomPt,
              backs,
              backData,
              mirrorBack,
              wPt,
              hPt,
              font,
              fontBold,
              tmpl.outline,
            ),
          ),
        );
      }
    }

    return doc.save();
  }

  pw.Widget _tiledLabelSheet(
    pw.Context ctx,
    PdfPageFormat sheetFormat,
    ({int cols, int rows, double cellW, double cellH}) grid,
    double pagePadTopPt,
    double pagePadLeftPt,
    double labelPadTopPt,
    double labelPadLeftPt,
    double labelPadRightPt,
    double labelPadBottomPt,
    List<LabelPageTemplate> pages,
    List<Map<String, String>> fieldDataPerPage,
    bool mirror,
    double wPt,
    double hPt,
    pw.Font font,
    pw.Font fontBold,
    LabelTemplateOutline? labelOutline,
  ) {
    final children = <pw.Widget>[];
    for (var i = 0; i < pages.length; i++) {
      final c = i % grid.cols;
      final r = i ~/ grid.cols;
      final data = i < fieldDataPerPage.length
          ? fieldDataPerPage[i]
          : <String, String>{};
      children.add(
        pw.Positioned(
          left: pagePadLeftPt + c * grid.cellW,
          top: pagePadTopPt + r * grid.cellH,
          child: pw.SizedBox(
            width: grid.cellW,
            height: grid.cellH,
            child: pw.Padding(
              padding: pw.EdgeInsets.fromLTRB(
                labelPadLeftPt,
                labelPadTopPt,
                labelPadRightPt,
                labelPadBottomPt,
              ),
              child: pw.FittedBox(
                fit: pw.BoxFit.contain,
                alignment: pw.Alignment.topLeft,
                child: _buildLabelPage(
                  ctx,
                  pages[i],
                  data,
                  wPt,
                  hPt,
                  mirror,
                  font,
                  fontBold,
                  labelOutline,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return pw.Stack(children: children);
  }

  Future<LabelPageTemplate> _substitutePage(
    LabelPageTemplate page,
    Map<String, String> data,
  ) async {
    final texts = <CustomTextElement>[];
    for (final ct in page.customTexts) {
      texts.add(ct.copyWith(text: _substitute(ct.text, data)));
    }
    return page.copyWith(customTexts: texts);
  }

  String _substitute(String input, Map<String, String> data) {
    return substituteLabelPlaceholders(input, data);
  }

  pw.Widget _buildLabelPage(
    pw.Context context,
    LabelPageTemplate page,
    Map<String, String> fieldData,
    double wPt,
    double hPt,
    bool mirror,
    pw.Font font,
    pw.Font fontBold,
    LabelTemplateOutline? labelOutline,
  ) {
    final children = <pw.Widget>[];

    for (final im in page.customImages) {
      if (!isLabelImagePathUsable(im.imagePath)) continue;
      final f = File(im.imagePath);
      try {
        final bytes = f.readAsBytesSync();
        children.add(
          pw.Positioned(
            left: labelPdfMmToPt(im.xMm),
            top: labelPdfMmToPt(im.yMm),
            child: pw.Transform.rotate(
              angle: im.rotationDegrees * math.pi / 180,
              child: pw.Image(
                pw.MemoryImage(bytes),
                width: labelPdfMmToPt(im.widthMm),
                height: labelPdfMmToPt(im.heightMm),
                fit: pw.BoxFit.contain,
              ),
            ),
          ),
        );
      } catch (_) {}
    }

    for (final t in page.customTexts) {
      final gKey = labelGenderIconFieldKeyFromBracketText(t.text);
      if (gKey != null) {
        final wMm = t.iconWidthMm ?? kLabelGenderIconDefaultWidthMm;
        final hMm = t.iconHeightMm ?? kLabelGenderIconDefaultHeightMm;
        final wPtBox = labelPdfMmToPt(wMm);
        final hPtBox = labelPdfMmToPt(hMm);
        final display = _fieldValueCi(fieldData, gKey);
        children.add(
          pw.Positioned(
            left: labelPdfMmToPt(t.xMm),
            top: labelPdfMmToPt(t.yMm),
            child: pw.Transform.rotate(
              angle: t.rotationDegrees * math.pi / 180,
              child: _pwGenderIcon(display, wPtBox, hPtBox),
            ),
          ),
        );
        continue;
      }
      final fs = t.fontSizePt;
      children.add(
        pw.Positioned(
          left: labelPdfMmToPt(t.xMm),
          top: labelPdfMmToPt(t.yMm),
          child: pw.Transform.rotate(
            angle: t.rotationDegrees * math.pi / 180,
            child: pw.Text(
              t.text,
              style: pw.TextStyle(
                font: t.bold ? fontBold : font,
                fontSize: fs,
                fontStyle: t.italic ? pw.FontStyle.italic : pw.FontStyle.normal,
              ),
            ),
          ),
        ),
      );
    }

    final outline = labelOutline;
    final stackChildren = <pw.Widget>[
      ...children,
      if (outline != null)
        pw.Positioned.fill(
          child: pw.CustomPaint(
            painter: (c, sz) => _paintPdfLabelOutline(c, sz, outline),
          ),
        ),
    ];
    final stack = pw.Stack(children: stackChildren);

    if (!mirror) {
      return pw.SizedBox(width: wPt, height: hPt, child: stack);
    }

    return pw.SizedBox(
      width: wPt,
      height: hPt,
      child: pw.Transform.rotate(
        angle: math.pi,
        child: pw.SizedBox(width: wPt, height: hPt, child: stack),
      ),
    );
  }

  String _fieldValueCi(Map<String, String> m, String key) {
    if (m.containsKey(key)) return m[key] ?? '';
    final low = key.toLowerCase();
    for (final e in m.entries) {
      if (e.key.toLowerCase() == low) return e.value;
    }
    return '';
  }

  pw.Widget _pwGenderIcon(String displaySex, double wPt, double hPt) {
    final s = displaySex.trim().toLowerCase();
    final ch = s == 'male'
        ? '\u2642'
        : s == 'female'
            ? '\u2640'
            : '?';
    final fs = math.min(wPt, hPt) * 0.88;
    return pw.SizedBox(
      width: wPt,
      height: hPt,
      child: pw.Center(
        child: pw.Text(
          ch,
          style: pw.TextStyle(fontSize: fs),
        ),
      ),
    );
  }
}

String _measurementValueForLabel(String columnName, Object? raw) {
  if (raw == null) return '';
  if (columnName == 'sex') {
    final idx = raw is int ? raw : (raw is num ? raw.toInt() : -1);
    if (idx >= 0 && idx < specimenSexList.length) {
      return specimenSexList[idx];
    }
  }
  if (raw is double) {
    if (raw.isNaN || raw.isInfinite) return '';
    if (raw == raw.roundToDouble()) return raw.toInt().toString();
    return raw.toString();
  }
  return raw.toString();
}

void _mergeMeasurementRowToLabelMap(
  String prefix,
  Map<String, dynamic> json,
  Map<String, String> target,
) {
  for (final e in json.entries) {
    if (e.key == 'specimenUuid') continue;
    final v = e.value;
    if (v == null) continue;
    target['$prefix.${e.key}'] =
        _measurementValueForLabel(e.key, v as Object?);
  }
}

/// Replaces `[fieldId]` tokens using [data] (case-insensitive key match).
String substituteLabelPlaceholders(String input, Map<String, String> data) {
  if (isLabelBracketGenderIconText(input)) return input;
  return input.replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (m) {
    final k = m.group(1)!.trim();
    if (data.containsKey(k)) return data[k]!;
    final lower = k.toLowerCase();
    for (final e in data.entries) {
      if (e.key.toLowerCase() == lower) return e.value;
    }
    return m.group(0)!;
  });
}

/// Resolved values for label placeholders and the print-labels table (same keys
/// as `[field]` in templates).
Future<Map<String, String>> fieldValuesForSpecimen(
  Database db,
  SpecimenData s,
) async {
  final m = <String, String>{};

  void put(String k, Object? v) {
    m[k] = v == null ? '' : v.toString();
  }

  put('uuid', s.uuid);
  put('projectUuid', s.projectUuid);
  put('speciesID', s.speciesID);
  put('iDConfidence', s.iDConfidence);
  put('iDMethod', s.iDMethod);
  put('taxonGroup', s.taxonGroup);
  put('condition', s.condition);
  put('prepDate', s.prepDate);
  put('prepTime', s.prepTime);
  put('collectionDate', s.collectionDate);
  put('collectionTime', s.collectionTime);
  put('captureDate', s.captureDate);
  put('isRelativeTime', s.isRelativeTime);
  put('captureTime', s.captureTime);
  put('relativeCaptureTime', s.relativeCaptureTime);
  put('trapType', s.trapType);
  put('methodID', s.methodID);
  put('coordinateID', s.coordinateID);
  put('catalogerID', s.catalogerID);
  put('fieldNumber', s.fieldNumber);
  put('collEventID', s.collEventID);
  put('isMultipleCollector', s.isMultipleCollector);
  put('collPersonnelID', s.collPersonnelID);
  put('collMethodID', s.collMethodID);
  put('museumID', s.museumID);
  put('preparatorID', s.preparatorID);

  put('fieldNumber', s.fieldNumber);
  put('catalogNum', s.fieldNumber?.toString() ?? '');

  final personnelQuery = PersonnelQuery(db);
  String fieldId = s.uuid;
  if (s.catalogerID != null) {
    try {
      final initial = await personnelQuery.getInitial(s.catalogerID!);
      fieldId = '${initial ?? ''}${s.fieldNumber ?? ''}';
      if (fieldId.isEmpty) fieldId = s.uuid;
    } catch (_) {
      fieldId = s.fieldNumber?.toString() ?? s.uuid;
    }
  } else if (s.fieldNumber != null) {
    fieldId = s.fieldNumber.toString();
  }
  put('fieldId', fieldId);

  String genus = '';
  String specificEpithet = '';
  String species = '';
  if (s.speciesID != null) {
    try {
      final tax = await TaxonomyQuery(db).getTaxonById(s.speciesID!);
      genus = tax.genus ?? '';
      specificEpithet = tax.specificEpithet ?? '';
      species = '${genus} ${specificEpithet}'.trim();
      put('taxonClass', tax.taxonClass);
      put('taxonOrder', tax.taxonOrder);
      put('taxonFamily', tax.taxonFamily);
      put('commonName', tax.commonName);
    } catch (_) {}
  }
  put('species', species);
  put('genus', genus);
  put('specificEpithet', specificEpithet);

  String locality = '';
  String site = '';
  if (s.collEventID != null) {
    try {
      final ev = await CollEventQuery(db).getCollEventById(s.collEventID!);
      if (ev.siteID != null) {
        final siteData = await SiteQuery(db).getSiteById(ev.siteID!);
        site = siteData.siteID ?? '';
        locality = siteData.locality ??
            siteData.habitatType ??
            siteData.municipality ??
            '';
      }
    } catch (_) {}
  }
  put('locality', locality);
  put('site', site);

  String coordinates = '';
  if (s.coordinateID != null) {
    try {
      final c = await CoordinateQuery(db).getCoordinateById(s.coordinateID!);
      coordinates =
          '${c.decimalLatitude ?? ''} ${c.decimalLongitude ?? ''}'.trim();
    } catch (_) {}
  }
  put('coordinates', coordinates);

  String cataloger = '';
  if (s.catalogerID != null) {
    try {
      cataloger = await personnelQuery.getPersonnelName(s.catalogerID!) ?? '';
    } catch (_) {}
  }
  put('cataloger', cataloger);

  String preparator = '';
  if (s.preparatorID != null) {
    try {
      preparator = await personnelQuery.getPersonnelName(s.preparatorID!) ?? '';
    } catch (_) {}
  }
  put('preparator', preparator);

  put('collector', '');

  String backOfTag = '';
  String tissueId = '';
  try {
    final parts = await SpecimenPartQuery(db).getSpecimenParts(s.uuid);
    if (parts.isNotEmpty) {
      final first = parts.first;
      backOfTag = first.type ?? '';
      tissueId = first.tissueID ?? '';
    }
  } catch (_) {}
  put('backOfTag', backOfTag);
  put('tissueId', tissueId);

  try {
    final row =
        await MammalSpecimenQuery(db).getMammalMeasurementByUuid(s.uuid);
    _mergeMeasurementRowToLabelMap('mammal', row.toJson(), m);
  } catch (_) {}
  try {
    final row =
        await AvianSpecimenQuery(db).getAvianMeasurementByUuid(s.uuid);
    _mergeMeasurementRowToLabelMap('avian', row.toJson(), m);
  } catch (_) {}
  try {
    final row =
        await HerpSpecimenQuery(db).getHerpMeasurementByUuid(s.uuid);
    _mergeMeasurementRowToLabelMap('herp', row.toJson(), m);
  } catch (_) {}

  for (final id in labelTemplateAvailableFieldIds(db)) {
    m.putIfAbsent(id, () => '');
  }
  return m;
}
