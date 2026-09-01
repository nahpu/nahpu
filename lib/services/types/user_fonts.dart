import 'package:path/path.dart' as path;

/// One font file belonging to a [UserFont] family.
class UserFontVariant {
  const UserFontVariant({
    required this.fileName,
    required this.subfamily,
    required this.weight,
    required this.italic,
    required this.byteSize,
  });

  factory UserFontVariant.fromJson(Map<String, dynamic> json) =>
      UserFontVariant(
        fileName: json['fileName'] as String,
        subfamily: json['subfamily'] as String? ?? 'Regular',
        weight: (json['weight'] as num?)?.toInt() ?? 400,
        italic: json['italic'] as bool? ?? false,
        byteSize: (json['byteSize'] as num?)?.toInt() ?? 0,
      );

  /// File name inside the family directory, never a path.
  final String fileName;
  final String subfamily;
  final int weight;
  final bool italic;
  final int byteSize;

  String get label {
    final trimmed = subfamily.trim();
    return trimmed.isEmpty ? 'Regular' : trimmed;
  }

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'subfamily': subfamily,
    'weight': weight,
    'italic': italic,
    'byteSize': byteSize,
  };
}

/// A font family installed by the user into `UserConfigs/fonts/`.
///
/// [family] is the font's internal typographic family name. Typst indexes
/// fonts by that name and Flutter registers runtime fonts under it, so the
/// template dropdown, the canvas, and the PDF all agree on one string.
class UserFont {
  const UserFont({
    required this.id,
    required this.family,
    required this.addedAt,
    this.variants = const [],
  });

  factory UserFont.fromJson(Map<String, dynamic> json) => UserFont(
    id: json['id'] as String,
    family: json['family'] as String,
    addedAt:
        DateTime.tryParse(json['addedAt'] as String? ?? '')?.toUtc() ??
        DateTime.now().toUtc(),
    variants: (json['variants'] as List? ?? const [])
        .whereType<Map>()
        .map((v) => UserFontVariant.fromJson(Map<String, dynamic>.from(v)))
        .toList(growable: false),
  );

  final String id;
  final String family;
  final DateTime addedAt;
  final List<UserFontVariant> variants;

  int get byteSize =>
      variants.fold(0, (total, variant) => total + variant.byteSize);

  bool get hasBold => variants.any((variant) => variant.weight >= 600);

  bool get hasItalic => variants.any((variant) => variant.italic);

  UserFont copyWith({List<UserFontVariant>? variants}) => UserFont(
    id: id,
    family: family,
    addedAt: addedAt,
    variants: variants ?? this.variants,
  );

  /// Relative path of [variant] from the user font root.
  String relativePathOf(UserFontVariant variant) =>
      path.join(id, variant.fileName);

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'id': id,
    'family': family,
    'addedAt': addedAt.toIso8601String(),
    'variants': variants.map((variant) => variant.toJson()).toList(),
  };
}

/// The catalog of every user-installed font family.
class UserFontCatalog {
  const UserFontCatalog({this.fonts = const []});

  factory UserFontCatalog.fromJson(Map<String, dynamic> json) =>
      UserFontCatalog(
        fonts: (json['fonts'] as List? ?? const [])
            .whereType<Map>()
            .map((f) => UserFont.fromJson(Map<String, dynamic>.from(f)))
            .toList(growable: false),
      );

  final List<UserFont> fonts;

  UserFont? byFamily(String family) {
    final needle = family.trim().toLowerCase();
    for (final font in fonts) {
      if (font.family.toLowerCase() == needle) return font;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'fonts': fonts.map((font) => font.toJson()).toList(),
  };
}
