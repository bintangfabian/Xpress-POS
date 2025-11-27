import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';

/// Banner untuk menampilkan informasi bahwa sedang dalam mode offline
/// Digunakan untuk mengganti error message saat fetch data gagal
class OfflineInfoBanner extends StatelessWidget {
  final String? customMessage;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const OfflineInfoBanner({
    super.key,
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
                const Text(
                  'Mode Offline',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customMessage ??
                      'Anda sedang dalam mode offline. Silahkan hubungkan kembali koneksi internet.',
                  style: const TextStyle(
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
