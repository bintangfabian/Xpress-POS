import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/components/spaces.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:xpress/presentation/home/pages/dashboard_page.dart';
import 'package:xpress/data/datasources/order_history_local_datasource.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/presentation/home/models/order_model.dart';

class QrisSuccessDialog extends StatelessWidget {
  final int total;
  final int change;
  final String orderType;
  final int? tableNumber;
  final String? orderNumber;
  final Future<bool> Function()? onSubmitOrder;

  const QrisSuccessDialog({
    super.key,
    required this.total,
    required this.change,
    required this.orderType,
    this.tableNumber,
    this.orderNumber,
    this.onSubmitOrder,
  });

  String _formatDate(DateTime dt) =>
      DateFormat('d MMMM yyyy').format(TimezoneHelper.toWib(dt));
  String _formatTime(DateTime dt) =>
      DateFormat('HH:mm:ss').format(TimezoneHelper.toWib(dt));
  String get _orderTypeLabel {
    final label = operationModeLabel(orderType);
    return label == '-' ? orderType : label;
  }

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
            const Text('Transaksi Berhasil',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            IconButton(
              icon: Assets.icons.cancel
                  .svg(color: AppColors.grey, height: 32, width: 32),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Pembayaran QRIS Berhasil!',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const SpaceHeight(32),
            Container(
              height: 107,
              width: 107,
              decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 6, color: AppColors.success)),
              child: Assets.icons.checklis.svg(color: AppColors.success),
            ),
            // const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SpaceHeight(12),
            Text(total.currencyFormatRp,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),

            const SpaceHeight(32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Order ${orderNumber ?? '#0001'}  -  '),
                Text(_orderTypeLabel),
                if (tableNumber != null) ...[
                  const Text('  -  '),
                  Text('Meja $tableNumber')
                ],
              ],
            ),
            const SpaceHeight(6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_formatDate(now)),
                const SizedBox(
                  width: 6,
                ),
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
                label: 'Selesai',
                textColor: AppColors.grey,
                color: AppColors.greyLight,
                borderColor: AppColors.grey,
                fontWeight: FontWeight.w600,
                onPressed: () async {
                  // Submit order to server
                  if (onSubmitOrder != null) {
                    final success = await onSubmitOrder!();
                    if (!success) {
                      // Show error if submission failed
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal menyimpan order ke server'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                      // Continue anyway to save locally
                    }
                  }

                  // Save to local history
                  final now2 = TimezoneHelper.now();
                  final id = await OrderHistoryLocalDatasource.instance
                      .getCurrentOrderId();
                  await OrderHistoryLocalDatasource.instance.addHistory({
                    'orderId': id,
                    'total': total,
                    'change': change,
                    'method': 'Qris',
                    'time': now2.toIso8601String(),
                    'orderType': normalizeOperationMode(orderType),
                    'tableNumber': tableNumber,
                  });
                  await OrderHistoryLocalDatasource.instance.incrementOrderId();

                  // reset checkout
                  // ignore: use_build_context_synchronously
                  context
                      .read<CheckoutBloc>()
                      .add(const CheckoutEvent.clearOrder());

                  // navigate to Home
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const DashboardPage(initialIndex: 0)),
                    (route) => false,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Button.filled(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                label: 'Cetak Struk',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cetak struk (coming soon)')),
                  );
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
