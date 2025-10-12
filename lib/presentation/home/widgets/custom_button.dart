import 'package:flutter/material.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/constants/colors.dart';
import '../../../core/assets/assets.gen.dart';

/// Wrapper khusus untuk tombol di Home page.
/// Pakai Button dari core/components/buttons.dart di dalamnya,
/// lalu tambah kondisi sesuai kebutuhan desain Home.
class CustomButton extends StatelessWidget {
  final String? label;
  final SvgGenImage? svgIcon;
  final VoidCallback onPressed;
  final bool filled;
  final double width;
  final double height;
  final bool disabled;

  const CustomButton({
    super.key,
    this.label,
    this.svgIcon,
    required this.onPressed,
    this.filled = false,
    this.width = 128,
    this.height = 52,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      // 🔹 Filled style (primary bg + white text/icon)
      return Button.filled(
        onPressed: onPressed,
        label: label ?? '',
        width: width,
        height: height,
        color: AppColors.primary,
        textColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 8),
        icon: svgIcon?.svg(width: 20, height: 20, color: Colors.white),
        fontWeight: FontWeight.bold,
        disabled: disabled,
      );
    } else {
      // 🔹 Outlined style (blueLight bg + primary border + primary text/icon)
      return Button.outlined(
        onPressed: onPressed,
        label: label ?? '',
        width: width,
        height: height,
        color: AppColors.primaryLight,
        borderColor: AppColors.primary,
        textColor: AppColors.primary,
        borderWidth: 2,
        padding: EdgeInsets.symmetric(horizontal: 8),
        icon: svgIcon?.svg(width: 20, height: 20, color: AppColors.primary),
        fontWeight: FontWeight.bold,
        disabled: disabled,
      );
    }
  }
}
