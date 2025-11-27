import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/presentation/table/blocs/generate_table/generate_table_bloc.dart';
import 'package:xpress/presentation/table/blocs/get_table/get_table_bloc.dart';
import '../../../core/components/components.dart';
import '../../../core/assets/assets.gen.dart';
import '../../../core/utils/snackbar_helper.dart';

class FormTableDialog extends StatefulWidget {
  const FormTableDialog({super.key});

  @override
  State<FormTableDialog> createState() => _FormTableDialogState();
}

class _FormTableDialogState extends State<FormTableDialog> {
  final generateController = TextEditingController();

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
            const Text('Kelola Meja',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
      content: SizedBox(
        width: 480,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Jumlah Meja",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // const SizedBox(height: 8),

                  // 🔹 Input Field
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: generateController, // 🔹 tambahkan controller
                      decoration: InputDecoration(
                        hintText: "Masukkan jumlah meja",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              // 🔹 Label
              // const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: Button.outlined(
                label: "Batal",
                textColor: AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.greyLight,
                borderColor: AppColors.grey,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BlocConsumer<GenerateTableBloc, GenerateTableState>(
                listener: (context, state) {
                  state.maybeWhen(
                    success: (message) {
                      if (message.startsWith('ERROR: ')) {
                        final msg = message.substring(7);
                        SnackbarHelper.showErrorOrOffline(
                          context,
                          msg,
                          offlineMessage:
                              'Generate meja tidak tersedia dalam mode offline. '
                              'Silahkan hubungkan kembali koneksi internet.',
                        );
                        return;
                      }
                      // refresh table setelah generate
                      context
                          .read<GetTableBloc>()
                          .add(const GetTableEvent.getTables());
                      context.pop();
                    },
                    orElse: () {},
                  );
                },
                builder: (context, state) {
                  return state.maybeWhen(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    orElse: () {
                      return Button.filled(
                        color: AppColors.success,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        onPressed: () {
                          // ✅ Validasi input
                          if (generateController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Jumlah meja tidak boleh kosong",
                                  style: TextStyle(
                                      color: AppColors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.warningLight,
                              ),
                            );
                            return;
                          }

                          final value =
                              int.tryParse(generateController.text.trim());
                          if (value == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Masukkan Angka Yang Valid",
                                  style: TextStyle(
                                      color: AppColors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.warningLight,
                              ),
                            );
                            return;
                          }

                          // 🔹 Dispatch event ke Bloc
                          context.read<GenerateTableBloc>().add(
                                GenerateTableEvent.generate(value),
                              );
                        },
                        label: 'Simpan',
                        height: 50,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
