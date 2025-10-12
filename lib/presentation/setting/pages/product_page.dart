import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/presentation/setting/bloc/get_products/get_products_bloc.dart';
import 'package:xpress/presentation/setting/dialogs/form_product_dialog.dart';
import 'package:xpress/presentation/setting/widgets/add_data.dart';
import 'package:xpress/presentation/setting/widgets/menu_product_item.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    context.read<GetProductsBloc>().add(const GetProductsEvent.fetch());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // const SettingsTitle('Manage Products'),
          const SizedBox(height: 24),
          BlocBuilder<GetProductsBloc, GetProductsState>(
            builder: (context, state) {
              return state.maybeWhen(orElse: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }, success: (products) {
                return GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: products.length + 1,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return AddData(
                        title: 'Add New Product',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const FormProductDialog(),
                          );
                        },
                      );
                    }
                    final item = products[index - 1];
                    return MenuProductItem(data: item, onTapEdit: () async {});
                  },
                );
              });
            },
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {

      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
