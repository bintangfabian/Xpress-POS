import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';

class CashDailyPage extends StatefulWidget {
  const CashDailyPage({super.key});

  @override
  State<CashDailyPage> createState() => _CashDailyPageState();
}

class _CashDailyPageState extends State<CashDailyPage> {
  final TextEditingController _saldoAwalCtrl = TextEditingController();
  final TextEditingController _pengeluaranCtrl = TextEditingController();
  final TextEditingController _keteranganCtrl = TextEditingController();

  int _saldoAwal = 0;
  int _totalPengeluaran = 0;
  final int _penjualanTunai = 0; // placeholder, bisa dihitung dari data transaksi

  @override
  void dispose() {
    _saldoAwalCtrl.dispose();
    _pengeluaranCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saldoAkhir = _saldoAwal - _totalPengeluaran + _penjualanTunai;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Rekap Kas'),
          const SpaceHeight(16),
          _section(
            title: 'Saldo awal',
            child: Column(
              children: [
                CustomTextField(
                  controller: _saldoAwalCtrl,
                  label: 'Saldo awal (Rp)',
                  keyboardType: TextInputType.number,
                ),
                const SpaceHeight(12),
                Button.filled(
                  onPressed: () {
                    setState(() {
                      _saldoAwal = int.tryParse(
                              _saldoAwalCtrl.text.replaceAll('.', '')) ??
                          0;
                    });
                  },
                  height: 48,
                  label: 'Simpan saldo awal',
                ),
              ],
            ),
          ),
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
                    setState(() {
                      _totalPengeluaran += int.tryParse(
                              _pengeluaranCtrl.text.replaceAll('.', '')) ??
                          0;
                      _pengeluaranCtrl.clear();
                      _keteranganCtrl.clear();
                    });
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
                _rowSummary('Saldo awal:', _saldoAwal),
                const SpaceHeight(8),
                _rowSummary('Pengeluaran:', _totalPengeluaran),
                const SpaceHeight(8),
                _rowSummary('Penjualan tunai:', _penjualanTunai),
                const SpaceHeight(8),
                const Divider(color: AppColors.primaryLightActive),
                const SpaceHeight(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saldo akhir:',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Rp $saldoAkhir',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowSummary(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text('Rp $value'),
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
