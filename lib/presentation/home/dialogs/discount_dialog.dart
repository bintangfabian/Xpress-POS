import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/components/spaces.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/models/response/discount_response_model.dart';

class DiscountDialog extends StatefulWidget {
  final List<Discount> discounts;
  const DiscountDialog({super.key, required this.discounts});

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final items = widget.discounts;
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('DISKON',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
            IconButton(
              icon: Assets.icons.cancel
                  .svg(color: AppColors.grey, height: 32, width: 32),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      content: SizedBox(
        width: 540,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Tidak ada diskon'),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (_, i) {
                    final d = items[i];
                    final isSelected = selectedIndex == i;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.name ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                const SizedBox(height: 4),
                                Text(d.description ?? '-',
                                    style: const TextStyle(
                                        color: AppColors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => selectedIndex = i),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.primary, width: 1),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ))
                                  : null,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SpaceHeight(12),
                  itemCount: items.length,
                ),
              const SpaceHeight(16),
              Row(
                children: [
                  Expanded(
                    child: Button.outlined(
                      label: 'Kembali',
                      color: AppColors.greyLight,
                      borderColor: AppColors.grey,
                      textColor: AppColors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Button.filled(
                      color: AppColors.success,
                      label: 'Apply',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      onPressed: () => Navigator.pop(context,
                          selectedIndex != null ? items[selectedIndex!] : null),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
