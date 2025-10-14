import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/core/utils/image_utils.dart';
import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/presentation/home/bloc/checkout/checkout_bloc.dart';

import '../../../core/constants/colors.dart';

class ProductCard extends StatelessWidget {
  final Product data;
  final VoidCallback onCartButton;

  const ProductCard({
    super.key,
    required this.data,
    required this.onCartButton,
  });

  @override
  Widget build(BuildContext context) {
    // Track inventory logic
    final isTrackingInventory = data.trackInventory ?? false;
    final actualStock = data.stock ?? 0;

    // Display stock: jika tidak tracking, tampilkan 999; jika tracking, tampilkan stock asli
    final displayStock = !isTrackingInventory ? 999 : actualStock;

    // Out of stock hanya untuk produk yang tracking inventory dan stock nya 0
    final isOutOfStock = isTrackingInventory && actualStock <= 0;

    // Debug logging - print untuk SEMUA produk
    print(
        'PRODUCT: ${data.name} | trackInventory=${data.trackInventory} | stock=${data.stock} | displayStock=$displayStock');

    return GestureDetector(
      onTap: isOutOfStock ? null : onCartButton,
      child: Opacity(
        opacity: isOutOfStock ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200, width: 1),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Gambar Produk + Label Stok + Overlay Habis
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0), // 🚀 padding gambar
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _buildProductImage(),
                      ),
                    ),
                    // Overlay "Stok Habis" jika stock = 0
                    if (isOutOfStock)
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.block,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Stok Habis',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Label Stok (hanya tampil jika masih ada stock atau tidak tracking)
                    if (!isOutOfStock)
                      Positioned(
                        bottom: 18,
                        right: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: !isTrackingInventory
                                ? AppColors.successLight
                                : (_stockIsLow()
                                    ? AppColors.dangerLight
                                    : AppColors.successLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Stok: $displayStock",
                            style: TextStyle(
                              color: !isTrackingInventory
                                  ? AppColors.success
                                  : (_stockIsLow()
                                      ? AppColors.danger
                                      : AppColors.success),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // === Nama Produk
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  data.name ?? "-",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // === Harga Produk
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  (data.price ?? '0').toIntegerFromText.currencyFormatRp,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final safeImageUrl = ImageUtils.getSafeImageUrl(data.image);

    if (safeImageUrl == null) {
      return Container(
        height: double.infinity,
        width: double.infinity,
        color: AppColors.grey.withOpacity(0.3),
        child: const Icon(
          Icons.image_not_supported,
          size: 40,
          color: AppColors.grey,
        ),
      );
    }

    return Image.network(
      safeImageUrl,
      height: double.infinity,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          color: AppColors.grey.withOpacity(0.3),
          child: const Icon(
            Icons.image_not_supported,
            size: 40,
            color: AppColors.grey,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: double.infinity,
          width: double.infinity,
          color: AppColors.grey.withOpacity(0.3),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  bool _stockIsLow() {
    final stock = data.stock ?? 0;
    final min = data.minStockLevel ?? 0;
    return stock <= min;
  }
}
