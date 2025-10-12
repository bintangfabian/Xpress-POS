import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:xpress/presentation/table/models/draft_order_model.dart';
import 'package:xpress/presentation/table/pages/payment_table_page.dart';
import 'package:xpress/presentation/home/pages/dashboard_page.dart';

class CardTableWidget extends StatefulWidget {
  final TableModel table;
  const CardTableWidget({super.key, required this.table});

  @override
  State<CardTableWidget> createState() => _CardTableWidgetState();
}

class _CardTableWidgetState extends State<CardTableWidget> {
  DraftOrderModel? data;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    if (widget.table.status != 'available') {
      data = await ProductLocalDatasource.instance
          .getDraftOrderById(widget.table.orderId);
    }
  }

  // Helper method to get color based on status
  Color _getBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.successLight;
      case 'reserved':
        return AppColors.warningLight;
      case 'occupied':
        return AppColors.dangerLight;
      case 'maintenance':
        return AppColors.greyLight;
      default:
        return AppColors.greyLight;
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.success;
      case 'reserved':
        return AppColors.warning;
      case 'occupied':
        return AppColors.danger;
      case 'maintenance':
        return AppColors.grey;
      default:
        return AppColors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Tersedia';
      case 'reserved':
        return 'Reservasi';
      case 'occupied':
        return 'Terpakai';
      case 'maintenance':
        return 'Dalam Perbaikan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.table.status;
    final isAvailable = status.toLowerCase() == 'available';
    final backgroundColor = _getBackgroundColor(status);
    final textColor = _getTextColor(status);
    final statusText = _getStatusText(status);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        if (isAvailable) {
          // ✅ Pindah ke DashboardPage dengan table terpilih
          context.push(DashboardPage(
            initialIndex: 0, // langsung ke HomePage
            selectedTable: widget.table,
          ));
        } else {
          context.read<CheckoutBloc>().add(
                CheckoutEvent.loadDraftOrder(data!),
              );
          log("Data Draft Order: ${data!.toMap()}");
          context.push(PaymentTablePage(
            table: widget.table,
            draftOrder: data!,
          ));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display table name
            Text(
              widget.table.name ?? 'Table ${widget.table.tableNumber ?? ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            // Display status in Indonesian
            Text(
              statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
