class Variables {
  static const String appName = 'Xpress POS';
  static const String apiVersion = 'v1';

  // Optional override via --dart-define=BASE_URL=http://<host>:<port>
  static const String envBaseUrl = String.fromEnvironment('BASE_URL',
      defaultValue: 'https://api.xpresspos.id/'); // server xpress pos
      // defaultValue: 'http://10.0.2.2:8000'); // local database
      // defaultValue: 'http://192.168.1.11:8000'); //local database for eksternal device

  // Dynamic base URL per platform
  static String get baseUrl => envBaseUrl;
}
//
