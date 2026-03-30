import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/pdf/services.dart';
import 'package:nahpu/services/export/site_writer.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/types/mammals.dart' as mammal_type;
import 'package:nahpu/services/types/herps.dart' as herp_type;
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:pdf/widgets.dart' as pw;

class SpecimenPdfWriter extends PdfServices {
  SpecimenPdfWriter({
    required super.ref,
    required super.pageFormat,
    required super.filePath,
    required super.pageOrientation,
  });

  Future<void> generatePdf() async {
    List<SpecimenData> specimenList =
        await SpecimenServices(ref: ref).getSpecimenList();
    generateProjectPage();
    for (var specimen in specimenList) {
      await _generateSpecimenPage(specimen);
    }
    writePdf(pdf);
  }

  Future<void> _generateSpecimenPage(SpecimenData data) async {
    pw.Widget collectingRecord = await _generateCollectingRecord(data);
    pw.Widget taxonomy = await _generateTaxonomyData(data);
    CollEventServices eventServices = CollEventServices(ref: ref);
    CollEventData? captureRecord =
        await eventServices.getCollEvent(data.collEventID);
    CollPersonnelData? collector = (data.collPersonnelID != null)
        ? await eventServices.getCollPersonnel(data.collPersonnelID!)
        : null;
    pw.Widget siteRecord = await _generateSiteRecord(captureRecord);
    pw.Widget measurements =
        await _generateMeasurements(data.uuid, data.taxonGroup ?? '');

    pw.Widget captureRecords =
        await _generateCaptureRecords(data, captureRecord, collector?.name);
    pw.Widget specimenParts = await _generateSpecimenParts(data.uuid);
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        orientation: pageOrientation,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'Specimen UUID: ${data.uuid}',
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.left,
              ),
              siteRecord,
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                      width: pageFormat.availableWidth / 2,
                      child: pw.Column(children: [
                        collectingRecord,
                        container(measurements)
                      ])),
                  pw.SizedBox(width: 8),
                  pw.SizedBox(
                    width: (pageFormat.availableWidth / 2) - 8,
                    child: pw.Column(
                      children: [
                        taxonomy,
                        captureRecords,
                        specimenParts,
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<pw.Widget> _generateSiteRecord(CollEventData? record) async {
    if (record == null) {
      return container(pw.Text('No site record'));
    }
    String verbatimLocality =
        await SiteWriterServices(ref: ref).getVerbatimLocality(record.siteID);
    List<CoordinateData> coordinates = record.siteID != null
        ? await CoordinateServices(ref: ref)
            .getCoordinatesBySiteID(record.siteID!)
        : [];
    return container(
      pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          textContent(verbatimLocality),
          pw.Column(
            children: _generateCoordinateList(coordinates),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _generateCoordinateList(List<CoordinateData> coordinates) {
    return coordinates.map((e) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          textContent(e.nameId ?? '', fontSize: 10),
          textContent(' ${e.decimalLatitude ?? ''}', fontSize: 10),
          textContent(', ${e.decimalLongitude ?? ''}', fontSize: 10),
          textContent(' ${e.elevationInMeter ?? '?'}m', fontSize: 10),
        ],
      );
    }).toList();
  }

  Future<pw.Widget> _generateSpecimenParts(String specimenUuid) async {
    List<SpecimenPartData> specimenParts =
        await SpecimenPartServices(ref: ref).getSpecimenParts(specimenUuid);

    List<pw.Widget> parts = specimenParts.map((e) {
      return pw.Column(children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            textContent(e.type ?? ''),
            textContent('Count: ${e.count ?? ''}'),
            textContent('Treatment: ${e.treatment ?? ''}'),
          ],
        ),
      ]);
    }).toList();
    return container(pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        titleText('Specimen parts'),
        pw.SizedBox(height: 10),
        pw.Column(children: parts),
      ],
    ));
  }

  Future<pw.Widget> _generateCollectingRecord(SpecimenData data) async {
    PersonnelData? cataloger = data.catalogerID != null
        ? await PersonnelServices(ref: ref)
            .getPersonnelByUuid(data.catalogerID!)
        : null;
    PersonnelData? preparator = data.preparatorID != null
        ? await PersonnelServices(ref: ref)
            .getPersonnelByUuid(data.preparatorID!)
        : null;
    return container(
      pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          titleText('Collecting records'),
          pw.SizedBox(height: 10),
          textContent('Cataloger: ${cataloger?.name ?? ''}'),
          textContent('Field number: ${data.fieldNumber ?? ''}'),
          textContent('Preparator: ${preparator?.name ?? ''}'),
          textContent('Specimen condition: ${data.condition}'),
          data.condition == 'Freshly Euthanized'
              ? textContent(
                  'Specimen collection time: ${data.collectionTime ?? ''}')
              : pw.SizedBox.shrink(),
          textContent('Preparation date: ${data.prepDate ?? ''}'),
          textContent('Preparation time: ${data.prepTime ?? ''}'),
        ],
      ),
    );
  }

  Future<pw.Widget> _generateTaxonomyData(SpecimenData data) async {
    TaxonomyData? taxonomy = data.speciesID != null
        ? await TaxonomyServices(ref: ref).getTaxonById(data.speciesID!)
        : null;
    if (taxonomy == null) {
      return container(pw.Text('No taxonomy data'));
    }
    return container(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          titleText('Taxonomy'),
          pw.SizedBox(height: 10),
          textContent('Class: ${taxonomy.taxonClass ?? ''}'),
          textContent('Order: ${taxonomy.taxonOrder ?? ''}'),
          textContent('Family: ${taxonomy.taxonFamily ?? ''}'),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              textContent('Species: '),
              textContent(
                '${taxonomy.genus ?? ''} ${taxonomy.specificEpithet ?? ''}',
                isItalic: true,
              ),
            ],
          ),
          taxonomy.commonName != null || taxonomy.commonName != ''
              ? textContent('Common name: ${taxonomy.commonName}')
              : pw.SizedBox.shrink(),
        ],
      ),
    );
  }

  Future<pw.Widget> _generateCaptureRecords(SpecimenData specimen,
      CollEventData? captureRecords, String? collector) async {
    CollEffortData? captureMethod = specimen.collMethodID != null
        ? await CollEventServices(ref: ref)
            .getCollEffort(specimen.collMethodID!)
        : null;
    return container(pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        titleText('Capture records'),
        pw.SizedBox(height: 10),
        captureMethod != null
            ? textContent('Capture method: ${captureMethod.method ?? ''}')
            : pw.SizedBox.shrink(),
        textContent('Capture date: ${specimen.captureDate ?? ''}'),
        textContent('Capture time: ${specimen.captureTime ?? ''}'),
        collector != null
            ? textContent('Collector: $collector')
            : pw.SizedBox(),
      ],
    ));
  }

  Future<pw.Widget> _generateMeasurements(
      String specimenUuid, String taxonGroup) async {
    CatalogFmt group = matchTaxonGroupToCatFmt(taxonGroup);
    switch (group) {
      case CatalogFmt.mammals:
        return _getMammalMeasurements(specimenUuid, taxonGroup);
      case CatalogFmt.birds:
        return _getAvianMeasurements(specimenUuid);
      case CatalogFmt.herpetofauna:
        return _getHerpMeasurements(specimenUuid);
    }
  }

  Future<pw.Widget> _getMammalMeasurements(
      String specimenUuid, String taxonGroup) async {
    MammalMeasurementData measurements =
        await SpecimenServices(ref: ref).getMammalMeasurementData(specimenUuid);
    String specimenAge = measurements.age != null
        ? mammal_type.specimenAgeList[measurements.age!]
        : '';
    SpecimenSex? sexEnum = getSpecimenSex(measurements.sex);
    String specimenSex =
        measurements.sex != null ? specimenSexList[measurements.sex!] : '';
    pw.Widget sexData = await _generateMammalSexData(measurements, sexEnum);
    return pw.Column(children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              titleText('Measurements'),
              pw.SizedBox(height: 10),
              textContent(
                  'Total length: ${measurements.totalLength?.truncateZero() ?? '?'} mm'),
              textContent(
                  'Tail length: ${measurements.tailLength?.truncateZero() ?? '?'} mm'),
              textContent(
                  'Hind foot length: ${measurements.hindFootLength?.truncateZero() ?? '?'} mm'),
              textContent(
                  'Ear length: ${measurements.earLength?.truncateZero() ?? '?'} mm'),
              taxonGroup == "Bats"
                  ? textContent(
                      'Forearm length: ${measurements.forearm?.truncateZero() ?? '?'} mm')
                  : pw.SizedBox.shrink(),
              textContent(
                  'Weight: ${measurements.weight?.truncateZero() ?? '?'} grams'),
              textContent('Accuracy: ${measurements.accuracy ?? '?'}'),
              textContent('Age: $specimenAge'),
              pw.SizedBox(height: 6),
              textContent('Sex: $specimenSex'),
              sexData,
              textContent('Remark:'),
              textContent(measurements.remark ?? ''),
            ],
          )
        ],
      ),
    ]);
  }

  Future<pw.Widget> _generateMammalSexData(
      MammalMeasurementData records, SpecimenSex? sexEnum) async {
    if (records.sex == null) return pw.SizedBox.shrink();

    switch (sexEnum) {
      case SpecimenSex.male:
        return _generateMaleMammalData(records);
      case SpecimenSex.female:
        return _generateFemaleMammalData(records);
      case SpecimenSex.unknown:
        return _generateUnknownMammalData(records);
      default:
        return pw.SizedBox.shrink();
    }
  }

  pw.Widget _generateMaleMammalData(MammalMeasurementData records) {
    String testisPos = records.testisPosition != null
        ? mammal_type.testisPositionList[records.testisPosition!]
        : '';
    String testisLength = records.testisLength != null
        ? '${records.testisLength?.truncateZero()} mm'
        : '';
    String testisWidth = records.testisWidth != null
        ? '${records.testisWidth?.truncateZero()} mm'
        : '';
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          textContent('Testes:'),
          pw.SizedBox(height: 6),
          textContent('Position: $testisPos'),
          textContent('Length: $testisLength'),
          textContent('Width: $testisWidth'),
        ]);
  }

  pw.Widget _generateFemaleMammalData(MammalMeasurementData records) {
    String vaginaOpening = records.vaginaOpening != null
        ? mammal_type.vaginaOpeningList[records.vaginaOpening!]
        : '';
    String mammaeCondition = records.mammaeCondition != null
        ? mammal_type.mammaeConditionList[records.mammaeCondition!]
        : '';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        textContent('Vagina opening: $vaginaOpening'),
        textContent('Mammae condition: $mammaeCondition'),
        pw.SizedBox(height: 6),
        textContent('Mammae formula:'),
        textContent('Inguinal: ${records.mammaeInguinalCount ?? ''}'),
        textContent('Abdominal: ${records.mammaeAbdominalCount ?? ''}'),
        textContent('Axillary: ${records.mammaeAxillaryCount ?? ''}'),
        pw.SizedBox(height: 6),
        textContent('Embryo:'),
        textContent('Left count: ${records.embryoLeftCount ?? ''}'),
        textContent('Right count: ${records.embryoRightCount ?? ''}'),
        textContent('CR length: ${records.embryoCR ?? ''}')
      ],
    );
  }

  pw.Widget _generateUnknownMammalData(MammalMeasurementData records) {
    return pw.Column(children: []);
  }

  Future<pw.Widget> _getAvianMeasurements(String specimenUuid) async {
    AvianMeasurementData measurements =
        await SpecimenServices(ref: ref).getAvianMeasurementData(specimenUuid);
    return pw.Column(children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              titleText('Measurements'),
              pw.SizedBox(height: 10),
              textContent('Weight: ${measurements.weight ?? '?'} grams'),
              textContent('Wingspan: ${measurements.wingspan ?? '?'} mm'),
            ],
          )
        ],
      ),
    ]);
  }

  Future<pw.Widget> _getHerpMeasurements(String specimenUuid) async {
    HerpMeasurementData measurements =
        await SpecimenServices(ref: ref).getHerpMeasurementData(specimenUuid);
    String specimenAge = measurements.age != null
        ? herp_type.specimenAgeList[measurements.age!]
        : '';
    String specimenSex =
        measurements.sex != null ? specimenSexList[measurements.sex!] : '';
    return pw.Column(children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              titleText('Measurements'),
              pw.SizedBox(height: 10),
              textContent('Sex: $specimenSex'),
              textContent('Age: $specimenAge'),
              pw.SizedBox(height: 6),
              textContent(
                  'Weight: ${measurements.weight?.truncateZero() ?? '?'} grams'),
              textContent('SVL: ${measurements.svl?.truncateZero() ?? '?'} cm'),
              pw.SizedBox(height: 6),
              textContent('Remark:'),
              textContent(measurements.remark ?? ''),
            ],
          )
        ],
      ),
    ]);
  }
}
