import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/components/spaces.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/presentation/home/models/order_model.dart';

class QrisConfirmDialog extends StatelessWidget {
  final int total;
  final int change;
  final String orderType;
  final int? tableNumber;
  final VoidCallback onAccepted;

  const QrisConfirmDialog({
    super.key,
    required this.total,
    required this.change,
    required this.orderType,
    this.tableNumber,
    required this.onAccepted,
  });

  String _formatDate(DateTime dt) =>
      DateFormat('d MMMM yyyy').format(TimezoneHelper.toWib(dt));
  String _formatTime(DateTime dt) =>
      DateFormat('HH:mm:ss').format(TimezoneHelper.toWib(dt));

  @override
  Widget build(BuildContext context) {
    final now = TimezoneHelper.now();
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Konfirmasi QRIS',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
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
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'konfirmasi kode QR untuk membayar:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SpaceHeight(32),
            Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Assets.icons.qr.svg(
                  colorFilter:
                      ColorFilter.mode(AppColors.black, BlendMode.srcIn),
                ),
              ),
            ),
            const SpaceHeight(12),
            Text(total.currencyFormatRp,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SpaceHeight(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Order #0001  •  '),
                Text(() {
                  final label = operationModeLabel(orderType);
                  return label == '-' ? orderType : label;
                }()),
                if (tableNumber != null) ...[
                  const Text('  •  '),
                  Text('Meja $tableNumber')
                ],
              ],
            ),
            const SpaceHeight(6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_formatDate(now)),
                const Text('  •  '),
                Text(_formatTime(now)),
              ],
            ),
            // const SpaceHeight(32),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: Button.outlined(
                label: 'Batal',
                textColor: AppColors.grey,
                color: AppColors.greyLight,
                borderColor: AppColors.grey,
                fontWeight: FontWeight.w600,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Button.filled(
                label: 'Diterima',
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                onPressed: () {
                  Navigator.pop(context);
                  onAccepted();
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
