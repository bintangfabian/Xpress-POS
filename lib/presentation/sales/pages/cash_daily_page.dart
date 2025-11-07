import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/presentation/sales/blocs/cash_session/cash_session_bloc.dart';
import 'package:xpress/presentation/sales/blocs/cash_session/cash_session_event.dart';
import 'package:xpress/presentation/sales/blocs/cash_session/cash_session_state.dart';

class CashDailyPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const CashDailyPage({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<CashDailyPage> createState() => _CashDailyPageState();
}

class _CashDailyPageState extends State<CashDailyPage> {
  final TextEditingController _saldoAwalCtrl = TextEditingController();
  final TextEditingController _pengeluaranCtrl = TextEditingController();
  final TextEditingController _keteranganCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCashSession();
  }

  @override
  void didUpdateWidget(CashDailyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _loadCashSession();
    }
  }

  void _loadCashSession() {
    context.read<CashSessionBloc>().add(GetCurrentCashSession());
  }

  @override
  void dispose() {
    _saldoAwalCtrl.dispose();
    _pengeluaranCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CashSessionBloc, CashSessionState>(
      builder: (context, state) {
        if (state is CashSessionInitial) {
          return const Center(child: Text('Memuat data...'));
        } else if (state is CashSessionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CashSessionError) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ContentTitle('Rekap Kas'),
                const SpaceHeight(16),
                _buildNoSessionView(context),
              ],
            ),
          );
        } else if (state is CashSessionSuccess) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ContentTitle('Rekap Kas'),
                const SpaceHeight(16),
                if (state.data.status == 'closed')
                  _buildClosedSessionView(state.data, context)
                else
                  _buildActiveSessionView(state.data, context),
              ],
            ),
          );
        }
        return const Center(child: Text('State tidak dikenali'));
      },
    );
  }

  Widget _buildNoSessionView(BuildContext context) {
    return _section(
      title: 'Buka Kas Harian',
      child: Column(
        children: [
          const Text(
            'Belum ada sesi kas aktif. Buka sesi kas untuk memulai.',
            style: TextStyle(color: AppColors.grey),
          ),
          const SpaceHeight(12),
          CustomTextField(
            controller: _saldoAwalCtrl,
            label: 'Saldo awal (Rp)',
            keyboardType: TextInputType.number,
          ),
          const SpaceHeight(12),
          Button.filled(
            onPressed: () {
              final openingBalance =
                  int.tryParse(_saldoAwalCtrl.text.replaceAll('.', '')) ?? 0;
              if (openingBalance > 0) {
                context
                    .read<CashSessionBloc>()
                    .add(OpenCashSession(openingBalance));
                _saldoAwalCtrl.clear();
              }
            },
            height: 48,
            label: 'Buka Sesi Kas',
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionView(dynamic data, BuildContext context) {
    final expectedBalance =
        data.openingBalance + data.cashSales - data.cashExpenses;

    return Column(
      children: [
        _section(
          title: 'Tambah pengeluaran',
          child: Column(
            children: [
              CustomTextField(
                controller: _pengeluaranCtrl,
                label: 'Jumlah pengeluaran (Rp)',
                keyboardType: TextInputType.number,
              ),
              const SpaceHeight(12),
              CustomTextField(
                controller: _keteranganCtrl,
                label: 'Tambah keterangan (Optional)',
              ),
              const SpaceHeight(12),
              Button.filled(
                onPressed: () {
                  final amount =
                      int.tryParse(_pengeluaranCtrl.text.replaceAll('.', '')) ??
                          0;
                  if (amount > 0 && _keteranganCtrl.text.isNotEmpty) {
                    context.read<CashSessionBloc>().add(
                          AddCashExpense(
                            sessionId: data.id ?? '',
                            amount: amount,
                            description: _keteranganCtrl.text,
                          ),
                        );
                    _pengeluaranCtrl.clear();
                    _keteranganCtrl.clear();
                  }
                },
                height: 48,
                label: 'Tambah pengeluaran',
              ),
            ],
          ),
        ),
        _section(
          title: 'Ringkasan kas harian',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _rowSummary('Saldo awal:', data.openingBalance),
              const SpaceHeight(8),
              _rowSummary('Penjualan tunai:', data.cashSales),
              const SpaceHeight(8),
              _rowSummary('Pengeluaran:', data.cashExpenses),
              const SpaceHeight(8),
              const Divider(color: AppColors.primaryLightActive),
              const SpaceHeight(8),
              _rowSummary('Saldo yang diharapkan:', expectedBalance),
              const SpaceHeight(8),
              if (data.closingBalance != null) ...[
                _rowSummary('Saldo akhir (fisik):', data.closingBalance!),
                const SpaceHeight(8),
                _rowSummary('Selisih:', data.variance,
                    color: data.variance == 0
                        ? AppColors.primary
                        : data.variance > 0
                            ? Colors.green
                            : AppColors.danger),
              ],
            ],
          ),
        ),
        if (data.expenses != null && data.expenses!.isNotEmpty)
          _section(
            title: 'Daftar Pengeluaran',
            child: Column(
              children: data.expenses!
                  .map<Widget>((expense) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.description ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  if (expense.category != null)
                                    Text(
                                      expense.category!,
                                      style: const TextStyle(
                                          fontSize: 12, color: AppColors.grey),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              expense.amount.currencyFormatRp,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.danger),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildClosedSessionView(dynamic data, BuildContext context) {
    return _section(
      title: 'Sesi Kas Ditutup',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sesi kas telah ditutup.',
            style: TextStyle(color: AppColors.grey),
          ),
          const SpaceHeight(12),
          _rowSummary('Saldo awal:', data.openingBalance),
          const SpaceHeight(8),
          _rowSummary('Penjualan tunai:', data.cashSales),
          const SpaceHeight(8),
          _rowSummary('Pengeluaran:', data.cashExpenses),
          const SpaceHeight(8),
          _rowSummary('Saldo akhir:', data.closingBalance ?? 0),
          const SpaceHeight(8),
          _rowSummary('Selisih:', data.variance,
              color: data.variance == 0
                  ? AppColors.primary
                  : data.variance > 0
                      ? Colors.green
                      : AppColors.danger),
        ],
      ),
    );
  }

  Widget _rowSummary(String label, int value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value.currencyFormatRp,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
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
