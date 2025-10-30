import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/data/datasources/member_remote_datasource.dart';
import 'package:xpress/data/models/response/member_response_model.dart';
import 'package:xpress/presentation/setting/dialogs/member_form_dialog.dart';
import 'package:xpress/presentation/setting/widgets/manage_member_card.dart';
import 'package:xpress/presentation/setting/widgets/loading_list_placeholder.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  late Future<List<Member>> _future;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listController = ScrollController();
  List<Member> _members = <Member>[];
  List<Member> _filteredMembers = <Member>[];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Member>> _load() async {
    final res = await MemberRemoteDatasource().getMembers();
    final data = res.fold((l) => <Member>[], (r) => r.data ?? <Member>[]);
    if (!mounted) return data;
    setState(() {
      _members = data;
      _filteredMembers = data;
    });
    return data;
  }

  void _onSearchChanged(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMembers = List<Member>.from(_members);
      } else {
        _filteredMembers = _members.where((member) {
          final name = (member.name ?? '').toLowerCase();
          final email = (member.email ?? '').toLowerCase();
          final phone = (member.phone ?? '').toLowerCase();
          return name.contains(query) ||
              email.contains(query) ||
              phone.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContentTitle('Kelola Member'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SearchInput(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Cari Member',
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 220,
              child: Button.filled(
                icon: Assets.icons.addPerson.svg(height: 20, width: 20),
                label: 'Tambah Member',
                fontSize: 16,
                onPressed: _openCreateMemberDialog,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: FutureBuilder<List<Member>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _MembersHeader(),
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
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error?.toString() ?? 'Gagal memuat data member.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              }
              final members = _filteredMembers;
              if (members.isEmpty) {
                return _MembersEmptyState(
                  controller: _listController,
                  message: _searchController.text.isEmpty
                      ? 'Belum ada member terdaftar.'
                      : 'Member tidak ditemukan untuk kata kunci tersebut.',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MembersHeader(),
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
                        itemCount: members.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = members[index];
                          return ManageMemberCard(
                            data: item,
                            onEditTap: () {},
                            onDeleteTap: () => _confirmDelete(item),
                            onRefresh: _refreshMembers,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openCreateMemberDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const MemberFormDialog(),
    );
    if (result == true) {
      _refreshMembers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member berhasil ditambahkan')),
      );
    }
  }

  Future<void> _refreshMembers() async {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _confirmDelete(Member member) async {
    final id = member.id;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID member tidak valid.')),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nonaktifkan Member',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                IconButton(
                  icon: Assets.icons.cancel.svg(
                    colorFilter:
                        ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
                    height: 32,
                    width: 32,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          content: SizedBox(
            width: context.deviceWidth / 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Apakah Anda yakin ingin menonaktifkan ${member.name ?? 'member'}? Member yang dinonaktifkan tidak akan muncul dalam daftar member aktif.',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
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
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button.filled(
                    label: 'Nonaktifkan',
                    color: AppColors.danger,
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
      // ignore: use_build_context_synchronously
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 800),
            content: Text('Menghapus member...'),
          ),
        );

      final result = await MemberRemoteDatasource().deleteMember(id);
      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      result.fold(
        (message) => messenger.showSnackBar(SnackBar(content: Text(message))),
        (_) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Member berhasil dinonaktifkan')),
          );
          _refreshMembers();
        },
      );
    }
  }
}

class _MembersHeader extends StatelessWidget {
  const _MembersHeader();

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
        border: Border.all(color: Colors.black.withAlpha((0.08 * 255).round())),
      ),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('Nama', style: _style)),
          // Expanded(flex: 2, child: Text('Email', style: _style)),
          Expanded(flex: 3, child: Text('Telepon', style: _style)),
          // Expanded(flex: 2, child: Text('Tanggal Lahir', style: _style)),
          Expanded(flex: 1, child: Text('Aksi', style: _style)),
        ],
      ),
    );
  }
}

class _MembersEmptyState extends StatelessWidget {
  final ScrollController controller;
  final String message;
  const _MembersEmptyState({
    required this.controller,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MembersHeader(),
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
                    border: Border.all(
                      color: Colors.black.withAlpha((0.08 * 255).round()),
                    ),
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
