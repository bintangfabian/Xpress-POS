import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/models/response/member_response_model.dart';
import 'package:xpress/presentation/setting/dialogs/member_detail_dialog.dart';
import 'package:xpress/presentation/setting/dialogs/member_edit_dialog.dart';

class ManageMemberCard extends StatelessWidget {
  final Member data;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onRefresh;
  const ManageMemberCard({
    super.key,
    required this.data,
    this.onEditTap,
    this.onDeleteTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _CellContent(
              icon: Assets.icons.user.svg(
                height: 24,
                width: 24,
                color: AppColors.primary,
              ),
              text: data.name ?? '-',
            ),
          ),
          // const SizedBox(width: 12),
          // Expanded(
          //   flex: 2,
          //   child: Text(
          //     data.email ?? '-',
          //     style: const TextStyle(
          //       fontSize: 14,
          //       fontWeight: FontWeight.w600,
          //       color: AppColors.black,
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              data.phone ?? '-',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          // const SizedBox(width: 12),
          // Expanded(
          //   flex: 2,
          //   child: Text(
          //     _formatDate(data.dateOfBirth),
          //     style: const TextStyle(
          //       fontSize: 14,
          //       fontWeight: FontWeight.w600,
          //       color: AppColors.black,
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  color: AppColors.primaryLightActive,
                  icon: Assets.icons.eye
                      .svg(height: 16, width: 16, color: AppColors.black),
                  onTap: () => _showMemberDetail(context),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  color: AppColors.primary,
                  icon: Assets.icons.editUnderline
                      .svg(height: 16, width: 16, color: AppColors.white),
                  onTap: () => _showEditMember(context),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  color: AppColors.danger,
                  icon: Assets.icons.trash
                      .svg(height: 16, width: 16, color: AppColors.white),
                  onTap: onDeleteTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMemberDetail(BuildContext context) {
    if (data.id == null) return;

    showDialog(
      context: context,
      builder: (context) => MemberDetailDialog(memberId: data.id!),
    );
  }

  Future<void> _showEditMember(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MemberEditDialog(member: data),
    );

    if (result == true && onRefresh != null) {
      onRefresh!();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final Widget icon;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: icon,
      ),
    );
  }
}

class _CellContent extends StatelessWidget {
  final Widget icon;
  final String text;

  const _CellContent({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: icon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
