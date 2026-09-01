import 'dart:convert';
import 'dart:io';

import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/templates/font_metadata.dart';
import 'package:nahpu/services/types/user_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Manages font families the user installs into `UserConfigs/fonts/`.
///
/// Fonts are stored per family so that the regular, bold, and italic files of
/// one family stay together and can be registered as a single Flutter font
/// family and handed to the Typst compiler as one set of byte buffers.
class UserFontService {
  const UserFontService();

  static const _catalogFileName = 'catalog.json';
  static const _metadataFileName = 'font.json';
  static const supportedExtensions = ['ttf', 'otf', 'ttc'];

  Future<UserFontCatalog> load() async {
    final directory = await getUserFontDirectory();
    final file = File(path.join(directory.path, _catalogFileName));
    if (!await file.exists()) return const UserFontCatalog();
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) throw const FormatException('Invalid font catalog');
    return UserFontCatalog.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> save(UserFontCatalog catalog) async {
    final directory = await getUserFontDirectory();
    final target = File(path.join(directory.path, _catalogFileName));
    final temporary = File('${target.path}.tmp');
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert(catalog.toJson()),
      flush: true,
    );
    if (await target.exists()) await target.delete();
    await temporary.rename(target.path);
  }

  /// Installs [source], returning the installed family and the new catalog.
  ///
  /// A file whose family is already installed is added as another variant of
  /// that family, replacing an existing file of the same name.
  Future<({UserFont font, UserFontCatalog catalog})> importFile(
    File source,
  ) async {
    final extension = path
        .extension(source.path)
        .toLowerCase()
        .replaceFirst('.', '');
    if (!supportedExtensions.contains(extension)) {
      throw const FormatException(
        'Choose a TrueType or OpenType font file (.ttf, .otf, or .ttc)',
      );
    }
    final bytes = await source.readAsBytes();
    final metadata = const FontMetadataReader().read(bytes);

    final catalog = await load();
    final existing = catalog.byFamily(metadata.family);
    final root = await getUserFontDirectory();
    final id = existing?.id ?? const Uuid().v4();
    final familyDirectory = Directory(path.join(root.path, id));
    await familyDirectory.create(recursive: true);

    final fileName = _variantFileName(metadata, extension);
    final target = File(path.join(familyDirectory.path, fileName));
    await target.writeAsBytes(bytes, flush: true);

    final variant = UserFontVariant(
      fileName: fileName,
      subfamily: metadata.subfamily,
      weight: metadata.weight,
      italic: metadata.italic,
      byteSize: bytes.length,
    );
    final variants = [
      ...?existing?.variants.where((v) => v.fileName != fileName),
      variant,
    ]..sort(_compareVariants);

    final font = existing == null
        ? UserFont(
            id: id,
            family: metadata.family,
            addedAt: DateTime.now().toUtc(),
            variants: variants,
          )
        : existing.copyWith(variants: variants);

    await File(
      path.join(familyDirectory.path, _metadataFileName),
    ).writeAsString(
      const JsonEncoder.withIndent('  ').convert(font.toJson()),
      flush: true,
    );

    final updated = UserFontCatalog(
      fonts: [...catalog.fonts.where((f) => f.id != font.id), font]
        ..sort((a, b) => a.family.compareTo(b.family)),
    );
    await save(updated);
    return (font: font, catalog: updated);
  }

  /// Removes [font] and its files, returning the updated catalog.
  Future<UserFontCatalog> deleteFont(UserFont font) async {
    final root = await getUserFontDirectory();
    final directory = Directory(path.join(root.path, font.id));
    if (await directory.exists()) await directory.delete(recursive: true);
    final catalog = await load();
    final updated = UserFontCatalog(
      fonts: catalog.fonts
          .where((f) => f.id != font.id)
          .toList(growable: false),
    );
    await save(updated);
    return updated;
  }

  /// Absolute path of one installed font file.
  Future<String> filePath(UserFont font, UserFontVariant variant) async {
    final root = await getUserFontDirectory();
    return path.join(root.path, font.relativePathOf(variant));
  }

  /// Bytes of every installed font file, for the Typst compiler.
  Future<List<List<int>>> loadAllFontBytes() async {
    final catalog = await load();
    if (catalog.fonts.isEmpty) return const [];
    final root = await getUserFontDirectory();
    final bytes = <List<int>>[];
    for (final font in catalog.fonts) {
      for (final variant in font.variants) {
        final file = File(path.join(root.path, font.relativePathOf(variant)));
        if (!await file.exists()) continue;
        bytes.add(await file.readAsBytes());
      }
    }
    return bytes;
  }

  String _variantFileName(FontFileMetadata metadata, String extension) {
    final stem = '${metadata.family}-${metadata.subfamily}'.replaceAll(
      RegExp(r'[^\w.\-]'),
      '_',
    );
    return '$stem.$extension';
  }

  int _compareVariants(UserFontVariant a, UserFontVariant b) {
    if (a.italic != b.italic) return a.italic ? 1 : -1;
    return a.weight.compareTo(b.weight);
  }
}
