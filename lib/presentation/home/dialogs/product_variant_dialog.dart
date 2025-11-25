import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/utils/image_utils.dart';
import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/data/models/response/product_variant_response_model.dart';
import 'package:xpress/data/datasources/product_variant_remote_datasource.dart';
import 'package:xpress/presentation/home/models/product_variant.dart';

/// Improved variant dialog dengan support untuk variant groups
/// Mendukung:
/// - Multiple variant groups (Size, Milk, Sugar, etc)
/// - Required groups validation
/// - Single/multiple selection per group
/// - Real-time price calculation
/// - Auto-select default options
class ProductVariantDialog extends StatefulWidget {
  final Product product;

  const ProductVariantDialog({
    super.key,
    required this.product,
  });

  @override
  State<ProductVariantDialog> createState() => _ProductVariantDialogState();
}

class _ProductVariantDialogState extends State<ProductVariantDialog> {
  final ProductVariantRemoteDatasource _datasource =
      ProductVariantRemoteDatasource();

  bool _loading = true;
  String? _error;
  ProductVariantData? _variantData;

  // Selected options per group: groupName -> Set of option IDs
  final Map<String, Set<String>> _selectedOptions = {};

  // Track price adjustment
  double _totalPriceAdjustment = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchVariants();
  }

  Future<void> _fetchVariants() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Use productId (server ID) for API call
      final productId =
          widget.product.productId?.toString() ?? widget.product.id?.toString();

      if (productId == null) {
        setState(() {
          _error = 'Product ID not found';
          _loading = false;
        });
        return;
      }

      final data = await _datasource.getProductVariants(productId);

      if (data == null || !data.hasVariants) {
        setState(() {
          _error = 'No variants available';
          _loading = false;
        });
        return;
      }

      setState(() {
        _variantData = data;
        _loading = false;
      });

      // Auto-select default options
      _autoSelectDefaults();
    } catch (e) {
      setState(() {
        _error = 'Failed to load variants: $e';
        _loading = false;
      });
    }
  }

  /// Auto-select default options for each group
  void _autoSelectDefaults() {
    if (_variantData == null) return;

    for (var group in _variantData!.variantGroups) {
      // Find default option
      final defaultOption = group.options.firstWhere(
        (opt) => opt.isDefault,
        orElse: () => group.options.first,
      );

      // Auto-select for required groups only
      if (group.isRequired) {
        _selectedOptions[group.groupName] = {defaultOption.id};
        _calculatePriceAdjustment();
      }
    }
  }

  /// Toggle option selection
  void _toggleOption(VariantGroup group, VariantOption option) {
    setState(() {
      final groupSelection = _selectedOptions[group.groupName] ?? <String>{};

      if (group.allowsMultipleSelections) {
        // Multiple selection (checkbox)
        if (groupSelection.contains(option.id)) {
          groupSelection.remove(option.id);
        } else {
          // Check max selections
          if (groupSelection.length < group.maxSelections) {
            groupSelection.add(option.id);
          } else {
            // Show snackbar if max reached
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Maximum ${group.maxSelections} selections for ${group.groupName}'),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
        }
      } else {
        // Single selection (radio)
        groupSelection.clear();
        groupSelection.add(option.id);
      }

      _selectedOptions[group.groupName] = groupSelection;
      _calculatePriceAdjustment();
    });
  }

  /// Calculate total price adjustment from selected options
  void _calculatePriceAdjustment() {
    double total = 0.0;

    if (_variantData == null) return;

    for (var group in _variantData!.variantGroups) {
      final selectedIds = _selectedOptions[group.groupName] ?? {};

      for (var optionId in selectedIds) {
        final option = group.options.firstWhere(
          (opt) => opt.id == optionId,
          orElse: () => group.options.first,
        );
        total += option.priceAdjustment;
      }
    }

    setState(() {
      _totalPriceAdjustment = total;
    });
  }

  /// Validate selections before confirming
  bool _validateSelections() {
    if (_variantData == null) return false;

    for (var group in _variantData!.variantGroups) {
      if (group.isRequired) {
        final selectedIds = _selectedOptions[group.groupName] ?? {};
        if (selectedIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select ${group.groupName}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          return false;
        }
      }
    }

    return true;
  }

  /// Convert selections to ProductVariant list (for backward compatibility)
  List<ProductVariant> _buildVariantList() {
    final List<ProductVariant> variants = [];

    if (_variantData == null) return variants;

    for (var group in _variantData!.variantGroups) {
      final selectedIds = _selectedOptions[group.groupName] ?? {};

      for (var optionId in selectedIds) {
        final option = group.options.firstWhere(
          (opt) => opt.id == optionId,
          orElse: () => group.options.first,
        );

        variants.add(ProductVariant(
          id: option.id,
          name: group.groupName,
          priceAdjustment: option.priceAdjustmentInt,
        ));
      }
    }

    return variants;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      title: _buildHeader(),
      content: _buildContent(),
      actions: [_buildActions()],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Varian Produk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.name ?? 'Unknown Product',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Assets.icons.cancel.svg(
              colorFilter: ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
              height: 28,
              width: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Loading variants...',
                  style: TextStyle(color: AppColors.grey)),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.grey),
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: AppColors.grey)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _fetchVariants,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_variantData == null || !_variantData!.hasVariants) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.grey),
              const SizedBox(height: 16),
              Text('No variants available',
                  style: TextStyle(color: AppColors.grey)),
            ],
          ),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxHeight: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product image
          _buildProductImage(),
          const Divider(height: 1),

          // Variant groups
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: _variantData!.variantGroups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final group = _variantData!.variantGroups[index];
                return _buildVariantGroup(group);
              },
            ),
          ),

          // Price summary
          _buildPriceSummary(),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final safeImageUrl = ImageUtils.getSafeImageUrl(widget.product.image);

    return Container(
      height: 120,
      width: double.infinity,
      color: AppColors.greyLight.withOpacity(0.3),
      child: safeImageUrl != null
          ? Image.network(
              safeImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Icon(
      Icons.image_outlined,
      size: 48,
      color: AppColors.grey.withOpacity(0.5),
    );
  }

  Widget _buildVariantGroup(VariantGroup group) {
    final selectedIds = _selectedOptions[group.groupName] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Row(
          children: [
            Text(
              group.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                group.groupName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (group.isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Group info
        if (group.allowsMultipleSelections)
          Text(
            'Select up to ${group.maxSelections} options',
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          )
        else
          Text(
            'Select one option',
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        const SizedBox(height: 12),

        // Options
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: group.options.map((option) {
            final isSelected = selectedIds.contains(option.id);
            return _buildOptionChip(group, option, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionChip(
      VariantGroup group, VariantOption option, bool isSelected) {
    return InkWell(
      onTap: () => _toggleOption(group, option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (group.allowsMultipleSelections)
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 18,
                color: isSelected ? AppColors.white : AppColors.grey,
              )
            else
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 18,
                color: isSelected ? AppColors.white : AppColors.grey,
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.value,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.grey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (option.priceAdjustment != 0)
                  Text(
                    option.formattedPriceAdjustment,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.white.withOpacity(0.9)
                          : AppColors.grey,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    final basePrice = double.tryParse(widget.product.price ?? '0') ?? 0.0;
    final finalPrice = basePrice + _totalPriceAdjustment;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyLight.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: AppColors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                finalPrice.toInt().currencyFormatRp,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (_totalPriceAdjustment != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _totalPriceAdjustment > 0
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_totalPriceAdjustment > 0 ? '+' : ''}${_totalPriceAdjustment.toInt().currencyFormatRp}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _totalPriceAdjustment > 0
                      ? AppColors.primary
                      : Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Button.outlined(
              label: 'Batal',
              color: AppColors.greyLight,
              borderColor: AppColors.grey,
              textColor: AppColors.grey,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Button.filled(
              color: AppColors.primary,
              label: 'Tambah ke Pesanan',
              onPressed: () {
                if (_validateSelections()) {
                  final variants = _buildVariantList();
                  Navigator.pop(context, variants);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
