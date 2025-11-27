import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';

class LimitExceededDialog extends StatelessWidget {
  final String message;
  final String? recommendedPlan;
  final int? currentCount;
  final int? limit;

  const LimitExceededDialog({
    super.key,
    required this.message,
    this.recommendedPlan,
    this.currentCount,
    this.limit,
  });

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
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Limit Tercapai',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Assets.icons.cancel.svg(
                colorFilter: ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
                height: 32,
                width: 32,
              ),
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
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
              if (currentCount != null && limit != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warningLightActive),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Penggunaan: $currentCount / $limit transaksi',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.warningActive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (recommendedPlan != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Rekomendasi: Upgrade ke plan $recommendedPlan untuk melanjutkan transaksi.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        Button.filled(
          onPressed: () => Navigator.pop(context),
          label: 'Mengerti',
          height: 50,
          color: AppColors.primary,
          textColor: AppColors.white,
          borderRadius: 8.0,
          fontSize: 16.0,
        ),
      ],
    );
  }
}
