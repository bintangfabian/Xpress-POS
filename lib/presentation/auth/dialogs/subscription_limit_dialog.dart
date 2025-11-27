import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/data/models/response/subscription_limit_response.dart';

class SubscriptionLimitDialog extends StatelessWidget {
  final SubscriptionLimitResponse limitResponse;

  const SubscriptionLimitDialog({
    super.key,
    required this.limitResponse,
  });

  Color _getWarningColor() {
    switch (limitResponse.warningLevel) {
      case 'exceeded':
        return AppColors.danger;
      case 'critical':
        return AppColors.warning;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getWarningIcon() {
    switch (limitResponse.warningLevel) {
      case 'exceeded':
        return Icons.error_outline;
      case 'critical':
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  String _getTitle() {
    switch (limitResponse.warningLevel) {
      case 'exceeded':
        return 'Limit Tercapai';
      case 'critical':
        return 'Limit Hampir Tercapai';
      case 'warning':
        return 'Peringatan Limit';
      default:
        return 'Informasi Limit';
    }
  }

  String _getMessage() {
    if (!limitResponse.canCreateOrder) {
      return 'Anda telah mencapai limit transaksi bulanan. Silakan upgrade plan untuk melanjutkan transaksi.';
    } else if (limitResponse.warningLevel == 'critical') {
      return 'Limit transaksi Anda hampir tercapai. Pertimbangkan untuk upgrade plan.';
    } else if (limitResponse.warningLevel == 'warning') {
      return 'Penggunaan transaksi Anda sudah mencapai ${limitResponse.usagePercentage.toStringAsFixed(0)}% dari limit.';
    }
    return 'Informasi penggunaan transaksi Anda.';
  }

  @override
  Widget build(BuildContext context) {
    final warningColor = _getWarningColor();
    final warningIcon = _getWarningIcon();
    final title = _getTitle();
    final message = _getMessage();

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
                  warningIcon,
                  color: warningColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
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
              const SizedBox(height: 16),
              // Usage info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: warningColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: warningColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Plan: ${limitResponse.plan.name}',
                            style: TextStyle(
                              fontSize: 13,
                              color: warningColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (limitResponse.isUnlimited)
                      Text(
                        'Penggunaan: ${limitResponse.currentCount} transaksi (Unlimited)',
                        style: TextStyle(
                          fontSize: 13,
                          color: warningColor,
                        ),
                      )
                    else ...[
                      Text(
                        'Penggunaan: ${limitResponse.currentCount} / ${limitResponse.limit} transaksi',
                        style: TextStyle(
                          fontSize: 13,
                          color: warningColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: limitResponse.usagePercentage / 100,
                          backgroundColor: warningColor.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(warningColor),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${limitResponse.usagePercentage.toStringAsFixed(1)}% digunakan',
                        style: TextStyle(
                          fontSize: 12,
                          color: warningColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (limitResponse.recommendedPlan != null &&
                  !limitResponse.canCreateOrder) ...[
                const SizedBox(height: 12),
                Text(
                  'Rekomendasi: Upgrade ke plan ${limitResponse.recommendedPlan} untuk melanjutkan transaksi.',
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
