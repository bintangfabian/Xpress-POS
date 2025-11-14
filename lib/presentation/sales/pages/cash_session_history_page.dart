import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/date_time_ext.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/data/models/response/cash_session_response_model.dart';
import 'package:xpress/data/datasources/sales_remote_datasource.dart';
import 'package:xpress/presentation/sales/blocs/cash_session_history/cash_session_history_bloc.dart';
import 'package:xpress/presentation/sales/blocs/cash_session_history/cash_session_history_event.dart';
import 'package:xpress/presentation/sales/blocs/cash_session_history/cash_session_history_state.dart';
import 'package:xpress/presentation/sales/pages/cash_session_detail_page.dart';

class CashSessionHistoryPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const CashSessionHistoryPage({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<CashSessionHistoryPage> createState() => _CashSessionHistoryPageState();
}

class _CashSessionHistoryPageState extends State<CashSessionHistoryPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(CashSessionHistoryPage oldWidget) {
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

    context.read<CashSessionHistoryBloc>().add(
          GetCashSessions(
            startDate: startDateStr,
            endDate: endDateStr,
          ),
        );
  }

  void _navigateToDetail(CashSessionData session) {
    final dataSource = SalesRemoteDataSource();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => CashSessionHistoryBloc(dataSource)
            ..add(GetCashSessionDetail(sessionId: session.id ?? '')),
          child: CashSessionDetailPage(sessionId: session.id ?? ''),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CashSessionHistoryBloc, CashSessionHistoryState>(
      builder: (context, state) {
        if (state is CashSessionHistoryInitial) {
          // Auto load data on initial state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadData();
          });
          return const Center(child: CircularProgressIndicator());
        } else if (state is CashSessionHistoryLoading) {
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
        } else if (state is CashSessionsSuccess) {
          final sessions = state.sessions;

          if (sessions.isEmpty) {
            final dateRangeText = widget.startDate.year ==
                        widget.endDate.year &&
                    widget.startDate.month == widget.endDate.month &&
                    widget.startDate.day == widget.endDate.day
                ? widget.startDate.toFormattedDateShort()
                : '${widget.startDate.toFormattedDateShort()} - ${widget.endDate.toFormattedDateShort()}';

            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.database.svg(
                          width: 120,
                          height: 120,
                          colorFilter: const ColorFilter.mode(
                              AppColors.grey, BlendMode.srcIn),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Tidak Ada Data',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada data dari $dateRangeText',
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Sort by openedAt descending (newest first)
          final sortedSessions = List<CashSessionData>.from(sessions)
            ..sort((a, b) {
              final aDate =
                  a.openedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bDate =
                  b.openedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bDate.compareTo(aDate);
            });

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ContentTitle('Riwayat Kas Harian'),
                  const SpaceHeight(16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedSessions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final session = sortedSessions[index];
                      return _CashSessionCard(
                        session: session,
                        onTap: () => _navigateToDetail(session),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: Text('State tidak dikenali'));
      },
    );
  }
}

class _CashSessionCard extends StatelessWidget {
  final CashSessionData session;
  final VoidCallback onTap;

  const _CashSessionCard({
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = session.status == 'open';
    final statusColor = isOpen ? AppColors.success : AppColors.primary;
    final statusText = isOpen ? 'BUKA' : 'TUTUP';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.greyLightActive.withOpacity(0.3),
          ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(session.openedAt),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (session.openedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(session.openedAt!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  backgroundColor: statusColor.withOpacity(0.1),
                  side: BorderSide(color: statusColor.withOpacity(0.4)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'Saldo Awal',
                    value: session.openingBalance.currencyFormatRp,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoItem(
                    label: 'Penjualan',
                    value: session.cashSales.currencyFormatRp,
                    valueColor: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'Pengeluaran',
                    value: session.cashExpenses.currencyFormatRp,
                    valueColor: AppColors.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoItem(
                    label: isOpen ? 'Ekspektasi' : 'Saldo Akhir',
                    value: isOpen
                        ? (session.openingBalance +
                                session.cashSales -
                                session.cashExpenses)
                            .currencyFormatRp
                        : (session.closingBalance?.currencyFormatRp ?? '-'),
                    valueColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (session.status == 'closed' && session.variance != 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: session.variance > 0
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      session.variance > 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 16,
                      color: session.variance > 0
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selisih: ${session.variance.currencyFormatRp}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: session.variance > 0
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Lihat Detail',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return date.toFormattedDate2();
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.primary,
          ),
        ),
      ],
    );
  }
}
