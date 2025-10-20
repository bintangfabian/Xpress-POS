import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/presentation/setting/models/tax_model.dart';
import 'package:xpress/presentation/setting/widgets/loading_list_placeholder.dart';
import 'package:xpress/presentation/setting/widgets/manage_tax_card.dart';

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
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futureLayanan = Future<List<TaxModel>>.delayed(
      const Duration(milliseconds: 200),
      () => items.where((e) => e.type.isLayanan).toList(),
    );
  }

  void onAddDataTap() {}
  void onEditTap(TaxModel m) {}

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
        const ContentTitle('Kelola Layanan'),
        const SizedBox(height: 24),
        Expanded(
          child: FutureBuilder<List<TaxModel>>(
            future: _futureLayanan,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ServiceTableHeader(),
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
                    snapshot.error?.toString() ?? 'Gagal memuat data layanan.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              }
              final layanan = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ServiceTableHeader(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: layanan.isEmpty
                        ? _ServiceEmptyState(
                            controller: _listController,
                            message: 'Belum ada layanan terdaftar.',
                          )
                        : Scrollbar(
                            controller: _listController,
                            thumbVisibility: true,
                            child: ListView.separated(
                              controller: _listController,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              padding: EdgeInsets.zero,
                              itemCount: layanan.length,
                              separatorBuilder: (context, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = layanan[index];
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

class _ServiceEmptyState extends StatelessWidget {
  final ScrollController controller;
  final String message;
  const _ServiceEmptyState({
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
