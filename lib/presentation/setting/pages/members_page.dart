import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/data/datasources/member_remote_datasource.dart';
import 'package:xpress/data/models/response/member_response_model.dart';
import 'package:xpress/presentation/setting/widgets/manage_member_card.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  late Future<List<Member>> _future;
  final TextEditingController _searchController = TextEditingController();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
                  icon: Assets.icons.addPerson.svg(height: 24, width: 24),
                  label: 'Tambah Member',
                  fontSize: 14,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<Member>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final members = _filteredMembers;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MembersHeader(),
                  const SizedBox(height: 16),
                  if (members.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada member terdaftar.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    ...members.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ManageMemberCard(
                          data: item,
                          onEditTap: () {},
                          onDeleteTap: () {},
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
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
          SizedBox(width: 12),
          Expanded(flex: 2, child: Text('Email', style: _style)),
          SizedBox(width: 12),
          Expanded(flex: 2, child: Text('Telepon', style: _style)),
          SizedBox(width: 12),
          SizedBox(width: 50, child: Text('Aksi', style: _style)),
        ],
      ),
    );
  }
}
