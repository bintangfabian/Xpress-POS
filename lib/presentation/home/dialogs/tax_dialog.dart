import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/components/spaces.dart';
import 'package:xpress/core/constants/colors.dart';

class TaxDialog extends StatefulWidget {
  final List<Map<String, dynamic>> taxes;
  final int? initial;
  const TaxDialog(
      {super.key,
      this.taxes = const [
        {'name': 'PB1', 'desc': 'tarif pajak (10%)', 'value': 10}
      ],
      this.initial});

  @override
  State<TaxDialog> createState() => _TaxDialogState();
}

class _TaxDialogState extends State<TaxDialog> {
  int? selectedIndex;

  @override
  void initState() {
    if (widget.initial != null) {
      final idx = widget.taxes.indexWhere((e) => e['value'] == widget.initial);
      if (idx != -1) selectedIndex = idx;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('PAJAK',
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
              ListView.separated(
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  final t = widget.taxes[i];
                  final isSelected = selectedIndex == i;
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['name'] ?? '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(t['desc'] ?? '-',
                                style: const TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
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
                            border:
                                Border.all(color: AppColors.primary, width: 1),
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
                  );
                },
                separatorBuilder: (_, __) => const SpaceHeight(12),
                itemCount: widget.taxes.length,
              ),
              // const SpaceHeight(16),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: Button.outlined(
                label: 'Kembali',
                color: AppColors.greyLight,
                borderColor: AppColors.grey,
                textColor: AppColors.grey,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Button.filled(
                color: AppColors.success,
                label: 'Apply',
                onPressed: () => Navigator.pop(
                    context,
                    selectedIndex != null
                        ? widget.taxes[selectedIndex!]['value'] as int
                        : null),
              ),
            ),
          ],
        )
      ],
    );
  }
}
