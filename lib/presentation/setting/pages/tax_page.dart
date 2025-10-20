import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';

import '../dialogs/form_tax_dialog.dart';
import '../models/tax_model.dart';
import '../widgets/loading_list_placeholder.dart';
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
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futurePajak = Future<List<TaxModel>>.delayed(
      const Duration(milliseconds: 200),
      () => items.where((e) => e.type.isPajak).toList(),
    );
  }

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
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContentTitle('Kelola Pajak'),
        const SizedBox(height: 24),
        Expanded(
          child: FutureBuilder<List<TaxModel>>(
            future: _futurePajak,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TaxTableHeader(title: 'Nama Pajak'),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LoadingListPlaceholder(
                        controller: _listController,
                        itemHeight: 72,
                      ),
                    ),
                  ],
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error?.toString() ?? 'Gagal memuat data pajak.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              }
              final pajak = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TaxTableHeader(title: 'Nama Pajak'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: pajak.isEmpty
                        ? _TaxEmptyState(
                            controller: _listController,
                            message: 'Belum ada pajak terdaftar.',
                          )
                        : Scrollbar(
                            controller: _listController,
                            thumbVisibility: true,
                            child: ListView.separated(
                              controller: _listController,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              padding: EdgeInsets.zero,
                              itemCount: pajak.length,
                              separatorBuilder: (context, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = pajak[index];
                                return ManageTaxCard(
                                  data: item,
                                  onEditTap: () => onEditTap(item),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
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

class _TaxEmptyState extends StatelessWidget {
  final ScrollController controller;
  final String message;
  const _TaxEmptyState({
    required this.controller,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      child: ListView(
        controller: controller,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.zero,
        children: [
          Container(
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
          ),
        ],
      ),
    );
  }
}
