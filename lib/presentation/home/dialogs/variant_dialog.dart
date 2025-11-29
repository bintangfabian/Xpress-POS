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
import 'package:xpress/data/datasources/product_variant_remote_datasource.dart';
import 'package:xpress/data/datasources/product_modifier_remote_datasource.dart';
import 'package:xpress/data/models/response/product_modifier_response_model.dart';
import 'package:xpress/presentation/home/models/product_variant.dart';
import 'package:xpress/presentation/home/models/product_modifier.dart';

class VariantDialog extends StatefulWidget {
  final Product product;
  final List<ProductVariant>? initialSelectedVariants;
  final List<ProductModifier>? initialSelectedModifiers;
  final List<String> options;

  const VariantDialog({
    super.key,
    required this.product,
    this.initialSelectedVariants,
    this.initialSelectedModifiers,
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
    ],
  });

  @override
  State<VariantDialog> createState() => _VariantDialogState();
}

// Helper class untuk grouped variant options
class _VariantGroupData {
  final String groupName;
  final bool isRequired;
  final List<_VariantOptionData> options;

  _VariantGroupData({
    required this.groupName,
    required this.isRequired,
    required this.options,
  });
}

class _VariantOptionData {
  final String id;
  final String value;
  final int priceAdjustment;
  final bool isDefault;

  _VariantOptionData({
    required this.id,
    required this.value,
    required this.priceAdjustment,
    required this.isDefault,
  });
}

class _VariantDialogState extends State<VariantDialog> {
  // Track selected option per group: groupName -> selected option ID
  final Map<String, String> _selectedPerGroup = {};

  bool _loading = true;
  List<_VariantGroupData> _variantGroups = [];
  String? _error;

  // Modifier state
  bool _loadingModifiers = false;
  List<ModifierGroup> _modifierGroups = [];
  final Map<String, Set<String>> _selectedModifiers =
      {}; // groupId -> Set of item IDs

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
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Get product ID (server ID)
      final productId =
          widget.product.productId?.toString() ?? widget.product.id?.toString();

      _logDebug('========================================');
      _logDebug('VARIANT DIALOG - Fetching variants for:');
      _logDebug('Product Name: ${widget.product.name}');
      _logDebug('Product ID: $productId');
      _logDebug('========================================');

      if (productId == null) {
        setState(() {
          _error = 'Product ID not found';
          _loading = false;
        });
        return;
      }

      // Fetch variant data using datasource
      final datasource = ProductVariantRemoteDatasource();
      final variantData = await datasource.getProductVariants(productId);

      if (variantData == null || !variantData.hasVariants) {
        _logDebug('VARIANT DIALOG - No variants found');
        setState(() {
          _variantGroups = [];
          _loading = false;
        });
        // Continue to fetch modifiers even if no variants
      }

      // Convert to internal format (only if variants exist)
      if (variantData != null && variantData.hasVariants) {
        final groups = variantData.variantGroups.map((group) {
          return _VariantGroupData(
            groupName: group.groupName,
            isRequired: group.isRequired,
            options: group.options.map((option) {
              return _VariantOptionData(
                id: option.id,
                value: option.value,
                priceAdjustment: option.priceAdjustmentInt,
                isDefault: option.isDefault,
              );
            }).toList(),
          );
        }).toList();

        _logDebug('VARIANT DIALOG - Found ${groups.length} variant groups');

        setState(() {
          _variantGroups = groups;
        });

        // Auto-select default options for required groups
        _autoSelectDefaults();
      }

      // Always fetch modifiers (even if no variants)
      await _fetchModifiers(productId);

      setState(() {
        _loading = false;
      });
    } catch (e, stackTrace) {
      _logDebug('VARIANT DIALOG - Error: $e', error: e);
      _logDebug('Stack trace: $stackTrace');
      setState(() {
        _error = 'Failed to load variants';
        _loading = false;
      });
    }
  }

  /// Fetch modifiers for the product
  Future<void> _fetchModifiers(String productId) async {
    setState(() {
      _loadingModifiers = true;
    });

    try {
      final modifierDatasource = ProductModifierRemoteDatasource();
      final modifierData =
          await modifierDatasource.getProductModifiers(productId);

      if (modifierData != null && modifierData.hasModifiers) {
        _logDebug(
            'VARIANT DIALOG - Found ${modifierData.modifierGroups.length} modifier groups');
        for (var group in modifierData.modifierGroups) {
          _logDebug('  - ${group.name}: ${group.items.length} items');
        }
        if (mounted) {
          setState(() {
            _modifierGroups = modifierData.modifierGroups;
            _loadingModifiers = false;
          });
          _logDebug(
              'VARIANT DIALOG - State updated with ${_modifierGroups.length} modifier groups');
          // Auto-select initial modifiers after modifiers are loaded
          _autoSelectInitialModifiers();
        }
      } else {
        _logDebug(
            'VARIANT DIALOG - No modifiers found (data: ${modifierData != null}, hasModifiers: ${modifierData?.hasModifiers ?? false})');
        if (mounted) {
          setState(() {
            _modifierGroups = [];
            _loadingModifiers = false;
          });
        }
      }
    } catch (e) {
      _logDebug('VARIANT DIALOG - Error fetching modifiers: $e');
      if (mounted) {
        setState(() {
          _modifierGroups = [];
          _loadingModifiers = false;
        });
      }
    }
  }

  /// Auto-select default options for required groups
  void _autoSelectDefaults() {
    // First, check if we have initial selected variants (editing mode)
    if (widget.initialSelectedVariants != null &&
        widget.initialSelectedVariants!.isNotEmpty) {
      _logDebug(
          'Loading initial selected variants: ${widget.initialSelectedVariants!.length}');

      // Map initial variants to groups by finding matching options
      for (var initialVariant in widget.initialSelectedVariants!) {
        _logDebug(
            '  - Initial variant: ${initialVariant.name} (ID: ${initialVariant.id})');

        // Find which group and option this variant belongs to
        for (var group in _variantGroups) {
          final matchingOption = group.options
              .where((opt) =>
                  opt.id == initialVariant.id ||
                  opt.value == initialVariant.name)
              .firstOrNull;

          if (matchingOption != null) {
            setState(() {
              _selectedPerGroup[group.groupName] = matchingOption.id;
            });
            _logDebug(
                '  ✓ Pre-selected ${matchingOption.value} for ${group.groupName}');
            break;
          }
        }
      }
    } else {
      // No initial selection, auto-select defaults for required groups
      for (var group in _variantGroups) {
        if (group.isRequired && group.options.isNotEmpty) {
          // Find default option or select first
          final defaultOption = group.options.firstWhere(
            (opt) => opt.isDefault,
            orElse: () => group.options.first,
          );

          setState(() {
            _selectedPerGroup[group.groupName] = defaultOption.id;
          });

          _logDebug(
              'Auto-selected ${defaultOption.value} for ${group.groupName}');
        }
      }
    }
  }

  /// Auto-select initial modifiers (for editing mode)
  void _autoSelectInitialModifiers() {
    if (widget.initialSelectedModifiers == null ||
        widget.initialSelectedModifiers!.isEmpty) {
      return;
    }

    _logDebug(
        'Loading initial selected modifiers: ${widget.initialSelectedModifiers!.length}');

    // Map initial modifiers to groups by finding matching items
    for (var initialModifier in widget.initialSelectedModifiers!) {
      _logDebug(
          '  - Initial modifier: ${initialModifier.name} (ID: ${initialModifier.id})');

      // Find which group and item this modifier belongs to
      for (var group in _modifierGroups) {
        final matchingItem = group.items
            .where((item) =>
                item.id == initialModifier.id ||
                item.name == initialModifier.name)
            .firstOrNull;

        if (matchingItem != null) {
          setState(() {
            final groupSelection = _selectedModifiers[group.id] ?? <String>{};
            groupSelection.add(matchingItem.id);
            _selectedModifiers[group.id] = groupSelection;
          });
          _logDebug('  ✓ Pre-selected ${matchingItem.name} for ${group.name}');
          break;
        }
      }
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
              // Right: Options (Grouped Variants)
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Pilihan :',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),

                      // Loading state
                      if (_loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )

                      // Error state
                      else if (_error != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: AppColors.grey),
                                const SizedBox(height: 8),
                                Text(_error!,
                                    style: TextStyle(color: AppColors.grey)),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _fetchOptions,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )

                      // Variant groups list (if exists) and Modifier section
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Variant groups
                            if (_variantGroups.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...List.generate(_variantGroups.length,
                                      (groupIdx) {
                                    final group = _variantGroups[groupIdx];
                                    return Column(
                                      children: [
                                        if (groupIdx > 0)
                                          const Divider(height: 24),
                                        _buildVariantGroup(group),
                                      ],
                                    );
                                  }),
                                ],
                              ),

                            // Divider between variants and modifiers
                            if (_variantGroups.isNotEmpty &&
                                !_loadingModifiers &&
                                _modifierGroups.isNotEmpty)
                              const Divider(height: 24),

                            // Modifier section (always show, even if loading or empty)
                            if (!_loading && _error == null)
                              _buildModifierSection(),

                            // Show message only if both are empty and not loading
                            if (_variantGroups.isEmpty &&
                                _modifierGroups.isEmpty &&
                                !_loadingModifiers &&
                                !_loading)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    'No variants or modifiers available',
                                    style: TextStyle(color: AppColors.grey),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
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
                onPressed: _handleConfirm,
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

  /// Build a variant group with radio button selection
  Widget _buildVariantGroup(_VariantGroupData group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Row(
          children: [
            Text(
              group.groupName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
            if (group.isRequired) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Wajib',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Group options
        ...group.options.map((option) {
          final isSelected = _selectedPerGroup[group.groupName] == option.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  // Radio behavior: select this option for this group
                  _selectedPerGroup[group.groupName] = option.id;
                });
              },
              child: Row(
                children: [
                  // Radio button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : Border.all(
                              color: AppColors.greyLightActive, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: isSelected
                        ? Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Option name
                  Expanded(
                    child: Text(
                      option.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Price adjustment
                  Text(
                    _formatPriceAdjustment(option.priceAdjustment),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: option.priceAdjustment == 0
                          ? AppColors.success
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Format price adjustment for display
  String _formatPriceAdjustment(int priceAdjustment) {
    if (priceAdjustment == 0) {
      return 'Free';
    } else if (priceAdjustment > 0) {
      return '+${priceAdjustment.currencyFormatRp}';
    } else {
      // Negative price (discount)
      return priceAdjustment.currencyFormatRp; // Already includes minus sign
    }
  }

  /// Build modifier section UI
  Widget _buildModifierSection() {
    _logDebug(
        '_buildModifierSection called - loading: $_loadingModifiers, groups: ${_modifierGroups.length}');

    if (_loadingModifiers) {
      _logDebug('Modifiers still loading...');
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_modifierGroups.isEmpty) {
      _logDebug('No modifier groups, returning empty');
      return const SizedBox.shrink();
    }

    _logDebug(
        'Building modifier section with ${_modifierGroups.length} groups');
    for (var group in _modifierGroups) {
      _logDebug('  - Group: ${group.name} (${group.items.length} items)');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_modifierGroups.length, (index) {
        final group = _modifierGroups[index];
        _logDebug('Building modifier group: ${group.name}');
        return Column(
          children: [
            if (index > 0) const Divider(height: 24),
            _buildModifierGroup(group),
          ],
        );
      }),
    );
  }

  /// Build modifier group UI (same design as variant)
  Widget _buildModifierGroup(ModifierGroup group) {
    final selectedIds = _selectedModifiers[group.id] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header (same as variant, with status and max select info)
        Row(
          children: [
            Text(
              group.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(width: 8),
            // Status badge (Wajib/Opsional)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: group.isRequired
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                group.isRequired ? 'Wajib' : 'Opsional',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: group.isRequired ? AppColors.primary : AppColors.grey,
                ),
              ),
            ),
            // Max select info
            if (group.maxSelect != null && group.maxSelect! > 0) ...[
              const SizedBox(width: 6),
              Text(
                '(Max ${group.maxSelect})',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: AppColors.grey,
                ),
              ),
            ] else if (group.allowsMultipleSelections &&
                (group.maxSelect == null || group.maxSelect == 0)) ...[
              const SizedBox(width: 6),
              Text(
                '(Max unlimited)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: AppColors.grey,
                ),
              ),
            ] else if (!group.allowsMultipleSelections) ...[
              const SizedBox(width: 6),
              Text(
                '(Max 1)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: AppColors.grey,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Group items (same design as variant options)
        ...group.items.map((item) {
          final isSelected = selectedIds.contains(item.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => _toggleModifierItem(group, item),
              child: Row(
                children: [
                  // Radio/Checkbox button (same as variant: 48x48, border radius 8)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : Border.all(
                              color: AppColors.greyLightActive, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: isSelected
                        ? Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Item name (same font as variant)
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Price adjustment (same as variant, show "Free" if 0)
                  Text(
                    item.priceDelta == 0 ? 'Free' : item.formattedPriceDelta,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: item.priceDelta == 0
                          ? AppColors.success
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Toggle modifier item selection
  void _toggleModifierItem(ModifierGroup group, ModifierItem item) {
    setState(() {
      final groupSelection = _selectedModifiers[group.id] ?? <String>{};

      if (group.allowsMultipleSelections) {
        if (groupSelection.contains(item.id)) {
          groupSelection.remove(item.id);
        } else {
          final maxSelect = group.maxSelect ?? 999;
          if (groupSelection.length < maxSelect) {
            groupSelection.add(item.id);
          } else {
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
        groupSelection.clear();
        groupSelection.add(item.id);
      }

      _selectedModifiers[group.id] = groupSelection;
    });
  }

  /// Validate and confirm selection
  void _handleConfirm() {
    // If no variants and no modifiers, just close
    if (_variantGroups.isEmpty && _modifierGroups.isEmpty) {
      Navigator.pop(context, {
        'variants': <ProductVariant>[],
        'modifiers': <ProductModifier>[],
      });
      return;
    }

    // Validate required variant groups
    for (var group in _variantGroups) {
      if (group.isRequired && !_selectedPerGroup.containsKey(group.groupName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mohon pilih ${group.groupName}'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // Validate required modifier groups
    for (var group in _modifierGroups) {
      if (group.isRequired) {
        final selectedIds = _selectedModifiers[group.id] ?? {};
        if (selectedIds.isEmpty || selectedIds.length < group.minSelect) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Mohon pilih minimal ${group.minSelect} dari ${group.name}'),
              backgroundColor: AppColors.danger,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
      }
    }

    // Build selected variants list
    final List<ProductVariant> selectedVariants = [];

    for (var entry in _selectedPerGroup.entries) {
      final groupName = entry.key;
      final selectedOptionId = entry.value;

      // Find the group and option
      final group = _variantGroups.firstWhere(
        (g) => g.groupName == groupName,
        orElse: () => _variantGroups.first,
      );

      final option = group.options.firstWhere(
        (o) => o.id == selectedOptionId,
        orElse: () => group.options.first,
      );

      // Save both group name and value for backend API
      selectedVariants.add(ProductVariant(
        id: option.id,
        name: option.value, // For display in UI
        groupName: groupName, // For backend API
        value: option.value, // For backend API
        priceAdjustment: option.priceAdjustment,
      ));
    }

    // Build selected modifiers list
    final List<ProductModifier> selectedModifiers = [];
    for (var group in _modifierGroups) {
      final selectedIds = _selectedModifiers[group.id] ?? {};
      for (var itemId in selectedIds) {
        final item = group.items.firstWhere(
          (it) => it.id == itemId,
          orElse: () => group.items.first,
        );
        selectedModifiers.add(ProductModifier(
          id: item.id,
          name: item.name,
          groupName: group.name,
          priceDelta: item.priceDelta,
        ));
      }
    }

    _logDebug('Selected variants: ${selectedVariants.length}');
    for (var v in selectedVariants) {
      _logDebug('  - ${v.name}: ${v.id} (+${v.priceAdjustment})');
    }

    _logDebug('Selected modifiers: ${selectedModifiers.length}');
    for (var m in selectedModifiers) {
      _logDebug('  - ${m.name}: ${m.id} (+${m.priceDelta})');
    }

    // Return both variants and modifiers as Map
    Navigator.pop(context, {
      'variants': selectedVariants,
      'modifiers': selectedModifiers,
    });
  }

  // Helper methods for stock display
  String _getDisplayStock() {
    final isTrackingInventory = widget.product.trackInventory ?? false;
    final actualStock = widget.product.stock; // null means unlimited
    // If not tracking or stock is null (unlimited), show "∞"
    if (!isTrackingInventory || actualStock == null) {
      return "∞";
    }
    return actualStock.toString();
  }

  Color _getStockColor() {
    final isTrackingInventory = widget.product.trackInventory ?? false;
    if (!isTrackingInventory) return AppColors.successLight;

    final stock = widget.product.stock;
    // If stock is null (unlimited), it's never low
    if (stock == null) return AppColors.successLight;

    final minStock = widget.product.minStockLevel ?? 0;
    return stock <= minStock ? AppColors.dangerLight : AppColors.successLight;
  }

  Color _getStockTextColor() {
    final isTrackingInventory = widget.product.trackInventory ?? false;
    if (!isTrackingInventory) return AppColors.success;

    final stock = widget.product.stock;
    // If stock is null (unlimited), it's never low
    if (stock == null) return AppColors.success;
    final minStock = widget.product.minStockLevel ?? 0;
    return stock <= minStock ? AppColors.danger : AppColors.success;
  }
}
