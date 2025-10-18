import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/presentation/setting/bloc/discount/discount_bloc.dart';
import '../dialogs/form_discount_dialog.dart';
import '../widgets/manage_discount_card.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  // final List<DiscountModel> discounts = [
  //   DiscountModel(
  //     name: '20',
  //     code: 'BUKAPUASA',
  //     description: null,
  //     discount: 50,
  //     category: ProductCategory.food,
  //   ),
  // ];

  void onEditTap() {
    showDialog(
      context: context,
      builder: (context) => const FormDiscountDialog(),
    );
  }

  void onAddDataTap() {
    showDialog(
      context: context,
      builder: (context) => const FormDiscountDialog(),
    );
  }

  @override
  void initState() {
    context.read<DiscountBloc>().add(const DiscountEvent.getDiscounts());
    super.initState();
  }

  Widget _loading() {
    return const SizedBox(
      height: 300,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Kelola Diskon'),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 220,
              child: Button.filled(
                label: 'Tambah Diskon Baru',
                height: 44,
                fontSize: 14,
                onPressed: onAddDataTap,
              ),
            ),
          ),
          const SizedBox(height: 24),
          BlocBuilder<DiscountBloc, DiscountState>(
            builder: (context, state) {
              return state.maybeWhen(
                loading: _loading,
                initial: _loading,
                error: (msg) => SizedBox(
                  height: 300,
                  child: Center(child: Text(msg)),
                ),
                loaded: (discounts) {
                  if (discounts.isEmpty) {
                    return const _EmptyTableState(
                        message: 'Belum ada diskon terdaftar.');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _DiscountTableHeader(),
                      const SizedBox(height: 16),
                      ...discounts.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ManageDiscountCard(
                            data: item,
                            onEditTap: onEditTap,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                orElse: _loading,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DiscountTableHeader extends StatelessWidget {
  const _DiscountTableHeader();

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
          Expanded(flex: 2, child: Text('Nama Diskon', style: _style)),
          SizedBox(width: 12),
          Expanded(flex: 2, child: Text('Deskripsi', style: _style)),
          SizedBox(width: 12),
          Expanded(flex: 1, child: Text('Nilai', style: _style)),
          SizedBox(width: 12),
          Expanded(flex: 1, child: Text('Status', style: _style)),
          SizedBox(width: 12),
          SizedBox(width: 75, child: Text('Aksi', style: _style)),
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
