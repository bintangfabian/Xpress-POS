import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/auth_remote_datasource.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/logic/bloc/sync/sync_bloc.dart';
import 'package:xpress/presentation/auth/pages/login_page.dart';
import 'package:xpress/presentation/home/pages/confirm_payment_page.dart';
import 'package:xpress/presentation/home/pages/home_page.dart';
import 'package:xpress/presentation/report/pages/report_page.dart';
import 'package:xpress/presentation/report/pages/transaction_detail_page.dart';
import 'package:xpress/presentation/sales/pages/sales_page.dart';
import 'package:xpress/presentation/setting/bloc/sync_order/sync_order_bloc.dart';
import 'package:xpress/presentation/setting/pages/settings_page.dart';
import 'package:xpress/presentation/table/pages/table_page.dart';

import '../../../core/assets/assets.gen.dart';
import '../bloc/online_checker/online_checker_bloc.dart';
import '../widgets/nav_item.dart';

class DashboardPage extends StatefulWidget {
  final int initialIndex; // ✅ Tambahan
  final TableModel? selectedTable; // ✅ Tambahan

  const DashboardPage({
    super.key,
    this.initialIndex = 0, // default HomePage
    this.selectedTable,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int _selectedIndex; // ✅ diubah jadi late
  late int _contentIndex; // ✅ index konten yang ditampilkan
  TableModel? _selectedTable; // ✅ simpan table yg dipilih
  String? _selectedOrderId; // ✅ simpan order id yang dipilih
  String _orderType = 'dinein';
  String _orderNumber = '#0001'; // ✅ simpan order number

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _contentIndex = widget.initialIndex; // konten awal mengikuti initialIndex
    _selectedTable = widget.selectedTable;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        isTable: _selectedTable != null,
        table: _selectedTable,
        onGoToPayment: (orderType, orderNumber) {
          setState(() {
            _orderType = orderType;
            _orderNumber = orderNumber;
            _contentIndex = 5; // tampilkan halaman konfirmasi
            _selectedIndex = 0; // navbar tetap aktif di Home
          });
        },
      ),
      const TablePage(),
      ReportPage(
        onOpenDetail: (String orderId) {
          setState(() {
            _selectedOrderId = orderId; // simpan order id
            _contentIndex = 6; // tampilkan halaman detail transaksi
            _selectedIndex = 2; // navbar tetap aktif di Report
          });
        },
      ),
      const SettingsPage(),
      const SalesPage(),
      // Index 5 = ConfirmPaymentPage
      ConfirmPaymentPage(
        isTable: _selectedTable != null,
        table: _selectedTable,
        orderType: _orderType,
        orderNumber: _orderNumber,
      ),
      // Index 6 = TransactionDetailPage
      TransactionDetailPage(
        orderId: _selectedOrderId,
        onBack: () {
          setState(() {
            _contentIndex = 2; // kembali ke ReportPage content
            _selectedIndex = 2; // navbar tetap di Report
          });
        },
      ),
    ];

    return MultiBlocListener(
      listeners: [
        BlocListener<SyncBloc, SyncState>(
          listener: (context, state) {
            state.whenOrNull(
              success: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sinkronisasi berhasil'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              failure: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.danger,
                  ),
                );
              },
            );
          },
        ),
        BlocListener<OnlineCheckerBloc, OnlineCheckerState>(
          listenWhen: (previous, current) {
            final wasOnline =
                previous.maybeWhen(online: () => true, orElse: () => false);
            final isOnline =
                current.maybeWhen(online: () => true, orElse: () => false);
            return wasOnline != isOnline && isOnline;
          },
          listener: (context, state) {
            _validateSessionOnReconnect();
          },
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.primaryLight,
          body: Row(
            children: [
              // ✅ Sidebar
              Container(
                width: 73,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Online checker
                    BlocBuilder<OnlineCheckerBloc, OnlineCheckerState>(
                      builder: (context, state) {
                        return state.maybeWhen(
                          orElse: () => _statusBox(false),
                          online: () {
                            context.read<SyncOrderBloc>().add(
                                  const SyncOrderEvent.syncOrder(),
                                );
                            return _statusBox(true);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // ✅ Nav Items
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          NavItem(
                            iconPath: Assets.icons.home.path,
                            isActive: _selectedIndex == 0,
                            onTap: () => setState(() {
                              _selectedIndex = 0;
                              _contentIndex = 0;
                            }),
                          ),
                          NavItem(
                            iconPath: Assets.icons.table.path,
                            isActive: _selectedIndex == 1,
                            onTap: () => setState(() {
                              _selectedIndex = 1;
                              _contentIndex = 1;
                            }),
                          ),
                          NavItem(
                            iconPath: Assets.icons.order.path,
                            isActive: _selectedIndex == 2,
                            onTap: () => setState(() {
                              _selectedIndex = 2;
                              _contentIndex = 2;
                            }),
                          ),
                          NavItem(
                            iconPath: Assets.icons.settings.path,
                            isActive: _selectedIndex == 3,
                            onTap: () => setState(() {
                              _selectedIndex = 3;
                              _contentIndex = 3;
                            }),
                          ),
                          NavItem(
                            iconPath: Assets.icons.graph.path,
                            isActive: _selectedIndex == 4,
                            onTap: () => setState(() {
                              _selectedIndex = 4;
                              _contentIndex = 4;
                            }),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Waktu
                    StreamBuilder<DateTime>(
                      stream: Stream.periodic(const Duration(seconds: 1),
                          (_) => TimezoneHelper.now()),
                      builder: (context, snapshot) {
                        final now = snapshot.data ?? TimezoneHelper.now();
                        return Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 57,
                              height: 31,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                DateFormat('HH:mm:ss').format(now),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              alignment: Alignment.center,
                              width: 57,
                              height: 61,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(DateFormat('dd').format(now),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary)),
                                  Text(DateFormat('MMM').format(now),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary)),
                                  Text(DateFormat('yyyy').format(now),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // ✅ Content
              Expanded(child: pages[_contentIndex]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _validateSessionOnReconnect() async {
    final authLocal = AuthLocalDataSource();
    final loginMode = await authLocal.getLoginMode();
    if (loginMode != 'offline') return;

    final token = await authLocal.getToken();
    if (token == null || token.isEmpty) return;

    final result = await AuthRemoteDatasource().fetchProfile(token);
    if (!mounted) return;
    await result.fold(
      (error) async {
        await authLocal.removeAuthData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.danger,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      },
      (user) async {
        await authLocal.updateCachedUser(user);
        await authLocal.setLoginMode('online');
      },
    );
  }

  Widget _statusBox(bool online) {
    return Container(
      height: 55,
      width: 57,
      decoration: BoxDecoration(
        color: online ? AppColors.success : AppColors.danger,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          online
              ? Assets.icons.signalON.svg(
                  height: 24,
                  width: 24,
                  colorFilter:
                      ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                )
              : Assets.icons.signalOff.svg(
                  height: 24,
                  width: 24,
                  colorFilter:
                      ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                ),
          Text(
            online ? "Online" : "Offline",
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
