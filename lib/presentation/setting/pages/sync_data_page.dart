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
  bool _isSyncing = false;
  int _syncProgress =
      0; // 0 = idle, 1 = product syncing, 2 = order syncing, 3 = done

  Future<void> _syncAll() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _syncProgress = 0;
    });

    // Show initial snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memulai sinkronisasi...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Sync products first
    setState(() => _syncProgress = 1);
    context.read<SyncProductBloc>().add(const SyncProductEvent.syncProduct());

    // Wait a bit for product sync to complete
    await Future.delayed(const Duration(seconds: 2));

    // Then sync orders
    setState(() => _syncProgress = 2);
    context.read<SyncOrderBloc>().add(const SyncOrderEvent.syncOrder());

    // Wait a bit for order sync to complete
    await Future.delayed(const Duration(seconds: 2));

    // Reset state
    setState(() {
      _syncProgress = 3;
      _isSyncing = false;
    });

    // Auto reset progress after showing done
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _syncProgress = 0);
      }
    });
  }

  String _getSyncStatusText() {
    switch (_syncProgress) {
      case 0:
        return 'Sinkronisasi Semua';
      case 1:
        return 'Menyinkronkan Produk...';
      case 2:
        return 'Menyinkronkan Order...';
      case 3:
        return 'Sinkronisasi Selesai!';
      default:
        return 'Sinkronisasi Semua';
    }
  }

  double? _getProgressValue() {
    switch (_syncProgress) {
      case 1:
        return 0.33;
      case 2:
        return 0.66;
      case 3:
        return 1.0;
      default:
        return null;
    }
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
                  if (!context.mounted) return;
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 52,
              decoration: BoxDecoration(
                color: _isSyncing
                    ? AppColors.primary.withOpacity(0.8)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSyncing ? null : _syncAll,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSyncing) ...[
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Flexible(
                          child: Text(
                            _getSyncStatusText(),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (_syncProgress == 3) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isSyncing)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: LinearProgressIndicator(
                value: _getProgressValue(),
                backgroundColor: AppColors.greyLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
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
              color: Colors.black.withAlpha((0.08 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            icon.svg(
              height: 32,
              width: 32,
              colorFilter: ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
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
