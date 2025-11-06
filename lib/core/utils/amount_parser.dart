class AmountParser {
  const AmountParser._();

  /// Parse various currency formats (e.g. "114000.00", "114,000", "Rp 114.000")
  /// into integer rupiah values.
  static int parse(dynamic raw) {
    if (raw == null) return 0;
    if (raw is num) return raw.round();

    final text = raw.toString().trim();
    if (text.isEmpty) return 0;

    // Keep digits, comma, dot, and minus sign only.
    final sanitized = text.replaceAll(RegExp(r'[^0-9,.\-]'), '');
    if (sanitized.isEmpty) return 0;

    String normalized = sanitized;
    final lastComma = sanitized.lastIndexOf(',');
    final lastDot = sanitized.lastIndexOf('.');

    if (lastComma != -1 && lastDot != -1) {
      // Both comma and dot exist; decide which is decimal separator
      if (lastComma > lastDot) {
        // Format like 15.000,50 -> remove thousand dots, convert comma to dot
        normalized =
            sanitized.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Format like 114,000.25 -> comma is thousand separator
        normalized = sanitized.replaceAll(',', '');
      }
    } else if (lastComma != -1) {
      final decimals = sanitized.length - lastComma - 1;
      // If comma is followed by <=2 digits, treat as decimal separator
      normalized = decimals <= 2
          ? sanitized.replaceAll(',', '.')
          : sanitized.replaceAll(',', '');
    } else if (lastDot != -1) {
      // Handle thousand separators with dot (e.g. 15.000)
      final decimals = sanitized.length - lastDot - 1;
      final multipleDots = sanitized.indexOf('.') != lastDot;
      if (decimals > 2 || multipleDots) {
        normalized = sanitized.replaceAll('.', '');
      }
    }

    final double? value = double.tryParse(normalized);
    if (value != null) {
      return value.round();
    }

    final digitsOnly = sanitized.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }
}
