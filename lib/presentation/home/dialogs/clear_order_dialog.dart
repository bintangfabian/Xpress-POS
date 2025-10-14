import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';

class ClearOrderDialog extends StatelessWidget {
  const ClearOrderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan judul dan tombol close

            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Konfirmasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                  IconButton(
                    icon: Assets.icons.cancel
                        .svg(color: AppColors.grey, height: 32, width: 32),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pesan konfirmasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: const Text(
                'Pesanan yang sudah Anda masukkan akan hilang jika kembali. Apakah Anda yakin ingin membatalkan pesanan ini?',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.2,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 24),

            // Tombol aksi
            Row(
              children: [
                Expanded(
                  child: Button.outlined(
                    onPressed: () => Navigator.pop(context, false),
                    label: 'Tidak',
                    height: 50,
                    color: AppColors.greyLight,
                    borderColor: AppColors.grey,
                    textColor: AppColors.grey,
                    borderRadius: 8.0,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button.filled(
                    onPressed: () => Navigator.pop(context, true),
                    label: 'Ya, Batalkan',
                    height: 50,
                    color: const Color(0xFFB91C1C),
                    textColor: AppColors.white,
                    borderRadius: 8.0,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
