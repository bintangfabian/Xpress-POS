import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/spaces.dart';
import 'package:xpress/core/extensions/int_ext.dart';

class OpenBillDialog extends StatelessWidget {
  final int totalPrice;
  final String orderNumber;
  final int? tableNumber;
  final String? orderType;

  const OpenBillDialog({
    super.key,
    required this.totalPrice,
    required this.orderNumber,
    this.tableNumber,
    this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.white,
      child: SizedBox(
        width: 491,
        height: 584,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Open Bill',
                      style: TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            const SpaceHeight(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.greyLightActive, width: 2)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(totalPrice.currencyFormatRp,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(orderNumber,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              if (tableNumber != null) ...[
                                const SizedBox(width: 8),
                                Text('Meja $tableNumber',
                                    style: const TextStyle(
                                        color: AppColors.black)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (orderType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                          // border:
                          //     Border.all(color: AppColors.primary, width: 1),
                        ),
                        child: Text(orderType!,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    const Spacer()
                  ],
                ),
              ),
            ),
            const SpaceHeight(12),
          ],
        ),
      ),
    );
  }
}
