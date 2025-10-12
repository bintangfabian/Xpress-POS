import 'package:flutter/material.dart';
import 'package:xpress/core/components/spaces.dart';
import 'package:xpress/core/extensions/date_time_ext.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/presentation/home/models/order_model.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

class SalesWidget extends StatelessWidget {
  final List<OrderModel> orders;
  final List<Widget>? headerWidgets;
  const SalesWidget({
    super.key,
    required this.orders,
    required this.headerWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SpaceHeight(16.0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: HorizontalDataTable(
                leftHandSideColumnWidth: 40,
                rightHandSideColumnWidth: 1700,
                isFixedHeader: true,
                headerWidgets: headerWidgets,
                leftSideItemBuilder: (context, index) {
                  return Container(
                    width: 40,
                    height: 52,
                    alignment: Alignment.centerLeft,
                    child: Center(child: Text(orders[index].id.toString())),
                  );
                },
                rightSideItemBuilder: (context, index) {
                  return Row(
                    children: <Widget>[
                      Container(
                        width: 120,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                            child: Text(
                          orders[index].customerName == ''
                              ? '-'
                              : orders[index].customerName,
                        )),
                      ),
                      Container(
                        width: 120,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                            child: Text(
                          orders[index].status,
                        )),
                      ),
                      Container(
                        width: 60,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                            child: Text(
                          orders[index].isSync == 0
                              ? 'Belum' //belum sync
                              : 'Sudah', //sudah sync
                        )),
                      ),
                      Container(
                        width: 120,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(child: Text(orders[index].paymentStatus)),
                      ),
                      Container(
                        width: 120,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(child: Text(orders[index].paymentMethod)),
                      ),
                      Container(
                        width: 120,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                            child: Text(
                          orders[index].paymentAmount.currencyFormatRp,
                        )),
                      ),
                      Container(
                        width: 120,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                            child: Text(
                          orders[index].subTotal.currencyFormatRp,
                        )),
                      ),
                      Container(
                        width: 120,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Text(
                            orders[index].tax.currencyFormatRp,
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Text(
                            orders[index].discountAmount.currencyFormatRp,
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Text(
                              orders[index].serviceCharge.currencyFormatRp),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Text(orders[index].total.currencyFormatRp),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Text(orders[index].paymentMethod),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Text(orders[index].totalItem.toString()),
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Text(orders[index].namaKasir),
                        ),
                      ),
                      Container(
                        width: 230,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Text(
                            DateTime.parse(orders[index].transactionTime)
                                .toFormattedDate2(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                itemCount: orders.length,
                rowSeparatorWidget: const Divider(
                  color: Colors.black38,
                  height: 1.0,
                  thickness: 0.0,
                ),
                leftHandSideColBackgroundColor: const Color(0xFFFFFFFF),
                rightHandSideColBackgroundColor: const Color(0xFFFFFFFF),
                itemExtent: 55,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
