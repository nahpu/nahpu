import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/import/batch/batch_import_reader.dart';
import 'package:path/path.dart' as p;

import '../helpers/rust_library.dart';

void main() {
  const reader = BatchImportReader();

  group('fromRows', () {
    test('drops blank rows, trims, and pads short rows', () {
      final table = reader.fromRows([
        ['﻿genus', ' epithet ', 'TL'],
        ['', '', ''],
        ['Rattus', ' tiomanicus', '210'],
        ['Mus'],
      ], fileName: 'f.csv');
      expect(table.headers, ['genus', 'epithet', 'TL']);
      expect(table.rows, [
        ['Rattus', 'tiomanicus', '210'],
        ['Mus', '', ''],
      ]);
      expect(table.rowNumbers, [3, 4]);
    });

    test('names blank and repeated headers', () {
      final table = reader.fromRows([
        ['sex', '', 'sex'],
        ['M', 'x', 'F'],
      ], fileName: 'f.csv');
      expect(table.headers, ['sex', 'Column 2', 'sex (2)']);
    });

    test('needs a header and a data row', () {
      expect(
        () => reader.fromRows([
          ['genus'],
        ], fileName: 'f.csv'),
        throwsFormatException,
      );
    });
  });

  group('guessBatchDelimiter', () {
    test('finds commas, tabs, and semicolons', () {
      expect(guessBatchDelimiter('a,b,c\n1,2,3'), ',');
      expect(guessBatchDelimiter('a\tb\tc\n1\t2\t3'), '\t');
      expect(guessBatchDelimiter('a;b;c\n1;2,5;3'), ';');
    });

    test('ignores delimiters inside quotes', () {
      expect(guessBatchDelimiter('a;b\n"x, y, z";2'), ';');
    });
  });

  group('readFile', () {
    late Directory dir;

    setUpAll(initRustLibForTest);
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('nahpu-batch-reader');
    });
    tearDown(() => dir.delete(recursive: true));

    test('reads a semicolon text file', () async {
      final path = p.join(dir.path, 'specimens.txt');
      await File(path).writeAsString('genus;TL\nRattus;210\n\nMus;80\n');
      final table = await reader.readFile(path);
      expect(table.fileName, 'specimens.txt');
      expect(table.headers, ['genus', 'TL']);
      expect(table.rows, [
        ['Rattus', '210'],
        ['Mus', '80'],
      ]);
    });

    test('reads quoted CSV cells', () async {
      final path = p.join(dir.path, 'sites.csv');
      await File(path).writeAsString('site,locality\nBK-1,"Camp 1, ridge"\n');
      final table = await reader.readFile(path);
      expect(table.rows.single, ['BK-1', 'Camp 1, ridge']);
    });
  });
}
