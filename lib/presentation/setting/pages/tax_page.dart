import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';

import '../dialogs/form_tax_dialog.dart';
import '../models/tax_model.dart';
import '../widgets/manage_tax_card.dart';

class TaxPage extends StatefulWidget {
  const TaxPage({super.key});

  @override
  State<TaxPage> createState() => _TaxPageState();
}

class _TaxPageState extends State<TaxPage> {
  final List<TaxModel> items = [
    TaxModel(name: 'Biaya Layanan', type: TaxType.layanan, value: 5),
    TaxModel(name: 'Pajak PB1', type: TaxType.pajak, value: 10),
  ];

  late Future<List<TaxModel>> _futurePajak;

  void onEditTap(TaxModel item) {
    showDialog(
      context: context,
      builder: (context) => FormTaxDialog(data: item),
    );
  }

  void onAddDataTap() {
    showDialog(
      context: context,
      builder: (context) => const FormTaxDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _futurePajak = Future<List<TaxModel>>.delayed(
      const Duration(milliseconds: 200),
      () => items.where((e) => e.type.isPajak).toList(),
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Kelola Pajak'),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 220,
              child: Button.filled(
                label: 'Tambah Pajak Baru',
                height: 44,
                fontSize: 14,
                onPressed: onAddDataTap,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<TaxModel>>(
            future: _futurePajak,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final pajak = snapshot.data ?? [];
              if (pajak.isEmpty) {
                return const _EmptyTableState(
                  message: 'Belum ada pajak terdaftar.',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TaxTableHeader(title: 'Nama Pajak'),
                  const SizedBox(height: 16),
                  ...pajak.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ManageTaxCard(
                        data: item,
                        onEditTap: () => onEditTap(item),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TaxTableHeader extends StatelessWidget {
  final String title;
  const _TaxTableHeader({required this.title});

  static const TextStyle _style = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w700,
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(title, style: _style)),
          const Expanded(flex: 2, child: Text('Jenis', style: _style)),
          const Expanded(flex: 1, child: Text('Nilai', style: _style)),
          const SizedBox(width: 80, child: Text('Aksi', style: _style)),
        ],
      ),
    );
  }
}

class _EmptyTableState extends StatelessWidget {
  final String message;
  const _EmptyTableState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
