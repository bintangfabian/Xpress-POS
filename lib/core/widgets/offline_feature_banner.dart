import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';

/// Banner untuk menampilkan informasi bahwa fitur belum tersedia dalam mode offline
/// Menampilkan pesan "coming soon" untuk fitur offline
class OfflineFeatureBanner extends StatelessWidget {
  final String featureName;
  final String? customMessage;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const OfflineFeatureBanner({
    super.key,
    required this.featureName,
    this.customMessage,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  customMessage != null
                      ? customMessage!
                      : 'Fitur $featureName Akan segera Hadir Dalam Mode Offline',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Silahkan Hubungkan Kembali Koneksi Internet',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
