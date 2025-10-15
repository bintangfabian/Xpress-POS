import 'dart:developer';

import 'package:xpress/core/components/spaces.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/date_time_ext.dart';
import 'package:xpress/core/utils/helper_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:xpress/core/utils/permession_handler.dart';
import 'package:xpress/core/utils/transaction_sales_invoice.dart';
import 'package:xpress/data/models/response/order_remote_datasource.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';

class TransactionReportWidget extends StatelessWidget {
  final String title;
  final String searchDateFormatted;
  final List<ItemOrder> transactionReport;
  final List<Widget>? headerWidgets;
  const TransactionReportWidget({
    super.key,
    required this.transactionReport,
    required this.title,
    required this.searchDateFormatted,
    required this.headerWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
          const SpaceHeight(24.0),
          Center(
            child: Text(
              title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.0),
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  searchDateFormatted,
                  style: const TextStyle(fontSize: 16.0),
                ),
                GestureDetector(
                  onTap: () async {
                    final status = await PermessionHelper().checkPermission();
                    if (status) {
                      final pdfFile = await TransactionSalesInvoice.generate(
                          transactionReport, searchDateFormatted);
                      log("pdfFile: $pdfFile");
                      HelperPdfService.openFile(pdfFile);
                    }
                  },
                  child: const Row(
                    children: [
                      Text(
                        "PDF",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(
                        Icons.download_outlined,
                        color: AppColors.primary,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SpaceHeight(16.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: HorizontalDataTable(
                  leftHandSideColumnWidth: 50,
                  rightHandSideColumnWidth: 1020,
                  isFixedHeader: true,
                  headerWidgets: headerWidgets,
                  // isFixedFooter: true,
                  // footerWidgets: _getTitleWidget(),
                  leftSideItemBuilder: (context, index) {
                    return Container(
                      width: 40,
                      height: 52,
                      alignment: Alignment.centerLeft,
                      child: Center(
                          child: Text(transactionReport[index].id ?? '')),
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
                            'Rp ${NumberFormat('#,###').format((double.tryParse(transactionReport[index].totalAmount ?? '0') ?? 0).toInt())}',
                          )),
                        ),
                        Container(
                          width: 120,
                          height: 52,
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          alignment: Alignment.centerLeft,
                          child: Center(
                              child: Text(
                            'Rp ${NumberFormat('#,###').format((double.tryParse(transactionReport[index].subtotal ?? '0') ?? 0).toInt())}',
                          )),
                        ),
                        Container(
                          width: 100,
                          height: 52,
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          alignment: Alignment.centerLeft,
                          child: Center(
                              child: Text(
                            'Rp ${NumberFormat('#,###').format((double.tryParse(transactionReport[index].taxAmount ?? '0') ?? 0).toInt())}',
                          )),
                        ),
                        Container(
                          width: 100,
                          height: 52,
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          alignment: Alignment.centerLeft,
                          child: Center(
                            child: Text(
                              'Rp ${NumberFormat('#,###').format((double.tryParse(transactionReport[index].discountAmount ?? '0') ?? 0).toInt())}',
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 52,
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          alignment: Alignment.centerLeft,
                          child: Center(
                            child: Text(
                              'Rp ${NumberFormat('#,###').format((double.tryParse(transactionReport[index].serviceCharge ?? '0') ?? 0).toInt())}',
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 52,
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          alignment: Alignment.centerLeft,
                          child: Center(
                            child: Text(
                                (transactionReport[index].totalItems ?? 0)
                                    .toString()),
                          ),
                        ),
                        Container(
                          width: 150,
                          height: 52,
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          alignment: Alignment.centerLeft,
                          child: Center(
                            child:
                                Text(transactionReport[index].user?.name ?? ''),
                          ),
                        ),
                        Container(
                          width: 230,
                          height: 52,
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          alignment: Alignment.centerLeft,
                          child: Center(
                            child: Text(transactionReport[index]
                                    .createdAt
                                    ?.toFormattedDate() ??
                                ''),
                          ),
                        ),
                      ],
                    );
                  },
                  itemCount: transactionReport.length,
                  rowSeparatorWidget: const Divider(
                    color: Colors.black38,
                    height: 1.0,
                    thickness: 0.0,
                  ),
                  leftHandSideColBackgroundColor: AppColors.white,
                  rightHandSideColBackgroundColor: AppColors.white,

                  itemExtent: 55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
