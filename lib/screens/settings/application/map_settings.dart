import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/providers/map_layers.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/map_layers.dart';

class MapLayerSettings extends ConsumerWidget {
  const MapLayerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(userMapCatalogProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsMapLayers)),
      body: CommonSettingList(
        sections: [
          const _BaseLayerSection(),
          catalog.when(
            loading: () => const _LoadingCustomLayersSection(),
            error: (error, stackTrace) =>
                _CustomLayersErrorSection(error: error),
            data: (value) => _CustomLayersSection(
              catalog: value,
              onImport: () => _import(context, ref),
            ),
          ),
        ],
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
          title: Text(context.l10n.settingsMapPmtilesType),
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
        SnackBar(content: Text(context.l10n.settingsMapImportError('$error'))),
      );
    }
  }
}

class _BaseLayerSection extends ConsumerWidget {
  const _BaseLayerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(spatialBasemapStyleProvider);
    return CommonSettingSection(
      title: context.l10n.settingsMapBaseLayer,
      isDivided: true,
      children: [
        for (final style in SpatialBasemapStyle.values)
          CommonSettingTile(
            title: style.localizedLabel(context.l10n),
            label: style.localizedDescription(context.l10n),
            icon: _baseLayerIcon(style),
            trailing: selected.value == style
                ? const Icon(Icons.check_rounded)
                : null,
            onTap: () =>
                ref.read(spatialBasemapStyleProvider.notifier).setStyle(style),
          ),
      ],
    );
  }
}

class _LoadingCustomLayersSection extends StatelessWidget {
  const _LoadingCustomLayersSection();

  @override
  Widget build(BuildContext context) => CommonSettingSection(
    title: context.l10n.settingsMapCustomLayers,
    children: const [
      Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
    ],
  );
}

class _CustomLayersErrorSection extends StatelessWidget {
  const _CustomLayersErrorSection({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => CommonSettingSection(
    title: context.l10n.settingsMapCustomLayers,
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(context.l10n.settingsMapLoadError('$error')),
      ),
    ],
  );
}

class _CustomLayersSection extends ConsumerWidget {
  const _CustomLayersSection({required this.catalog, required this.onImport});

  final UserMapCatalog catalog;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context, WidgetRef ref) => CommonSettingSection(
    title: context.l10n.settingsMapCustomLayers,
    isDivided: catalog.layers.isNotEmpty,
    children: [
      if (catalog.layers.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(context.l10n.settingsMapNoCustomLayers),
        ),
      for (final layer in catalog.layers)
        _CustomLayerTile(
          layer: layer,
          onChanged: (enabled) => ref
              .read(userMapCatalogProvider.notifier)
              .setEnabled(layer.id, enabled),
        ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 2),
            child: Center(
              child: FilledButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.file_open_outlined),
                label: Text(context.l10n.settingsMapImportCustomLayer),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              _supportedFormatsMessage(context.l10n),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    ],
  );
}

class _CustomLayerTile extends StatelessWidget {
  const _CustomLayerTile({required this.layer, required this.onChanged});

  final UserMapLayer layer;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final supported = !Platform.isLinux || layer.kind.isSupportedOffline;
    return CommonSettingTile(
      title: layer.name,
      label: supported
          ? layer.kind.localizedLabel(l10n)
          : l10n.settingsMapKindUnavailableOnLinux(
              layer.kind.localizedLabel(l10n),
            ),
      icon: _layerIcon(layer.kind),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.settingsMapConfigureLayer,
            onPressed: () => _showLayerDetails(context, layer.id),
            icon: const Icon(Icons.tune_outlined),
          ),
          Tooltip(
            message: supported
                ? l10n.settingsMapShowLayer
                : l10n.settingsMapLayerUnavailableOnLinux,
            child: Checkbox(
              value: layer.enabled,
              onChanged: supported
                  ? (enabled) {
                      if (enabled != null) onChanged(enabled);
                    }
                  : null,
            ),
          ),
        ],
      ),
      onTap: null,
    );
  }
}

class _LayerDetailsSheet extends ConsumerWidget {
  const _LayerDetailsSheet({required this.layerId});

  final String layerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(userMapCatalogProvider).value;
    final index =
        catalog?.layers.indexWhere((layer) => layer.id == layerId) ?? -1;
    if (catalog == null || index < 0) return const SizedBox.shrink();
    final layer = catalog.layers[index];
    final supported = !Platform.isLinux || layer.kind.isSupportedOffline;
    final notifier = ref.read(userMapCatalogProvider.notifier);
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(layer.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              layer.kind.localizedLabel(l10n),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(),
            if (!supported) ...[
              const SizedBox(height: 8),
              Text(
                l10n.settingsMapLayerTypeUnavailableOnLinux,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Text(l10n.settingsMapOpacity),
                const Spacer(),
                Text('${(layer.opacity * 100).round()}%'),
              ],
            ),
            Slider(
              value: layer.opacity.clamp(0, 1),
              onChanged: supported
                  ? (opacity) => notifier.setOpacity(layer.id, opacity)
                  : null,
            ),
            if (layer.kind == UserMapLayerKind.demPmtiles)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsMapUseTerrain),
                subtitle: Text(l10n.settingsMapHillshadeNote),
                value: catalog.activeTerrainLayerId == layer.id,
                onChanged: supported && layer.enabled
                    ? (enabled) => notifier.setTerrain(layer.id, enabled)
                    : null,
              ),
            const SizedBox(height: 12),
            Text(
              l10n.settingsMapLayerOrder,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: index > 0
                      ? () => notifier.reorder(index, index - 1)
                      : null,
                  icon: const Icon(Icons.arrow_upward_rounded),
                  label: Text(l10n.settingsMapMoveEarlier),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: index < catalog.layers.length - 1
                      ? () => notifier.reorder(index, index + 2)
                      : null,
                  icon: const Icon(Icons.arrow_downward_rounded),
                  label: Text(l10n.settingsMapMoveLater),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _deleteLayer(context, ref, layer),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.settingsMapDeleteLayer),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showLayerDetails(BuildContext context, String layerId) {
  final isLargeScreen = MediaQuery.sizeOf(context).width >= 600;
  if (isLargeScreen) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: _LayerDetailsSheet(layerId: layerId),
        ),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _LayerDetailsSheet(layerId: layerId),
  );
}

Future<void> _deleteLayer(
  BuildContext context,
  WidgetRef ref,
  UserMapLayer layer,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.settingsMapDeleteLayerTitle),
      content: Text(context.l10n.settingsMapDeleteLayerBody(layer.name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.commonDelete),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(userMapCatalogProvider.notifier).delete(layer.id);
  if (context.mounted) Navigator.pop(context);
}

IconData _baseLayerIcon(SpatialBasemapStyle style) => switch (style) {
  SpatialBasemapStyle.none => Icons.layers_clear_outlined,
  SpatialBasemapStyle.automatic => Icons.brightness_auto_outlined,
  SpatialBasemapStyle.naturalEarthOffline => Icons.public_outlined,
  SpatialBasemapStyle.positron => Icons.light_mode_outlined,
  SpatialBasemapStyle.bright => Icons.wb_sunny_outlined,
  SpatialBasemapStyle.liberty => Icons.palette_outlined,
  SpatialBasemapStyle.dark => Icons.dark_mode_outlined,
};

IconData _layerIcon(UserMapLayerKind kind) => switch (kind) {
  UserMapLayerKind.geoJson => Icons.polyline_outlined,
  UserMapLayerKind.rasterPmtiles => Icons.image_outlined,
  UserMapLayerKind.vectorPmtiles => Icons.layers_outlined,
  UserMapLayerKind.demPmtiles => Icons.terrain_outlined,
};

String _supportedFormatsMessage(AppLocalizations l10n) => Platform.isLinux
    ? l10n.settingsMapSupportedFormatsLinux
    : l10n.settingsMapSupportedFormats;
