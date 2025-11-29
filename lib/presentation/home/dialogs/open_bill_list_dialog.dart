import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/data/models/response/order_response_model.dart';
import 'package:xpress/presentation/home/dialogs/open_bill_detail_dialog.dart';
import 'package:xpress/core/utils/amount_parser.dart';

class OpenBillListDialog extends StatefulWidget {
  final Function(ItemOrder)? onContinue;
  final Function(ItemOrder)? onPay;

  const OpenBillListDialog({
    super.key,
    this.onContinue,
    this.onPay,
  });

  @override
  State<OpenBillListDialog> createState() => _OpenBillListDialogState();
}

class _OpenBillListDialogState extends State<OpenBillListDialog> {
  bool _isLoading = true;
  List<ItemOrder> _openBills = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOpenBills();
  }

  Future<void> _loadOpenBills() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await OrderRemoteDatasource().getOpenBills();

      result.fold(
        (error) {
          print('❌ Error loading open bills: $error');
          setState(() {
            _errorMessage = error;
            _isLoading = false;
          });
        },
        (orders) {
          print('✅ Loaded ${orders.length} open bills');
          // Debug each order
          for (var order in orders) {
            print('  Order ${order.orderNumber}:');
            print('    - Total Amount: ${order.totalAmount}');
            print('    - Items count: ${order.items?.length ?? 0}');
            if (order.items != null && order.items!.isNotEmpty) {
              for (var item in order.items!) {
                print(
                    '      * ${item.productName} x${item.quantity} = ${item.totalPrice}');
              }
            }
          }

          setState(() {
            _openBills = orders;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      print('❌ Exception loading open bills: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.white,
      child: SizedBox(
        width: 600,
        height: 700,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Open Bill',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.white),
                        onPressed: _loadOpenBills,
                        tooltip: 'Refresh',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadOpenBills,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                  ),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _openBills.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: AppColors.grey.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Tidak ada Open Bill',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _openBills.length,
                              itemBuilder: (context, index) {
                                final order = _openBills[index];
                                return _buildOpenBillCard(order, context);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenBillCard(ItemOrder order, BuildContext context) {
    // Calculate total from items if totalAmount is 0 or null
    int totalAmount = AmountParser.parse(order.totalAmount);

    print('🏷️ Building card for ${order.orderNumber}:');
    print(
        '   totalAmount from order: ${order.totalAmount} (parsed: $totalAmount)');
    print('   items count: ${order.items?.length ?? 0}');

    if (totalAmount == 0 && order.items != null && order.items!.isNotEmpty) {
      totalAmount = order.items!.fold<int>(
        0,
        (sum, item) {
          final itemTotal = AmountParser.parse(item.totalPrice);
          print('   + item: ${item.productName} = $itemTotal');
          return sum + itemTotal;
        },
      );
      print('   Calculated total from items: $totalAmount');
    }

    final tableName = order.table?.name ??
        (order.table?.tableNumber != null
            ? 'Meja ${order.table!.tableNumber}'
            : null);

    // Format order type untuk display
    final orderTypeDisplay = order.operationMode == 'dine_in'
        ? 'Dine In'
        : order.operationMode == 'takeaway'
            ? 'Take Away'
            : 'N/A';

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => OpenBillDetailDialog(
            order: order,
            onContinue: () {
              // Close the list dialog first
              Navigator.pop(context);
              // Then call the callback
              widget.onContinue?.call(order);
            },
            onPay: () {
              // Close the list dialog first
              Navigator.pop(context);
              // Then call the callback
              widget.onPay?.call(order);
            },
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyLightActive, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totalAmount.currencyFormatRp,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            order.orderNumber ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey,
                            ),
                          ),
                          if (tableName != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tableName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: order.operationMode == 'dine_in'
                        ? AppColors.primaryLight
                        : AppColors.successLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    orderTypeDisplay,
                    style: TextStyle(
                      color: order.operationMode == 'dine_in'
                          ? AppColors.primary
                          : AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (order.items != null && order.items!.isNotEmpty) ...[
              const Divider(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items!.take(3).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.productName ?? 'N/A',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (order.items!.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+ ${order.items!.length - 3} items lainnya',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
