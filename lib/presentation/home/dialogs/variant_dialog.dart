import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/components/spaces.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/core/utils/image_utils.dart';
import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';

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
  final String label;
  final int priceAdjustment;
  _VariantItem(this.label, this.priceAdjustment);
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
      final name = (e['value'] ?? e['name'] ?? '').toString();
      final adj = (e['price_adjustment'] ?? 0).toString();
      final padj = int.tryParse(adj.replaceAll('.00', '')) ?? 0;
      return _VariantItem(name, padj);
    }).toList();
  } catch (_) {
    return [];
  }
}

class _VariantDialogState extends State<VariantDialog> {
  final Set<String> selected = {};
  bool _loading = true;
  List<_VariantItem> _options = [];

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    try {
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final id = widget.product.id ?? widget.product.productId;
      if (id == null) {
        setState(() {
          _options = [];
          _loading = false;
        });
        return;
      }
      final uri = Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/products/$id/options');
      final headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };
      var res = await http.get(uri, headers: headers);
      if (res.statusCode == 403) {
        res = await http.get(uri, headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Accept': 'application/json',
        });
      }
      if (res.statusCode == 200) {
        final parsed = _parseOptions(res.body);
        setState(() {
          _options = parsed;
          _loading = false;
        });
      } else {
        setState(() {
          _options = [];
          _loading = false;
        });
      }
    } catch (_) {
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Tambah Opsi Varians',
              style: TextStyle(fontWeight: FontWeight.w700)),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      content: SizedBox(
        width: 678,
        height: 506,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Product card
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 312,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: Colors.grey.shade200, width: 1),
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
                                      color: AppColors.successLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Stok: ${widget.product.stock ?? 0}",
                                      style: TextStyle(
                                        color: AppColors.success,
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
                                  final label = _options.isNotEmpty
                                      ? _options[idx].label
                                      : widget.options[idx];
                                  final price = _options.isNotEmpty
                                      ? _options[idx].priceAdjustment
                                      : 0;
                                  final isSelected = selected.contains(label);

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
                                                selected.add(label);
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
              const SizedBox(height: 16),
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
                      onPressed: () =>
                          Navigator.pop(context, selected.toList()),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final safeImageUrl = ImageUtils.getSafeImageUrl(widget.product.image);

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
}
