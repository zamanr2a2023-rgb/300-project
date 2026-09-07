package com.paned.app.paned_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode

/// TextureView avoids blank/white SurfaceView on some MediaTek devices
/// where Flutter reports `Width is zero` and never paints.
class MainActivity : FlutterActivity() {
  override fun getRenderMode(): RenderMode = RenderMode.texture
}
