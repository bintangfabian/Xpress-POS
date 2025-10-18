import 'package:flutter/material.dart';
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
  String? _storeName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ds = AuthLocalDataSource();
      final auth = await ds.getAuthData();
      final storeUuid = await ds.getStoreUuid();
      if (!mounted) return;
      setState(() {
        _user = auth.user;
        _storeName =
            auth.user?.store?.name ?? auth.user?.storeId ?? storeUuid;
      });
      final identifier =
          auth.user?.store?.id ?? auth.user?.storeId ?? storeUuid;
      if (identifier != null && identifier.isNotEmpty) {
        await ds.saveStoreUuid(identifier);
      }
      await _refreshFromRemoteIfNeeded(ds, storeUuid);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _user = null;
        _storeName = null;
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
    if (!needsRemote) return;

    final token = await ds.getToken();
    if (token == null || token.isEmpty) return;

    final result = await AuthRemoteDatasource().fetchProfile(token);
    if (!mounted) return;
    await result.fold(
      (_) async {},
      (user) async {
        await ds.updateCachedUser(user);
        final identifier = user.store?.id ?? user.storeId;
        if (identifier != null && identifier.isNotEmpty) {
          await ds.saveStoreUuid(identifier);
        }
        final latestStoreUuid = await ds.getStoreUuid();
        if (!mounted) return;
        setState(() {
          _user = user;
          _storeName =
              user.store?.name ?? user.storeId ?? latestStoreUuid ?? cachedStoreUuid;
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Profil Pengguna'),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  border:
                      Border.all(width: 1, color: AppColors.greyLightActive),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Informasi Profil",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'Nama Toko',
                          value: _storeName ?? '-',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoCard(
                          label: 'Nama Cabang',
                          value: '-',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'Username',
                          value: _user?.name ?? '-',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoCard(
                          label: 'ROLE',
                          value: _roleDisplay,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _InfoCard(
                    label: 'Email',
                    value: _user?.email ?? '-',
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;
  const _InfoCard({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
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
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
