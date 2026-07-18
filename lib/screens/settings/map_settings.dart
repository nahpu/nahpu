import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/map_layers.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/map_layers.dart';

class BasemapStyleSettings extends ConsumerWidget {
  const BasemapStyleSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(spatialBasemapStyleProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Basemap style')),
      body: CommonSettingList(
        sections: [
          CommonSettingSection(
            title: 'Basemap style',
            isDivided: true,
            children: [
              for (final style in SpatialBasemapStyle.values)
                CommonSettingTile(
                  title: style.label,
                  label: style.description,
                  icon: _styleIcon(style),
                  trailing: selected.value == style
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () async {
                    await ref
                        .read(spatialBasemapStyleProvider.notifier)
                        .setStyle(style);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
            ],
          ),
          if (Platform.isLinux)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Linux uses the offline Natural Earth basemap. The selected '
                'online vector style applies on other supported platforms.',
              ),
            ),
        ],
      ),
    );
  }

  IconData _styleIcon(SpatialBasemapStyle style) => switch (style) {
    SpatialBasemapStyle.automatic => Icons.brightness_auto_outlined,
    SpatialBasemapStyle.positron => Icons.light_mode_outlined,
    SpatialBasemapStyle.bright => Icons.wb_sunny_outlined,
    SpatialBasemapStyle.liberty => Icons.palette_outlined,
    SpatialBasemapStyle.dark => Icons.dark_mode_outlined,
  };
}

class UserMapLayerSettings extends ConsumerWidget {
  const UserMapLayerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(userMapCatalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom map layers'),
        actions: [
          IconButton(
            tooltip: 'Import layer (.geojson, .json, .zip, or .pmtiles)',
            onPressed: catalog.isLoading ? null : () => _import(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load custom map layers: $error'),
          ),
        ),
        data: (value) {
          if (value.layers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.layers_clear_outlined, size: 40),
                    const SizedBox(height: 12),
                    const Text('No custom map layers have been imported.'),
                    const SizedBox(height: 12),
                    const _SupportedMapLayerFormats(),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _import(context, ref),
                      icon: const Icon(Icons.file_open_outlined),
                      label: const Text('Import layer'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: _SupportedMapLayerFormats(),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: value.layers.length,
                  onReorderItem: ref
                      .read(userMapCatalogProvider.notifier)
                      .reorder,
                  itemBuilder: (context, index) {
                    final layer = value.layers[index];
                    final supported =
                        !Platform.isLinux || layer.kind.isSupportedOnLinux;
                    return Card(
                      key: ValueKey(layer.id),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.layers_outlined),
                              title: Text(layer.name),
                              subtitle: Text(
                                supported
                                    ? layer.kind.label
                                    : '${layer.kind.label} · unsupported on Linux',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: supported && layer.enabled,
                                    onChanged: supported
                                        ? (enabled) => ref
                                              .read(
                                                userMapCatalogProvider.notifier,
                                              )
                                              .setEnabled(layer.id, enabled)
                                        : null,
                                  ),
                                  IconButton(
                                    tooltip: 'Delete layer',
                                    onPressed: () =>
                                        _delete(context, ref, layer),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                    ),
                                  ),
                                  const Icon(Icons.drag_handle_rounded),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Text('Opacity'),
                                Expanded(
                                  child: Slider(
                                    value: layer.opacity.clamp(0, 1),
                                    onChanged: supported
                                        ? (opacity) => ref
                                              .read(
                                                userMapCatalogProvider.notifier,
                                              )
                                              .setOpacity(layer.id, opacity)
                                        : null,
                                  ),
                                ),
                                SizedBox(
                                  width: 44,
                                  child: Text(
                                    '${(layer.opacity * 100).round()}%',
                                  ),
                                ),
                              ],
                            ),
                            if (layer.kind == UserMapLayerKind.demPmtiles)
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Use for 3D terrain'),
                                subtitle: const Text(
                                  'Hillshade remains visible when terrain is off.',
                                ),
                                value: value.activeTerrainLayerId == layer.id,
                                onChanged: supported && layer.enabled
                                    ? (enabled) => ref
                                          .read(userMapCatalogProvider.notifier)
                                          .setTerrain(layer.id, enabled)
                                    : null,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final selected = await FilePickerServices().selectAnyFile();
    if (selected == null || !context.mounted) return;
    final extension = selected.path.toLowerCase();
    UserMapLayerKind? kind;
    if (extension.endsWith('.pmtiles')) {
      kind = await showDialog<UserMapLayerKind>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('PMTiles layer type'),
          children: [
            for (final candidate in [
              UserMapLayerKind.rasterPmtiles,
              UserMapLayerKind.vectorPmtiles,
              UserMapLayerKind.demPmtiles,
            ])
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, candidate),
                child: Text(candidate.label),
              ),
          ],
        ),
      );
      if (kind == null) return;
    }
    try {
      await ref
          .read(userMapCatalogProvider.notifier)
          .importFile(File(selected.path), requestedKind: kind);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to import map layer: $error')),
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    UserMapLayer layer,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete map layer?'),
        content: Text('Delete ${layer.name} and its stored map data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(userMapCatalogProvider.notifier).delete(layer.id);
    }
  }
}

class _SupportedMapLayerFormats extends StatelessWidget {
  const _SupportedMapLayerFormats();

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Supported files',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          const Text(
            'GeoJSON (.geojson, .json) and zipped WGS84 Shapefiles (.zip).',
          ),
          const Text(
            'PMTiles (.pmtiles) for raster, vector, and elevation or terrain data.',
          ),
          const SizedBox(height: 4),
          Text(
            'Convert GeoTIFF and other elevation rasters to PMTiles before importing.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (Platform.isLinux) ...[
            const SizedBox(height: 4),
            Text(
              'On Linux, GeoJSON and raster PMTiles are supported; vector and elevation PMTiles are unavailable.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    ),
  );
}
