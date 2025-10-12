import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';

class SalesRecapPage extends StatelessWidget {
  const SalesRecapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Rekap Penjualan'),
          const SpaceHeight(16),
          _section(
            title: 'Transaksi penjualan',
            child: Column(
              children: const [
                _TripleRow(left: 'Tunai', middle: '10x', right: 'Rp 120.000'),
                SpaceHeight(8),
                _TripleRow(left: 'QRIS', middle: '12x', right: 'Rp 138.000'),
                SpaceHeight(8),
                _TripleRow(
                    left: 'Kartu Debit', middle: '12x', right: 'Rp 138.000'),
                SpaceHeight(12),
                Divider(color: AppColors.primaryLightActive),
                SpaceHeight(8),
                _TotalRow(label: 'Total transaksi', amount: 'Rp 376.000'),
              ],
            ),
          ),
          _section(
            title: 'Penerimaan di kasir',
            child: Column(
              children: const [
                _TripleRow(left: 'Tunai', middle: '10x', right: 'Rp 120.000'),
                SpaceHeight(8),
                _TripleRow(
                    left: 'Non - Tunai', middle: '24x', right: 'Rp 276.000'),
                SpaceHeight(12),
                Divider(color: AppColors.primaryLightActive),
                SpaceHeight(8),
                _TotalRow(
                    label: 'Total perimaan di kasir', amount: 'Rp 376.000'),
              ],
            ),
          ),
          _section(
            title: 'Total',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _LabeledAmount(
                  label: 'Penerimaan sistem',
                  helper: '(Total kas + Total transaksi penjualan)',
                  amount: 'Rp 120.000',
                ),
                SpaceHeight(12),
                _LabeledAmount(
                  label: 'Selisih total',
                  helper: '(Total penerimaan di kasir - Penerimaan di sistem)',
                  amount: '-Rp 275.000',
                  amountColor: AppColors.danger,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SpaceHeight(12),
          child,
        ],
      ),
    );
  }
}

class _TripleRow extends StatelessWidget {
  final String left;
  final String middle;
  final String right;
  const _TripleRow(
      {required this.left, required this.middle, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(left, style: const TextStyle(color: Colors.black)),
        ),
        Expanded(
          flex: 1,
          child: Text(middle, textAlign: TextAlign.left),
        ),
        Expanded(
          flex: 2,
          child: Text(right, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String amount;
  const _TotalRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _LabeledAmount extends StatelessWidget {
  final String label;
  final String helper;
  final String amount;
  final Color amountColor;
  const _LabeledAmount({
    required this.label,
    required this.helper,
    required this.amount,
    this.amountColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text(
              '(Total kas + Total transaksi penjualan)',
              style: TextStyle(color: AppColors.grey),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(fontWeight: FontWeight.w700, color: amountColor),
        ),
      ],
    );
  }
}
