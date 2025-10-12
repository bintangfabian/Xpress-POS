import 'package:flutter/material.dart';
import 'package:xpress/data/models/response/discount_response_model.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/constants/colors.dart';

class ManageDiscountCard extends StatelessWidget {
  final Discount data;
  final VoidCallback onEditTap;
  final VoidCallback? onDeleteTap;

  const ManageDiscountCard({
    super.key,
    required this.data,
    required this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.greyLightActive),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: [
                InkWell(
                  onTap: onDeleteTap,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Assets.icons.trash
                        .svg(height: 16, width: 16, color: AppColors.white),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onEditTap,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Assets.icons.edit
                        .svg(height: 16, width: 16, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Assets.icons.bill
                    .svg(height: 42, width: 42, color: AppColors.black),
              ),
              const SizedBox(height: 16),
              _rowText('Nama', data.name ?? '-'),
              const SizedBox(height: 6),
              _rowText('Nilai', '${data.value?.replaceAll('.00', '') ?? '0'}%'),
              const SizedBox(height: 6),
              _rowText('Deskripsi', data.description ?? '-'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rowText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppColors.black, fontSize: 14),
        children: [
          TextSpan(
              text: '$label',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const TextSpan(text: '  :  '),
          TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
