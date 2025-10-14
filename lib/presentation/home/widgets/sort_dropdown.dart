import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/assets/assets.gen.dart';

enum SortOption {
  nameAZ('Nama A-Z'),
  nameZA('Nama Z-A'),
  priceLowHigh('Harga Rendah-Tinggi'),
  priceHighLow('Harga Tinggi-Rendah');

  final String label;
  const SortOption(this.label);
}

class SortDropdown extends StatelessWidget {
  final SortOption? selectedOption;
  final Function(SortOption) onChanged;

  const SortDropdown({
    super.key,
    this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      offset: const Offset(0, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      color: AppColors.white,
      itemBuilder: (context) => SortOption.values.map((option) {
        return PopupMenuItem<SortOption>(
          value: option,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          height: 48,
          child: Text(
            option.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
        );
      }).toList(),
      onSelected: onChanged,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Assets.icons.sort.svg(
            height: 24,
            width: 24,
            colorFilter:
                const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
