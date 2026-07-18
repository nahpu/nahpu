import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/statistics_exporter.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/src/rust/frb_generated.dart';

void main() {
  late Directory tempDirectory;

  setUpAll(() async {
    final libraryPath = Platform.isMacOS
        ? 'rust/target/debug/librust_lib_nahpu.dylib'
        : Platform.isWindows
            ? 'rust/target/debug/rust_lib_nahpu.dll'
            : 'rust/target/debug/librust_lib_nahpu.so';
    await RustLib.init(externalLibrary: ExternalLibrary.open(libraryPath));
  });

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync('nahpu_stats_export_');
  });

  tearDown(() {
    tempDirectory.deleteSync(recursive: true);
  });

  test('writes statistics tables as CSV, TSV, and Excel', () async {
    const rows = [
      StatisticTableRow(
        rank: 1,
        category: 'Myotis lucifugus',
        count: 3,
        percent: 75,
      ),
      StatisticTableRow(
        rank: 2,
        category: 'Eptesicus fuscus',
        count: 1,
        percent: 25,
      ),
    ];
    const exporter = StatisticsTableExporter();

    final csv = File('${tempDirectory.path}/statistics.csv');
    final tsv = File('${tempDirectory.path}/statistics.tsv');
    final excel = File('${tempDirectory.path}/statistics.xlsx');
    await exporter.write(csv, ExportFmt.csv, rows);
    await exporter.write(tsv, ExportFmt.tsv, rows);
    await exporter.write(excel, ExportFmt.excel, rows);

    expect(
      await csv.readAsString(),
      contains('Rank,Category,Count,Percent (%)'),
    );
    expect(await csv.readAsString(), contains('1,Myotis lucifugus,3,75.00'));
    expect(await tsv.readAsString(), contains('Rank\tCategory\tCount'));
    expect(excel.lengthSync(), greaterThan(0));
  });
}
