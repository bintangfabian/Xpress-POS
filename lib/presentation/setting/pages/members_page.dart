import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/data/datasources/member_remote_datasource.dart';
import 'package:xpress/data/models/response/member_response_model.dart';
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
                onPressed: () {
                  
                },
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MembersHeader(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: members.isEmpty
                        ? _MembersEmptyState(
                            controller: _listController,
                            message: _searchController.text.isEmpty
                                ? 'Belum ada member terdaftar.'
                                : 'Member tidak ditemukan untuk kata kunci tersebut.',
                          )
                        : Scrollbar(
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
                                  onDeleteTap: () {},
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
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('Nama', style: _style)),
          Expanded(flex: 2, child: Text('Email', style: _style)),
          Expanded(flex: 2, child: Text('Telepon', style: _style)),
          SizedBox(width: 80, child: Text('Aksi', style: _style)),
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
    return Scrollbar(
      controller: controller,
      child: ListView(
        controller: controller,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withOpacity(0.08),
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
    );
  }
}
