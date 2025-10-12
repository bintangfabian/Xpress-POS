import 'package:flutter/foundation.dart';

class Variables {
  static const String appName = 'Xpress POS';
  static const String apiVersion = 'v1';

  // Optional override via --dart-define=BASE_URL=http://<host>:<port>
  static const String envBaseUrl =
      String.fromEnvironment('BASE_URL', defaultValue: '');

  // Dynamic base URL per platform
  static String get baseUrl {
    if (envBaseUrl.isNotEmpty) return envBaseUrl;

    if (kIsWeb) return 'http://localhost:8000';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator -> host machine
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        // iOS simulator / desktop
        return 'http://127.0.0.1:8000';
    }
  }
}
