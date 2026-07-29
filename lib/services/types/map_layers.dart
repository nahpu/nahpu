enum SpatialBasemapStyle {
  none,
  automatic,
  naturalEarthOffline,
  positron,
  bright,
  liberty,
  dark,
}

extension SpatialBasemapStyleDetails on SpatialBasemapStyle {
  String get label => switch (this) {
    SpatialBasemapStyle.none => 'None',
    SpatialBasemapStyle.automatic => 'Automatic',
    SpatialBasemapStyle.naturalEarthOffline => 'Natural Earth (Offline)',
    SpatialBasemapStyle.positron => 'Positron',
    SpatialBasemapStyle.bright => 'Bright',
    SpatialBasemapStyle.liberty => 'Liberty',
    SpatialBasemapStyle.dark => 'Dark',
  };

  String get description => switch (this) {
    SpatialBasemapStyle.none => 'No geographic base layer',
    SpatialBasemapStyle.automatic =>
      'Positron in light mode and Dark in dark mode',
    SpatialBasemapStyle.naturalEarthOffline =>
      'Bundled country boundaries that work without internet access',
    SpatialBasemapStyle.positron => 'Minimal, low-contrast light map',
    SpatialBasemapStyle.bright => 'Detailed map with bright colors',
    SpatialBasemapStyle.liberty => 'Detailed map with balanced colors',
    SpatialBasemapStyle.dark => 'Dark map for low-light use',
  };

  SpatialBasemapStyle resolve({required bool isDark}) {
    if (this != SpatialBasemapStyle.automatic) return this;
    return isDark ? SpatialBasemapStyle.dark : SpatialBasemapStyle.positron;
  }

  String? get styleUrl => switch (this) {
    SpatialBasemapStyle.none || SpatialBasemapStyle.naturalEarthOffline => null,
    SpatialBasemapStyle.automatic =>
      'https://tiles.openfreemap.org/styles/positron',
    _ => 'https://tiles.openfreemap.org/styles/$name',
  };
}

enum UserMapLayerKind { geoJson, rasterPmtiles, vectorPmtiles, demPmtiles }

extension UserMapLayerKindDetails on UserMapLayerKind {
  String get label => switch (this) {
    UserMapLayerKind.geoJson => 'GeoJSON',
    UserMapLayerKind.rasterPmtiles => 'Raster tiles',
    UserMapLayerKind.vectorPmtiles => 'Vector tiles',
    UserMapLayerKind.demPmtiles => 'Elevation model',
  };

  bool get isSupportedOnLinux =>
      this == UserMapLayerKind.geoJson ||
      this == UserMapLayerKind.rasterPmtiles;
}

class UserMapBounds {
  const UserMapBounds({
    required this.west,
    required this.south,
    required this.east,
    required this.north,
  });

  final double west;
  final double south;
  final double east;
  final double north;

  List<double> get values => [west, south, east, north];

  Map<String, dynamic> toJson() => {
    'west': west,
    'south': south,
    'east': east,
    'north': north,
  };

  factory UserMapBounds.fromJson(Map<String, dynamic> json) => UserMapBounds(
    west: (json['west'] as num).toDouble(),
    south: (json['south'] as num).toDouble(),
    east: (json['east'] as num).toDouble(),
    north: (json['north'] as num).toDouble(),
  );
}

class UserMapLayer {
  const UserMapLayer({
    required this.id,
    required this.name,
    required this.kind,
    required this.dataFile,
    required this.originalFileName,
    required this.sourceHash,
    required this.addedAt,
    this.sourceCrs = 'EPSG:4326',
    this.bounds,
    this.minZoom = 0,
    this.maxZoom = 22,
    this.attribution,
    this.enabled = true,
    this.opacity = 1,
    this.color = 0xff1565c0,
    this.fillOpacity = 0.24,
    this.lineWidth = 2,
    this.pointRadius = 5,
    this.vectorLayerNames = const [],
    this.demEncoding,
  });

  final String id;
  final String name;
  final UserMapLayerKind kind;
  final String dataFile;
  final String originalFileName;
  final String sourceHash;
  final DateTime addedAt;
  final String sourceCrs;
  final UserMapBounds? bounds;
  final int minZoom;
  final int maxZoom;
  final String? attribution;
  final bool enabled;
  final double opacity;
  final int color;
  final double fillOpacity;
  final double lineWidth;
  final double pointRadius;
  final List<String> vectorLayerNames;
  final String? demEncoding;

  UserMapLayer copyWith({
    String? name,
    bool? enabled,
    double? opacity,
    int? color,
    double? fillOpacity,
    double? lineWidth,
    double? pointRadius,
    String? attribution,
  }) => UserMapLayer(
    id: id,
    name: name ?? this.name,
    kind: kind,
    dataFile: dataFile,
    originalFileName: originalFileName,
    sourceHash: sourceHash,
    addedAt: addedAt,
    sourceCrs: sourceCrs,
    bounds: bounds,
    minZoom: minZoom,
    maxZoom: maxZoom,
    attribution: attribution ?? this.attribution,
    enabled: enabled ?? this.enabled,
    opacity: opacity ?? this.opacity,
    color: color ?? this.color,
    fillOpacity: fillOpacity ?? this.fillOpacity,
    lineWidth: lineWidth ?? this.lineWidth,
    pointRadius: pointRadius ?? this.pointRadius,
    vectorLayerNames: vectorLayerNames,
    demEncoding: demEncoding,
  );

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'id': id,
    'name': name,
    'kind': kind.name,
    'dataFile': dataFile,
    'originalFileName': originalFileName,
    'sourceHash': sourceHash,
    'addedAt': addedAt.toUtc().toIso8601String(),
    'sourceCrs': sourceCrs,
    if (bounds != null) 'bounds': bounds!.toJson(),
    'minZoom': minZoom,
    'maxZoom': maxZoom,
    if (attribution != null) 'attribution': attribution,
    'enabled': enabled,
    'opacity': opacity,
    'color': color,
    'fillOpacity': fillOpacity,
    'lineWidth': lineWidth,
    'pointRadius': pointRadius,
    'vectorLayerNames': vectorLayerNames,
    if (demEncoding != null) 'demEncoding': demEncoding,
  };

  factory UserMapLayer.fromJson(Map<String, dynamic> json) => UserMapLayer(
    id: json['id'] as String,
    name: json['name'] as String,
    kind: UserMapLayerKind.values.byName(json['kind'] as String),
    dataFile: json['dataFile'] as String,
    originalFileName: json['originalFileName'] as String,
    sourceHash: json['sourceHash'] as String,
    addedAt: DateTime.parse(json['addedAt'] as String),
    sourceCrs: json['sourceCrs'] as String? ?? 'EPSG:4326',
    bounds: json['bounds'] is Map
        ? UserMapBounds.fromJson(
            Map<String, dynamic>.from(json['bounds'] as Map),
          )
        : null,
    minZoom: json['minZoom'] as int? ?? 0,
    maxZoom: json['maxZoom'] as int? ?? 22,
    attribution: json['attribution'] as String?,
    enabled: json['enabled'] as bool? ?? true,
    opacity: (json['opacity'] as num? ?? 1).toDouble(),
    color: json['color'] as int? ?? 0xff1565c0,
    fillOpacity: (json['fillOpacity'] as num? ?? 0.24).toDouble(),
    lineWidth: (json['lineWidth'] as num? ?? 2).toDouble(),
    pointRadius: (json['pointRadius'] as num? ?? 5).toDouble(),
    vectorLayerNames: (json['vectorLayerNames'] as List? ?? const [])
        .cast<String>(),
    demEncoding: json['demEncoding'] as String?,
  );
}

class UserMapCatalog {
  const UserMapCatalog({this.layers = const [], this.activeTerrainLayerId});

  final List<UserMapLayer> layers;
  final String? activeTerrainLayerId;

  UserMapCatalog copyWith({
    List<UserMapLayer>? layers,
    String? activeTerrainLayerId,
    bool clearActiveTerrain = false,
  }) => UserMapCatalog(
    layers: layers ?? this.layers,
    activeTerrainLayerId: clearActiveTerrain
        ? null
        : activeTerrainLayerId ?? this.activeTerrainLayerId,
  );

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'activeTerrainLayerId': activeTerrainLayerId,
    'layers': layers.map((layer) => layer.toJson()).toList(),
  };

  factory UserMapCatalog.fromJson(Map<String, dynamic> json) => UserMapCatalog(
    activeTerrainLayerId: json['activeTerrainLayerId'] as String?,
    layers: (json['layers'] as List? ?? const [])
        .map(
          (value) =>
              UserMapLayer.fromJson(Map<String, dynamic>.from(value as Map)),
        )
        .toList(growable: false),
  );
}
