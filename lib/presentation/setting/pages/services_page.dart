import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/presentation/setting/widgets/manage_tax_card.dart';
import 'package:xpress/presentation/setting/models/tax_model.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final List<TaxModel> items = [
    TaxModel(name: 'Service Charge', type: TaxType.layanan, value: 5),
  ];

  late Future<List<TaxModel>> _futureLayanan;

  void onAddDataTap() {}
  void onEditTap(TaxModel m) {}

  @override
  Widget build(BuildContext context) {
    _futureLayanan = Future<List<TaxModel>>.delayed(
      const Duration(milliseconds: 200),
      () => items.where((e) => e.type.isLayanan).toList(),
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Kelola Layanan'),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 220,
              child: Button.filled(
                label: 'Tambah Layanan Baru',
                height: 44,
                fontSize: 14,
                onPressed: onAddDataTap,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<TaxModel>>(
            future: _futureLayanan,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final layanan = snapshot.data ?? [];
              if (layanan.isEmpty) {
                return const _EmptyTableState(
                  message: 'Belum ada layanan terdaftar.',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ServiceTableHeader(),
                  const SizedBox(height: 16),
                  ...layanan.map(
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

class _ServiceTableHeader extends StatelessWidget {
  const _ServiceTableHeader();

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
        children: const [
          Expanded(flex: 2, child: Text('Nama Layanan', style: _style)),
          Expanded(flex: 2, child: Text('Jenis', style: _style)),
          Expanded(flex: 1, child: Text('Nilai', style: _style)),
          SizedBox(width: 80, child: Text('Aksi', style: _style)),
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
