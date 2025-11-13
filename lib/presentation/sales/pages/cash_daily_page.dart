import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/date_time_ext.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/data/models/response/cash_session_response_model.dart';
import 'package:xpress/presentation/sales/blocs/cash_session/cash_session_bloc.dart';
import 'package:xpress/presentation/sales/blocs/cash_session/cash_session_event.dart';
import 'package:xpress/presentation/sales/blocs/cash_session/cash_session_state.dart';

enum _CashSessionAction { fetch, open, close, expense }

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
  final TextEditingController _expenseAmountCtrl = TextEditingController();
  final TextEditingController _expenseNoteCtrl = TextEditingController();
  final TextEditingController _expenseCategoryCtrl = TextEditingController();
  final TextEditingController _openShiftAmountCtrl = TextEditingController();
  final TextEditingController _openShiftNotesCtrl = TextEditingController();
  final TextEditingController _closeShiftAmountCtrl = TextEditingController();
  CashSessionData? _session;
  bool _isSubmittingExpense = false;
  _CashSessionAction? _lastAction;

  @override
  void initState() {
    super.initState();
    _hydrateFromBlocState();
    _loadCashSession();
  }

  void _loadCashSession() {
    _lastAction = _CashSessionAction.fetch;
    context.read<CashSessionBloc>().add(GetCurrentCashSession());
  }

  void _hydrateFromBlocState() {
    final currentState = context.read<CashSessionBloc>().state;
    if (currentState is CashSessionSuccess) {
      _session = currentState.data;
    } else if (currentState is CashSessionEmpty) {
      _session = null;
    } else if (currentState is CashSessionError &&
        _isNoSessionMessage(currentState.message)) {
      _session = null;
    }
  }

  @override
  void dispose() {
    _expenseAmountCtrl.dispose();
    _expenseNoteCtrl.dispose();
    _expenseCategoryCtrl.dispose();
    _openShiftAmountCtrl.dispose();
    _openShiftNotesCtrl.dispose();
    _closeShiftAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CashSessionBloc, CashSessionState>(
      listener: _handleStateChange,
      builder: (context, state) {
        final bool isInitial = state is CashSessionInitial && _session == null;
        final bool showFullLoader =
            _session == null && state is CashSessionLoading;
        if (isInitial || showFullLoader) {
          return const Center(child: CircularProgressIndicator());
        }

        final bool isRefreshing = _session != null && state is CashSessionLoading;
        final String? errorBanner = _resolveErrorMessage(state);

        return RefreshIndicator(
          onRefresh: () async => _loadCashSession(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ContentTitle('Kas Harian'),
                const SpaceHeight(16),
                if (errorBanner != null) _errorBanner(errorBanner),
                _buildShiftStatusSection(isRefreshing),
                _buildSummarySection(),
                _buildExpenseComposer(),
                _buildExpenseList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStateChange(BuildContext context, CashSessionState state) {
    if (state is CashSessionSuccess) {
      setState(() {
        _session = state.data;
        _isSubmittingExpense = false;
      });

      if (_lastAction != _CashSessionAction.fetch && mounted) {
        final message = switch (_lastAction) {
          _CashSessionAction.open => 'Shift berhasil dibuka.',
          _CashSessionAction.close => 'Shift berhasil ditutup.',
          _CashSessionAction.expense => 'Pengeluaran berhasil dicatat.',
          _ => null,
        };
        if (message != null) {
          _showSnackBar(message, isError: false);
        }
      }
      _lastAction = null;
    } else if (state is CashSessionEmpty) {
      setState(() {
        _session = null;
        _isSubmittingExpense = false;
      });
      _lastAction = null;
    } else if (state is CashSessionError) {
      final isEmptySession = _isNoSessionMessage(state.message);
      if (isEmptySession) {
        setState(() {
          _session = null;
        });
      }
      setState(() {
        _isSubmittingExpense = false;
      });

      if (!isEmptySession) {
        _showSnackBar(state.message);
      }
      _lastAction = null;
    }
  }

  Widget _errorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dangerLightActive),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.dangerActive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftStatusSection(bool isRefreshing) {
    final session = _session;
    final bool hasSession = session != null;
    final bool isOpen = session?.status == 'open';
    final bool canOpenShift = !isOpen;
    final bool canCloseShift = isOpen && (session?.id?.isNotEmpty ?? false);

    String statusText = 'Belum ada shift aktif';
    Color statusColor = AppColors.grey;
    if (session != null) {
      if (isOpen) {
        statusText = 'Shift sedang berjalan';
        statusColor = AppColors.success;
      } else {
        statusText = 'Shift terakhir sudah ditutup';
        statusColor = AppColors.primary;
      }
    }

    return _section(
      title: 'Status Shift',
      trailing: isRefreshing
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              onPressed: _loadCashSession,
              icon: const Icon(Icons.refresh),
              tooltip: 'Segarkan data',
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                label: Text(
                  hasSession ? session.status.toUpperCase() : 'BELUM AKTIF',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                backgroundColor: statusColor.withValues(alpha: 0.1),
                side: BorderSide(color: statusColor.withValues(alpha: 0.4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          if (session != null) ...[
            _infoRow('Dibuka pada', _formatDateTime(session.openedAt)),
            const SizedBox(height: 8),
            _infoRow('Ditutup pada', _formatDateTime(session.closedAt)),
            const SizedBox(height: 8),
            _infoRow('Saldo awal', session.openingBalance.currencyFormatRp),
          ] else
            const Text(
              'Belum ada data shift. Tekan tombol "Buka Shift" untuk memulai pencatatan kas.',
              style: TextStyle(color: AppColors.grey),
            ),
          if (session != null) ...[
            const SizedBox(height: 8),
            Text(
              'Catatan Shift',
              style: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (session.notes ?? '-').isEmpty ? '-' : session.notes!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Button.filled(
            onPressed: () {
              if (!isOpen) {
                _openShiftDialog();
                return;
              }
              if (session != null) {
                _closeShiftDialog(session);
              }
            },
            label: isOpen ? 'Tutup Shift' : 'Buka Shift',
            color: isOpen ? AppColors.danger : AppColors.primary,
            disabled: isRefreshing || (isOpen ? !canCloseShift : !canOpenShift),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final session = _session;
    final int? closingBalance = session?.closingBalance;
    final int expectedBalance =
        session == null ? 0 : _calculateExpectedBalance(session);
    final int? variance = session == null
        ? null
        : (session.status == 'closed'
            ? session.variance
            : (closingBalance != null
                ? (closingBalance - expectedBalance)
                : null));

    return _section(
      title: 'Ringkasan Kas Harian',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _summaryTile('Saldo Awal', _formatCurrency(session?.openingBalance)),
          _summaryTile(
              'Penjualan Tunai', _formatCurrency(session?.cashSales)),
          _summaryTile('Pengeluaran', _formatCurrency(session?.cashExpenses)),
          _summaryTile(
            'Saldo Ekspektasi',
            session == null ? '-' : expectedBalance.currencyFormatRp,
          ),
          _summaryTile(
            'Saldo Fisik',
            _formatCurrency(closingBalance),
          ),
          _summaryTile(
            'Selisih',
            variance == null ? '-' : variance.currencyFormatRp,
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

  Widget _buildExpenseComposer() {
    final bool hasActiveSession = _session?.status == 'open';

    return _section(
      title: 'Catat Pengeluaran Tunai',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catat pengeluaran tunai melalui formulir pop-up agar histori shift tetap rapi.',
            style: TextStyle(color: AppColors.grey),
          ),
          const SpaceHeight(16),
          Button.filled(
            onPressed: _showExpenseDialog,
            label: 'Tambah Pengeluaran',
            disabled: !hasActiveSession || _isSubmittingExpense,
          ),
          if (!hasActiveSession)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Buka shift terlebih dahulu untuk mencatat pengeluaran.',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          if (_isSubmittingExpense && hasActiveSession)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Menyimpan pengeluaran...',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showExpenseDialog() async {
    final session = _session;
    if (session == null || session.status != 'open') {
      _showSnackBar(
        'Belum ada shift aktif. Buka shift untuk mencatat pengeluaran.',
      );
      return;
    }

    _expenseAmountCtrl.clear();
    _expenseNoteCtrl.clear();
    _expenseCategoryCtrl.clear();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Pengeluaran Tunai',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _expenseAmountCtrl,
                  label: 'Jumlah pengeluaran (Rp)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _expenseCategoryCtrl,
                  label: 'Kategori',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _expenseNoteCtrl,
                  label: 'Deskripsi',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSubmittingExpense
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                    },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: _isSubmittingExpense
                  ? null
                  : () => _submitExpense(dialogContext),
              child: _isSubmittingExpense
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseList() {
    final expenses = List<CashExpense>.from(_session?.expenses ?? [])
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
                return Row(
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
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemCount: expenses.length,
            ),
    );
  }

  void _openShiftDialog() async {
    _openShiftAmountCtrl.clear();
    _openShiftNotesCtrl.clear();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buka Shift',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Masukkan saldo awal kas sebelum shift dimulai.',
                style: TextStyle(color: AppColors.grey),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _openShiftAmountCtrl,
                label: 'Saldo awal (Rp)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _openShiftNotesCtrl,
                label: 'Catatan shift',
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Button.outlined(
                      onPressed: () => Navigator.pop(context),
                      label: 'Batal',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Button.filled(
                      onPressed: () {
                        final amount = _parseCurrency(_openShiftAmountCtrl.text);
                        final notes = _openShiftNotesCtrl.text.trim();
                        if (amount <= 0) {
                          _showSnackBar(
                            'Saldo awal harus lebih dari 0.',
                          );
                          return;
                        }
                        if (notes.isEmpty) {
                          _showSnackBar('Catatan shift wajib diisi.');
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        Navigator.pop(
                          context,
                          {
                            'amount': amount,
                            'notes': notes,
                          },
                        );
                      },
                      label: 'Mulai Shift',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;

    if (result != null) {
      final int amount = (result['amount'] as int?) ?? 0;
      final String notes = (result['notes'] as String?)?.trim() ?? '';
      if (amount > 0 && notes.isNotEmpty) {
        _lastAction = _CashSessionAction.open;
        context.read<CashSessionBloc>().add(
              OpenCashSession(
                openingBalance: amount,
                notes: notes,
              ),
            );
      }
    }
  }

  void _closeShiftDialog(CashSessionData session) async {
    _closeShiftAmountCtrl.clear();
    final expected = _calculateExpectedBalance(session);

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tutup Shift',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Saldo ekspektasi: ${expected.currencyFormatRp}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _closeShiftAmountCtrl,
                label: 'Saldo fisik akhir (Rp)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Button.outlined(
                      onPressed: () => Navigator.pop(context),
                      label: 'Batal',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Button.filled(
                      onPressed: () {
                        final amount = _parseCurrency(_closeShiftAmountCtrl.text);
                        if (amount <= 0) {
                          _showSnackBar(
                            'Saldo akhir harus lebih dari 0.',
                          );
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context, amount);
                      },
                      label: 'Tutup Shift',
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;

    if (result != null && result > 0) {
      _lastAction = _CashSessionAction.close;
      context
          .read<CashSessionBloc>()
          .add(CloseCashSession(session.id ?? '', result));
    }
  }

  void _submitExpense(BuildContext dialogContext) {
    final session = _session;
    if (session == null || session.id == null) {
      _showSnackBar('Belum ada shift aktif.');
      return;
    }

    final amount = _parseCurrency(_expenseAmountCtrl.text);
    final description = _expenseNoteCtrl.text.trim();
    final category = _expenseCategoryCtrl.text.trim();

    if (amount <= 0 || description.isEmpty || category.isEmpty) {
      _showSnackBar(
        'Nominal, kategori, dan deskripsi wajib diisi untuk mencatat pengeluaran.',
      );
      return;
    }

    FocusScope.of(dialogContext).unfocus();

    setState(() {
      _isSubmittingExpense = true;
    });
    _lastAction = _CashSessionAction.expense;

    context.read<CashSessionBloc>().add(
          AddCashExpense(
            sessionId: session.id!,
            amount: amount,
            description: description,
            category: category,
          ),
        );

    Navigator.of(dialogContext).pop();
    _expenseAmountCtrl.clear();
    _expenseNoteCtrl.clear();
    _expenseCategoryCtrl.clear();
  }

  String? _resolveErrorMessage(CashSessionState state) {
    if (state is CashSessionError && !_isNoSessionMessage(state.message)) {
      return state.message;
    }
    return null;
  }

  bool _isNoSessionMessage(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('no active cash session') ||
        normalized.contains('no open cash session') ||
        normalized.contains('no_active_cash_session');
  }

  int _calculateExpectedBalance(CashSessionData data) =>
      data.openingBalance + data.cashSales - data.cashExpenses;

  int _parseCurrency(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  String _formatCurrency(int? value) =>
      value == null ? '-' : value.currencyFormatRp;

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  String _formatDateTime(DateTime? date) =>
      date == null ? '-' : date.toFormattedDate3();

  Widget _summaryTile(String title, String value, {Color? valueColor}) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyLightActive.withValues(alpha: 0.4),
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

  Widget _section({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 2, right: 2, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SpaceHeight(12),
          child,
        ],
      ),
    );
  }
}
