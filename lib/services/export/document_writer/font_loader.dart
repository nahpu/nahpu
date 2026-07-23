part of '../document_writer.dart';

class _DocumentFontLoader {
  const _DocumentFontLoader();

  Future<List<Uint8List>> loadFontBytes() async {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      rootBundle,
    );
    final List<String> fontAssets = manifest
        .listAssets()
        .where(
          (String key) =>
              key.startsWith('assets/fonts/') &&
              key.endsWith('.ttf') &&
              !key.contains('nahpu_font.ttf'),
        )
        .toList();

    List<Uint8List> fontBytesList = [];
    for (var asset in fontAssets) {
      final byteData = await rootBundle.load(asset);
      fontBytesList.add(byteData.buffer.asUint8List());
    }
    return fontBytesList;
  }
}
