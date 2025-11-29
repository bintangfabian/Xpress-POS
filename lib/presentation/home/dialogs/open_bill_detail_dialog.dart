import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/data/models/response/order_response_model.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/utils/amount_parser.dart';

class OpenBillDetailDialog extends StatelessWidget {
  final ItemOrder order;
  final VoidCallback? onContinue;
  final VoidCallback? onPay;

  const OpenBillDetailDialog({
    super.key,
    required this.order,
    this.onContinue,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total from items if totalAmount is 0
    int totalAmount = AmountParser.parse(order.totalAmount);
    if (totalAmount == 0 && order.items != null && order.items!.isNotEmpty) {
      totalAmount = order.items!.fold<int>(
        0,
        (sum, item) {
          // Calculate from unit_price * quantity if total_price is 0
          int itemTotal = AmountParser.parse(item.totalPrice);
          if (itemTotal == 0) {
            final unitPrice = AmountParser.parse(item.unitPrice);
            final quantity = item.quantity ?? 0;
            itemTotal = unitPrice * quantity;
          }
          return sum + itemTotal;
        },
      );
    }

    final tableName = order.table?.name ??
        (order.table?.tableNumber != null
            ? 'Meja ${order.table!.tableNumber}'
            : null);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.white,
      child: SizedBox(
        width: 500,
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
                  const Text(
                    'Detail Open Bill',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      totalAmount.currencyFormatRp,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.orderNumber ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (tableName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tableName,
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Items List
                    const Text(
                      'Daftar Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (order.items != null && order.items!.isNotEmpty) ...[
                      ...order.items!.map((item) {
                        // Calculate from unit_price * quantity if total_price is 0
                        int itemTotal = AmountParser.parse(item.totalPrice);
                        if (itemTotal == 0) {
                          final unitPrice = AmountParser.parse(item.unitPrice);
                          final quantity = item.quantity ?? 0;
                          itemTotal = unitPrice * quantity;
                        }
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.greyLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${item.quantity ?? 0}x',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    // ✅ Display variants
                                    if (item.productOptions != null &&
                                        item.productOptions!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      ...item.productOptions!.map((option) {
                                        if (option is Map<String, dynamic>) {
                                          final name =
                                              option['name']?.toString() ?? '';
                                          final value =
                                              option['value']?.toString() ?? '';
                                          final priceAdj =
                                              option['price_adjustment'] ?? 0;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, top: 2),
                                            child: Text(
                                              '$name: $value${priceAdj != 0 && priceAdj != '0' ? ' (+${priceAdj})' : ''}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.grey,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      }).toList(),
                                    ],
                                    // ✅ Display modifiers
                                    if (item.modifiers != null &&
                                        item.modifiers!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      ...item.modifiers!.map((modifier) {
                                        final name =
                                            modifier.modifierItem?.name ??
                                                'Modifier';
                                        final priceDelta =
                                            modifier.priceDelta ?? '0';
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, top: 2),
                                          child: Text(
                                            '+ $name${priceDelta != '0' && priceDelta != 0 ? ' (+$priceDelta)' : ''}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                    if (item.notes != null &&
                                        item.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.notes!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                itemTotal.currencyFormatRp,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ] else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Tidak ada items',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.greyLight),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Button.outlined(
                      onPressed: () {
                        Navigator.pop(context);
                        onContinue?.call();
                      },
                      label: 'Lanjutkan',
                      height: 48,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      borderColor: AppColors.primary,
                      textColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Button.filled(
                      onPressed: () {
                        Navigator.pop(context);
                        onPay?.call();
                      },
                      label: 'Bayar',
                      height: 48,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
