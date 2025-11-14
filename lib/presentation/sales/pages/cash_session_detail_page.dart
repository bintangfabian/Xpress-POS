import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/date_time_ext.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/data/dataoutputs/print_dataoutputs.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/cash_session_response_model.dart';
import 'package:xpress/presentation/sales/blocs/cash_session_history/cash_session_history_bloc.dart';
import 'package:xpress/presentation/sales/blocs/cash_session_history/cash_session_history_event.dart';
import 'package:xpress/presentation/sales/blocs/cash_session_history/cash_session_history_state.dart';

class CashSessionDetailPage extends StatefulWidget {
  final String sessionId;

  const CashSessionDetailPage({
    super.key,
    required this.sessionId,
  });

  @override
  State<CashSessionDetailPage> createState() => _CashSessionDetailPageState();
}

class _CashSessionDetailPageState extends State<CashSessionDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<CashSessionHistoryBloc>().add(
          GetCashSessionDetail(sessionId: widget.sessionId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kas Harian'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocBuilder<CashSessionHistoryBloc, CashSessionHistoryState>(
        builder: (context, state) {
          if (state is CashSessionHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CashSessionHistoryError) {
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.danger),
                      const SpaceHeight(16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                      const SpaceHeight(16),
                      Button.filled(
                        onPressed: _loadData,
                        label: 'Coba Lagi',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is CashSessionDetailSuccess) {
            final session = state.session;
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(session),
                    const SpaceHeight(16),
                    _buildStatusSection(session),
                    const SpaceHeight(16),
                    _buildSummarySection(session),
                    const SpaceHeight(16),
                    _buildExpenseList(session),
                    const SpaceHeight(16),
                    _buildPrintButton(session),
                    const SpaceHeight(16),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Memuat data...'));
        },
      ),
    );
  }

  Widget _buildHeaderSection(CashSessionData session) {
    final isOpen = session.status == 'open';
    final statusColor = isOpen ? AppColors.success : AppColors.primary;
    final statusText = isOpen ? 'BUKA' : 'TUTUP';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sesi Kas Harian',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: statusColor.withOpacity(0.1),
                side: BorderSide(color: statusColor.withOpacity(0.4)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (session.openedAt != null) ...[
            _infoRow('Dibuka pada', _formatDateTime(session.openedAt)),
            const SizedBox(height: 8),
          ],
          if (session.closedAt != null) ...[
            _infoRow('Ditutup pada', _formatDateTime(session.closedAt)),
            const SizedBox(height: 8),
          ],
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              'Catatan Shift',
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              session.notes ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection(CashSessionData session) {
    return _section(
      title: 'Status Shift',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('ID Sesi', session.id ?? '-'),
          if (session.userId != null) ...[
            const SizedBox(height: 8),
            _infoRow('User ID', session.userId ?? '-'),
          ],
          if (session.storeId != null) ...[
            const SizedBox(height: 8),
            _infoRow('Store ID', session.storeId ?? '-'),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarySection(CashSessionData session) {
    final isOpen = session.status == 'open';
    final expectedBalance =
        session.openingBalance + session.cashSales - session.cashExpenses;
    final int? closingBalance = session.closingBalance;
    final int? variance = isOpen
        ? null
        : (closingBalance != null ? (closingBalance - expectedBalance) : null);

    return _section(
      title: 'Ringkasan Kas Harian',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _summaryTile('Saldo Awal', session.openingBalance.currencyFormatRp),
          _summaryTile('Penjualan Tunai', session.cashSales.currencyFormatRp,
              valueColor: AppColors.success),
          _summaryTile('Pengeluaran', session.cashExpenses.currencyFormatRp,
              valueColor: AppColors.danger),
          _summaryTile(
            'Saldo Ekspektasi',
            expectedBalance.currencyFormatRp,
          ),
          _summaryTile(
            'Saldo Fisik',
            closingBalance != null ? closingBalance.currencyFormatRp : '-',
          ),
          _summaryTile(
            'Selisih',
            variance != null ? variance.currencyFormatRp : '-',
            valueColor: variance == null
                ? AppColors.grey
                : variance == 0
                    ? AppColors.success
                    : (variance > 0 ? Colors.green : AppColors.danger),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(CashSessionData session) {
    final expenses = List<CashExpense>.from(session.expenses ?? [])
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return _section(
      title: 'Pengeluaran Tercatat',
      child: expenses.isEmpty
          ? const Text(
              'Belum ada pengeluaran yang dicatat pada shift ini.',
              style: TextStyle(color: AppColors.grey),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greyLightActive.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.description ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if ((expense.category?.isNotEmpty ?? false)) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Kategori: ${expense.category}',
                                style: const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(expense.createdAt),
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        expense.amount.currencyFormatRp,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: expenses.length,
            ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SpaceHeight(12),
          child,
        ],
      ),
    );
  }

  Widget _summaryTile(String title, String value, {Color? valueColor}) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyLightActive.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPrintButton(CashSessionData session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Button.filled(
        onPressed: () => _printReport(session),
        label: 'Print Laporan',
        color: AppColors.primary,
        icon: Assets.icons.printer.svg(
          height: 20,
          width: 20,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Future<void> _printReport(CashSessionData session) async {
    try {
      final sizeReceipt = await AuthLocalDataSource().getSizeReceipt();
      final paperSize = int.tryParse(sizeReceipt) ?? 58;

      final printValue = await PrintDataoutputs.instance.printCashSessionReport(
        session: session,
        paperSize: paperSize,
      );

      final bool connectionStatus =
          await PrintBluetoothThermal.connectionStatus;
      if (!connectionStatus) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Printer tidak terhubung. Silakan hubungkan printer terlebih dahulu.'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }

      await PrintBluetoothThermal.writeBytes(printValue);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dicetak'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencetak laporan: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime? date) =>
      date == null ? '-' : date.toFormattedDate3();
}
