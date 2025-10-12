import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/presentation/setting/widgets/add_data.dart';
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

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Member>> _load() async {
    final res = await MemberRemoteDatasource().getMembers();
    return res.fold((l) => <Member>[], (r) => r.data ?? <Member>[]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Kelola Member'),
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
              final members = snapshot.data ?? [];
              return GridView.builder(
                shrinkWrap: true,
                itemCount: members.length + 1,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.85,
                  crossAxisCount: 3,
                  crossAxisSpacing: 30.0,
                  mainAxisSpacing: 30.0,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return AddData(
                      title: 'Tambah Member Baru',
                      onPressed: () {},
                    );
                  }
                  final item = members[index - 1];
                  return ManageMemberCard(
                    data: item,
                    onEditTap: () {},
                    onDeleteTap: () {},
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
