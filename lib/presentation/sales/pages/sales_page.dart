import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/date_time_ext.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/datasources/sales_remote_datasource.dart';
import 'package:xpress/presentation/sales/blocs/day_sales/day_sales_bloc.dart';
import 'package:xpress/presentation/sales/blocs/cash_session/cash_session_bloc.dart';
import 'package:xpress/presentation/sales/blocs/sales_recap/sales_recap_bloc.dart';
import 'package:xpress/presentation/sales/blocs/best_sellers/best_sellers_bloc.dart';
import 'package:xpress/presentation/sales/blocs/sales_summary/sales_summary_bloc.dart';
import 'package:xpress/presentation/sales/pages/sales_recap_page.dart';
import 'package:xpress/presentation/sales/pages/top_selling_page.dart';
import 'package:xpress/presentation/sales/pages/cash_daily_page.dart';
import 'package:xpress/presentation/sales/pages/inventory_page.dart';
import 'package:xpress/presentation/sales/pages/summary_page.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  int currentIndex = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    context
        .read<DaySalesBloc>()
        .add(DaySalesEvent.getDaySales(TimezoneHelper.now()));
    super.initState();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showCustomDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      // Trigger data refresh for all sections
      _refreshData();
    }
  }

  void _refreshData() {
    // This will be called when date range changes
    // Child pages will listen to this and refresh their data
    setState(() {});
  }

  String _getDateRangeText() {
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return startDate.toFormattedDateShort();
    }
    return '${startDate.toFormattedDateShort()} - ${endDate.toFormattedDateShort()}';
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _getDateRangeText();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CashSessionBloc(SalesRemoteDataSource()),
        ),
        BlocProvider(
          create: (context) => SalesRecapBloc(SalesRemoteDataSource()),
        ),
        BlocProvider(
          create: (context) => BestSellersBloc(SalesRemoteDataSource()),
        ),
        BlocProvider(
          create: (context) => SalesSummaryBloc(SalesRemoteDataSource()),
        ),
      ],
      child: Row(
        children: [
          // Left menu
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Fixed date header (outside scroll)
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: InkWell(
                      onTap: _selectDateRange,
                      child: Container(
                        height: 67,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                dateText,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Assets.icons.calender.svg(
                              height: 32,
                              width: 32,
                              colorFilter: const ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),
                  // Scrollable menu list
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const PageTitle(title: 'Laporan'),
                          const SizedBox(height: 16),
                          MenuTile(
                            icon: Assets.icons.tunai,
                            title: 'Kas Harian',
                            subtitle: 'Rekap Kas Harian',
                            active: currentIndex == 0,
                            onTap: () => setState(() => currentIndex = 0),
                          ),
                          MenuTile(
                            icon: Assets.icons.cash,
                            title: 'Rekap Penjualan',
                            subtitle: 'Monitoring Uang Penjualan',
                            active: currentIndex == 1,
                            onTap: () => setState(() => currentIndex = 1),
                          ),
                          MenuTile(
                            icon: Assets.icons.cart,
                            title: 'Terlaris',
                            subtitle: 'Ringkasan Produk Terlaris',
                            active: currentIndex == 2,
                            onTap: () => setState(() => currentIndex = 2),
                          ),
                          MenuTile(
                            icon: Assets.icons.task,
                            title: 'Ringkasan',
                            subtitle: 'Kelola Pendapatan',
                            active: currentIndex == 3,
                            onTap: () => setState(() => currentIndex = 3),
                          ),
                          MenuTile(
                            icon: Assets.icons.stock,
                            title: 'Inventori',
                            subtitle: 'Informasi Barang & Stock',
                            active: currentIndex == 4,
                            onTap: () => setState(() => currentIndex = 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Right content
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.only(right: 6, bottom: 6, top: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IndexedStack(
                index: currentIndex,
                children: [
                  CashDailyPage(startDate: startDate, endDate: endDate),
                  SalesRecapPage(startDate: startDate, endDate: endDate),
                  TopSellingPage(startDate: startDate, endDate: endDate),
                  SummaryPage(startDate: startDate, endDate: endDate),
                  const InventoryPage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
