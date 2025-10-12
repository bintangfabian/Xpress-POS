import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/presentation/setting/bloc/sync_order/sync_order_bloc.dart';
import 'package:xpress/presentation/setting/bloc/sync_product/sync_product_bloc.dart';

class SyncDataPage extends StatefulWidget {
  const SyncDataPage({super.key});

  @override
  State<SyncDataPage> createState() => _SyncDataPageState();
}

class _SyncDataPageState extends State<SyncDataPage> {
  void _syncAll() {
    // Trigger known syncs; others can be wired later
    context.read<SyncProductBloc>().add(const SyncProductEvent.syncProduct());
    context.read<SyncOrderBloc>().add(const SyncOrderEvent.syncOrder());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sinkronisasi dimulai...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Sinkronisasi Data'),
          const SizedBox(height: 16),

          // Produk
          BlocConsumer<SyncProductBloc, SyncProductState>(
            listener: (context, state) {
              state.maybeWhen(
                orElse: () {},
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(message), backgroundColor: Colors.red),
                  );
                },
                loaded: (productResponseModel) async {
                  await ProductLocalDatasource.instance.deleteAllProducts();
                  await ProductLocalDatasource.instance
                      .insertProducts(productResponseModel.data!);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sinkronisasi produk berhasil'),
                        backgroundColor: Colors.green),
                  );
                },
              );
            },
            builder: (context, state) {
              final isLoading =
                  state.maybeWhen(loading: () => true, orElse: () => false);
              return _SyncRow(
                icon: Assets.icons.cart,
                title: 'Sinkronisasi Produk',
                subtitle: 'Sinkronisasi produk dari server ke database',
                onPressed: isLoading
                    ? null
                    : () => context
                        .read<SyncProductBloc>()
                        .add(const SyncProductEvent.syncProduct()),
              );
            },
          ),

          // Kategori (placeholder action)
          _SyncRow(
            icon: Assets.icons.packages,
            title: 'Sinkronisasi Kategori',
            subtitle: 'Sinkronisasi kategori dari server ke database',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sinkronisasi kategori...')),
              );
            },
          ),

          // Member (placeholder action)
          _SyncRow(
            icon: Assets.icons.people,
            title: 'Sinkronisasi Member',
            subtitle: 'Sinkronisasi member dari server ke database',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sinkronisasi member...')),
              );
            },
          ),

          // Diskon (placeholder action)
          _SyncRow(
            icon: Assets.icons.percentange,
            title: 'Sinkronisasi Diskon',
            subtitle: 'Sinkronisasi diskon dari server ke database',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sinkronisasi diskon...')),
              );
            },
          ),

          // Order
          BlocConsumer<SyncOrderBloc, SyncOrderState>(
            listener: (context, state) {
              state.maybeWhen(
                orElse: () {},
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(message), backgroundColor: Colors.red),
                  );
                },
                loaded: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sinkronisasi order berhasil'),
                        backgroundColor: Colors.green),
                  );
                },
              );
            },
            builder: (context, state) {
              final isLoading =
                  state.maybeWhen(loading: () => true, orElse: () => false);
              return _SyncRow(
                icon: Assets.icons.order,
                title: 'Sinkronisasi Order',
                subtitle: 'Sinkronisasi order dari server ke database',
                onPressed: isLoading
                    ? null
                    : () => context
                        .read<SyncOrderBloc>()
                        .add(const SyncOrderEvent.syncOrder()),
              );
            },
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Button.filled(
              onPressed: _syncAll,
              height: 52,
              label: 'Sinkronisasi Semua',
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  final SvgGenImage icon;
  final String title;
  final String subtitle;
  final VoidCallback? onPressed;
  const _SyncRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            icon.svg(height: 32, width: 32, color: AppColors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              child: Button.filled(
                onPressed: onPressed ?? () {},
                disabled: onPressed == null,
                height: 44,
                label: 'Sinkronisasi',
              ),
            )
          ],
        ),
      ),
    );
  }
}
