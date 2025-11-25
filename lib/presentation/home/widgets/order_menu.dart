import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:xpress/presentation/home/models/product_quantity.dart';

import '../../../core/constants/colors.dart';

class OrderMenu extends StatelessWidget {
  final ProductQuantity data;
  final VoidCallback? onTap;

  const OrderMenu({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final basePrice = data.product.price?.toIntegerFromText ?? 0;
    final variantPrice =
        data.variants?.fold<int>(0, (sum, v) => sum + v.priceAdjustment) ?? 0;
    final totalPrice = basePrice + variantPrice;
    final subtotal = totalPrice * data.quantity;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Menu (nama + harga satuan)
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.product.name ?? "-",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "@${basePrice.currencyFormatRp}",
                    style: const TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                  if (data.variants != null && data.variants!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...data.variants!.map((v) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Text(
                            v.name,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        )),
                  ],
                ],
              ),
            ),

            // Quantity (- qty +)
            SizedBox(
              width: 150,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.danger, width: 1),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.remove,
                            size: 20, color: AppColors.danger),
                        onPressed: () {
                          context
                              .read<CheckoutBloc>()
                              .setPendingVariants(data.variants);
                          context
                              .read<CheckoutBloc>()
                              .add(CheckoutEvent.removeItem(data.product));
                        },
                      ),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.grey, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          data.quantity.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.success, width: 1),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add,
                            size: 20, color: AppColors.success),
                        onPressed: () {
                          context
                              .read<CheckoutBloc>()
                              .setPendingVariants(data.variants);
                          context
                              .read<CheckoutBloc>()
                              .add(CheckoutEvent.addItem(data.product));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Subtotal
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  subtotal.currencyFormatRp,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
