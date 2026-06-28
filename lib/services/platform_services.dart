import 'dart:io';
import 'package:flutter/material.dart';

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
  if (deviceWidth < 600) {
    return ScreenType.phone;
  } else if (deviceWidth < 900) {
    return ScreenType.tablet;
  } else {
    return ScreenType.desktop;
  }
}
