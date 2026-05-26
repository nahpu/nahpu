import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/pdf/services.dart';
import 'package:nahpu/services/export/site_writer.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:pdf/widgets.dart' as pw;

class NarrativePdfWriter extends PdfServices {
  NarrativePdfWriter({
    required super.ref,
    required super.pageFormat,
    required super.filePath,
    required super.pageOrientation,
  });

  Future<void> generatePdf() async {
    List<NarrativeData> narrativeList =
        await NarrativeServices(ref: ref).getAllNarrative();

    if (narrativeList.isEmpty) {
      throw Exception('No narrative records to export.');
    }

    for (var narrative in narrativeList) {
      await generateNarrativePage(pdf, narrative);
    }

    await writePdf(pdf);
  }

  Future<void> generateNarrativePage(
      pw.Document pdf, NarrativeData data) async {
    String verbatimLocality =
        await SiteWriterServices(ref: ref).getVerbatimLocality(data.siteID);
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        orientation: pageOrientation,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Text(
              data.date ?? 'No date',
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.left,
            ),
            container(pw.Text(
              verbatimLocality,
              style: const pw.TextStyle(fontSize: 12),
            )),
            container(
              pw.Text(
                data.narrative ?? 'No narrative',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
