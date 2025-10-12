import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';

import '../dialogs/form_tax_dialog.dart';
import '../models/tax_model.dart';
import '../widgets/add_data.dart';
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
              return GridView.builder(
                shrinkWrap: true,
                itemCount: pajak.length + 1,
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
                      title: 'Tambah Pajak Baru',
                      onPressed: onAddDataTap,
                    );
                  }
                  final item = pajak[index - 1];
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
