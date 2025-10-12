import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/custom_date_picker.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/date_time_ext.dart';
import 'package:xpress/core/utils/date_formatter.dart';
import 'package:xpress/presentation/report/blocs/item_sales_report/item_sales_report_bloc.dart';
import 'package:xpress/presentation/report/blocs/product_sales/product_sales_bloc.dart';
import 'package:xpress/presentation/report/blocs/summary/summary_bloc.dart';
import 'package:xpress/presentation/report/blocs/transaction_report/transaction_report_bloc.dart';
import 'package:xpress/presentation/report/widgets/item_sales_report_widget.dart';
import 'package:xpress/presentation/report/widgets/product_sales_chart_widget.dart';
import 'package:xpress/presentation/report/widgets/report_menu.dart';
import 'package:xpress/presentation/report/widgets/report_title.dart';
import 'package:flutter/material.dart';
import 'package:xpress/presentation/report/widgets/summary_report_widget.dart';
import 'package:xpress/presentation/report/widgets/transaction_report_widget.dart';
import 'package:xpress/presentation/report/pages/transaction_detail_page.dart';
import 'package:xpress/core/components/buttons.dart';

import '../../../core/components/spaces.dart';

class ReportPage extends StatefulWidget {
  final VoidCallback? onOpenDetail;
  const ReportPage({super.key, this.onOpenDetail});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int selectedMenu = 0;
  String title = 'Summary Sales Report';
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();
  bool isOnline = true;
  bool hasOfflineData = false; // sementara: offline => tidak ada data

  @override
  Widget build(BuildContext context) {
    String searchDateFormatted =
        '${fromDate.toFormattedDate2()} to ${toDate.toFormattedDate2()}';
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 6),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ReportTitle(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (!isOnline) setState(() => isOnline = true);
                          },
                          child: Container(
                            height: 85,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: isOnline ? 5 : 3,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            child: const Text(
                              "Transaksi Online",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (isOnline) setState(() => isOnline = false);
                          },
                          child: Container(
                            height: 85,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: !isOnline ? 5 : 3,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            child: const Text(
                              "Transaksi Offline",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: isOnline
                        ? _buildOrdersList()
                        : (hasOfflineData
                            ? _buildOrdersList()
                            : _buildEmptyOfflineState()),
                  ),
                  if (!isOnline && hasOfflineData) ...[
                    const SizedBox(height: 8),
                    Button.filled(
                      height: 52,
                      onPressed: () {},
                      icon: Assets.icons.sync
                          .svg(height: 20, width: 20, color: AppColors.white),
                      label: 'Transfer Data',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView(
      children: [
        _getProductByDate("Selasa, 7 Oktober 2025", "Rp 120.000"),
        _getProductByDate("Senin, 6 Oktober 2025", "Rp 120.000"),
        _getProductByDate("Minggu, 5 Oktober 2025", "Rp 120.000"),
      ],
    );
  }

  Widget _buildEmptyOfflineState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.deleteMinus
              .svg(height: 128, width: 128, color: AppColors.primary),
          const SizedBox(height: 12),
          const Text(
            'Riwayat Transaksi Offline Telah Berhasil Disingkronisasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
  // }

  Widget _getProductByDate(date, income) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          margin: EdgeInsets.only(top: 4),
          height: 56,
          decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                income,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        _getProductListByDate(),
        _getProductListByDate(),
        _getProductListByDate(),
      ],
    );
  }

  Widget _getProductListByDate() {
    return InkWell(
      onTap: () {
        if (widget.onOpenDetail != null) {
          widget.onOpenDetail!.call();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TransactionDetailPage(),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        margin: EdgeInsets.symmetric(vertical: 6),
        height: 70,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(width: 2, color: AppColors.greyLight)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 8),
              child: Row(
                children: [
                  Assets.icons.nonTunai
                      .svg(color: AppColors.primary, height: 46, width: 46),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rp 158.000",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            "16.10",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            width: 24,
                          ),
                          Text(
                            "Meja 1",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              "DINE IN",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            Text(
              "TUNAI",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: 106,
              height: 37,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.all(Radius.circular(6))),
              child: Text(
                "Lunas",
                style: TextStyle(
                    color: AppColors.success,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
