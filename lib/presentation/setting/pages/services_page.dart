import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/presentation/setting/widgets/add_data.dart';
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
              return GridView.builder(
                shrinkWrap: true,
                itemCount: layanan.length + 1,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.85,
                  crossAxisCount: 3,
                  crossAxisSpacing: 30.0,
                  mainAxisSpacing: 30.0,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return AddData(
                      title: 'Tambah Layanan Baru',
                      onPressed: onAddDataTap,
                    );
                  }
                  final item = layanan[index - 1];
                  return ManageTaxCard(
                    data: item,
                    onEditTap: () => onEditTap(item),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
