import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/widgets/offline_info_banner.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';
import 'package:xpress/presentation/sales/blocs/best_sellers/best_sellers_bloc.dart';
import 'package:xpress/presentation/sales/blocs/best_sellers/best_sellers_event.dart';
import 'package:xpress/presentation/sales/blocs/best_sellers/best_sellers_state.dart';

class TopSellingPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const TopSellingPage({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<TopSellingPage> createState() => _TopSellingPageState();
}

class _TopSellingPageState extends State<TopSellingPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(TopSellingPage oldWidget) {
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

    context.read<BestSellersBloc>().add(
          GetBestSellers(
            startDate: startDateStr,
            endDate: endDateStr,
            limit: 10,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BestSellersBloc, BestSellersState>(
      builder: (context, state) {
        if (state is BestSellersInitial) {
          return const Center(child: Text('Memuat data...'));
        } else if (state is BestSellersLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BestSellersError) {
          return BlocBuilder<OnlineCheckerBloc, OnlineCheckerState>(
            builder: (context, onlineState) {
              final isOnline = onlineState.maybeWhen(
                  online: () => true, orElse: () => false);
              if (!isOnline) {
                return const Center(
                  child: OfflineInfoBanner(
                    customMessage:
                        'Data produk terlaris tidak tersedia dalam mode offline. '
                        'Silahkan hubungkan kembali koneksi internet.',
                  ),
                );
              }
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
            },
          );
        } else if (state is BestSellersSuccess) {
          final data = state.data;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ContentTitle('Terlaris'),
                const SpaceHeight(16),
                _section(
                  title: 'Produk terlaris',
                  child: data.products.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Tidak ada data produk terlaris',
                              style: TextStyle(color: AppColors.grey),
                            ),
                          ),
                        )
                      : Column(
                          children: data.products.asMap().entries.map((entry) {
                            final index = entry.key;
                            final product = entry.value;
                            return Column(
                              children: [
                                if (index > 0) const SpaceHeight(16),
                                _ProductRow(
                                  rank: index + 1,
                                  name: product.productName,
                                  category: product.categoryName,
                                  price: product.totalRevenue.currencyFormatRp,
                                  sold: 'Terjual ${product.totalQuantitySold}x',
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                ),
                _section(
                  title: 'Kategori terlaris',
                  child: data.categories.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Tidak ada data kategori terlaris',
                              style: TextStyle(color: AppColors.grey),
                            ),
                          ),
                        )
                      : Column(
                          children:
                              data.categories.asMap().entries.map((entry) {
                            final index = entry.key;
                            final category = entry.value;
                            return Column(
                              children: [
                                if (index > 0) const SpaceHeight(24),
                                _ProductRow(
                                  rank: index + 1,
                                  name: category.categoryName,
                                  price: category.totalRevenue.currencyFormatRp,
                                  sold:
                                      'Terjual ${category.totalQuantitySold}x',
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('State tidak dikenali'));
      },
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
            color: Colors.black.withAlpha((0.06 * 255).round()),
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
  final int rank;
  final String name;
  final String? category;
  final String price;
  final String sold;

  const _ProductRow({
    required this.rank,
    required this.name,
    this.category,
    required this.price,
    required this.sold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rank badge
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                rank <= 3 ? AppColors.primary : AppColors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? AppColors.white : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (category != null) ...[
                const SizedBox(height: 4),
                Text(
                  category!,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                )),
            const SizedBox(height: 4),
            Text(sold,
                style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          ],
        ),
      ],
    );
  }
}
