import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/presentation/sales/blocs/sales_recap/sales_recap_bloc.dart';
import 'package:xpress/presentation/sales/blocs/sales_recap/sales_recap_event.dart';
import 'package:xpress/presentation/sales/blocs/sales_recap/sales_recap_state.dart';

class SalesRecapPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const SalesRecapPage({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<SalesRecapPage> createState() => _SalesRecapPageState();
}

class _SalesRecapPageState extends State<SalesRecapPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(SalesRecapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _loadData();
    }
  }

  void _loadData() {
    final startDateStr =
        '${widget.startDate.year}-${widget.startDate.month.toString().padLeft(2, '0')}-${widget.startDate.day.toString().padLeft(2, '0')}';
    final endDateStr =
        '${widget.endDate.year}-${widget.endDate.month.toString().padLeft(2, '0')}-${widget.endDate.day.toString().padLeft(2, '0')}';

    context.read<SalesRecapBloc>().add(
          GetSalesRecap(
            startDate: startDateStr,
            endDate: endDateStr,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesRecapBloc, SalesRecapState>(
      builder: (context, state) {
        if (state is SalesRecapInitial) {
          return const Center(child: Text('Memuat data...'));
        } else if (state is SalesRecapLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SalesRecapError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.danger),
                const SpaceHeight(16),
                Text(state.message),
              ],
            ),
          );
        } else if (state is SalesRecapSuccess) {
          final data = state.data;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ContentTitle('Rekap Penjualan'),
                const SpaceHeight(16),
                _section(
                  title: 'Transaksi per Metode Pembayaran',
                  child: Column(
                    children: [
                      ...data.paymentMethods.map((pm) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _TripleRow(
                              left: _formatPaymentMethod(pm.paymentMethod),
                              middle: '${pm.count}x',
                              right: pm.totalAmount.currencyFormatRp,
                            ),
                          )),
                      const SpaceHeight(12),
                      const Divider(color: AppColors.primaryLightActive),
                      const SpaceHeight(8),
                      _TotalRow(
                        label: 'Total transaksi',
                        amount: data.totals.grandTotal.currencyFormatRp,
                      ),
                    ],
                  ),
                ),
                _section(
                  title: 'Penerimaan di kasir',
                  child: Column(
                    children: [
                      _TripleRow(
                        left: 'Tunai',
                        middle: '${_getCashCount(data.paymentMethods)}x',
                        right: data.totals.totalCash.currencyFormatRp,
                      ),
                      const SpaceHeight(8),
                      _TripleRow(
                        left: 'Non - Tunai',
                        middle: '${_getNonCashCount(data.paymentMethods)}x',
                        right: data.totals.totalNonCash.currencyFormatRp,
                      ),
                      const SpaceHeight(12),
                      const Divider(color: AppColors.primaryLightActive),
                      const SpaceHeight(8),
                      _TotalRow(
                        label: 'Total penerimaan di kasir',
                        amount: data.totals.grandTotal.currencyFormatRp,
                      ),
                    ],
                  ),
                ),
                if (data.operationModes.isNotEmpty)
                  _section(
                    title: 'Transaksi per Mode Operasi',
                    child: Column(
                      children: [
                        ...data.operationModes.map((om) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _TripleRow(
                                left: _formatOperationMode(om.operationMode),
                                middle: '${om.count}x',
                                right: om.totalAmount.currencyFormatRp,
                              ),
                            )),
                        const SpaceHeight(12),
                        const Divider(color: AppColors.primaryLightActive),
                        const SpaceHeight(8),
                        _TotalRow(
                          label: 'Total',
                          amount: data.totals.grandTotal.currencyFormatRp,
                        ),
                      ],
                    ),
                  ),
                _section(
                  title: 'Total',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LabeledAmount(
                        label: 'Total penerimaan sistem',
                        helper: '(Total kas + Total transaksi penjualan)',
                        amount: data.totals.grandTotal.currencyFormatRp,
                      ),
                      const SpaceHeight(12),
                      _LabeledAmount(
                        label: 'Total transaksi',
                        helper: '(Jumlah semua transaksi)',
                        amount: '${data.totals.totalTransactions}',
                        amountColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('State tidak dikenali'));
      },
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'qris':
        return 'QRIS';
      case 'debit_card':
      case 'debit card':
        return 'Kartu Debit';
      case 'credit_card':
      case 'credit card':
        return 'Kartu Kredit';
      case 'transfer':
        return 'Transfer';
      default:
        return method;
    }
  }

  String _formatOperationMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'dine_in':
      case 'dine in':
        return 'Dine In';
      case 'take_away':
      case 'takeaway':
        return 'Take Away';
      case 'delivery':
        return 'Delivery';
      default:
        return mode;
    }
  }

  int _getCashCount(List paymentMethods) {
    int count = 0;
    for (var pm in paymentMethods) {
      if (pm.paymentMethod.toLowerCase() == 'cash') {
        count = pm.count;
      }
    }
    return count;
  }

  int _getNonCashCount(List paymentMethods) {
    int count = 0;
    for (var pm in paymentMethods) {
      if (pm.paymentMethod.toLowerCase() != 'cash') {
        count += pm.count as int;
      }
    }
    return count;
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SpaceHeight(12),
          child,
        ],
      ),
    );
  }
}

class _TripleRow extends StatelessWidget {
  final String left;
  final String middle;
  final String right;
  const _TripleRow({
    required this.left,
    required this.middle,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(left, style: const TextStyle(color: Colors.black)),
        ),
        Expanded(
          flex: 1,
          child: Text(middle, textAlign: TextAlign.left),
        ),
        Expanded(
          flex: 2,
          child: Text(right, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String amount;
  const _TotalRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _LabeledAmount extends StatelessWidget {
  final String label;
  final String helper;
  final String amount;
  final Color amountColor;
  const _LabeledAmount({
    required this.label,
    required this.helper,
    required this.amount,
    this.amountColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                helper,
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(fontWeight: FontWeight.w700, color: amountColor),
        ),
      ],
    );
  }
}
