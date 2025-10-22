import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';

class PerformanceOptimizer {
  static void optimizeApp() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (kReleaseMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  static void optimizeImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 50;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20;
  }
}