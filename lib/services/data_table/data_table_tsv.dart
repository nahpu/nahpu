/// Tab-separated text for copying cells to and from spreadsheets.
///
/// Follows what spreadsheet apps put on the clipboard: cells holding a tab,
/// newline, or quote are wrapped in quotes, with quotes doubled.
String encodeDataTableTsv(List<List<String>> rows) =>
    rows.map((row) => row.map(_encodeCell).join('\t')).join('\n');

String _encodeCell(String value) {
  if (!value.contains(RegExp('[\t\n\r"]'))) return value;
  return '"${value.replaceAll('"', '""')}"';
}

/// Parses clipboard text into rows of cells. A trailing newline, which
/// spreadsheet apps add after the last row, doesn't add an empty row.
List<List<String>> decodeDataTableTsv(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  var atCellStart = true;

  void endCell() {
    row.add(cell.toString());
    cell.clear();
    atCellStart = true;
  }

  void endRow() {
    endCell();
    rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < text.length; i++) {
    final char = text[i];
    if (inQuotes) {
      if (char == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.write(char);
      }
      continue;
    }
    switch (char) {
      case '"' when atCellStart:
        inQuotes = true;
        atCellStart = false;
      case '\t':
        endCell();
      case '\r':
        if (i + 1 < text.length && text[i + 1] == '\n') i++;
        endRow();
      case '\n':
        endRow();
      default:
        cell.write(char);
        atCellStart = false;
    }
  }
  if (!atCellStart || cell.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}
