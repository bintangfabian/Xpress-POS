import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';

class TableStatusDialog extends StatefulWidget {
  final String currentStatus; // available, reserved, occupied
  final Function(String newStatus) onStatusChanged;

  const TableStatusDialog({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  State<TableStatusDialog> createState() => _TableStatusDialogState();
}

class _TableStatusDialogState extends State<TableStatusDialog> {
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    // Set default selection berdasarkan status meja
    final status = widget.currentStatus.toLowerCase();
    if (status == 'available') {
      selectedStatus = 'add_order'; // Default ke Tambah Pesanan
    } else if (status == 'reserved') {
      selectedStatus = 'add_order'; // Default ke Tambah Pesanan
    } else {
      selectedStatus = 'available'; // Default ke Kosongkan Meja
    }
  }

  String _getDialogMessage() {
    switch (widget.currentStatus.toLowerCase()) {
      case 'available':
        return 'Silakan pilih status meja saat ini untuk memastikan ketersediaan dan pesanan tetap terbarui';
      case 'reserved':
        return 'Meja ini sudah di reservasi oleh pelanggan. Silakan pilih aksi berikut:';
      case 'occupied':
        return 'Meja ini sedang digunakan pelanggan. Silakan pilih aksi berikut:';
      default:
        return 'Silakan pilih status meja';
    }
  }

  List<Widget> _buildStatusOptions() {
    final status = widget.currentStatus.toLowerCase();

    if (status == 'available') {
      // Gambar 1: Meja Tersedia - semua opsi
      return [
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                label: 'Tambah Pesanan',
                backgroundColor: AppColors.successLight,
                borderColor: AppColors.success,
                textColor: AppColors.success,
                status: 'add_order',
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildStatusCard(
                label: 'Reservasi',
                backgroundColor: AppColors.warningLight,
                borderColor: AppColors.warning,
                textColor: AppColors.warning,
                status: 'reserved',
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildStatusCard(
                label: 'Terpakai',
                backgroundColor: AppColors.dangerLight,
                borderColor: AppColors.danger,
                textColor: AppColors.danger,
                status: 'occupied',
              ),
            ),
          ],
        ),
      ];
    } else if (status == 'reserved') {
      // Gambar 2: Meja Reservasi - 2 opsi
      return [
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                label: 'Tambah Pesanan',
                backgroundColor: AppColors.successLight,
                borderColor: AppColors.success,
                textColor: AppColors.success,
                status: 'add_order',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusCard(
                label: 'Terpakai',
                backgroundColor: AppColors.dangerLight,
                borderColor: AppColors.danger,
                textColor: AppColors.danger,
                status: 'occupied',
              ),
            ),
          ],
        ),
      ];
    } else {
      // Gambar 3: Meja Terpakai - 1 opsi besar
      return [
        _buildStatusCard(
          label: 'Kosongkan Meja (Tersedia)',
          backgroundColor: AppColors.successLight,
          borderColor: AppColors.success,
          textColor: AppColors.success,
          status: 'available',
          fullWidth: true,
        ),
      ];
    }
  }

  Widget _buildStatusCard({
    required String label,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required String status,
    bool fullWidth = false,
  }) {
    final isSelected = selectedStatus == status;

    return isSelected
        ? Button.filled(
            onPressed: () {
              setState(() {
                selectedStatus = status;
              });
            },
            label: label,
            height: fullWidth ? 120 : 140,
            color: borderColor,
            textColor: AppColors.white,
            borderRadius: 8.0,
            fontSize: 18.0,
            width: double.infinity,
          )
        : Button.outlined(
            onPressed: () {
              setState(() {
                selectedStatus = status;
              });
            },
            label: label,
            height: fullWidth ? 120 : 140,
            color: backgroundColor,
            borderColor: borderColor,
            textColor: textColor,
            borderRadius: 8.0,
            fontSize: 18.0,
            width: double.infinity,
          );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Status Meja',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            IconButton(
              icon: Assets.icons.cancel.svg(
                colorFilter: ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
                height: 32,
                width: 32,
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      content: SizedBox(
        width: context.deviceWidth / 1.75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pesan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                _getDialogMessage(),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.2,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 24),
        
            // Opsi status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: _buildStatusOptions(),
              ),
            ),
            // const SizedBox(height: 32),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: Button.outlined(
                onPressed: () => Navigator.pop(context),
                label: 'Batal',
                height: 50,
                color: AppColors.greyLight,
                borderColor: AppColors.grey,
                textColor: AppColors.grey,
                borderRadius: 8.0,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Button.filled(
                onPressed: () {
                  if (selectedStatus != null) {
                    // Panggil callback dengan status yang dipilih
                    // Callback akan handle Navigator.pop dengan return value
                    widget.onStatusChanged(selectedStatus!);
                  }
                },
                label: 'Simpan',
                height: 50,
                color: AppColors.success,
                textColor: AppColors.white,
                borderRadius: 8.0,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
