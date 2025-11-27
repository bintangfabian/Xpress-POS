import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

/// Service untuk mengecek ketersediaan fitur berdasarkan status online/offline
/// Semua fitur offline ditandai sebagai "coming soon"
class FeatureAvailabilityService {
  final OnlineCheckerBloc onlineCheckerBloc;

  FeatureAvailabilityService(this.onlineCheckerBloc);

  /// Cek apakah fitur tersedia berdasarkan status online/offline
  /// Untuk sekarang, semua fitur offline ditandai sebagai coming soon
  bool isFeatureAvailable(String featureCode) {
    final isOnline = onlineCheckerBloc.isOnline;

    // Daftar fitur yang memerlukan koneksi online
    // Semua fitur ini ditandai sebagai "coming soon" saat offline
    const onlineOnlyFeatures = [
      'add_product',
      'edit_product',
      'delete_product',
      'add_discount',
      'edit_discount',
      'delete_discount',
      'add_member',
      'edit_member',
      'delete_member',
      'qris_payment',
      'sales_report',
      'table_management',
      'generate_table',
      'update_table_status',
      'cash_session',
      'product_variants',
      'store_settings',
    ];

    // Jika fitur memerlukan online dan sedang offline, return false
    if (onlineOnlyFeatures.contains(featureCode) && !isOnline) {
      return false;
    }

    return true;
  }

  /// Dapatkan pesan error jika fitur tidak tersedia
  String getUnavailableMessage(String featureCode) {
    final featureNames = {
      'add_product': 'Tambah Produk',
      'edit_product': 'Edit Produk',
      'delete_product': 'Hapus Produk',
      'add_discount': 'Tambah Diskon',
      'edit_discount': 'Edit Diskon',
      'delete_discount': 'Hapus Diskon',
      'add_member': 'Tambah Member',
      'edit_member': 'Edit Member',
      'delete_member': 'Hapus Member',
      'qris_payment': 'Pembayaran QRIS',
      'sales_report': 'Laporan Penjualan',
      'table_management': 'Kelola Meja',
      'generate_table': 'Generate Meja',
      'update_table_status': 'Update Status Meja',
      'cash_session': 'Sesi Kas',
      'product_variants': 'Varian Produk',
      'store_settings': 'Pengaturan Toko',
    };

    final featureName = featureNames[featureCode] ?? 'Fitur ini';
    return 'Fitur "$featureName" akan segera hadir dalam mode offline. '
        'Silakan hubungkan ke internet untuk menggunakan fitur ini.';
  }

  /// Dapatkan nama fitur yang user-friendly
  String getFeatureName(String featureCode) {
    final featureNames = {
      'add_product': 'Tambah Produk',
      'edit_product': 'Edit Produk',
      'delete_product': 'Hapus Produk',
      'add_discount': 'Tambah Diskon',
      'edit_discount': 'Edit Diskon',
      'delete_discount': 'Hapus Diskon',
      'add_member': 'Tambah Member',
      'edit_member': 'Edit Member',
      'delete_member': 'Hapus Member',
      'qris_payment': 'Pembayaran QRIS',
      'sales_report': 'Laporan Penjualan',
      'table_management': 'Kelola Meja',
      'generate_table': 'Generate Meja',
      'update_table_status': 'Update Status Meja',
      'cash_session': 'Sesi Kas',
      'product_variants': 'Varian Produk',
      'store_settings': 'Pengaturan Toko',
    };

    return featureNames[featureCode] ?? 'Fitur';
  }
}
