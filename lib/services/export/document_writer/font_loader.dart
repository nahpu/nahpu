part of '../document_writer.dart';

class _DocumentFontLoader {
  const _DocumentFontLoader();

  /// Font bytes handed to the Typst compiler: every bundled family, plus the
  /// families the user installed into `UserConfigs/fonts/`.
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
    fontBytesList.addAll(await _userFontBytes());
    return fontBytesList;
  }

  /// User fonts are best-effort: a missing or unreadable catalog must not stop
  /// a document from being generated with the bundled families.
  Future<List<Uint8List>> _userFontBytes() async {
    try {
      final bytes = await const UserFontService().loadAllFontBytes();
      return bytes.map(Uint8List.fromList).toList(growable: false);
    } on Object {
      return const [];
    }
  }
}
