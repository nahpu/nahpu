import 'dart:io';

import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfServices extends AppServices {
  PdfServices({
    required super.ref,
    required this.pageFormat,
    required this.filePath,
    required this.pageOrientation,
  });

  final PdfPageFormat pageFormat;
  final pw.PageOrientation pageOrientation;
  final File filePath;
  final pdf = pw.Document();

  Future<void> writePdf(pw.Document pdf) async {
    await filePath.writeAsBytes(await pdf.save());
  }

  Future<void> generateProjectPage() async {
    ProjectData projectData =
        await ProjectServices(ref: ref).getProjectByUuid(currentProjectUuid);
    return pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        orientation: pageOrientation,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  projectData.name,
                  style: const pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.left,
                ),
                pw.Text(
                  projectData.description ?? '',
                  style: const pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.left,
                ),
                pw.Text(
                  projectData.uuid,
                  style: const pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.left,
                ),
                pw.Text(
                  '${projectData.startDate} - ${projectData.endDate}',
                  style: const pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.left,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  pw.Widget textContent(String text,
      {double fontSize = 12, bool isItalic = false}) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 11,
        fontStyle: isItalic ? pw.FontStyle.italic : pw.FontStyle.normal,
      ),
      textAlign: pw.TextAlign.left,
    );
  }

  pw.Widget titleText(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      textAlign: pw.TextAlign.left,
    );
  }

  pw.Widget container(pw.Widget widget) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Container(
        width: pageFormat.availableWidth,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        padding: const pw.EdgeInsets.all(8),
        constraints: const pw.BoxConstraints(maxWidth: 500),
        child: widget,
      ),
    );
  }
}
