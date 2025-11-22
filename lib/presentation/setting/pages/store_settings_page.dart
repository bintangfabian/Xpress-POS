import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/datasources/store_remote_datasource.dart';
import 'package:xpress/data/models/response/store_response_model.dart';

class StoreSettingPage extends StatefulWidget {
  const StoreSettingPage({super.key});

  @override
  State<StoreSettingPage> createState() => _StoreSettingPageState();
}

class _StoreSettingPageState extends State<StoreSettingPage> {
  StoreDetail? _store;
  bool _isLoading = false;
  String? _errorMessage;

  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _fetchStore();
  }

  Future<void> _fetchStore() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await StoreRemoteDatasource().getCurrentStore();
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure;
          _isLoading = false;
        });
      },
      (detail) {
        setState(() {
          _store = detail;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetchStore,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ContentTitle('Pengaturan Toko'),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final isFirstLoad = _store == null && _isLoading;
    if (isFirstLoad) {
      return const _SkeletonLayout();
    }

    if (_store == null && _errorMessage != null) {
      return _ErrorState(
        message: _errorMessage!,
        onRetry: _fetchStore,
      );
    }

    if (_store == null) {
      return const SizedBox.shrink();
    }

    final store = _store!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(minHeight: 4),
            ),
          ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _InlineWarning(message: _errorMessage!),
          ),
        _buildHeroCard(store),
        const SizedBox(height: 24),
        _buildIdentitySection(store),
        const SizedBox(height: 24),
        _buildSettingsSection(store),
      ],
    );
  }

  Widget _buildHeroCard(StoreDetail store) {
    final statusColor = _statusColor(store.status);
    final statusText = _formatStatus(store.status);
    final ageText = _formatStoreAge(store.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryActive, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha((0.25 * 255).round()),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoBadge(
                name: store.name,
                logoUrl: store.logo,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name ?? 'Nama Toko',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'ID : ${_valueOrDash(store.id)}',
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.85 * 255).round()),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.av_timer,
                          color: Colors.white.withAlpha((0.8 * 255).round()),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Usia toko • $ageText',
                          style: TextStyle(
                            color: Colors.white.withAlpha((0.85 * 255).round()),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Chip(
                backgroundColor: statusColor,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                side: BorderSide(
                    color: statusColor.withAlpha((0.4 * 255).round()),
                    width: 2),
                label: Text(
                  statusText,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HeroMetric(
                  label: 'Dibuat',
                  value: _formatDateTime(store.createdAt),
                ),
                _HeroMetric(
                  label: 'Terakhir diperbarui',
                  value: _formatDateTime(store.updatedAt ?? store.createdAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection(StoreDetail store) {
    return _SectionCard(
      icon: Icons.store_mall_directory_outlined,
      title: 'Identitas & Kontak',
      subtitle: 'Detail utama untuk memastikan pengalaman pelanggan konsisten.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _InfoTile(
                icon: Icons.alternate_email,
                label: 'Email',
                value: _valueOrDash(store.email),
                expand: true,
              ),
              _InfoTile(
                icon: Icons.phone_outlined,
                label: 'Nomor Telepon',
                value: _valueOrDash(store.phone),
                expand: true,
              ),
              // _InfoTile(
              //   icon: Icons.badge_outlined,
              //   label: 'ID Toko',
              //   value: _valueOrDash(store.id),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.place_outlined,
            label: 'Alamat',
            value: _valueOrDash(store.address),
            expand: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(StoreDetail store) {
    final settings = store.settings;
    if (settings == null) {
      return _SectionCard(
        icon: Icons.tune,
        title: 'Pengaturan Operasional',
        child: const Text(
          'Pengaturan toko belum tersedia. Silakan coba segarkan kembali atau cek koneksi Anda.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey,
          ),
        ),
      );
    }

    final receiptFooter = settings.receiptFooter?.trim();
    return _SectionCard(
      icon: Icons.tune,
      title: 'Pengaturan Operasional',
      subtitle: 'Pantau konfigurasi pajak dan layanan yang aktif di outlet.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.payments_outlined,
                  label: 'Mata Uang',
                  value: _valueOrDash(settings.currency),
                  accentColor: AppColors.primary,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.percent,
                  label: 'Pajak',
                  value: _formatPercent(settings.taxRate),
                  // accentColor: AppColors.warning,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.room_service_outlined,
                  label: 'Biaya Layanan',
                  value: _formatPercent(settings.serviceChargeRate),
                  // accentColor: AppColors.success,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.public,
                  label: 'Zona Waktu',
                  value: _valueOrDash(settings.timezone),
                ),
              )
            ],
          ),
          // Wrap(
          //   spacing: 16,
          //   runSpacing: 16,
          //   children: [
          //     _InfoTile(
          //       icon: Icons.payments_outlined,
          //       label: 'Mata Uang',
          //       value: _valueOrDash(settings.currency),
          //       accentColor: AppColors.primary,
          //     ),
          //     _InfoTile(
          //       icon: Icons.percent,
          //       label: 'Pajak',
          //       value: _formatPercent(settings.taxRate),
          //       // accentColor: AppColors.warning,
          //     ),
          //     _InfoTile(
          //       icon: Icons.room_service_outlined,
          //       label: 'Biaya Layanan',
          //       value: _formatPercent(settings.serviceChargeRate),
          //       // accentColor: AppColors.success,
          //     ),
          //     _InfoTile(
          //       icon: Icons.public,
          //       label: 'Zona Waktu',
          //       value: _valueOrDash(settings.timezone),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryLightActive),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.primaryActive,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Catatan Struk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryActive,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  (receiptFooter != null && receiptFooter.isNotEmpty)
                      ? receiptFooter
                      : 'Belum ada catatan struk yang ditambahkan.',
                  style: const TextStyle(
                    color: AppColors.greyActive,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatStoreAge(DateTime? createdAt) {
    if (createdAt == null) return '-';
    final now = DateTime.now();
    Duration difference = now.difference(createdAt);
    if (difference.isNegative) {
      difference = Duration.zero;
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} hari';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} jam';
    }
    return 'Baru bergabung';
  }

  String _formatPercent(double? value) {
    if (value == null) return '-';
    final isInt = value % 1 == 0;
    final formatted =
        isInt ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return '$formatted%';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return _dateFormatter.format(value.toLocal());
  }

  String _formatStatus(String? status) {
    if (status == null || status.trim().isEmpty) return 'Tidak diketahui';
    final cleaned = status.replaceAll('_', ' ').trim().toLowerCase();
    final parts = cleaned.split(' ');
    return parts
        .map(
          (part) =>
              part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
        )
        .join(' ');
  }

  Color _statusColor(String? status) {
    final normalized = status?.toLowerCase() ?? '';
    if (normalized.contains('active')) {
      return AppColors.success;
    }
    if (normalized.contains('suspend') || normalized.contains('block')) {
      return AppColors.danger;
    }
    return AppColors.warning;
  }

  String _valueOrDash(String? value) {
    if (value == null) return '-';
    final trimmed = value.trim();
    return trimmed.isEmpty ? '-' : trimmed;
  }
}

class _LogoBadge extends StatelessWidget {
  final String? name;
  final String? logoUrl;

  const _LogoBadge({required this.name, required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final initials = _resolveInitials(name);
    final trimmedLogo = logoUrl?.trim();
    if (trimmedLogo != null && trimmedLogo.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          trimmedLogo,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialsBadge(initials: initials),
        ),
      );
    }
    return _InitialsBadge(initials: initials);
  }

  String _resolveInitials(String? value) {
    if (value == null || value.trim().isEmpty) return 'XP';
    final words = value.trim().split(RegExp(r'\s+'));
    final buffer = StringBuffer();
    for (final word in words.take(2)) {
      if (word.isEmpty) continue;
      buffer.write(word[0].toUpperCase());
    }
    final result = buffer.toString();
    return result.isEmpty ? 'XP' : result;
  }
}

class _InitialsBadge extends StatelessWidget {
  final String initials;

  const _InitialsBadge({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withAlpha((0.6 * 255).round()),
          width: 2,
        ),
        gradient: const LinearGradient(
          colors: [Color(0x33FFFFFF), Color(0x19FFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha((0.7 * 255).round()),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyLightActive),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withAlpha((0.08 * 255).round()),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryActive,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool expand;
  final Color? accentColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.expand = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedAccent = accentColor ?? AppColors.primary;
    final tile = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary, // base primary background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            offset: const Offset(0, 5), // Only bottom shadow
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 0, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.black.withAlpha((0.05 * 255).round()), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: resolvedAccent.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: resolvedAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: tile);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      child: tile,
    );
  }
}

class _InlineWarning extends StatelessWidget {
  final String message;

  const _InlineWarning({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningLightActive),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.warningActive,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dangerLightActive),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.sentiment_dissatisfied_outlined,
            size: 42,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat data toko',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.dangerActive,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.dangerActive,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLayout extends StatelessWidget {
  const _SkeletonLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SkeletonBox(height: 220),
        SizedBox(height: 24),
        _SkeletonBox(height: 180),
        SizedBox(height: 24),
        _SkeletonBox(height: 180),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;

  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
