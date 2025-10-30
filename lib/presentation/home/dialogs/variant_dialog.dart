import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/core/utils/image_utils.dart';
import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/presentation/home/models/product_variant.dart';

class VariantDialog extends StatefulWidget {
  final Product product;
  final List<String> options;
  const VariantDialog(
      {super.key,
      required this.product,
      this.options = const [
        'Small',
        'Medium',
        'Large',
        'No Sugar',
        'Less Sugar',
        'More Sugar',
        'Hot',
        'Cold',
        'Less Ice',
        'Normal Ice',
        'More Ice',
      ]});

  @override
  State<VariantDialog> createState() => _VariantDialogState();
}

class _VariantItem {
  final String? id; // UUID from server
  final String label;
  final int priceAdjustment;
  _VariantItem(this.label, this.priceAdjustment, {this.id});
}

List<_VariantItem> _parseOptions(String body) {
  try {
    final map = jsonDecode(body);
    List list = [];
    if (map is List) list = map;
    if (map is Map) {
      final d = map['data'];
      if (d is List) list = d;
    }
    return list.map<_VariantItem>((e) {
      final id = e['id']?.toString(); // Capture UUID
      final name = (e['value'] ?? e['name'] ?? '').toString();
      final adj = (e['price_adjustment'] ?? 0).toString();
      final padj = int.tryParse(adj.replaceAll('.00', '')) ?? 0;
      return _VariantItem(name, padj, id: id);
    }).toList();
  } catch (_) {
    return [];
  }
}

class _VariantDialogState extends State<VariantDialog> {
  final Map<String, _VariantItem> selected =
      {}; // name -> _VariantItem (includes id)
  bool _loading = true;
  List<_VariantItem> _options = [];

  void _logDebug(String message, {Object? error}) {
    assert(() {
      developer.log(message, name: 'VariantDialog', error: error);
      return true;
    }());
  }

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    try {
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      // IMPORTANT: Use productId for API (this is the actual server ID)
      // id is local database ID, productId is from server
      final id = widget.product.productId ?? widget.product.id;

      _logDebug('========================================');
      _logDebug('VARIANT DIALOG - Fetching options for:');
      _logDebug('Product Name: ${widget.product.name}');
      _logDebug('Product ID (local): ${widget.product.id}');
      _logDebug('Product ProductId (server): ${widget.product.productId}');
      _logDebug('Using ID for API: $id');
      _logDebug('========================================');

      if (id == null) {
        setState(() {
          _options = [];
          _loading = false;
        });
        return;
      }

      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/products/$id/options');

      _logDebug('VARIANT DIALOG - API URL: $uri');

      final headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      var res = await http.get(uri, headers: headers);

      _logDebug('VARIANT DIALOG - Response Status: ${res.statusCode}');
      _logDebug('VARIANT DIALOG - Response Body: ${res.body}');

      if (res.statusCode == 403) {
        res = await http.get(uri, headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Accept': 'application/json',
        });
      }
      if (res.statusCode == 200) {
        final parsed = _parseOptions(res.body);
        _logDebug('VARIANT DIALOG - Parsed ${parsed.length} options');
        setState(() {
          _options = parsed;
          _loading = false;
        });
      } else {
        _logDebug('VARIANT DIALOG - No options found');
        setState(() {
          _options = [];
          _loading = false;
        });
      }
    } catch (e) {
      _logDebug('VARIANT DIALOG - Error: $e', error: e);
      setState(() {
        _options = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tambah Opsi Varian',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            IconButton(
              icon: Assets.icons.cancel.svg(
                colorFilter: ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
                height: 32,
                width: 32,
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      content: SizedBox(
        width: context.deviceWidth / 1.75,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Product card
              Expanded(
                flex: 2,
                child: Container(
                  height: 312,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.05 * 255).round()),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === Gambar Produk + Label Stok
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(
                                  12.0), // 🚀 padding gambar
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _buildProductImage(),
                              ),
                            ),
                            Positioned(
                              bottom: 18,
                              right: 18,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStockColor(),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Stok: ${_getDisplayStock()}",
                                  style: TextStyle(
                                    color: _getStockTextColor(),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Text(
                          widget.product.name ?? "-",
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Text(
                          (widget.product.price ?? '0')
                              .toIntegerFromText
                              .currencyFormatRp,
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
              const SizedBox(width: 16),
              // Right: Options
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pilihan :',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    // Scrollable list for variants
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 370, // adjust as needed
                          ),
                          child: Scrollbar(
                            thickness: 0,
                            thumbVisibility: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _options.isNotEmpty
                                  ? _options.length
                                  : widget.options.length,
                              itemBuilder: (context, idx) {
                                final item = _options.isNotEmpty
                                    ? _options[idx]
                                    : _VariantItem(widget.options[idx], 0);
                                final label = item.label;
                                final price = item.priceAdjustment;
                                final isSelected = selected.containsKey(label);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      // Tombol select di kiri
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (isSelected) {
                                              selected.remove(label);
                                            } else {
                                              selected[label] =
                                                  item; // Store full item with id
                                            }
                                          });
                                        },
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: isSelected
                                                ? Border.all(
                                                    color: AppColors.primary,
                                                    width: 2)
                                                : Border.all(
                                                    color: AppColors
                                                        .greyLightActive,
                                                    width: 2),
                                          ),
                                          alignment: Alignment.center,
                                          child: isSelected
                                              ? Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Nama varian
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      // Harga varian di kanan
                                      Text(
                                        "+ ${price.currencyFormatRp}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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
      actions: [
        Row(
          children: [
            Expanded(
              child: Button.outlined(
                label: 'Kembali',
                color: AppColors.greyLight,
                borderColor: AppColors.grey,
                textColor: AppColors.grey,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Button.filled(
                color: AppColors.success,
                label: 'Selesai',
                onPressed: () {
                  final variants = selected.entries
                      .map((e) => ProductVariant(
                            id: e.value.id, // Include UUID
                            name: e.key,
                            priceAdjustment: e.value.priceAdjustment,
                          ))
                      .toList();
                  Navigator.pop(context, variants);
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildProductImage() {
    final safeImageUrl = ImageUtils.getSafeImageUrl(widget.product.image);

    if (safeImageUrl == null) {
      return Container(
        height: double.infinity,
        width: double.infinity,
        color: AppColors.grey.withAlpha((0.3 * 255).round()),
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
          color: AppColors.grey.withAlpha((0.3 * 255).round()),
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
          color: AppColors.grey.withAlpha((0.3 * 255).round()),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  // Helper methods for stock display
  int _getDisplayStock() {
    final isTrackingInventory = widget.product.trackInventory ?? false;
    final actualStock = widget.product.stock ?? 0;
    return !isTrackingInventory ? 999 : actualStock;
  }

  Color _getStockColor() {
    final isTrackingInventory = widget.product.trackInventory ?? false;
    if (!isTrackingInventory) return AppColors.successLight;

    final stock = widget.product.stock ?? 0;
    final minStock = widget.product.minStockLevel ?? 0;
    return stock <= minStock ? AppColors.dangerLight : AppColors.successLight;
  }

  Color _getStockTextColor() {
    final isTrackingInventory = widget.product.trackInventory ?? false;
    if (!isTrackingInventory) return AppColors.success;

    final stock = widget.product.stock ?? 0;
    final minStock = widget.product.minStockLevel ?? 0;
    return stock <= minStock ? AppColors.danger : AppColors.success;
  }
}
