import 'dart:io';

import 'package:nahpu/services/statistics/spatial.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/src/rust/api/export.dart';

class StatisticsTableExporter {
  const StatisticsTableExporter();

  Future<void> write(
    File file,
    ExportFmt format,
    List<StatisticTableRow> rows,
  ) {
    return writeRows(
      file,
      format,
      headers: const ['Rank', 'Category', 'Count', 'Percent (%)'],
      rows: [
        for (final row in rows)
          [
            row.rank.toString(),
            row.category,
            row.count.toString(),
            row.percent.toStringAsFixed(2),
          ],
      ],
    );
  }

  Future<void> writeRows(
    File file,
    ExportFmt format, {
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    if (format == ExportFmt.json) {
      throw ArgumentError('Statistics tables do not support JSON export.');
    }
    return writeTabularRecords(
      headers: headers,
      rows: rows,
      outputPath: file.path,
      exportFormat: format.name,
    );
  }
}

List<String> spatialStatisticExportHeaders(SpatialStatisticKind kind) =>
    kind.hasCounts
    ? const [
        'Name',
        'Locality',
        'Latitude',
        'Longitude',
        'Elevation (m)',
        'Count',
        'Percent (%)',
      ]
    : const [
        'Name',
        'Locality',
        'Decimal Latitude',
        'Decimal Longitude',
        'Elevation (m)',
        'Datum',
        'Uncertainty (m)',
        'GPS Unit',
        'Notes',
      ];

List<List<String>> buildSpatialStatisticExportRows(
  SpatialStatisticKind kind,
  List<SpatialStatisticDatum> rows,
) {
  final total = spatialStatisticTotal(rows);
  return [
    for (final row in rows)
      if (kind.hasCounts)
        [
          row.displayName,
          formatCoordinateText(row.locality),
          formatCoordinate(row.decimalLatitude, decimals: 6),
          formatCoordinate(row.decimalLongitude, decimals: 6),
          formatCoordinate(row.elevationInMeter, decimals: 2),
          (row.count ?? 0).toString(),
          spatialStatisticPercent(row, total).toStringAsFixed(2),
        ]
      else
        [
          row.displayName,
          formatCoordinateText(row.locality),
          formatCoordinate(row.decimalLatitude, decimals: 6),
          formatCoordinate(row.decimalLongitude, decimals: 6),
          formatCoordinate(row.elevationInMeter, decimals: 2),
          formatCoordinateText(row.datum),
          formatCoordinateInteger(row.uncertaintyInMeters),
          formatCoordinateText(row.gpsUnit),
          formatCoordinateText(row.notes),
        ],
  ];
}
