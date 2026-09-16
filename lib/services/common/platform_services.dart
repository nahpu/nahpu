import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

enum PlatformType { mobile, desktop, unknown }

enum ScreenType { phone, tablet, desktop }

IconData get systemIcon {
  if (Platform.isAndroid) {
    return Icons.phone_android_rounded;
  } else if (Platform.isIOS) {
    return Icons.phone_iphone_rounded;
  } else if (Platform.isLinux) {
    return Icons.laptop_chromebook_rounded;
  } else if (Platform.isMacOS) {
    return Icons.laptop_mac_rounded;
  } else if (Platform.isWindows) {
    return Icons.laptop_windows_rounded;
  } else {
    return Icons.device_unknown_rounded;
  }
}

PlatformType get systemPlatform {
  if (Platform.isAndroid || Platform.isIOS) {
    return PlatformType.mobile;
  } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    return PlatformType.desktop;
  } else {
    return PlatformType.unknown;
  }
}

ScreenType getScreenType(BuildContext context) {
  final double deviceWidth = MediaQuery.of(context).size.width;
  if (deviceWidth < NahpuBreakpoints.compact) {
    return ScreenType.phone;
  } else if (deviceWidth < NahpuBreakpoints.desktop) {
    return ScreenType.tablet;
  } else {
    return ScreenType.desktop;
  }
}

/// Where an export can be written on this platform.
///
/// Kept separate from [systemPlatform] because the export rule no longer
/// tracks "is this a phone": Android resolves its Storage Access Framework
/// tree picker to a real filesystem path, so it can save directly, while iOS
/// cannot pick a folder at all.
enum ExportDestinationMode {
  /// The user browses to a folder and NAHPU writes into it.
  ///
  /// Desktop and Android. When the user has not browsed, the export falls back
  /// to the application documents directory, which is what `AppIOServices`
  /// already does with a null directory.
  chooseDirectory,

  /// No picker and no durable home: NAHPU writes the file to its temporary
  /// export directory and the user passes it on with Share.
  temporary,
}

/// What NAHPU can offer beside Share once a file has been written.
///
/// Exactly one applies per platform, which is why this is an enum rather than
/// a pair of booleans.
enum SavedFileAction {
  /// Show the containing folder in the system file browser.
  reveal,

  /// Open the system "Save to..." dialog so the user can place a copy.
  saveCopy,

  /// Nothing beyond Share.
  none,
}

/// The destination rule for the running platform.
ExportDestinationMode get platformExportDestination => Platform.isIOS
    ? ExportDestinationMode.temporary
    : ExportDestinationMode.chooseDirectory;

/// The action to offer beside Share for the running platform.
///
/// Desktop reveals the saved file in a file manager. Android cannot:
/// `FilePickerServices.openContainingDirectory` launches a `file://` URI,
/// which Android has blocked since API 24 (`FileUriExposedException`), so it
/// opens a Storage Access Framework save dialog instead — the Files app. iOS
/// needs neither, because its share sheet already carries "Save to Files".
SavedFileAction get platformSavedFileAction {
  if (systemPlatform == PlatformType.desktop) return SavedFileAction.reveal;
  if (Platform.isAndroid) return SavedFileAction.saveCopy;
  return SavedFileAction.none;
}
