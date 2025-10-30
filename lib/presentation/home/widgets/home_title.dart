import 'package:flutter/material.dart';
import '../../../core/components/components.dart';
import '../../../core/constants/colors.dart';
import '../../../core/assets/assets.gen.dart';

class HomeTitle extends StatelessWidget {
  final TextEditingController controller;
  final Function(String value)? onChanged;
  final bool showSortButton;
  final VoidCallback? onSortPressed;

  const HomeTitle({
    super.key,
    required this.controller,
    this.onChanged,
    this.showSortButton = false,
    this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 🔹 Judul + tanggal
        const Text(
          'Daftar Menu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        // 🔹 Search
        SizedBox(
          width: 328,
          height: 48,
          child: SearchInput(
            controller: controller,
            onChanged: onChanged,
            hintText: 'Search Menu',
          ),
        ),

        // const SizedBox(width: 8),

        Button.outlined(
          width: 48,
          height: 48,
          icon: Assets.icons.sort.svg(
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          ),
          color: AppColors.primaryLight,
          borderColor: AppColors.primary,
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: Implement add table functionality
          },
        ),
      ],
    );
  }
}
