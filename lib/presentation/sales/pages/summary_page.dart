import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Ringkasan'),
          const SpaceHeight(16),
          Row(
            children: [
              Expanded(child: _salesStatisticCard()),
              const SizedBox(width: 16),
              Expanded(child: _revenueDonutCard()),
            ],
          ),
          const SpaceHeight(16),
          _summarySection(),
        ],
      ),
    );
  }

  Widget _sectionContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _salesStatisticCard() {
    return _sectionContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryLightActive),
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 70,
                  child: Column(
                    children: const [
                      Text('Rp 320.000',
                          style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      CircleAvatar(
                          radius: 6, backgroundColor: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SpaceHeight(8),
          const Text('Statistik penjualan',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const Divider(color: AppColors.primaryLightActive),
          const SpaceHeight(8),
          const Text('29 Agustus 2025: Rp 320.000'),
        ],
      ),
    );
  }

  Widget _revenueDonutCard() {
    return _sectionContainer(
      Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF052649), width: 20),
                    ),
                  ),
                  // Inner cutout
                  Container(
                    height: 100,
                    width: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total Pendapatan',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Rp 320.000',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Pendapatan: Rp 320.000'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _summarySection() {
    return _sectionContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const Divider(color: AppColors.primaryLightActive),
          const SpaceHeight(8),
          _pair('Penjualan kotor', 'Rp 1.918.000', 'Penjualan bersih',
              'Rp 1.918.000'),
          const SpaceHeight(24),
          _pair('Laba kotor', 'Rp 1.918.000', 'Laba bersih', 'Rp 1.918.000'),
          const SpaceHeight(24),
          _pair('Total transaksi', 'Rp 1.918.000', 'Marjin laba kotor',
              'Rp 1.918.000'),
        ],
      ),
    );
  }

  Widget _pair(String l1, String v1, String l2, String v2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l1, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(v1),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l2, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(v2),
            ],
          ),
        ),
      ],
    );
  }
}
