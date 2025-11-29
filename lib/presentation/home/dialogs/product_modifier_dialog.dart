import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/utils/image_utils.dart';
import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/data/models/response/product_modifier_response_model.dart';
import 'package:xpress/data/datasources/product_modifier_remote_datasource.dart';
import 'package:xpress/presentation/home/models/product_modifier.dart';

/// Modifier dialog dengan UI yang sama seperti variant dialog
/// Mendukung:
/// - Multiple modifier groups (Toppings, Sauces, etc)
/// - Required groups validation
/// - Single/multiple selection per group
/// - Real-time price calculation
class ProductModifierDialog extends StatefulWidget {
  final Product product;

  const ProductModifierDialog({
    super.key,
    required this.product,
  });

  @override
  State<ProductModifierDialog> createState() => _ProductModifierDialogState();
}

class _ProductModifierDialogState extends State<ProductModifierDialog> {
  final ProductModifierRemoteDatasource _datasource =
      ProductModifierRemoteDatasource();

  bool _loading = true;
  String? _error;
  ProductModifierData? _modifierData;

  // Selected items per group: groupId -> Set of item IDs
  final Map<String, Set<String>> _selectedItems = {};

  // Track price adjustment
  double _totalPriceAdjustment = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchModifiers();
  }

  Future<void> _fetchModifiers() async {
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

      final data = await _datasource.getProductModifiers(productId);

      if (data == null || !data.hasModifiers) {
        setState(() {
          _error = 'No modifiers available';
          _loading = false;
        });
        return;
      }

      setState(() {
        _modifierData = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load modifiers: $e';
        _loading = false;
      });
    }
  }

  /// Toggle item selection
  void _toggleItem(ModifierGroup group, ModifierItem item) {
    setState(() {
      final groupSelection = _selectedItems[group.id] ?? <String>{};

      if (group.allowsMultipleSelections) {
        // Multiple selection (checkbox)
        if (groupSelection.contains(item.id)) {
          groupSelection.remove(item.id);
        } else {
          // Check max selections
          final maxSelect = group.maxSelect ?? 999; // null means unlimited
          if (groupSelection.length < maxSelect) {
            groupSelection.add(item.id);
          } else {
            // Show snackbar if max reached
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Maximum ${group.maxSelect ?? "unlimited"} selections for ${group.name}'),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
        }
      } else {
        // Single selection (radio)
        groupSelection.clear();
        groupSelection.add(item.id);
      }

      _selectedItems[group.id] = groupSelection;
      _calculatePriceAdjustment();
    });
  }

  /// Calculate total price adjustment from selected items
  void _calculatePriceAdjustment() {
    double total = 0.0;

    if (_modifierData == null) return;

    for (var group in _modifierData!.modifierGroups) {
      final selectedIds = _selectedItems[group.id] ?? {};

      for (var itemId in selectedIds) {
        final item = group.items.firstWhere(
          (it) => it.id == itemId,
          orElse: () => group.items.first,
        );
        total += item.priceDelta;
      }
    }

    setState(() {
      _totalPriceAdjustment = total;
    });
  }

  /// Validate selections before confirming
  bool _validateSelections() {
    if (_modifierData == null) return false;

    for (var group in _modifierData!.modifierGroups) {
      if (group.isRequired) {
        final selectedIds = _selectedItems[group.id] ?? {};
        if (selectedIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Please select at least ${group.minSelect} from ${group.name}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          return false;
        }

        // Check min select
        if (selectedIds.length < group.minSelect) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Please select at least ${group.minSelect} from ${group.name}'),
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

  /// Convert selections to ProductModifier list
  List<ProductModifier> _buildModifierList() {
    final List<ProductModifier> modifiers = [];

    if (_modifierData == null) return modifiers;

    for (var group in _modifierData!.modifierGroups) {
      final selectedIds = _selectedItems[group.id] ?? {};

      for (var itemId in selectedIds) {
        final item = group.items.firstWhere(
          (it) => it.id == itemId,
          orElse: () => group.items.first,
        );

        modifiers.add(ProductModifier(
          id: item.id,
          name: item.name,
          groupName: group.name,
          priceDelta: item.priceDelta,
        ));
      }
    }

    return modifiers;
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
                  'Pilih Modifier',
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
              Text('Loading modifiers...',
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
                onPressed: _fetchModifiers,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_modifierData == null || !_modifierData!.hasModifiers) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.grey),
              const SizedBox(height: 16),
              Text('No modifiers available',
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

          // Modifier groups
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: _modifierData!.modifierGroups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final group = _modifierData!.modifierGroups[index];
                return _buildModifierGroup(group);
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

  Widget _buildModifierGroup(ModifierGroup group) {
    final selectedIds = _selectedItems[group.id] ?? {};

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
                group.name,
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
        Text(
          group.allowsMultipleSelections
              ? 'Select ${group.minSelect > 0 ? '${group.minSelect}-' : ''}${group.maxSelect ?? "unlimited"} options'
              : 'Select one option',
          style: TextStyle(fontSize: 12, color: AppColors.grey),
        ),
        const SizedBox(height: 12),

        // Items
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: group.items.map((item) {
            final isSelected = selectedIds.contains(item.id);
            return _buildItemChip(group, item, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildItemChip(
      ModifierGroup group, ModifierItem item, bool isSelected) {
    return InkWell(
      onTap: () => _toggleItem(group, item),
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
                  item.name,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.grey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (item.priceDelta != 0)
                  Text(
                    item.formattedPriceDelta,
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
                  final modifiers = _buildModifierList();
                  Navigator.pop(context, modifiers);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
