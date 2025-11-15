import 'dart:math' as math;
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
  int? _selectedDateIndex;

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

    // Reset selected index when loading new data
    setState(() {
      _selectedDateIndex = null;
    });

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
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                          child: _salesStatisticCard(data.dailyStatistics)),
                      const SizedBox(width: 16),
                      Expanded(child: _revenueDonutCard(data)),
                    ],
                  ),
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

    // Ensure selected index is valid (use 0 as default if invalid or null)
    final selectedIndex =
        (_selectedDateIndex != null && _selectedDateIndex! < dailyStats.length)
            ? _selectedDateIndex!
            : (dailyStats.isNotEmpty ? 0 : null);

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
                              children: dailyStats.asMap().entries.map((entry) {
                                final index = entry.key;
                                final stat = entry.value;
                                final percentage = maxValue > 0
                                    ? (stat.totalSales / maxValue)
                                    : 0.0;
                                // Reduce max height to 85 to leave space for text and spacing
                                final barHeight = 85 * percentage;
                                final isSelected = selectedIndex == index;

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedDateIndex = index;
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            height: barHeight.toDouble(),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                      .withOpacity(0.8)
                                                  : AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: isSelected
                                                  ? Border.all(
                                                      color: AppColors.primary,
                                                      width: 2,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            stat.date.split('-').last,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.grey,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
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
          if (dailyStats.isNotEmpty && selectedIndex != null)
            Text(
              '${dailyStats[selectedIndex].date}: ${(dailyStats[selectedIndex].totalSales as int).currencyFormatRp}',
            ),
        ],
      ),
    );
  }

  Widget _revenueDonutCard(dynamic data) {
    final totalRevenue = data.totalRevenue as int;
    final netProfit = data.netProfit as int;
    final cost = totalRevenue - netProfit;

    // Calculate percentages
    final profitPercentage =
        totalRevenue > 0 ? (netProfit / totalRevenue) : 0.0;
    final costPercentage = totalRevenue > 0 ? (cost / totalRevenue) : 0.0;

    return _sectionContainer(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Donut chart with two segments
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: CustomPaint(
                      painter: DonutChartPainter(
                        profitPercentage: profitPercentage,
                        costPercentage: costPercentage,
                        profitColor: const Color(
                            0xFF052649), // Dark blue (almost black/navy)
                        costColor:
                            const Color(0xFF0E549F), // Medium blue (vibrant)
                        strokeWidth: 20,
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
                  // Text in center
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

class DonutChartPainter extends CustomPainter {
  final double profitPercentage;
  final double costPercentage;
  final Color profitColor;
  final Color costColor;
  final double strokeWidth;

  DonutChartPainter({
    required this.profitPercentage,
    required this.costPercentage,
    required this.profitColor,
    required this.costColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Start from top (12 o'clock position)
    const startAngle = -math.pi / 2;

    // Draw profit segment (dark blue - larger segment)
    if (profitPercentage > 0) {
      final profitSweepAngle = 2 * math.pi * profitPercentage;
      final profitPaint = Paint()
        ..color = profitColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        startAngle,
        profitSweepAngle,
        false,
        profitPaint,
      );
    }

    // Draw cost segment (medium blue - smaller segment)
    if (costPercentage > 0) {
      final costStartAngle = startAngle + (2 * math.pi * profitPercentage);
      final costSweepAngle = 2 * math.pi * costPercentage;
      final costPaint = Paint()
        ..color = costColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        costStartAngle,
        costSweepAngle,
        false,
        costPaint,
      );
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return oldDelegate.profitPercentage != profitPercentage ||
        oldDelegate.costPercentage != costPercentage ||
        oldDelegate.profitColor != profitColor ||
        oldDelegate.costColor != costColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
