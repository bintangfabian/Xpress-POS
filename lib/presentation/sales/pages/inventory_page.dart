import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/presentation/home/bloc/local_product/local_product_bloc.dart';
import 'package:xpress/presentation/report/blocs/product_sales/product_sales_bloc.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

enum InventorySortOption {
  nameAsc('Nama A-Z'),
  nameDesc('Nama Z-A'),
  priceAsc('Harga Rendah-Tinggi'),
  priceDesc('Harga Tinggi-Rendah'),
  stockAsc('Stok Terendah'),
  stockDesc('Stok Tertinggi'),
  soldAsc('Terjual Terendah'),
  soldDesc('Terjual Tertinggi');

  final String label;
  const InventorySortOption(this.label);
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'Semua';
  Map<int, int> _soldQuantities = {}; // Map productId -> soldQuantity
  InventorySortOption? _currentSort;

  @override
  void initState() {
    super.initState();
    // Load products
    context
        .read<LocalProductBloc>()
        .add(const LocalProductEvent.getLocalProduct());

    // Load sales data for today
    final now = TimezoneHelper.now();
    final startDate =
        DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];
    final endDate = now.toIso8601String().split('T')[0];
    context.read<ProductSalesBloc>().add(
          ProductSalesEvent.getProductSales(startDate, endDate),
        );
  }

  Future<void> _refreshData() async {
    // Reload products
    context
        .read<LocalProductBloc>()
        .add(const LocalProductEvent.getLocalProduct());

    // Reload sales data for today
    final now = TimezoneHelper.now();
    final startDate =
        DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];
    final endDate = now.toIso8601String().split('T')[0];
    context.read<ProductSalesBloc>().add(
          ProductSalesEvent.getProductSales(startDate, endDate),
        );

    // Wait a bit for the data to load
    await Future.delayed(const Duration(milliseconds: 500));
  }

  List<Product> _filterProducts(List<Product> products) {
    // Create a mutable copy of the list
    List<Product> filtered = List<Product>.from(products);

    // Filter by search text
    if (_searchCtrl.text.isNotEmpty) {
      filtered = filtered
          .where((p) => (p.name ?? '')
              .toLowerCase()
              .contains(_searchCtrl.text.toLowerCase()))
          .toList();
    }

    // Filter by category
    if (_selectedCategory != 'Semua') {
      filtered = filtered
          .where((p) => (p.category?.name ?? 'Lainnya') == _selectedCategory)
          .toList();
    }

    // Sort products - create a new list to ensure it's mutable
    final sortedList = List<Product>.from(filtered);
    if (_currentSort != null) {
      sortedList.sort((a, b) {
        switch (_currentSort!) {
          case InventorySortOption.nameAsc:
            return (a.name ?? '').compareTo(b.name ?? '');
          case InventorySortOption.nameDesc:
            return (b.name ?? '').compareTo(a.name ?? '');
          case InventorySortOption.priceAsc:
            final priceA = int.tryParse(a.price ?? '0') ?? 0;
            final priceB = int.tryParse(b.price ?? '0') ?? 0;
            return priceA.compareTo(priceB);
          case InventorySortOption.priceDesc:
            final priceA = int.tryParse(a.price ?? '0') ?? 0;
            final priceB = int.tryParse(b.price ?? '0') ?? 0;
            return priceB.compareTo(priceA);
          case InventorySortOption.stockAsc:
            final stockA = a.stock ?? 999999;
            final stockB = b.stock ?? 999999;
            return stockA.compareTo(stockB);
          case InventorySortOption.stockDesc:
            final stockA = a.stock ?? 999999;
            final stockB = b.stock ?? 999999;
            return stockB.compareTo(stockA);
          case InventorySortOption.soldAsc:
            final soldA = _soldQuantities[a.productId] ?? 0;
            final soldB = _soldQuantities[b.productId] ?? 0;
            return soldA.compareTo(soldB);
          case InventorySortOption.soldDesc:
            final soldA = _soldQuantities[a.productId] ?? 0;
            final soldB = _soldQuantities[b.productId] ?? 0;
            return soldB.compareTo(soldA);
        }
      });
    }

    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductSalesBloc, ProductSalesState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (sales) {
            // Convert sales list to map for quick lookup
            setState(() {
              _soldQuantities = {
                for (var sale in sales)
                  if (sale.productId != null)
                    sale.productId!:
                        int.tryParse(sale.totalQuantity ?? '0') ?? 0
              };
            });
          },
          orElse: () {},
        );
      },
      child: BlocBuilder<LocalProductBloc, LocalProductState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Memuat data...')),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat data',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LocalProductBloc>().add(
                            const LocalProductEvent.getLocalProduct(),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
            loaded: (products) {
              // Get unique categories
              final categories = <String>{};
              for (var product in products) {
                final categoryName = product.category?.name ?? 'Lainnya';
                categories.add(categoryName);
              }
              // Sort categories and ensure "Semua" is always first
              final sortedCategories = categories.toList()..sort();
              final categoryList = ['Semua', ...sortedCategories];

              final filteredProducts = _filterProducts(products);

              return RefreshIndicator(
                onRefresh: _refreshData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ContentTitle('Inventori'),
                      const SpaceHeight(16),

                      // Search + sort
                      Row(
                        children: [
                          Expanded(
                            child: SearchInput(
                              controller: _searchCtrl,
                              hintText: 'Cari Produk...',
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          PopupMenuButton<InventorySortOption>(
                            offset: const Offset(0, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            color: AppColors.white,
                            itemBuilder: (context) =>
                                InventorySortOption.values.map((option) {
                              return PopupMenuItem<InventorySortOption>(
                                value: option,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 0),
                                height: 48,
                                child: Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _currentSort == option
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: _currentSort == option
                                        ? AppColors.primary
                                        : AppColors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            onSelected: (option) {
                              setState(() {
                                _currentSort = option;
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                border: Border.all(
                                    color: AppColors.primary, width: 2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Assets.icons.sort.svg(
                                  height: 24,
                                  width: 24,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      const SpaceHeight(16),

                      // Category Tabs (Horizontal Scroll)
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryList.length,
                          itemBuilder: (context, index) {
                            final category = categoryList[index];
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < categoryList.length - 1 ? 12 : 0,
                              ),
                              child: _TabChip(
                                label: category,
                                isActive: isSelected,
                                onTap: () => setState(
                                    () => _selectedCategory = category),
                              ),
                            );
                          },
                        ),
                      ),

                      const SpaceHeight(16),

                      // Header row
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            _HeaderCell('Gambar', flex: 2),
                            _HeaderCell('Menu', flex: 5),
                            _HeaderCell('Stok', flex: 2),
                            _HeaderCell('Terjual', flex: 2),
                            _HeaderCell('Status', flex: 1),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // List
                      filteredProducts.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  'Tidak ada produk ditemukan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: filteredProducts
                                  .map((product) => _InventoryRow(
                                        product: product,
                                        soldQuantity: _soldQuantities[
                                                product.productId] ??
                                            0,
                                      ))
                                  .toList(),
                            ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TabChip(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.white : AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  const _HeaderCell(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  final Product product;
  final int soldQuantity;

  const _InventoryRow({
    required this.product,
    required this.soldQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final stock = product.stock; // null means unlimited stock
    final minStockLevel = product.minStockLevel ?? 5;
    // If stock is null (unlimited), it's never low
    final isLowStock = stock != null && stock <= minStockLevel;
    final price = int.tryParse(product.price ?? '0') ?? 0;
    final categoryName = product.category?.name ?? 'Lainnya';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildProductImage(),
            ),
          ),
          // Menu & Info
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Produk',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${price.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        )}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Stok
          Expanded(
            flex: 2,
            child: Text(
              stock == null ? '∞' : '$stock',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isLowStock ? AppColors.danger : AppColors.black,
              ),
            ),
          ),
          // Terjual
          Expanded(
            flex: 2,
            child: Text(
              '$soldQuantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
          // Status
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isLowStock
                      ? AppColors.dangerLight
                      : AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isLowStock ? 'Stok Rendah' : 'Stok Aman',
                  style: TextStyle(
                    color: isLowStock ? AppColors.danger : AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final imageUrl = product.image;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Try to load network image
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          height: 60,
          width: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultImage(),
        );
      } else {
        // Try to load asset image
        return Image.asset(
          imageUrl,
          height: 60,
          width: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultImage(),
        );
      }
    }

    return _defaultImage();
  }

  Widget _defaultImage() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Assets.icons.food.svg(
        height: 30,
        width: 30,
        colorFilter: const ColorFilter.mode(
          AppColors.grey,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
