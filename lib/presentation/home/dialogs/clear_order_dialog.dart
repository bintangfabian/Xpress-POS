import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';

class ClearOrderDialog extends StatelessWidget {
  const ClearOrderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Padding(
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
      content: SizedBox(
        width: context.deviceWidth / 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pesan konfirmasi
              Text(
                'Pesanan yang sudah Anda masukkan akan hilang,',
                style: TextStyle(
                  fontSize: 14,
                  // height: 1.2,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                'Apakah Anda yakin ingin membatalkan pesanan ini?',
                style: TextStyle(
                  fontSize: 14,
                  // height: 1.2,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
      actions: [
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
                color: AppColors.danger,
                textColor: AppColors.white,
                borderRadius: 8.0,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
