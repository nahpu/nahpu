import 'dart:io';

import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/src/rust/api/export.dart';

class StatisticsTableExporter {
  const StatisticsTableExporter();

  Future<void> write(
    File file,
    ExportFmt format,
    List<StatisticTableRow> rows,
  ) {
    if (format == ExportFmt.json) {
      throw ArgumentError('Statistics tables do not support JSON export.');
    }
    return writeTabularRecords(
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
      outputPath: file.path,
      exportFormat: format.name,
    );
  }
}
