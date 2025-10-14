import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/components/spaces.dart';
import 'package:xpress/core/constants/colors.dart';

class MemberDialog extends StatefulWidget {
  final List<String> members;
  final String? initial;
  const MemberDialog({super.key, this.members = const [], this.initial});

  @override
  State<MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends State<MemberDialog> {
  final TextEditingController searchController = TextEditingController();
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final idx = widget.members
          .indexWhere((e) => e.toLowerCase() == widget.initial!.toLowerCase());
      if (idx >= 0) selectedIndex = idx;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.members
        .where((e) =>
            e.toLowerCase().contains(searchController.text.toLowerCase()))
        .toList();

    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('MEMBER',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 32, fontFamily: '')),
            IconButton(
              icon: Assets.icons.cancel
                  .svg(color: AppColors.grey, height: 32, width: 32),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      content: SizedBox(
        width: 480,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(
                          8.0), // optional: adjust padding as needed
                      child: Assets.icons.user.svg(
                          color: AppColors.greyLightActive,
                          height: 18,
                          width: 18),
                    ),
                    hintText: 'Cari Member',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SpaceHeight(12),
              Flexible(
                child: filtered.isEmpty
                    ? SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Assets.icons.user
                                  .svg(color: AppColors.grey, height: 128),
                              const SizedBox(height: 8),
                              Text('Tidak Ada Member',
                                  style: TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (_, i) {
                          final isSelected = selectedIndex == i;
                          return InkWell(
                            onTap: () => setState(() => selectedIndex = i),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryActive
                                    : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.primaryLight,
                                ),
                              ),
                              child: Text(filtered[i],
                                  style: TextStyle(
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.black,
                                      fontWeight: FontWeight.w600)),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SpaceHeight(8),
                        itemCount: filtered.length,
                      ),
              ),
              const SpaceHeight(16),
              Row(
                children: [
                  Expanded(
                    child: Button.outlined(
                      label: 'Kembali',
                      color: AppColors.greyLight,
                      borderColor: AppColors.grey,
                      textColor: AppColors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Button.filled(
                      color: AppColors.success,
                      label: 'Apply',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      onPressed: () => Navigator.pop(
                          context,
                          selectedIndex != null
                              ? filtered[selectedIndex!]
                              : null),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
