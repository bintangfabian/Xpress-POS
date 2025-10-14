import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/constants/borders.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:xpress/presentation/home/dialogs/cash_success_dialog.dart';
import 'package:xpress/presentation/home/dialogs/discount_dialog.dart';
import 'package:xpress/presentation/home/dialogs/member_dialog.dart';
import 'package:xpress/presentation/home/dialogs/table_select_dialog.dart';
import 'package:xpress/presentation/home/dialogs/tax_dialog.dart';
import 'package:xpress/presentation/home/dialogs/service_dialog.dart';
import 'package:xpress/data/models/response/discount_response_model.dart';
import 'package:xpress/presentation/home/dialogs/qris_confirm_dialog.dart';
import 'package:xpress/presentation/home/dialogs/qris_success_dialog.dart';
import 'package:xpress/presentation/home/pages/dashboard_page.dart';
// removed old payment_qris_dialog usage
// dialogs moved to separated files
import 'package:xpress/presentation/home/pages/home_page.dart';
import 'package:xpress/presentation/home/widgets/custom_button.dart';
import 'package:xpress/presentation/home/widgets/home_title.dart';
import 'package:xpress/presentation/home/widgets/order_menu.dart';
import 'package:xpress/presentation/table/blocs/get_table/get_table_bloc.dart';
import '../../../core/components/components.dart';
import 'package:xpress/presentation/home/widgets/custom_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';

class ConfirmPaymentPage extends StatefulWidget {
  final bool isTable;
  final TableModel? table;
  final String orderType; // dinein / takeaway

  const ConfirmPaymentPage({
    super.key,
    required this.isTable,
    this.table,
    required this.orderType,
  });

  @override
  State<ConfirmPaymentPage> createState() => _ConfirmPaymentPageState();
}

class _ConfirmPaymentPageState extends State<ConfirmPaymentPage> {
  final noteController = TextEditingController();
  final customerController = TextEditingController();
  final totalPayController = TextEditingController();
  final Map<int, List<String>> _selectedVariants = {};
  bool isCash = true;
  int? _selectedTableNumber;

  // Helper method to parse table number from String to int
  int? _parseTableNumber(String? tableNumber) {
    if (tableNumber == null || tableNumber.isEmpty) return null;
    // Extract number from string like "T001" -> 1
    final numStr = tableNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numStr);
  }

  @override
  void initState() {
    super.initState();
    _selectedTableNumber = _parseTableNumber(widget.table?.tableNumber);
    // Rebuild when total pay changes to update Pay button enabled state and change value
    totalPayController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    customerController.dispose();
    totalPayController.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchMembers() async {
    try {
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/members?per_page=100');
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
        final map = jsonDecode(res.body);
        List items = [];
        if (map is Map && map['data'] is List) items = map['data'];
        return items
            .map((e) => (e['name'] ?? e['member_number'] ?? '-').toString())
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Discount>> _fetchDiscounts() async {
    try {
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/discounts?per_page=100');
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
        final map = jsonDecode(res.body);
        List items = [];
        if (map is Map && map['data'] is List) items = map['data'];
        return items
            .map((e) => Discount(
                  id: e['id'] is int ? e['id'] : int.tryParse('${e['id']}'),
                  name: e['name']?.toString(),
                  description: e['description']?.toString(),
                  type: (e['type'] ?? 'percentage').toString(),
                  value: (e['value'] ?? '0').toString(),
                ))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  int _calculateCartTotal() {
    final state = context.read<CheckoutBloc>().state;
    return state.maybeWhen(
      loaded: (products, discountModel, discount, discountAmount, tax,
              serviceCharge, totalQuantity, totalPrice, draftName, orderType) =>
          products
              .map(
                  (e) => (e.product.price?.toIntegerFromText ?? 0) * e.quantity)
              .fold(0, (a, b) => a + b),
      orElse: () => 0,
    );
  }

  int _currentTotalPay() {
    return totalPayController.text.toIntegerFromText;
  }

  void _addToTotalPay(int amount) {
    final current = _currentTotalPay();
    final updated = current + amount;
    totalPayController.text = updated.toString();
  }

  int _calculateDueTotal() {
    final state = context.read<CheckoutBloc>().state;
    return state.maybeWhen(
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
        orderType,
      ) {
        final subtotal = products
            .map((e) => (e.product.price?.toIntegerFromText ?? 0) * e.quantity)
            .fold(0, (a, b) => a + b);
        final discAmt = _computeDiscountAmount(subtotal, discountModel);
        final taxAmt = _computeTaxAmount(subtotal, tax);
        final serviceAmt = _computeServiceAmount(subtotal, serviceCharge);
        final total = subtotal - discAmt + taxAmt + serviceAmt;
        return total.ceil();
      },
      orElse: () => 0,
    );
  }

  int _calculateChange() {
    final paid = _currentTotalPay();
    final due = _calculateDueTotal();
    final change = paid - due;
    return change > 0 ? change : 0;
  }

  String get _orderTypeLabel {
    switch (widget.orderType.toLowerCase()) {
      case 'dinein':
        return 'Dine In';
      case 'takeaway':
        return 'Take Away';
      default:
        return widget.orderType;
    }
  }

  int _computeDiscountAmount(int subtotal, Discount? model) {
    if (model == null) return 0;
    final val = int.tryParse(model.value ?? '0') ?? 0;
    if ((model.type ?? '').toLowerCase() == 'percent') {
      final amt = (subtotal * (val / 100)).floor();
      return amt.clamp(0, subtotal);
    }
    // fixed amount
    return val.clamp(0, subtotal);
  }

  int _computeTaxAmount(int subtotal, int taxPercent) {
    if (taxPercent <= 0) return 0;
    return (subtotal * (taxPercent / 100)).floor();
  }

  int _computeServiceAmount(int subtotal, int servicePercent) {
    if (servicePercent <= 0) return 0;
    return (subtotal * (servicePercent / 100)).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primaryLight,
      body: Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 6.0, right: 6.0),
        child: Row(
          children: [
            // ✅ Konten utama
            Expanded(
              child: Row(
                children: [
                  // Detail pesanan
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: _buildOrderDetail(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Detail transaksi
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Detail Transaksi
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: _buildTransactionDetail(),
                          ),
                          SizedBox(height: 6),
                          // Pembayaran
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Pembayaran",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SpaceHeight(12),

                                // 🔹 Tombol Tunai & QRIS
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        svgIcon: Assets.icons.cash,
                                        filled: isCash,
                                        label: "Tunai",
                                        onPressed: () {
                                          setState(() {
                                            isCash = true;
                                          });
                                        },
                                      ),
                                    ),
                                    const SpaceWidth(8),
                                    Expanded(
                                      child: CustomButton(
                                        svgIcon: Assets.icons.qr,
                                        filled: !isCash,
                                        label: "QRIS",
                                        onPressed: () {
                                          setState(() {
                                            isCash = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SpaceHeight(12),

                                // 🔹 TextField Total + Tombol Uang Pas
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 46,
                                        child: TextField(
                                          controller: totalPayController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: "Total Bayar",
                                            prefixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Assets.icons.payment.svg(
                                                  color: AppColors
                                                      .greyLightActive),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              borderSide: BorderSide(
                                                color: AppColors.grey,
                                                width: 1.0,
                                              ),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              borderSide: BorderSide(
                                                color: AppColors.primary,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 46,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          final total = _calculateDueTotal();
                                          totalPayController.text =
                                              total.toString();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          side: const BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                          minimumSize: const Size(120, 46),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(0),
                                              bottomLeft: Radius.circular(0),
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Uang Pas",
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SpaceHeight(12),

                                // 🔹 Tombol nominal
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        filled: false,
                                        label: "500",
                                        onPressed: () {
                                          _addToTotalPay(500);
                                        },
                                      ),
                                    ),
                                    const SpaceWidth(6),
                                    Expanded(
                                      child: CustomButton(
                                        filled: false,
                                        label: "1000",
                                        onPressed: () {
                                          _addToTotalPay(1000);
                                        },
                                      ),
                                    ),
                                    const SpaceWidth(6),
                                    Expanded(
                                      child: CustomButton(
                                        filled: false,
                                        label: "5000",
                                        onPressed: () {
                                          _addToTotalPay(5000);
                                        },
                                      ),
                                    ),
                                    const SpaceWidth(6),
                                    Expanded(
                                      child: CustomButton(
                                        filled: false,
                                        label: "50000",
                                        onPressed: () {
                                          _addToTotalPay(50000);
                                        },
                                      ),
                                    ),
                                    const SpaceWidth(6),
                                    Expanded(
                                      child: CustomButton(
                                        filled: false,
                                        label: "100000",
                                        onPressed: () {
                                          _addToTotalPay(100000);
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SpaceHeight(12),

                                // 🔹 Total Kembalian
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.greyLight,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Kembalian',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Builder(builder: (context) {
                                        final change = _calculateChange();
                                        return Text(
                                          change.currencyFormatRp,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                ),

                                const SpaceHeight(32),

                                // 🔹 Action Buttons
                                Row(
                                  children: [
                                    Button.outlined(
                                      width: 64,
                                      height: 64,
                                      color: AppColors.primaryLight,
                                      borderColor: AppColors.primary,
                                      padding: EdgeInsets.zero,
                                      icon: Assets.icons.backArrow.svg(
                                          color: AppColors.primary,
                                          height: 24,
                                          width: 24),
                                      onPressed: () {
                                        final checkoutBloc =
                                            context.read<CheckoutBloc>();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: checkoutBloc,
                                              child: DashboardPage(
                                                initialIndex: 0,
                                                selectedTable: widget.table,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SpaceWidth(8),
                                    Expanded(
                                      child: Builder(builder: (context) {
                                        final dueTotal = _calculateDueTotal();
                                        final isEnabled =
                                            _currentTotalPay() >= dueTotal &&
                                                dueTotal > 0;
                                        return CustomButton(
                                          height: 64,
                                          filled: true,
                                          svgIcon: Assets.icons.cash,
                                          label: 'Bayar',
                                          disabled: !isEnabled,
                                          onPressed: () async {
                                            if (!isEnabled) return;
                                            final total = _calculateDueTotal();
                                            final change = _calculateChange();
                                            if (isCash) {
                                              await showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) =>
                                                    CashSuccessDialog(
                                                  total: total,
                                                  change: change,
                                                  orderType: widget.orderType,
                                                  tableNumber:
                                                      _parseTableNumber(widget
                                                          .table?.tableNumber),
                                                ),
                                              );
                                            } else {
                                              await showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) =>
                                                    QrisConfirmDialog(
                                                  total: total,
                                                  change: change,
                                                  orderType: widget.orderType,
                                                  tableNumber:
                                                      _parseTableNumber(widget
                                                          .table?.tableNumber),
                                                  onAccepted: () async {
                                                    await showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (_) =>
                                                          QrisSuccessDialog(
                                                        total: total,
                                                        change: change,
                                                        orderType:
                                                            widget.orderType,
                                                        tableNumber:
                                                            _parseTableNumber(
                                                                widget.table
                                                                    ?.tableNumber),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Detail Pesanan
  Widget _buildOrderDetail() {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => _emptyOrder(),
          loaded: (products, _, __, ___, ____, _____, ______, _______, ________,
              _________) {
            if (products.isEmpty) {
              return _emptyOrder();
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsetsGeometry.only(bottom: 8),
                            child: const Text(
                              'Detail Pesanan',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                height: 37,
                                width: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.greyLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                    child: const Text(
                                  "#0001",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                )),
                              ),
                              const SizedBox(width: 12),
                              IntrinsicWidth(
                                child: Container(
                                  height: 37,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _orderTypeLabel,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if ((_selectedTableNumber ??
                                      _parseTableNumber(
                                          widget.table?.tableNumber)) !=
                                  null) ...[
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
                                      widget.table?.name ??
                                          "Meja ${_selectedTableNumber ?? _parseTableNumber(widget.table?.tableNumber) ?? ''}",
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      CustomButton(
                        width: 175,
                        height: 52,
                        svgIcon: Assets.icons.bill,
                        label: "Ubah Pesanan",
                        onPressed: () {
                          final checkoutBloc = context.read<
                              CheckoutBloc>(); // ✅ simpan dulu sebelum navigate

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value:
                                    checkoutBloc, // ✅ aman, ga pakai context lama
                                child:
                                    DashboardPage(), // atau HomePage sesuai flow kamu
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // 🔹 Header kolom
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 4,
                        child: Text(
                          "Menu",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Quantity",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Subtotal",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                // const Divider(),

                // 🔹 List pesanan
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

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: products.length + 1,
                            itemBuilder: (context, i) {
                              if (i < products.length) {
                                return OrderMenu(
                                  data: products[i],
                                );
                              } else {
                                // After the last product, show the "Detail Pesanan" section
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Detail Pesanan',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 130,
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller: noteController,
                                          maxLines: 5,
                                          decoration: InputDecoration(
                                            alignLabelWithHint: true,
                                            hintText:
                                                "Tambahkan Catatan Pesanan Jika Perlu",
                                            hintStyle: const TextStyle(
                                              color: AppColors.grey,
                                              fontSize: 16,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.all(12),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: const BorderSide(
                                                  color: AppColors.grey,
                                                  width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: const BorderSide(
                                                  color: AppColors.primary,
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _totalOrderPrice() {
    return BlocBuilder<CheckoutBloc, CheckoutState>(builder: (context, state) {
      return state.maybeWhen(
          orElse: () => _emptyOrder(),
          loaded: (
            products,
            discountModel,
            __,
            ___,
            tax,
            serviceCharge,
            ______,
            _______,
            ________,
            _________,
          ) {
            if (products.isEmpty) {
              return _emptyOrder();
            }
            final subtotal = products
                .map((e) =>
                    (e.product.price?.toIntegerFromText ?? 0) * e.quantity)
                .fold(0, (a, b) => a + b);
            final discAmt = _computeDiscountAmount(subtotal, discountModel);
            final taxAmt = _computeTaxAmount(subtotal, tax);
            final serviceAmt = _computeServiceAmount(subtotal, serviceCharge);
            final total = subtotal - discAmt + taxAmt + serviceAmt;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      total.currencyFormatRp,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    });
  }

  // 🔹 Detail Transaksi
  Widget _buildTransactionDetail() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detail Transaksi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SpaceHeight(16),

          // 🔹 Nama Customer dengan icon user
          TextFormField(
            controller: customerController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: AppColors.primary),
              hintText: "Nama Customer",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          const SpaceHeight(16),

          // 🔹 Tombol Membership & Nomor Meja
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  svgIcon: Assets.icons.user,
                  filled: false,
                  label: "Membership",
                  onPressed: () async {
                    // fetch members from API
                    final list = await _fetchMembers();
                    final res = await showDialog<String>(
                      context: context,
                      builder: (_) => MemberDialog(
                        members: list,
                        initial: customerController.text,
                      ),
                    );
                    if (res != null && res.isNotEmpty) {
                      customerController.text = res;
                    }
                  },
                ),
              ),
              const SpaceWidth(8),
              Expanded(
                child: CustomButton(
                  svgIcon: Assets.icons.table,
                  filled: false,
                  label: "Nomor Meja",
                  onPressed: () async {
                    final bloc = context.read<GetTableBloc>();
                    bloc.add(const GetTableEvent.getTables());
                    int tableCount = bloc.state.maybeWhen(
                      success: (tables) => tables.length,
                      orElse: () => 0,
                    );
                    if (tableCount == 0) {
                      final state = await bloc.stream.firstWhere(
                        (s) => s.maybeWhen(
                            success: (_) => true, orElse: () => false),
                      );
                      tableCount = state.maybeWhen(
                        success: (tables) => tables.length,
                        orElse: () => 0,
                      );
                    }
                    final selected = await showDialog<int>(
                      context: context,
                      builder: (_) => TableSelectDialog(
                        initialTable: _selectedTableNumber ??
                            _parseTableNumber(widget.table?.tableNumber) ??
                            0,
                        tableCount: tableCount,
                      ),
                    );
                    if (selected != null) {
                      setState(() => _selectedTableNumber = selected);
                    }
                  },
                ),
              ),
            ],
          ),

          const SpaceHeight(16),

          // 🔹 Tombol Diskon, Pajak, Layanan
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  svgIcon: Assets.icons.percentange,
                  filled: false,
                  label: "Diskon",
                  onPressed: () async {
                    final discounts = await _fetchDiscounts();
                    final selected = await showDialog<Discount>(
                      context: context,
                      builder: (_) => DiscountDialog(discounts: discounts),
                    );
                    if (selected != null) {
                      context
                          .read<CheckoutBloc>()
                          .add(CheckoutEvent.addDiscount(selected));
                    }
                  },
                ),
              ),
              const SpaceWidth(8),
              Expanded(
                child: CustomButton(
                  svgIcon: Assets.icons.task,
                  filled: false,
                  label: "Pajak",
                  onPressed: () async {
                    final selected = await showDialog<int>(
                      context: context,
                      builder: (_) => const TaxDialog(),
                    );
                    if (selected != null) {
                      context
                          .read<CheckoutBloc>()
                          .add(CheckoutEvent.addTax(selected));
                    }
                  },
                ),
              ),
              const SpaceWidth(8),
              Expanded(
                child: CustomButton(
                  svgIcon: Assets.icons.paste,
                  filled: false,
                  label: "Layanan",
                  onPressed: () async {
                    final selected = await showDialog<int>(
                      context: context,
                      builder: (_) => const ServiceDialog(),
                    );
                    if (selected != null) {
                      context
                          .read<CheckoutBloc>()
                          .add(CheckoutEvent.addServiceCharge(selected));
                    }
                  },
                ),
              ),
            ],
          ),

          const SpaceHeight(24),

          // 🔹 Breakdown harga (dinamis)
          BlocBuilder<CheckoutBloc, CheckoutState>(
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _priceRow("Subtotal", "Rp0"),
                    _priceRow("Diskon", "-Rp0"),
                    _priceRow("Layanan", "Rp0"),
                    _priceRow("Pajak", "Rp0"),
                    _totalPriceRow("Total", "Rp0"),
                  ],
                ),
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
                  final subtotal = products
                      .map((e) =>
                          (e.product.price?.toIntegerFromText ?? 0) *
                          e.quantity)
                      .fold(0, (a, b) => a + b);
                  final discAmt =
                      _computeDiscountAmount(subtotal, discountModel);
                  final taxAmt = _computeTaxAmount(subtotal, tax);
                  final serviceAmt =
                      _computeServiceAmount(subtotal, serviceCharge);
                  final total = subtotal - discAmt + taxAmt + serviceAmt;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _priceRow("Subtotal", subtotal.currencyFormatRp),
                      _priceRow("Diskon", "-${discAmt.currencyFormatRp}"),
                      _priceRow("Layanan", serviceAmt.currencyFormatRp),
                      _priceRow("Pajak", taxAmt.currencyFormatRp),
                      const SizedBox(
                        height: 8,
                      ),
                      _totalPriceRow("Total", total.currencyFormatRp),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value,
      {bool bold = false, bool highlight = false}) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalPriceRow(String label, String value,
      {bool bold = false, bool highlight = false}) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyOrder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icons.bill.svg(width: 120, height: 120, color: AppColors.grey),
          const SpaceHeight(24),
          Column(
            children: [
              Text(
                "Silakan Pilih Tipe Order",
                style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                "Tambahkan Pesanan",
                style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
