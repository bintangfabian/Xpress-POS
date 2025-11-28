import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/core/widgets/feature_guard.dart';
import 'package:xpress/core/widgets/offline_feature_banner.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';
import 'package:xpress/presentation/setting/bloc/add_discount/add_discount_bloc.dart';
import 'package:xpress/presentation/setting/bloc/discount/discount_bloc.dart';

import '../../../core/components/buttons.dart';
import '../../../core/components/spaces.dart';
import '../models/discount_model.dart';

class FormDiscountDialog extends StatefulWidget {
  final DiscountModel? data;
  const FormDiscountDialog({super.key, this.data});

  @override
  State<FormDiscountDialog> createState() => _FormDiscountDialogState();
}

class _FormDiscountDialogState extends State<FormDiscountDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final discountController = TextEditingController();
  final List<String> _typeOptions = const ['percentage', 'fixed'];
  String _selectedType = 'percentage';
  final FocusNode _discountFocusNode = FocusNode();
  bool _isDiscountFocused = false;
  String? _discountErrorMessage;
  static const int _maxDigits = 18;

  String get _valueHint => _selectedType == 'percentage'
      ? 'Masukkan Nilai (%)'
      : 'Masukkan Nilai (Rp)';

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    // Remove non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '';
    // Format with thousand separators
    final number = int.tryParse(digitsOnly) ?? 0;
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  void initState() {
    super.initState();
    _discountFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isDiscountFocused = _discountFocusNode.hasFocus;
        });
      }
    });
    // Listen to controller changes to update prefix visibility
    discountController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    discountController.dispose();
    _discountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tambah Diskon',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            IconButton(
              icon: Assets.icons.cancel.svg(
                colorFilter: ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
                height: 32,
                width: 32,
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: context.deviceWidth / 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<OnlineCheckerBloc, OnlineCheckerState>(
                  builder: (context, state) {
                    final isOnline = state.maybeWhen(
                        online: () => true, orElse: () => false);
                    if (!isOnline) {
                      return const OfflineFeatureBanner(
                        featureName: 'Tambah Diskon',
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Nama Diskon",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: nameController, // 🔹 tambahkan controller
                        decoration: InputDecoration(
                          hintText: "Masukkan Nama Diskon",
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(24.0),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Deskripsi Diskon",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller:
                            descriptionController, // 🔹 tambahkan controller
                        decoration: InputDecoration(
                          hintText: "Masukkan Deskripsi Diskon",
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(24.0),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Tipe Diskon",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedType,
                        items: _typeOptions
                            .map(
                              (type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type == 'percentage' ? 'Percentage' : 'Fixed',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedType = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Pilih tipe diskon',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(24.0),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Nilai",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: discountController,
                        focusNode: _discountFocusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: _selectedType == 'fixed'
                            ? [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(_maxDigits +
                                    10), // Allow extra for formatting
                              ]
                            : null,
                        onChanged: _selectedType == 'fixed'
                            ? (value) {
                                // Remove "Rp." prefix and format
                                String cleanedValue =
                                    value.replaceAll('Rp.', '').trim();
                                cleanedValue = cleanedValue.replaceAll('.', '');

                                // Validasi maksimal digit
                                if (cleanedValue.length > _maxDigits) {
                                  // Potong ke maxDigits
                                  cleanedValue =
                                      cleanedValue.substring(0, _maxDigits);
                                  setState(() {
                                    _discountErrorMessage =
                                        'Maksimal $_maxDigits digit';
                                  });
                                } else {
                                  setState(() {
                                    _discountErrorMessage = null;
                                  });
                                }

                                // Format the value
                                final formatted = _formatCurrency(cleanedValue);

                                // Update controller without triggering listener
                                discountController.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                    offset: formatted.length,
                                  ),
                                );
                              }
                            : null,
                        decoration: InputDecoration(
                          hintText: _valueHint,
                          prefixText: ((_isDiscountFocused ||
                                      discountController.text.isNotEmpty) &&
                                  _selectedType == 'fixed')
                              ? 'Rp. '
                              : null,
                          prefixStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _discountErrorMessage != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _discountErrorMessage != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _discountErrorMessage != null
                                  ? Colors.red
                                  : Colors.blue,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorText: _selectedType == 'fixed'
                              ? _discountErrorMessage
                              : null,
                          errorMaxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(32.0),
                Row(
                  children: [
                    Expanded(
                      child: Button.outlined(
                        label: 'Batal',
                        color: AppColors.greyLight,
                        borderColor: AppColors.grey,
                        textColor: AppColors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocConsumer<AddDiscountBloc, AddDiscountState>(
                      listener: (context, state) {
                        state.maybeWhen(
                          orElse: () {},
                          success: () {
                            context
                                .read<DiscountBloc>()
                                .add(const DiscountEvent.getDiscounts());
                            context.pop();
                          },
                        );
                      },
                      builder: (context, state) {
                        return state.maybeWhen(orElse: () {
                          return Expanded(
                            child: FeatureGuard(
                              featureCode: 'add_discount',
                              child: Button.filled(
                                color: AppColors.success,
                                label: 'Tambah',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                onPressed: () {
                                  context.read<AddDiscountBloc>().add(
                                        AddDiscountEvent.addDiscount(
                                          name: nameController.text,
                                          description:
                                              descriptionController.text,
                                          value: int.parse(
                                              discountController.text),
                                          type: _selectedType,
                                        ),
                                      );
                                },
                              ),
                              disabledChild: Button.filled(
                                color: AppColors.success,
                                label: 'Tambah',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                onPressed: () {},
                                disabled: true,
                              ),
                            ),
                          );
                        }, loading: () {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
