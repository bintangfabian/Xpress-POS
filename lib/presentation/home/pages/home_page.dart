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
import 'package:xpress/presentation/home/widgets/custom_button.dart';
import 'package:xpress/presentation/home/widgets/custom_tab_bar.dart';
import 'package:xpress/presentation/home/widgets/order_menu.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/components/components.dart';
import '../../../core/constants/colors.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../widgets/product_card.dart';
import 'package:xpress/presentation/home/dialogs/variant_dialog.dart';
import 'package:xpress/data/datasources/product_variant_remote_datasource.dart';
import 'package:xpress/data/datasources/product_modifier_remote_datasource.dart';
import 'package:xpress/presentation/home/models/product_modifier.dart';
import 'package:xpress/presentation/setting/bloc/get_categories/get_categories_bloc.dart';
import 'package:xpress/presentation/setting/bloc/sync_product/sync_product_bloc.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/presentation/home/dialogs/open_bill_list_dialog.dart';
import 'package:xpress/presentation/home/dialogs/clear_order_dialog.dart';
import 'package:xpress/presentation/home/widgets/sort_dropdown.dart';
import 'package:xpress/presentation/home/models/product_variant.dart';
import 'package:xpress/presentation/home/models/product_quantity.dart';
import 'package:xpress/presentation/home/pages/confirm_payment_page.dart';
import 'package:xpress/presentation/home/pages/dashboard_page.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/core/utils/amount_parser.dart';
import 'package:xpress/data/datasources/subscription_remote_datasource.dart';
import 'package:xpress/presentation/home/dialogs/limit_exceeded_dialog.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';
import 'package:xpress/core/utils/snackbar_helper.dart';

class HomePage extends StatefulWidget {
  final bool isTable;
  final TableModel? table;
  final void Function(String orderType, String orderNumber,
      {String? existingOrderId, ItemOrder? openBillOrder})? onGoToPayment;

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
  ItemOrder? _editingOpenBillOrder; // Store full order object

  // ✅ FIX: Prevent concurrent force resync
  bool _isResyncInProgress = false;

  void _logHome(String message) {
    assert(() {
      developer.log(message, name: 'HomePage');
      return true;
    }());
  }

  @override
  void initState() {
    // ✅ Load products directly from API (no local database storage to prevent duplication)
    context
        .read<LocalProductBloc>()
        .add(const LocalProductEvent.getLocalProduct());

    context.read<GetCategoriesBloc>().add(const GetCategoriesEvent.fetch());
    _loadNextOrderNumber();

    // ✅ Fast Checkout: Auto set operation mode
    // Jika sudah memilih meja, set ke dine in, jika tidak set ke takeaway
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOperationMode();
    });

    super.initState();
  }

  // ✅ Helper method untuk update operation mode berdasarkan meja
  void _updateOperationMode() {
    final orderType =
        (widget.isTable && widget.table != null) ? 'dinein' : 'takeaway';
    context.read<CheckoutBloc>().add(
          CheckoutEvent.setOrderType(orderType),
        );
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Update operation mode jika meja berubah
    if (oldWidget.table?.id != widget.table?.id ||
        oldWidget.isTable != widget.isTable) {
      _updateOperationMode();
    }
  }

  Future<void> _forceResyncProducts() async {
    // ✅ FIX: Prevent concurrent resync operations
    if (_isResyncInProgress) {
      _logHome('⚠️ FORCE RESYNC: Already in progress, skipping...');
      return;
    }

    _isResyncInProgress = true;
    _logHome('========================================');
    _logHome('FORCE RESYNC: Deleting all products...');

    // Clear local products
    await ProductLocalDatasource.instance.deleteAllProducts();

    _logHome('FORCE RESYNC: Products deleted, starting sync...');

    if (!mounted) {
      _isResyncInProgress = false;
      return;
    }

    // Sync from server
    // ✅ FIX: Don't load products here - let BlocListener handle it after sync completes
    // This prevents race condition that causes duplicate products
    context.read<SyncProductBloc>().add(const SyncProductEvent.syncProduct());

    _logHome('FORCE RESYNC: Triggered, waiting for sync to complete...');
    _logHome('========================================');
    // Note: _isResyncInProgress will be reset in BlocListener after sync completes
  }

  Future<void> _loadNextOrderNumber() async {
    try {
      final next = await OrderRemoteDatasource().getNextOrderNumber();
      if (!mounted) return;
      setState(() => _orderNumber = next);
    } catch (_) {}
  }
  //

  /// Handle editing variant and modifier for item already in cart
  Future<void> _handleEditVariant(ProductQuantity productQuantity) async {
    try {
      _logHome('========================================');
      _logHome('Edit variant/modifier for: ${productQuantity.product.name}');
      _logHome('Current variants: ${productQuantity.variants?.length ?? 0}');
      _logHome('Current modifiers: ${productQuantity.modifiers?.length ?? 0}');

      // Get product ID
      final productId = productQuantity.product.productId?.toString() ??
          productQuantity.product.id?.toString();

      if (productId == null) {
        _logHome('ERROR: Product ID is null');
        return;
      }

      // Check if product has variants or modifiers
      final datasource = ProductVariantRemoteDatasource();
      final variantData = await datasource.getProductVariants(productId);

      final modifierDatasource = ProductModifierRemoteDatasource();
      final modifierData =
          await modifierDatasource.getProductModifiers(productId);

      if (!mounted) return;

      // Show dialog if has variants OR modifiers
      if ((variantData != null && variantData.hasVariants) ||
          (modifierData != null && modifierData.hasModifiers)) {
        _logHome('✅ Opening variant/modifier dialog for edit...');

        // Show dialog with pre-selected variants and modifiers
        final dialogResult = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (_) => VariantDialog(
            product: productQuantity.product,
            initialSelectedVariants: productQuantity.variants,
            initialSelectedModifiers: productQuantity.modifiers,
          ),
        );

        if (!mounted) return;

        if (dialogResult != null) {
          final variants = dialogResult['variants'] as List<ProductVariant>?;
          final modifiers = dialogResult['modifiers'] as List<ProductModifier>?;

          _logHome('✅ Variants updated: ${variants?.length ?? 0} options');
          _logHome('✅ Modifiers updated: ${modifiers?.length ?? 0} items');

          // Update the item in cart with new variants and modifiers
          final bloc = context.read<CheckoutBloc>();
          bloc.add(CheckoutEvent.updateItemVariantsAndModifiers(
            productQuantity.product,
            productQuantity.variants, // old variants
            variants ?? [], // new variants
            productQuantity.modifiers, // old modifiers
            modifiers ?? [], // new modifiers
          ));

          _logHome('✅ Item variants and modifiers updated in cart');
        } else {
          _logHome('ℹ️ Edit cancelled');
        }
      }

      _logHome('========================================');
    } catch (e, stackTrace) {
      _logHome('❌ Error editing variants/modifiers: $e');
      _logHome('Stack trace: $stackTrace');
    }
  }

  /// Handle product selection with conditional variant logic
  /// If product has variants → show variant dialog
  /// If product has no variants → directly add to cart
  Future<void> _handleProductSelection(Product product) async {
    try {
      _logHome('========================================');
      _logHome('Product selected: ${product.name}');
      _logHome('Checking for variants...');

      // Get product ID (use server ID if available)
      final productId = product.productId?.toString() ?? product.id?.toString();

      if (productId == null) {
        _logHome('ERROR: Product ID is null');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid product'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Check if product has variants
      final datasource = ProductVariantRemoteDatasource();
      final variantData = await datasource.getProductVariants(productId);

      if (!mounted) return;

      // Show variant dialog (which now includes modifiers, even if no variants)
      // This dialog will show modifiers if available, regardless of variants
      List<ProductVariant>? selectedVariants;
      List<ProductModifier>? selectedModifiers;

      // Check if product has modifiers
      final modifierDatasource = ProductModifierRemoteDatasource();
      final modifierData =
          await modifierDatasource.getProductModifiers(productId);

      if (!mounted) return;

      // Show dialog if has variants OR modifiers
      if ((variantData != null && variantData.hasVariants) ||
          (modifierData != null && modifierData.hasModifiers)) {
        if (variantData != null && variantData.hasVariants) {
          _logHome(
              '✅ Product has ${variantData.variantGroups.length} variant groups');
        }
        if (modifierData != null && modifierData.hasModifiers) {
          _logHome(
              '✅ Product has ${modifierData.modifierGroups.length} modifier groups');
        }
        _logHome('   Opening variant dialog (with modifiers)...');

        // VariantDialog now returns Map with both variants and modifiers
        final dialogResult = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (_) => VariantDialog(product: product),
        );

        if (!mounted) return;

        if (dialogResult != null) {
          final variants = dialogResult['variants'] as List<ProductVariant>?;
          final modifiers = dialogResult['modifiers'] as List<ProductModifier>?;

          if (variants != null && variants.isNotEmpty) {
            _logHome('✅ Variants selected: ${variants.length} options');
            selectedVariants = variants;

            // Store selected variants for this product
            if (product.id != null) {
              setState(() {
                _selectedVariants[product.id!] = variants;
              });
            }
          }

          if (modifiers != null && modifiers.isNotEmpty) {
            _logHome('✅ Modifiers selected: ${modifiers.length} items');
            selectedModifiers = modifiers;
          } else {
            _logHome('ℹ️ No modifiers selected (optional)');
          }
        } else {
          _logHome('ℹ️ Dialog cancelled');
          return; // User cancelled
        }
      } else {
        _logHome('ℹ️ Product has no variants or modifiers');
        // Add directly to cart without dialog
      }

      // Add to cart with selected variants and modifiers
      _logHome('✅ Adding to cart...');
      final bloc = context.read<CheckoutBloc>();
      bloc.setPendingVariants(selectedVariants);
      bloc.setPendingModifiers(selectedModifiers);
      bloc.add(CheckoutEvent.addItem(product));

      _logHome('✅ Product added to cart');
      _logHome('   Variants: ${selectedVariants?.length ?? 0}');
      _logHome('   Modifiers: ${selectedModifiers?.length ?? 0}');

      _logHome('========================================');
    } catch (e, stackTrace) {
      _logHome('❌ Error handling product selection: $e');
      _logHome('Stack trace: $stackTrace');

      // If error checking variants, assume no variants and add directly
      _logHome('⚠️ Assuming no variants due to error, adding directly...');

      if (mounted) {
        final bloc = context.read<CheckoutBloc>();
        bloc.setPendingVariants(null);
        bloc.add(CheckoutEvent.addItem(product));
      }
    }
  }

  Future<void> _createOpenBillOrder(String orderType) async {
    try {
      // ✅ PRE-CHECK: Check limit before creating open bill order
      final onlineCheckerBloc = context.read<OnlineCheckerBloc>();
      if (onlineCheckerBloc.isOnline) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        try {
          final subscriptionDatasource = SubscriptionRemoteDatasource();
          final limitResult = await subscriptionDatasource.checkLimitStatus();

          if (!mounted) return;
          Navigator.of(context).pop(); // Close loading

          bool shouldContinue = true;
          limitResult.fold(
            (error) {
              // Error checking limit - continue anyway
              _logHome('Warning: Failed to check limit: $error');
              shouldContinue = true;
            },
            (limitResponse) {
              if (!limitResponse.canCreateOrder ||
                  limitResponse.warningLevel == 'exceeded') {
                // Show limit exceeded dialog
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => LimitExceededDialog(
                      message: limitResponse.message ??
                          'Anda telah mencapai limit transaksi bulanan. Silakan upgrade plan untuk melanjutkan transaksi.',
                      recommendedPlan: limitResponse.recommendedPlan,
                      currentCount: limitResponse.currentCount,
                      limit: limitResponse.limit,
                    ),
                  );
                }
                shouldContinue = false; // Stop here, don't create order
              }
            },
          );

          // ✅ EARLY RETURN: Jika limit exceeded, jangan lanjutkan
          if (!shouldContinue) {
            return;
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop(); // Close loading
          }
          _logHome('Error checking limit: $e');
          // Continue anyway if error
        }
      }

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

          // Build items using toOrderItemMap() for correct API format
          final items = products.map((e) {
            // Convert ProductQuantity to order item format
            final productQuantity = ProductQuantity(
              product: e.product,
              quantity: e.quantity,
              variants: e.variants,
              modifiers: e.modifiers, // ✅ Include modifiers
            );
            return productQuantity.toOrderItemMap();
          }).toList();

          // Build order data
          final orderData = <String, dynamic>{
            'operation_mode': orderType == 'dinein' ? 'dine_in' : 'takeaway',
            'payment_mode': 'open_bill',
            'status': 'open',
            'service_charge': serviceAmt.toDouble(),
            'discount_amount': discAmt.toDouble(),
            'notes': '',
            'items': items,
            'deduct_inventory':
                true, // ✅ Tambahkan flag untuk kurangi stok saat create open bill
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
          if (taxAmt > 0) orderData['tax_amount'] = taxAmt.toDouble();

          // Create open bill order
          _logHome('📤 Creating open bill order...');
          _logHome('Order data: $orderData');

          final result = await OrderRemoteDatasource().createOpenBillOrder(
            orderData: orderData,
            totalAmount: totalAmt,
          );

          if (!mounted) return;

          // Close loading dialog
          Navigator.of(context).pop();

          result.fold(
            (error) {
              _logHome('❌ Failed to create open bill: $error');
              SnackbarHelper.showErrorOrOffline(
                context,
                'Gagal membuat Open Bill: $error',
                offlineMessage:
                    'Membuat Open Bill tidak tersedia dalam mode offline. '
                    'Silahkan hubungkan kembali koneksi internet.',
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

        SnackbarHelper.showErrorOrOffline(
          context,
          'Error: $e',
          offlineMessage: 'Operasi tidak tersedia dalam mode offline. '
              'Silahkan hubungkan kembali koneksi internet.',
        );
      }
    }
  }

  // Load open bill to checkout (Lanjutkan)
  Future<void> _loadOpenBillToCheckout(ItemOrder order) async {
    _logHome('🔄 Loading open bill to checkout: ${order.id}');
    _logHome('Order items count: ${order.items?.length ?? 0}');

    // Set editing state
    setState(() {
      _isEditingOpenBill = true;
      _editingOpenBillId = order.id;
      _editingOpenBillOrder = order; // Store full order object
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
          paymentAmount: AmountParser.parse(order.totalAmount),
        );
      }
    });

    // ✅ Clear existing checkout first
    _logHome('🧹 Clearing existing checkout...');
    context.read<CheckoutBloc>().add(const CheckoutEvent.clearOrder());

    // ✅ Wait for clear to complete - increase delay to ensure state is cleared
    await Future.delayed(const Duration(milliseconds: 300));

    // Load items to checkout one by one
    if (order.items != null && order.items!.isNotEmpty) {
      _logHome('📦 Loading ${order.items!.length} items...');

      for (var item in order.items!) {
        if (item.productId != null) {
          _logHome(
              '  - Loading product: ${item.productName} (ID: ${item.productId}) x${item.quantity}');

          // ✅ Create Product directly from OrderItem data (no local database query)
          Product? result;

          // Use item.product if available (from eager loaded relationship), otherwise create from OrderItem fields
          if (item.product != null) {
            // Convert order_response_model.Product to Product from product_response_model
            final orderProduct = item.product!;
            result = Product(
              id: orderProduct.id,
              productId: orderProduct.id,
              name: orderProduct.name,
              price: item.unitPrice ?? '0', // Use unitPrice from order item
              image: orderProduct.image,
              category: null,
            );
            _logHome(
                '    ✓ Product from order item: ${result.name} (ID: ${result.id})');
          } else {
            // Create Product from OrderItem fields
            result = Product(
              id: item.productId,
              productId: item.productId,
              name: item.productName ?? '',
              price: item.unitPrice ?? '0',
              image: null,
              category: null,
            );
            _logHome(
                '    ✓ Product created from order item data: ${result.name} (ID: ${result.id})');
          }

          // ✅ Restore variants from productOptions
          List<ProductVariant>? restoredVariants;
          if (item.productOptions != null && item.productOptions!.isNotEmpty) {
            _logHome(
                '    📦 Restoring ${item.productOptions!.length} variants...');
            restoredVariants = [];
            for (var option in item.productOptions!) {
              if (option is Map<String, dynamic>) {
                // ✅ FIX: Parse price_adjustment safely (can be String, int, or double)
                final priceAdj = option['price_adjustment'];
                final priceAdjInt = priceAdj is int
                    ? priceAdj
                    : priceAdj is double
                        ? priceAdj.toInt()
                        : priceAdj is String
                            ? (double.tryParse(priceAdj) ?? 0.0).toInt()
                            : 0;

                final variant = ProductVariant(
                  id: option['id']?.toString(),
                  name: option['name']?.toString() ??
                      option['value']?.toString() ??
                      '',
                  groupName: option['name']?.toString(),
                  value: option['value']?.toString(),
                  priceAdjustment: priceAdjInt,
                );
                restoredVariants.add(variant);
                _logHome(
                    '      ✓ Variant: ${variant.name} (+${variant.priceAdjustment})');
              }
            }
          }

          // ✅ Restore modifiers from modifiers field
          List<ProductModifier>? restoredModifiers;
          if (item.modifiers != null && item.modifiers!.isNotEmpty) {
            _logHome('    🎨 Restoring ${item.modifiers!.length} modifiers...');
            restoredModifiers = [];
            for (var modifierData in item.modifiers!) {
              // Use modifier_item data if available, otherwise use order_item_modifier data
              final modifierItem = modifierData.modifierItem;
              if (modifierItem != null) {
                final modifier = ProductModifier(
                  id: modifierItem.id,
                  name: modifierItem.name ?? '',
                  groupName: null, // Can be enhanced later if needed
                  priceDelta: modifierItem.priceDelta ?? 0.0,
                );
                restoredModifiers.add(modifier);
                _logHome(
                    '      ✓ Modifier: ${modifier.name} (+${modifier.priceDelta.toInt()})');
              } else if (modifierData.modifierItemId != null) {
                // Fallback: create modifier from modifier_item_id
                final modifier = ProductModifier(
                  id: modifierData.modifierItemId,
                  name:
                      'Modifier', // Will be updated when product modifiers are loaded
                  priceDelta: modifierData.priceDelta ?? 0.0,
                );
                restoredModifiers.add(modifier);
                _logHome(
                    '      ✓ Modifier (ID only): ${modifier.id} (+${modifier.priceDelta.toInt()})');
              }
            }
          }

          // ✅ Set pending variants and modifiers BEFORE adding items
          // This ensures variants/modifiers are applied when items are added
          if (restoredVariants != null && restoredVariants.isNotEmpty) {
            context.read<CheckoutBloc>().setPendingVariants(restoredVariants);
            _logHome('    ✅ Variants set as pending');
          }
          if (restoredModifiers != null && restoredModifiers.isNotEmpty) {
            context.read<CheckoutBloc>().setPendingModifiers(restoredModifiers);
            _logHome('    ✅ Modifiers set as pending');
          }

          // Add item multiple times to match quantity (CheckoutBloc will handle grouping)
          // Variants and modifiers are already set as pending, so they will be applied
          final quantity = item.quantity ?? 1;
          _logHome('    Adding $quantity items to checkout...');
          for (int i = 0; i < quantity; i++) {
            if (mounted) {
              context.read<CheckoutBloc>().add(
                    CheckoutEvent.addItem(result),
                  );
              _logHome('      ✓ Added item ${i + 1}/$quantity');
              // Small delay between each add to ensure CheckoutBloc processes the event
              await Future.delayed(const Duration(milliseconds: 150));
            }
          }

          // ✅ Clear pending after adding all items for this product (variants/modifiers already applied)
          // Wait a bit longer to ensure all items are fully processed by CheckoutBloc
          await Future.delayed(const Duration(milliseconds: 200));
          if (mounted) {
            context.read<CheckoutBloc>().setPendingVariants(null);
            context.read<CheckoutBloc>().setPendingModifiers(null);
            _logHome('    ✅ Pending variants/modifiers cleared');
          }
        }
      }

      _logHome('✅ All items loaded');
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

          // Build items using toOrderItemMap() for correct API format
          final items = products.map((e) {
            // Convert ProductQuantity to order item format
            final productQuantity = ProductQuantity(
              product: e.product,
              quantity: e.quantity,
              variants: e.variants,
              modifiers: e.modifiers, // ✅ Include modifiers
            );
            final itemMap = productQuantity.toOrderItemMap();
            // ✅ Add unit_price, total_price, and product_name for update open bill (required by backend)
            final unitPrice = productQuantity.unitPrice;
            final totalPrice = productQuantity.totalPrice;
            itemMap['unit_price'] = unitPrice;
            itemMap['total_price'] = totalPrice;
            itemMap['product_name'] =
                e.product.name; // ✅ Required: product_name cannot be null
            return itemMap;
          }).toList();

          // Build order data for update
          final orderData = <String, dynamic>{
            'operation_mode': orderType == 'dinein' ? 'dine_in' : 'takeaway',
            'service_charge': serviceAmt.toDouble(),
            'discount_amount': discAmt.toDouble(),
            'notes': '',
            'items': items,
            'update_inventory':
                true, // ✅ Update stok saat edit open bill (jika ada perubahan items)
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
          if (taxAmt > 0) orderData['tax_amount'] = taxAmt.toDouble();

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
              SnackbarHelper.showErrorOrOffline(
                context,
                'Gagal mengupdate Open Bill: $error',
                offlineMessage:
                    'Update Open Bill tidak tersedia dalam mode offline. '
                    'Silahkan hubungkan kembali koneksi internet.',
              );
            },
            (success) {
              // ✅ Clear checkout dan reset state setelah update berhasil
              context
                  .read<CheckoutBloc>()
                  .add(const CheckoutEvent.clearOrder());
              setState(() {
                _isEditingOpenBill = false;
                _editingOpenBillId = null;
                _editingOpenBillTable = null;
                _editingOpenBillOrder = null;
              });

              // ✅ Resync products to update stock after order update
              _forceResyncProducts();

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

        SnackbarHelper.showErrorOrOffline(
          context,
          'Error: $e',
          offlineMessage: 'Operasi tidak tersedia dalam mode offline. '
              'Silahkan hubungkan kembali koneksi internet.',
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
          SnackbarHelper.showErrorOrOffline(
            context,
            'Gagal membatalkan Open Bill: $error',
            offlineMessage:
                'Membatalkan Open Bill tidak tersedia dalam mode offline. '
                'Silahkan hubungkan kembali koneksi internet.',
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
            _editingOpenBillOrder = null; // Clear full order object
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

        SnackbarHelper.showErrorOrOffline(
          context,
          'Error: $e',
          offlineMessage: 'Operasi tidak tersedia dalam mode offline. '
              'Silahkan hubungkan kembali koneksi internet.',
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
        paymentAmount: AmountParser.parse(order.totalAmount),
      );
    }

    // ✅ Clear existing checkout first
    _logHome('🧹 Clearing existing checkout for payment...');
    context.read<CheckoutBloc>().add(const CheckoutEvent.clearOrder());

    // ✅ Wait for clear to complete - increase delay to ensure state is cleared
    await Future.delayed(const Duration(milliseconds: 300));

    // ✅ FIX: Load items with variants and modifiers to CheckoutBloc
    if (order.items != null && order.items!.isNotEmpty) {
      _logHome(
          '📦 Loading ${order.items!.length} items to checkout for payment...');

      // Group items by product_id, variants, and modifiers to add them once with correct quantity
      final Map<String, ProductQuantity> groupedItems = {};

      for (var item in order.items!) {
        if (item.productId != null) {
          _logHome(
              '  - Processing product: ${item.productName} (ID: ${item.productId}) x${item.quantity}');

          // Convert productOptions (List<dynamic>) to List<ProductVariant>
          final List<ProductVariant> itemVariants = [];
          if (item.productOptions != null && item.productOptions!.isNotEmpty) {
            for (var option in item.productOptions!) {
              if (option is Map<String, dynamic>) {
                final priceAdj = option['price_adjustment'];
                final priceAdjInt = priceAdj is int
                    ? priceAdj
                    : priceAdj is double
                        ? priceAdj.toInt()
                        : priceAdj is String
                            ? (int.tryParse(priceAdj) ?? 0)
                            : 0;
                itemVariants.add(ProductVariant(
                  id: option['id']?.toString(),
                  name: option['name']?.toString() ??
                      option['value']?.toString() ??
                      '',
                  groupName: option['name']?.toString(),
                  value: option['value']?.toString(),
                  priceAdjustment: priceAdjInt,
                ));
              }
            }
          }

          // Convert modifiers (List<OrderItemModifier>) to List<ProductModifier>
          final List<ProductModifier> itemModifiers = [];
          if (item.modifiers != null && item.modifiers!.isNotEmpty) {
            for (var modifierData in item.modifiers!) {
              final modifierItem = modifierData.modifierItem;
              if (modifierItem != null) {
                itemModifiers.add(ProductModifier(
                  id: modifierItem.id,
                  name: modifierItem.name ?? 'Unknown Modifier',
                  priceDelta: modifierItem.priceDelta ?? 0.0,
                ));
              } else if (modifierData.modifierItemId != null) {
                itemModifiers.add(ProductModifier(
                  id: modifierData.modifierItemId,
                  name: 'Modifier',
                  priceDelta: modifierData.priceDelta ?? 0.0,
                ));
              }
            }
          }

          // Create a unique key for grouping based on product, variants, and modifiers
          final itemKey =
              '${item.productId}-${itemVariants.map((v) => v.id).join(',')}-${itemModifiers.map((m) => m.id).join(',')}';

          if (groupedItems.containsKey(itemKey)) {
            groupedItems[itemKey]!.quantity += (item.quantity ?? 1);
          } else {
            // ✅ Create Product directly from OrderItem data (no local database query)
            Product? result;

            // Use item.product if available (from eager loaded relationship), otherwise create from OrderItem fields
            if (item.product != null) {
              // Convert order_response_model.Product to Product from product_response_model
              final orderProduct = item.product!;
              result = Product(
                id: orderProduct.id,
                productId: orderProduct.id,
                name: orderProduct.name,
                price: item.unitPrice ?? '0', // Use unitPrice from order item
                image: orderProduct.image,
                category: null,
              );
            } else {
              // Create Product from OrderItem fields
              result = Product(
                id: item.productId,
                productId: item.productId,
                name: item.productName ?? '',
                price: item.unitPrice ?? '0',
                image: null,
                category: null,
              );
            }

            // result is always non-null after creation
            groupedItems[itemKey] = ProductQuantity(
              product: result,
              quantity: item.quantity ?? 1,
              variants: itemVariants.isNotEmpty ? itemVariants : null,
              modifiers: itemModifiers.isNotEmpty ? itemModifiers : null,
            );
          }
        }
      }

      // Add grouped items to checkout bloc
      for (var entry in groupedItems.entries) {
        final productQuantity = entry.value;
        _logHome(
            '  Adding grouped item: ${productQuantity.product.name} x${productQuantity.quantity}');
        _logHome(
            '    Variants: ${productQuantity.variants?.map((v) => v.name).join(', ') ?? 'None'}');
        _logHome(
            '    Modifiers: ${productQuantity.modifiers?.map((m) => m.name).join(', ') ?? 'None'}');

        if (mounted) {
          // ✅ Set pending variants and modifiers BEFORE adding items
          if (productQuantity.variants != null &&
              productQuantity.variants!.isNotEmpty) {
            context
                .read<CheckoutBloc>()
                .setPendingVariants(productQuantity.variants);
            _logHome('    ✅ Variants set as pending');
          }
          if (productQuantity.modifiers != null &&
              productQuantity.modifiers!.isNotEmpty) {
            context
                .read<CheckoutBloc>()
                .setPendingModifiers(productQuantity.modifiers);
            _logHome('    ✅ Modifiers set as pending');
          }

          // Add the item with the correct quantity
          _logHome(
              '    Adding ${productQuantity.quantity} items to checkout...');
          for (int i = 0; i < productQuantity.quantity; i++) {
            if (mounted) {
              context.read<CheckoutBloc>().add(
                    CheckoutEvent.addItem(productQuantity.product),
                  );
              _logHome(
                  '      ✓ Added item ${i + 1}/${productQuantity.quantity}');
              // Small delay between each add to prevent race condition
              await Future.delayed(const Duration(milliseconds: 150));
            }
          }

          // ✅ Clear pending after adding all items for this product
          // Wait a bit longer to ensure all items are fully processed by CheckoutBloc
          await Future.delayed(const Duration(milliseconds: 200));
          if (mounted) {
            context.read<CheckoutBloc>().setPendingVariants(null);
            context.read<CheckoutBloc>().setPendingModifiers(null);
            _logHome('    ✅ Pending variants/modifiers cleared');
          }
        }
      }

      _logHome('✅ All items loaded to checkout');
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
            existingOrderId: order.id,
            openBillOrder: order,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Disable BlocListener for SyncProductBloc to prevent auto resync and duplication
    // Products are loaded from local database only. Resync is done manually when needed.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.only(top: 6.0, right: 6.0),
        child: Column(
          children: [
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
                                // ✅ Tampilkan table dari widget.table atau _editingOpenBillTable
                                if ((widget.isTable && widget.table != null) ||
                                    _editingOpenBillTable != null) ...[
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
                                        _editingOpenBillTable?.name ??
                                            widget.table?.name ??
                                            "Meja ${_editingOpenBillTable?.tableNumber ?? widget.table?.tableNumber ?? ''}",
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
                                            onPressed: () async {
                                              // Show dialog and wait for result
                                              await showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    OpenBillListDialog(
                                                  onContinue:
                                                      _loadOpenBillToCheckout,
                                                  onPay:
                                                      _navigateToPaymentFromOpenBill,
                                                ),
                                              );
                                              // Refresh open bills list after dialog closes
                                              // This ensures completed orders are removed from list
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
                                                          fontWeight: FontWeight
                                                              .w600))),
                                              SizedBox(
                                                  width: 150,
                                                  child: Text("Quantity",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight
                                                              .w600))),
                                              Expanded(
                                                  flex: 3,
                                                  child: Text("Subtotal",
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight
                                                              .w600))),
                                            ],
                                          ),
                                        ),

                                        // List pesanan
                                        Expanded(
                                          child: ListView.builder(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            itemCount: products.length,
                                            itemBuilder: (_, i) {
                                              return OrderMenu(
                                                data: products[i],
                                                onTap: products[i].hasVariants
                                                    ? () => _handleEditVariant(
                                                        products[i])
                                                    : null,
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
                                                        // ✅ Include modifier price adjustment
                                                        final modifierPrice = e
                                                                .modifiers
                                                                ?.fold<int>(
                                                                    0,
                                                                    (sum, m) =>
                                                                        sum +
                                                                        m.priceDelta
                                                                            .toInt()) ??
                                                            0;
                                                        return (basePrice +
                                                                variantPrice +
                                                                modifierPrice) *
                                                            e.quantity;
                                                      })
                                                      .fold(0, (a, b) => a + b)
                                                      .currencyFormatRp,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                  _editingOpenBillId != null) {
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
                                                    // ✅ Include modifier price adjustment
                                                    final modifierPrice =
                                                        e.modifiers?.fold<int>(
                                                                0,
                                                                (sum, m) =>
                                                                    sum +
                                                                    m.priceDelta
                                                                        .toInt()) ??
                                                            0;
                                                    return (basePrice +
                                                            variantPrice +
                                                            modifierPrice) *
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
                                                    ? () {}
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
                                                disabled: orderType == null,
                                                onPressed: orderType == null
                                                    ? () {}
                                                    : () {
                                                        // Pass open bill context if in editing mode
                                                        widget.onGoToPayment
                                                            ?.call(
                                                          orderType,
                                                          _orderNumber,
                                                          existingOrderId:
                                                              _isEditingOpenBill
                                                                  ? _editingOpenBillId
                                                                  : null,
                                                          openBillOrder:
                                                              _isEditingOpenBill
                                                                  ? _editingOpenBillOrder
                                                                  : null,
                                                        );
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
                      await _handleProductSelection(filtered[i]);
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
