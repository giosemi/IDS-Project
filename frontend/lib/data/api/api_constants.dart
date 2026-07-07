import 'package:flutter/foundation.dart';

/// Backend locale: su emulatore Android `localhost` punta al device, non al Mac.
String get kBaseUrl {
  if (kIsWeb) return 'http://localhost:8081';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:8081';
    default:
      return 'http://localhost:8081';
  }
}
