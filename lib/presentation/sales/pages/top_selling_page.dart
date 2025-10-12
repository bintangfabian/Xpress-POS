import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';

class TopSellingPage extends StatelessWidget {
  const TopSellingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Terlaris'),
          const SpaceHeight(16),
          _section(
            title: 'Produk terlaris',
            child: Column(
              children: const [
                _ProductRow(
                    name: 'Ayam Goreng Dada',
                    price: 'Rp 120.000',
                    sold: 'Terjual 12x'),
                SpaceHeight(16),
                _ProductRow(
                    name: 'Ayam Goreng Dada',
                    price: 'Rp 120.000',
                    sold: 'Terjual 12x'),
                SpaceHeight(16),
                _ProductRow(
                    name: 'Ayam Goreng Dada',
                    price: 'Rp 120.000',
                    sold: 'Terjual 12x'),
                SpaceHeight(16),
                _ProductRow(
                    name: 'Ayam Goreng Dada',
                    price: 'Rp 120.000',
                    sold: 'Terjual 12x'),
              ],
            ),
          ),
          _section(
            title: 'Kategori terlaris',
            child: Column(
              children: const [
                _ProductRow(
                    name: 'Makanan', price: 'Rp 120.000', sold: 'Terjual 12x'),
                SpaceHeight(24),
                _ProductRow(
                    name: 'Minuman', price: 'Rp 120.000', sold: 'Terjual 12x'),
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
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SpaceHeight(8),
          const Divider(color: AppColors.primaryLightActive),
          const SpaceHeight(8),
          child,
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String name;
  final String price;
  final String sold;
  const _ProductRow(
      {required this.name, required this.price, required this.sold});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: Text(name,
              style: const TextStyle(fontSize: 16, color: Colors.black)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price,
                style: const TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(height: 4),
            Text(sold,
                style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          ],
        ),
      ],
    );
  }
}
