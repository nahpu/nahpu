# NAHPU release keep rules for R8. Everything not kept here or by a
# dependency's consumer rules is shrunk and obfuscated.

# maplibre_android drives the native MapLibre view from Dart through jnigen
# bindings (lib/src/jni.g.dart), which look these Flutter embedding types up by
# their JNI names. The plugin's consumer rules keep org.maplibre.** and its own
# classes are @Keep, but these are not, so without them native maps fail in
# obfuscated release builds.
-keep class io.flutter.plugin.platform.PlatformView { *; }
-keep class io.flutter.plugin.platform.PlatformViewFactory { *; }
-keep class io.flutter.plugin.common.PluginRegistry { *; }
-keep class io.flutter.plugin.common.PluginRegistry$ActivityResultListener { *; }
-keep class io.flutter.plugin.common.PluginRegistry$NewIntentListener { *; }
-keep class io.flutter.plugin.common.PluginRegistry$RequestPermissionsResultListener { *; }
-keep class io.flutter.plugin.common.PluginRegistry$UserLeaveHintListener { *; }
-keep class io.flutter.plugin.common.PluginRegistry$WindowFocusChangedListener { *; }
-keep class io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding { *; }
-keep class io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding$OnSaveInstanceStateListener { *; }
