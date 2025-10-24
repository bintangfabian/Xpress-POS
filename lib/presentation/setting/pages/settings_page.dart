import 'package:flutter/material.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/presentation/setting/pages/discount_page.dart';
import 'package:xpress/presentation/setting/pages/manage_printer_page.dart';
import 'package:xpress/presentation/setting/pages/sync_data_page.dart';
import 'package:xpress/presentation/setting/pages/store_settings_page.dart';
import 'package:xpress/presentation/setting/pages/user_profile_page.dart';
import 'package:xpress/presentation/setting/pages/members_page.dart';
import 'package:xpress/presentation/setting/pages/services_page.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/components/components.dart';
import '../../../core/constants/colors.dart';
import '../../auth/pages/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int currentIndex = 0;

  void indexValue(int index) {
    currentIndex = index;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // setRole();
  }

  // void setRole() {
  //   final ds = AuthLocalDataSource();
  //   ds.isAuthDataExists().then((exists) async {
  //     if (!mounted) return;
  //     if (!exists) {
  //       setState(() {
  //         role = null; // default to no role when not logged in
  //       });
  //       return;
  //     }
  //     try {
  //       final value = await ds.getAuthData();
  //       if (!mounted) return;
  //       setState(() {
  //         role = value.user?.role;
  //       });
  //     } catch (_) {
  //       if (!mounted) return;
  //       setState(() {
  //         role = null;
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 6),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            // LEFT CONTENT
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      const PageTitle(title: 'Pengaturan'),
                      const SpaceHeight(16.0),
                      MenuTile(
                        icon: Assets.icons.user,
                        title: 'Profil Pengguna',
                        subtitle: 'Lihat Informasi Akun',
                        active: currentIndex == 0,
                        onTap: () => indexValue(0),
                      ),
                      MenuTile(
                        icon: Assets.icons.settings,
                        title: 'Pengaturan Toko',
                        subtitle: 'Lihat Pengaturan Toko',
                        active: currentIndex == 1,
                        onTap: () => indexValue(1),
                      ),
                      MenuTile(
                        icon: Assets.icons.addPerson,
                        title: 'Kelola Member',
                        subtitle: 'Kelola Member Pelanggan',
                        active: currentIndex == 2,
                        onTap: () => indexValue(2),
                      ),
                      MenuTile(
                        icon: Assets.icons.percentange,
                        title: 'Kelola Diskon',
                        subtitle: 'Kelola Diskon Pelanggan',
                        active: currentIndex == 3,
                        onTap: () => indexValue(3),
                      ),

                      // MenuTile(
                      //   icon: Assets.icons.paste,
                      //   title: 'Kelola Layanan',
                      //   subtitle: 'Kelola Layanan Pelanggan',
                      //   active: currentIndex == 4,
                      //   onTap: () => indexValue(4),
                      // ),
                      MenuTile(
                        icon: Assets.icons.printer,
                        title: 'Kelola Printer',
                        subtitle: 'Tambah dan Hapus Printer',
                        active: currentIndex == 4,
                        onTap: () => indexValue(4),
                      ),
                      MenuTile(
                        icon: Assets.icons.sync,
                        title: 'Sinkronisasi Data',
                        subtitle: 'Sinkronisasi Data dengan Server',
                        active: currentIndex == 5,
                        onTap: () => indexValue(5),
                      ),
                      MenuTile(
                        icon: Assets.icons.logout,
                        title: 'Logout',
                        subtitle: 'Keluar dari Akun',
                        active: false,
                        isLogout: true,
                        onTap: () async {
                          // Clear local auth and navigate to Login
                          await AuthLocalDataSource().removeAuthData();
                          if (!mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // RIGHT CONTENT
            Expanded(
              flex: 4,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox.expand(
                    child: IndexedStack(
                      index: currentIndex,
                      children: [
                        const UserProfilePage(), // 0 Profil Pengguna
                        StoreSettingPage(), // 3 Kelola Pajak
                        const MembersPage(), // 1 Kelola Member
                        DiscountPage(), // 2 Kelola Diskon
                        // const ServicesPage(), // 4 Kelola Layanan
                        const ManagePrinterPage(), // 5 Kelola Printer
                        const SyncDataPage(), // 6 Sinkronisasi Data
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreContextPage extends StatefulWidget {
  @override
  State<_StoreContextPage> createState() => _StoreContextPageState();
}

class _StoreContextPageState extends State<_StoreContextPage> {
  final _controller = TextEditingController();
  String? _current;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await AuthLocalDataSource().getStoreUuid();
    if (!mounted) return;
    setState(() {
      _current = id;
      _controller.text = id ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Store Context',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Text('Store UUID saat ini: ${_current ?? '-'}'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Masukkan Store UUID',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                final v = _controller.text.trim();
                if (v.isEmpty) {
                  await AuthLocalDataSource().saveStoreUuid('');
                  if (!mounted) return;
                  setState(() => _current = null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Store UUID dikosongkan')),
                  );
                  return;
                }
                await AuthLocalDataSource().saveStoreUuid(v);
                if (!mounted) return;
                setState(() => _current = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Store UUID disimpan')),
                );
              },
              child: const Text('Simpan'),
            )
          ],
        )
      ],
    );
  }
}
