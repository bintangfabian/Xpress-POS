import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/models/response/member_response_model.dart';

class ManageMemberCard extends StatelessWidget {
  final Member data;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  const ManageMemberCard(
      {super.key, required this.data, this.onEditTap, this.onDeleteTap});

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
            flex: 2,
            child: _CellContent(
              icon: Assets.icons.user.svg(
                height: 24,
                width: 24,
                color: AppColors.primary,
              ),
              text: data.name ?? '-',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              data.email ?? '-',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              data.phone ?? '-',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(data.dateOfBirth),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  color: AppColors.primary,
                  icon: Assets.icons.editUnderline
                      .svg(height: 16, width: 16, color: AppColors.white),
                  onTap: onEditTap,
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

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(date);
      final monthNames = const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final month = monthNames[parsed.month - 1];
      final day = parsed.day.toString().padLeft(2, '0');
      return '$day $month ${parsed.year}';
    } catch (_) {
      return date;
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
