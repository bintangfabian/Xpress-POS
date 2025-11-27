import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/date_time_ext.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/widgets/offline_info_banner.dart';
import 'package:xpress/core/widgets/print_button.dart';
import 'package:xpress/data/dataoutputs/print_dataoutputs.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/cash_session_response_model.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';
import 'package:xpress/presentation/sales/blocs/cash_session_history/cash_session_history_bloc.dart';
import 'package:xpress/presentation/sales/blocs/cash_session_history/cash_session_history_event.dart';
import 'package:xpress/presentation/sales/blocs/cash_session_history/cash_session_history_state.dart';

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
  String? _selectedSessionId;
  CashSessionData? _selectedSession;

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
      // Reset selected session when date changes
      _selectedSessionId = null;
      _selectedSession = null;
      _loadData();
    }
  }

  void _loadData() {
    // Format start date as beginning of day
    final startDateStr =
        '${widget.startDate.year}-${widget.startDate.month.toString().padLeft(2, '0')}-${widget.startDate.day.toString().padLeft(2, '0')}';
    // Format end date to include full day (23:59:59) to ensure all sessions opened on that day are included
    final endDateStr =
        '${widget.endDate.year}-${widget.endDate.month.toString().padLeft(2, '0')}-${widget.endDate.day.toString().padLeft(2, '0')} 23:59:59';

    context.read<CashSessionHistoryBloc>().add(
          GetCashSessions(
            startDate: startDateStr,
            endDate: endDateStr,
          ),
        );
  }

  void _showDetail(CashSessionData session) {
    setState(() {
      _selectedSessionId = session.id;
      _selectedSession = session;
    });
    // Load detail data
    context.read<CashSessionHistoryBloc>().add(
          GetCashSessionDetail(sessionId: session.id ?? ''),
        );
  }

  void _hideDetail() {
    setState(() {
      _selectedSessionId = null;
      _selectedSession = null;
    });
    // Reload data to show list again
    _loadData();
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
          // Show loading only if not showing detail
          if (_selectedSessionId != null) {
            // Keep showing detail while loading
            return _buildContentWithDetail(state);
          }
          return const Center(child: CircularProgressIndicator());
        } else if (state is CashSessionHistoryError) {
          return BlocBuilder<OnlineCheckerBloc, OnlineCheckerState>(
            builder: (context, onlineState) {
              final isOnline = onlineState.maybeWhen(
                  online: () => true, orElse: () => false);
              if (!isOnline) {
                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: const Center(
                      child: OfflineInfoBanner(
                        customMessage:
                            'Data riwayat kas harian tidak tersedia dalam mode offline. '
                            'Silahkan hubungkan kembali koneksi internet.',
                      ),
                    ),
                  ),
                );
              }
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
            },
          );
        } else if (state is CashSessionsSuccess) {
          final sessions = state.sessions;

          // If showing detail, show detail view
          if (_selectedSessionId != null) {
            return _buildContentWithDetail(state);
          }

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
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ContentTitle('Riwayat Kas Harian'),
                    const SpaceHeight(16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
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
                  ],
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
                        onTap: () => _showDetail(session),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (state is CashSessionDetailSuccess) {
          // Update selected session with detail data
          if (_selectedSessionId == state.session.id) {
            _selectedSession = state.session;
          }
          return _buildContentWithDetail(state);
        }
        return const Center(child: Text('State tidak dikenali'));
      },
    );
  }

  Widget _buildContentWithDetail(CashSessionHistoryState state) {
    final session = _selectedSession;
    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isLoading = state is CashSessionHistoryLoading;

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedSessionId != null) {
          context.read<CashSessionHistoryBloc>().add(
                GetCashSessionDetail(sessionId: _selectedSessionId!),
              );
        } else {
          _loadData();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom header with back button inside
            Padding(
              padding: const EdgeInsets.all(2.5),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      offset: const Offset(0, 5),
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _hideDetail,
                      tooltip: 'Kembali ke daftar',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Riwayat Kas Harian',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SpaceHeight(16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ..._buildDetailContent(session),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailContent(CashSessionData session) {
    final isOpen = session.status == 'open';
    final statusColor = isOpen ? AppColors.success : AppColors.primary;
    final statusText = isOpen ? 'BUKA' : 'TUTUP';
    final expectedBalance =
        session.openingBalance + session.cashSales - session.cashExpenses;
    final int? closingBalance = session.closingBalance;
    final int? variance = isOpen
        ? null
        : (closingBalance != null ? (closingBalance - expectedBalance) : null);

    final expenses = List<CashExpense>.from(session.expenses ?? [])
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return [
      // Header Section
      Container(
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
            if (session.openedAt != null && session.closedAt != null) ...[
              _infoRow('Durasi',
                  _calculateDuration(session.openedAt!, session.closedAt!)),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      const SpaceHeight(16),
      // Status Section
      _section(
        title: 'Status Shift',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('ID Sesi', session.id ?? '-'),
            const SizedBox(height: 8),
            _infoRow('Shift dibuka oleh',
                session.user?.name ?? session.userId ?? '-'),
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
      ),
      const SpaceHeight(16),
      // Summary Section
      _section(
        title: 'Ringkasan Kas Harian',
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _summaryTile(
                    'Saldo Awal', session.openingBalance.currencyFormatRp),
                _summaryTile(
                    'Penjualan Tunai', session.cashSales.currencyFormatRp,
                    valueColor: AppColors.success),
                _summaryTile(
                    'Pengeluaran', session.cashExpenses.currencyFormatRp,
                    valueColor: AppColors.danger),
                _summaryTile(
                  'Saldo Ekspektasi',
                  expectedBalance.currencyFormatRp,
                ),
                _summaryTile(
                  'Saldo Fisik',
                  closingBalance != null
                      ? closingBalance.currencyFormatRp
                      : '-',
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
          ],
        ),
      ),
      const SpaceHeight(16),
      // Expense List
      _section(
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
      ),
      const SpaceHeight(16),
      // Print Button
      Container(
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
        child: PrintButton(
          label: 'Print Laporan',
          color: AppColors.primary,
          icon: Assets.icons.printer.svg(
            height: 20,
            width: 20,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPrint: () async {
            final sizeReceipt = await AuthLocalDataSource().getSizeReceipt();
            final paperSize = int.tryParse(sizeReceipt) ?? 58;
            return await PrintDataoutputs.instance.printCashSessionReport(
              session: session,
              paperSize: paperSize,
            );
          },
        ),
      ),
    ];
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
    return SizedBox(
      width: 200,
      child: Container(
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
      ),
    );
  }

  String _calculateDuration(DateTime start, DateTime end) {
    // Calculate total duration in minutes
    final duration = end.difference(start);
    final totalMinutes = duration.inMinutes;

    // Handle negative duration (if end is before start, it means it crossed midnight)
    // This shouldn't happen in normal cases, but we handle it anyway
    final absMinutes = totalMinutes.abs();

    final days = absMinutes ~/ (24 * 60);
    final hours = (absMinutes % (24 * 60)) ~/ 60;
    final minutes = absMinutes % 60;

    final parts = <String>[];
    if (days > 0) {
      parts.add('$days hari');
    }
    if (hours > 0) {
      parts.add('$hours jam');
    }
    if (minutes > 0 || parts.isEmpty) {
      parts.add('$minutes menit');
    }

    return parts.join(' ');
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

  String _formatDateTime(DateTime? date) =>
      date == null ? '-' : date.toFormattedDate3();
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
