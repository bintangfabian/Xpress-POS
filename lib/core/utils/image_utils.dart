import 'package:xpress/core/constants/variables.dart';

class ImageUtils {
  /// Validates if an image URL is safe to load
  static bool isValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;

    // Block external placeholder services
    final blockedDomains = [
      'via.placeholder.com',
      'placeholder.com',
      'picsum.photos',
      'loremflickr.com',
    ];

    for (String domain in blockedDomains) {
      if (imageUrl.contains(domain)) {
        return false;
      }
    }

    return true;
  }

  /// Gets a safe image URL, returns null if URL is not safe
  static String? getSafeImageUrl(String? imageUrl) {
    if (!isValidImageUrl(imageUrl)) {
      return null;
    }

    if (imageUrl!.contains('http')) {
      return imageUrl;
    } else {
      return '${Variables.baseUrl}/$imageUrl';
    }
  }

  /// Gets a fallback image URL for local assets
  static String getFallbackImagePath() {
    return 'assets/images/no-product.png';
  }
}
