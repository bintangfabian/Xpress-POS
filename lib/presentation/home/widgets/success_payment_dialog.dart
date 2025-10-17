import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/data/dataoutputs/print_dataoutputs.dart';
import 'package:xpress/presentation/home/models/product_quantity.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/spaces.dart';
import '../../table/blocs/get_table/get_table_bloc.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../bloc/order/order_bloc.dart';

class SuccessPaymentDialog extends StatefulWidget {
  const SuccessPaymentDialog({
    super.key,
    required this.data,
    required this.totalQty,
    required this.totalPrice,
    required this.totalTax,
    required this.totalDiscount,
    required this.subTotal,
    required this.normalPrice,
    required this.totalService,
    required this.draftName,
  });
  final List<ProductQuantity> data;
  final int totalQty;
  final int totalPrice;
  final int totalTax;
  final int totalDiscount;
  final int subTotal;
  final int normalPrice;
  final int totalService;
  final String draftName;

  @override
  State<SuccessPaymentDialog> createState() => _SuccessPaymentDialogState();
}

class _SuccessPaymentDialogState extends State<SuccessPaymentDialog> {
  // List<ProductQuantity> data = [];
  // int totalQty = 0;
  // int totalPrice = 0;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Assets.icons.home.svg()),
            const SpaceHeight(16.0),
            const Center(
              child: Text(
                'Pembayaran telah sukses dilakukan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            const SpaceHeight(20.0),
            const Text('METODE BAYAR'),
            const SpaceHeight(5.0),
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                final paymentMethod = state.maybeWhen(
                  orElse: () => 'Cash',
                  loaded: (model, orderId) => model.paymentMethod,
                );
                return Text(
                  paymentMethod,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
            const SpaceHeight(10.0),
            const Divider(),
            const SpaceHeight(8.0),
            const Text('TOTAL TAGIHAN'),
            const SpaceHeight(5.0),
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                final total = state.maybeWhen(
                  orElse: () => 0,
                  loaded: (model, orderId) => model.total,
                );
                return Text(
                  widget.totalPrice.currencyFormatRp,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
            const SpaceHeight(10.0),
            const Divider(),
            const SpaceHeight(8.0),
            const Text('NOMINAL BAYAR'),
            const SpaceHeight(5.0),
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                final paymentAmount = state.maybeWhen(
                  orElse: () => 0,
                  loaded: (model, orderId) => model.paymentAmount,
                );
                return Text(
                  paymentAmount.ceil().currencyFormatRp,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
            const Divider(),
            const SpaceHeight(8.0),
            const Text('KEMBALIAN'),
            const SpaceHeight(5.0),
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                final paymentAmount = state.maybeWhen(
                  orElse: () => 0,
                  loaded: (model, orderId) => model.paymentAmount,
                );
                final total = state.maybeWhen(
                  orElse: () => 0,
                  loaded: (model, orderId) => model.total,
                );
                final diff = paymentAmount - total;
                log("DIFF: $diff  paymentAmount: $paymentAmount  total: $total");
                return Text(
                  diff.ceil().currencyFormatRp,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
            const SpaceHeight(10.0),
            const Divider(),
            const SpaceHeight(8.0),
            const Text('WAKTU PEMBAYARAN'),
            const SpaceHeight(5.0),
            Text(
              DateFormat('dd MMMM yyyy, HH:mm').format(TimezoneHelper.now()),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SpaceHeight(20.0),
            Row(
              children: [
                Flexible(
                  child: Button.outlined(
                    onPressed: () {
                      context
                          .read<CheckoutBloc>()
                          .add(const CheckoutEvent.started());
                      context
                          .read<GetTableBloc>()
                          .add(const GetTableEvent.getTables());
                      context.popToRoot();
                    },
                    label: 'Kembali',
                  ),
                ),
                const SpaceWidth(8.0),
                Flexible(
                  child: BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, state) {
                      final paymentAmount = state.maybeWhen(
                        orElse: () => 0,
                        loaded: (model, orderId) => model.paymentAmount,
                      );

                      final kembalian = paymentAmount - widget.totalPrice;
                      return Button.filled(
                        onPressed: () async {
                          final sizeReceipt =
                              await AuthLocalDataSource().getSizeReceipt();
                          final printValue =
                              await PrintDataoutputs.instance.printOrderV3(
                            widget.data,
                            widget.totalQty,
                            widget.totalPrice,
                            'Cash',
                            paymentAmount,
                            kembalian,
                            widget.totalTax,
                            widget.totalDiscount,
                            widget.subTotal,
                            1,
                            'Cashier Ali',
                            widget.draftName,
                            int.parse(sizeReceipt),
                          );
                          await PrintBluetoothThermal.writeBytes(printValue);
                        },
                        label: 'Print',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
