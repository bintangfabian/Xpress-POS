import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/presentation/home/bloc/local_product/local_product_bloc.dart';
import 'package:xpress/presentation/setting/bloc/sync_product/sync_product_bloc.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
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
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/presentation/home/dialogs/open_bill_dialog.dart';
import 'package:xpress/presentation/home/dialogs/clear_order_dialog.dart';
import 'package:xpress/presentation/home/widgets/sort_dropdown.dart';
import 'package:xpress/presentation/home/models/product_variant.dart';

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

  @override
  void initState() {
    // Force delete and re-sync products to ensure trackInventory is loaded
    _forceResyncProducts();

    context.read<GetCategoriesBloc>().add(const GetCategoriesEvent.fetch());
    _loadNextOrderNumber();
    super.initState();
  }

  Future<void> _forceResyncProducts() async {
    print('========================================');
    print('FORCE RESYNC: Deleting all products...');

    // Clear local products
    await ProductLocalDatasource.instance.deleteAllProducts();

    print('FORCE RESYNC: Products deleted, starting sync...');

    if (!mounted) return;

    // Sync from server
    context.read<SyncProductBloc>().add(const SyncProductEvent.syncProduct());

    // Load local products
    context
        .read<LocalProductBloc>()
        .add(const LocalProductEvent.getLocalProduct());

    print('FORCE RESYNC: Complete');
    print('========================================');
  }

  Future<void> _loadNextOrderNumber() async {
    try {
      final next = await OrderRemoteDatasource().getNextOrderNumber();
      if (!mounted) return;
      setState(() => _orderNumber = next);
    } catch (_) {}
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
            if (!mounted) return;
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
          child: Row(
            children: [
              // ✅ Kiri: Daftar Menu
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
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
                        child:
                            BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
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
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Pesanan
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            const Text(
                              "Pesanan",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
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
                            if (widget.isTable && widget.table != null) ...[
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

                            // 🔹 Open Bill di header hanya kalau kosong
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
                                        onPressed: () {},
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                          onPressed: () {
                                            context.read<CheckoutBloc>().add(
                                                const CheckoutEvent
                                                    .setOrderType("dinein"));
                                          },
                                        )
                                      : Button.outlined(
                                          label: "Dine In",
                                          onPressed: () {
                                            context.read<CheckoutBloc>().add(
                                                const CheckoutEvent
                                                    .setOrderType("dinein"));
                                          },
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: selectedType == "takeaway"
                                      ? Button.filled(
                                          label: "Take Away",
                                          onPressed: () {
                                            context.read<CheckoutBloc>().add(
                                                const CheckoutEvent
                                                    .setOrderType("takeaway"));
                                          },
                                        )
                                      : Button.outlined(
                                          label: "Take Away",
                                          onPressed: () {
                                            context.read<CheckoutBloc>().add(
                                                const CheckoutEvent
                                                    .setOrderType("takeaway"));
                                          },
                                        ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SpaceHeight(32),

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
                                if (products.isEmpty) return _emptyOrder();

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
                                                      fontWeight:
                                                          FontWeight.w600))),
                                          Expanded(
                                              flex: 3,
                                              child: Text("Quantity",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600))),
                                          Expanded(
                                              flex: 2,
                                              child: Text("Subtotal",
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600))),
                                        ],
                                      ),
                                    ),

                                    // List pesanan
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(16),
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
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Total",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                    fontSize: 20)),
                                            Text(
                                              products
                                                  .map((e) {
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
                                                  })
                                                  .fold(0, (a, b) => a + b)
                                                  .currencyFormatRp,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
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
                              if (products.isEmpty) return const SizedBox();

                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 16),
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
                                          colorFilter: const ColorFilter.mode(
                                              AppColors.grey, BlendMode.srcIn)),
                                      borderColor: AppColors.grey,
                                      padding: EdgeInsets.zero,
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) =>
                                              const ClearOrderDialog(),
                                        );

                                        if (confirm == true) {
                                          if (!mounted) return;
                                          context.read<CheckoutBloc>().add(
                                              const CheckoutEvent.clearOrder());
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Pesanan berhasil dihapus")),
                                          );
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
                                                final variantPrice = e.variants
                                                        ?.fold<int>(
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
                                          final isDisabled = total <= 0;
                                          return CustomButton(
                                            height: 64,
                                            svgIcon: Assets.icons.bill,
                                            label: 'Open Bill',
                                            disabled: isDisabled,
                                            onPressed: isDisabled
                                                ? () {}
                                                : () async {
                                                    // Parse table number from String to int
                                                    int? tableNum;
                                                    if (widget.table
                                                            ?.tableNumber !=
                                                        null) {
                                                      final numStr = widget
                                                          .table!.tableNumber!
                                                          .replaceAll(
                                                              RegExp(r'[^0-9]'),
                                                              '');
                                                      tableNum =
                                                          int.tryParse(numStr);
                                                    }

                                                    await showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          OpenBillDialog(
                                                        totalPrice: total,
                                                        orderNumber:
                                                            _orderNumber,
                                                        tableNumber: tableNum,
                                                        orderType: orderType,
                                                      ),
                                                    );
                                                  },
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Expanded(
                                      child: BlocBuilder<CheckoutBloc,
                                          CheckoutState>(
                                        builder: (context, state) {
                                          final orderType = state.maybeWhen(
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
                                                          content: Text(
                                                              "Pilih Dine In atau Take Away dulu")),
                                                    );
                                                  }
                                                : () {
                                                    widget.onGoToPayment?.call(
                                                        orderType,
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

                if (filtered.isEmpty)
                  return const Center(child: Text("No Items"));

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ProductCard(
                    data: filtered[i],
                    onCartButton: () async {
                      final res = await showDialog<List<ProductVariant>>(
                        context: context,
                        builder: (_) => VariantDialog(product: filtered[i]),
                      );
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
}
