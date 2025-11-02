import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/data/models/response/order_response_model.dart'
    hide Product;
import 'package:xpress/logic/bloc/sync/sync_bloc.dart';
import 'package:xpress/presentation/home/bloc/local_product/local_product_bloc.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';
import 'package:xpress/presentation/home/widgets/custom_button.dart';
import 'package:xpress/presentation/home/widgets/custom_tab_bar.dart';
import 'package:xpress/presentation/home/widgets/order_menu.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/components/components.dart';
import '../../../core/constants/colors.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../widgets/product_card.dart';
import 'package:xpress/presentation/home/dialogs/variant_dialog.dart';
import 'package:xpress/presentation/setting/bloc/get_categories/get_categories_bloc.dart';
import 'package:xpress/presentation/setting/bloc/sync_product/sync_product_bloc.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/presentation/home/dialogs/open_bill_list_dialog.dart';
import 'package:xpress/presentation/home/dialogs/clear_order_dialog.dart';
import 'package:xpress/presentation/home/widgets/sort_dropdown.dart';
import 'package:xpress/presentation/home/models/product_variant.dart';
import 'package:xpress/presentation/home/pages/confirm_payment_page.dart';
import 'package:xpress/presentation/home/pages/dashboard_page.dart';
import 'package:xpress/presentation/widgets/offline_banner.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

class HomePage extends StatefulWidget {
  final bool isTable;
  final TableModel? table;
  final void Function(String orderType, String orderNumber)? onGoToPayment;

  const HomePage({
    super.key,
    required this.isTable,
    this.table,
    this.onGoToPayment,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  String? _orderType; // dinein / takeaway
  final Map<int, List<ProductVariant>> _selectedVariants = {};
  String _orderNumber = '#0001';
  String _searchQuery = '';
  SortOption? _sortOption;

  // Open Bill tracking
  bool _isEditingOpenBill = false;
  String? _editingOpenBillId;
  TableModel? _editingOpenBillTable;

  void _logHome(String message) {
    assert(() {
      developer.log(message, name: 'HomePage');
      return true;
    }());
  }

  @override
  void initState() {
    // Force delete and re-sync products to ensure trackInventory is loaded
    _forceResyncProducts();

    context.read<GetCategoriesBloc>().add(const GetCategoriesEvent.fetch());
    _loadNextOrderNumber();
    super.initState();
  }

  Future<void> _forceResyncProducts() async {
    _logHome('========================================');
    _logHome('FORCE RESYNC: Deleting all products...');

    // Clear local products
    await ProductLocalDatasource.instance.deleteAllProducts();

    _logHome('FORCE RESYNC: Products deleted, starting sync...');

    if (!mounted) return;

    // Sync from server
    context.read<SyncProductBloc>().add(const SyncProductEvent.syncProduct());

    // Load local products
    context
        .read<LocalProductBloc>()
        .add(const LocalProductEvent.getLocalProduct());

    _logHome('FORCE RESYNC: Complete');
    _logHome('========================================');
  }

  Future<void> _loadNextOrderNumber() async {
    try {
      final next = await OrderRemoteDatasource().getNextOrderNumber();
      if (!mounted) return;
      setState(() => _orderNumber = next);
    } catch (_) {}
  }

  Future<void> _createOpenBillOrder(String orderType) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final state = context.read<CheckoutBloc>().state;

      await state.maybeWhen(
        loaded: (
          products,
          discountModel,
          discount,
          discountAmount,
          tax,
          serviceCharge,
          totalQuantity,
          totalPrice,
          draftName,
          ordType,
        ) async {
          // Calculate amounts
          final subtotal = products.map((e) {
            final basePrice = e.product.price?.toIntegerFromText ?? 0;
            final variantPrice =
                e.variants?.fold<int>(0, (sum, v) => sum + v.priceAdjustment) ??
                    0;
            return (basePrice + variantPrice) * e.quantity;
          }).fold(0, (a, b) => a + b);

          final discAmt = discountAmount;
          final taxAmt = (subtotal * (tax / 100)).round();
          final serviceAmt = (subtotal * (serviceCharge / 100)).round();
          final totalAmt = subtotal - discAmt + taxAmt + serviceAmt;

          // Build items
          final items = products.map((e) {
            final basePrice = e.product.price?.toIntegerFromText ?? 0;
            final variantPrice =
                e.variants?.fold<int>(0, (sum, v) => sum + v.priceAdjustment) ??
                    0;
            final unitPrice = basePrice + variantPrice;
            final totalPrice = unitPrice * e.quantity;

            return {
              'product_id': e.product.id,
              'product_name': e.product.name,
              'quantity': e.quantity,
              'unit_price': unitPrice,
              'total_price': totalPrice,
            };
          }).toList();

          // Build order data
          final orderData = <String, dynamic>{
            'order_number': _orderNumber,
            'order_type': orderType,
            'subtotal': subtotal,
            'total_amount': totalAmt,
            'items': items,
          };

          // Add table_id if exists
          if (widget.table?.id != null && widget.table!.id!.isNotEmpty) {
            orderData['table_id'] = widget.table!.id;
          }

          // Add financial details
          if (discAmt > 0) orderData['discount_amount'] = discAmt.toDouble();
          if (serviceAmt > 0) {
            orderData['service_charge'] = serviceAmt.toDouble();
          }
          if (taxAmt > 0) orderData['tax'] = taxAmt.toDouble();

          // Create open bill order
          final result = await OrderRemoteDatasource().createOpenBillOrder(
            orderData: orderData,
            totalAmount: totalAmt,
          );

          if (!mounted) return;

          // Close loading dialog
          Navigator.of(context).pop();

          result.fold(
            (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal membuat Open Bill: $error'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            (orderId) {
              // Success - clear cart and show success message
              context
                  .read<CheckoutBloc>()
                  .add(const CheckoutEvent.clearOrder());

              // Navigate back to dashboard page (home)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardPage(
                    initialIndex: 0, // HomePage
                  ),
                ),
                (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Open Bill berhasil dibuat!'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          );
        },
        orElse: () async {
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        // Close loading if still showing
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // Load open bill to checkout (Lanjutkan)
  Future<void> _loadOpenBillToCheckout(ItemOrder order) async {
    // Set editing state
    setState(() {
      _isEditingOpenBill = true;
      _editingOpenBillId = order.id;
      _orderNumber = order.orderNumber ?? _orderNumber;

      // Set order type
      if (order.operationMode != null) {
        _orderType = order.operationMode == 'dine_in'
            ? 'dinein'
            : order.operationMode == 'takeaway'
                ? 'takeaway'
                : null;
      }

      // Set table if exists
      if (order.table != null) {
        final now = TimezoneHelper.now();
        _editingOpenBillTable = TableModel(
          id: order.table!.id,
          tableNumber: order.table!.tableNumber,
          name: order.table!.name,
          startTime:
              order.createdAt?.toIso8601String() ?? now.toIso8601String(),
          status: 'occupied',
          orderId: 0,
          paymentAmount: int.tryParse(order.totalAmount ?? '0') ?? 0,
        );
      }
    });

    // Clear existing checkout first
    context.read<CheckoutBloc>().add(const CheckoutEvent.clearOrder());

    // Load items to checkout
    if (order.items != null) {
      for (var item in order.items!) {
        if (item.productId != null) {
          // Fetch the product from local DB to get proper Product model
          final result = await ProductLocalDatasource.instance
              .getProductById(item.productId!);
          if (result != null) {
            // Add to checkout with quantity
            for (int i = 0; i < (item.quantity ?? 1); i++) {
              if (mounted) {
                context.read<CheckoutBloc>().add(
                      CheckoutEvent.addItem(result),
                    );
              }
            }
          }
        }
      }
    }

    // Set order type in bloc if available
    if (_orderType != null && mounted) {
      context.read<CheckoutBloc>().add(
            CheckoutEvent.setOrderType(_orderType!),
          );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Open Bill berhasil dimuat. Silakan lanjutkan pesanan.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Update open bill order (Simpan)
  Future<void> _updateOpenBillOrder(String orderType) async {
    if (!_isEditingOpenBill || _editingOpenBillId == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final state = context.read<CheckoutBloc>().state;

      await state.maybeWhen(
        loaded: (
          products,
          discountModel,
          discount,
          discountAmount,
          tax,
          serviceCharge,
          totalQuantity,
          totalPrice,
          draftName,
          ordType,
        ) async {
          // Calculate amounts
          final subtotal = products.map((e) {
            final basePrice = e.product.price?.toIntegerFromText ?? 0;
            final variantPrice =
                e.variants?.fold<int>(0, (sum, v) => sum + v.priceAdjustment) ??
                    0;
            return (basePrice + variantPrice) * e.quantity;
          }).fold(0, (a, b) => a + b);

          final discAmt = discountAmount;
          final taxAmt = (subtotal * (tax / 100)).round();
          final serviceAmt = (subtotal * (serviceCharge / 100)).round();
          final totalAmt = subtotal - discAmt + taxAmt + serviceAmt;

          // Build items
          final items = products.map((e) {
            final basePrice = e.product.price?.toIntegerFromText ?? 0;
            final variantPrice =
                e.variants?.fold<int>(0, (sum, v) => sum + v.priceAdjustment) ??
                    0;
            final unitPrice = basePrice + variantPrice;
            final totalPrice = unitPrice * e.quantity;

            return {
              'product_id': e.product.id,
              'product_name': e.product.name,
              'quantity': e.quantity,
              'unit_price': unitPrice,
              'total_price': totalPrice,
            };
          }).toList();

          // Build order data for update
          final orderData = <String, dynamic>{
            'order_number': _orderNumber,
            'order_type': orderType,
            'subtotal': subtotal,
            'total_amount': totalAmt,
            'items': items,
          };

          // Add table_id if exists
          if (_editingOpenBillTable?.id != null &&
              _editingOpenBillTable!.id!.isNotEmpty) {
            orderData['table_id'] = _editingOpenBillTable!.id;
          }

          // Add financial details
          if (discAmt > 0) orderData['discount_amount'] = discAmt.toDouble();
          if (serviceAmt > 0) {
            orderData['service_charge'] = serviceAmt.toDouble();
          }
          if (taxAmt > 0) orderData['tax'] = taxAmt.toDouble();

          // Update open bill order
          final result = await OrderRemoteDatasource().updateOpenBillOrder(
            orderId: _editingOpenBillId!,
            orderData: orderData,
          );

          if (!mounted) return;

          // Close loading dialog
          Navigator.of(context).pop();

          result.fold(
            (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal mengupdate Open Bill: $error'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Open Bill berhasil diupdate!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          );
        },
        orElse: () async {
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        // Close loading if still showing
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // Cancel open bill order (Batalkan)
  Future<void> _cancelOpenBillOrder() async {
    if (!_isEditingOpenBill || _editingOpenBillId == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Cancel open bill order
      final result = await OrderRemoteDatasource().cancelOpenBillOrder(
        orderId: _editingOpenBillId!,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membatalkan Open Bill: $error'),
              backgroundColor: AppColors.danger,
            ),
          );
        },
        (success) {
          // Clear checkout
          context.read<CheckoutBloc>().add(const CheckoutEvent.clearOrder());

          // Reset editing state
          setState(() {
            _isEditingOpenBill = false;
            _editingOpenBillId = null;
            _editingOpenBillTable = null;
          });

          // Navigate back to dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardPage(
                initialIndex: 0, // HomePage
              ),
            ),
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Open Bill berhasil dibatalkan!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        // Close loading if still showing
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // Navigate to payment page (Bayar)
  Future<void> _navigateToPaymentFromOpenBill(ItemOrder order) async {
    // Determine order type
    final orderType = order.operationMode == 'dine_in'
        ? 'dinein'
        : order.operationMode == 'takeaway'
            ? 'takeaway'
            : 'dinein'; // default

    // Convert Table from order to TableModel
    TableModel? tableModel;
    if (order.table != null) {
      final now = TimezoneHelper.now();
      tableModel = TableModel(
        id: order.table!.id,
        tableNumber: order.table!.tableNumber,
        name: order.table!.name,
        startTime: order.createdAt?.toIso8601String() ?? now.toIso8601String(),
        status: 'occupied',
        orderId: 0, // Will be updated after payment
        paymentAmount: int.tryParse(order.totalAmount ?? '0') ?? 0,
      );
    }

    // Clear existing checkout first
    context.read<CheckoutBloc>().add(const CheckoutEvent.clearOrder());

    // Convert OrderItem to Product for checkout
    if (order.items != null) {
      for (var item in order.items!) {
        if (item.productId != null) {
          // Fetch the product from local DB
          final result = await ProductLocalDatasource.instance
              .getProductById(item.productId!);
          if (result != null) {
            // Add to checkout with quantity
            for (int i = 0; i < (item.quantity ?? 1); i++) {
              if (mounted) {
                context.read<CheckoutBloc>().add(
                      CheckoutEvent.addItem(result),
                    );
              }
            }
          }
        }
      }
    }

    // Navigate to payment page
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmPaymentPage(
            isTable: orderType == 'dinein',
            table: tableModel,
            orderType: orderType,
            orderNumber: order.orderNumber ?? '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SyncProductBloc, SyncProductState>(
      listener: (context, state) async {
        state.maybeWhen(
          orElse: () {},
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          },
          loaded: (productResponseModel) async {
            // Replace local products with server data then refresh LocalProductBloc
            await ProductLocalDatasource.instance.deleteAllProducts();
            await ProductLocalDatasource.instance
                .insertProducts(productResponseModel.data!);
            if (!context.mounted) return;
            context
                .read<LocalProductBloc>()
                .add(const LocalProductEvent.getLocalProduct());
          },
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.only(top: 6.0, right: 6.0),
          child: Column(
            children: [
              BlocBuilder<OnlineCheckerBloc, OnlineCheckerState>(
                builder: (context, state) {
                  final isOffline = state.maybeWhen(
                    offline: () => true,
                    orElse: () => false,
                  );
                  if (!isOffline) {
                    return const SizedBox.shrink();
                  }
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: OfflineBanner(),
                  );
                },
              ),
              BlocBuilder<SyncBloc, SyncState>(
                builder: (context, state) {
                  final isSyncing = state.maybeWhen(
                    inProgress: () => true,
                    orElse: () => false,
                  );
                  if (!isSyncing) {
                    return const SizedBox.shrink();
                  }
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: LinearProgressIndicator(),
                  );
                },
              ),
              Expanded(
                child: Row(
                  children: [
                    // ✅ Kiri: Daftar Menu
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding:
                            const EdgeInsets.only(left: 16, top: 12, right: 16),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          color: AppColors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header + search
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daftar Menu',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 328,
                                  height: 48,
                                  child: SearchInput(
                                    controller: searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value.toLowerCase();
                                      });
                                    },
                                    hintText: 'Search Menu',
                                  ),
                                ),
                                SortDropdown(
                                  selectedOption: _sortOption,
                                  onChanged: (option) {
                                    setState(() {
                                      _sortOption = option;
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SpaceHeight(16),

                            // Tab kategori
                            Expanded(
                              child: BlocBuilder<GetCategoriesBloc,
                                  GetCategoriesState>(
                                builder: (context, state) {
                                  return state.maybeWhen(
                                    success: (cats) {
                                      final titles = [
                                        'Semua',
                                        ...cats.map((e) => e.name ?? '-')
                                      ];
                                      final views = [
                                        _buildProductGrid(),
                                        ...cats.map((e) => _buildProductGrid(
                                            filterCategoryId: e.id)),
                                      ];
                                      return CustomTabBar(
                                        tabTitles: titles,
                                        initialTabIndex: 0,
                                        tabViews: views,
                                      );
                                    },
                                    orElse: () => CustomTabBar(
                                      tabTitles: const ['Semua'],
                                      initialTabIndex: 0,
                                      tabViews: [
                                        _buildProductGrid(),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // ✅ Kanan: Pesanan
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Row(
                                children: [
                                  const Text(
                                    "Pesanan",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    height: 37,
                                    width: 72,
                                    decoration: BoxDecoration(
                                      color: AppColors.greyLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(_orderNumber,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  if (widget.isTable &&
                                      widget.table != null) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      height: 37,
                                      width: 72,
                                      decoration: BoxDecoration(
                                        color: AppColors.successLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          widget.table!.name ??
                                              "Meja ${widget.table!.tableNumber ?? ''}",
                                          style: const TextStyle(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),

                                  // 🔹 Open Bill di header hanya kalau kosong - Menampilkan List Open Bill
                                  BlocBuilder<CheckoutBloc, CheckoutState>(
                                    builder: (context, state) {
                                      return state.maybeWhen(
                                        orElse: () => const SizedBox(),
                                        loaded: (
                                          products,
                                          _,
                                          __,
                                          ___,
                                          ____,
                                          _____,
                                          ______,
                                          _______,
                                          ________,
                                          _________,
                                        ) {
                                          if (products.isEmpty) {
                                            return CustomButton(
                                              height: 52,
                                              label: "Open Bill",
                                              svgIcon: Assets.icons.bill,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      OpenBillListDialog(
                                                    onContinue:
                                                        _loadOpenBillToCheckout,
                                                    onPay:
                                                        _navigateToPaymentFromOpenBill,
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // 🔹 Pilihan Dine In / Take Away
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: BlocBuilder<CheckoutBloc, CheckoutState>(
                                builder: (context, state) {
                                  final selectedType = state.maybeWhen(
                                    loaded: (products,
                                        discountModel,
                                        discount,
                                        discountAmount,
                                        tax,
                                        serviceCharge,
                                        totalQuantity,
                                        totalPrice,
                                        draftName,
                                        orderType) {
                                      return orderType;
                                    },
                                    orElse: () => null,
                                  );

                                  return Row(
                                    children: [
                                      Expanded(
                                        child: selectedType == "dinein"
                                            ? Button.filled(
                                                label: "Dine In",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                onPressed: () {
                                                  context
                                                      .read<CheckoutBloc>()
                                                      .add(const CheckoutEvent
                                                          .setOrderType(
                                                          "dinein"));
                                                },
                                              )
                                            : Button.outlined(
                                                label: "Dine In",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                onPressed: () {
                                                  context
                                                      .read<CheckoutBloc>()
                                                      .add(const CheckoutEvent
                                                          .setOrderType(
                                                          "dinein"));
                                                },
                                              ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: selectedType == "takeaway"
                                            ? Button.filled(
                                                label: "Take Away",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                onPressed: () {
                                                  context
                                                      .read<CheckoutBloc>()
                                                      .add(const CheckoutEvent
                                                          .setOrderType(
                                                          "takeaway"));
                                                },
                                              )
                                            : Button.outlined(
                                                label: "Take Away",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                onPressed: () {
                                                  context
                                                      .read<CheckoutBloc>()
                                                      .add(const CheckoutEvent
                                                          .setOrderType(
                                                          "takeaway"));
                                                },
                                              ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            const SpaceHeight(20),

                            // Area pesanan
                            Expanded(
                              child: BlocBuilder<CheckoutBloc, CheckoutState>(
                                builder: (context, state) {
                                  return state.maybeWhen(
                                    orElse: () => _emptyOrder(),
                                    loaded: (
                                      products,
                                      _,
                                      __,
                                      ___,
                                      ____,
                                      _____,
                                      ______,
                                      _______,
                                      ________,
                                      _________,
                                    ) {
                                      if (products.isEmpty) {
                                        return _emptyOrder();
                                      }

                                      return Column(
                                        children: [
                                          // Header kolom
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24.0),
                                            child: Row(
                                              children: const [
                                                Expanded(
                                                    flex: 4,
                                                    child: Text("Menu",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600))),
                                                SizedBox(
                                                    width: 150,
                                                    child: Text("Quantity",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600))),
                                                Expanded(
                                                    flex: 3,
                                                    child: Text("Subtotal",
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600))),
                                              ],
                                            ),
                                          ),

                                          // List pesanan
                                          Expanded(
                                            child: ListView.builder(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              itemCount: products.length,
                                              itemBuilder: (_, i) {
                                                return OrderMenu(
                                                  data: products[i],
                                                );
                                              },
                                            ),
                                          ),

                                          // Total
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text("Total",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              AppColors.primary,
                                                          fontSize: 20)),
                                                  Text(
                                                    products
                                                        .map((e) {
                                                          final basePrice = e
                                                                  .product
                                                                  .price
                                                                  ?.toIntegerFromText ??
                                                              0;
                                                          final variantPrice = e
                                                                  .variants
                                                                  ?.fold<int>(
                                                                      0,
                                                                      (sum, v) =>
                                                                          sum +
                                                                          v.priceAdjustment) ??
                                                              0;
                                                          return (basePrice +
                                                                  variantPrice) *
                                                              e.quantity;
                                                        })
                                                        .fold(
                                                            0, (a, b) => a + b)
                                                        .currencyFormatRp,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors.primary,
                                                        fontSize: 20),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            // 🔹 Tombol aksi hanya kalau ada pesanan
                            BlocBuilder<CheckoutBloc, CheckoutState>(
                              builder: (context, state) {
                                return state.maybeWhen(
                                  orElse: () => const SizedBox(),
                                  loaded: (
                                    products,
                                    _,
                                    __,
                                    ___,
                                    ____,
                                    _____,
                                    ______,
                                    _______,
                                    ________,
                                    _________,
                                  ) {
                                    if (products.isEmpty) {
                                      return const SizedBox();
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        children: [
                                          // Tombol Clear
                                          Button.outlined(
                                            width: 64,
                                            height: 64,
                                            color: AppColors.greyLight,
                                            icon: Assets.icons.trash.svg(
                                                height: 24,
                                                width: 24,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                        AppColors.grey,
                                                        BlendMode.srcIn)),
                                            borderColor: AppColors.grey,
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (_) =>
                                                    const ClearOrderDialog(),
                                              );

                                              if (!context.mounted) return;

                                              if (confirm == true) {
                                                // If editing open bill, cancel the order
                                                if (_isEditingOpenBill &&
                                                    _editingOpenBillId !=
                                                        null) {
                                                  await _cancelOpenBillOrder();
                                                } else {
                                                  // Normal clear order
                                                  context
                                                      .read<CheckoutBloc>()
                                                      .add(const CheckoutEvent
                                                          .clearOrder());
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            "Pesanan berhasil dihapus")),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),

                                          Expanded(
                                            child: BlocBuilder<CheckoutBloc,
                                                CheckoutState>(
                                              builder: (context, state) {
                                                int total = 0;
                                                String? orderType;
                                                state.maybeWhen(
                                                  loaded: (products,
                                                      discountModel,
                                                      discount,
                                                      discountAmount,
                                                      tax,
                                                      serviceCharge,
                                                      totalQuantity,
                                                      totalPrice,
                                                      draftName,
                                                      ordType) {
                                                    total = products.map((e) {
                                                      final basePrice = e
                                                              .product
                                                              .price
                                                              ?.toIntegerFromText ??
                                                          0;
                                                      final variantPrice =
                                                          e.variants?.fold<int>(
                                                                  0,
                                                                  (sum, v) =>
                                                                      sum +
                                                                      v.priceAdjustment) ??
                                                              0;
                                                      return (basePrice +
                                                              variantPrice) *
                                                          e.quantity;
                                                    }).fold(0, (a, b) => a + b);
                                                    orderType = ordType;
                                                  },
                                                  orElse: () {},
                                                );
                                                final isDisabled = total <= 0 ||
                                                    orderType == null;
                                                return CustomButton(
                                                  height: 64,
                                                  svgIcon: _isEditingOpenBill
                                                      ? Assets.icons.refresh
                                                      : Assets.icons.bill,
                                                  label: _isEditingOpenBill
                                                      ? 'Simpan'
                                                      : 'Open Bill',
                                                  disabled: isDisabled,
                                                  onPressed: isDisabled
                                                      ? () {
                                                          if (orderType ==
                                                              null) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .warning,
                                                                content: Text(
                                                                  "Pilih Dine In atau Take Away dulu",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      : _isEditingOpenBill
                                                          ? () =>
                                                              _updateOpenBillOrder(
                                                                  orderType!)
                                                          : () =>
                                                              _createOpenBillOrder(
                                                                  orderType!),
                                                );
                                              },
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          Expanded(
                                            child: BlocBuilder<CheckoutBloc,
                                                CheckoutState>(
                                              builder: (context, state) {
                                                final orderType =
                                                    state.maybeWhen(
                                                  loaded: (products,
                                                      discountModel,
                                                      discount,
                                                      discountAmount,
                                                      tax,
                                                      serviceCharge,
                                                      totalQuantity,
                                                      totalPrice,
                                                      draftName,
                                                      orderType) {
                                                    return orderType;
                                                  },
                                                  orElse: () => null,
                                                );

                                                return CustomButton(
                                                  filled: true,
                                                  height: 64,
                                                  svgIcon: Assets.icons.cash,
                                                  label: "Lanjutkan",
                                                  onPressed: orderType == null
                                                      ? () {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .warning,
                                                              content: Text(
                                                                "Pilih Dine In atau Take Away dulu",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      : () {
                                                          widget.onGoToPayment
                                                              ?.call(orderType,
                                                                  _orderNumber);
                                                        },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get orderTypeLabel {
    switch (_orderType) {
      case "dinein":
        return "Dine In";
      case "takeaway":
        return "Take Away";
      default:
        return "Belum dipilih";
    }
  }

  Widget _buildProductGrid({int? filterCategoryId}) {
    return BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
      builder: (context, categoriesState) {
        return BlocBuilder<LocalProductBloc, LocalProductState>(
          builder: (context, state) {
            return state.maybeWhen(
              orElse: () => const Center(child: CircularProgressIndicator()),
              loaded: (products) {
                // 1. Filter by category - create mutable copy
                var filtered = filterCategoryId == null
                    ? List<Product>.from(products)
                    : products
                        .where((e) => e.category?.id == filterCategoryId)
                        .toList();

                // 2. Filter by search query
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered
                      .where((e) =>
                          (e.name ?? '').toLowerCase().contains(_searchQuery))
                      .toList();
                }

                // 3. Sort by selected option
                if (_sortOption != null) {
                  switch (_sortOption!) {
                    case SortOption.nameAZ:
                      filtered.sort(
                          (a, b) => (a.name ?? '').compareTo(b.name ?? ''));
                      break;
                    case SortOption.nameZA:
                      filtered.sort(
                          (a, b) => (b.name ?? '').compareTo(a.name ?? ''));
                      break;
                    case SortOption.priceLowHigh:
                      filtered.sort((a, b) {
                        final priceA = a.price?.toIntegerFromText ?? 0;
                        final priceB = b.price?.toIntegerFromText ?? 0;
                        return priceA.compareTo(priceB);
                      });
                      break;
                    case SortOption.priceHighLow:
                      filtered.sort((a, b) {
                        final priceA = a.price?.toIntegerFromText ?? 0;
                        final priceB = b.price?.toIntegerFromText ?? 0;
                        return priceB.compareTo(priceA);
                      });
                      break;
                  }
                } else if (filterCategoryId == null) {
                  // 4. Default sorting by category order (Coffee → Tea → Pastry → Snack)
                  categoriesState.maybeWhen(
                    success: (categories) {
                      filtered.sort((a, b) {
                        final catIdA = a.category?.id ?? 999;
                        final catIdB = b.category?.id ?? 999;

                        // Find index in categories list
                        final indexA =
                            categories.indexWhere((c) => c.id == catIdA);
                        final indexB =
                            categories.indexWhere((c) => c.id == catIdB);

                        final orderA = indexA == -1 ? 999 : indexA;
                        final orderB = indexB == -1 ? 999 : indexB;

                        return orderA.compareTo(orderB);
                      });
                    },
                    orElse: () {},
                  );
                }

                //TODO: if empty product must have desain
                if (filtered.isEmpty) return _emptyProduct();

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ProductCard(
                    data: filtered[i],
                    onCartButton: () async {
                      final res = await showDialog<List<ProductVariant>>(
                        context: context,
                        builder: (_) => VariantDialog(product: filtered[i]),
                      );
                      if (!context.mounted) return;
                      if (res != null) {
                        final bloc = context.read<CheckoutBloc>();
                        bloc.setPendingVariants(res);
                        bloc.add(CheckoutEvent.addItem(filtered[i]));
                        if (filtered[i].id != null) {
                          setState(() {
                            _selectedVariants[filtered[i].id!] = res;
                          });
                        }
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _emptyOrder() {
    return EmptyState(
      icon: Assets.icons.bill,
      message: "Silakan Pilih Tipe Order",
      subtitle: "Tambahkan Pesanan",
    );
  }

  Widget _emptyProduct() {
    return EmptyState(
      icon: Assets.icons.stock,
      message: "Tidak Ada Produk",
    );
  }
}
