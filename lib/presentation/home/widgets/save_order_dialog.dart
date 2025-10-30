import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/data/dataoutputs/print_dataoutputs.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/presentation/home/models/product_quantity.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/spaces.dart';
import '../../table/blocs/get_table/get_table_bloc.dart';
import '../bloc/checkout/checkout_bloc.dart';

class SaveOrderDialog extends StatefulWidget {
  const SaveOrderDialog({
    super.key,
    required this.data,
    required this.totalQty,
    required this.totalPrice,
    required this.totalTax,
    required this.totalDiscount,
    required this.subTotal,
    required this.normalPrice,
    required this.table,
    required this.draftName,
  });
  final List<ProductQuantity> data;
  final int totalQty;
  final int totalPrice;
  final int totalTax;
  final int totalDiscount;
  final int subTotal;
  final int normalPrice;
  final TableModel table;
  final String draftName;

  @override
  State<SaveOrderDialog> createState() => _SaveOrderDialogState();
}

class _SaveOrderDialogState extends State<SaveOrderDialog> {
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
                'Order Berhasil Disimpan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
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
                  child: Button.filled(
                    onPressed: () async {
                      final sizeReceipt =
                          await AuthLocalDataSource().getSizeReceipt();

                      // Parse table number from String to int
                      int tableNum = 0;
                      if (widget.table.tableNumber != null) {
                        final numStr = widget.table.tableNumber!
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        tableNum = int.tryParse(numStr) ?? 0;
                      }

                      final printValue = await PrintDataoutputs.instance
                          .printChecker(widget.data, tableNum, widget.draftName,
                              'Cashier Ali', int.parse(sizeReceipt));
                      await PrintBluetoothThermal.writeBytes(printValue);
                    },
                    label: 'Print Checker',
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
