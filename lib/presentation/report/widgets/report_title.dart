import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class ReportTitle extends StatelessWidget {
  const ReportTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8))),
      child: const Text(
        'Riwayat Pesanan',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
