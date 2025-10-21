import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/models/response/discount_response_model.dart';
import 'package:xpress/presentation/setting/bloc/delete_discount/delete_discount_cubit.dart';
import 'package:xpress/presentation/setting/bloc/discount/discount_bloc.dart';
import '../dialogs/form_discount_dialog.dart';
import '../widgets/loading_list_placeholder.dart';
import '../widgets/manage_discount_card.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final ScrollController _listController = ScrollController();

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

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Widget _loadingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DiscountTableHeader(),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteDiscountCubit, DeleteDiscountState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == DeleteDiscountStatus.loading) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                duration: Duration(milliseconds: 800),
                content: Text('Menghapus diskon...'),
              ),
            );
        } else if (state.status == DeleteDiscountStatus.success) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Diskon berhasil dihapus')),
            );
          context.read<DiscountBloc>().add(const DiscountEvent.getDiscounts());
        } else if (state.status == DeleteDiscountStatus.error &&
            state.message != null) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
        }
      },
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
                icon: Assets.icons.plus.svg(height: 24, width: 24),
                label: 'Tambah Diskon',
                fontSize: 16,
                onPressed: onAddDataTap,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<DiscountBloc, DiscountState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: _loadingView,
                  initial: _loadingView,
                  error: (msg) => Center(
                    child: Text(
                      msg,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  loaded: (discounts) {
                    if (discounts.isEmpty) {
                      return _DiscountEmptyState(
                        controller: _listController,
                        message: 'Belum ada diskon terdaftar.',
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _DiscountTableHeader(),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Scrollbar(
                            controller: _listController,
                            thumbVisibility: true,
                            child: ListView.separated(
                              controller: _listController,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              padding: EdgeInsets.zero,
                              itemCount: discounts.length,
                              separatorBuilder: (context, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = discounts[index];
                                return ManageDiscountCard(
                                  data: item,
                                  onEditTap: onEditTap,
                                  onDeleteTap: () => _confirmDelete(item),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  orElse: _loadingView,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Discount discount) async {
    final id = discount.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID diskon tidak valid.')),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 12, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hapus Diskon',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                IconButton(
                  icon: Assets.icons.cancel
                      .svg(color: AppColors.grey, height: 32, width: 32),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: const Text(
              'Apakah Anda yakin ingin menghapus diskon ini?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Button.outlined(
                    label: 'Batal',
                    color: AppColors.white,
                    borderColor: AppColors.grey,
                    textColor: AppColors.grey,
                    fontSize: 16,
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button.filled(
                    label: 'Hapus',
                    color: AppColors.danger,
                    fontSize: 16,
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      context.read<DeleteDiscountCubit>().delete(id);
    }
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

class _DiscountEmptyState extends StatelessWidget {
  final ScrollController controller;
  final String message;

  const _DiscountEmptyState({
    required this.controller,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DiscountTableHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: Scrollbar(
            controller: controller,
            child: ListView(
              controller: controller,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
          ),
        ),
      ],
    );
  }
}
