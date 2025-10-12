import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/presentation/setting/bloc/discount/discount_bloc.dart';
import '../dialogs/form_discount_dialog.dart';
import '../widgets/add_data.dart';
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
                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: discounts.length + 1,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.85,
                      crossAxisCount: 3,
                      crossAxisSpacing: 30.0,
                      mainAxisSpacing: 30.0,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return AddData(
                          title: 'Tambah Diskon Baru',
                          onPressed: onAddDataTap,
                        );
                      }
                      final item = discounts[index - 1];
                      return ManageDiscountCard(
                        data: item,
                        onEditTap: onEditTap,
                      );
                    },
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
