import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/auth_remote_datasource.dart';
import 'package:xpress/data/models/response/auth_response_model.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ds = AuthLocalDataSource();
      final auth = await ds.getAuthData();
      final storeUuid = await ds.getStoreUuid();

      if (!mounted) return;
      setState(() {
        _user = auth.user;
      });

      final identifier =
          auth.user?.store?.id ?? auth.user?.storeId ?? storeUuid;
      if (identifier != null && identifier.isNotEmpty) {
        await ds.saveStoreUuid(identifier);
      }

      await _refreshFromRemoteIfNeeded(ds, storeUuid);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _user = null;
        _isLoading = false;
        _errorMessage = 'Gagal memuat data profil: $e';
      });
    }
  }

  Future<void> _refreshFromRemoteIfNeeded(
    AuthLocalDataSource ds,
    String? cachedStoreUuid,
  ) async {
    final needsRemote = _user == null ||
        _user?.store?.name == null ||
        (_user?.roles == null || _user!.roles!.isEmpty);
    if (!needsRemote) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final token = await ds.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Token tidak tersedia. Silakan login ulang.';
      });
      return;
    }

    final result = await AuthRemoteDatasource().fetchProfile(token);
    if (!mounted) return;
    await result.fold(
      (failure) async {
        setState(() {
          _isLoading = false;
          _errorMessage = failure;
        });
      },
      (user) async {
        await ds.updateCachedUser(user);
        final identifier = user.store?.id ?? user.storeId;
        if (identifier != null && identifier.isNotEmpty) {
          await ds.saveStoreUuid(identifier);
        }
        if (!mounted) return;
        setState(() {
          _user = user;
          _isLoading = false;
          _errorMessage = null;
        });
      },
    );
  }

  String get _roleDisplay {
    final roles = _user?.roles;
    if (roles != null && roles.isNotEmpty) {
      return roles.join(', ');
    }
    return _user?.role ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ContentTitle('Profil Pengguna'),
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
    final isFirstLoad = _user == null && _isLoading;
    if (isFirstLoad) {
      return const _SkeletonLayout();
    }

    if (_user == null && _errorMessage != null) {
      return _ErrorState(
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    if (_user == null) {
      return const SizedBox.shrink();
    }

    final user = _user!;
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
        _buildHeroCard(user),
        const SizedBox(height: 24),
        _buildAccountSection(user),
        // const SizedBox(height: 24),
        // _buildStoreSection(user),
      ],
    );
  }

  Widget _buildHeroCard(User user) {
    final ageText = _formatUserAge(user.createdAt);
    final joinDate = _formatDateTime(user.createdAt);
    final lastUpdate = _formatDateTime(user.updatedAt ?? user.createdAt);

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
              _AvatarBadge(
                name: user.name,
                email: user.email,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? 'Pengguna',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(width: 8),
                    Text(
                      'Aktif selama • $ageText',
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.85 * 255).round()),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.14 * 255).round()),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HeroMetric(
                  label: 'Bergabung',
                  value: joinDate,
                ),
                _HeroMetric(
                  label: 'Terakhir diperbarui',
                  value: lastUpdate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(User user) {
    return _SectionCard(
      icon: Icons.person_outline,
      title: 'Informasi Akun',
      subtitle: 'Detail profil untuk memudahkan pengelolaan akses pengguna.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _InfoTile(
                icon: Icons.badge_outlined,
                label: 'Nama Pengguna',
                value: _valueOrDash(user.name),
                expand: true,
              ),
              _InfoTile(
                icon: Icons.verified_user_outlined,
                label: 'Peran',
                value: _roleDisplay,
                expand: true,
              ),
              _InfoTile(
                icon: Icons.alternate_email,
                label: 'Email',
                value: _valueOrDash(user.email),
                expand: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildStoreSection(User user) {
  //   final storeId = user.store?.id ?? user.storeId;
  //   final status = user.store?.status;
  //   return _SectionCard(
  //     icon: Icons.store_mall_directory_outlined,
  //     title: 'Toko & Akses',
  //     subtitle:
  //         'Informasi pengikatan akun ke outlet dan hak akses operasional.',
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Wrap(
  //           spacing: 16,
  //           runSpacing: 16,
  //           children: [
  //             _InfoTile(
  //               icon: Icons.storefront_outlined,
  //               label: 'Nama Toko',
  //               value: _valueOrDash(_storeName),
  //             ),
  //             _InfoTile(
  //               icon: Icons.key_outlined,
  //               label: 'ID Toko',
  //               value: _valueOrDash(storeId),
  //             ),
  //             _InfoTile(
  //               icon: Icons.verified_outlined,
  //               label: 'Status Toko',
  //               value: _valueOrDash(status),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _formatUserAge(DateTime? createdAt) {
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

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return _dateFormatter.format(value.toLocal());
  }

  String _valueOrDash(String? value) {
    if (value == null) return '-';
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '-';
    return trimmed;
  }
}

class _AvatarBadge extends StatelessWidget {
  final String? name;
  final String? email;

  const _AvatarBadge({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final initials = _resolveInitials(name ?? email);
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

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
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
          border: Border.all(color: Colors.black.withAlpha((0.05 * 255).round()), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
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
          const Text(
            'Gagal memuat profil',
            style: TextStyle(
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
