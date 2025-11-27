import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

/// Helper untuk menampilkan snackbar dengan informasi offline
/// Mengganti error snackbar dengan informasi mode offline
class SnackbarHelper {
  /// Menampilkan snackbar error atau informasi offline berdasarkan status koneksi
  static void showErrorOrOffline(
    BuildContext context,
    String errorMessage, {
    String? offlineMessage,
  }) {
    final onlineCheckerBloc = context.read<OnlineCheckerBloc>();
    final isOnline = onlineCheckerBloc.isOnline;

    if (!isOnline) {
      // Tampilkan informasi offline, bukan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  offlineMessage ??
                      'Anda sedang dalam mode offline. Silahkan hubungkan kembali koneksi internet.',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.warningLight,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      // Tampilkan error normal saat online
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Menampilkan snackbar informasi offline saja
  static void showOfflineInfo(
    BuildContext context, {
    String? customMessage,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customMessage ??
                    'Anda sedang dalam mode offline. Silahkan hubungkan kembali koneksi internet.',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warningLight,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
