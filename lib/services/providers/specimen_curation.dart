import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';

/// The tissue check setup, kept on this device.
final tissueCheckSettingsProvider =
    NotifierProvider<TissueCheckSettingsNotifier, TissueCheckSettings>(
      TissueCheckSettingsNotifier.new,
    );

class TissueCheckSettingsNotifier extends Notifier<TissueCheckSettings> {
  @override
  TissueCheckSettings build() => TissueCheckSettings.decode(
    ref.watch(settingProvider).getString(tissueCheckPrefKey),
  );

  Future<void> set(TissueCheckSettings settings) async {
    state = settings;
    await ref
        .read(settingProvider)
        .setString(tissueCheckPrefKey, settings.encode());
  }
}
