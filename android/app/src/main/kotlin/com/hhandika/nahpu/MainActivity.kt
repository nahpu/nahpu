package com.hhandika.nahpu

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android 15+ draws apps targeting SDK 35 edge-to-edge. Opt in on older
        // versions too, so the Flutter UI handles the same system bar insets on
        // every Android version.
        WindowCompat.enableEdgeToEdge(window)
        super.onCreate(savedInstanceState)
    }
}
