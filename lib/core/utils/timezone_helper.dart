class TimezoneHelper {
  static const Duration _wibOffset = Duration(hours: 7);

  /// Returns the current time adjusted to WIB (UTC+7).
  static DateTime now() {
    return DateTime.now().toUtc().add(_wibOffset);
  }

  /// Converts any [dateTime] to WIB (UTC+7).
  static DateTime toWib(DateTime dateTime) {
    return dateTime.toUtc().add(_wibOffset);
  }
}
