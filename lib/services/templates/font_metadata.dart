import 'dart:typed_data';

/// Font weight and style descriptors read from an sfnt container.
class FontFileMetadata {
  const FontFileMetadata({
    required this.family,
    required this.subfamily,
    required this.weight,
    required this.italic,
  });

  /// Typographic family name, as indexed by Typst's font book and used as the
  /// Flutter font family for runtime-registered fonts.
  final String family;

  /// Typographic subfamily, such as `Regular`, `Bold`, or `Bold Italic`.
  final String subfamily;

  /// `OS/2` `usWeightClass`, clamped to the 100-900 range.
  final int weight;

  final bool italic;
}

/// Thrown when a file is not a readable TrueType or OpenType font.
class FontFormatException implements Exception {
  const FontFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Reads family and style metadata from a TrueType, OpenType, or collection
/// font file.
///
/// Only the `name`, `OS/2`, and `head` tables are parsed. Collections are read
/// through their first font, which is enough to name the family.
class FontMetadataReader {
  const FontMetadataReader();

  static const int _nameIdFontFamily = 1;
  static const int _nameIdFontSubfamily = 2;
  static const int _nameIdTypographicFamily = 16;
  static const int _nameIdTypographicSubfamily = 17;

  FontFileMetadata read(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    final tables = _tableDirectory(data);

    final names = _readNameTable(data, tables['name']);
    final family =
        names[_nameIdTypographicFamily] ?? names[_nameIdFontFamily] ?? '';
    if (family.isEmpty) {
      throw const FontFormatException(
        'The font does not declare a family name',
      );
    }
    final subfamily =
        names[_nameIdTypographicSubfamily] ??
        names[_nameIdFontSubfamily] ??
        'Regular';

    final os2 = tables['OS/2'];
    var weight = 400;
    bool? italic;
    if (os2 != null && os2.length >= 64) {
      weight = data.getUint16(os2.offset + 4);
      italic = data.getUint16(os2.offset + 62) & 0x01 != 0;
    }
    if (italic == null) {
      final head = tables['head'];
      italic = head != null && head.length >= 46
          ? data.getUint16(head.offset + 44) & 0x02 != 0
          : subfamily.toLowerCase().contains('italic');
    }

    return FontFileMetadata(
      family: family,
      subfamily: subfamily,
      weight: weight.clamp(100, 900),
      italic: italic,
    );
  }

  Map<String, _TableRecord> _tableDirectory(ByteData data) {
    if (data.lengthInBytes < 12) {
      throw const FontFormatException('The file is too small to be a font');
    }
    var offset = 0;
    final tag = data.getUint32(0);
    if (tag == 0x74746366) {
      // `ttcf`: read the directory of the collection's first font.
      if (data.lengthInBytes < 16) {
        throw const FontFormatException('The font collection is truncated');
      }
      offset = data.getUint32(12);
    } else if (tag != 0x00010000 && tag != 0x4f54544f && tag != 0x74727565) {
      throw const FontFormatException(
        'Choose a TrueType or OpenType font (.ttf, .otf, or .ttc)',
      );
    }

    final numTables = data.getUint16(offset + 4);
    final records = <String, _TableRecord>{};
    for (var index = 0; index < numTables; index++) {
      final entry = offset + 12 + index * 16;
      if (entry + 16 > data.lengthInBytes) break;
      final name = String.fromCharCodes(
        Uint8List.view(data.buffer, data.offsetInBytes + entry, 4),
      );
      records[name] = _TableRecord(
        offset: data.getUint32(entry + 8),
        length: data.getUint32(entry + 12),
      );
    }
    return records;
  }

  Map<int, String> _readNameTable(ByteData data, _TableRecord? table) {
    if (table == null) {
      throw const FontFormatException('The font has no name table');
    }
    final base = table.offset;
    if (base + 6 > data.lengthInBytes) {
      throw const FontFormatException('The font name table is truncated');
    }
    final count = data.getUint16(base + 2);
    final stringBase = base + data.getUint16(base + 4);

    // Prefer the Windows Unicode records, falling back to Macintosh Roman.
    final resolved = <int, String>{};
    final preferred = <int, bool>{};
    for (var index = 0; index < count; index++) {
      final record = base + 6 + index * 12;
      if (record + 12 > data.lengthInBytes) break;
      final platformId = data.getUint16(record);
      final encodingId = data.getUint16(record + 2);
      final nameId = data.getUint16(record + 6);
      final length = data.getUint16(record + 8);
      final offset = stringBase + data.getUint16(record + 10);
      if (offset + length > data.lengthInBytes) continue;

      final isWindowsUnicode = platformId == 3 && encodingId <= 1;
      final isMacRoman = platformId == 1 && encodingId == 0;
      if (!isWindowsUnicode && !isMacRoman) continue;
      if (preferred[nameId] == true && !isWindowsUnicode) continue;

      final raw = Uint8List.view(
        data.buffer,
        data.offsetInBytes + offset,
        length,
      );
      final value = isWindowsUnicode
          ? _decodeUtf16Be(raw)
          : String.fromCharCodes(raw);
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      resolved[nameId] = trimmed;
      preferred[nameId] = isWindowsUnicode;
    }
    return resolved;
  }

  String _decodeUtf16Be(Uint8List raw) {
    final units = <int>[];
    for (var index = 0; index + 1 < raw.length; index += 2) {
      units.add((raw[index] << 8) | raw[index + 1]);
    }
    return String.fromCharCodes(units);
  }
}

class _TableRecord {
  const _TableRecord({required this.offset, required this.length});

  final int offset;
  final int length;
}
