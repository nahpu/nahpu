import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/sites/map_layer_service.dart';
import 'package:nahpu/services/types/map_layers.dart';

final userMapCatalogProvider =
    AsyncNotifierProvider<UserMapCatalogNotifier, UserMapCatalog>(
      UserMapCatalogNotifier.new,
    );

class UserMapCatalogNotifier extends AsyncNotifier<UserMapCatalog> {
  final _service = const UserMapLayerService();

  @override
  Future<UserMapCatalog> build() => _service.load();

  Future<void> importFile(File file, {UserMapLayerKind? requestedKind}) async {
    final current = state.value ?? await _service.load();
    final layer = await _service.importFile(file, requestedKind: requestedKind);
    if (current.layers.any((item) => item.sourceHash == layer.sourceHash)) {
      await _service.deleteLayer(layer);
      throw StateError('This map layer has already been imported.');
    }
    final updated = current.copyWith(layers: [...current.layers, layer]);
    await _service.save(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> setEnabled(String id, bool enabled) => _updateLayers(
    (layers) => [
      for (final layer in layers)
        layer.id == id ? layer.copyWith(enabled: enabled) : layer,
    ],
  );

  Future<void> setOpacity(String id, double opacity) => _updateLayers(
    (layers) => [
      for (final layer in layers)
        layer.id == id ? layer.copyWith(opacity: opacity) : layer,
    ],
  );

  Future<void> reorder(int oldIndex, int newIndex) => _updateLayers((layers) {
    final reordered = [...layers];
    if (newIndex > oldIndex) newIndex--;
    final layer = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, layer);
    return reordered;
  });

  Future<void> setTerrain(String id, bool enabled) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(
      activeTerrainLayerId: enabled ? id : null,
      clearActiveTerrain: !enabled,
    );
    await _service.save(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> delete(String id) async {
    final current = state.value;
    if (current == null) return;
    final layer = current.layers.where((item) => item.id == id).firstOrNull;
    if (layer == null) return;
    await _service.deleteLayer(layer);
    final updated = current.copyWith(
      layers: current.layers.where((item) => item.id != id).toList(),
      clearActiveTerrain: current.activeTerrainLayerId == id,
    );
    await _service.save(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> _updateLayers(
    List<UserMapLayer> Function(List<UserMapLayer>) update,
  ) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(layers: update(current.layers));
    await _service.save(updated);
    state = AsyncValue.data(updated);
  }
}
