import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/presentation/table/models/draft_order_model.dart';
import 'package:xpress/presentation/home/pages/dashboard_page.dart';
import 'package:xpress/presentation/table/dialogs/table_status_dialog.dart';
import 'package:xpress/presentation/table/blocs/get_table/get_table_bloc.dart';
import 'package:xpress/data/datasources/table_remote_datasource.dart';

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
    final backgroundColor = _getBackgroundColor(status);
    final textColor = _getTextColor(status);
    final statusText = _getStatusText(status);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        // Log info meja yang diklik
        log('========================================');
        log('TABLE CLICKED:');
        log('  - Table Number: ${widget.table.tableNumber}');
        log('  - Table Name: ${widget.table.name}');
        log('  - Table ID: ${widget.table.id}');
        log('  - Current Status: ${widget.table.status}');
        log('========================================');

        // Tampilkan dialog untuk memilih aksi
        final result = await showDialog<String>(
          context: context,
          builder: (context) => TableStatusDialog(
            currentStatus: widget.table.status,
            onStatusChanged: (newStatus) {
              log('Status dialog callback - closing with result: $newStatus');
              Navigator.pop(context, newStatus);
            },
          ),
        );

        log('Dialog returned with result: $result');
        if (result == null) {
          log('User cancelled dialog');
          return; // User membatalkan dialog
        }

        // Handle berdasarkan pilihan
        if (result == 'add_order') {
          if (!context.mounted) return;
          // Tambah Pesanan - selalu ke HomePage untuk buat/tambah pesanan
          context.push(DashboardPage(
            initialIndex: 0,
            selectedTable: widget.table,
          ));
        } else {
          if (!context.mounted) return;
          // Update status meja (available, reserved, occupied)
          log('Preparing to update status to: $result');

          if (widget.table.id == null || widget.table.id!.isEmpty) {
            log('ERROR: Table ID is null or empty');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ID Meja tidak ditemukan'),
                backgroundColor: AppColors.danger,
              ),
            );
            return;
          }

          log('Starting update process...');

          // Update status ke database (tanpa loading indicator untuk test)
          final datasource = TableRemoteDatasource();
          final updateResult = await datasource.updateTableStatus(
            tableId: widget.table.id!,
            status: result,
          );

          log('Update completed, processing result...');

          // Handle result
          if (!mounted) {
            log('Widget not mounted, skipping UI update');
            return;
          }

          updateResult.fold(
            (error) {
              log('Update FAILED with error: $error');
              // Show error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $error'),
                  backgroundColor: AppColors.danger,
                  duration: const Duration(seconds: 5),
                ),
              );
            },
            (_) {
              log('Update SUCCESS! Refreshing table list...');
              // Refresh table list
              context.read<GetTableBloc>().add(
                    const GetTableEvent.getTables(),
                  );

              log('Showing success snackbar...');
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Status meja berhasil diubah'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
              log('All done!');
            },
          );
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
