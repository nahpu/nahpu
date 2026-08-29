import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:path/path.dart' as path;
import 'package:pmtiles/pmtiles.dart';
import 'package:uuid/uuid.dart';
import 'package:nahpu/src/rust/api/gis.dart' as gis;

class UserMapLayerService {
  const UserMapLayerService();

  static const _catalogFileName = 'catalog.json';

  Future<UserMapCatalog> load() async {
    final directory = await getUserMapDirectory();
    final file = File(path.join(directory.path, _catalogFileName));
    if (!await file.exists()) return const UserMapCatalog();
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) throw const FormatException('Invalid map catalog');
    return UserMapCatalog.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> save(UserMapCatalog catalog) async {
    final directory = await getUserMapDirectory();
    final target = File(path.join(directory.path, _catalogFileName));
    final temporary = File('${target.path}.tmp');
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert(catalog.toJson()),
      flush: true,
    );
    if (await target.exists()) await target.delete();
    await temporary.rename(target.path);
  }

  Future<UserMapLayer> importFile(
    File source, {
    UserMapLayerKind? requestedKind,
  }) async {
    final extension = path.extension(source.path).toLowerCase();
    if (extension == '.geojson' ||
        extension == '.json' ||
        extension == '.zip') {
      return _importVector(source);
    }
    if (extension == '.pmtiles') {
      return _importPmTiles(source, requestedKind: requestedKind);
    }
    throw const FormatException(
      'Choose GeoJSON, a zipped WGS84 Shapefile, or PMTiles. Convert GeoTIFF '
      'rasters and elevation models to PMTiles before importing.',
    );
  }

  Future<void> deleteLayer(UserMapLayer layer) async {
    final directory = await getUserMapDirectory();
    final layerDirectory = Directory(path.join(directory.path, layer.id));
    if (await layerDirectory.exists()) {
      await layerDirectory.delete(recursive: true);
    }
  }

  Future<UserMapLayer> _importVector(File source) async {
    final directory = await Directory.systemTemp.createTemp(
      'nahpu_map_import_',
    );
    final converted = File(path.join(directory.path, 'converted.geojson'));
    try {
      await gis.convertVectorLayerToGeojson(
        inputPath: source.path,
        outputPath: converted.path,
      );
      return await _importGeoJson(converted, originalSource: source);
    } finally {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  }

  Future<UserMapLayer> _importGeoJson(
    File source, {
    required File originalSource,
  }) async {
    final decoded = jsonDecode(await source.readAsString());
    if (decoded is! Map) throw const FormatException('Invalid GeoJSON object');
    final normalized = _normalizeGeoJson(Map<String, dynamic>.from(decoded));
    final bounds = _geoJsonBounds(normalized);
    return _store(
      source: originalSource,
      kind: UserMapLayerKind.geoJson,
      outputName: 'data.geojson',
      bounds: bounds,
      writer: (target) => File(target).writeAsString(jsonEncode(normalized)),
    );
  }

  Future<UserMapLayer> _importPmTiles(
    File source, {
    UserMapLayerKind? requestedKind,
  }) async {
    final archive = await PmTilesArchive.fromFile(source);
    final tileType = archive.header.tileType;
    final metadataValue = await archive.metadata;
    final metadata = metadataValue is Map
        ? Map<String, dynamic>.from(metadataValue)
        : const <String, dynamic>{};
    final kind = tileType == TileType.mvt
        ? UserMapLayerKind.vectorPmtiles
        : requestedKind ?? UserMapLayerKind.rasterPmtiles;
    if (kind == UserMapLayerKind.geoJson ||
        (tileType == TileType.mvt && kind != UserMapLayerKind.vectorPmtiles)) {
      throw const FormatException('The selected PMTiles layer type is invalid');
    }
    final header = archive.header;
    return _store(
      source: source,
      kind: kind,
      outputName: 'data.pmtiles',
      bounds: UserMapBounds(
        west: header.minPosition.longitude,
        south: header.minPosition.latitude,
        east: header.maxPosition.longitude,
        north: header.maxPosition.latitude,
      ),
      minZoom: header.minZoom,
      maxZoom: header.maxZoom,
      demEncoding: kind == UserMapLayerKind.demPmtiles ? 'terrarium' : null,
      attribution: metadata['attribution'] as String?,
      vectorLayerNames: (metadata['vector_layers'] as List? ?? const [])
          .whereType<Map>()
          .map((layer) => layer['id'])
          .whereType<String>()
          .toList(growable: false),
      writer: source.copy,
    );
  }

  Future<UserMapLayer> _store({
    required File source,
    required UserMapLayerKind kind,
    required String outputName,
    required UserMapBounds? bounds,
    required Future<File> Function(String targetPath) writer,
    int minZoom = 0,
    int maxZoom = 22,
    String? demEncoding,
    String? attribution,
    List<String> vectorLayerNames = const [],
  }) async {
    final root = await getUserMapDirectory();
    final id = const Uuid().v4();
    final temporary = Directory(path.join(root.path, '.$id.import'));
    final finalDirectory = Directory(path.join(root.path, id));
    await temporary.create(recursive: true);
    try {
      final hash = await sha256.bind(source.openRead()).first;
      final layer = UserMapLayer(
        id: id,
        name: path.basenameWithoutExtension(source.path),
        kind: kind,
        dataFile: outputName,
        originalFileName: path.basename(source.path),
        sourceHash: hash.toString(),
        addedAt: DateTime.now().toUtc(),
        bounds: bounds,
        minZoom: minZoom,
        maxZoom: maxZoom,
        demEncoding: demEncoding,
        attribution: attribution,
        vectorLayerNames: vectorLayerNames,
      );
      await writer(path.join(temporary.path, outputName));
      await File(path.join(temporary.path, 'layer.json')).writeAsString(
        const JsonEncoder.withIndent('  ').convert(layer.toJson()),
        flush: true,
      );
      await temporary.rename(finalDirectory.path);
      return layer;
    } catch (_) {
      if (await temporary.exists()) await temporary.delete(recursive: true);
      rethrow;
    }
  }

  Map<String, dynamic> _normalizeGeoJson(Map<String, dynamic> source) {
    if (source['type'] == 'FeatureCollection' && source['features'] is List) {
      return source;
    }
    if (source['type'] == 'Feature') {
      return {
        'type': 'FeatureCollection',
        'features': [source],
      };
    }
    throw const FormatException(
      'GeoJSON must be a Feature or FeatureCollection',
    );
  }

  UserMapBounds? _geoJsonBounds(Map<String, dynamic> collection) {
    var west = double.infinity;
    var south = double.infinity;
    var east = double.negativeInfinity;
    var north = double.negativeInfinity;
    void visit(Object? value) {
      if (value is List &&
          value.length >= 2 &&
          value[0] is num &&
          value[1] is num) {
        final longitude = (value[0] as num).toDouble();
        final latitude = (value[1] as num).toDouble();
        if (!longitude.isFinite || !latitude.isFinite) return;
        west = longitude < west ? longitude : west;
        east = longitude > east ? longitude : east;
        south = latitude < south ? latitude : south;
        north = latitude > north ? latitude : north;
        return;
      }
      if (value is List) {
        for (final child in value) {
          visit(child);
        }
      } else if (value is Map) {
        visit(value['coordinates']);
        visit(value['geometries']);
        visit(value['geometry']);
        visit(value['features']);
      }
    }

    visit(collection);
    if (!west.isFinite) return null;
    return UserMapBounds(west: west, south: south, east: east, north: north);
  }
}
