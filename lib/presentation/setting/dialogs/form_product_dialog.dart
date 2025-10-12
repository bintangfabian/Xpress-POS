import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/components/custom_text_field.dart';
import 'package:xpress/core/components/image_picker_widget.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/data/models/response/category_response_model.dart';
import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/presentation/setting/bloc/add_product/add_product_bloc.dart';
import 'package:xpress/presentation/setting/bloc/get_categories/get_categories_bloc.dart';
import 'package:xpress/presentation/setting/bloc/get_products/get_products_bloc.dart';
import 'package:xpress/presentation/setting/bloc/sync_product/sync_product_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/spaces.dart';

class FormProductDialog extends StatefulWidget {
  const FormProductDialog({
    super.key,
  });

  @override
  State<FormProductDialog> createState() => _FormProductDialogState();
}

class _FormProductDialogState extends State<FormProductDialog> {
  TextEditingController? nameController;
  TextEditingController? priceController;
  TextEditingController? stockController;

  XFile? imageFile;

  bool isBestSeller = false;
  int priceValue = 0;

  CategoryModel? selectCategory;
  String? imageUrl;

  @override
  void initState() {
    context.read<GetCategoriesBloc>().add(const GetCategoriesEvent.fetch());
    nameController = TextEditingController();
    priceController = TextEditingController();
    stockController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    nameController!.dispose();
    priceController!.dispose();
    stockController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
          ),
          Text(
            'Add Product',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: context.deviceWidth / 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: nameController!,
                label: 'Product Name',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
              ),
              const SpaceHeight(20.0),
              CustomTextField(
                controller: priceController!,
                label: 'Price',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  priceValue = value.toIntegerFromText;
                  final int newValue = value.toIntegerFromText;
                  priceController!.text = newValue.currencyFormatRp;
                  priceController!.selection = TextSelection.fromPosition(
                      TextPosition(offset: priceController!.text.length));
                },
              ),
              const SpaceHeight(20.0),
              ImagePickerWidget(
                label: 'Photo Product',
                onChanged: (file) {
                  if (file == null) {
                    return;
                  }
                  imageFile = file;
                },
              ),
              const SpaceHeight(20.0),
              CustomTextField(
                controller: stockController!,
                label: 'Stock',
                keyboardType: TextInputType.number,
              ),
              const SpaceHeight(20.0),
              const Text(
                "Category",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SpaceHeight(12.0),
              BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    orElse: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    success: (categories) {
                      return DropdownButtonHideUnderline(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: DropdownButton<CategoryModel>(
                            value: selectCategory,
                            hint: const Text("Select Category"),
                            isExpanded: true, // Untuk mengisi lebar container
                            onChanged: (newValue) {
                              if (newValue != null) {
                                selectCategory = newValue;
                                setState(() {});
                                log("selectCategory: ${selectCategory!.name}");
                              }
                            },
                            items: categories
                                .map<DropdownMenuItem<CategoryModel>>(
                                    (CategoryModel category) {
                              return DropdownMenuItem<CategoryModel>(
                                value: category,
                                child: Text(category.name!),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SpaceHeight(20.0),
              Row(
                children: [
                  Checkbox(
                    value: isBestSeller,
                    onChanged: (value) {
                      setState(() {
                        isBestSeller = value!;
                      });
                    },
                  ),
                  const Text('Favorite Product'),
                ],
              ),
              const SpaceHeight(20.0),
              const SpaceHeight(24.0),
              BlocConsumer<AddProductBloc, AddProductState>(
                listener: (context, state) {
                  state.maybeMap(
                    orElse: () {},
                    success: (_) {
                      context
                          .read<SyncProductBloc>()
                          .add(const SyncProductEvent.syncProduct());
                      context
                          .read<GetProductsBloc>()
                          .add(const GetProductsEvent.fetch());
                      context.pop(true);

                      const snackBar = SnackBar(
                        content: Text('Success Add Product'),
                        backgroundColor: AppColors.primary,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBar,
                      );
                    },
                  );
                },
                builder: (context, state) {
                  return state.maybeWhen(
                    orElse: () {
                      return Button.filled(
                        onPressed: () {
                          log("isBestSeller: $isBestSeller");
                          final String name = nameController!.text;

                          final int stock =
                              stockController!.text.toIntegerFromText;
                          final Product product = Product(
                              name: name,
                              price: priceValue.toString(),
                              stock: stock,
                              categoryId: selectCategory!.id,
                              isFavorite: isBestSeller ? 1 : 0,
                              image: imageFile!.path);
                          context.read<AddProductBloc>().add(
                              AddProductEvent.addProduct(product, imageFile!));
                        },
                        label: 'Save Product',
                      );
                    },
                    loading: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                },
              ),
              const SpaceHeight(16.0),
            ],
          ),
        ),
      ),
    );
  }
}
