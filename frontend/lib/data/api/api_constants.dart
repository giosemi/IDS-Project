import 'package:flutter/foundation.dart';

/// Override at build time, e.g.:
/// `fvm flutter build apk --dart-define=API_BASE_URL=http://192.168.1.42:8081`
const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

/// Backend locale: su emulatore Android `localhost` punta al device, non al Mac.
/// Su telefono fisico usa l'IP LAN del Mac (vedi README / istruzioni build).
String get kBaseUrl {
  if (_apiBaseUrlOverride.isNotEmpty) {
    return _apiBaseUrlOverride;
  }
  if (kIsWeb) return 'http://localhost:8081';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:8081';
    default:
      return 'http://localhost:8081';
  }
}
