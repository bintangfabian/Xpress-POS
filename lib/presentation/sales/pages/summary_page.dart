import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/presentation/sales/blocs/sales_summary/sales_summary_bloc.dart';
import 'package:xpress/presentation/sales/blocs/sales_summary/sales_summary_event.dart';
import 'package:xpress/presentation/sales/blocs/sales_summary/sales_summary_state.dart';

class SummaryPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const SummaryPage({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(SummaryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _loadData();
    }
  }

  void _loadData() {
    final startDateStr =
        '${widget.startDate.year}-${widget.startDate.month.toString().padLeft(2, '0')}-${widget.startDate.day.toString().padLeft(2, '0')}';
    final endDateStr =
        '${widget.endDate.year}-${widget.endDate.month.toString().padLeft(2, '0')}-${widget.endDate.day.toString().padLeft(2, '0')}';

    context.read<SalesSummaryBloc>().add(
          GetSalesSummary(
            startDate: startDateStr,
            endDate: endDateStr,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesSummaryBloc, SalesSummaryState>(
      builder: (context, state) {
        if (state is SalesSummaryInitial) {
          return const Center(child: Text('Memuat data...'));
        } else if (state is SalesSummaryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SalesSummaryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.danger),
                const SpaceHeight(16),
                Text(state.message),
              ],
            ),
          );
        } else if (state is SalesSummarySuccess) {
          final data = state.data;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ContentTitle('Ringkasan'),
                const SpaceHeight(16),
                Row(
                  children: [
                    Expanded(child: _salesStatisticCard(data.dailyStatistics)),
                    const SizedBox(width: 16),
                    Expanded(child: _revenueDonutCard(data)),
                  ],
                ),
                const SpaceHeight(16),
                _summarySection(data),
              ],
            ),
          );
        }
        return const Center(child: Text('State tidak dikenali'));
      },
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

  Widget _salesStatisticCard(List dailyStats) {
    // Find max value for scaling
    int maxValue = 0;
    if (dailyStats.isNotEmpty) {
      maxValue = dailyStats
          .map((stat) => stat.totalSales as int)
          .reduce((a, b) => a > b ? a : b);
    }

    return _sectionContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: dailyStats.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada data',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  )
                : Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppColors.primaryLightActive),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: dailyStats.map((stat) {
                                final percentage = maxValue > 0
                                    ? (stat.totalSales / maxValue)
                                    : 0.0;
                                final barHeight = 100 * percentage;

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: barHeight.toDouble(),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          stat.date.split('-').last,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
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
          if (dailyStats.isNotEmpty)
            Text(
              '${dailyStats.first.date}: ${(dailyStats.first.totalSales as int).currencyFormatRp}',
            ),
        ],
      ),
    );
  }

  Widget _revenueDonutCard(dynamic data) {
    final totalRevenue = data.totalRevenue as int;
    final netProfit = data.netProfit as int;
    final percentage = totalRevenue > 0 ? (netProfit / totalRevenue) : 0.0;

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
                  // Background ring (light)
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFB3D4E5),
                        width: 20,
                      ),
                    ),
                  ),
                  // Foreground ring (dark) - represents percentage
                  if (percentage > 0)
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: CircularProgressIndicator(
                        value: percentage.toDouble(),
                        strokeWidth: 20,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF052649),
                        ),
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Pendapatan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          )),
                      const SizedBox(height: 4),
                      Text(totalRevenue.currencyFormatRp,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF052649),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Profit',
                      style: TextStyle(fontSize: 12, color: AppColors.grey)),
                ],
              ),
              Text(netProfit.currencyFormatRp,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _summarySection(dynamic data) {
    return _sectionContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const Divider(color: AppColors.primaryLightActive),
          const SpaceHeight(8),
          _pair(
            'Penjualan kotor',
            (data.grossSales as int).currencyFormatRp,
            'Penjualan bersih',
            (data.netSales as int).currencyFormatRp,
          ),
          const SpaceHeight(24),
          _pair(
            'Laba kotor',
            (data.grossProfit as int).currencyFormatRp,
            'Laba bersih',
            (data.netProfit as int).currencyFormatRp,
          ),
          const SpaceHeight(24),
          _pair(
            'Total transaksi',
            '${data.totalTransactions}',
            'Marjin laba kotor',
            '${(data.grossProfitMargin as double).toStringAsFixed(2)}%',
          ),
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
