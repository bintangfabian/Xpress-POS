import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';

class TransactionDetailPage extends StatelessWidget {
  final VoidCallback? onBack;
  const TransactionDetailPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 6, bottom: 6, right: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 92,
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          leading: IconButton(
            onPressed: () {
              if (onBack != null) {
                onBack!.call();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: Assets.icons.backArrow
                .svg(color: AppColors.white, height: 48, width: 48),
          ),
          title: const Text(
            'Detail Transaksi',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Centered amount and transaction id
              Center(
                child: Column(
                  children: const [
                    Text(
                      'Rp 158.000',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID Transaksi: XP123010304059501210121',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _rowSpaceBetween(
                  'Waktu dan Tanggal', '16:10:21 - 7 Oktober 2025'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Metode Pembayaran', 'Tunai'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Konsumen', 'Agus'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Status Pembayaran', 'Lunas'),
              const SizedBox(height: 16),
              // Refund button (outlined danger) using shared Button
              Button.outlined(
                onPressed: () {},
                height: 48,
                borderRadius: 8,
                color: AppColors.dangerLight,
                borderColor: AppColors.danger,
                textColor: AppColors.danger,
                icon: Assets.icons.refund
                    .svg(color: AppColors.danger, height: 20, width: 20),
                label: 'Refund',
              ),
              const SizedBox(height: 8),
              // Print receipt button (outlined primary) using shared Button
              Button.outlined(
                onPressed: () {},
                height: 48,
                borderRadius: 8,
                color: AppColors.primaryLight,
                borderColor: AppColors.primary,
                textColor: AppColors.primary,
                icon: Assets.icons.printer
                    .svg(color: AppColors.primary, height: 20, width: 20),
                label: 'Cetak Struk',
              ),
              const SizedBox(height: 32),
              const Text(
                'Daftar Produk',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  Row(
                    children: const [
                      Text('1x',
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                      SizedBox(width: 12),
                      Text('Rp 158.000',
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                  height: 2, width: double.infinity, color: AppColors.primary),
              const SizedBox(height: 10),
              _rowSpaceBetween('Total Transaksi', 'Rp 158.000', isBold: true),
              const SizedBox(height: 8),
              _rowSpaceBetween('Diskon', '-Rp 0'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Subtotal', 'Total Transaksi - Diskon'),
              const SizedBox(height: 10),
              Container(
                  height: 2, width: double.infinity, color: AppColors.primary),
              const SizedBox(height: 10),
              _rowSpaceBetween('Total Belanja', 'Rp 158.000', isBold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowSpaceBetween(String left, String right, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          right,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
